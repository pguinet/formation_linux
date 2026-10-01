# Scripts bash simples

## Objectifs d'apprentissage
- Creer des scripts bash fonctionnels et robustes
- Maitriser les variables, conditions et boucles
- Gerer les arguments et les codes de retour
- Implementer la gestion d'erreurs et le logging
- Developper des scripts d'administration systeme

## Introduction

Les **scripts bash** permettent d'automatiser les taches repetitives et de creer des outils personnalises. Bash (Bourne Again Shell) est le shell par defaut sur la plupart des distributions Linux et offre des fonctionnalites de programmation puissantes.

---

## 1. Structure de base d'un script bash

### Shebang et configuration

#### Ligne shebang
```bash
#!/bin/bash
# Le shebang indique quel interpreteur utiliser

#!/usr/bin/env bash
# Version portable (trouve bash dans le PATH)

#!/bin/sh
# Shell POSIX (plus compatible mais moins de fonctionnalites)
```

#### Options de script recommandees
```bash
#!/bin/bash

# Mode strict recommande
set -euo pipefail
# -e : arret si erreur
# -u : arret si variable non definie
# -o pipefail : echec si une commande du pipeline echoue

# Desactivation du globbing
set -f

# Script simple avec bonnes pratiques
#!/bin/bash
set -euo pipefail

echo "Debut du script"
echo "Utilisateur: $USER"
echo "Date: $(date)"
```

### Permissions et execution

#### Rendre un script executable
```bash
# Creer le script
cat > mon_script.sh << 'EOF'
#!/bin/bash
echo "Hello World!"
echo "Script execute par: $USER"
EOF

# Donner les permissions d'execution
chmod +x mon_script.sh

# Executer le script
./mon_script.sh

# Ou
bash mon_script.sh
```

#### Placement des scripts
```bash
# Scripts personnels
mkdir -p ~/bin
mv mon_script.sh ~/bin/
export PATH="$HOME/bin:$PATH"  # Dans ~/.bashrc
mon_script.sh  # Executable depuis n'importe ou

# Scripts systeme
sudo mv mon_script.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/mon_script.sh
```

---

## 2. Variables et types de donnees

### Variables locales et environnement

#### Declaration et utilisation
```bash
#!/bin/bash

# Variables locales (sans export)
nom="Alice"
age=25
actif=true

# Variables d'environnement (avec export)
export SCRIPT_VERSION="1.0"
export LOG_LEVEL="INFO"

# Utilisation
echo "Nom: $nom"
echo "Age: $age ans"
echo "Version: $SCRIPT_VERSION"

# Acces securise avec accolades
echo "Utilisateur ${nom} a ${age} ans"
```

#### Variables speciales bash
```bash
#!/bin/bash

echo "Nom du script: $0"
echo "Premier argument: $1"
echo "Deuxieme argument: $2"
echo "Tous les arguments: $@"
echo "Nombre d'arguments: $#"
echo "PID du script: $$"
echo "Code retour derniere commande: $?"
echo "Arguments sous forme chaine: $*"

# Variables d'environnement utiles
echo "Utilisateur: $USER"
echo "Repertoire personnel: $HOME"
echo "Repertoire courant: $PWD"
echo "Shell: $SHELL"
echo "Nom d'hote: $HOSTNAME"
```

### Types et manipulation de donnees

#### Chaines de caracteres
```bash
#!/bin/bash

texte="Bonjour le monde"
nom="Alice"

# Longueur
echo "Longueur: ${#texte}"

# Extraction de sous-chaines
echo "Sous-chaine: ${texte:0:7}"      # "Bonjour"
echo "Fin: ${texte: -5}"              # "monde"

# Remplacement
echo "${texte/monde/univers}"         # Remplacer premiere occurrence
echo "${texte//o/0}"                  # Remplacer toutes les occurrences

# Casse
echo "${nom^^}"                       # Majuscules
echo "${nom,,}"                       # Minuscules
```

#### Tableaux
```bash
#!/bin/bash

# Tableau indexe
fruits=("pomme" "banane" "orange" "kiwi")

# Acces aux elements
echo "Premier fruit: ${fruits[0]}"
echo "Dernier fruit: ${fruits[-1]}"

# Tous les elements
echo "Tous les fruits: ${fruits[@]}"
echo "Nombre de fruits: ${#fruits[@]}"

# Ajouter des elements
fruits+=("mangue" "ananas")

# Parcourir le tableau
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done

# Tableau associatif (bash 4+)
declare -A config
config[host]="localhost"
config[port]="8080"
config[debug]="true"

echo "Configuration:"
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

#### Variables numeriques
```bash
#!/bin/bash

