"""Tests de l'extraction des titres de niveau 1 (via pandoc)."""

import pytest

import build


def source(tmp_path, contenu):
    chemin = tmp_path / "chapitre.md"
    chemin.write_text(contenu, encoding="utf-8")
    return chemin


def test_extrait_le_titre_avec_la_typographie_de_pandoc(tmp_path):
    chemin = source(
        tmp_path,
        "# Chapitre 1.1 — L'été `ls`\n\n## Section\n\n```\n# pas un titre\n```\n",
    )

    assert build.titre_chapitre(chemin) == "Chapitre 1.1 — L’été ls"


@pytest.mark.parametrize("contenu", ["## Section seule\n", "# Un\n\n# Deux\n"])
def test_refuse_zero_ou_plusieurs_titres_de_niveau_1(tmp_path, contenu):
    with pytest.raises(build.ErreurBuild, match="exactement 1 attendu"):
        build.titre_chapitre(source(tmp_path, contenu))


def test_signale_une_commande_en_echec():
    with pytest.raises(build.ErreurBuild, match="échec de : false"):
        build.executer(["false"])
