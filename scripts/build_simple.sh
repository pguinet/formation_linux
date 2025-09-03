#!/bin/bash

# Script de génération simple sans LaTeX
# Génère des versions Markdown consolidées

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TP_DIR="$PROJECT_DIR/travaux_pratiques"

echo "📚 Génération des supports en Markdown consolidé..."

mkdir -p "$BUILD_DIR"

# Génération du Module 1
echo "📖 Génération du Module 1..."
MODULE1_FILE="$BUILD_DIR/module_01_decouverte.md"

cat > "$MODULE1_FILE" << EOF
# Module 1 : Découverte et premiers pas

**Formation Linux - Prima Solutions**  
*Généré le $(date "+%d/%m/%Y %H:%M")*

---

EOF

# Ajouter tous les fichiers du module 1
for file in "$SUPPORTS_DIR/module_01_decouverte"/*.md; do
    if [ -f "$file" ]; then
        echo "## $(basename "$file" .md | sed 's/^[0-9]*_//' | tr '_' ' ' | sed 's/\b\w/\U&/g')" >> "$MODULE1_FILE"
        echo "" >> "$MODULE1_FILE"
        cat "$file" >> "$MODULE1_FILE"
        echo -e "\n---\n" >> "$MODULE1_FILE"
    fi
done

# Ajouter les TP
echo "# Travaux Pratiques" >> "$MODULE1_FILE"
echo "" >> "$MODULE1_FILE"

for tp_file in "$TP_DIR/tp01_installation"/*.md; do
    if [ -f "$tp_file" ]; then
        echo "## $(basename "$tp_file" .md | tr '_' ' ' | sed 's/\b\w/\U&/g')" >> "$MODULE1_FILE"
        echo "" >> "$MODULE1_FILE"
        cat "$tp_file" >> "$MODULE1_FILE"
        echo -e "\n---\n" >> "$MODULE1_FILE"
    fi
done

echo "✅ Module 1 généré: $MODULE1_FILE"

# Génération d'un aperçu de la structure
STRUCTURE_FILE="$BUILD_DIR/structure_formation.md"
cat > "$STRUCTURE_FILE" << EOF
# Structure de la Formation Linux

**Généré le $(date "+%d/%m/%Y %H:%M")**

## Modules disponibles

EOF

# Lister tous les modules
for module_dir in "$SUPPORTS_DIR"/module_*; do
    if [ -d "$module_dir" ]; then
        module_name=$(basename "$module_dir" | sed 's/module_[0-9]*_//' | tr '_' ' ' | sed 's/\b\w/\U&/g')
        module_num=$(basename "$module_dir" | sed 's/module_\([0-9]*\)_.*/\1/')
        echo "### Module $module_num : $module_name" >> "$STRUCTURE_FILE"
        echo "" >> "$STRUCTURE_FILE"
        
        # Lister les chapitres
        for chapter in "$module_dir"/*.md; do
            if [ -f "$chapter" ]; then
                chapter_name=$(basename "$chapter" .md | sed 's/^[0-9]*_//' | tr '_' ' ')
                echo "- $chapter_name" >> "$STRUCTURE_FILE"
            fi
        done
        echo "" >> "$STRUCTURE_FILE"
    fi
done

echo "📋 Structure générée: $STRUCTURE_FILE"

echo ""
echo "📂 Fichiers générés dans $BUILD_DIR :"
ls -la "$BUILD_DIR"/*.md 2>/dev/null || echo "Aucun fichier .md trouvé"

echo ""
echo "💡 Pour voir le contenu:"
echo "   cat $MODULE1_FILE | head -50"
echo "   cat $STRUCTURE_FILE"