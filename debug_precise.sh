#!/bin/bash

# Script de debug précis pour identifier le problème LaTeX

set -e

echo "🔍 Debug précis du problème LaTeX"

# Générer juste le module 1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TEMPLATE_DIR="$SCRIPT_DIR/scripts/templates"

mkdir -p "$BUILD_DIR"

module_num=1
module_num_fmt=$(printf "%02d" $module_num)
module_dir=$(ls -d "$SUPPORTS_DIR/module_${module_num_fmt}_"* 2>/dev/null | head -1)

if [ ! -d "$module_dir" ]; then
    echo "❌ Module $module_num non trouvé: $module_dir"
    exit 1
fi

module_name=$(basename "$module_dir" | sed 's/module_[0-9]*_//' | tr '_' ' ')
module_title=$(echo "$module_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
temp_md="$BUILD_DIR/debug_module_${module_num_fmt}.md"
output_file="$BUILD_DIR/debug_module_${module_num_fmt}.pdf"

echo "📄 Module $module_num: $module_title"

# En-tête du module avec le contenu exact de la fonction
cat > "$temp_md" << EOF
---
title: "Module $module_num : $module_title"
author: "Pascal Guinet - Prima Solutions"
date: \today
module-content: |
  **Durée estimée :** 3-4 heures
  
  **Objectifs :** Maîtriser les concepts et outils du module $module_num
  
  **Prérequis :** Modules précédents complétés
  
  **Approche :** Formation progressive avec travaux pratiques
reset-chapter-numbering: true
---

# Présentation du module

Ce module couvre les aspects essentiels du module $module_num.

\newpage

EOF

# Ajouter les chapitres
for chapter in "$module_dir"/*.md; do
    if [ -f "$chapter" ]; then
        chapter_name=$(basename "$chapter" .md | sed 's/^[0-9]*_//' | tr '_' ' ')
        echo "" >> "$temp_md"
        echo "# $chapter_name" >> "$temp_md"
        echo "" >> "$temp_md"
        
        # Contenu normal
        cat "$chapter" >> "$temp_md"
        echo "" >> "$temp_md"
    fi
done

echo "📁 Fichier markdown créé: $temp_md"
echo "📏 Taille: $(wc -l < "$temp_md") lignes"

# Nettoyage minimal
echo "🧹 Nettoyage Unicode..."
"$SCRIPT_DIR/scripts/clean_unicode.sh" "$temp_md" > /dev/null 2>&1 || true

echo "🔨 Test génération PDF avec template..."
if pandoc "$temp_md" \
    --template="$TEMPLATE_DIR/formation_template.tex" \
    --pdf-engine=pdflatex \
    --toc \
    --toc-depth=2 \
    --highlight-style=tango \
    --variable geometry:margin=2.5cm \
    --variable fontsize=11pt \
    --variable documentclass:article \
    --variable papersize=a4 \
    --variable lang=fr \
    -o "$output_file"; then
    echo "✅ Module généré avec template: $output_file"
else
    echo "❌ Erreur avec template. Essai sans template..."
    if pandoc "$temp_md" \
        --pdf-engine=pdflatex \
        --toc \
        --toc-depth=2 \
        --highlight-style=tango \
        --variable geometry:margin=2.5cm \
        --variable fontsize=11pt \
        --variable documentclass:article \
        --variable papersize=a4 \
        --variable lang=fr \
        -o "${output_file%.pdf}_sans_template.pdf"; then
        echo "✅ Module généré sans template: ${output_file%.pdf}_sans_template.pdf"
    else
        echo "❌ Erreur même sans template"
        echo "🔍 Fichier conservé pour debug: $temp_md"
    fi
fi

echo "🎯 Debug terminé"