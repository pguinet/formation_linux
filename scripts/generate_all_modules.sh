#!/bin/bash

# Script pour générer tous les modules individuels de base

# Ne pas arrêter sur erreur pour continuer avec les autres modules
# set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
BUILD_DIR="$PROJECT_DIR/build/modules_base"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

mkdir -p "$BUILD_DIR"

echo "🚀 Génération de tous les modules individuels de base"
echo "=================================================="

# Fonction pour générer un module individuel
generate_module() {
    local module_num=$1

    local module_num_fmt=$(printf "%02d" $module_num)
    local module_dir=$(ls -d "$SUPPORTS_DIR/module_${module_num_fmt}_"* 2>/dev/null | head -1)

    if [ ! -d "$module_dir" ]; then
        echo "  ❌ Module $module_num non trouvé"
        return 1
    fi

    local module_name=$(basename "$module_dir" | sed 's/module_[0-9]*_//' | tr '_' ' ')
    local module_title=$(echo "$module_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
    local output_file="$BUILD_DIR/module_${module_num_fmt}_$(echo $module_name | tr ' ' '_').pdf"
    local temp_md="$BUILD_DIR/temp_module_${module_num_fmt}.md"

    echo "  📄 Module $module_num: $module_title"

    # Créer le contenu Markdown
    cat > "$temp_md" << EOF
---
title: "Module $module_num : $module_title"
author: "Pascal Guinet - Prima Solutions"
date: $(date "+%d/%m/%Y")
---

# Module $module_num : $module_title

EOF

    # Ajouter les chapitres
    for chapter in "$module_dir"/*.md; do
        if [ -f "$chapter" ]; then
            local chapter_name=$(basename "$chapter" .md | sed 's/^[0-9]*_//' | tr '_' ' ')
            echo "## $chapter_name" >> "$temp_md"
            echo "" >> "$temp_md"
            cat "$chapter" >> "$temp_md"
            echo "" >> "$temp_md"
        fi
    done

    # Nettoyage basique
    "$SCRIPT_DIR/clean_unicode.sh" "$temp_md" > /dev/null 2>&1 || true

    # Génération PDF simplifiée
    echo "  🔨 Génération PDF..."
    if pandoc "$temp_md" \
        --pdf-engine=pdflatex \
        --toc \
        --toc-depth=2 \
        --highlight-style=tango \
        --variable geometry:margin=2.5cm \
        --variable fontsize=11pt \
        --variable documentclass:article \
        --variable papersize=a4 \
        --variable lang=fr \
        -o "$output_file" 2>&1; then

        echo "  ✅ Module $module_num généré: $(basename "$output_file")"
        rm -f "$temp_md"
        return 0
    else
        echo "  ❌ Erreur génération module $module_num"
        # Conserver le fichier temporaire pour debug
        echo "  📄 Fichier temporaire conservé: $temp_md"
        return 1
    fi
}

# Générer tous les modules
success_count=0
total_modules=8

for module_num in {1..8}; do
    echo "🔄 Traitement du module $module_num..."
    if generate_module "$module_num"; then
        ((success_count++))
        echo "  ✅ Module $module_num réussi"
    else
        echo "  ❌ Module $module_num échoué"
    fi
    echo ""
done

echo "📊 Résultats:"
echo "============="
echo "Modules générés avec succès: $success_count/$total_modules"

if [ $success_count -eq $total_modules ]; then
    echo "🎉 Tous les modules ont été générés !"
else
    echo "⚠️ Certains modules n'ont pas pu être générés"
fi

echo ""
echo "📁 Fichiers générés:"
find "$BUILD_DIR" -name "*.pdf" -exec ls -lh {} \;