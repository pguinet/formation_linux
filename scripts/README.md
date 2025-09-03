# Scripts de génération des supports

Ce dossier contient tous les scripts nécessaires à la génération automatique des supports PDF de la formation Linux.

## Scripts principaux

### `build_all.sh`
Script principal qui génère tous les formats de supports :
- Formation complète (PDF complet avec tous les modules et TP)
- Formation accélérée (PDF condensé pour le format 8h)
- Supports par module (PDF individuels pour chaque module)

```bash
./scripts/build_all.sh
```

### `build_pdf.sh`
Génération d'un PDF complet spécifique :

```bash
# Formation complète
./scripts/build_pdf.sh complete

# Formation accélérée  
./scripts/build_pdf.sh acceleree
```

### `build_modules.sh`
Génération des PDFs individuels pour chaque module :

```bash
./scripts/build_modules.sh
```

## Configuration

### `config.sh`
Fichier de configuration centrale contenant :
- Paramètres de génération (auteur, titre, version)
- Chemins des répertoires
- Configuration Pandoc et LaTeX
- Fonctions utilitaires partagées

### `templates/`
- `pdf_template.tex` : Template LaTeX personnalisé pour une mise en page professionnelle

## Prérequis

### Installation des dépendances (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install pandoc texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended
```

### Vérification des dépendances
```bash
# Vérifier que pandoc est installé
pandoc --version

# Vérifier que pdflatex est disponible
pdflatex --version
```

## Utilisation

1. **Génération complète** (recommandé) :
   ```bash
   ./scripts/build_all.sh
   ```

2. **Génération d'un format spécifique** :
   ```bash
   ./scripts/build_pdf.sh complete     # Formation complète
   ./scripts/build_pdf.sh acceleree    # Formation accélérée
   ./scripts/build_modules.sh          # Modules individuels
   ```

## Structure des fichiers générés

```
build/
├── formation_complete.pdf      # Formation complète (tous modules + TP)
├── formation_acceleree.pdf     # Formation accélérée (modules essentiels)
└── supports_par_module/        # PDFs individuels par module
    ├── module_01_decouverte.pdf
    ├── module_02_navigation.pdf
    └── ...
```

## Personnalisation

### Modifier le template
Éditer `templates/pdf_template.tex` pour personnaliser :
- Couleurs et mise en page
- En-têtes et pieds de page  
- Page de titre
- Styles de code

### Ajouter un module
1. Créer le dossier `supports/module_XX_nom/`
2. Ajouter les fichiers `.md` du contenu
3. Créer le dossier `travaux_pratiques/tpXX_nom/`
4. Mettre à jour `config.sh` si nécessaire

## Dépannage

### Erreur "pandoc not found"
Installer pandoc : `sudo apt-get install pandoc`

### Erreur "pdflatex not found"
Installer LaTeX : `sudo apt-get install texlive-latex-base texlive-latex-extra`

### Erreur de génération LaTeX
Le script génère automatiquement une version simplifiée en cas d'erreur avec le template personnalisé.

### PDF vides ou incorrects
Vérifier que les fichiers `.md` existent dans les dossiers de modules et qu'ils contiennent du contenu valide.