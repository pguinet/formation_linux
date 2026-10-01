#!/usr/bin/env python3
"""Pilote l'installeur graphique de Debian 13 sous QEMU/KVM et capture
chaque écran significatif.

Exécuté dans le conteneur décrit par le Dockerfile voisin (voir
capturer.sh). Principe :

- QEMU tourne sans affichage, avec un moniteur QMP sur socket Unix ;
- chaque étape envoie des touches (QMP send-key), puis attend l'écran
  suivant : l'écran doit être stable (captures successives quasi
  identiques) et contenir un texte attendu, reconnu par OCR (tesseract) ;
- si l'écran attendu ne vient pas dans le délai imparti, le script
  s'arrête en nommant l'étape et en conservant la dernière capture.

Volumes attendus :
  /work    dossier de travail (build/captures/debian) : disque, socket,
           captures brutes, journal ; l'ISO est dans /work/cache
  /sortie  dossier des PNG finaux (ressources/images/installation)
"""

from __future__ import annotations

import json
import os
import shutil
import socket
import subprocess
import sys
import time
import unicodedata
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageChops

TRAVAIL = Path(os.environ.get("TRAVAIL", "/work"))
SORTIE = Path(os.environ.get("SORTIE", "/sortie"))
ISO = TRAVAIL / "cache" / os.environ.get("ISO_NOM", "debian-13.7.0-amd64-DVD-1.iso")
DISQUE = TRAVAIL / "debian.qcow2"
SOCKET_QMP = TRAVAIL / "qmp.sock"
BRUT = TRAVAIL / "brut"
JOURNAL = TRAVAIL / "piloter.log"

# Seuils de comparaison d'images (en pixels différents).
SEUIL_STABLE = 400  # curseur clignotant, petites animations
PERIODE = 1.0  # secondes entre deux captures de surveillance


def journal(message: str) -> None:
    ligne = f"[{time.strftime('%H:%M:%S')}] {message}"
    print(ligne, flush=True)
    with JOURNAL.open("a", encoding="utf-8") as f:
        f.write(ligne + "\n")


class Echec(RuntimeError):
    """Écran attendu non obtenu."""


# --------------------------------------------------------------------------
# QMP
# --------------------------------------------------------------------------


class Qmp:
    def __init__(self, chemin: Path, delai: float = 30.0) -> None:
        fin = time.monotonic() + delai
        while True:
            try:
                self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                self.sock.connect(str(chemin))
                break
            except OSError:
                if time.monotonic() > fin:
                    raise Echec(f"socket QMP {chemin} injoignable") from None
                time.sleep(0.5)
        self.fichier = self.sock.makefile("rwb")
        self._lire()  # bannière
        self.commande("qmp_capabilities")

    def _lire(self) -> dict:
        while True:
            ligne = self.fichier.readline()
            if not ligne:
                raise Echec("connexion QMP fermée (QEMU arrêté ?)")
            message = json.loads(ligne)
            if "event" not in message:
                return message

    def commande(self, nom: str, **arguments) -> object:
        requete = {"execute": nom}
        if arguments:
            requete["arguments"] = arguments
        self.fichier.write(json.dumps(requete).encode() + b"\n")
        self.fichier.flush()
        reponse = self._lire()
        if "error" in reponse:
            raise Echec(f"QMP {nom} : {reponse['error']}")
        return reponse.get("return")


# --------------------------------------------------------------------------
# Clavier
# --------------------------------------------------------------------------

# Disposition de la machine invitée au moment de la saisie : QMP envoie
# des touches physiques (codes de la disposition US), la machine invitée
# les interprète selon sa propre disposition.
AZERTY = {
    "a": ["q"],
    "q": ["a"],
    "z": ["w"],
    "w": ["z"],
    "m": ["semicolon"],
    "-": ["6"],
    " ": ["spc"],
    ".": ["shift", "comma"],
}
QWERTY = {"-": ["minus"], " ": ["spc"], ".": ["dot"]}


