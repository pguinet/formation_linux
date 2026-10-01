"""Tests des images : résolution des chemins, échec si absente, mise en page."""

import struct
import subprocess
import zlib
from pathlib import Path

import pypdf
import pytest

import generer

# A4 (21 x 29,7 cm), marges de 2,2 cm : surface de texte en pouces.
LARGEUR_LIGNE_POUCES = (21 - 2 * 2.2) / 2.54
HAUTEUR_TEXTE_POUCES = (29.7 - 2 * 2.2) / 2.54


def ecrire_png(chemin: Path, largeur: int, hauteur: int) -> Path:
    """PNG RVB en dégradé, écrit sans dépendance externe."""
    ligne = b"\x00" + b"".join(bytes((x * 255 // largeur, 100, 200)) for x in range(largeur))

    def bloc(type_bloc: bytes, donnees: bytes) -> bytes:
        crc = zlib.crc32(type_bloc + donnees) & 0xFFFFFFFF
        return struct.pack(">I", len(donnees)) + type_bloc + donnees + struct.pack(">I", crc)

    entete = struct.pack(">IIBBBBB", largeur, hauteur, 8, 2, 0, 0, 0)
    chemin.parent.mkdir(parents=True, exist_ok=True)
    chemin.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + bloc(b"IHDR", entete)
        + bloc(b"IDAT", zlib.compress(ligne * hauteur))
        + bloc(b"IEND", b"")
    )
    return chemin


def ecrire_source(chemin: Path, texte: str) -> Path:
    chemin.parent.mkdir(parents=True, exist_ok=True)
    chemin.write_text(texte, encoding="utf-8")
    return chemin


def construire(tmp_path: Path, *sources: Path) -> Path:
    document = generer.Document("doc.pdf", "Doc", tuple(sources))
    return generer.construire(document, "Auteur", tmp_path / "sortie")


def images_du_texte(pdf: Path) -> list[tuple[int, int, int, float, float]]:
    """(page, largeur, hauteur, ppp x, ppp y) des images hors couverture (pdfimages)."""
    sortie = subprocess.run(
        ["pdfimages", "-list", str(pdf)], capture_output=True, text=True, check=True
    ).stdout
    images = []
    for ligne in sortie.splitlines()[2:]:
        champs = ligne.split()
        if champs[2] == "image" and champs[0] != "1":
            page, largeur, hauteur = (int(champs[indice]) for indice in (0, 3, 4))
            images.append((page, largeur, hauteur, float(champs[12]), float(champs[13])))
    return images


def test_commande_pandoc_resout_les_images_et_echoue_sur_avertissement():
    document = generer.Document("doc.pdf", "Doc", (Path("/s/a.md"),))

    commande = generer.commande_pandoc(document, "A", Path("/d/couv.tex"), Path("/d/doc.tex"))

    assert "rebase_relative_paths" in commande[commande.index("-f") + 1]
    assert "--fail-if-warnings" in commande
    assert "--extract-media=/d/doc-media" in commande


def test_image_relative_au_fichier_source_apparait_dans_le_pdf(tmp_path):
    ecrire_png(tmp_path / "chap" / "img" / "capture.png", 200, 100)
    source = ecrire_source(
        tmp_path / "chap" / "a.md", "# Chapitre\n\nTexte.\n\n![Une capture](img/capture.png)\n"
    )

    pdf = construire(tmp_path, source)

    pages = pypdf.PdfReader(pdf).pages
    assert any(page.images for page in pages)
    texte = subprocess.run(["pdftotext", str(pdf), "-"], capture_output=True, text=True).stdout
    assert "Une capture" in texte


def test_images_de_meme_nom_dans_deux_dossiers_restent_distinctes(tmp_path):
    ecrire_png(tmp_path / "a" / "fig.png", 300, 100)
    ecrire_png(tmp_path / "b" / "fig.png", 100, 300)
    source_a = ecrire_source(tmp_path / "a" / "a.md", "# A\n\n![Figure A](fig.png)\n")
    source_b = ecrire_source(tmp_path / "b" / "b.md", "# B\n\n![Figure B](fig.png)\n")

    pdf = construire(tmp_path, source_a, source_b)

    tailles = {(largeur, hauteur) for _, largeur, hauteur, _, _ in images_du_texte(pdf)}
    assert tailles == {(300, 100), (100, 300)}


def test_image_absente_fait_echouer_le_build_en_la_nommant(tmp_path):
    source = ecrire_source(tmp_path / "chap" / "a.md", "# Chapitre\n\n![Perdue](absente.png)\n")

    with pytest.raises(generer.ErreurBuild) as erreur:
        construire(tmp_path, source)

    assert "absente.png" in str(erreur.value)
    assert not (tmp_path / "sortie" / "doc.pdf").exists()


def test_image_large_limitee_a_75_pour_cent_de_la_ligne(tmp_path):
    ecrire_png(tmp_path / "large.png", 1600, 800)
    source = ecrire_source(tmp_path / "a.md", "# Chapitre\n\n![Large](large.png)\n")

    [(_, _, _, ppp_x, ppp_y)] = images_du_texte(construire(tmp_path, source))

    assert 1600 / ppp_x == pytest.approx(0.75 * LARGEUR_LIGNE_POUCES, rel=0.02)
    assert ppp_x == pytest.approx(ppp_y, rel=0.01)


def test_image_haute_limitee_a_45_pour_cent_de_la_page(tmp_path):
    ecrire_png(tmp_path / "haute.png", 300, 1200)
    source = ecrire_source(tmp_path / "a.md", "# Chapitre\n\n![Haute](haute.png)\n")

    [(_, _, _, ppp_x, ppp_y)] = images_du_texte(construire(tmp_path, source))

    # La hauteur de texte réelle est un peu inférieure (en-tête de page).
    hauteur = 1200 / ppp_y
    assert 0.40 * HAUTEUR_TEXTE_POUCES < hauteur <= 0.45 * HAUTEUR_TEXTE_POUCES
    assert ppp_x == pytest.approx(ppp_y, rel=0.01)


def test_image_reste_a_sa_place_dans_le_texte(tmp_path):
    ecrire_png(tmp_path / "haute.png", 300, 1200)
    source = ecrire_source(
        tmp_path / "a.md",
        "# Chapitre\n\n\\vspace*{0.6\\textheight}\n\nAVANT\n\n![Légende](haute.png)\n\nAPRES\n",
    )

    pdf = construire(tmp_path, source)

    [(page_image, *_)] = images_du_texte(pdf)
    texte_page = pypdf.PdfReader(pdf).pages[page_image - 1].extract_text()
    # Un flottant htbp partirait seul à la page suivante, APRES restant avant lui.
    assert "APRES" in texte_page
    assert texte_page.index("Légende") < texte_page.index("APRES")
    assert "AVANT" not in texte_page


def test_image_trouvee_avec_un_dossier_de_sortie_relatif(tmp_path, monkeypatch):
    ecrire_png(tmp_path / "chap" / "img.png", 200, 100)
    source = ecrire_source(tmp_path / "chap" / "a.md", "# Chapitre\n\n![Capture](img.png)\n")
    monkeypatch.chdir(tmp_path)

    pdf = generer.construire(generer.Document("doc.pdf", "Doc", (source,)), "A", Path("sortie"))

    assert len(images_du_texte(pdf)) == 1
