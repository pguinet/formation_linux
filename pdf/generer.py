"""Génération des PDF de la formation Linux.

Lit pdf/documents.yaml et produit build/pdf/<fichier>.pdf. S'arrête à la
première erreur : aucun repli silencieux.
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

import yaml

RACINE = Path(__file__).resolve().parent.parent
DOSSIER_PDF = Path(__file__).resolve().parent
CHAMPS_DOCUMENT = {"fichier", "titre", "sous_titre", "sources"}
FORMAT_MARKDOWN = "markdown+lists_without_preceding_blankline"
LOGO_LICENCE = RACINE / "ressources" / "images" / "licenses" / "cc-by-nc-sa.png"
_ECHAPPEMENTS_LATEX = {
    "\\": r"\textbackslash{}",
    "&": r"\&",
    "%": r"\%",
    "$": r"\$",
    "#": r"\#",
    "_": r"\_",
    "{": r"\{",
    "}": r"\}",
    "~": r"\textasciitilde{}",
    "^": r"\textasciicircum{}",
}


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
    for champ in ("fichier", "titre", "sous_titre"):
        if not isinstance(entree.get(champ, ""), str):
            raise ErreurBuild(f"{contexte} : champ '{champ}' : chaîne attendue")
    if not isinstance(entree["sources"], list) or not all(
        isinstance(source, str) for source in entree["sources"]
    ):
        raise ErreurBuild(f"{contexte} : champ 'sources' : liste de chemins attendue")

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


def echapper_latex(texte: str) -> str:
    return "".join(_ECHAPPEMENTS_LATEX.get(caractere, caractere) for caractere in texte)


def generer_couverture(document: Document, chapitres: list[str], logo: Path) -> str:
    """Page de couverture LaTeX : titre, liste des chapitres, licence."""
    sous_titre = (
        rf"\vspace{{0.5cm}}{{\Large {echapper_latex(document.sous_titre)}\par}}"
        if document.sous_titre
        else ""
    )
    items = "\n".join(rf"\item{{}} {echapper_latex(chapitre)}" for chapitre in chapitres)
    return rf"""\begin{{titlepage}}
