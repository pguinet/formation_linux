#!/bin/bash

# Test très simple pour générer seulement le module 2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration minimale
BUILD_DIR="$PROJECT_DIR/build/modules_base"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

mkdir -p "$BUILD_DIR"

echo "🧪 Test génération module 2 seulement"
echo "===================================="

# Fonction simplifiée pour le module 2
generate_module_2() {
    local module_num=2
    local module_num_fmt="02"
    local module_dir="$SUPPORTS_DIR/module_02_navigation"

    if [ ! -d "$module_dir" ]; then
        echo "❌ Module 2 non trouvé"
        return 1
    fi

    local output_file="$BUILD_DIR/module_02_navigation.pdf"
    local temp_md="$BUILD_DIR/temp_module_02.md"

    echo "📄 Génération module 2: Navigation"

    # Créer contenu simple
    cat > "$temp_md" << 'EOF'
---
title: "Module 2 : Navigation"
author: "Pascal Guinet - Prima Solutions"
date: $(date "+%d/%m/%Y")
---

# Module 2 : Navigation

## Arborescence Linux

Linux organise ses fichiers dans une structure hiérarchique appelée **arborescence**.

### Répertoires principaux

- **/** : Racine du système
- **/home** : Répertoires personnels des utilisateurs
- **/etc** : Fichiers de configuration
- **/var** : Données variables (logs, bases de données)
- **/usr** : Programmes et bibliothèques
- **/bin** : Commandes essentielles
- **/sbin** : Commandes d'administration

EOF

    # Génération PDF
    echo "🔨 Génération PDF..."
    if pandoc "$temp_md" \
        --pdf-engine=pdflatex \
        --toc \
        --variable geometry:margin=2.5cm \
        --variable fontsize=11pt \
        --variable documentclass:article \
        --variable papersize=a4 \
        --variable lang=fr \
        -o "$output_file" 2>&1; then

        echo "✅ Module 2 généré avec succès"
        rm -f "$temp_md"
        return 0
    else
        echo "❌ Erreur génération module 2"
        return 1
    fi
}

# Test
generate_module_2
result=$?

echo ""
echo "📊 Résultat: $result"
if [ $result -eq 0 ]; then
    echo "🎉 Test réussi!"
else
    echo "💥 Test échoué"
fi