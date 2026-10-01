"""Génération des PDF de la formation Linux.

Lit pdf/documents.yaml et produit build/pdf/<fichier>.pdf. S'arrête à la
première erreur : aucun repli silencieux.
"""

from __future__ import annotations

import json
import subprocess
from dataclasses import dataclass
from pathlib import Path

import yaml

RACINE = Path(__file__).resolve().parent.parent
DOSSIER_PDF = Path(__file__).resolve().parent
CHAMPS_DOCUMENT = {"fichier", "titre", "sous_titre", "sources"}
FORMAT_MARKDOWN = "markdown+lists_without_preceding_blankline"


class ErreurBuild(Exception):
    """Erreur de génération, avec un message destiné à l'utilisateur."""


@dataclass(frozen=True)
class Document:
    fichier: str
    titre: str
    sources: tuple[Path, ...]
    sous_titre: str = ""


@dataclass(frozen=True)
class Catalogue:
    auteur: str
    documents: list[Document]


def charger_documents(chemin: Path, racine: Path) -> Catalogue:
    """Lit et valide le catalogue des PDF à produire."""
    try:
        donnees = yaml.safe_load(chemin.read_text(encoding="utf-8"))
    except yaml.YAMLError as erreur:
        raise ErreurBuild(f"{chemin} : YAML invalide : {erreur}") from erreur
    if not isinstance(donnees, dict):
        raise ErreurBuild(f"{chemin} : un dictionnaire est attendu")

    auteur = donnees.get("auteur")
    if not isinstance(auteur, str) or not auteur:
        raise ErreurBuild(f"{chemin} : champ 'auteur' manquant")
    entrees = donnees.get("documents")
    if not isinstance(entrees, list) or not entrees:
        raise ErreurBuild(f"{chemin} : liste 'documents' manquante ou vide")

    documents: list[Document] = []
    for numero, entree in enumerate(entrees, start=1):
        documents.append(_lire_document(entree, f"{chemin}, document {numero}", racine))

    vus: set[str] = set()
    for document in documents:
        if document.fichier in vus:
            raise ErreurBuild(f"{chemin} : '{document.fichier}' déclaré deux fois")
        vus.add(document.fichier)
    return Catalogue(auteur, documents)


def _lire_document(entree: object, contexte: str, racine: Path) -> Document:
    if not isinstance(entree, dict):
        raise ErreurBuild(f"{contexte} : un dictionnaire est attendu")
    inconnus = sorted(set(entree) - CHAMPS_DOCUMENT)
    if inconnus:
        raise ErreurBuild(f"{contexte} : champ(s) inconnu(s) : {', '.join(inconnus)}")
    for champ in ("fichier", "titre", "sources"):
        if not entree.get(champ):
            raise ErreurBuild(f"{contexte} : champ '{champ}' manquant")

    fichier = entree["fichier"]
    if not fichier.endswith(".pdf") or "/" in fichier:
        raise ErreurBuild(f"{contexte} : '{fichier}' doit se terminer par .pdf, sans dossier")
    sources = []
    for source in entree["sources"]:
        chemin = racine / source
        if not chemin.is_file():
            raise ErreurBuild(f"{contexte} : source introuvable : {source}")
        sources.append(chemin)
    return Document(fichier, entree["titre"], tuple(sources), entree.get("sous_titre", ""))


def executer(commande: list[str], entree: str | None = None, cwd: Path | None = None) -> str:
    """Lance une commande, renvoie sa sortie ; lève ErreurBuild en cas d'échec."""
    resultat = subprocess.run(
        commande, input=entree, capture_output=True, text=True, cwd=cwd, check=False
    )
    if resultat.returncode != 0:
        raise ErreurBuild(f"échec de : {' '.join(commande)}\n{resultat.stderr.strip()}")
    return resultat.stdout


def titres_niveau1(source: Path) -> list[str]:
    """Titres de niveau 1 d'un fichier Markdown, tels que pandoc les rendra."""
    ast = json.loads(executer(["pandoc", "-f", FORMAT_MARKDOWN, "-t", "json", str(source)]))
    titres = []
    for bloc in ast["blocks"]:
        if bloc["t"] == "Header" and bloc["c"][0] == 1:
            titre = {
                "pandoc-api-version": ast["pandoc-api-version"],
                "meta": {},
                "blocks": [{"t": "Plain", "c": bloc["c"][2]}],
            }
            texte = executer(
                ["pandoc", "-f", "json", "-t", "plain", "--wrap=none"], entree=json.dumps(titre)
            )
            titres.append(texte.strip())
    return titres


def titre_chapitre(source: Path) -> str:
    """Titre unique d'un fichier source (règle : exactement un titre de niveau 1)."""
    titres = titres_niveau1(source)
    if len(titres) != 1:
        raise ErreurBuild(f"{source} : {len(titres)} titre(s) de niveau 1, exactement 1 attendu")
    return titres[0]
