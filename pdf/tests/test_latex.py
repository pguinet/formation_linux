"""Tests de la partie LaTeX : échappement, couverture, commande, log."""

from pathlib import Path

import generer

DOCUMENT = generer.Document("doc.pdf", "Module 2 — Navigation", (Path("/s/a.md"), Path("/s/b.md")))


def test_echappe_les_caracteres_speciaux_latex():
    assert generer.echapper_latex(r"a_b & 50% #1 {x} ~ ^ \ $") == (
        r"a\_b \& 50\% \#1 \{x\} \textasciitilde{} \textasciicircum{} "
        r"\textbackslash{} \$"
    )


def test_couverture_contient_titre_chapitres_et_licence():
    couverture = generer.generer_couverture(
        DOCUMENT, ["Chapitre 2.1 — Les_chemins", "Chapitre 2.2 — Explorer"], Path("/logo.png")
    )

    assert r"\begin{titlepage}" in couverture
    assert "Module 2 — Navigation" in couverture
    assert couverture.count(r"\item ") == 2
    assert r"Les\_chemins" in couverture
    assert r"\includegraphics[width=3cm]{/logo.png}" in couverture
    assert "CC BY-NC-SA 4.0" in couverture


def test_couverture_avec_sous_titre():
    document = generer.Document("doc.pdf", "Titre", (Path("/s/a.md"),), "Le sous-titre")

    assert "Le sous-titre" in generer.generer_couverture(document, ["Chap"], Path("/logo.png"))


def test_commande_pandoc():
    commande = generer.commande_pandoc(DOCUMENT, "Auteur", Path("/d/couv.tex"), Path("/d/doc.tex"))

    assert commande[:3] == ["pandoc", "-f", generer.FORMAT_MARKDOWN]
    assert commande[-2:] == ["/s/a.md", "/s/b.md"]
    for attendu in (
        "lang=fr",
        "documentclass=report",
        "title-meta=Module 2 — Navigation",
        "author-meta=Auteur",
        str(generer.DOSSIER_PDF / "preambule.tex"),
        "/d/couv.tex",
        "/d/doc.tex",
    ):
        assert attendu in commande


def test_erreurs_latex_detecte_caractere_manquant_et_erreur_fatale():
    log = (
        "ligne normale\n"
        "Missing character: There is no ✅ (U+2705) in font [lmroman10-regular]\n"
        "suite\n"
        "./doc.tex:78:  ==> Fatal error occurred, no output PDF file produced!\n"
    )

    erreurs = generer.erreurs_latex(log)

    assert any("U+2705" in ligne for ligne in erreurs)
    assert any("Fatal error" in ligne for ligne in erreurs)


def test_erreurs_latex_vide_pour_un_log_propre():
    assert generer.erreurs_latex("This is LuaHBTeX\nOutput written on doc.pdf\n") == []
