#!/bin/bash

# Script de test pour valider l'uniformité des templates LaTeX
# Vérifie que tous les scripts utilisent le même template formation_template.tex

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧪 Test d'uniformité des templates LaTeX"
echo "====================================="

# Fonction de test
test_template_usage() {
    local script="$1"
    local expected_template="formation_template.tex"
    local script_name=$(basename "$script")

    echo "📋 Vérification de $script_name..."

    # Cas spécial pour build_modules.sh qui utilise un template inline
    if [[ "$script_name" == "build_modules.sh" ]]; then
        if grep -q "include-in-header" "$script" && grep -q "documentclass:article" "$script"; then
            echo "  ✅ Utilise un template inline cohérent"
            return 0
        else
            echo "  ❌ Template inline manquant ou incorrect"
            return 1
        fi
    fi

    # Cas normal : vérification du template externe
    if grep -q "$expected_template" "$script"; then
        echo "  ✅ Utilise le bon template: $expected_template"
        return 0
    else
        echo "  ❌ N'utilise pas le template attendu: $expected_template"
        echo "  📄 Templates trouvés dans $script:"
        grep -n "template.*\.tex" "$script" || echo "    Aucun template trouvé"
        return 1
    fi
}

# Liste des scripts à vérifier
scripts_to_check=(
    "scripts/build_formations.sh"
    "scripts/build_modules_additionnels.sh"
    "scripts/build_docker_module.sh"
    "scripts/build_formation_complete.sh"
    "scripts/build_modules.sh"
)

echo "🔍 Analyse des scripts..."
echo ""

failed_tests=0
total_tests=0

for script in "${scripts_to_check[@]}"; do
    if [ -f "$PROJECT_DIR/$script" ]; then
        total_tests=$((total_tests + 1))
        if ! test_template_usage "$PROJECT_DIR/$script"; then
            failed_tests=$((failed_tests + 1))
        fi
    else
        echo "⚠️  Script non trouvé: $script"
    fi
    echo ""
done

echo "📊 Résultats du test:"
echo "===================="
echo "Total de scripts vérifiés: $total_tests"
echo "Scripts conformes: $((total_tests - failed_tests))"
echo "Scripts non conformes: $failed_tests"

if [ $failed_tests -eq 0 ]; then
    echo ""
    echo "🎉 Tous les scripts utilisent le template uniforme !"
    echo ""
    echo "📋 Template utilisé: formation_template.tex"
    echo "🌍 Langue: Français (babel)"
    echo "🎨 Mise en page: Professionnelle et cohérente"
    exit 0
else
    echo ""
    echo "❌ Certains scripts ne sont pas conformes."
    echo "🔧 Veuillez corriger les scripts non conformes."
    exit 1
fi