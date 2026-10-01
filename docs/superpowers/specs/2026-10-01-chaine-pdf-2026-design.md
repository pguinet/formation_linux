# Chaîne de génération PDF 2026 -- Design

Date : 2026-10-01
Statut : validé

## Contexte

L'ancienne chaîne PDF (`scripts/`, 3 workflows GitHub Actions, plus de
3 300 lignes) n'a probablement jamais produit un build complet sans erreur.
Causes identifiées :

- **pdfLaTeX** gère mal l'UTF-8 : accents remplacés par des « x », d'où
  `clean_unicode.sh` qui réécrit les sources à coups de `sed`.
- **Environnements divergents** : la CI installe ses paquets via `apt`, le
  poste local n'a pas les mêmes outils (pandoc absent).
- **Erreurs avalées** : `|| echo`, `> /dev/null 2>&1`, « versions
  simplifiées » de repli. Un build cassé pouvait passer pour un succès.

Depuis l'archivage de l'ancien cours dans `archives/cours_2025/`, la chaîne
ne couvre plus rien d'utile pour le cours de base.

## Objectif

Une chaîne qui **fonctionne**, identique en local et sur GitHub, qui échoue
bruyamment au moindre problème et dont le résultat est vérifié par des tests.

## Décisions

1. **Périmètre : 11 PDF.** 8 modules de base, 2 modules additionnels (Git,
   Docker), 1 annexe d'installation. Pas de PDF du cours complet.
2. **Mise en page sobre d'abord.** La spécification de mise en page de
   CLAUDE.md (cadre de couleur, numérotation romaine, recto-verso) n'est pas
   visée par cette version ; elle pourra être ajoutée ensuite, test à
   l'appui.
3. **Publication : release sur tag.** Chaque push et PR construit et teste ;
   une release GitHub n'est créée que sur un tag `v*`.
4. **Technique : pandoc + LuaLaTeX dans une image Docker figée** (approche A,
   préférée à pandoc + Typst et à pandoc + WeasyPrint).
5. **L'ancienne chaîne est supprimée** (`scripts/` en entier, les 3
   workflows). Elle reste dans l'historique Git.

## Architecture

```
pdf/
  Dockerfile        FROM pandoc/extra:<version> figée par digest
                    + poppler-utils, pytest, pypdf, ruff, shellcheck (épinglés)
  documents.yaml    déclaration des 11 PDF
  build.py          build Python, arrêt à la première erreur
  template.tex      template LaTeX unique (LuaLaTeX)
  tests/            tests pytest (unitaires + vérification des PDF)
  build             point d'entrée : docker build + docker run
```

- **Point d'entrée unique** : `./pdf/build` construit l'image puis lance, dans
  le conteneur, `build.py` et les tests. L'utilisateur du conteneur reprend
  l'uid/gid local pour que les fichiers produits ne soient pas à root.
  Options : `--no-test` (build seul), `--check` (lint seul).
- **Sortie** : `build/pdf/*.pdf` (déjà ignoré par Git), diagnostic dans
  `build/pdf/debug/`.
- **`documents.yaml`** déclare chaque PDF explicitement : nom de fichier,
  titre, sous-titre éventuel, liste ordonnée des sources. Aucune déduction à
  partir des noms de dossiers. Ajouter un PDF = ajouter une entrée.
- **Les sources ne sont jamais modifiées par le build.** `clean_unicode.sh`
  disparaît. Un caractère absent des polices fait échouer le build.

### Les 11 documents

| PDF | Sources |
|-----|---------|
| `module_01_decouverte.pdf` ... `module_08_automatisation.pdf` | chapitres de `cours_2026/module_0X_*/`, dans l'ordre |
| `module_additionnel_git.pdf` | `supports/modules_additionnels/module_git/` (4 chapitres) puis `travaux_pratiques/tp_additionnels/tp_git/` |
| `module_additionnel_docker.pdf` | `supports/modules_additionnels/module_docker/` (4 chapitres) puis `travaux_pratiques/tp_additionnels/tp_docker/` |
| `annexe_installation.pdf` | `cours_2026/annexes/installation.md` |

