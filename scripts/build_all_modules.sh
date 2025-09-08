#!/bin/bash

# Script de génération de tous les PDFs (modules de base + additionnels)
# Usage: ./build_all_modules.sh

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build"
SUPPORTS_DIR="$ROOT_DIR/supports"
TP_DIR="$ROOT_DIR/travaux_pratiques"

echo "🏗️ Génération de tous les modules de formation Linux..."

# Créer les répertoires de build
mkdir -p "$BUILD_DIR"/{modules_base,modules_additionnels}

# Fonction de génération d'un module individuel
build_single_module() {
    local module_num="$1"
    local module_path="$2"
    local output_dir="$3"
    
    local module_name=$(basename "$module_path" | sed 's/module_[0-9]*_//' | tr '_' ' ')
    local module_title=$(echo "$module_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
    local temp_file="$output_dir/temp_module_$(printf "%02d" $module_num).md"
    local output_file="$output_dir/module_$(printf "%02d" $module_num)_$(echo $module_name | tr ' ' '_').pdf"
    
    echo "  📄 Module $module_num: $module_title"
    
    # En-tête du module
    cat > "$temp_file" << EOF
---
title: "Formation Linux - Module $module_num"
subtitle: "$module_title"
author: "Formation Linux - Prima Solutions"
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

# Module $module_num : $module_title

EOF

    # Ajouter tous les chapitres du module
    for chapter in "$module_path"/*.md; do
        if [ -f "$chapter" ]; then
            chapter_name=$(basename "$chapter" .md)
            echo "    - $chapter_name"
            echo "" >> "$temp_file"
            echo "## $(echo $chapter_name | sed 's/[0-9]*_//' | tr '_' ' ')" >> "$temp_file"
            echo "" >> "$temp_file"
            cat "$chapter" >> "$temp_file"
            echo "" >> "$temp_file"
        fi
    done
    
    # Ajouter les travaux pratiques
    local tp_num=$(printf "%02d" $module_num)
    local tp_path=$(ls -d "$TP_DIR/tp${tp_num}_"* 2>/dev/null | head -1)
    
    if [ -d "$tp_path" ]; then
        echo "    + Travaux pratiques"
        echo "" >> "$temp_file"
        echo "\\newpage" >> "$temp_file"
        echo "" >> "$temp_file"
        echo "# Travaux pratiques" >> "$temp_file"
        echo "" >> "$temp_file"
        
        for tp_file in "$tp_path"/*.md; do
            if [ -f "$tp_file" ]; then
                tp_name=$(basename "$tp_file" .md)
                echo "      - $tp_name"
                echo "" >> "$temp_file"
                echo "## $(echo $tp_name | tr '_' ' ')" >> "$temp_file"
                echo "" >> "$temp_file"
                cat "$tp_file" >> "$temp_file"
                echo "" >> "$temp_file"
            fi
        done
    fi
    
    # Nettoyage Unicode
    "$SCRIPT_DIR/clean_unicode.sh" "$temp_file" > /dev/null
    
    # Génération PDF
    cd "$output_dir"
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
        --output="$(basename "$output_file")" \
        "$(basename "$temp_file")" 2>/dev/null; then
        
        echo "    ✅ Généré: $(basename "$output_file")"
        rm -f "$temp_file"
        return 0
    else
        echo "    ❌ Échec: Module $module_num"
        return 1
    fi
}

# Générer les modules de base (1-8)
echo "📚 Génération des modules de base..."
SUCCESS_COUNT=0
TOTAL_MODULES=8

for i in {1..8}; do
    MODULE_NUM=$(printf "%02d" $i)
    MODULE_PATH=$(ls -d "$SUPPORTS_DIR/module_${MODULE_NUM}_"* 2>/dev/null | head -1)
    
    if [ -d "$MODULE_PATH" ]; then
        if build_single_module "$i" "$MODULE_PATH" "$BUILD_DIR/modules_base"; then
            ((SUCCESS_COUNT++))
        fi
    else
        echo "  ⚠️ Module $i non trouvé"
    fi
done

# Générer la formation complète
echo ""
echo "📖 Génération de la formation complète..."
if "$SCRIPT_DIR/build_formation_complete.sh" complete; then
    echo "  ✅ Formation complète générée"
    ((SUCCESS_COUNT++))
    ((TOTAL_MODULES++))
else
    echo "  ❌ Échec formation complète"
fi

# Générer la formation accélérée
echo ""
echo "⚡ Génération de la formation accélérée..."
if "$SCRIPT_DIR/build_formation_complete.sh" acceleree; then
    echo "  ✅ Formation accélérée générée"
    ((SUCCESS_COUNT++))
    ((TOTAL_MODULES++))
else
    echo "  ❌ Échec formation accélérée"
fi

# Générer les modules additionnels
echo ""
echo "🔧 Génération des modules additionnels..."
if "$SCRIPT_DIR/build_modules_additionnels.sh"; then
    echo "  ✅ Modules additionnels générés"
    ((SUCCESS_COUNT+=2))  # Git + Docker
    ((TOTAL_MODULES+=2))
else
    echo "  ❌ Échec modules additionnels"
fi

# Résumé final
echo ""
echo "📊 Résumé de génération:"
echo "  ✅ Réussis: $SUCCESS_COUNT/$TOTAL_MODULES"

if [ -d "$BUILD_DIR" ]; then
    echo ""
    echo "📁 Fichiers générés:"
    find "$BUILD_DIR" -name "*.pdf" -exec du -h {} \; | sort
    
    TOTAL_SIZE=$(find "$BUILD_DIR" -name "*.pdf" -exec du -b {} + | awk '{sum+=$1} END {print sum}')
    if [ -n "$TOTAL_SIZE" ]; then
        TOTAL_SIZE_MB=$((TOTAL_SIZE / 1024 / 1024))
        echo ""
        echo "📐 Taille totale: ${TOTAL_SIZE_MB}MB"
    fi
fi

if [ $SUCCESS_COUNT -eq $TOTAL_MODULES ]; then
    echo "🎉 Tous les modules ont été générés avec succès!"
    exit 0
else
    echo "⚠️ Certains modules ont échoué."
    exit 1
fi