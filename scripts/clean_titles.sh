#!/bin/bash

# Script pour nettoyer les titres des fichiers markdown
# Supprime les préfixes "Module X.Y :", "Chapitre X.Y :" et les numéros

echo "🧹 Nettoyage des titres des chapitres..."

# Trouver tous les fichiers .md dans les modules
find supports/ -name "*.md" -type f | while read -r file; do
    # Lire la première ligne
    first_line=$(head -1 "$file")
    
    # Vérifier si c'est un titre avec préfixe à nettoyer
    if [[ "$first_line" =~ ^#[[:space:]]+(Module|Chapitre)[[:space:]]+[0-9]+\.[0-9]+[[:space:]]*:[[:space:]]* ]]; then
        # Extraire le titre sans le préfixe
        clean_title=$(echo "$first_line" | sed -E 's/^#[[:space:]]+(Module|Chapitre)[[:space:]]+[0-9]+\.[0-9]+[[:space:]]*:[[:space:]]*/# /')
        
        echo "  📝 $file"
        echo "    Avant: $first_line"
        echo "    Après: $clean_title"
        
        # Créer un fichier temporaire avec le nouveau titre
        {
            echo "$clean_title"
            tail -n +2 "$file"
        } > "$file.tmp" && mv "$file.tmp" "$file"
        
    # Vérifier si c'est un titre avec préfixe "Chapitre" sans numéro de module
    elif [[ "$first_line" =~ ^#[[:space:]]+(Chapitre)[[:space:]]+[0-9]+\.[0-9]+[[:space:]]*:[[:space:]]* ]]; then
        # Extraire le titre sans le préfixe
        clean_title=$(echo "$first_line" | sed -E 's/^#[[:space:]]+(Chapitre)[[:space:]]+[0-9]+\.[0-9]+[[:space:]]*:[[:space:]]*/# /')
        
        echo "  📝 $file"
        echo "    Avant: $first_line"
        echo "    Après: $clean_title"
        
        # Créer un fichier temporaire avec le nouveau titre
        {
            echo "$clean_title"
            tail -n +2 "$file"
        } > "$file.tmp" && mv "$file.tmp" "$file"
    fi
done

echo "✅ Nettoyage terminé!"