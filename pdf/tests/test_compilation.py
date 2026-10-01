"""Tests de la compilation LaTeX et de la construction d'un document."""

import pytest

import generer

PREAMBULE = "\\documentclass{article}\n\\begin{document}\n"


def compiler_texte(tmp_path, corps):
    tex = tmp_path / "essai.tex"
    tex.write_text(PREAMBULE + corps + "\n\\end{document}\n", encoding="utf-8")
    with pytest.raises(generer.ErreurBuild) as erreur:
        generer.compiler(tex)
    return str(erreur.value)


def test_compiler_signale_une_commande_inconnue(tmp_path):
    message = compiler_texte(tmp_path, "\\nimporte")

    assert "Undefined control sequence" in message
    assert "rm -rf build/pdf/debug" in message


def test_compiler_signale_un_caractere_absent_de_la_police(tmp_path):
    message = compiler_texte(tmp_path, "\\tracinglostchars=3\nValidé ✅")

    assert "Missing character" in message


def test_construire_supprime_l_ancien_pdf_meme_en_cas_d_echec(tmp_path):
    source = tmp_path / "a.md"
    source.write_text("## Pas de titre de niveau 1\n", encoding="utf-8")
    ancien = tmp_path / "doc.pdf"
    ancien.write_bytes(b"%PDF perime")

    with pytest.raises(generer.ErreurBuild):
        generer.construire(generer.Document("doc.pdf", "Doc", (source,)), "Auteur", tmp_path)

    assert not ancien.exists()
