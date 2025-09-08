#!/bin/bash

# Script de nettoyage complet des caractères Unicode problématiques
# Usage: ./clean_unicode.sh fichier.md

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Erreur: fichier $FILE non trouvé"
    exit 1
fi

echo "Nettoyage Unicode de $FILE..."

# Caractères d'arborescence (tous les variants)
sed -i 's/├/+/g' "$FILE"
sed -i 's/└/+/g' "$FILE" 
sed -i 's/┌/+/g' "$FILE"
sed -i 's/┐/+/g' "$FILE"
sed -i 's/┘/+/g' "$FILE"
sed -i 's/│/|/g' "$FILE"
sed -i 's/─/-/g' "$FILE"
sed -i 's/┬/+/g' "$FILE"
sed -i 's/┴/+/g' "$FILE"
sed -i 's/┤/+/g' "$FILE"
sed -i 's/┼/+/g' "$FILE"
sed -i 's/┊/|/g' "$FILE"
sed -i 's/┋/|/g' "$FILE"
sed -i 's/╱/\//g' "$FILE"
sed -i 's/╲/\\/g' "$FILE"

# Symboles mathématiques et flèches
sed -i 's/≠/!=/g' "$FILE"
sed -i 's/≤/<=/g' "$FILE"
sed -i 's/≥/>=/g' "$FILE"
sed -i 's/↔/<-->/g' "$FILE"
sed -i 's/→/->/g' "$FILE"
sed -i 's/←/<-/g' "$FILE"
sed -i 's/↑/^/g' "$FILE"
sed -i 's/↓/v/g' "$FILE"
sed -i 's/▶/>/g' "$FILE"
sed -i 's/◀/</g' "$FILE"
sed -i 's/√/sqrt/g' "$FILE"
sed -i 's/×/x/g' "$FILE"
sed -i 's/÷/div/g' "$FILE"

# Emojis et symboles
sed -i 's/✅/[OK]/g' "$FILE"
sed -i 's/❌/[NOK]/g' "$FILE"
sed -i 's/⚠️/[WARN]/g' "$FILE"
sed -i 's/📁/[DIR]/g' "$FILE"
sed -i 's/🔧/[TOOL]/g' "$FILE"
sed -i 's/🔍/[SEARCH]/g' "$FILE"
sed -i 's/✓/[OK]/g' "$FILE"
sed -i 's/✗/[NOK]/g' "$FILE"
sed -i 's/🎯/[TARGET]/g' "$FILE"
sed -i 's/🚀/[START]/g' "$FILE"
sed -i 's/📄/[DOC]/g' "$FILE"
sed -i 's/📚/[BOOKS]/g' "$FILE"
sed -i 's/⚡/[FAST]/g' "$FILE"
sed -i 's/🧹/[CLEAN]/g' "$FILE"
sed -i 's/🔄/[LOADING]/g' "$FILE"
sed -i 's/🔥/[FIRE]/g' "$FILE"
sed -i 's/💡/[IDEA]/g' "$FILE"
sed -i 's/⭐/[STAR]/g' "$FILE"
sed -i 's/🎉/[PARTY]/g' "$FILE"
sed -i 's/🔊/[SOUND]/g' "$FILE"

# Nettoyer tous les emojis restants avec perl
if command -v perl &> /dev/null; then
    perl -CSD -pi -e 's/[\x{1F300}-\x{1F5FF}]//g' "$FILE"  # Symboles divers
    perl -CSD -pi -e 's/[\x{1F600}-\x{1F64F}]//g' "$FILE"  # Emoticons
    perl -CSD -pi -e 's/[\x{1F680}-\x{1F6FF}]//g' "$FILE"  # Transport
    perl -CSD -pi -e 's/[\x{1F700}-\x{1F77F}]//g' "$FILE"  # Alchimiques
    perl -CSD -pi -e 's/[\x{1F900}-\x{1F9FF}]//g' "$FILE"  # Supplémentaires
fi

# Guillemets et ponctuation
sed -i 's/«/"/g' "$FILE"
sed -i 's/»/"/g' "$FILE"
sed -i "s/'/'/g" "$FILE"
sed -i "s/'/'/g" "$FILE"
sed -i 's/"/"/g' "$FILE"
sed -i 's/"/"/g' "$FILE"
sed -i 's/…/.../g' "$FILE"
sed -i 's/–/-/g' "$FILE"
sed -i 's/—/-/g' "$FILE"

# Espaces insécables et autres
sed -i 's/ / /g' "$FILE"
sed -i 's/·/*/g' "$FILE"
sed -i 's/•/*/g' "$FILE"
sed -i 's/●/*/g' "$FILE"

# Indices et exposants
sed -i 's/₀/0/g' "$FILE"
sed -i 's/₁/1/g' "$FILE"
sed -i 's/₂/2/g' "$FILE"
sed -i 's/₃/3/g' "$FILE"
sed -i 's/₄/4/g' "$FILE"
sed -i 's/₅/5/g' "$FILE"
sed -i 's/₆/6/g' "$FILE"
sed -i 's/₇/7/g' "$FILE"
sed -i 's/₈/8/g' "$FILE"
sed -i 's/₉/9/g' "$FILE"

# Ajout de quelques autres caractères problématiques
sed -i 's/ℹ/[INFO]/g' "$FILE"
sed -i 's/©/(c)/g' "$FILE"
sed -i 's/®/(R)/g' "$FILE"
sed -i 's/™/(TM)/g' "$FILE"

# NE PAS utiliser iconv pour préserver les caractères accentués français
# Le script se contente du nettoyage sélectif des caractères problématiques ci-dessus
echo "Caractères accentués français préservés"

echo "Nettoyage terminé."