class Clavier:
    def __init__(self, qmp: Qmp) -> None:
        self.qmp = qmp
        self.disposition = QWERTY

    def touches(self, *combinaisons: str, pause: float = 0.15) -> None:
        """Envoie des touches : 'ret', 'tab', 'shift-tab', 'ctrl-alt-t'..."""
        for combinaison in combinaisons:
            codes = combinaison.split("-") if combinaison != "minus" else [combinaison]
            self._envoyer(codes)
            time.sleep(pause)

    def _envoyer(self, codes: list[str]) -> None:
        self.qmp.commande(
            "send-key",
            keys=[{"type": "qcode", "data": c} for c in codes],
            **{"hold-time": 60},
        )

    def taper(self, texte: str) -> None:
        for caractere in texte:
            if caractere in self.disposition:
                codes = self.disposition[caractere]
            elif caractere.isalnum() and caractere.isascii():
                codes = [caractere.lower()]
                if caractere.isupper():
                    codes = ["shift", *codes]
            else:
                raise ValueError(f"caractère non géré : {caractere!r}")
            self._envoyer(codes)
            time.sleep(0.08)


# --------------------------------------------------------------------------
# Écran
# --------------------------------------------------------------------------


def normaliser(texte: str) -> str:
    sans_accents = unicodedata.normalize("NFKD", texte)
    sans_accents = "".join(c for c in sans_accents if not unicodedata.combining(c))
    return " ".join(sans_accents.lower().split())


def pixels_differents(a: Image.Image, b: Image.Image) -> int:
    if a.size != b.size:
        return a.size[0] * a.size[1]
    masque = ImageChops.difference(a, b).convert("L").point(lambda v: 255 if v else 0)
    return masque.histogram()[255]


def ocr(image: Image.Image) -> str:
    # Agrandir améliore nettement la reconnaissance des petites polices.
    agrandie = image.convert("L").resize((image.width * 2, image.height * 2))
    chemin = BRUT / "_ocr.png"
    agrandie.save(chemin)
    resultat = subprocess.run(
        ["tesseract", str(chemin), "-", "-l", "fra"],
        capture_output=True,
        text=True,
        check=False,
    )
    return normaliser(resultat.stdout)


def progression(image: Image.Image) -> float:
    """Remplissage (0 à 1) de la barre de progression de l'installeur
    graphique (1280x800) : pixels bleus sur la ligne médiane de la barre."""
    debut, fin, ligne = 73, 1207, 196
    bleus = 0
    for x in range(debut, fin):
        r, _, b = image.getpixel((x, ligne))
        if b > r + 50:
            bleus += 1
    return bleus / (fin - debut)


@dataclass
class Capture:
    fichier: str
    description: str


