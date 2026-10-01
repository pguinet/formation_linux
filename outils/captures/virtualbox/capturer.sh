#!/bin/bash
# Captures reproductibles de l'interface de VirtualBox 7.2.20 (Linux, en
# francais) pour l'annexe d'installation VirtualBox.
#
# Usage : outils/captures/virtualbox/capturer.sh
#
# 1. Telecharge (si absent) et verifie par SHA256 le paquet Debian de
#    VirtualBox, l'Extension Pack et l'image Debian 13.7 DVD-1 dans
#    build/captures/cache/.
# 2. Construit l'image Docker formation-linux-vbox.
# 3. Lance pilote.sh dans un conteneur (Xvfb + openbox + xdotool) : aucune
#    VM n'est demarree, seules les fenetres sont capturees.
# 4. Copie les PNG optimises dans ressources/images/installation/ avec la
#    liste vbox-captures.txt.
set -euo pipefail

ICI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RACINE="$(cd "$ICI/../../.." && pwd)"
CACHE="$RACINE/build/captures/cache"
TRAVAIL="$RACINE/build/captures/vbox"
CONTEXTE="$RACINE/build/captures/vbox-contexte"
DEST="$RACINE/ressources/images/installation"
IMAGE="formation-linux-vbox"

VBOX_URL="https://download.virtualbox.org/virtualbox/7.2.20"
DEB="virtualbox-7.2_7.2.20-175154~Debian~trixie_amd64.deb"
DEB_SHA256="04b25e10058a4e0e561498db05c456f9705b8315e3535522d30af5bc9cc06cd7"
EXTPACK="Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack"
EXTPACK_SHA256="0a050da993f2e3cf2e4e9cda2fa8667e44a2b25479b27abd41af6812c1e43591"
ISO_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd"
ISO="debian-13.7.0-amd64-DVD-1.iso"
ISO_SHA256="347b6c67a3cc0b7ddb60b178f683470c4e2b7ac426c996d9337a2ff36c1a32d2"

# telecharger_verifie FICHIER URL SHA256
telecharger_verifie() {
    local fichier="$1" url="$2" attendu="$3"
    if [ -f "$CACHE/$fichier" ] \
        && echo "$attendu  $CACHE/$fichier" | sha256sum --check --status; then
        echo "OK (cache) : $fichier"
        return
    fi
    echo "Telechargement : $url"
    curl -fL --retry 3 -o "$CACHE/$fichier.part" "$url"
    mv "$CACHE/$fichier.part" "$CACHE/$fichier"
    if ! echo "$attendu  $CACHE/$fichier" | sha256sum --check --status; then
        echo "ERREUR : SHA256 incorrect pour $fichier" >&2
        exit 1
    fi
    echo "OK (telecharge) : $fichier"
}

mkdir -p "$CACHE" "$TRAVAIL" "$CONTEXTE" "$DEST"
telecharger_verifie "$DEB" "$VBOX_URL/$DEB" "$DEB_SHA256"
telecharger_verifie "$EXTPACK" "$VBOX_URL/$EXTPACK" "$EXTPACK_SHA256"
telecharger_verifie "$ISO" "$ISO_URL/$ISO" "$ISO_SHA256"

# Contexte de construction minimal (le paquet seul, pas l'image ISO).
ln -f "$CACHE/$DEB" "$CONTEXTE/$DEB" 2>/dev/null || cp -f "$CACHE/$DEB" "$CONTEXTE/$DEB"
docker build -t "$IMAGE" -f "$ICI/Dockerfile" \
    --build-context cache="$CONTEXTE" "$ICI"

rm -f "$TRAVAIL"/vbox-*.png "$TRAVAIL"/vbox-captures.txt "$TRAVAIL"/echec.png
# Le dossier du cache est monte a la place de D:\PrenomNOM\sources\ :
# /mnt/D/PrenomNOM/sources (lecture seule).
docker run --rm \
    -e HOTE_UID="$(id -u)" -e HOTE_GID="$(id -g)" \
    -v "$CACHE:/mnt/D/PrenomNOM/sources:ro" \
    -v "$ICI:/outils:ro" \
    -v "$TRAVAIL:/sortie" \
    "$IMAGE" bash /outils/pilote.sh

rm -f "$DEST"/vbox-*.png
cp "$TRAVAIL"/vbox-*.png "$TRAVAIL/vbox-captures.txt" "$DEST/"
echo
echo "Captures copiees dans $DEST :"
ls -l "$DEST"/vbox-*
echo
echo "Hash de licence de l'Extension Pack : $(cat "$TRAVAIL/extpack-licence.txt")"
