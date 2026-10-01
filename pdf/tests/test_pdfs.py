"""Vérification des PDF produits (lancer ./pdf/build pdf avant)."""

import re
import subprocess

import pypdf
import pytest

import generer

SORTIE = generer.RACINE / "build" / "pdf"
CATALOGUE = generer.charger_documents(generer.DOSSIER_PDF / "documents.yaml", generer.RACINE)
CARACTERES_FRANCAIS = set("éèêëàâçùûüîïôœÉÈÊÀÇÔ«»")
SEUIL_DEBORDEMENT_PT = 20.0


@pytest.fixture(scope="module", params=CATALOGUE.documents, ids=lambda d: d.fichier)
def document(request):
    return request.param


@pytest.fixture(scope="module")
def chemin_pdf(document):
    chemin = SORTIE / document.fichier
    assert chemin.is_file(), f"{chemin} absent : lancer ./pdf/build pdf"
    return chemin


@pytest.fixture(scope="module")
def lecteur(chemin_pdf):
    return pypdf.PdfReader(chemin_pdf)


@pytest.fixture(scope="module")
def log(document):
    chemin = SORTIE / "debug" / f"{document.fichier.removesuffix('.pdf')}.log"
    assert chemin.is_file(), f"{chemin} absent : lancer ./pdf/build pdf"
    return chemin.read_text(encoding="utf-8", errors="replace")


def test_au_moins_deux_pages(lecteur):
    assert len(lecteur.pages) >= 2


def test_metadonnees(document, lecteur):
    assert lecteur.metadata.title == document.titre
    assert lecteur.metadata.author == CATALOGUE.auteur
    assert lecteur.trailer["/Root"].get("/Lang") == "fr"


def test_signets_de_niveau_1_dans_l_ordre_des_sources(document, lecteur):
    signets = [entree.title for entree in lecteur.outline if not isinstance(entree, list)]

    assert signets == [generer.titre_chapitre(source) for source in document.sources]


def test_caracteres_francais_preserves(document, chemin_pdf):
    texte = subprocess.run(
        ["pdftotext", str(chemin_pdf), "-"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    dans_les_sources = {
        caractere
        for source in document.sources
        for caractere in source.read_text(encoding="utf-8")
        if caractere in CARACTERES_FRANCAIS
    }

    manquants = "".join(sorted(dans_les_sources - set(texte)))
    assert manquants == "", f"caractères des sources absents du PDF : {manquants}"


def test_aucun_caractere_manquant(log):
    assert "Missing character" not in log


def test_aucun_debordement_notable(log):
    debordements = [
        f"{largeur}pt {lignes}"
        for largeur, lignes in re.findall(
            r"Overfull \\hbox \((\d+(?:\.\d+)?)pt too wide\) (.*)",
            log,
        )
        if float(largeur) > SEUIL_DEBORDEMENT_PT
    ]

    assert debordements == [], "lignes du .tex de build/pdf/debug :\n" + "\n".join(debordements)
