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
        (VALIDE.replace("doc.pdf", "12"), "champ 'fichier' : chaîne attendue"),
        (VALIDE + "    sous_titre: 3\n", "champ 'sous_titre' : chaîne attendue"),
        (VALIDE.replace("[a.md]", "a.md"), "champ 'sources' : liste de chemins attendue"),
    ],
)
def test_refuse_un_catalogue_invalide(tmp_path, contenu, message):
    with pytest.raises(generer.ErreurBuild, match=re.escape(message)):
        generer.charger_documents(ecrire(tmp_path, contenu), tmp_path)


def test_selectionne_les_documents_demandes():
    a = generer.Document("a.pdf", "A", ())
    b = generer.Document("b.pdf", "B", ())

    assert generer.selectionner([a, b], []) == [a, b]
    assert generer.selectionner([a, b], ["b.pdf"]) == [b]
    with pytest.raises(generer.ErreurBuild, match="inconnu"):
        generer.selectionner([a, b], ["c.pdf"])


ATTENDUS = [
    "module_01_decouverte.pdf",
    "module_02_navigation.pdf",
    "module_03_manipulation.pdf",
    "module_04_consultation.pdf",
    "module_05_droits.pdf",
    "module_06_processus.pdf",
    "module_07_reseaux.pdf",
    "module_08_automatisation.pdf",
    "module_additionnel_git.pdf",
    "module_additionnel_git_windows.pdf",
    "module_additionnel_docker.pdf",
    "annexe_installation_ssh.pdf",
    "annexe_installation_virtualbox.pdf",
]


def catalogue_du_depot():
    return generer.charger_documents(generer.DOSSIER_PDF / "documents.yaml", generer.RACINE)


def test_le_catalogue_du_depot_declare_les_13_pdf():
    assert [document.fichier for document in catalogue_du_depot().documents] == ATTENDUS


RACINES_ACTIVES = [
    "cours_2026",
    "supports/modules_additionnels",
    "travaux_pratiques/tp_additionnels",
]


def test_chaque_source_active_est_dans_un_pdf():
    catalogue = catalogue_du_depot()
    declares = {source for document in catalogue.documents for source in document.sources}

    oublies = sorted(
        str(chemin.relative_to(generer.RACINE))
        for racine in RACINES_ACTIVES
        for chemin in (generer.RACINE / racine).rglob("*.md")
        if chemin not in declares
    )
    assert oublies == []


def test_aucune_source_n_est_declaree_deux_fois():
    sources = [source for document in catalogue_du_depot().documents for source in document.sources]

    assert sorted({s for s in sources if sources.count(s) > 1}) == []


def test_un_module_de_base_reprend_tous_les_chapitres_de_son_dossier_dans_l_ordre():
    for document in catalogue_du_depot().documents:
        if document.fichier.startswith("module_0"):
            dossier = generer.RACINE / "cours_2026" / document.fichier.removesuffix(".pdf")
            assert document.sources == tuple(sorted(dossier.glob("*.md"))), document.fichier