# Arithmetique bash
a=10
b=5

# Operations arithmetiques
echo "Addition: $((a + b))"
echo "Soustraction: $((a - b))"
echo "Multiplication: $((a * b))"
echo "Division: $((a / b))"
echo "Modulo: $((a % b))"

# Incrementation
((a++))
echo "a apres incrementation: $a"

# Comparaisons numeriques
if ((a > b)); then
    echo "$a est plus grand que $b"
fi

# Variables de calcul
resultat=$((a * b + 10))
echo "Resultat: $resultat"
```

---

## 3. Structures conditionnelles

### Tests et comparaisons

#### Tests sur fichiers
```bash
#!/bin/bash

fichier="$1"

if [ -z "$fichier" ]; then
    echo "Usage: $0 <fichier>"
    exit 1
fi

# Tests de fichiers
if [ -f "$fichier" ]; then
    echo "$fichier est un fichier regulier"
elif [ -d "$fichier" ]; then
    echo "$fichier est un repertoire"
elif [ -L "$fichier" ]; then
    echo "$fichier est un lien symbolique"
else
    echo "$fichier n'existe pas ou type inconnu"
fi

# Tests de permissions
if [ -r "$fichier" ]; then
    echo "Fichier lisible"
fi

if [ -w "$fichier" ]; then
    echo "Fichier modifiable"
fi

if [ -x "$fichier" ]; then
    echo "Fichier executable"
fi
```

#### Tests sur chaines
```bash
#!/bin/bash

texte1="$1"
texte2="$2"

# Test de chaine vide
if [ -z "$texte1" ]; then
    echo "Premiere chaine est vide"
fi

# Test de chaine non vide
if [ -n "$texte1" ]; then
    echo "Premiere chaine: '$texte1'"
fi

# Comparaisons de chaines
if [ "$texte1" = "$texte2" ]; then
    echo "Chaines identiques"
elif [ "$texte1" \< "$texte2" ]; then
    echo "'$texte1' < '$texte2' (ordre lexicographique)"
else
    echo "'$texte1' > '$texte2' (ordre lexicographique)"
fi

# Tests avec expressions regulieres (bash)
if [[ "$texte1" =~ ^[0-9]+$ ]]; then
    echo "$texte1 est un nombre"
fi

if [[ "$texte1" == *"test"* ]]; then
    echo "$texte1 contient 'test'"
fi
```

#### Tests numeriques
```bash
#!/bin/bash

num1=${1:-0}
num2=${2:-0}

# Comparaisons numeriques
if [ "$num1" -eq "$num2" ]; then
    echo "$num1 egal $num2"
elif [ "$num1" -gt "$num2" ]; then
    echo "$num1 plus grand que $num2"
elif [ "$num1" -lt "$num2" ]; then
    echo "$num1 plus petit que $num2"
fi

# Autres operateurs numeriques
if [ "$num1" -ge 0 ]; then
    echo "$num1 est positif ou nul"
fi

if [ "$num1" -le 100 ]; then
    echo "$num1 est inferieur ou egal a 100"
fi

if [ "$num1" -ne 0 ]; then
    echo "$num1 est different de zero"
fi
```

### Structures conditionnelles complexes

#### case/esac - Switch bash
```bash
#!/bin/bash

action="$1"

case "$action" in
    "start")
        echo "Demarrage du service..."
        # Commandes de demarrage
        ;;
    "stop")
        echo "Arret du service..."
        # Commandes d'arret
        ;;
    "restart")
        echo "Redemarrage du service..."
        # Commandes de redemarrage
        ;;
    "status")
        echo "Etat du service..."
        # Verification du statut
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 {start|stop|restart|status|help}"
        ;;
    *)
        echo "Action inconnue: $action"
        echo "Usage: $0 {start|stop|restart|status|help}"
        exit 1
        ;;
esac
```

#### Conditions avec patterns
```bash
#!/bin/bash

fichier="$1"

