#!/bin/bash

# Script de génération du PDF pour le module Git uniquement
# Version rapide pour tester le module Git

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build/modules_additionnels"
SUPPORTS_DIR="$PROJECT_DIR/supports/modules_additionnels"
TP_DIR="$PROJECT_DIR/travaux_pratiques/tp_additionnels"

DATE=$(date "+%d/%m/%Y")

echo "🔧 Génération du module Git..."

mkdir -p "$BUILD_DIR"

# Vérification que le module Git existe
MODULE_DIR="$SUPPORTS_DIR/module_git"
TP_GIT_DIR="$TP_DIR/tp_git"

if [ ! -d "$MODULE_DIR" ]; then
    echo "❌ Module Git non trouvé dans $MODULE_DIR"
    exit 1
fi

# Configuration du module Git
TITLE="Module additionnel : Git"
OUTPUT_FILE="$BUILD_DIR/module_additionnel_git.pdf"
TEMP_MD="$BUILD_DIR/temp_git.md"

echo "📄 Génération: $TITLE"

# Création du fichier temporaire de contenu
cat > "$TEMP_MD" << EOF
---
title: "$TITLE"
author: "Pascal Guinet - Prima Solutions"
date: "$DATE"
geometry: "margin=2.5cm"
---

EOF

# Ajout du contenu du module Git dans l'ordre
for file in "$MODULE_DIR"/0*.md; do
    if [ -f "$file" ]; then
        echo "  📖 Ajout: $(basename "$file")"
        # Décaler tous les titres d'un niveau vers le bas
        sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/## /g; s/TEMP3/### /g; s/TEMP4/#### /g; s/TEMP5/##### /g; s/TEMP6/###### /g' "$file" >> "$TEMP_MD"
        echo "" >> "$TEMP_MD"
        echo "\\newpage" >> "$TEMP_MD"
        echo "" >> "$TEMP_MD"
    fi
done

# Ajout des TP Git
if [ -d "$TP_GIT_DIR" ]; then
    echo "# Travaux Pratiques" >> "$TEMP_MD"
    echo "" >> "$TEMP_MD"
    
    for tp_file in "$TP_GIT_DIR"/tp*.md "$TP_GIT_DIR"/exercices*.md; do
        if [ -f "$tp_file" ]; then
            tp_name=$(basename "$tp_file" .md | tr '_' ' ' | sed 's/\b\w/\U&/g')
            echo "  📝 Ajout TP: $tp_name"
            echo "## $tp_name" >> "$TEMP_MD"
            echo "" >> "$TEMP_MD"
            # Décaler tous les titres d'un niveau vers le bas pour les TP
            sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/### /g; s/TEMP3/#### /g; s/TEMP4/##### /g; s/TEMP5/###### /g; s/TEMP6/####### /g' "$tp_file" >> "$TEMP_MD"
            echo "" >> "$TEMP_MD"
            echo "\\newpage" >> "$TEMP_MD"
            echo "" >> "$TEMP_MD"
        fi
    done
fi

# Nettoyage des caractères Unicode problématiques pour LaTeX
echo "🧹 Nettoyage des caractères Unicode..."
"$SCRIPT_DIR/clean_unicode.sh" "$TEMP_MD"

# Génération du PDF
echo "📄 Génération du PDF..."

# Créer un fichier header LaTeX temporaire pour configurer la numérotation
HEADER_TEX="$BUILD_DIR/header_git.tex"
cat > "$HEADER_TEX" << 'EOF'
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
    -o "$OUTPUT_FILE" 2>/dev/null || {
        echo "⚠️ Erreur avec la version complète, tentative version simplifiée..."
        pandoc "$TEMP_MD" \
            --pdf-engine=pdflatex \
            --toc \
            --number-sections \
            -V lang=fr \
            -V geometry:"margin=2.5cm" \
            -o "$OUTPUT_FILE"
    }

# Nettoyage
rm -f "$TEMP_MD" "$HEADER_TEX"

if [ -f "$OUTPUT_FILE" ]; then
    echo "✅ Module Git généré avec succès: $(basename "$OUTPUT_FILE")"
    echo "📁 Fichier: $OUTPUT_FILE"
    echo "📊 Taille: $(du -h "$OUTPUT_FILE" | cut -f1)"
    echo ""
    echo "🔍 Contenu du PDF:"
    echo "   - 4 chapitres théoriques"
    echo "   - 3 TP pratiques"
    echo "   - Exercices supplémentaires avec corrections"
    echo ""
    echo "📖 Pour visualiser: xdg-open '$OUTPUT_FILE'"
else
    echo "❌ Erreur lors de la génération du module Git"
    exit 1
fi