\centering
\vspace*{{3cm}}
{{\Large Formation Linux\par}}
\vspace{{1cm}}
{{\Huge\bfseries {echapper_latex(document.titre)}\par}}
{sous_titre}
\vspace{{2cm}}
\begin{{minipage}}{{0.8\textwidth}}
\begin{{itemize}}
{items}
\end{{itemize}}
\end{{minipage}}
\vfill
\includegraphics[width=3cm]{{{logo}}}\par
\vspace{{0.3cm}}
{{\small Ce document est mis à disposition selon les termes de la licence
Creative Commons Attribution -- Pas d'Utilisation Commerciale -- Partage dans
les Mêmes Conditions 4.0 International (CC BY-NC-SA 4.0).\par}}
\end{{titlepage}}
"""


def commande_pandoc(document: Document, auteur: str, couverture: Path, sortie: Path) -> list[str]:
    """Commande pandoc Markdown -> LaTeX autonome pour un document."""
    return [
        "pandoc",
        "-f",
        FORMAT_MARKDOWN,
        # Sans « -smart », l'écrivain LaTeX réécrit ’ “ ” — en ' `` '' --- :
        # le texte imprimé n'y perd rien, mais les signets du PDF si.
        "--to",
        "latex-smart",
        "--standalone",
        "--output",
        str(sortie),
        "--top-level-division=chapter",
        "--toc",
        "--toc-depth=2",
        "--syntax-highlighting=tango",
        "-V",
        "documentclass=report",
        "-V",
        "papersize=a4",
        "-V",
        "geometry:margin=2.2cm",
        "-V",
        "lang=fr",
        "-V",
        "monofont=DejaVu Sans Mono",
        "-V",
        "monofontoptions=Scale=0.85",
        "-V",
        "monofontoptions=ItalicFont=DejaVu Sans Mono Oblique",
        "-V",
        "monofontoptions=BoldItalicFont=DejaVu Sans Mono Bold Oblique",
        "-M",
        f"title-meta={document.titre}",
        "-M",
        f"author-meta={auteur}",
        "--include-in-header",
        str(DOSSIER_PDF / "preambule.tex"),
        "--include-before-body",
        str(couverture),
        *[str(source) for source in document.sources],
    ]


def erreurs_latex(log: str) -> list[str]:
    """Lignes d'erreur d'un log LaTeX (avec deux lignes de contexte), 30 au plus."""
    lignes = log.splitlines()
    erreurs: list[str] = []
    for index, ligne in enumerate(lignes):
        if ligne.startswith("!") or "Missing character" in ligne or re.match(r"^\S+:\d+: ", ligne):
            erreurs.extend(lignes[index : index + 3])
    return erreurs[:30]


def compiler(tex: Path) -> Path:
    """Compile un .tex avec latexmk/LuaLaTeX ; lève ErreurBuild au moindre problème."""
    resultat = subprocess.run(
        [
            "latexmk",
            "-lualatex",
            "-interaction=nonstopmode",
            "-halt-on-error",
            "-file-line-error",
            tex.name,
        ],
        cwd=tex.parent,
        capture_output=True,
        text=True,
        check=False,
    )
    log = tex.with_suffix(".log")
    texte_log = log.read_text(encoding="utf-8", errors="replace") if log.exists() else ""
    erreurs = erreurs_latex(texte_log)
    if resultat.returncode != 0 or erreurs:
        sorties = (resultat.stdout + resultat.stderr).splitlines()
        detail = "\n".join(erreurs) or "\n".join(sorties[-30:])
        chemin_log = log.relative_to(RACINE) if log.is_relative_to(RACINE) else log
        raise ErreurBuild(
            f"échec LaTeX pour {tex.name} (log complet : {chemin_log})\n{detail}\n"
            "si l'erreur paraît incohérente : rm -rf build/pdf/debug"
        )
    return tex.with_suffix(".pdf")


def construire(document: Document, auteur: str, sortie: Path) -> Path:
    """Produit sortie/<fichier> ; les intermédiaires restent dans sortie/debug/."""
    debug = sortie / "debug"
    debug.mkdir(parents=True, exist_ok=True)
    pdf = sortie / document.fichier
    pdf.unlink(missing_ok=True)
    nom = Path(document.fichier).stem
    chapitres = [titre_chapitre(source) for source in document.sources]
    couverture = debug / f"{nom}-couverture.tex"
    couverture.write_text(generer_couverture(document, chapitres, LOGO_LICENCE), encoding="utf-8")
    tex = debug / f"{nom}.tex"
    executer(commande_pandoc(document, auteur, couverture, tex))
    shutil.copy2(compiler(tex), pdf)
    return pdf


def selectionner(documents: list[Document], fichiers: list[str]) -> list[Document]:
    if not fichiers:
        return documents
    connus = {document.fichier: document for document in documents}
    inconnus = [fichier for fichier in fichiers if fichier not in connus]
    if inconnus:
        raise ErreurBuild(f"document(s) inconnu(s) : {', '.join(inconnus)}")
    return [connus[fichier] for fichier in fichiers]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("fichiers", nargs="*", help="PDF à produire (tous par défaut)")
    parser.add_argument("--sortie", type=Path, default=RACINE / "build" / "pdf")
    args = parser.parse_args(argv)
    try:
        catalogue = charger_documents(DOSSIER_PDF / "documents.yaml", RACINE)
        documents = selectionner(catalogue.documents, args.fichiers)
        for document in documents:
            print(f"-> {document.fichier}", flush=True)
            construire(document, catalogue.auteur, args.sortie)
    except ErreurBuild as erreur:
        print(f"ERREUR : {erreur}", file=sys.stderr)
        return 1
    print(f"{len(documents)} PDF produit(s) dans {args.sortie}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
