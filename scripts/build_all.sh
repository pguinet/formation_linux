#!/bin/bash

# Script principal de génération des supports de formation Linux
# Génère tous les formats : PDF complet, PDF accéléré, et PDFs par module

set -e  # Arrêt en cas d'erreur

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TP_DIR="$PROJECT_DIR/travaux_pratiques"

echo "🚀 Début de la génération des supports de formation Linux"
echo "📁 Répertoire projet: $PROJECT_DIR"

# Vérification des dépendances
echo "🔍 Vérification des dépendances..."
if ! command -v pandoc &> /dev/null; then
    echo "❌ Pandoc n'est pas installé. Installation requise:"
    echo "   Ubuntu/Debian: sudo apt-get install pandoc texlive-latex-recommended"
    exit 1
fi

if ! command -v pdflatex &> /dev/null; then
    echo "❌ pdflatex n'est pas installé. Installation requise:"
    echo "   Ubuntu/Debian: sudo apt-get install texlive-latex-base texlive-latex-extra"
    exit 1
fi

echo "✅ Dépendances OK"

# Nettoyage du répertoire de build
echo "🧹 Nettoyage du répertoire de build..."
rm -rf "$BUILD_DIR"/*
mkdir -p "$BUILD_DIR/supports_par_module"

# Utilisation du nouveau script de génération des formations
echo "📚 Génération de toutes les formations selon les nouvelles spécifications..."
"$SCRIPT_DIR/build_formations.sh"

echo "✅ Génération terminée avec succès!"
echo "📂 Fichiers générés dans: $BUILD_DIR"
echo "   📁 Formations complètes :"
echo "      - formations/formation_acceleree.pdf"
echo "      - formations/formation_longue.pdf"
echo "   📁 Modules de base individuels :"
echo "      - modules_base/module_01_*.pdf à module_08_*.pdf"
echo "   📁 Modules additionnels :"
echo "      - modules_additionnels/module_additionnel_git.pdf"
echo "      - modules_additionnels/module_additionnel_docker.pdf"