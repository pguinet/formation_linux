#!/bin/bash
# Pilotage de VirtualBox 7.2.20 dans le conteneur (lance par capturer.sh).
# Ecran virtuel Xvfb 1280x800, gestionnaire de fenetres openbox, saisies
# par xdotool (texte colle via le presse-papiers : plus fiable que la frappe
# caractere par caractere dans les champs a completion de VirtualBox).
# Les coordonnees de clic sont relatives a la fenetre visee, dont la taille
# est fixee par le script.
set -euo pipefail

SORTIE=/sortie
LISTE="$SORTIE/vbox-captures.txt"
SOURCES=/mnt/D/PrenomNOM/sources
MACHINES=/mnt/D/PrenomNOM/VirtualBox
ISO="$SOURCES/debian-13.7.0-amd64-DVD-1.iso"
EXTPACK="$SOURCES/Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack"
VBM=/usr/lib/virtualbox/VBoxManage
export DISPLAY=:99

journal() { echo "[pilote] $*" >&2; }
echec() { journal "ERREUR : $*"; import -window root "$SORTIE/echec.png" || true; exit 1; }

# attendre_fenetre TITRE [DELAI] : affiche l'identifiant de la fenetre
# visible dont le titre contient TITRE.
attendre_fenetre() {
    local titre="$1" delai="${2:-30}" i w
    for ((i = 0; i < delai * 4; i++)); do
        w=$(xdotool search --onlyvisible --name "$titre" 2>/dev/null | tail -1 || true)
        if [ -n "$w" ]; then echo "$w"; return; fi
        sleep 0.25
    done
    echec "fenetre « $titre » absente apres ${delai} s"
}

# attendre_disparition TITRE [DELAI]
attendre_disparition() {
    local titre="$1" delai="${2:-60}" i
    for ((i = 0; i < delai * 4; i++)); do
        xdotool search --onlyvisible --name "$titre" >/dev/null 2>&1 || return 0
        sleep 0.25
    done
    echec "fenetre « $titre » toujours presente apres ${delai} s"
}

# attendre_stable [DELAI] : attend deux captures successives identiques.
attendre_stable() {
    local delai="${1:-20}" i
    import -window root /tmp/stable-a.png
    for ((i = 0; i < delai * 2; i++)); do
        sleep 0.5
        import -window root /tmp/stable-b.png
        if [ "$(compare -metric AE /tmp/stable-a.png /tmp/stable-b.png null: 2>&1 || true)" = "0" ]; then
            return
        fi
        mv /tmp/stable-b.png /tmp/stable-a.png
    done
    journal "avertissement : ecran non stabilise apres ${delai} s"
}

# clic FENETRE X Y : clic gauche en coordonnees relatives a la fenetre.
clic() { xdotool mousemove --window "$1" "$2" "$3" click 1; sleep 0.5; }

# coller TEXTE : remplace le contenu du champ actif par TEXTE.
coller() {
    printf %s "$1" | xclip -selection clipboard
    xdotool key ctrl+a ctrl+v
    sleep 0.3
}

# placer FENETRE LARGEUR HAUTEUR X Y
placer() {
    xdotool windowsize "$1" "$2" "$3"
    xdotool windowmove "$1" "$4" "$5"
    sleep 1
}

# capturer NOM FENETRE DESCRIPTION : capture la fenetre avec son cadre.
capturer() {
    local nom="$1" w="$2" description="$3" x y l h ext g d hd b
    xdotool mousemove 1279 799   # pointeur hors des fenetres
    attendre_stable
    x=$(xwininfo -id "$w" | awk '/Absolute upper-left X/ {print $4}')
    y=$(xwininfo -id "$w" | awk '/Absolute upper-left Y/ {print $4}')
    l=$(xwininfo -id "$w" | awk '/Width:/ {print $2}')
    h=$(xwininfo -id "$w" | awk '/Height:/ {print $2}')
    ext=$(xprop -id "$w" _NET_FRAME_EXTENTS | sed 's/.*= //; s/,//g')
    read -r g d hd b <<< "${ext:-0 0 0 0}"
    import -window root -crop "$((l + g + d))x$((h + hd + b))+$((x - g))+$((y - hd))" \
        +repage -strip "$SORTIE/$nom.png"
    optipng -quiet -o2 "$SORTIE/$nom.png"
    printf '%s.png -> %s\n' "$nom" "$description" >> "$LISTE"
    journal "capture $nom.png"
}

# --- Mise en route ----------------------------------------------------------
mkdir -m 700 "$XDG_RUNTIME_DIR"
Xvfb :99 -screen 0 1280x800x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
for _ in $(seq 40); do xdpyinfo >/dev/null 2>&1 && break; sleep 0.25; done
xdpyinfo >/dev/null 2>&1 || echec "Xvfb ne demarre pas"
openbox >/tmp/openbox.log 2>&1 &
sleep 1

