#!/bin/bash

# Script pour corriger et tester la génération des modules individuels

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Inclure les fonctions nécessaires
source "$SCRIPT_DIR/config.sh"

echo "🔧 Correction génération modules individuels"
echo "==========================================="

# Fonction pour générer un module individuel (version corrigée)
generate_individual_module_fixed() {
    local module_num=$1

    local module_num_fmt=$(printf "%02d" $module_num)
    local module_dir=$(ls -d "$SUPPORTS_DIR/module_${module_num_fmt}_"* 2>/dev/null | head -1)

    if [ ! -d "$module_dir" ]; then
        echo "  ❌ Module $module_num non trouvé: $module_dir"
        return 1
    fi

    local module_name=$(basename "$module_dir" | sed 's/module_[0-9]*_//' | tr '_' ' ')
    local module_title=$(echo "$module_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
    local output_file="$BUILD_DIR/modules_base/module_${module_num_fmt}_$(echo $module_name | tr ' ' '_').pdf"
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
        return 1
    fi
}

# Générer tous les modules
echo "🚀 Génération de tous les modules individuels..."
success_count=0

for module_num in {1..8}; do
    echo ""
    echo "🔄 Module $module_num..."
    if generate_individual_module_fixed "$module_num"; then
        ((success_count++))
    fi
done

echo ""
echo "📊 Résultats finaux:"
echo "===================="
echo "Modules générés: $success_count/8"

if [ $success_count -eq 8 ]; then
    echo "🎉 SUCCÈS: Tous les modules ont été générés!"
else
    echo "⚠️ PARTIEL: $success_count modules générés sur 8"
fi

echo ""
echo "📁 Fichiers générés:"
find "$BUILD_DIR/modules_base/" -name "*.pdf" -exec ls -lh {} \; 2>/dev/null || echo "Aucun fichier trouvé"