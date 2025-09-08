#!/bin/bash

# Script de génération PDF pour le module Docker uniquement
# Usage: ./build_docker_module.sh

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build/modules_additionnels"
DOCKER_DIR="$ROOT_DIR/supports/modules_additionnels/module_docker"
DOCKER_TP_DIR="$ROOT_DIR/travaux_pratiques/tp_additionnels/tp_docker"

echo "🐳 Génération PDF du module Docker..."

# Créer le répertoire de build s'il n'existe pas
mkdir -p "$BUILD_DIR"

# Vérifier que le module Docker existe
if [ ! -d "$DOCKER_DIR" ]; then
    echo "❌ Erreur: Répertoire du module Docker non trouvé: $DOCKER_DIR"
    exit 1
fi

# Créer le fichier temporaire combiné
TEMP_FILE="$BUILD_DIR/temp_module_docker.md"

echo "📄 Compilation du contenu Docker..."

# En-tête du document
cat > "$TEMP_FILE" << 'EOF'
---
title: "Module additionnel : Docker"
subtitle: "Conteneurisation et orchestration"
author: "Formation Linux"
date: \today
lang: fr-FR
documentclass: article
geometry: margin=2cm
fontsize: 11pt
toc: true
toc-depth: 3
numbersections: true
colorlinks: true
linkcolor: blue
urlcolor: blue
---

\newpage

EOF

# Ajouter tous les chapitres du module Docker
echo "  📝 Ajout des chapitres théoriques..."
for chapter in "$DOCKER_DIR"/*.md; do
    if [ -f "$chapter" ]; then
        chapter_name=$(basename "$chapter" .md)
        echo "    - $chapter_name"
        echo "" >> "$TEMP_FILE"
        echo "\\newpage" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        cat "$chapter" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
    fi
done

# Ajouter les travaux pratiques
if [ -d "$DOCKER_TP_DIR" ]; then
    echo "  📝 Ajout des travaux pratiques..."
    echo "" >> "$TEMP_FILE"
    echo "\\newpage" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    echo "# Travaux pratiques" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    
    for tp in "$DOCKER_TP_DIR"/*.md; do
        if [ -f "$tp" ] && [[ "$(basename "$tp")" != "README.md" ]]; then
            tp_name=$(basename "$tp" .md)
            echo "    - $tp_name"
            echo "" >> "$TEMP_FILE"
            echo "\\newpage" >> "$TEMP_FILE"
            echo "" >> "$TEMP_FILE"
            cat "$tp" >> "$TEMP_FILE"
            echo "" >> "$TEMP_FILE"
        fi
    done
fi

# Nettoyage des caractères Unicode
echo "🧹 Nettoyage des caractères Unicode..."
"$SCRIPT_DIR/clean_unicode.sh" "$TEMP_FILE"

# Génération du PDF
echo "📚 Génération du PDF..."
cd "$BUILD_DIR"

# Tentative de génération avec couverture
if pandoc \
    --from markdown \
    --to pdf \
    --pdf-engine=pdflatex \
    --template="$SCRIPT_DIR/../templates/pdf_template.tex" \
    --toc \
    --number-sections \
    --highlight-style=tango \
    --variable fontsize=11pt \
    --variable geometry:margin=2cm \
    --variable colorlinks=true \
    --variable linkcolor=blue \
    --variable urlcolor=blue \
    --output="module_additionnel_docker.pdf" \
    "temp_module_docker.md" 2>/dev/null; then
    
    echo "✅ PDF généré avec succès: module_additionnel_docker.pdf"
else
    echo "⚠️ Erreur avec template, tentative version simplifiée..."
    
    # Génération simplifiée sans template personnalisé
    if pandoc \
        --from markdown \
        --to pdf \
        --pdf-engine=pdflatex \
        --toc \
        --number-sections \
        --highlight-style=tango \
        --variable fontsize=11pt \
        --variable geometry:margin=2cm \
        --variable colorlinks=true \
        --variable linkcolor=blue \
        --variable urlcolor=blue \
        --output="module_additionnel_docker.pdf" \
        "temp_module_docker.md"; then
        
        echo "✅ PDF généré en mode simplifié: module_additionnel_docker.pdf"
    else
        echo "❌ Échec de la génération PDF"
        echo "💡 Vérifiez les erreurs ci-dessus et le contenu du fichier temp_module_docker.md"
        exit 1
    fi
fi

# Nettoyage des fichiers temporaires
rm -f temp_cover_docker.* 2>/dev/null || true

echo "🎉 Module Docker PDF généré dans: $BUILD_DIR/module_additionnel_docker.pdf"
echo "📊 Taille du fichier: $(du -h "$BUILD_DIR/module_additionnel_docker.pdf" | cut -f1)"