#!/bin/bash

# Test spécifique pour vérifier la génération de la formation accélérée

set -e

echo "🧪 Test formation accélérée - contenu des chapitres"

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SUPPORTS_DIR="$PROJECT_DIR/supports"
temp_md="$BUILD_DIR/test_formation_acceleree.md"

mkdir -p "$BUILD_DIR"

# Créer en-tête
cat > "$temp_md" << 'EOF'
---
title: "Test Formation Accélérée"
author: "Test"
date: \today
---

# Test Formation Accélérée

EOF

# Tester la fonction add_module_to_document avec mode condensed
echo "📄 Test ajout Module 1 en mode condensed..."

module_num=1
module_num_fmt=$(printf "%02d" $module_num)
module_dir=$(ls -d "$SUPPORTS_DIR/module_${module_num_fmt}_"* 2>/dev/null | head -1)
module_name=$(basename "$module_dir" | sed 's/module_[0-9]*_//' | tr '_' ' ')
module_title=$(echo "$module_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')

echo "" >> "$temp_md"
echo "\\newpage" >> "$temp_md"  
echo "" >> "$temp_md"
echo "# Module $module_num : $module_title {.unnumbered}" >> "$temp_md"
echo "" >> "$temp_md"

# Ajouter les chapitres en mode condensed
for chapter in "$module_dir"/*.md; do
    if [ -f "$chapter" ]; then
        chapter_name=$(basename "$chapter" .md | sed 's/^[0-9]*_//' | tr '_' ' ')
        echo "" >> "$temp_md"
        echo "# $chapter_name" >> "$temp_md"
        echo "" >> "$temp_md"
        
        echo "  📖 Traitement chapitre: $chapter_name"
        echo "    Fichier: $(basename "$chapter")"
        
        # Mode condensed
        second_h2_line=$(grep -n "^## " "$chapter" | sed -n '2p' | cut -d: -f1)
        echo "    Deuxième ## trouvé à la ligne: ${second_h2_line:-'non trouvé'}"
        
        if [ -n "$second_h2_line" ] && [ "$second_h2_line" -gt 10 ]; then
            # Prendre jusqu'au deuxième ## (exclu)
            lines_to_take=$((second_h2_line - 1))
            echo "    → Prise des $lines_to_take premières lignes"
            sed -n "1,${lines_to_take}p" "$chapter" >> "$temp_md"
        else
            # Prendre les 50 premières lignes comme version condensée  
            echo "    → Prise des 50 premières lignes"
            head -50 "$chapter" >> "$temp_md"
        fi
        
        echo "" >> "$temp_md"
        echo "" >> "$temp_md"
    fi
done

echo ""
echo "📏 Résultat: $(wc -l < "$temp_md") lignes générées"
echo ""
echo "📖 Aperçu du contenu généré:"
echo "--- DÉBUT (lignes 20-60) ---"
sed -n '20,60p' "$temp_md"
echo "--- FIN ---"

echo ""
echo "🎯 Test terminé. Fichier conservé: $temp_md"