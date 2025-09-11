#!/bin/bash

# Script principal de génération des formations selon les nouvelles consignes
# Génère : formation_acceleree.pdf, formation_longue.pdf, modules individuels

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SUPPORTS_DIR="$PROJECT_DIR/supports"
TP_DIR="$PROJECT_DIR/travaux_pratiques"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

echo "🚀 Génération des formations Linux selon les nouvelles spécifications"
echo "📁 Répertoire projet: $PROJECT_DIR"

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

echo "✅ Dépendances OK"

# Nettoyage et préparation
echo "🧹 Préparation des répertoires..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"/{formations,modules_base,modules_additionnels}

# Fonction pour générer la formation accélérée
generate_formation_acceleree() {
    echo "⚡ Génération formation accélérée..."
    
    local output_file="$BUILD_DIR/formations/formation_acceleree.pdf"
    local temp_md="$BUILD_DIR/temp_formation_acceleree.md"
    
    # En-tête avec métadonnées
    cat > "$temp_md" << 'EOF'
---
title: "Formation Linux Accélérée"
author: "Pascal Guinet - Prima Solutions"
date: \today
module-content: |
  **Durée :** 2 séances de 4 heures (8h total)
  
  **Public :** Utilisateurs avec VM Linux et accès SSH
  
  **Objectifs :**
  - Maîtriser les commandes Linux essentielles
  - Naviguer efficacement dans le système de fichiers
  - Gérer les droits et permissions
  - Automatiser les tâches courantes
  
  **Approche :** Formation intensive axée sur la pratique
reset-chapter-numbering: true
---

# Présentation de la formation

Cette formation accélérée couvre l'essentiel de Linux en 8 heures intensives.

## Jour 1 (4h) : Fondamentaux
- Modules 1, 2, 3 : Découverte, navigation, manipulation de fichiers

## Jour 2 (4h) : Utilisation avancée  
- Modules 4, 5, 6, 7, 8 : Consultation, droits, processus, réseaux, scripts

\newpage

EOF

    # Ajouter les modules sélectionnés pour la formation accélérée
    local modules_acceleres=(1 2 3 4 5 6 7 8)
    
    for module_num in "${modules_acceleres[@]}"; do
        add_module_to_document "$module_num" "$temp_md" "condensed"
    done
    
    generate_pdf_from_markdown "$temp_md" "$output_file" "Formation accélérée"
}

# Fonction pour générer la formation longue
generate_formation_longue() {
    echo "📚 Génération formation longue..."
    
    local output_file="$BUILD_DIR/formations/formation_longue.pdf"
    local temp_md="$BUILD_DIR/temp_formation_longue.md"
    
    # En-tête avec métadonnées
    cat > "$temp_md" << 'EOF'
---
title: "Formation Linux Complète"
author: "Pascal Guinet - Prima Solutions" 
date: \today
module-content: |
  **Durée :** 25 séances de 1h30 (37h30 total)
  
  **Public :** Utilisateurs Windows avec VirtualBox
  
  **Objectifs :**
  - Apprentissage progressif et détaillé de Linux
  - Installation et configuration d'un environnement
  - Maîtrise complète des outils et commandes
  - Autonomie dans l'administration système
  
  **Approche :** Formation étalée avec nombreux travaux pratiques
reset-chapter-numbering: true
---

# Présentation de la formation

Formation complète Linux sur 25 séances, adaptée aux débutants.

## Organisation
- **Séances 1-3 :** Installation et découverte (Module 1)
- **Séances 4-7 :** Navigation système (Module 2)
- **Séances 8-12 :** Manipulation fichiers (Module 3)
- **Séances 13-16 :** Édition et recherche (Module 4)
- **Séances 17-20 :** Droits et sécurité (Module 5)
- **Séances 21-23 :** Processus et système (Module 6)
- **Séances 24-25 :** Réseau et automatisation (Modules 7-8)

\newpage

EOF

    # Ajouter tous les modules avec contenu détaillé
    for module_num in {1..8}; do
        add_module_to_document "$module_num" "$temp_md" "detailed"
    done
    
    generate_pdf_from_markdown "$temp_md" "$output_file" "Formation longue"
}

