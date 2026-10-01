"""Tests du chargement de documents.yaml."""

import re

import pytest

import generer

VALIDE = """\
auteur: Auteur
documents:
  - fichier: doc.pdf
    titre: Mon titre
    sources: [a.md]
"""


def ecrire(tmp_path, contenu):
    (tmp_path / "a.md").write_text("# Titre\n", encoding="utf-8")
    chemin = tmp_path / "documents.yaml"
    chemin.write_text(contenu, encoding="utf-8")
    return chemin


def test_charge_un_catalogue_valide(tmp_path):
    catalogue = generer.charger_documents(ecrire(tmp_path, VALIDE), tmp_path)

    assert catalogue.auteur == "Auteur"
    assert catalogue.documents == [generer.Document("doc.pdf", "Mon titre", (tmp_path / "a.md",))]


def test_lit_le_sous_titre_optionnel(tmp_path):
    contenu = VALIDE.replace(
        "    titre: Mon titre\n", "    titre: Mon titre\n    sous_titre: Sous\n"
    )

    catalogue = generer.charger_documents(ecrire(tmp_path, contenu), tmp_path)

    assert catalogue.documents[0].sous_titre == "Sous"


@pytest.mark.parametrize(
    ("contenu", "message"),
    [
        ("auteur: [", "YAML invalide"),
        ("documents: []\n", "auteur"),
        ("auteur: A\n", "documents"),
        ("auteur: A\ndocuments: []\n", "documents"),
        (VALIDE.replace("    titre: Mon titre\n", ""), "champ 'titre' manquant"),
        (VALIDE.replace("[a.md]", "[absent.md]"), "source introuvable : absent.md"),
        (VALIDE.replace("doc.pdf", "doc.txt"), "doit se terminer par .pdf"),
        (VALIDE + "    couleur: rouge\n", "champ(s) inconnu(s) : couleur"),
        (VALIDE + VALIDE.split("documents:\n")[1], "déclaré deux fois"),
    ],
)
def test_refuse_un_catalogue_invalide(tmp_path, contenu, message):
    with pytest.raises(generer.ErreurBuild, match=re.escape(message)):
        generer.charger_documents(ecrire(tmp_path, contenu), tmp_path)
