#!/bin/bash

# Script de génération PDF pour la formation Linux complète
# Usage: ./build_formation_complete.sh [type]
# Types: complete (défaut), acceleree, modules-only

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build"
SUPPORTS_DIR="$ROOT_DIR/supports"
TP_DIR="$ROOT_DIR/travaux_pratiques"

TYPE="${1:-complete}"

echo "📚 Génération de la formation Linux complète (type: $TYPE)..."

# Créer le répertoire de build s'il n'existe pas
mkdir -p "$BUILD_DIR"

# Vérifier que les modules existent
if [ ! -d "$SUPPORTS_DIR" ]; then
    echo "❌ Erreur: Répertoire des supports non trouvé: $SUPPORTS_DIR"
    exit 1
fi

# Nom du fichier de sortie selon le type
case "$TYPE" in
    "complete")
        OUTPUT_FILE="formation_linux_complete.pdf"
        TEMP_FILE="$BUILD_DIR/temp_formation_complete.md"
        ;;
    "acceleree")
        OUTPUT_FILE="formation_linux_acceleree.pdf"
        TEMP_FILE="$BUILD_DIR/temp_formation_acceleree.md"
        ;;
    "modules-only")
        OUTPUT_FILE="formation_linux_modules_seuls.pdf"
        TEMP_FILE="$BUILD_DIR/temp_formation_modules.md"
        ;;
    *)
        echo "❌ Type non reconnu: $TYPE (complete, acceleree, modules-only)"
        exit 1
        ;;
esac

echo "📄 Compilation du contenu pour: $TYPE..."

# En-tête du document
cat > "$TEMP_FILE" << 'EOF'
---
title: "Formation Linux"
subtitle: "Guide complet - Débutant à intermédiaire"
author: "Formation Linux - Prima Solutions"
date: \today
lang: fr
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

# Présentation de la formation

Cette formation Linux s'adresse à un public généraliste souhaitant découvrir et maîtriser les bases du système d'exploitation Linux.

## Public cible

- **Prérequis** : Connaissance générale d'un système d'exploitation, notion de fichier et d'arborescence
- **Niveau** : Débutant à intermédiaire  
- **Durée** : Variable selon le format choisi

## Formats de formation

### Format accéléré (8 heures)
- **Public** : Utilisateurs avec VM Linux et accès SSH
- **Durée** : 2 séances de 4 heures
- **Focus** : Essentiel pratique et opérationnel

### Format étalé (37h30)
- **Public** : Utilisateurs Windows avec VirtualBox
- **Durée** : 25 séances de 1h30
- **Focus** : Apprentissage progressif et détaillé

## Structure du contenu

- 8 modules de formation couvrant tous les aspects essentiels
- Travaux pratiques pour chaque module
- Ressources complémentaires et références
- Évaluations adaptées au niveau

\newpage

EOF

# Ajouter les modules de base dans l'ordre
echo "  📝 Ajout des modules de base..."

