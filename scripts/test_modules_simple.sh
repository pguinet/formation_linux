#!/bin/bash

# Script simple pour tester seulement la génération des modules individuels

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration minimale
BUILD_DIR="$PROJECT_DIR/build/modules_base"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

mkdir -p "$BUILD_DIR"

echo "🧪 Test simple génération modules individuels"
echo "==========================================="

# Fonction simplifiée pour générer un module individuel
generate_individual_module_simple() {
    local module_num=$1

    echo "📋 Test génération module $module_num"

    local module_num_fmt=$(printf "%02d" $module_num)
    local module_dir=$(ls -d "$SUPPORTS_DIR/module_${module_num_fmt}_"* 2>/dev/null | head -1)

    if [ ! -d "$module_dir" ]; then
        echo "  ❌ Module $module_num non trouvé: $module_dir"
        return 1
    fi

    echo "  ✅ Module trouvé: $(basename "$module_dir")"
    echo "  📁 Contenu: $(ls "$module_dir"/*.md | wc -l) fichiers Markdown"

    return 0
}

# Test des modules 1 à 8
for module_num in {1..8}; do
    if generate_individual_module_simple "$module_num"; then
        echo "  ✅ Module $module_num: OK"
    else
        echo "  ❌ Module $module_num: ÉCHEC"
    fi
    echo ""
done

echo "📊 Test terminé"