## Rendu et mise en page

- **Couverture** : « Formation Linux », titre du document, liste des
  chapitres (issue de `documents.yaml`), cartouche licence CC BY-NC-SA 4.0
  avec le logo `ressources/images/licenses/cc-by-nc-sa`.
- **Sommaire** : chapitres (`#`) et sections (`##`) avec numéros de page.
- **Chapitres** : `#` -> chapitre LaTeX (nouvelle page), `##` -> section.
  Aucune numérotation automatique : les titres portent déjà
  « Chapitre X.Y -- ... ».
- **Pages** : A4, `report`, numéro en bas au centre, titre du chapitre en
  en-tête.
- **Typographie** : babel français, Latin Modern pour le texte, DejaVu Sans
  Mono pour le code. Blocs de code sur fond gris clair avec retour à la
  ligne automatique. Tableaux en `longtable`.
- **Sources des modules additionnels** : les flèches, caractères de boîtes et
  emojis encore présents (module Git, TP Git) sont remplacés par des
  équivalents ASCII, conformément à CLAUDE.md. C'est la seule modification
  de contenu prévue.

## Gestion des erreurs

- Chaque étape s'arrête à la première erreur (`set -euo pipefail` côté shell,
  exceptions non rattrapées côté Python, code de sortie non nul).
- En cas d'échec, `build.py` affiche le PDF concerné, la commande pandoc et
  les 30 dernières lignes pertinentes du log LaTeX. Le `.tex` intermédiaire
  et le log sont conservés dans `build/pdf/debug/`.
- Le log LaTeX est analysé : tout `Missing character` fait échouer le build.

## Tests et qualité

**Tests unitaires de `build.py`** : validation de `documents.yaml` (source
manquante, nom en double, champ absent), construction de la commande pandoc.

**Tests des PDF produits** (pypdf, `pdftotext`), pour chacun des 11 PDF :

- le fichier existe et compte au moins 2 pages ;
- métadonnées renseignées (titre, auteur, langue `fr`) ;
- le texte extrait contient les caractères `é è à ç ù ê « »` présents dans
  les sources, et chaque titre `#` des sources, accents intacts ;
- les signets du PDF reprennent les titres `#` des sources, dans l'ordre ;
- le log LaTeX ne contient ni `Missing character` ni `Overfull \hbox`
  au-delà d'un seuil (fixé à l'implémentation).

Les tests vérifient le fond, pas l'esthétique : une relecture visuelle reste
nécessaire à chaque évolution notable du template.

**Qualité** : `ruff check` et `ruff format --check` pour le Python,
`shellcheck` pour `pdf/build`, lancés par `./pdf/build --check` et en CI.

## CI

Un seul workflow `.github/workflows/pdf.yml` :

- **push et pull request** : build de l'image (cache), `./pdf/build --check`,
  `./pdf/build`, artifact avec les 11 PDF ; en cas d'échec, artifact
  `build/pdf/debug/`.
- **tag `v*`** : idem, plus une release GitHub avec les 11 PDF attachés.

La CI exécute les mêmes commandes qu'en local : ce qui passe en local passe
sur GitHub.

## Reproductibilité

- Image pandoc figée par digest ; versions pip épinglées.
- `SOURCE_DATE_EPOCH` fixé (date du dernier commit) pour des PDF quasi
  identiques d'un build à l'autre.

## Documentation

CLAUDE.md (sections PDF, GitHub Actions, structure, commandes de diagnostic),
README et CONTRIBUTING sont mis à jour pour décrire `./pdf/build` et la
release sur tag. Les mentions de `clean_unicode.sh` et des anciens scripts
disparaissent.

## Hors périmètre

- PDF du cours complet.
- Mise en page riche de CLAUDE.md (cadre de couleur, numérotation romaine,
  en-têtes recto-verso).
- Contenu des volets « bureau Debian 13 » et « homelab Docker ».