# Fonction pour ajouter un module au document
add_module_to_document() {
    local module_num=$1
    local temp_md=$2
    local level=${3:-"normal"}  # condensed, normal, detailed
    
    local module_num_fmt=$(printf "%02d" $module_num)
    local module_dir=$(ls -d "$SUPPORTS_DIR/module_${module_num_fmt}_"* 2>/dev/null | head -1)
    
    if [ ! -d "$module_dir" ]; then
        echo "  ⚠️ Module $module_num non trouvé"
        return
    fi
    
    local module_name=$(basename "$module_dir" | sed 's/module_[0-9]*_//' | tr '_' ' ')
    local module_title=$(echo "$module_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
    
    echo "  📄 Ajout Module $module_num: $module_title"
    
    # Titre de partie (nouvelle page + titre non numéroté) - version simplifiée
    echo "" >> "$temp_md"
    echo "\\newpage" >> "$temp_md"
    echo "" >> "$temp_md"
    echo "# Module $module_num : $module_title {.unnumbered}" >> "$temp_md"
    echo "" >> "$temp_md"
    
    # Ajouter les chapitres
    for chapter in "$module_dir"/*.md; do
        if [ -f "$chapter" ]; then
            local chapter_name=$(basename "$chapter" .md | sed 's/^[0-9]*_//' | tr '_' ' ')
            echo "" >> "$temp_md"
            echo "# $chapter_name" >> "$temp_md"
            echo "" >> "$temp_md"
            
            # Contenu du chapitre selon le niveau
            if [ "$level" = "condensed" ]; then
                # Version condensée : prendre seulement les sections principales
                sed -n '1,/^## /p' "$chapter" | head -n -1 >> "$temp_md"
            else
                # Version complète
                cat "$chapter" >> "$temp_md"
            fi
            
            # IMPORTANT: S'assurer qu'il y a une ligne vide à la fin pour éviter 
            # la concaténation accidentelle avec le titre suivant
            echo "" >> "$temp_md"
            echo "" >> "$temp_md"
            echo "" >> "$temp_md"
        fi
    done
    
    # Ajouter les travaux pratiques si pas condensé
    if [ "$level" != "condensed" ]; then
        local tp_dir=$(ls -d "$TP_DIR/tp${module_num_fmt}_"* 2>/dev/null | head -1)
        if [ -d "$tp_dir" ]; then
            echo "" >> "$temp_md"
            echo "# Travaux Pratiques" >> "$temp_md"
            echo "" >> "$temp_md"
            
            for tp_file in "$tp_dir"/*.md; do
                if [ -f "$tp_file" ]; then
                    local tp_name=$(basename "$tp_file" .md | tr '_' ' ')
                    echo "## $tp_name" >> "$temp_md"
                    echo "" >> "$temp_md"
                    cat "$tp_file" >> "$temp_md"
                    echo "" >> "$temp_md"
                fi
            done
        fi
    fi
}


# Fonction pour générer un module individuel
generate_individual_module() {
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
    local temp_md="$BUILD_DIR/temp_module_${module_num_fmt}.md"
    
    echo "  📄 Module $module_num: $module_title"
    
    # En-tête du module
    cat > "$temp_md" << EOF
---
title: "Module $module_num : $module_title"
author: "Pascal Guinet - Prima Solutions"
date: \today
module-content: |
  **Durée estimée :** 3-4 heures
  
  **Objectifs :** Maîtriser les concepts et outils du module $module_num
  
  **Prérequis :** Modules précédents complétés
  
  **Contenu :** Voir sommaire détaillé ci-après
reset-chapter-numbering: true
---

EOF

    # Ajouter le contenu du module (sans numéro de partie)
    for chapter in "$module_dir"/*.md; do
        if [ -f "$chapter" ]; then
            local chapter_name=$(basename "$chapter" .md | sed 's/^[0-9]*_//' | tr '_' ' ')
            echo "" >> "$temp_md"
            echo "# $chapter_name" >> "$temp_md"
            echo "" >> "$temp_md"
            cat "$chapter" >> "$temp_md"
            # S'assurer qu'il y a bien un retour à la ligne à la fin
            echo "" >> "$temp_md"
            echo "" >> "$temp_md"
        fi
    done
    
    # Ajouter les travaux pratiques
    local tp_dir=$(ls -d "$TP_DIR/tp${module_num_fmt}_"* 2>/dev/null | head -1)
    if [ -d "$tp_dir" ]; then
        echo "" >> "$temp_md"
        echo "\\newpage" >> "$temp_md"
        echo "" >> "$temp_md"
        echo "# Travaux Pratiques" >> "$temp_md"
        echo "" >> "$temp_md"
        
        for tp_file in "$tp_dir"/*.md; do
            if [ -f "$tp_file" ]; then
                local tp_name=$(basename "$tp_file" .md | tr '_' ' ')
                echo "## $tp_name" >> "$temp_md"
                echo "" >> "$temp_md"
                cat "$tp_file" >> "$temp_md"
                echo "" >> "$temp_md"
            fi
        done
    fi
    
    generate_pdf_from_markdown "$temp_md" "$output_file" "Module $module_num"
}

# Fonction de génération PDF commune - template unique
generate_pdf_from_markdown() {
    local temp_md=$1
    local output_file=$2
    local description=$3
    
    # Vérifier que le fichier markdown existe
    if [ ! -f "$temp_md" ]; then
        echo "  ❌ Fichier markdown introuvable: $temp_md"
        return 1
    fi
    
    # Créer le répertoire de sortie s'il n'existe pas
    mkdir -p "$(dirname "$output_file")"
    
    # Nettoyage des caractères problématiques pour LaTeX
    echo "  🧹 Nettoyage des caractères problématiques..."
    
    # S'assurer que le fichier se termine par un retour à la ligne
    if [ -s "$temp_md" ] && [ "$(tail -c1 "$temp_md" | wc -l)" -eq 0 ]; then
        echo "" >> "$temp_md"
    fi
    
    # Nettoyage minimal - laisser Pandoc gérer l'échappement LaTeX

    # Caractères Unicode problématiques
    sed -i 's/→/->/g' "$temp_md"  # Flèche droite
    sed -i 's/←/<--/g' "$temp_md"  # Flèche gauche
    sed -i 's/▶/>/g' "$temp_md"   # Triangle droit
    sed -i 's/◀/</g' "$temp_md"   # Triangle gauche
    sed -i 's/≠/!=/g' "$temp_md"  # Différent de
    sed -i 's/≤/<=/g' "$temp_md"  # Inférieur ou égal
    sed -i 's/≥/>=/g' "$temp_md"  # Supérieur ou égal

    # Plus de nettoyage d'échappement agressif - laisser Pandoc gérer
    
    # Nettoyage Unicode standard
    "$SCRIPT_DIR/clean_unicode.sh" "$temp_md" > /dev/null 2>&1 || true
    
    # Génération avec le template unique
    local current_dir=$(pwd)
    cd "$(dirname "$output_file")"

    echo "  🔨 Génération PDF: $description..."

    # Génération simplifiée (plus fiable que le template custom)
    echo "  🔍 Debug: fichier markdown temporaire: $temp_md"

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
        --variable babel-lang=french \
        -o "$(basename "$output_file")" 2>&1; then

        echo "  ✅ $description généré: $(basename "$output_file")"
        cd "$current_dir"
        rm -f "$temp_md"
        return 0
    else
        echo "  ❌ Erreur génération $description"
        echo "  🔍 Fichier markdown conservé pour debug: $temp_md"
        cd "$current_dir"
        return 1
    fi
}

# Exécution principale
echo ""
echo "📚 Génération des formations complètes..."
mkdir -p "$BUILD_DIR/formations"

# Générer formation accélérée
generate_formation_acceleree

# Générer formation longue  
generate_formation_longue

echo ""
echo "📖 Génération des modules individuels de base..."
success_count=0
echo "  🔍 Début de la boucle pour les modules 1 à 8"
for module_num in {1..8}; do
    echo "  🔄 Début traitement module $module_num"
    # Ne pas arrêter le script si un module échoue
    set +e  # Désactiver arrêt sur erreur temporairement
    generate_individual_module "$module_num"
    result=$?
    set -e  # Réactiver arrêt sur erreur

    if [ $result -eq 0 ]; then
        ((success_count++))
        echo "  ✅ Module $module_num traité avec succès (total: $success_count)"
    else
        echo "  ❌ Échec traitement module $module_num (code: $result)"
    fi
    echo "  🔄 Fin traitement module $module_num"
done
echo "  📊 Modules traités avec succès: $success_count/8"

echo ""
echo "🔧 Génération des modules additionnels..."
set +e  # Désactiver arrêt sur erreur temporairement
"$SCRIPT_DIR/build_modules_additionnels.sh"
additionnels_result=$?
set -e  # Réactiver arrêt sur erreur

if [ $additionnels_result -eq 0 ]; then
    echo "  ✅ Modules additionnels générés avec succès"
else
    echo "  ⚠️ Échec génération modules additionnels (code: $additionnels_result)"
fi

# Résumé
echo ""
echo "📊 Résumé de génération:"
if [ -f "$BUILD_DIR/formations/formation_acceleree.pdf" ]; then
    echo "  ✅ Formation accélérée"
else
    echo "  ❌ Formation accélérée"
fi

if [ -f "$BUILD_DIR/formations/formation_longue.pdf" ]; then
    echo "  ✅ Formation longue"
else
    echo "  ❌ Formation longue"  
fi

echo "  ✅ Modules de base: $success_count/8"

echo ""
echo "📁 Fichiers générés dans: $BUILD_DIR"
echo "🎉 Génération terminée!"