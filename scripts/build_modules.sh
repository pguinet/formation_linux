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
    
    # === GÉNÉRATION AVEC COUVERTURE ===
    local cover_tex="$BUILD_DIR/temp_cover_${module_num}.tex"
    local cover_pdf="$BUILD_DIR/temp_cover_${module_num}.pdf"
    local content_pdf="$BUILD_DIR/temp_content_${module_num}.pdf"
    
    # Génération de la couverture du module
    if [ -f "$TEMPLATE_DIR/couverture_module.tex" ]; then
        cp "$TEMPLATE_DIR/couverture_module.tex" "$cover_tex"
        sed -i "s/\\\$title\\\$/${title//\//\\\/}/g" "$cover_tex"
        sed -i "s/\\\$date\\\$/${DATE//\//\\\/}/g" "$cover_tex"
        
        cd "$PROJECT_DIR"
        pdflatex -output-directory="$BUILD_DIR" -interaction=nonstopmode "$cover_tex" > /dev/null 2>&1
        
        # Vérifier si le PDF de couverture a été créé (même avec des warnings)
        if [ ! -f "$cover_pdf" ]; then
            echo "    ⚠️ Erreur génération couverture pour $title"
        fi
    fi
    
    # Création du fichier temporaire de contenu
    cat > "$temp_md" << EOF
---
title: "$title"
author: "Pascal Guinet - Prima Solutions"
date: "$DATE"
geometry: "margin=2.5cm"
---

EOF
    
    # Ajout du contenu du module
    for file in "$module_dir"/*.md; do
        if [ -f "$file" ]; then
            # Décaler tous les titres d'un niveau vers le bas (# devient ##, ## devient ###, etc.)
            sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/## /g; s/TEMP3/### /g; s/TEMP4/#### /g; s/TEMP5/##### /g; s/TEMP6/###### /g' "$file" >> "$temp_md"
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
                # Décaler tous les titres d'un niveau vers le bas pour les TP aussi
                sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/## /g; s/TEMP3/### /g; s/TEMP4/#### /g; s/TEMP5/##### /g; s/TEMP6/###### /g' "$tp_file" >> "$temp_md"
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
        # Décaler tous les titres d'un niveau vers le bas pour le TP placeholder aussi
        sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/## /g; s/TEMP3/### /g; s/TEMP4/#### /g; s/TEMP5/##### /g; s/TEMP6/###### /g' "$tp_dir/exercice_principal.md" >> "$temp_md"
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
    
    # Créer un fichier header LaTeX temporaire pour désactiver la numérotation niveau 1
    local header_tex="$BUILD_DIR/header_${module_num}.tex"
    cat > "$header_tex" << 'EOF'
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

    # Génération du PDF de contenu
    pandoc "$temp_md" \
        --include-in-header="$header_tex" \
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
        -o "$content_pdf" 2>/dev/null || {
            echo "    ⚠️ Erreur génération contenu pour $title"
            # Version simplifiée sans template en cas d'erreur
            pandoc "$temp_md" \
                --pdf-engine=pdflatex \
                --toc \
                --number-sections \
                -V lang=fr \
                -V geometry:"margin=2.5cm" \
                -o "$content_pdf"
        }
    
    # === FUSION COUVERTURE + CONTENU ===
    if [ -f "$cover_pdf" ] && [ -f "$content_pdf" ]; then
        # Utilisation de pdfunite si disponible
        if command -v pdfunite &> /dev/null; then
            pdfunite "$cover_pdf" "$content_pdf" "$output_file" 2>/dev/null || cp "$content_pdf" "$output_file"
        # Sinon utilisation de ghostscript
        elif command -v gs &> /dev/null; then
            gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE="$output_file" -dBATCH "$cover_pdf" "$content_pdf" 2>/dev/null || cp "$content_pdf" "$output_file"
        else
            cp "$content_pdf" "$output_file"
        fi
    else
        # Pas de couverture, utilisation du contenu seul
        cp "$content_pdf" "$output_file" 2>/dev/null || {
            echo "    ⚠️ Utilisation du PDF sans couverture"
            cp "$content_pdf" "$output_file"
        }
    fi
    
    # Nettoyage
    rm -f "$temp_md" "$cover_tex" "$cover_pdf" "$content_pdf" "$header_tex"
    
    echo "  ✅ Généré: $(basename "$output_file")"
}

# Génération de tous les modules
for module_num in $(echo "${!MODULES[@]}" | tr ' ' '\n' | sort); do
    generate_module_pdf "$module_num" "${MODULES[$module_num]}"
done

echo "✅ Tous les modules ont été générés dans: $BUILD_DIR"
echo "📁 $(ls -1 "$BUILD_DIR"/*.pdf | wc -l) fichiers PDF créés"