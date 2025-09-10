#!/bin/bash

# Script de debug pour la boucle de génération des modules

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Inclure les fonctions nécessaires
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/build_formations.sh"

echo "🐛 Debug boucle génération modules"
echo "=================================="

# Simuler la boucle de génération
success_count=0
echo "  🔍 Début de la boucle pour les modules 1 à 3 (test)"

for module_num in {1..3}; do
    echo ""
    echo "  🔄 Début traitement module $module_num"

    # Appeler la fonction
    generate_individual_module "$module_num"
    result=$?

    echo "  📊 Résultat fonction: $result"

    if [ $result -eq 0 ]; then
        ((success_count++))
        echo "  ✅ Module $module_num traité avec succès (total: $success_count)"
    else
        echo "  ❌ Échec traitement module $module_num"
    fi

    echo "  🔄 Fin traitement module $module_num"
    echo "  📈 Progress: $success_count modules réussis"
done

echo ""
echo "📊 Résultats debug:"
echo "==================="
echo "Modules testés: 3"
echo "Modules réussis: $success_count"
echo "Modules échoués: $((3 - success_count))"