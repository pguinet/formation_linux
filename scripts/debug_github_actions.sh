#!/bin/bash

# Script de diagnostic pour GitHub Actions
# Reproduit exactement les conditions du CI

set -e

echo "🔍 Diagnostic GitHub Actions - Reproduction locale"
echo "=================================================="

# Configuration identique au CI
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"

echo "📁 Répertoires:"
echo "  - Script: $SCRIPT_DIR"
echo "  - Projet: $PROJECT_DIR"
echo "  - Build: $BUILD_DIR"

# Versions des outils (comme dans le CI)
echo ""
echo "🛠️ Versions des outils:"
pandoc --version | head -1
pdflatex --version | head -1
gs --version | head -1

# Nettoyage complet
echo ""
echo "🧹 Nettoyage complet..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"/{formations,modules_base,modules_additionnels}

# Test avec un seul module pour isolation
echo ""
echo "🧪 Test génération module 1 isolé..."

module_num=1
module_num_fmt=$(printf "%02d" $module_num)
module_dir=$(ls -d "$PROJECT_DIR/supports/module_${module_num_fmt}_"* 2>/dev/null | head -1)

if [ ! -d "$module_dir" ]; then
    echo "❌ Module $module_num non trouvé"
    exit 1
fi

module_name=$(basename "$module_dir" | sed 's/module_[0-9]*_//' | tr '_' ' ')
module_title=$(echo "$module_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
temp_md="$BUILD_DIR/debug_github_actions.md"
output_file="$BUILD_DIR/debug_github_actions.pdf"

echo "📄 Module: $module_title"
echo "📝 Fichier MD: $temp_md"
echo "📄 Fichier PDF: $output_file"

# Génération markdown minimaliste (reproduction exacte du script principal)
cat > "$temp_md" << EOF
---
title: "Module $module_num : $module_title"
author: "Pascal Guinet - Prima Solutions"
date: \\today
module-content: |
  **Durée estimée :** 3-4 heures
  
  **Objectifs :** Maîtriser les concepts et outils du module $module_num
  
  **Prérequis :** Modules précédents complétés
  
  **Approche :** Formation progressive avec travaux pratiques
reset-chapter-numbering: true
---

# Présentation du module

Ce module couvre les aspects essentiels du module $module_num.

\\newpage

EOF

# Ajouter SEULEMENT le premier chapitre pour isolation
first_chapter=$(ls "$module_dir"/*.md 2>/dev/null | head -1)
if [ -f "$first_chapter" ]; then
    chapter_name=$(basename "$first_chapter" .md | sed 's/^[0-9]*_//' | tr '_' ' ')
    echo "" >> "$temp_md"
    echo "# $chapter_name" >> "$temp_md"
    echo "" >> "$temp_md"
    
    # Ajouter seulement les 100 premières lignes du chapitre
    head -100 "$first_chapter" >> "$temp_md"
    echo "" >> "$temp_md"
fi

echo "📏 Taille fichier MD: $(wc -l < "$temp_md") lignes"

# Nettoyage Unicode identique au script principal
echo "🧹 Nettoyage Unicode..."
if [ -f "$SCRIPT_DIR/clean_unicode.sh" ]; then
    "$SCRIPT_DIR/clean_unicode.sh" "$temp_md" > /dev/null 2>&1 || true
    echo "  ✅ Nettoyage Unicode appliqué"
else
    echo "  ⚠️ Script clean_unicode.sh non trouvé"
fi

# Test génération PDF EXACTEMENT comme dans le script
echo ""
echo "🔨 Test génération PDF (reproduction exacte script principal)..."

cd "$BUILD_DIR"

# Commande EXACTE du script build_formations.sh
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
    --variable babel-lang=french \
    -o "$(basename "$output_file")" 2>&1; then

    echo "✅ PDF généré avec succès: $output_file"
    ls -lh "$output_file"
else
    echo "❌ Erreur génération PDF"
    echo ""
    echo "🔍 Contenu du fichier markdown (premières/dernières lignes):"
    echo "--- DÉBUT ---"
    head -20 "$temp_md"
    echo "--- ... ---"
    tail -20 "$temp_md"
    echo "--- FIN ---"
    
    echo ""
    echo "🔍 Vérification blocs de code:"
    echo "Nombre de \`\`\`: $(grep -c '```' "$temp_md" || echo 0)"
    
    echo ""
    echo "🔍 Recherche caractères problématiques:"
    echo "Caractères Unicode: $(grep -P '[^\x00-\x7F]' "$temp_md" | head -5 || echo 'Aucun')"
    
    exit 1
fi

echo ""
echo "🎯 Diagnostic terminé avec succès"