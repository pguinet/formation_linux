#!/bin/bash

# Script de génération PDF avec couverture pour la formation Linux
# Usage: ./build_pdf_with_cover.sh [complete|acceleree]

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
AUTHOR="Pascal Guinet - Prima Solutions"

case "$FORMAT" in
    "complete")
        TITLE="Formation Linux Complète"
        OUTPUT_FILE="$BUILD_DIR/formation_complete_avec_couverture.pdf"
        INCLUDE_ALL=true
        ;;
    "acceleree")
        TITLE="Formation Linux Accélérée"
        OUTPUT_FILE="$BUILD_DIR/formation_acceleree_avec_couverture.pdf"
        INCLUDE_ALL=false
        ;;
    *)
        echo "Usage: $0 [complete|acceleree]"
        exit 1
        ;;
esac

echo "📄 Génération du PDF avec couverture: $TITLE"

# Création du répertoire de build
mkdir -p "$BUILD_DIR"

# === GÉNÉRATION DE LA COUVERTURE ===
echo "🎨 Génération de la couverture..."

COVER_TEX="$BUILD_DIR/temp_couverture.tex"
COVER_PDF="$BUILD_DIR/temp_couverture.pdf"

# Copie et personnalisation du template de couverture
cp "$TEMPLATE_DIR/couverture.tex" "$COVER_TEX"
sed -i "s/\\\$title\\\$/${TITLE//\//\\\/}/g" "$COVER_TEX"
sed -i "s/\\\$date\\\$/${DATE//\//\\\/}/g" "$COVER_TEX"

# Génération du PDF de couverture
cd "$PROJECT_DIR"
pdflatex -output-directory="$BUILD_DIR" -interaction=nonstopmode "$COVER_TEX" > /dev/null 2>&1

# Vérifier si le PDF de couverture a été créé (même avec des warnings)
if [ ! -f "$COVER_PDF" ]; then
    echo "⚠️ Erreur lors de la génération de la couverture, utilisation du contenu seul"
else
    echo "✅ Couverture générée avec succès"
fi

# === GÉNÉRATION DU CONTENU PRINCIPAL ===
echo "📝 Génération du contenu principal..."

TEMP_MD="$BUILD_DIR/temp_formation.md"

# En-tête du document
cat > "$TEMP_MD" << EOF
---
title: "$TITLE"
author: "$AUTHOR"
date: "$DATE"
geometry: "margin=2.5cm"
---

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
                # Décaler tous les titres d'un niveau vers le bas (# devient ##, ## devient ###, etc.)
                sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/## /g; s/TEMP3/### /g; s/TEMP4/#### /g; s/TEMP5/##### /g; s/TEMP6/###### /g' "$file" >> "$TEMP_MD"
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
                    # Décaler tous les titres d'un niveau vers le bas pour les TP aussi
                    sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/## /g; s/TEMP3/### /g; s/TEMP4/#### /g; s/TEMP5/##### /g; s/TEMP6/###### /g' "$tp_file" >> "$TEMP_MD"
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

# Nettoyage des caractères Unicode problématiques
echo "🧹 Nettoyage des caractères Unicode..."
"$SCRIPT_DIR/clean_unicode.sh" "$TEMP_MD"

# === GÉNÉRATION DU CONTENU PRINCIPAL ===
echo "🔄 Conversion Markdown vers PDF..."

CONTENT_PDF="$BUILD_DIR/temp_content.pdf"

# Créer un fichier header LaTeX temporaire pour désactiver la numérotation niveau 1
HEADER_TEX="$BUILD_DIR/header.tex"
cat > "$HEADER_TEX" << 'EOF'
\usepackage{titlesec}
\usepackage{tocloft}

% Limiter la numérotation aux niveaux 2 et 3 seulement (subsection et subsubsection)
\setcounter{secnumdepth}{2}

% Désactiver la numérotation pour les sections (niveau 1)
\titleformat{\section}{\Large\bfseries}{\quad}{0pt}{}
\titlespacing*{\section}{0pt}{3.5ex plus 1ex minus .2ex}{2.3ex plus .2ex}

% Configuration table des matières - supprimer numérotation niveau 1
\renewcommand{\cftsecpresnum}{}
\renewcommand{\cftsecaftersnum}{}
\setlength{\cftsecnumwidth}{0pt}

% Ajuster la profondeur de numérotation dans la table des matières
\setcounter{tocdepth}{3}
EOF

pandoc "$TEMP_MD" \
    --include-in-header="$HEADER_TEX" \
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
    -o "$CONTENT_PDF"

# Nettoyage
rm -f "$HEADER_TEX"

# === FUSION DES PDFs ===
echo "📎 Fusion de la couverture et du contenu..."

if [ -f "$COVER_PDF" ] && [ -f "$CONTENT_PDF" ]; then
    # Utilisation de pdfunite si disponible
    if command -v pdfunite &> /dev/null; then
        pdfunite "$COVER_PDF" "$CONTENT_PDF" "$OUTPUT_FILE"
    # Sinon utilisation de ghostscript
    elif command -v gs &> /dev/null; then
        gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE="$OUTPUT_FILE" -dBATCH "$COVER_PDF" "$CONTENT_PDF"
    else
        echo "⚠️ Aucun outil de fusion PDF disponible. Utilisation du contenu seul."
        cp "$CONTENT_PDF" "$OUTPUT_FILE"
    fi
else
    echo "⚠️ Problème avec la couverture. Utilisation du contenu seul."
    cp "$CONTENT_PDF" "$OUTPUT_FILE"
fi

# Nettoyage des fichiers temporaires
rm -f "$BUILD_DIR"/temp_*

echo "✅ PDF généré avec couverture: $OUTPUT_FILE"