case "$fichier" in
    *.txt)
        echo "Fichier texte detecte"
        cat "$fichier"
        ;;
    *.jpg|*.png|*.gif)
        echo "Fichier image detecte"
        file "$fichier"
        ;;
    *.sh)
        echo "Script bash detecte"
        bash -n "$fichier" && echo "Syntaxe correcte"
        ;;
    [0-9]*)
        echo "Nom commence par un chiffre"
        ;;
    /etc/*)
        echo "Fichier de configuration systeme"
        ;;
    *)
        echo "Type de fichier non reconnu"
        ;;
esac
```

---

## 4. Boucles et iterations

### Boucle for

#### Iteration sur listes
```bash
#!/bin/bash

# Liste de valeurs
echo "=== Fruits ==="
for fruit in pomme banane orange; do
    echo "Fruit: $fruit"
done

# Liste de fichiers
echo -e "\n=== Fichiers .txt ==="
for fichier in *.txt; do
    if [ -f "$fichier" ]; then
        echo "Fichier: $fichier ($(wc -l < "$fichier") lignes)"
    fi
done

# Sequence numerique
echo -e "\n=== Compteur ==="
for i in {1..5}; do
    echo "Iteration $i"
done

# Pas personnalise
echo -e "\n=== Pas de 2 ==="
for i in {0..10..2}; do
    echo "Nombre pair: $i"
done
```

#### Iteration sur tableaux et arguments
```bash
#!/bin/bash

# Tableau
services=("nginx" "apache2" "mysql" "postgresql")

echo "=== Services a verifier ==="
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "[OK] $service: actif"
    else
        echo "[NOK] $service: inactif"
    fi
done

# Arguments du script
echo -e "\n=== Arguments recus ==="
for arg in "$@"; do
    echo "Argument: $arg"
done

# Style C
echo -e "\n=== Style C ==="
for ((i=0; i<5; i++)); do
    echo "Index: $i, Carre: $((i*i))"
done
```

### Boucle while

#### Boucle conditionnelle
```bash
#!/bin/bash

# Compteur simple
compteur=1
echo "=== Compteur while ==="
while [ $compteur -le 5 ]; do
    echo "Compteur: $compteur"
    ((compteur++))
done

# Lecture d'un fichier ligne par ligne
echo -e "\n=== Lecture fichier ==="
if [ -f "/etc/passwd" ]; then
    while IFS=: read -r user _ uid _ _ home shell; do
        if [ "$uid" -ge 1000 ]; then
            echo "Utilisateur: $user, UID: $uid, Home: $home, Shell: $shell"
        fi
    done < /etc/passwd
fi

# Boucle infinie avec condition de sortie
echo -e "\n=== Surveillance (Ctrl+C pour arreter) ==="
while true; do
    load=$(cat /proc/loadavg | cut -d' ' -f1)
    echo "$(date): Charge systeme: $load"
    
    # Condition de sortie
    if (( $(echo "$load > 5.0" | bc -l) )); then
        echo "Charge trop elevee, arret de la surveillance"
        break
    fi
    
    sleep 5
done
```

### Boucle until

#### Attente conditionnelle
```bash
#!/bin/bash

# Attendre qu'un service soit demarre
service_name="$1"

if [ -z "$service_name" ]; then
    echo "Usage: $0 <service_name>"
    exit 1
fi

echo "Attente du demarrage de $service_name..."
until systemctl is-active --quiet "$service_name"; do
    echo "Service $service_name pas encore actif, attente..."
    sleep 2
done

echo "Service $service_name est maintenant actif!"

# Attendre qu'un fichier apparaisse
fichier_attendu="/tmp/signal_file"
echo "Attente du fichier signal: $fichier_attendu"

until [ -f "$fichier_attendu" ]; do
    echo "Fichier pas encore cree, attente..."
    sleep 1
done

echo "Fichier signal detecte!"
```

---

## 5. Fonctions

### Definition et utilisation

#### Fonctions simples
```bash
#!/bin/bash

# Definition d'une fonction simple
saluer() {
    echo "Bonjour $1!"
}

# Fonction avec valeur de retour
est_pair() {
    local nombre=$1
    if (( nombre % 2 == 0 )); then
        return 0  # vrai
    else
        return 1  # faux
    fi
}

# Fonction avec variables locales
calculer_moyenne() {
    local somme=0
    local count=0
    
    for nombre in "$@"; do
        ((somme += nombre))
        ((count++))
    done
    
    if [ $count -gt 0 ]; then
        echo "scale=2; $somme / $count" | bc
    else
        echo "0"
    fi
}

# Utilisation des fonctions
saluer "Alice"
saluer "Bob"

if est_pair 42; then
    echo "42 est pair"
fi

moyenne=$(calculer_moyenne 10 20 30 40 50)
echo "Moyenne: $moyenne"
```

#### Fonctions utilitaires
```bash
#!/bin/bash

# Fonction de logging avec horodatage
log() {
    local niveau="$1"
    shift
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$niveau] $*" >&2
}

# Fonction de validation
valider_fichier() {
    local fichier="$1"
    
    if [ ! -f "$fichier" ]; then
        log "ERREUR" "Fichier inexistant: $fichier"
        return 1
    fi
    
    if [ ! -r "$fichier" ]; then
        log "ERREUR" "Fichier non lisible: $fichier"
        return 1
    fi
    
    log "INFO" "Fichier valide: $fichier"
    return 0
}

# Fonction de sauvegarde
sauvegarder_fichier() {
    local source="$1"
    local destination="$2"
    
    if valider_fichier "$source"; then
        if cp "$source" "$destination"; then
            log "INFO" "Sauvegarde reussie: $source -> $destination"
            return 0
        else
            log "ERREUR" "Echec sauvegarde: $source -> $destination"
            return 1
        fi
    fi
    
    return 1
}

# Utilisation
log "INFO" "Debut du script"
sauvegarder_fichier "/etc/passwd" "/tmp/passwd.backup"
log "INFO" "Fin du script"
```

---

## 6. Gestion d'erreurs et codes de retour

### Codes de retour et exit

#### Gestion basique des erreurs
```bash
#!/bin/bash
set -euo pipefail

# Fonction qui peut echouer
copier_avec_verification() {
    local source="$1"
    local dest="$2"
    
    if [ ! -f "$source" ]; then
        echo "Erreur: Fichier source inexistant: $source" >&2
        return 1
    fi
    
    if ! cp "$source" "$dest"; then
        echo "Erreur: Impossible de copier $source vers $dest" >&2
        return 2
    fi
    
    echo "Copie reussie: $source -> $dest"
    return 0
}

# Gestion des codes de retour
fichier_source="/etc/hostname"
fichier_dest="/tmp/hostname.backup"

if copier_avec_verification "$fichier_source" "$fichier_dest"; then
    echo "Operation terminee avec succes"
    exit 0
else
    code_erreur=$?
    case $code_erreur in
        1) echo "Erreur: Fichier source non trouve" >&2 ;;
        2) echo "Erreur: Probleme lors de la copie" >&2 ;;
        *) echo "Erreur inconnue (code: $code_erreur)" >&2 ;;
    esac
    exit $code_erreur
fi
```

#### Trap - Gestion des signaux
```bash
#!/bin/bash

# Fichier temporaire
TEMP_FILE="/tmp/mon_script_$$"

# Fonction de nettoyage
cleanup() {
    echo "Nettoyage en cours..."
    rm -f "$TEMP_FILE"
    echo "Nettoyage termine"
}

# Capturer les signaux pour nettoyage
trap cleanup EXIT
trap 'echo "Script interrompu"; exit 1' INT TERM

# Simulation de travail
echo "Creation de fichier temporaire: $TEMP_FILE"
echo "Donnees temporaires" > "$TEMP_FILE"

echo "Travail en cours... (Ctrl+C pour interrompre)"
for i in {1..10}; do
    echo "Etape $i/10"
    sleep 1
done

echo "Travail termine normalement"
# Le cleanup sera appele automatiquement grace a trap EXIT
```

### Validation d'entrees

#### Script robuste avec validations
```bash
#!/bin/bash
set -euo pipefail

# Fonction d'aide
usage() {
    cat << EOF
Usage: $0 [OPTIONS] <source> <destination>

Copie un fichier avec verifications de securite.

OPTIONS:
    -h, --help      Afficher cette aide
    -v, --verbose   Mode verbeux
    -f, --force     Forcer l'ecrasement

EXEMPLES:
    $0 file1.txt file2.txt
    $0 -v -f /etc/passwd backup.txt
EOF
}

# Variables par defaut
VERBOSE=false
FORCE=false
SOURCE=""
DESTINATION=""

# Analyse des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -*)
            echo "Option inconnue: $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            if [ -z "$SOURCE" ]; then
                SOURCE="$1"
            elif [ -z "$DESTINATION" ]; then
                DESTINATION="$1"
            else
                echo "Trop d'arguments" >&2
                usage >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validation des parametres obligatoires
if [ -z "$SOURCE" ] || [ -z "$DESTINATION" ]; then
    echo "Erreur: Source et destination sont obligatoires" >&2
    usage >&2
    exit 1
fi

# Fonction de log conditionnel
log() {
    if [ "$VERBOSE" = true ]; then
        echo "[$(date '+%H:%M:%S')] $*"
    fi
}

# Validations
log "Validation du fichier source: $SOURCE"
if [ ! -f "$SOURCE" ]; then
    echo "Erreur: Fichier source inexistant: $SOURCE" >&2
    exit 2
fi

if [ ! -r "$SOURCE" ]; then
    echo "Erreur: Fichier source non lisible: $SOURCE" >&2
    exit 2
fi

log "Verification de la destination: $DESTINATION"
if [ -f "$DESTINATION" ] && [ "$FORCE" = false ]; then
    echo "Erreur: Fichier destination existe deja (utiliser -f pour forcer): $DESTINATION" >&2
    exit 3
fi

# Copie
log "Copie de $SOURCE vers $DESTINATION"
if cp "$SOURCE" "$DESTINATION"; then
    echo "Copie reussie: $SOURCE -> $DESTINATION"
    log "Taille copiee: $(stat -c%s "$DESTINATION") bytes"
else
    echo "Erreur lors de la copie" >&2
    exit 4
fi
```

---

## 7. Scripts d'administration systeme

### Script de surveillance systeme

```bash
#!/bin/bash
# system_monitor.sh - Surveillance systeme complete

set -euo pipefail

# Configuration
SCRIPT_NAME=$(basename "$0")
LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"
CONFIG_FILE="/etc/${SCRIPT_NAME%.sh}.conf"
ALERT_EMAIL="admin@domain.com"

# Seuils par defaut
DEFAULT_CPU_THRESHOLD=80
DEFAULT_MEM_THRESHOLD=85
DEFAULT_DISK_THRESHOLD=90

# Charger configuration si disponible
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Valeurs finales
CPU_THRESHOLD=${CPU_THRESHOLD:-$DEFAULT_CPU_THRESHOLD}
MEM_THRESHOLD=${MEM_THRESHOLD:-$DEFAULT_MEM_THRESHOLD}
DISK_THRESHOLD=${DISK_THRESHOLD:-$DEFAULT_DISK_THRESHOLD}

# Fonction de logging
log_message() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Fonction d'alerte
send_alert() {
    local subject="$1"
    local message="$2"
    
    log_message "ALERT" "$subject"
    
    # Envoyer par email si configure
    if command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "$subject" "$ALERT_EMAIL" || true
    fi
    
    # Notification systeme si disponible
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Alerte Systeme" "$subject" || true
    fi
}

# Verification CPU
check_cpu() {
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    cpu_usage=${cpu_usage%.*}  # Supprimer decimales
    
    log_message "INFO" "Utilisation CPU: ${cpu_usage}%"
    
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        local top_processes
        top_processes=$(ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %s: %.1f%%\n", $11, $3}')
        
        send_alert "CPU eleve: ${cpu_usage}%" \
"Utilisation CPU: ${cpu_usage}% (seuil: ${CPU_THRESHOLD}%)

Top processus:
$top_processes"
        return 1
    fi
    
    return 0
}

# Verification memoire
check_memory() {
    local mem_info
    mem_info=$(free | grep Mem:)
    
    local total=$(echo "$mem_info" | awk '{print $2}')
    local used=$(echo "$mem_info" | awk '{print $3}')
    local mem_usage=$((used * 100 / total))
    
    log_message "INFO" "Utilisation memoire: ${mem_usage}%"
    
    if [ "$mem_usage" -gt "$MEM_THRESHOLD" ]; then
        local mem_details
        mem_details=$(free -h | grep -E "Mem:|Swap:")
        
        send_alert "Memoire elevee: ${mem_usage}%" \
"Utilisation memoire: ${mem_usage}% (seuil: ${MEM_THRESHOLD}%)

Details memoire:
$mem_details"
        return 1
    fi
    
    return 0
}

# Verification espace disque
check_disk() {
    local alerts=()
    
    while read filesystem size used avail percent mountpoint; do
        # Ignorer la ligne d'en-tete et les pseudo-filesystems
        [[ "$filesystem" =~ ^/dev ]] || continue
        
        local usage=${percent%\%}
        log_message "INFO" "Disque $mountpoint: ${usage}% utilise"
        
        if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
            alerts+=("$mountpoint: ${usage}% (${used}/${size})")
        fi
    done < <(df -h)
    
    if [ ${#alerts[@]} -gt 0 ]; then
        local alert_list
        alert_list=$(printf "  %s\n" "${alerts[@]}")
        
        send_alert "Espace disque faible" \
"Partitions avec espace faible (seuil: ${DISK_THRESHOLD}%):
$alert_list

Detail complet:
$(df -h)"
        return 1
    fi
    
    return 0
}

# Verification services
check_services() {
    local critical_services=("sshd" "cron" "rsyslog")
    local failed_services=()
    
    for service in "${critical_services[@]}"; do
        if ! systemctl is-active --quiet "$service" 2>/dev/null; then
            failed_services+=("$service")
        fi
    done
    
    if [ ${#failed_services[@]} -gt 0 ]; then
        local service_list
        service_list=$(printf "  %s\n" "${failed_services[@]}")
        
        send_alert "Services critiques arretes" \
"Services critiques non actifs:
$service_list

Etat detaille:
$(for s in "${failed_services[@]}"; do systemctl status "$s" --no-pager -l || true; done)"
        return 1
    fi
    
    log_message "INFO" "Tous les services critiques sont actifs"
    return 0
}

# Fonction principale
main() {
    log_message "INFO" "Debut de la surveillance systeme"
    
    local exit_code=0
    
    # Executer toutes les verifications
    check_cpu || exit_code=1
    check_memory || exit_code=1
    check_disk || exit_code=1
    check_services || exit_code=1
    
    if [ $exit_code -eq 0 ]; then
        log_message "INFO" "Surveillance terminee - Aucune alerte"
    else
        log_message "WARNING" "Surveillance terminee - Alertes detectees"
    fi
    
    return $exit_code
}

# Gestion des signaux
trap 'log_message "WARNING" "Script interrompu"; exit 130' INT TERM

# Execution
case "${1:-}" in
    "--help"|"-h")
        cat << EOF
Usage: $0 [OPTIONS]

Surveillance systeme avec alertes automatiques.

OPTIONS:
    --help, -h      Afficher cette aide
    --config        Afficher la configuration actuelle
    --test          Mode test (pas d'alertes par email)

CONFIGURATION:
Fichier: $CONFIG_FILE
Variables:
    CPU_THRESHOLD=$CPU_THRESHOLD
    MEM_THRESHOLD=$MEM_THRESHOLD
    DISK_THRESHOLD=$DISK_THRESHOLD
    ALERT_EMAIL=$ALERT_EMAIL
EOF
        ;;
    "--config")
        echo "Configuration actuelle:"
        echo "  CPU_THRESHOLD=$CPU_THRESHOLD%"
        echo "  MEM_THRESHOLD=$MEM_THRESHOLD%"
        echo "  DISK_THRESHOLD=$DISK_THRESHOLD%"
        echo "  ALERT_EMAIL=$ALERT_EMAIL"
        echo "  LOG_FILE=$LOG_FILE"
        ;;
    "--test")
        ALERT_EMAIL=""  # Desactiver email en mode test
        main
        ;;
    "")
        main
        ;;
    *)
        echo "Option inconnue: $1" >&2
        echo "Utiliser --help pour voir les options disponibles" >&2
        exit 1
        ;;
esac
```

### Script de deploiement d'application

```bash
#!/bin/bash
# deploy_app.sh - Script de deploiement automatise

set -euo pipefail

# Configuration
APP_NAME="mon-app"
APP_DIR="/opt/$APP_NAME"
BACKUP_DIR="/backup/deployments"
LOG_FILE="/var/log/deploy-$APP_NAME.log"
SYSTEMD_SERVICE="$APP_NAME.service"

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging avec couleurs
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
}

# Fonction de nettoyage
cleanup() {
    if [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
        log_info "Nettoyage du repertoire temporaire: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# Validation de l'environnement
validate_environment() {
    log_info "Validation de l'environnement de deploiement"
    
    # Verifier droits sudo
    if ! sudo -n true 2>/dev/null; then
        log_error "Droits sudo requis"
        exit 1
    fi
    
    # Verifier espace disque
    local available_space
    available_space=$(df /opt | tail -1 | awk '{print $4}')
    if [ "$available_space" -lt 1048576 ]; then  # 1GB en KB
        log_warning "Espace disque faible sur /opt: ${available_space}KB"
    fi
    
    # Creer repertoires necessaires
    sudo mkdir -p "$APP_DIR" "$BACKUP_DIR"
    
    log_info "Environnement valide"
}

# Sauvegarde de l'ancienne version
backup_current_version() {
    if [ -d "$APP_DIR" ] && [ "$(ls -A "$APP_DIR" 2>/dev/null)" ]; then
        local backup_name="$APP_NAME-backup-$(date +%Y%m%d_%H%M%S)"
        local backup_path="$BACKUP_DIR/$backup_name"
        
        log_info "Sauvegarde de la version actuelle vers: $backup_path"
        
        sudo mkdir -p "$backup_path"
        sudo cp -r "$APP_DIR"/* "$backup_path/"
        
        # Garder seulement les 5 dernieres sauvegardes
        sudo find "$BACKUP_DIR" -maxdepth 1 -name "$APP_NAME-backup-*" -type d | \
            sort -r | tail -n +6 | xargs -r sudo rm -rf
        
        log_info "Sauvegarde terminee"
    else
        log_info "Aucune version existante a sauvegarder"
    fi
}

# Deploiement de la nouvelle version
deploy_application() {
    local source_path="$1"
    
    if [ ! -f "$source_path" ]; then
        log_error "Archive source non trouvee: $source_path"
        exit 1
    fi
    
    log_info "Deploiement depuis: $source_path"
    
    # Creer repertoire temporaire
    TEMP_DIR=$(mktemp -d)
    log_info "Extraction vers: $TEMP_DIR"
    
    # Extraire l'archive
    case "$source_path" in
        *.tar.gz|*.tgz)
            tar -xzf "$source_path" -C "$TEMP_DIR"
            ;;
        *.tar.bz2)
            tar -xjf "$source_path" -C "$TEMP_DIR"
            ;;
        *.zip)
            unzip -q "$source_path" -d "$TEMP_DIR"
            ;;
        *)
            log_error "Format d'archive non supporte: $source_path"
            exit 1
            ;;
    esac
    
    # Arreter le service s'il existe
    if systemctl is-active --quiet "$SYSTEMD_SERVICE" 2>/dev/null; then
        log_info "Arret du service: $SYSTEMD_SERVICE"
        sudo systemctl stop "$SYSTEMD_SERVICE"
    fi
    
    # Copier les nouveaux fichiers
    log_info "Installation des nouveaux fichiers"
    sudo rm -rf "$APP_DIR"/*
    sudo cp -r "$TEMP_DIR"/* "$APP_DIR/"
    
    # Definir les permissions
    sudo chown -R root:root "$APP_DIR"
    sudo chmod -R 755 "$APP_DIR"
    
    # Rendre les scripts executables
    find "$APP_DIR" -name "*.sh" -exec sudo chmod +x {} \;
    
    log_info "Deploiement des fichiers termine"
}

# Configuration du service systemd
configure_service() {
    local service_file="/etc/systemd/system/$SYSTEMD_SERVICE"
    
    if [ -f "$APP_DIR/systemd.service" ]; then
        log_info "Installation du service systemd"
        sudo cp "$APP_DIR/systemd.service" "$service_file"
        sudo systemctl daemon-reload
        sudo systemctl enable "$SYSTEMD_SERVICE"
    else
        log_warning "Fichier de service systemd non trouve"
    fi
}

# Tests post-deploiement
run_post_deploy_tests() {
    log_info "Execution des tests post-deploiement"
    
    # Demarrer le service
    if systemctl is-enabled --quiet "$SYSTEMD_SERVICE" 2>/dev/null; then
        log_info "Demarrage du service: $SYSTEMD_SERVICE"
        sudo systemctl start "$SYSTEMD_SERVICE"
        
        # Attendre le demarrage
        sleep 5
        
        # Verifier l'etat
        if systemctl is-active --quiet "$SYSTEMD_SERVICE"; then
            log_info "[OK] Service demarre avec succes"
        else
            log_error "[NOK] Echec du demarrage du service"
            sudo systemctl status "$SYSTEMD_SERVICE" --no-pager
            return 1
        fi
    fi
    
    # Tests applicatifs personnalises
    if [ -f "$APP_DIR/tests/health_check.sh" ]; then
        log_info "Execution des tests de sante"
        if sudo "$APP_DIR/tests/health_check.sh"; then
            log_info "[OK] Tests de sante reussis"
        else
            log_error "[NOK] Echec des tests de sante"
            return 1
        fi
    fi
    
    return 0
}

# Rollback en cas d'echec
rollback() {
    log_warning "Rollback en cours..."
    
    local latest_backup
    latest_backup=$(sudo find "$BACKUP_DIR" -maxdepth 1 -name "$APP_NAME-backup-*" -type d | sort -r | head -1)
    
    if [ -n "$latest_backup" ]; then
        log_info "Restauration depuis: $latest_backup"
        sudo rm -rf "$APP_DIR"/*
        sudo cp -r "$latest_backup"/* "$APP_DIR/"
        
        # Redemarrer le service
        if systemctl is-enabled --quiet "$SYSTEMD_SERVICE" 2>/dev/null; then
            sudo systemctl restart "$SYSTEMD_SERVICE"
        fi
        
        log_info "Rollback termine"
    else
        log_error "Aucune sauvegarde disponible pour le rollback"
    fi
}

# Fonction principale
main() {
    local source_archive="$1"
    
    log_info "=== Debut du deploiement de $APP_NAME ==="
    log_info "Archive source: $source_archive"
    log_info "Date: $(date)"
    
    # Processus de deploiement
    validate_environment
    backup_current_version
    deploy_application "$source_archive"
    configure_service
    
    # Tests et validation
    if run_post_deploy_tests; then
        log_info "[PARTY] Deploiement reussi!"
        log_info "=== Fin du deploiement ==="
        exit 0
    else
        log_error "Tests post-deploiement echoues"
        rollback
        log_error "[NOK] Deploiement echoue - Rollback effectue"
        exit 1
    fi
}

# Gestion des arguments
case "${1:-}" in
    ""|"--help"|"-h")
        cat << EOF
Usage: $0 <archive_path>

Deploie une application depuis une archive.

ARGUMENTS:
    archive_path    Chemin vers l'archive (.tar.gz, .tar.bz2, .zip)

EXEMPLES:
    $0 /path/to/app-v1.2.3.tar.gz
    $0 app-release.zip

Le script effectue:
1. Validation de l'environnement
2. Sauvegarde de la version actuelle
3. Deploiement de la nouvelle version
4. Configuration du service systemd
5. Tests post-deploiement
6. Rollback automatique en cas d'echec
EOF
        exit 0
        ;;
    *)
        if [ ! -f "$1" ]; then
            log_error "Archive non trouvee: $1"
            exit 1
        fi
        main "$1"
        ;;
esac
```

---

## Resume

### Structure de script bash
```bash
#!/bin/bash
set -euo pipefail          # Mode strict

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "$0")"

# Fonctions
function_name() {
    local param="$1"
    # Code de la fonction
    return 0
}

# Gestion des signaux
cleanup() {
    # Nettoyage
}
trap cleanup EXIT

# Code principal
main() {
    # Logique principale
}

# Point d'entree
main "$@"
```

### Variables et tableaux
```bash
# Variables simples
var="valeur"
readonly CONSTANTE="valeur"

# Tableaux
array=("a" "b" "c")
declare -A assoc_array
assoc_array[key]="value"

# Variables speciales
$0 $1 $2 ...   # Script et arguments
$@ $*          # Tous les arguments
$#             # Nombre d'arguments
$$             # PID du script
$?             # Code retour derniere commande
```

### Structures de controle
```bash
# Conditions
if [[ condition ]]; then
    # code
elif [[ autre_condition ]]; then
    # code
else
    # code
fi

# Boucles
for item in liste; do
    # code
done

while [[ condition ]]; do
    # code
done

# Case
case "$var" in
    pattern1) command1 ;;
    pattern2) command2 ;;
    *) default ;;
esac
```

### Fonctions utiles
```bash
# Logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >&2
}

# Validation
validate_file() {
    [[ -f "$1" && -r "$1" ]]
}

# Cleanup automatique
trap 'rm -f "$TEMP_FILE"' EXIT
```

### Bonnes pratiques
- **Mode strict** : `set -euo pipefail`
- **Validation d'entrees** : verifier arguments et fichiers
- **Gestion d'erreurs** : codes de retour et trap
- **Logging** : horodater et rediriger vers stderr
- **Documentation** : usage et exemples
- **Securite** : eviter l'injection de commandes
- **Portabilite** : tester sur differentes distributions

---

**Temps de lecture estime** : 40-45 minutes
**Niveau** : Intermediaire a avance
**Pre-requis** : Commandes de base bash, redirections, expressions regulieres