#!/usr/bin/env bash
# Captures reproductibles de l'installeur graphique de Debian 13.7 (DVD-1).
#
# - télécharge l'ISO dans build/captures/cache/ (reprise possible) et
#   vérifie son SHA256 ;
# - construit l'image Docker voisine (QEMU, python3, tesseract) ;
# - lance l'installation complète sous QEMU/KVM, pilotée par piloter.py ;
# - écrit ressources/images/installation/debian-*.png et debian-captures.txt.
#
# Usage : outils/captures/debian/capturer.sh
# Prérequis : Docker, /dev/kvm accessible, ~40 Go libres, accès Internet.
# Durée : de l'ordre de 30 à 60 minutes selon la machine et le réseau.
set -euo pipefail

ICI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RACINE="$(cd "$ICI/../../.." && pwd)"
CACHE="$RACINE/build/captures/cache"
TRAVAIL="$RACINE/build/captures/debian"
SORTIE="$RACINE/ressources/images/installation"
IMAGE="formation-linux-captures-debian"

ISO="debian-13.7.0-amd64-DVD-1.iso"
URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/$ISO"
# Ancienne version : https://cdimage.debian.org/cdimage/archive/13.7.0/amd64/iso-dvd/
SHA256="347b6c67a3cc0b7ddb60b178f683470c4e2b7ac426c996d9337a2ff36c1a32d2"

erreur() { echo "ERREUR : $*" >&2; exit 1; }

[ -r /dev/kvm ] && [ -w /dev/kvm ] || erreur "/dev/kvm inaccessible (KVM activé ? groupe kvm ?)"
command -v docker >/dev/null || erreur "docker introuvable"

mkdir -p "$CACHE" "$TRAVAIL" "$SORTIE"

verifier_iso() { echo "$SHA256  $CACHE/$ISO" | sha256sum --check --status; }

if [ -f "$CACHE/$ISO" ] && verifier_iso; then
    echo "ISO présente et valide : $CACHE/$ISO"
else
    echo "Téléchargement de $ISO (environ 4 Go)..."
    curl -fL -C - -o "$CACHE/$ISO" "$URL" \
        || curl -fL -C - -o "$CACHE/$ISO" "https://cdimage.debian.org/cdimage/archive/13.7.0/amd64/iso-dvd/$ISO"
    verifier_iso || erreur "SHA256 incorrect pour $CACHE/$ISO (fichier à supprimer puis relancer)"
    echo "SHA256 vérifié."
fi

docker build -q -t "$IMAGE" "$ICI" >/dev/null

NOM="captures-debian-$$"
trap 'docker rm -f "$NOM" >/dev/null 2>&1 || true' EXIT
debut=$(date +%s)
docker run --rm --name "$NOM" \
    --device /dev/kvm \
    --user "$(id -u):$(id -g)" --group-add "$(stat -c %g /dev/kvm)" \
    -v "$TRAVAIL:/work" \
    -v "$CACHE:/work/cache:ro" \
    -v "$SORTIE:/sortie" \
    -e ISO_NOM="$ISO" \
    "$IMAGE"
fin=$(date +%s)
echo "Terminé en $(( (fin - debut) / 60 )) min. Captures : $SORTIE/debian-*.png"
echo "Journal : $TRAVAIL/piloter.log"
