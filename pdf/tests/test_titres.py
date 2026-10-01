"""Tests de l'extraction des titres de niveau 1 (via pandoc)."""

import pytest

import generer


def source(tmp_path, contenu):
    chemin = tmp_path / "chapitre.md"
    chemin.write_text(contenu, encoding="utf-8")
    return chemin


def test_extrait_le_titre_avec_la_typographie_de_pandoc(tmp_path):
    chemin = source(
        tmp_path,
        "# Chapitre 1.1 — L'été `ls`\n\n## Section\n\n```\n# pas un titre\n```\n",
    )

    assert generer.titre_chapitre(chemin) == "Chapitre 1.1 — L’été ls"


@pytest.mark.parametrize(
    "contenu", ["## Section seule\n", "# Un\n\n# Deux\n", "- # Un\n\n# Deux\n"]
)
def test_refuse_zero_ou_plusieurs_titres_de_niveau_1(tmp_path, contenu):
    with pytest.raises(generer.ErreurBuild, match="exactement 1 attendu"):
        generer.titre_chapitre(source(tmp_path, contenu))


def test_signale_une_commande_en_echec():
    with pytest.raises(generer.ErreurBuild) as erreur:
        generer.executer(["sh", "-c", "echo raison >&2; false"])

    lignes = str(erreur.value).splitlines()
    assert lignes == ["échec de sh", "raison", "commande : sh -c echo raison >&2; false"]


def test_echec_avec_message_personnalise():
    with pytest.raises(generer.ErreurBuild, match="^pandoc a échoué pour x.pdf\n"):
        generer.executer(["false"], echec="pandoc a échoué pour x.pdf")
