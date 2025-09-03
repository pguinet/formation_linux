#!/bin/bash

# Script de génération PDF pour la formation Linux
# Usage: ./build_pdf.sh [complete|acceleree]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TP_DIR="$PROJECT_DIR/travaux_pratiques"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

# Paramètres
FORMAT=${1:-complete}
DATE=$(date "+%d/%m/%Y")
AUTHOR="Formation Linux - Prima Solutions"

case "$FORMAT" in
    "complete")
        TITLE="Formation Linux Complète"
        OUTPUT_FILE="$BUILD_DIR/formation_complete.pdf"
        INCLUDE_ALL=true
        ;;
    "acceleree")
        TITLE="Formation Linux Accélérée"
        OUTPUT_FILE="$BUILD_DIR/formation_acceleree.pdf"
        INCLUDE_ALL=false
        ;;
    *)
        echo "Usage: $0 [complete|acceleree]"
        exit 1
        ;;
esac

echo "📄 Génération du PDF: $TITLE"

# Création du fichier temporaire de contenu
TEMP_MD="$BUILD_DIR/temp_formation.md"
mkdir -p "$BUILD_DIR"

# En-tête du document
cat > "$TEMP_MD" << EOF
---
title: "$TITLE"
author: "$AUTHOR"
date: "$DATE"
geometry: "margin=2.5cm"
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

EOF

# Fonction pour ajouter un module
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
        
        # Ajouter les TP si format complet
        if [ "$INCLUDE_ALL" = true ] && [ -d "$tp_dir" ]; then
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

# Ajout des modules selon le format
if [ "$INCLUDE_ALL" = true ]; then
    # Format complet : tous les modules
    add_module "01" "decouverte"
    add_module "02" "navigation"
    add_module "03" "manipulation"
    add_module "04" "consultation"
    add_module "05" "droits"
    add_module "06" "processus"
    add_module "07" "reseaux"
    add_module "08" "automatisation"
else
    # Format accéléré : modules essentiels uniquement
    add_module "01" "decouverte"
    add_module "02" "navigation"
    add_module "03" "manipulation"
    add_module "04" "consultation"
    add_module "05" "droits"
    
    # Ajout d'un résumé des modules avancés
    cat >> "$TEMP_MD" << EOF
# Modules Avancés (Survol)

## Module 6 : Processus et Système
Gestion des processus, monitoring système, variables d'environnement.

## Module 7 : Réseaux et Services  
Configuration réseau de base, transferts de fichiers, services système.

## Module 8 : Automatisation et Scripts
Scripts bash, tâches programmées, personnalisation.

EOF
fi

# Nettoyage complet des caractères Unicode problématiques
echo "🧹 Nettoyage des caractères Unicode..."
# Caractères d'arborescence
sed -i 's/├/+/g' "$TEMP_MD"
sed -i 's/└/+/g' "$TEMP_MD" 
sed -i 's/│/|/g' "$TEMP_MD"
sed -i 's/─/-/g' "$TEMP_MD"
# Symboles mathématiques
sed -i 's/≠/!=/g' "$TEMP_MD"
sed -i 's/≤/<=/g' "$TEMP_MD"
sed -i 's/≥/>=/g' "$TEMP_MD"
sed -i 's/↔/<-->/g' "$TEMP_MD"
# Emojis et symboles
sed -i 's/✅/[OK]/g' "$TEMP_MD"
sed -i 's/❌/[NOK]/g' "$TEMP_MD"
sed -i 's/⚠️/[WARN]/g' "$TEMP_MD"
sed -i 's/📁/[DIR]/g' "$TEMP_MD"
sed -i 's/🔧/[TOOL]/g' "$TEMP_MD"
sed -i 's/🔍/[SEARCH]/g' "$TEMP_MD"
# Nettoyer tous les autres caractères Unicode en dehors de la plage ASCII
sed -i 's/[^\x00-\x7F]//g' "$TEMP_MD"

# Génération du PDF avec Pandoc 
echo "🔄 Conversion Markdown vers PDF..."
pandoc "$TEMP_MD" \
    --pdf-engine=pdflatex \
    --toc \
    --toc-depth=3 \
    --number-sections \
    --highlight-style=tango \
    --variable=geometry:"margin=2.5cm" \
    --variable=fontsize:11pt \
    --variable=documentclass:article \
    --variable=papersize:a4 \
    --variable=lang:fr \
    -o "$OUTPUT_FILE"

# Nettoyage
rm -f "$TEMP_MD"

echo "✅ PDF généré: $OUTPUT_FILE"