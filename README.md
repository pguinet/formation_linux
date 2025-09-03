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
sudo apt-get install pandoc texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended
```

**CentOS/RHEL/Rocky Linux :**
```bash
# Avec yum
sudo yum install pandoc texlive

# Avec dnf
sudo dnf install pandoc texlive-scheme-basic texlive-collection-latexextra
```

**Vérification :**
```bash
pandoc --version
pdflatex --version
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