#!/bin/bash

# Version debug du script pour identifier précisément où ça échoue dans GitHub Actions

set -e

echo "🚀 Génération formations Linux - VERSION DEBUG"
echo "============================================="

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SUPPORTS_DIR="$PROJECT_DIR/supports"

echo "📁 Debug: Répertoires"
echo "  - SCRIPT_DIR: $SCRIPT_DIR"
echo "  - PROJECT_DIR: $PROJECT_DIR"
echo "  - BUILD_DIR: $BUILD_DIR"
echo "  - SUPPORTS_DIR: $SUPPORTS_DIR"

# Vérifications de base
echo "🔍 Debug: Vérifications de base"
echo "  - Pandoc: $(which pandoc || echo 'NON TROUVÉ')"
echo "  - pdflatex: $(which pdflatex || echo 'NON TROUVÉ')"

# Nettoyage
echo "🧹 Debug: Nettoyage"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"/{formations,modules_base,modules_additionnels}
echo "  ✅ Répertoires créés"

# Test avec seulement les 3 premiers modules pour isoler le problème
echo ""
echo "📖 DEBUG: Test génération 3 premiers modules seulement"
success_count=0

for module_num in {1..3}; do
    echo ""
    echo "🔄 DEBUG: === DÉBUT MODULE $module_num ==="
    echo "  - Date: $(date)"
    echo "  - PWD: $(pwd)"
    echo "  - success_count AVANT: $success_count"
    
    # Vérifier que le module existe
    module_num_fmt=$(printf "%02d" $module_num)
    module_dir=$(ls -d "$SUPPORTS_DIR/module_${module_num_fmt}_"* 2>/dev/null | head -1 || echo "")
    
    if [ -z "$module_dir" ] || [ ! -d "$module_dir" ]; then
        echo "  ❌ DEBUG: Module $module_num non trouvé: '$module_dir'"
        echo "  🔍 DEBUG: Contenu supports:"
        ls -la "$SUPPORTS_DIR/" | head -5
        continue
    fi
    
    echo "  ✅ DEBUG: Module trouvé: $module_dir"
    
    module_name=$(basename "$module_dir" | sed 's/module_[0-9]*_//' | tr '_' ' ')
    module_title=$(echo "$module_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
    output_file="$BUILD_DIR/modules_base/module_${module_num_fmt}_$(echo $module_name | tr ' ' '_').pdf"
    temp_md="$BUILD_DIR/debug_temp_module_${module_num_fmt}.md"
    
    echo "  📄 DEBUG: Module $module_num: $module_title"
    echo "  📝 DEBUG: Fichier temp: $temp_md"
    echo "  📄 DEBUG: Fichier sortie: $output_file"
    
    # Création fichier markdown minimal
    echo "  📝 DEBUG: Création markdown..."
    cat > "$temp_md" << EOF
---
title: "DEBUG Module $module_num : $module_title"  
author: "Pascal Guinet - Prima Solutions"
date: \\today
---

# Module $module_num : $module_title

Test de génération pour debug GitHub Actions.

## Contenu minimal

Ce module contient du contenu minimal pour tester la génération.

EOF

    # Ajouter SEULEMENT le premier chapitre pour éviter problèmes
    first_chapter=$(ls "$module_dir"/*.md 2>/dev/null | head -1 || echo "")
    if [ -f "$first_chapter" ]; then
        echo "  📖 DEBUG: Ajout premier chapitre: $(basename "$first_chapter")"
        chapter_name=$(basename "$first_chapter" .md | sed 's/^[0-9]*_//' | tr '_' ' ')
        echo "" >> "$temp_md"
        echo "# $chapter_name" >> "$temp_md"
        echo "" >> "$temp_md"
        
        # Prendre seulement les 50 premières lignes pour réduire les risques
        head -50 "$first_chapter" >> "$temp_md" || echo "Erreur lecture chapitre" >> "$temp_md"
        echo "" >> "$temp_md"
    else
        echo "  ⚠️ DEBUG: Aucun chapitre trouvé dans $module_dir"
    fi
    
    echo "  📏 DEBUG: Taille markdown: $(wc -l < "$temp_md" 2>/dev/null || echo '?') lignes"
    
    # Nettoyage Unicode
    echo "  🧹 DEBUG: Nettoyage Unicode..."
    if [ -f "$SCRIPT_DIR/clean_unicode.sh" ]; then
        "$SCRIPT_DIR/clean_unicode.sh" "$temp_md" > /dev/null 2>&1 || echo "    ⚠️ Erreur nettoyage Unicode"
        echo "    ✅ Nettoyage appliqué"
    else
        echo "    ⚠️ Script clean_unicode.sh non trouvé"
    fi
    
    # Génération PDF avec debug maximum
    echo "  🔨 DEBUG: Génération PDF..."
    echo "    - Répertoire courant: $(pwd)"
    echo "    - Commande: cd $(dirname "$output_file") && pandoc..."
    
    cd "$(dirname "$output_file")" || {
        echo "  ❌ DEBUG: Impossible de changer vers $(dirname "$output_file")"
        cd "$BUILD_DIR"
        echo "    → Utilisation de $BUILD_DIR à la place"
    }
    
    echo "    - Nouveau PWD: $(pwd)"
    
    # Utiliser la commande pandoc la plus simple possible
    if timeout 60 pandoc "$temp_md" \
        --pdf-engine=pdflatex \
        --variable geometry:margin=2.5cm \
        --variable fontsize=11pt \
        --variable documentclass:article \
        --variable lang=fr \
        -o "$(basename "$output_file")" 2>&1; then
        
        echo "  ✅ DEBUG: Module $module_num généré avec succès"
        echo "    - Fichier: $(ls -lh "$(basename "$output_file")" 2>/dev/null || echo 'FICHIER INTROUVABLE')"
        
        # Incrémenter le compteur de succès avec debug
        echo "  🔢 DEBUG: Incrémentation success_count ($success_count -> $((success_count + 1)))"
        success_count=$((success_count + 1))
        echo "    ✅ success_count APRÈS: $success_count"
        
        # Nettoyer le fichier temporaire
        rm -f "$temp_md"
        echo "    🧹 Fichier temporaire supprimé"
        
    else
        echo "  ❌ DEBUG: Erreur génération module $module_num"
        echo "    🔍 Conservation fichier temporaire: $temp_md"
        echo "    🔍 Contenu (premières lignes):"
        head -10 "$temp_md" 2>/dev/null || echo "    Impossible de lire le fichier"
    fi
    
    # Retour au répertoire projet
    cd "$PROJECT_DIR"
    echo "  🔄 DEBUG: Retour répertoire: $(pwd)"
    
    echo "🔄 DEBUG: === FIN MODULE $module_num ==="
    echo "  - success_count FINAL: $success_count"
    echo "  - Date fin: $(date)"
    
    # Pause pour debug
    sleep 1
done

echo ""
echo "📊 DEBUG: Résumé final"
echo "  - Modules traités: 3"  
echo "  - Modules réussis: $success_count"
echo "  - Fichiers PDF générés:"
find "$BUILD_DIR" -name "*.pdf" 2>/dev/null | wc -l || echo "0"

if [ $success_count -gt 0 ]; then
    echo "✅ DEBUG: Au moins un module généré avec succès"
    exit 0
else
    echo "❌ DEBUG: Aucun module généré"
    exit 1
fi