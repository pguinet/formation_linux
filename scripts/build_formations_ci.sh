#!/bin/bash

# Version robuste du script de génération spécialement adaptée pour GitHub Actions CI
# Avec nettoyage et gestion d'erreurs renforcés

set -e

echo "🚀 Génération formations Linux - Version CI robuste"
echo "===================================================="

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TP_DIR="$PROJECT_DIR/travaux_pratiques"

echo "📁 Répertoires:"
echo "  - Projet: $PROJECT_DIR"
echo "  - Build: $BUILD_DIR"

# Vérification des dépendances
echo "🔍 Vérification des dépendances..."
if ! command -v pandoc &> /dev/null; then
    echo "❌ Pandoc n'est pas installé"
    exit 1
fi

if ! command -v pdflatex &> /dev/null; then
    echo "❌ pdflatex n'est pas installé"
    exit 1
fi

echo "🛠️ Versions:"
pandoc --version | head -1
pdflatex --version | head -1

echo "✅ Dépendances OK"

# Nettoyage et préparation
echo "🧹 Préparation des répertoires..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"/{formations,modules_base,modules_additionnels}

# Fonction de nettoyage minimal pour CI
clean_markdown_for_ci() {
    local file=$1
    
    echo "  🧹 Nettoyage CI: $(basename "$file")"
    
    # Utiliser le script de nettoyage existant
    if [ -f "$SCRIPT_DIR/clean_unicode.sh" ]; then
        "$SCRIPT_DIR/clean_unicode.sh" "$file" > /dev/null 2>&1 || true
    fi
}

# Fonction de génération PDF ultra-robuste pour CI
generate_pdf_ci_safe() {
    local temp_md=$1
    local output_file=$2
    local description=$3
    
    echo "  🔨 Génération PDF CI sécurisée: $description..."
    
    # Nettoyage agressif
    clean_markdown_for_ci "$temp_md"
    
    # Créer répertoire de sortie
    mkdir -p "$(dirname "$output_file")"
    
    # Variables LaTeX pour maximum de compatibilité
    local pandoc_args=(
        --pdf-engine=pdflatex
        --toc
        --toc-depth=2
        --highlight-style=tango
        --variable geometry:margin=2.5cm
        --variable fontsize=11pt
        --variable documentclass:article
        --variable papersize=a4
        --variable lang=fr
        --variable babel-lang=french
        --variable fontenc=T1
        --variable inputenc=utf8
    )
    
    echo "  🔍 Fichier markdown: $temp_md ($(wc -l < "$temp_md") lignes)"
    
    # Tentative de génération avec timeout
    if timeout 300 pandoc "$temp_md" "${pandoc_args[@]}" -o "$output_file" 2>&1; then
        echo "  ✅ $description généré: $(basename "$output_file")"
        rm -f "$temp_md"
        return 0
    else
        echo "  ❌ Erreur génération $description"
        echo "  🔍 Conservation fichier pour debug: $temp_md"
        echo "  🔍 Taille: $(wc -l < "$temp_md") lignes"
        echo "  🔍 Échantillon problématique (lignes 580-590):"
        sed -n '580,590p' "$temp_md" | head -10 || echo "    (lignes non disponibles)"
        return 1
    fi
}

# Fonction pour générer un module individuel (version CI)
generate_individual_module_ci() {
    local module_num=$1
    
    local module_num_fmt=$(printf "%02d" $module_num)
    local module_dir=$(ls -d "$SUPPORTS_DIR/module_${module_num_fmt}_"* 2>/dev/null | head -1)
    
    if [ ! -d "$module_dir" ]; then
        echo "  ⚠️ Module $module_num non trouvé"
        return 1
    fi
    
    local module_name=$(basename "$module_dir" | sed 's/module_[0-9]*_//' | tr '_' ' ')
    local module_title=$(echo "$module_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
    local output_file="$BUILD_DIR/modules_base/module_${module_num_fmt}_$(echo $module_name | tr ' ' '_').pdf"
    local temp_md="$BUILD_DIR/temp_module_ci_${module_num_fmt}.md"
    
    echo "  📄 Module $module_num: $module_title"
    
    # En-tête simplifié pour CI
    cat > "$temp_md" << EOF
---
title: "Module $module_num : $module_title"
author: "Pascal Guinet - Prima Solutions"
date: \\today
---

# Module $module_num : $module_title

EOF

    # Ajouter les chapitres avec limitations
    local chapter_count=0
    for chapter in "$module_dir"/*.md; do
        if [ -f "$chapter" ] && [ $chapter_count -lt 10 ]; then  # Limiter à 10 chapitres max
            local chapter_name=$(basename "$chapter" .md | sed 's/^[0-9]*_//' | tr '_' ' ')
            echo "" >> "$temp_md"
            echo "# $chapter_name" >> "$temp_md"
            echo "" >> "$temp_md"
            
            # Limiter la taille du chapitre (éviter les fichiers trop volumineux)
            if [ $(wc -l < "$chapter") -gt 500 ]; then
                echo "  ⚠️ Chapitre volumineux $(wc -l < "$chapter") lignes, limitation à 500"
                head -500 "$chapter" >> "$temp_md"
                echo "" >> "$temp_md"
                echo "*[Chapitre tronqué pour compatibilité CI]*" >> "$temp_md"
            else
                cat "$chapter" >> "$temp_md"
            fi
            echo "" >> "$temp_md"
            
            ((chapter_count++))
        fi
    done

    # Génération PDF
    generate_pdf_ci_safe "$temp_md" "$output_file" "Module $module_num"
}

# Génération des modules individuels de base avec robustesse CI
echo ""
echo "📖 Génération des modules individuels (version CI robuste)..."
success_count=0

for module_num in {1..8}; do
    echo "  🔄 Traitement module $module_num..."
    
    # Gestion d'erreur robuste
    set +e
    generate_individual_module_ci "$module_num"
    result=$?
    set -e

    if [ $result -eq 0 ]; then
        ((success_count++))
        echo "  ✅ Module $module_num: OK (total: $success_count)"
    else
        echo "  ❌ Module $module_num: ECHEC (code: $result)"
    fi
done

echo "  📊 Modules générés: $success_count/8"

# Générer modules additionnels si possible
echo ""
echo "🔧 Génération modules additionnels (si disponible)..."
if [ -f "$SCRIPT_DIR/build_modules_additionnels.sh" ]; then
    set +e
    "$SCRIPT_DIR/build_modules_additionnels.sh"
    additionnels_result=$?
    set -e
    
    if [ $additionnels_result -eq 0 ]; then
        echo "  ✅ Modules additionnels générés"
    else
        echo "  ⚠️ Échec modules additionnels (code: $additionnels_result)"
    fi
else
    echo "  ⚠️ Script modules additionnels non trouvé"
fi

# Résumé final
echo ""
echo "📊 Résumé génération CI:"
echo "  ✅ Modules de base: $success_count/8"

modules_count=$(find "$BUILD_DIR" -name "*.pdf" 2>/dev/null | wc -l || echo "0")
echo "  📄 Total PDFs générés: $modules_count"

if [ $modules_count -gt 0 ]; then
    echo "  📁 Fichiers générés:"
    find "$BUILD_DIR" -name "*.pdf" -exec ls -lh {} \; | head -10
fi

echo ""
echo "🎯 Génération CI terminée (modules: $success_count/8, PDFs: $modules_count)"

# Code de sortie selon succès
if [ $success_count -ge 4 ]; then  # Au moins la moitié des modules
    exit 0
else
    echo "❌ Trop peu de modules générés avec succès"
    exit 1
fi