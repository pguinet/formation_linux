#!/bin/bash

# Script de test pour déboguer la génération des modules individuels

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Inclure les fonctions du script principal
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/build_formations.sh"

echo "🧪 Test génération modules individuels"
echo "===================================="

# Test génération d'un seul module
echo "🔍 Test génération module 2..."
if generate_individual_module 2; then
    echo "✅ Module 2 généré avec succès"
else
    echo "❌ Échec génération module 2"
fi

echo ""
echo "🔍 Test génération module 3..."
if generate_individual_module 3; then
    echo "✅ Module 3 généré avec succès"
else
    echo "❌ Échec génération module 3"
fi

echo ""
echo "📊 Vérification des fichiers générés:"
find "$BUILD_DIR/modules_base/" -name "*.pdf" -exec ls -lh {} \;