class Ecran:
    def __init__(self, qmp: Qmp) -> None:
        self.qmp = qmp
        self.compteur = 0
        self.derniere: Image.Image | None = None
        self.captures: list[Capture] = []

    def instantane(self) -> Image.Image:
        self.compteur += 1
        chemin = BRUT / f"_instantane{self.compteur % 2}.png"
        self.qmp.commande("screendump", filename=str(chemin), format="png")
        image = Image.open(chemin).convert("RGB")
        image.load()
        return image

    def attendre(
        self,
        etape: str,
        textes: list[str],
        delai: float,
        absents: list[str] | None = None,
        stable: float = 2.0,
    ) -> Image.Image:
        """Attend un écran stable contenant l'un des textes (OCR normalisé)
        et aucun des textes « absents ». Lève Echec après `delai` secondes."""
        attendus = [normaliser(t) for t in textes]
        exclus = [normaliser(t) for t in (absents or [])]
        debut = time.monotonic()
        precedente = self.instantane()
        stable_depuis = time.monotonic()
        derniere_lue: Image.Image | None = None
        texte = ""
        while True:
            time.sleep(PERIODE)
            image = self.instantane()
            if pixels_differents(image, precedente) > SEUIL_STABLE:
                stable_depuis = time.monotonic()
            precedente = image
            nouveau = derniere_lue is None or pixels_differents(image, derniere_lue) > SEUIL_STABLE
            if time.monotonic() - stable_depuis >= stable and nouveau:
                texte = ocr(image)
                derniere_lue = image
                if any(t in texte for t in attendus) and not any(t in texte for t in exclus):
                    duree = time.monotonic() - debut
                    journal(f"{etape} : écran obtenu en {duree:.0f} s")
                    self.derniere = image
                    return image
            if time.monotonic() - debut > delai:
                echec = TRAVAIL / f"echec-{etape}.png"
                image.save(echec)
                raise Echec(
                    f"étape « {etape} » : écran attendu ({' | '.join(textes)}) "
                    f"non obtenu en {delai:.0f} s. Dernière capture : {echec}. "
                    f"Texte lu : {texte[:400]!r}"
                )

    def capturer(self, nom: str, description: str) -> None:
        assert self.derniere is not None
        numero = len(self.captures) + 1
        fichier = f"debian-{numero:02d}-{nom}.png"
        self.derniere.save(BRUT / fichier)
        self.captures.append(Capture(fichier, description))
        journal(f"capture {fichier} : {description}")


# --------------------------------------------------------------------------
# QEMU
# --------------------------------------------------------------------------


def lancer_qemu(installation: bool) -> subprocess.Popen:
    if SOCKET_QMP.exists():
        SOCKET_QMP.unlink()
    commande = [
        "qemu-system-x86_64",
        "-enable-kvm",
        "-cpu",
        "host",
        "-smp",
        "2",
        "-m",
        "4096",
        "-machine",
        "pc",
        "-device",
        "ahci,id=ahci",
        "-drive",
        f"file={DISQUE},if=none,id=disque,format=qcow2",
        "-device",
        "ide-hd,drive=disque,bus=ahci.0",
        "-drive",
        f"file={ISO},if=none,id=dvd,media=cdrom,readonly=on",
        "-device",
        "ide-cd,drive=dvd,bus=ahci.1",
        "-netdev",
        "user,id=reseau",
        "-device",
        "e1000,netdev=reseau",
        "-vga",
        "std",
        "-display",
        "none",
        "-qmp",
        f"unix:{SOCKET_QMP},server=on,wait=off",
        "-usb",
        "-device",
        "usb-tablet",
    ]
    if installation:
        commande += ["-boot", "once=d"]
    journal("lancement : " + " ".join(commande))
    return subprocess.Popen(commande, stdout=JOURNAL.open("a"), stderr=subprocess.STDOUT)


# --------------------------------------------------------------------------
# Scénario
# --------------------------------------------------------------------------

LONG = 900  # étapes de copie/installation de base
TRES_LONG = 5400  # installation des logiciels (GNOME)


