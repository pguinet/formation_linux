#!/bin/bash

# Script de génération des PDFs pour les modules additionnels
# Génère un PDF pour chaque module additionnel individuellement

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build/modules_additionnels"
SUPPORTS_DIR="$PROJECT_DIR/supports/modules_additionnels"
TP_DIR="$PROJECT_DIR/travaux_pratiques/tp_additionnels"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

DATE=$(date "+%d/%m/%Y")
AUTHOR="Formation Linux - Prima Solutions"

echo "📚 Génération des PDFs pour les modules additionnels..."

mkdir -p "$BUILD_DIR"

# Modules additionnels disponibles
declare -A MODULES_ADDITIONNELS
# Auto-détection des modules additionnels
for module_dir in "$SUPPORTS_DIR"/module_*; do
    if [ -d "$module_dir" ]; then
        module_name=$(basename "$module_dir" | sed 's/^module_//')
        MODULES_ADDITIONNELS["$module_name"]="$module_name"
    fi
done

# Si aucun module détecté, vérifier s'il y a au moins module_git
if [ ${#MODULES_ADDITIONNELS[@]} -eq 0 ]; then
    if [ -d "$SUPPORTS_DIR/module_git" ]; then
        MODULES_ADDITIONNELS["git"]="git"
    fi
fi

# Fonction de génération pour un module additionnel
generate_module_additionnel_pdf() {
    local module_name=$1
    local module_dir="$SUPPORTS_DIR/module_${module_name}"
    local tp_dir="$TP_DIR/tp_${module_name}"
    
    if [ ! -d "$module_dir" ]; then
        echo "⚠️  Module additionnel $module_name non trouvé dans $module_dir"
        return 1
    fi
    
    # Nom formaté du module
    local formatted_name=$(echo "$module_name" | tr '_' ' ' | sed 's/\b\w/\U&/g')
    local title="Module additionnel : $formatted_name"
    local output_file="$BUILD_DIR/module_additionnel_${module_name}.pdf"
    local temp_md="$BUILD_DIR/temp_module_${module_name}.md"
    
    echo "  📄 Génération: $title"
    
    # === GÉNÉRATION AVEC COUVERTURE ===
    local cover_tex="$BUILD_DIR/temp_cover_${module_name}.tex"
    local cover_pdf="$BUILD_DIR/temp_cover_${module_name}.pdf"
    local content_pdf="$BUILD_DIR/temp_content_${module_name}.pdf"
    
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
                sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/### /g; s/TEMP3/#### /g; s/TEMP4/##### /g; s/TEMP5/###### /g; s/TEMP6/####### /g' "$tp_file" >> "$temp_md"
                echo "" >> "$temp_md"
                echo "\\newpage" >> "$temp_md"
                echo "" >> "$temp_md"
            fi
        done
    fi
    
    # Nettoyage des caractères Unicode problématiques
    "$SCRIPT_DIR/clean_unicode.sh" "$temp_md"
    
    # Créer un fichier header LaTeX temporaire pour configurer la numérotation
    local header_tex="$BUILD_DIR/header_${module_name}.tex"
    cat > "$header_tex" << 'EOF'
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{titlesec}
\usepackage{tocloft}

% Configurer la numérotation : sections non numérotées, subsections et subsubsections numérotées
\setcounter{secnumdepth}{2}

% Supprimer la numérotation des sections (chapitres du module)
\titleformat{\section}{\Large\bfseries}{}{0pt}{}
\titlespacing*{\section}{0pt}{3.5ex plus 1ex minus .2ex}{2.3ex plus .2ex}

% Garder la numérotation normale pour subsections et subsubsections
\titleformat{\subsection}{\large\bfseries}{\thesubsection.}{1em}{}
\titleformat{\subsubsection}{\normalsize\bfseries}{\thesubsubsection.}{1em}{}

% Table des matières - supprimer complètement la numérotation des sections
\renewcommand{\cftsecpresnum}{}
\renewcommand{\cftsecaftersnum}{}
\renewcommand{\cftsecnumwidth}{0pt}
\renewcommand{\cftsecfont}{\bfseries}
\renewcommand{\cftsecpagefont}{\bfseries}

% Ajuster la profondeur de numérotation dans la table des matières
\setcounter{tocdepth}{3}
EOF

    # Génération du PDF de contenu
    pandoc "$temp_md" \
        --include-in-header="$header_tex" \
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
        -o "$content_pdf" 2>/dev/null || {
            echo "    ⚠️ Erreur génération contenu pour $title, tentative version simplifiée"
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
        if [ -f "$content_pdf" ]; then
            cp "$content_pdf" "$output_file"
        else
            echo "    ❌ Impossible de générer le PDF pour $title"
            return 1
        fi
    fi
    
    # Nettoyage
    rm -f "$temp_md" "$cover_tex" "$cover_pdf" "$content_pdf" "$header_tex"
    
    echo "  ✅ Généré: $(basename "$output_file")"
}

# Vérification qu'il y a des modules additionnels
if [ ${#MODULES_ADDITIONNELS[@]} -eq 0 ]; then
    echo "ℹ️  Aucun module additionnel trouvé dans $SUPPORTS_DIR"
    echo "   Les modules additionnels doivent être dans des dossiers nommés 'module_*'"
    exit 0
fi

# Génération de tous les modules additionnels
echo "🔍 Modules additionnels détectés: ${!MODULES_ADDITIONNELS[*]}"
for module_name in "${!MODULES_ADDITIONNELS[@]}"; do
    generate_module_additionnel_pdf "$module_name"
done

echo "✅ Tous les modules additionnels ont été générés dans: $BUILD_DIR"
echo "📁 $(ls -1 "$BUILD_DIR"/*.pdf 2>/dev/null | wc -l) fichiers PDF créés"