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
    assert couverture.count(r"\item{} ") == 2
    assert r"Les\_chemins" in couverture
    assert r"\includegraphics[width=3cm]{/logo.png}" in couverture
    assert "CC BY-NC-SA 4.0" in couverture


def test_couverture_protege_un_chapitre_commencant_par_un_crochet():
    couverture = generer.generer_couverture(DOCUMENT, ["[Annexe] Installation"], Path("/l.png"))

    assert r"\item{} [Annexe] Installation" in couverture


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
        str(generer.DOSSIER_PDF / "preambule.tex"),
        "/d/couv.tex",
        "/d/doc.tex",
    ):
        assert attendu in commande
    for meta in ("title-meta=Module 2 — Navigation", "author-meta=Auteur"):
        assert commande[commande.index(meta) - 1] == "-M"


def test_commande_pandoc_echappe_titre_et_auteur_dans_les_metadonnees(tmp_path):
    source = tmp_path / "a.md"
    source.write_text("# Chapitre\n", encoding="utf-8")
    vide = tmp_path / "vide.tex"
    vide.write_text("", encoding="utf-8")
    sortie = tmp_path / "doc.tex"
    document = generer.Document("doc.pdf", "Git & GitHub 100% a_b", (source,))
    commande = generer.commande_pandoc(document, "A & B", vide, sortie)
    commande[commande.index(str(generer.DOSSIER_PDF / "preambule.tex"))] = str(vide)

    generer.executer(commande)

    tex = sortie.read_text(encoding="utf-8")
    assert r"pdftitle={Git \& GitHub 100\% a\_b}" in tex
    assert r"pdfauthor={A \& B}" in tex


def test_erreurs_latex_detecte_caractere_manquant_et_erreur_fatale():
    log = (
        "ligne normale\n"
        "Missing character: There is no ✅ (U+2705) in font [lmroman10-regular]\n"
        "suite\n"
        "!  ==> Fatal error occurred, no output PDF file produced!\n"
    )

    erreurs = generer.erreurs_latex(log)

    assert any("U+2705" in ligne for ligne in erreurs)
    assert any("Fatal error" in ligne for ligne in erreurs)


def test_erreurs_latex_detecte_une_erreur_dans_un_paquet():
    log = (
        "/opt/texlive/texdir/texmf-dist/tex/latex/fontspec/fontspec.sty:123: "
        'Package fontspec Error: The font "Absente" cannot be found.\n'
    )

    assert any("fontspec Error" in ligne for ligne in generer.erreurs_latex(log))


def test_erreurs_latex_vide_pour_un_log_propre():
    assert generer.erreurs_latex("This is LuaHBTeX\nOutput written on doc.pdf\n") == []