# Message propre au conteneur (pas d'USB hote) : masque, il n'existe pas sur
# un poste Windows normal.
$VBM setextradata global GUI/SuppressMessages cannotEnumerateHostUSBDevices
mkdir -p "$MACHINES"
cat > "$LISTE" <<'FIN'
# Captures VirtualBox 7.2.20 (Linux, interface en francais, Basic Mode)
# Produites par outils/captures/virtualbox/capturer.sh (Xvfb + openbox).
# Chemins : l'assistant refuse un chemin Windows pour l'image ISO (fichier
# introuvable sous Linux) et transforme un dossier D:\... en chemin relatif ;
# les captures montrent donc l'equivalent Linux :
#   /mnt/D/PrenomNOM/sources    = D:\PrenomNOM\sources
#   /mnt/D/PrenomNOM/VirtualBox = D:\PrenomNOM\VirtualBox
# Apparence : fenetres Linux (theme Qt Fusion, cadres openbox) ; libelles
# identiques a la version Windows. Plusieurs libelles de la 7.2.20 ne sont
# pas traduits en francais (assistant, accueil) : c'est le cas aussi sous
# Windows. Carte reseau de l'hote : eth0 (sous Windows, nom de la carte
# Ethernet du poste).
FIN

/usr/bin/VirtualBox >/tmp/virtualbox.log 2>&1 &
GEST=$(attendre_fenetre "Gestionnaire de machines" 60)
placer "$GEST" 1100 720 90 40

# --- 1. Premier lancement --------------------------------------------------
capturer vbox-01-premier-lancement "$GEST" \
    "Gestionnaire au premier lancement : choix Basic Mode / Expert Mode (textes d'accueil non traduits dans la 7.2.20)"
clic "$GEST" 990 396                       # Basic Mode
sleep 1

# --- 2. Extension Pack ------------------------------------------------------
xdotool key ctrl+t                         # Outils > Extensions
sleep 1
capturer vbox-02-outil-extensions "$GEST" \
    "Outil Extensions (Fichier > Outils > Extensions, Ctrl+T) : liste vide, bouton Install"
clic "$GEST" 72 50                         # Install
attendre_fenetre "Choisissez un fichier extension" >/dev/null
sleep 0.5
coller "$EXTPACK"
xdotool key Return
QUESTION=$(attendre_fenetre "VirtualBox - Question")
capturer vbox-03-extension-confirmation "$QUESTION" \
    "Confirmation : Oracle VirtualBox Extension Pack, version 7.2.20r175154, bouton Installation"
xdotool key Return                         # Installation (bouton par defaut)
LIC=$(attendre_fenetre "Licence VirtualBox")
sleep 1
capturer vbox-04-extension-licence-debut "$LIC" \
    "Licence PUEL de l'Extension Pack : boutons J'accepte / Je n'accepte pas grises tant que le texte n'est pas lu"
xdotool mousemove --window "$LIC" 290 250
xdotool click --repeat 250 --delay 5 5      # molette jusqu'en bas du texte
sleep 1
capturer vbox-05-extension-licence-fin "$LIC" \
    "Licence lue jusqu'au bout : bouton J'accepte actif"
clic "$LIC" 424 426                       # J'accepte
attendre_disparition "Licence VirtualBox" 120
for _ in $(seq 120); do
    $VBM list extpacks 2>/dev/null | grep -q "Usable: *true" && break
    sleep 0.5
done
$VBM list extpacks | grep -q "Version: *7.2.20" || echec "Extension Pack non installe"
sleep 2
capturer vbox-06-extension-installee "$GEST" \
    "Extension installee : Oracle VirtualBox Extension Pack, active, version 7.2.20r175154"

# --- 3. Assistant Nouvelle machine virtuelle --------------------------------
clic "$GEST" 23 41                         # outil Home
clic "$GEST" 79 50                         # Nouvelle
WIZ=$(attendre_fenetre "New Virtual Machine")
sleep 1
coller FormationLinux                      # champ VM Name (focus initial)
xdotool key Tab
coller "$MACHINES"                         # VM Folder
xdotool key Tab
coller "$ISO"                              # ISO Image
xdotool key Tab
sleep 3                                    # detection du systeme dans l'ISO
capturer vbox-07-nouvelle-machine-iso-detectee "$WIZ" \
    "Assistant, page 1 : nom FormationLinux, dossier et ISO saisis, Debian 13 Trixie (64-bit) detecte, installation sans surveillance cochee par defaut"
