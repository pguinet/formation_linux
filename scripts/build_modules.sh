#!/bin/bash

# Script de génération des PDFs par module
# Génère un PDF pour chaque module individuellement

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build/supports_par_module"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TP_DIR="$PROJECT_DIR/travaux_pratiques"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

DATE=$(date "+%d/%m/%Y")
AUTHOR="Formation Linux - Prima Solutions"

echo "📚 Génération des PDFs par module..."

mkdir -p "$BUILD_DIR"

# Modules à traiter
declare -A MODULES
MODULES[01]="decouverte"
MODULES[02]="navigation"
MODULES[03]="manipulation"
MODULES[04]="consultation"
MODULES[05]="droits"
MODULES[06]="processus"
MODULES[07]="reseaux"
MODULES[08]="automatisation"

# Fonction de génération pour un module
generate_module_pdf() {
    local module_num=$1
    local module_name=$2
    local module_dir="$SUPPORTS_DIR/module_${module_num}_${module_name}"
    local tp_dir="$TP_DIR/tp${module_num}_${module_name}"
    
    if [ ! -d "$module_dir" ]; then
        echo "⚠️  Module $module_num ($module_name) non trouvé, création d'un fichier placeholder"
        mkdir -p "$module_dir"
        cat > "$module_dir/01_introduction.md" << EOF
# Introduction

Ce module sera développé prochainement.

## Objectifs

- Objectif 1
- Objectif 2
- Objectif 3

## Contenu prévu

Le contenu de ce module est en cours de rédaction.
EOF
    fi
    
    # Nom formaté du module
    local formatted_name=$(echo "$module_name" | tr '_' ' ' | sed 's/\b\w/\U&/g')
    local title="Module $module_num : $formatted_name"
    local output_file="$BUILD_DIR/module_${module_num}_${module_name}.pdf"
    local temp_md="$BUILD_DIR/temp_module_${module_num}.md"
    
    echo "  📄 Génération: $title"
    
    # Création du fichier temporaire
    cat > "$temp_md" << EOF
---
title: "$title"
author: "$AUTHOR"
date: "$DATE"
logo: "ressources/images/logo.png"
---

# $title

EOF
    
    # Ajout du contenu du module
    for file in "$module_dir"/*.md; do
        if [ -f "$file" ]; then
            local chapter_name=$(basename "$file" .md | sed 's/^[0-9]*_//' | tr '_' ' ' | sed 's/\b\w/\U&/g')
            echo "## $chapter_name" >> "$temp_md"
            echo "" >> "$temp_md"
            cat "$file" >> "$temp_md"
            echo "" >> "$temp_md"
            echo "\\newpage" >> "$temp_md"
            echo "" >> "$temp_md"
        fi
    done
    
    # Ajout des TP
    if [ -d "$tp_dir" ]; then
        echo "# Travaux Pratiques" >> "$temp_md"
        echo "" >> "$temp_md"
        
        for tp_file in "$tp_dir"/*.md; do
            if [ -f "$tp_file" ]; then
                local tp_name=$(basename "$tp_file" .md | tr '_' ' ' | sed 's/\b\w/\U&/g')
                echo "## $tp_name" >> "$temp_md"
                echo "" >> "$temp_md"
                cat "$tp_file" >> "$temp_md"
                echo "" >> "$temp_md"
                echo "\\newpage" >> "$temp_md"
                echo "" >> "$temp_md"
            fi
        done
    else
        # Créer un TP placeholder
        mkdir -p "$tp_dir"
        cat > "$tp_dir/exercice_principal.md" << EOF
# Exercice Principal

## Objectif

Mettre en pratique les notions du module $module_num.

## Instructions

Les instructions détaillées seront ajoutées prochainement.

## Solution

La solution sera fournie dans une version ultérieure.
EOF
        echo "# Travaux Pratiques" >> "$temp_md"
        echo "" >> "$temp_md"
        echo "## Exercice Principal" >> "$temp_md"
        echo "" >> "$temp_md"
        cat "$tp_dir/exercice_principal.md" >> "$temp_md"
    fi
    
    # Nettoyage sélectif des caractères Unicode problématiques
    sed -i 's/├/+/g' "$temp_md"
    sed -i 's/└/+/g' "$temp_md" 
    sed -i 's/│/|/g' "$temp_md"
    sed -i 's/─/-/g' "$temp_md"
    sed -i 's/≠/!=/g' "$temp_md"
    sed -i 's/≤/<=/g' "$temp_md"
    sed -i 's/≥/>=/g' "$temp_md"
    sed -i 's/↔/<-->/g' "$temp_md"
    sed -i 's/✅/[OK]/g' "$temp_md"
    sed -i 's/❌/[NOK]/g' "$temp_md"
    sed -i 's/⚠️/[WARN]/g' "$temp_md"
    sed -i 's/📁/[DIR]/g' "$temp_md"
    sed -i 's/🔧/[TOOL]/g' "$temp_md"
    sed -i 's/🔍/[SEARCH]/g' "$temp_md"
    sed -i 's/✓/[OK]/g' "$temp_md"
    sed -i 's/✗/[NOK]/g' "$temp_md"
    sed -i 's/…/.../g' "$temp_md"
    
    # Génération du PDF
    pandoc "$temp_md" \
        --pdf-engine=pdflatex \
        --toc \
        --toc-depth=2 \
        --number-sections \
        --highlight-style=tango \
        --variable=geometry:"margin=2.5cm" \
        --variable=fontsize:11pt \
        --variable=documentclass:article \
        --variable=papersize:a4 \
        --variable=lang:fr \
        -o "$output_file" 2>/dev/null || {
            echo "⚠️  Erreur lors de la génération de $output_file, génération d'une version simplifiée"
            # Version simplifiée sans template en cas d'erreur
            pandoc "$temp_md" \
                --pdf-engine=pdflatex \
                --toc \
                --number-sections \
                -V lang=fr \
                -V geometry:"margin=2.5cm" \
                -o "$output_file"
        }
    
    # Nettoyage
    rm -f "$temp_md"
    
    echo "  ✅ Généré: $(basename "$output_file")"
}

# Génération de tous les modules
for module_num in $(echo "${!MODULES[@]}" | tr ' ' '\n' | sort); do
    generate_module_pdf "$module_num" "${MODULES[$module_num]}"
done

echo "✅ Tous les modules ont été générés dans: $BUILD_DIR"
echo "📁 $(ls -1 "$BUILD_DIR"/*.pdf | wc -l) fichiers PDF créés"