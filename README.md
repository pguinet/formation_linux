# Formation Linux

## Vue d'ensemble

Cette formation Linux s'adresse à un public généraliste souhaitant découvrir et maîtriser les bases du système d'exploitation Linux.

## Public cible

- **Prérequis** : Connaissance générale d'un système d'exploitation, notion de fichier et d'arborescence
- **Niveau** : Débutant à intermédiaire
- **Durée** : Variable selon le format choisi

## Formats de formation

### Format accéléré (8 heures)
- **Public** : Utilisateurs avec VM Linux et accès SSH
- **Durée** : 2 séances de 4 heures
- **Focus** : Essentiel pratique et opérationnel

### Format étalé (37h30)
- **Public** : Utilisateurs Windows avec VirtualBox
- **Durée** : 25 séances de 1h30
- **Focus** : Apprentissage progressif et détaillé

## Structure du contenu

- 8 modules de formation couvrant tous les aspects essentiels
- Travaux pratiques pour chaque module
- Ressources complémentaires et références
- Évaluations adaptées au niveau

## Organisation des fichiers

```
├── supports/           # Contenu théorique par module
├── travaux_pratiques/  # Exercices pratiques
├── ressources/         # Images, scripts, références
├── evaluations/        # Quiz et exercices d'évaluation  
├── build/             # Fichiers PDF générés
└── scripts/           # Scripts de génération et templates
```

## Prérequis pour la génération PDF

### Installation des dépendances

**Ubuntu/Debian :**
```bash
sudo apt-get update
sudo apt-get install pandoc texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended texlive-lang-french
```

**CentOS/RHEL/Rocky Linux :**
```bash
# Avec yum
sudo yum install pandoc texlive texlive-babel-french

# Avec dnf
sudo dnf install pandoc texlive-scheme-basic texlive-collection-latexextra texlive-babel-french
```

**Vérification :**
```bash
pandoc --version
pdflatex --version

# Test du support français
pdflatex -interaction=nonstopmode <<< '\documentclass{article}\usepackage[french]{babel}\begin{document}Test\end{document}' && echo "Support français OK"
```

### Génération des supports

Les supports sont rédigés en Markdown et exportés en PDF via les scripts de génération :

```bash
# Génération complète
./scripts/build_all.sh

# Génération par type
./scripts/build_pdf.sh complete      # Formation complète
./scripts/build_pdf.sh acceleree     # Formation accélérée  
./scripts/build_modules.sh           # Modules individuels

# Version simple sans LaTeX (si dépendances manquantes)
./scripts/build_simple.sh
```

Voir le fichier `CLAUDE.md` pour le plan détaillé de la formation.

## Licence

![Licence Creative Commons](ressources/images/licenses/cc-by-nc-sa.png)

Ce projet est mis à disposition selon les termes de la [Licence Creative Commons Attribution - Pas d'Utilisation Commerciale - Partage dans les Mêmes Conditions 4.0 International](http://creativecommons.org/licenses/by-nc-sa/4.0/).

**Vous êtes autorisé à :**
- **Partager** — copier, distribuer et communiquer le matériel par tous moyens et sous tous formats
- **Adapter** — remixer, transformer et créer à partir du matériel

**Selon les conditions suivantes :**
- **Attribution** — Vous devez créditer l'Œuvre, intégrer un lien vers la licence et indiquer si des modifications ont été effectuées à l'Œuvre
- **Pas d'Utilisation Commerciale** — Vous n'êtes pas autorisé à faire un usage commercial de cette Œuvre
- **Partage dans les Mêmes Conditions** — Dans le cas où vous effectuez un remix, que vous transformez, ou créez à partir du matériel composant l'Œuvre originale, vous devez diffuser l'Œuvre modifiée dans les même conditions

## Auteur

Formation Linux - Prima Solutions