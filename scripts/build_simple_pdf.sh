#!/bin/bash

# Script de génération PDF simple sans template complexe

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TP_DIR="$PROJECT_DIR/travaux_pratiques"

FORMAT=${1:-complete}
DATE=$(date "+%d/%m/%Y")
AUTHOR="Formation Linux - Prima Solutions"

case "$FORMAT" in
    "complete")
        TITLE="Formation Linux Complète"
        OUTPUT_FILE="$BUILD_DIR/formation_complete.pdf"
        ;;
    "acceleree")
        TITLE="Formation Linux Accélérée"
        OUTPUT_FILE="$BUILD_DIR/formation_acceleree.pdf"
        ;;
    *)
        echo "Usage: $0 [complete|acceleree]"
        exit 1
        ;;
esac

echo "📄 Génération du PDF simple: $TITLE"

TEMP_MD="$BUILD_DIR/temp_formation.md"
mkdir -p "$BUILD_DIR"

# En-tête du document
cat > "$TEMP_MD" << EOF
---
title: "$TITLE"
author: "$AUTHOR"
date: "$DATE"
---

# $TITLE

## Présentation de la formation

Cette formation Linux s'adresse à un public généraliste souhaitant découvrir et maîtriser les bases du système d'exploitation Linux.

### Objectifs pédagogiques

- Comprendre les concepts fondamentaux de Linux
- Maîtriser les commandes de base du terminal
- Gérer les fichiers et dossiers efficacement
- Comprendre les droits et la sécurité
- Automatiser des tâches simples

\\newpage

EOF

# Fonction pour ajouter un module (version simplifiée)
add_module() {
    local module_num=$1
    local module_name=$2
    local module_dir="$SUPPORTS_DIR/module_${module_num}_${module_name}"
    local tp_dir="$TP_DIR/tp${module_num}_${module_name}"
    
    if [ -d "$module_dir" ]; then
        echo "# Module $module_num : $(echo $module_name | tr '_' ' ' | sed 's/\b\w/\U&/g')" >> "$TEMP_MD"
        echo "" >> "$TEMP_MD"
        
        # Ajouter tous les fichiers .md du module
        for file in "$module_dir"/*.md; do
            if [ -f "$file" ]; then
                echo "## $(basename "$file" .md | sed 's/^[0-9]*_//' | tr '_' ' ' | sed 's/\b\w/\U&/g')" >> "$TEMP_MD"
                echo "" >> "$TEMP_MD"
                cat "$file" >> "$TEMP_MD"
                echo "" >> "$TEMP_MD"
                echo "\\newpage" >> "$TEMP_MD"
                echo "" >> "$TEMP_MD"
            fi
        done
        
        # Ajouter les TP
        if [ -d "$tp_dir" ]; then
            echo "## Travaux Pratiques - Module $module_num" >> "$TEMP_MD"
            echo "" >> "$TEMP_MD"
            
            for tp_file in "$tp_dir"/*.md; do
                if [ -f "$tp_file" ]; then
                    echo "### $(basename "$tp_file" .md | tr '_' ' ' | sed 's/\b\w/\U&/g')" >> "$TEMP_MD"
                    echo "" >> "$TEMP_MD"
                    cat "$tp_file" >> "$TEMP_MD"
                    echo "" >> "$TEMP_MD"
                fi
            done
            echo "\\newpage" >> "$TEMP_MD"
            echo "" >> "$TEMP_MD"
        fi
    fi
}

# Ajout du contenu selon le format
if [ "$FORMAT" = "complete" ]; then
    add_module "01" "decouverte"
else
    # Version accélérée - seulement module 1
    add_module "01" "decouverte"
fi

# Génération du PDF avec Pandoc (version simple)
echo "🔄 Conversion Markdown vers PDF (version simple)..."
pandoc "$TEMP_MD" \
    --pdf-engine=pdflatex \
    --toc \
    --toc-depth=2 \
    --number-sections \
    -V lang=fr \
    -V geometry:"margin=2.5cm" \
    -V fontsize=11pt \
    -V documentclass=article \
    -V papersize=a4 \
    -o "$OUTPUT_FILE"

# Nettoyage
rm -f "$TEMP_MD"

echo "✅ PDF généré: $OUTPUT_FILE"