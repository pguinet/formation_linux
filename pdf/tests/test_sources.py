"""Vérifications des sources Markdown du catalogue."""

import json

import generer

CATALOGUE = generer.charger_documents(generer.DOSSIER_PDF / "documents.yaml", generer.RACINE)
SOURCES = sorted({source for document in CATALOGUE.documents for source in document.sources})
# Sans « smart », pandoc garde « -- » tel quel : on peut le repérer dans l'AST.
FORMAT_SANS_TYPOGRAPHIE = f"{generer.FORMAT_MARKDOWN}-smart"
NOEUDS_DE_CODE = {"Code", "CodeBlock"}


def textes_hors_code(noeud):
    """Contenu des nœuds Str d'un AST pandoc, en ignorant le code."""
    if isinstance(noeud, list):
        for element in noeud:
            yield from textes_hors_code(element)
    elif isinstance(noeud, dict):
        if noeud.get("t") in NOEUDS_DE_CODE:
            return
        if noeud.get("t") == "Str":
            yield noeud["c"]
            return
        for valeur in noeud.values():
            yield from textes_hors_code(valeur)


def test_pas_de_double_tiret_hors_code():
    # Hors code, pandoc transforme « -- » en tiret : rw-r--r-- deviendrait rw-r–r–.
    fautes = []
    for source in SOURCES:
        ast = json.loads(
            generer.executer(["pandoc", "-f", FORMAT_SANS_TYPOGRAPHIE, "-t", "json", str(source)])
        )
        fautes.extend(
            f"{source.relative_to(generer.RACINE)} : {texte}"
            for texte in textes_hors_code(ast["blocks"])
            if "--" in texte
        )

    assert fautes == [], "mettre ces valeurs entre backticks :\n" + "\n".join(fautes)