clic "$WIZ" 250 298                        # decocher Proceed with Unattended Installation
capturer vbox-08-nouvelle-machine-sans-surveillance-decochee "$WIZ" \
    "Assistant, page 1 : case Proceed with Unattended Installation decochee (installation manuelle)"
xdotool key alt+s                          # Suivant
sleep 1.5
xdotool key alt+m; coller 4096             # Base Memory
xdotool key alt+n; coller 2                # Number of CPUs
clic "$WIZ" 752 199; coller "30 Gio"       # Disk Size (le raccourci Alt+K vise le curseur)
xdotool key Tab
capturer vbox-09-nouvelle-machine-materiel "$WIZ" \
    "Assistant, page 2 : 4096 Mo de memoire, 2 CPU, disque de 30 Gio (VDI dynamique par defaut en Basic Mode), EFI non coche"
xdotool key alt+s                          # Suivant
sleep 1.5
capturer vbox-10-nouvelle-machine-recapitulatif "$WIZ" \
    "Assistant, Recapitulatif : FormationLinux, dossier, ISO, Debian 13 Trixie (64-bit), sans surveillance false, 4096, 2 processeurs, 30,00 Gio"
xdotool key alt+f                          # Finish
attendre_disparition "New Virtual Machine" 60
sleep 2
$VBM showvminfo FormationLinux >/dev/null || echec "VM FormationLinux non creee"
capturer vbox-11-machine-creee "$GEST" \
    "Gestionnaire : machine FormationLinux creee (Eteinte), details 4096 Mo, 2 processeurs, ISO et FormationLinux.vdi 30,00 Gio, reseau NAT par defaut"

# --- 4. Configuration : reseau par pont, processeur -------------------------
clic "$GEST" 211 50                        # Configuration
CONF=$(attendre_fenetre "FormationLinux - Settings")
placer "$CONF" 1000 680 140 60
clic "$CONF" 71 269                        # section Reseau
clic "$CONF" 466 208                       # liste « Attached to »
xdotool key Down Return                    # NAT -> Acces par pont
sleep 1
capturer vbox-12-configuration-reseau-pont "$CONF" \
    "Configuration > Reseau : Adapter 1 active, Attached to = Acces par pont, Name = eth0 (carte reseau de l'hote)"
clic "$CONF" 71 109                        # section System
clic "$CONF" 383 96                        # onglet Processeur
capturer vbox-13-configuration-processeur "$CONF" \
    "Configuration > System > Processeur : Number of CPUs = 2"
clic "$CONF" 778 658                       # OK
attendre_disparition "FormationLinux - Settings" 30
$VBM showvminfo FormationLinux --machinereadable | grep -q '^nic1="bridged"' \
    || echec "le reseau n'est pas en acces par pont"
sleep 1
capturer vbox-14-machine-configuree "$GEST" \
    "Gestionnaire : details de FormationLinux, Reseau : Interface 1 en Acces par pont"

# --- 5. Verifications et hash de licence ------------------------------------
$VBM showvminfo FormationLinux --machinereadable > "$SORTIE/vm-formationlinux.txt"
$VBM showmediuminfo "$MACHINES/FormationLinux/FormationLinux.vdi" > "$SORTIE/disque-formationlinux.txt"
grep -q "Format variant: *dynamic" "$SORTIE/disque-formationlinux.txt" \
    || echec "disque non dynamique"
grep -q "Capacity: *30720 MBytes" "$SORTIE/disque-formationlinux.txt" \
    || echec "disque different de 30 Gio"
grep -q "Storage format: *VDI" "$SORTIE/disque-formationlinux.txt" \
    || echec "disque non VDI"
grep -q '^memory=4096$' "$SORTIE/vm-formationlinux.txt" || echec "memoire differente de 4096 Mo"
grep -q '^cpus=2$' "$SORTIE/vm-formationlinux.txt" || echec "nombre de CPU different de 2"
HASH=$(echo y | $VBM extpack install --replace "$EXTPACK" 2>&1 \
    | grep -o -- '--accept-license=[0-9a-f]*' | cut -d= -f2)
ATTENDU=$(tar -xzOf "$EXTPACK" ./ExtPack-license.txt | sha256sum | cut -d' ' -f1)
[ -n "$HASH" ] && [ "$HASH" = "$ATTENDU" ] || echec "hash de licence inattendu : $HASH"
echo "$HASH" > "$SORTIE/extpack-licence.txt"
journal "hash de licence de l'Extension Pack : $HASH"

/usr/lib/virtualbox/VBoxManage --version > "$SORTIE/version.txt"
chown -R "${HOTE_UID:-0}:${HOTE_GID:-0}" "$SORTIE"
journal "termine"