for i in {1..8}; do
    MODULE_NUM=$(printf "%02d" $i)
    MODULE_DIR="$SUPPORTS_DIR/module_${MODULE_NUM}_*"
    
    # Trouver le répertoire du module (gestion des noms variables)
    MODULE_PATH=$(ls -d $MODULE_DIR 2>/dev/null | head -1)
    
    if [ -d "$MODULE_PATH" ]; then
        MODULE_NAME=$(basename "$MODULE_PATH" | sed 's/module_[0-9]*_//' | tr '_' ' ')
        MODULE_TITLE=$(echo "$MODULE_NAME" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
        
        echo "    - Module $i: $MODULE_TITLE"
        
        echo "" >> "$TEMP_FILE"
        echo "\\newpage" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        echo "# Module $i : $MODULE_TITLE" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        
        # Ajouter tous les chapitres du module avec décalage des titres
        for chapter in "$MODULE_PATH"/*.md; do
            if [ -f "$chapter" ]; then
                chapter_name=$(basename "$chapter" .md)
                echo "      - $chapter_name"
                echo "" >> "$TEMP_FILE"
                # Décaler tous les titres d'un niveau vers le bas (# devient ##, ## devient ###, etc.)
                sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/## /g; s/TEMP3/### /g; s/TEMP4/#### /g; s/TEMP5/##### /g; s/TEMP6/###### /g' "$chapter" >> "$TEMP_FILE"
                echo "" >> "$TEMP_FILE"
            fi
        done
        
        # Ajouter les travaux pratiques si ce n'est pas le type "modules-only"
        if [ "$TYPE" != "modules-only" ]; then
            TP_NUM=$(printf "%02d" $i)
            TP_DIR_PATTERN="$TP_DIR/tp${TP_NUM}_*"
            TP_PATH=$(ls -d $TP_DIR_PATTERN 2>/dev/null | head -1)
            
            if [ -d "$TP_PATH" ]; then
                echo "      + Travaux pratiques"
                echo "" >> "$TEMP_FILE"
                echo "## Travaux pratiques - Module $i" >> "$TEMP_FILE"
                echo "" >> "$TEMP_FILE"
                
                for tp_file in "$TP_PATH"/*.md; do
                    if [ -f "$tp_file" ]; then
                        tp_name=$(basename "$tp_file" .md)
                        echo "        - $tp_name"
                        echo "" >> "$TEMP_FILE"
                        echo "### $(echo $tp_name | tr '_' ' ')" >> "$TEMP_FILE"
                        echo "" >> "$TEMP_FILE"
                        # Décaler tous les titres d'un niveau vers le bas pour les TP aussi
                        sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/## /g; s/TEMP3/### /g; s/TEMP4/#### /g; s/TEMP5/##### /g; s/TEMP6/###### /g' "$tp_file" >> "$TEMP_FILE"
                        echo "" >> "$TEMP_FILE"
                    fi
                done
            fi
        fi
    else
        echo "    ⚠️ Module $i non trouvé dans $MODULE_DIR"
    fi
done

# Pour le type complet, ajouter aussi les modules additionnels
if [ "$TYPE" = "complete" ]; then
    echo "  📝 Ajout des modules additionnels..."
    
    if [ -d "$SUPPORTS_DIR/modules_additionnels" ]; then
        echo "" >> "$TEMP_FILE"
        echo "\\newpage" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        echo "# Modules additionnels" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        echo "Les modules additionnels sont des modules complémentaires qui peuvent être suivis indépendamment après avoir complété les modules de base." >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        
        # Module Git
        if [ -d "$SUPPORTS_DIR/modules_additionnels/module_git" ]; then
            echo "    - Module additionnel Git"
            echo "" >> "$TEMP_FILE"
            echo "\\newpage" >> "$TEMP_FILE"
            echo "" >> "$TEMP_FILE"
            echo "## Module additionnel : Git - Contrôle de version" >> "$TEMP_FILE"
            echo "" >> "$TEMP_FILE"
            
            for chapter in "$SUPPORTS_DIR/modules_additionnels/module_git"/*.md; do
                if [ -f "$chapter" ]; then
                    echo "" >> "$TEMP_FILE"
                    # Décaler tous les titres d'un niveau vers le bas
                    sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/### /g; s/TEMP3/#### /g; s/TEMP4/##### /g; s/TEMP5/###### /g; s/TEMP6/####### /g' "$chapter" >> "$TEMP_FILE"
                    echo "" >> "$TEMP_FILE"
                fi
            done
        fi
        
        # Module Docker  
        if [ -d "$SUPPORTS_DIR/modules_additionnels/module_docker" ]; then
            echo "    - Module additionnel Docker"
            echo "" >> "$TEMP_FILE"
            echo "\\newpage" >> "$TEMP_FILE"
            echo "" >> "$TEMP_FILE"
            echo "## Module additionnel : Docker - Conteneurisation" >> "$TEMP_FILE"
            echo "" >> "$TEMP_FILE"
            
            for chapter in "$SUPPORTS_DIR/modules_additionnels/module_docker"/*.md; do
                if [ -f "$chapter" ]; then
                    echo "" >> "$TEMP_FILE"
                    # Décaler tous les titres d'un niveau vers le bas
                    sed 's/^##### /TEMP6/g; s/^#### /TEMP5/g; s/^### /TEMP4/g; s/^## /TEMP3/g; s/^# /TEMP2/g; s/TEMP2/### /g; s/TEMP3/#### /g; s/TEMP4/##### /g; s/TEMP5/###### /g; s/TEMP6/####### /g' "$chapter" >> "$TEMP_FILE"
                    echo "" >> "$TEMP_FILE"
                fi
            done
        fi
    fi
fi

# Nettoyage des caractères Unicode
echo "🧹 Nettoyage des caractères Unicode..."
"$SCRIPT_DIR/clean_unicode.sh" "$TEMP_FILE"

# Génération du PDF
echo "📚 Génération du PDF..."
cd "$BUILD_DIR"

# Créer un fichier header LaTeX temporaire pour configurer la numérotation
HEADER_TEX="$BUILD_DIR/header.tex"
cat > "$HEADER_TEX" << 'EOF'
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{titlesec}
\usepackage{tocloft}

% Configurer la numérotation : sections non numérotées, subsections et subsubsections numérotées
\setcounter{secnumdepth}{2}

% Supprimer la numérotation des sections (modules)
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

# Tentative de génération avec template
if pandoc \
    --from markdown \
    --to pdf \
    --pdf-engine=pdflatex \
    --include-in-header="$HEADER_TEX" \
    --template="$SCRIPT_DIR/../templates/pdf_template.tex" \
    --toc \
    --toc-depth=3 \
    --number-sections \
    --highlight-style=tango \
    --variable fontsize=11pt \
    --variable geometry:margin=2cm \
    --variable colorlinks=true \
    --variable linkcolor=blue \
    --variable urlcolor=blue \
    --output="$OUTPUT_FILE" \
    "$(basename $TEMP_FILE)" 2>/dev/null; then
    
    echo "✅ PDF généré avec succès: $OUTPUT_FILE"
else
    echo "⚠️ Erreur avec template, tentative version simplifiée..."
    
    # Génération simplifiée sans template personnalisé
    if pandoc \
        --from markdown \
        --to pdf \
        --pdf-engine=pdflatex \
        --include-in-header="$HEADER_TEX" \
        --toc \
        --toc-depth=3 \
        --number-sections \
        --highlight-style=tango \
        --variable fontsize=11pt \
        --variable geometry:margin=2cm \
        --variable colorlinks=true \
        --variable linkcolor=blue \
        --variable urlcolor=blue \
        --output="$OUTPUT_FILE" \
        "$(basename $TEMP_FILE)"; then
        
        echo "✅ PDF généré en mode simplifié: $OUTPUT_FILE"
    else
        echo "❌ Échec de la génération PDF"
        echo "💡 Vérifiez les erreurs ci-dessus et le contenu du fichier $(basename $TEMP_FILE)"
        exit 1
    fi
fi

# Nettoyage des fichiers temporaires
rm -f "$HEADER_TEX"
rm -f temp_cover_*.* 2>/dev/null || true

# Statistiques
if [ -f "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    PAGE_COUNT=$(pdfinfo "$OUTPUT_FILE" 2>/dev/null | grep "Pages:" | awk '{print $2}' || echo "?")
    echo "🎉 Formation Linux PDF générée: $BUILD_DIR/$OUTPUT_FILE"
    echo "📊 Taille: $FILE_SIZE | Pages: $PAGE_COUNT"
else
    echo "❌ Fichier PDF non créé"
    exit 1
fi