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

\setcounter{section}{-1}

# $TITLE

## Présentation de la formation

Cette formation Linux s'adresse à un public généraliste souhaitant découvrir et maîtriser les bases du système d'exploitation Linux.

### Objectifs pédagogiques

- Comprendre les concepts fondamentaux de Linux
- Maîtriser les commandes de base du terminal
- Gérer les fichiers et dossiers efficacement
- Comprendre les droits et la sécurité
- Automatiser des tâches simples

## Licence

![Licence Creative Commons](ressources/images/licenses/cc-by-nc-sa.png)

Ce document est mis à disposition selon les termes de la [Licence Creative Commons Attribution - Pas d'Utilisation Commerciale - Partage dans les Mêmes Conditions 4.0 International](http://creativecommons.org/licenses/by-nc-sa/4.0/).

**Vous êtes autorisé à :**
- **Partager** — copier, distribuer et communiquer le matériel par tous moyens et sous tous formats
- **Adapter** — remixer, transformer et créer à partir du matériel

**Selon les conditions suivantes :**
- **Attribution** — Vous devez créditer l'Œuvre, intégrer un lien vers la licence et indiquer si des modifications ont été effectuées à l'Œuvre
- **Pas d'Utilisation Commerciale** — Vous n'êtes pas autorisé à faire un usage commercial de cette Œuvre
- **Partage dans les Mêmes Conditions** — Dans le cas où vous effectuez un remix, que vous transformez, ou créez à partir du matériel composant l'Œuvre originale, vous devez diffuser l'Œuvre modifiée dans les même conditions

EOF

# Fonction pour ajouter un module
add_module() {
    local module_num=$1
    local module_name=$2
    local module_dir="$SUPPORTS_DIR/module_${module_num}_${module_name}"
    local tp_dir="$TP_DIR/tp${module_num}_${module_name}"
    
    if [ -d "$module_dir" ]; then
        # Ajouter un saut de page avant chaque nouveau module (sauf le premier)
        if [ "$module_num" != "01" ]; then
            echo "\\newpage" >> "$TEMP_MD"
            echo "" >> "$TEMP_MD"
        fi
        
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

# Génération du PDF avec Pandoc 
echo "🔄 Conversion Markdown vers PDF..."

# Créer un fichier header LaTeX temporaire pour désactiver la numérotation niveau 1
HEADER_TEX="$BUILD_DIR/header.tex"
cat > "$HEADER_TEX" << 'EOF'
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{titlesec}
\usepackage{tocloft}

% Configurer la numérotation : sections non numérotées, subsections et subsubsections numérotées
\setcounter{secnumdepth}{2}

% Supprimer la numérotation des sections (modules) mais garder le comptage
\titleformat{\section}{\Large\bfseries}{}{0pt}{}
\titlespacing*{\section}{0pt}{3.5ex plus 1ex minus .2ex}{2.3ex plus .2ex}

% Réinitialiser le compteur de subsections à chaque nouvelle section
\makeatletter
\@addtoreset{subsection}{section}
\@addtoreset{subsubsection}{subsection}
\makeatother

% Garder la numérotation normale pour subsections et subsubsections
\titleformat{\subsection}{\large\bfseries}{\thesubsection.}{1em}{}
\titleformat{\subsubsection}{\normalsize\bfseries}{\thesubsubsection.}{1em}{}

% Table des matières - supprimer complètement la numérotation des sections
\renewcommand{\cftsecpresnum}{}
\renewcommand{\cftsecaftersnum}{}
\renewcommand{\cftsecnumwidth}{0pt}
\renewcommand{\cftsecfont}{\bfseries}
\renewcommand{\cftsecpagefont}{\bfseries}

% Ajuster la profondeur de la table des matières
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
    -o "$OUTPUT_FILE"

# Nettoyage
rm -f "$HEADER_TEX"

# Nettoyage (désactivé pour debug)
# rm -f "$TEMP_MD"

echo "✅ PDF généré: $OUTPUT_FILE"