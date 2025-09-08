#!/bin/bash

# Nettoyage complet des caractères Unicode pour LaTeX
# Préserve les caractères français essentiels

if [ $# -eq 0 ]; then
    echo "Usage: $0 fichier.md"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Erreur: fichier $FILE non trouvé"
    exit 1
fi

echo "Nettoyage Unicode complet de $FILE..."

# Caractères de dessin de boîtes
perl -i -pe 's/[┌┐└┘├┤┬┴┼]/+/g' "$FILE"
perl -i -pe 's/[│]/|/g' "$FILE"
perl -i -pe 's/[─]/−/g' "$FILE"
perl -i -pe 's/[╱]/\//g' "$FILE"
perl -i -pe 's/[╲]/\\/g' "$FILE"

# Flèches
perl -i -pe 's/[→]/−>/g' "$FILE"
perl -i -pe 's/[←]/<−/g' "$FILE"
perl -i -pe 's/[↑]/^/g' "$FILE"
perl -i -pe 's/[↓]/v/g' "$FILE"
perl -i -pe 's/[↔]/<−>/g' "$FILE"
perl -i -pe 's/[▶]/>/g' "$FILE"
perl -i -pe 's/[◀]/</g' "$FILE"

# Symboles mathématiques
perl -i -pe 's/[≠]/!=/g' "$FILE"
perl -i -pe 's/[≤]/<=/g' "$FILE"
perl -i -pe 's/[≥]/>=/g' "$FILE"
perl -i -pe 's/[×]/x/g' "$FILE"
perl -i -pe 's/[÷]/\//g' "$FILE"

# Puces et symboles
perl -i -pe 's/[●•]/*/g' "$FILE"
perl -i -pe 's/[◦]/o/g' "$FILE"
perl -i -pe 's/[▪▫]/*/g' "$FILE"

# Emojis (approche large)
perl -i -pe 's/[\x{1F300}-\x{1F9FF}]/[EMOJI]/g' "$FILE"
perl -i -pe 's/[✅]/[OK]/g' "$FILE"
perl -i -pe 's/[❌]/[NOK]/g' "$FILE"
perl -i -pe 's/[⚠️]/[WARN]/g' "$FILE"
perl -i -pe 's/[✓]/[OK]/g' "$FILE"
perl -i -pe 's/[✗]/[NOK]/g' "$FILE"

# Autres caractères problématiques
perl -i -pe 's/[…]/.../g' "$FILE"
perl -i -pe 's/['']/'"'"'/g' "$FILE"
perl -i -pe 's/[""]/"/g' "$FILE"
perl -i -pe 's/[–—]/−/g' "$FILE"

# Nettoyer tout caractère non-ASCII sauf les accents français essentiels
# Préserver: àáâäèéêëìíîïòóôöùúûüÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÇçÑñ
perl -i -pe 's/[^\x00-\x7F\xC0-\xFF]//g' "$FILE"

echo "Nettoyage Unicode complet terminé."