def scenario(qmp: Qmp, ecran: Ecran, clavier: Clavier) -> None:
    attendre, capturer, touches = ecran.attendre, ecran.capturer, clavier.touches

    def cacher_pointeur() -> None:
        """Place le pointeur de la tablette USB dans le coin inférieur droit.

        Deux positions successives : une position identique à la précédente
        ne produit aucun événement (cas d'une nouvelle session graphique)."""
        for valeur in (32000, 32767):
            qmp.commande(
                "input-send-event",
                events=[
                    {"type": "abs", "data": {"axis": "x", "value": valeur}},
                    {"type": "abs", "data": {"axis": "y", "value": valeur}},
                ],
            )
            time.sleep(0.2)

    def cliquer(x: int, y: int) -> None:
        """Clic gauche aux coordonnées (x, y) d'un écran 1280x800."""
        position = [
            {"type": "abs", "data": {"axis": "x", "value": x * 32767 // 1279}},
            {"type": "abs", "data": {"axis": "y", "value": y * 32767 // 799}},
        ]
        qmp.commande("input-send-event", events=position)
        time.sleep(0.3)
        for appui in (True, False):
            evenement = {"type": "btn", "data": {"button": "left", "down": appui}}
            qmp.commande("input-send-event", events=[evenement])
            time.sleep(0.1)

    def attendre_progression(etape, textes, seuil, delai) -> None:
        """Attend un écran de progression dont la barre dépasse `seuil`."""
        fin = time.monotonic() + delai
        while True:
            reste = fin - time.monotonic()
            if reste <= 0:
                raise Echec(
                    f"étape « {etape} » : progression {seuil:.0%} non atteinte en {delai} s"
                )
            attendre(etape, textes, reste, stable=1.0)
            if progression(ecran.derniere) >= seuil:
                return
            time.sleep(5)

    def etape(
        etape, textes, nom, description, delai=300, absents=None, avant=None, valider=("ret",)
    ):
        """Attend l'écran, applique les saisies `avant`, capture, valide."""
        attendre(etape, textes, delai, absents)
        if avant:
            avant()
            attendre(etape, textes, 60, absents)
        capturer(nom, description)
        touches(*valider)

    # --- Démarrage sur le DVD -------------------------------------------
    # Le menu affiche un compte à rebours (synthèse vocale au bout de 30 s) :
    # pas d'exigence de stabilité, puis une flèche l'arrête.
    attendre("menu", ["installer menu (bios mode)"], 120, stable=0.0)
    touches("down", "up")
    etape(
        "menu",
        ["installer menu (bios mode)"],
        "menu-demarrage",
        "menu de démarrage du DVD (BIOS), « Graphical install » sélectionné",
        delai=30,
    )

    # --- Langue, pays, clavier (disposition US jusqu'au choix du clavier) --
    attendre("langue", ["select a language"], 300)
    cacher_pointeur()
    etape(
        "langue",
        ["select a language"],
        "langue",
        "choix de la langue : French - Français",
        avant=lambda: touches("down", "down", "down", "down"),
    )
    etape("pays", ["situation geographique"], "pays", "choix du pays : France")
    etape("clavier", ["configurer le clavier"], "clavier", "disposition du clavier : Français")
    clavier.disposition = AZERTY

    # --- Réseau ------------------------------------------------------------
    etape(
        "nom-machine",
        ["veuillez indiquer le nom de ce systeme"],
        "nom-machine",
        "nom de machine : debian-formation",
        delai=600,
        avant=lambda: clavier.taper("debian-formation"),
    )
    etape("domaine", ["le domaine est la partie"], "domaine", "nom de domaine laissé vide")

    # --- Comptes -----------------------------------------------------------
    def mots_de_passe() -> None:
        clavier.taper("cid")
        touches("tab", "tab")  # la case « Afficher le mot de passe » est sautée
        clavier.taper("cid")

    etape(
        "root",
        ["mot de passe du superutilisateur"],
        "mot-de-passe-root",
        "mot de passe du superutilisateur root (cid), saisi deux fois",
        avant=mots_de_passe,
    )
    etape(
        "nom-complet",
        ["nom complet du nouvel utilisateur"],
        "nom-complet",
        "nom complet du nouvel utilisateur : cid",
        avant=lambda: clavier.taper("cid"),
    )
    etape(
        "identifiant",
        ["identifiant pour le compte"],
        "identifiant",
        "identifiant du compte utilisateur : cid (proposé)",
    )
    etape(
        "mdp-utilisateur",
        ["mot de passe pour le nouvel utilisateur"],
        "mot-de-passe-utilisateur",
        "mot de passe de l'utilisateur cid (cid), saisi deux fois",
        avant=mots_de_passe,
    )

    # --- Partitionnement ---------------------------------------------------
    etape(
        "methode",
        ["methode de partitionnement"],
        "partitionnement-methode",
        "partitionnement assisté : utiliser un disque entier",
    )
    etape(
        "disque",
        ["disque a partitionner"],
        "partitionnement-disque",
        "choix du disque à partitionner (sda, 32,2 Go)",
    )
    etape(
        "schema",
        ["dans le doute, choisissez le premier"],
        "partitionnement-schema",
        "schéma : tout dans une seule partition",
    )
    etape(
        "resume",
        ["voici la table des partitions"],
        "partitionnement-resume",
        "résumé : terminer le partitionnement et appliquer les changements",
    )
    etape(
        "confirmation",
        ["appliquer les changements sur les disques"],
        "partitionnement-confirmation",
        "confirmation de l'écriture sur le disque : Oui",
        avant=lambda: touches("down"),
    )

    # --- Système de base ---------------------------------------------------
    attendre_progression("base", ["installation du systeme de base"], 0.3, LONG)
    capturer("installation-base", "progression : installation du système de base")

    # --- Outil de gestion des paquets --------------------------------------
    etape(
        "autres-supports",
        ["analyser d'autres supports"],
        "autres-supports",
        "analyser d'autres supports : Non",
        delai=LONG,
    )
    etape(
        "miroir",
        ["utiliser un miroir sur le reseau"],
        "miroir-reseau",
        "utiliser un miroir sur le réseau : Oui",
        avant=lambda: touches("down"),
    )
    etape("pays-miroir", ["pays du miroir"], "miroir-pays", "pays du miroir : France")
    etape(
        "miroir-choix", ["generalement, deb.debian.org"], "miroir-choix", "miroir : deb.debian.org"
    )
    etape("mandataire", ["mandataire http"], "mandataire", "mandataire HTTP laissé vide")

    # --- Popularité, logiciels ---------------------------------------------
    etape(
        "popcon",
        ["popularity-contest", "etude statistique"],
        "popularite",
        "enquête de popularité des paquets : Non",
        delai=LONG,
    )

    def cocher_ssh() -> None:
        touches(*["down"] * 10)
        touches("spc")

    # Entrée sur la liste basculerait la case : Tab vers « Continuer ».
    etape(
        "logiciels",
        ["logiciels a installer"],
        "logiciels",
        "sélection des logiciels : bureau Debian, GNOME, serveur SSH, utilitaires usuels",
        delai=LONG,
        avant=cocher_ssh,
        valider=("tab", "ret"),
    )

    attendre_progression(
        "logiciels-progression", ["choisir et installer des logiciels"], 0.4, TRES_LONG
    )
    capturer("installation-logiciels", "progression : choisir et installer des logiciels")

    # --- GRUB et fin -------------------------------------------------------
    etape(
        "grub",
        ["grub sur le disque principal ?"],
        "grub",
        "installer GRUB sur le disque principal : Oui",
        delai=TRES_LONG,
    )
    etape(
        "grub-disque",
        ["peripherique ou sera installe"],
        "grub-disque",
        "périphérique d'installation de GRUB : /dev/sda",
        avant=lambda: touches("down"),
    )
    etape(
        "fin",
        ["installation est terminee"],
        "fin-installation",
        "fin de l'installation : redémarrage",
        delai=LONG,
    )

    # --- Premier démarrage -------------------------------------------------
    # GRUB n'attend que 5 s : on surveille sans exiger de stabilité longue,
    # puis une flèche arrête le compte à rebours.
    attendre("grub-menu", ["gnu grub"], 600, stable=0.0)
    touches("down", "up")
    attendre("grub-menu", ["gnu grub"], 30)
    capturer("menu-grub", "premier démarrage : menu GRUB")
    touches("ret")

    attendre("connexion", ["absent de la liste"], 900)
    cacher_pointeur()
    attendre("connexion", ["absent de la liste"], 60)
    capturer("connexion", "écran de connexion GNOME : utilisateur cid")
    # Le focus clavier initial de GDM varie : clic sur l'utilisateur.
    cliquer(640, 349)
    cacher_pointeur()
    attendre("connexion-mdp", ["cid"], 120, absents=["absent de la liste"])
    clavier.taper("cid")
    attendre("connexion-mdp", ["cid"], 60, absents=["absent de la liste"])
    capturer("connexion-mot-de-passe", "saisie du mot de passe de cid")
    touches("ret")

    # --- Session GNOME -----------------------------------------------------
    attendre("bienvenue", ["bienvenue dans debian"], 600)
    cacher_pointeur()
    attendre("bienvenue", ["bienvenue dans debian"], 60)
    capturer("bienvenue", "première session : fenêtre de bienvenue (Passer)")
    touches("ret")
    # Vue d'ensemble des activités : peu de texte lisible, on attend la
    # disparition de la fenêtre de bienvenue.
    attendre("activites", [""], 120, absents=["bienvenue", "visite guidee"])
    cacher_pointeur()
    attendre("activites", [""], 30, absents=["bienvenue", "visite guidee"])
    capturer("bureau", "bureau GNOME : vue d'ensemble des activités")
    clavier.taper("terminal")
    attendre("recherche", ["terminal"], 120)
    capturer("recherche-terminal", "recherche de l'application Terminal")
    touches("ret")
    attendre("terminal", ["cid@debian-formation"], 120)
    capturer("terminal", "terminal ouvert : invite cid@debian-formation")

    qmp.commande("system_powerdown")


def finaliser(ecran: Ecran) -> None:
    """Optimise les PNG, les copie dans /sortie et écrit la liste."""
    SORTIE.mkdir(parents=True, exist_ok=True)
    for ancien in SORTIE.glob("debian-*.png"):
        ancien.unlink()
    for capture in ecran.captures:
        source = BRUT / capture.fichier
        cible = SORTIE / capture.fichier
        subprocess.run(
            [
                "pngquant",
                "--quality=80-98",
                "--speed",
                "1",
                "--force",
                "--output",
                str(cible),
                str(source),
            ],
            check=False,
        )
        if not cible.exists():  # qualité non atteinte : PNG sans perte
            shutil.copy(source, cible)
        subprocess.run(["optipng", "-quiet", "-o2", str(cible)], check=True)
    lignes = [
        "# Captures de l'installeur Debian 13.7 (DVD-1), générées par",
        "# outils/captures/debian/capturer.sh ; ne pas modifier à la main.",
        "",
    ]
    lignes += [f"{c.fichier} -> {c.description}" for c in ecran.captures]
    (SORTIE / "debian-captures.txt").write_text("\n".join(lignes) + "\n", encoding="utf-8")
    journal(f"{len(ecran.captures)} captures écrites dans {SORTIE}")


def main() -> int:
    BRUT.mkdir(parents=True, exist_ok=True)
    JOURNAL.write_text("", encoding="utf-8")
    if not ISO.exists():
        journal(f"ISO absente : {ISO}")
        return 2
    if DISQUE.exists():
        DISQUE.unlink()
    subprocess.run(["qemu-img", "create", "-q", "-f", "qcow2", str(DISQUE), "30G"], check=True)
    qemu = lancer_qemu(installation=True)
    try:
        qmp = Qmp(SOCKET_QMP)
        ecran = Ecran(qmp)
        clavier = Clavier(qmp)
        scenario(qmp, ecran, clavier)
        finaliser(ecran)
    except Echec as erreur:
        journal(f"ÉCHEC : {erreur}")
        return 1
    finally:
        if qemu.poll() is None:
            qemu.terminate()
            try:
                qemu.wait(timeout=30)
            except subprocess.TimeoutExpired:
                qemu.kill()
    return 0


if __name__ == "__main__":
    sys.exit(main())
