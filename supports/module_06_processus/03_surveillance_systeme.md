# Module 6.3 : Surveillance systeme

## Objectifs d'apprentissage
- Monitorer l'etat general du systeme avec uptime et load average
- Surveiller l'espace disque avec df et du
- Analyser l'utilisation memoire avec free et /proc/meminfo
- Comprendre les metriques systeme importantes
- Mettre en place une surveillance proactive

## Introduction

La **surveillance systeme** consiste a monitorer les ressources critiques (CPU, memoire, disque, reseau) pour maintenir les performances et prevenir les problemes. Linux fournit de nombreux outils integres pour cette surveillance.

---

## 1. Surveillance de la charge systeme

### Commande uptime - Etat general

#### Information fournie
```bash
# Executer uptime
uptime

# Sortie exemple :
# 15:30:42 up 5 days,  2:15,  3 users,  load average: 0.75, 0.60, 0.45
#    |        |         |       |              |      |     |
#    |        |         |       |              |      |     +- Charge moyenne 15 min
#    |        |         |       |              |      +- Charge moyenne 5 min  
#    |        |         |       |              +- Charge moyenne 1 min
#    |        |         |       +- Utilisateurs connectes
#    |        |         +- Duree depuis dernier redemarrage
#    +- Heure actuelle
```

### Comprendre la charge moyenne (load average)

#### Interpretation des valeurs
```bash
# Load average sur systeme 4 coeurs :
# 0.00-1.00  : Systeme tres peu charge
# 1.00-2.00  : Charge normale  
# 2.00-3.00  : Systeme charge mais acceptable
# 3.00-4.00  : Systeme tres charge (100% utilisation)
# > 4.00     : Surcharge (processus en attente)

# Regle generale :
# Load average <= nombre de CPU/coeurs = OK
# Load average > nombre de CPU/coeurs = surcharge potentielle
```

#### Verifier le nombre de coeurs
```bash
# Nombre de processeurs logiques
nproc

# Informations detaillees CPU
lscpu | grep "CPU(s)"
cat /proc/cpuinfo | grep processor | wc -l

# Information complete
lscpu
```

#### Surveiller la charge en temps reel
```bash
# Actualisation continue
watch uptime

# Actualisation personnalisee (toutes les 5 secondes)
watch -n 5 uptime

# Integrer dans un script
while true; do
    echo "$(date): $(uptime)"
    sleep 60
done
```

### Analyser les tendances de charge

#### Script d'analyse historique
```bash
#!/bin/bash
# load_analyzer.sh - Analyse des tendances de charge

LOG_FILE="/var/log/system_load.log"

# Enregistrer la charge periodiquement
log_load() {
    while true; do
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $(uptime)" >> "$LOG_FILE"
        sleep 300    # Toutes les 5 minutes
    done
}

# Analyser les pics de charge
analyze_load() {
    local threshold=2.0
    
    echo "=== ANALYSE DE CHARGE - Seuil: $threshold ==="
    grep -E "load average: [^,]*[3-9]\." "$LOG_FILE" | tail -20
    
    echo -e "\n=== RESUME ==="
    echo "Nombre d'incidents de charge elevee:"
    grep -c "load average: [^,]*[3-9]\." "$LOG_FILE"
    
    echo "Derniere charge elevee:"
    grep "load average: [^,]*[3-9]\." "$LOG_FILE" | tail -1
}

# Utilisation
case "$1" in
    "log")     log_load ;;
    "analyze") analyze_load ;;
    *)         echo "Usage: $0 {log|analyze}" ;;
esac
```

---

## 2. Surveillance de l'espace disque

### Commande df - Espace disque par systeme de fichiers

#### Utilisation de base
```bash
# Affichage standard
df

# Format lisible (human-readable)
df -h

# Affichage des inodes
df -i

# Systeme de fichiers specifique
df -h /var
df -h /home
```

#### Exemple d'analyse df
```bash
df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        20G  15G  4.2G  79%  /
# /dev/sda2       100G  45G   50G  48%  /home
# /dev/sdb1       500G 450G   25G  95%  /var/log
# tmpfs           2.0G     0  2.0G   0%  /tmp

# [WARN] Alertes :
# - /dev/sdb1 a 95% -> Critique
# - /dev/sda1 a 79% -> Surveillance renforcee
```

#### Options utiles de df
```bash
# Exclure certains types de systemes de fichiers
df -h -x tmpfs -x devtmpfs

# Afficher seulement les disques locaux
df -h -l

# Format de sortie personnalise
df --output=source,size,used,avail,pcent,target -h

# Trier par utilisation
df -h | sort -k 5 -nr
```

### Commande du - Utilisation detaillee des repertoires

#### Analyses de base
```bash
# Taille d'un repertoire
du -h /var/log

# Resume seulement (pas les sous-repertoires)
du -sh /var/log
du -sh /home/*

# Top 10 des plus gros repertoires
du -h /var | sort -hr | head -10

# Profondeur limitee
du -h --max-depth=2 /var
```

#### Analyse des gros consommateurs
```bash
# Script de recherche des gros fichiers
#!/bin/bash
# disk_usage_analysis.sh

echo "=== ANALYSE UTILISATION DISQUE ==="
echo

echo "Systemes de fichiers critiques (>90%) :"
df -h | awk 'NR>1 && $5+0 > 90 {print $5 " " $6 " (" $4 " libre)"}'
echo

echo "Top 10 repertoires dans /var :"
du -sh /var/* 2>/dev/null | sort -hr | head -10
echo

echo "Top 10 repertoires dans /home :"
du -sh /home/* 2>/dev/null | sort -hr | head -10
echo

echo "Fichiers volumineux (>100M) dans /tmp :"
find /tmp -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

#### Surveillance automatisee de l'espace
```bash
#!/bin/bash
# disk_monitor.sh - Surveillance automatique

THRESHOLD=85    # Seuil d'alerte en %
EMAIL="admin@domain.com"

check_disk_usage() {
    df -h | awk '
    NR>1 && $5+0 > '$THRESHOLD' {
        printf "ALERTE: %s sur %s utilise %s (libre: %s)\n", $5, $6, $3, $4
    }'
}

# Verifier et alerter
alerts=$(check_disk_usage)

if [ -n "$alerts" ]; then
    echo "$alerts" | tee /var/log/disk_alerts.log
    
    # Envoyer email (si configure)
    echo "$alerts" | mail -s "Alerte espace disque sur $(hostname)" "$EMAIL"
    
    # Log detaille pour analyse
    {
        echo "=== ALERTE DISQUE $(date) ==="
        echo "$alerts"
        echo
        echo "Etat complet des disques :"
        df -h
        echo
        echo "Top 10 gros repertoires /var :"
        du -sh /var/* 2>/dev/null | sort -hr | head -10
    } >> /var/log/disk_analysis.log
fi
```

---

## 3. Surveillance memoire

### Commande free - Etat de la memoire

#### Affichage de base
```bash
# Memoire en Ko (defaut)
free

# Format lisible  
free -h

# Actualisation continue (toutes les 2 secondes)
free -h -s 2

# Affichage detaille
free -h --wide
```

#### Comprendre la sortie de free
```bash
free -h
#               total        used        free      shared  buff/cache   available
# Mem:            8.0G        2.1G        1.2G        180M        4.7G        5.4G
# Swap:           2.0G        256M        1.7G

# Explication :
# - total     : RAM totale installee
# - used      : Memoire utilisee par les processus
# - free      : Memoire completement libre
# - shared    : Memoire partagee (tmpfs, SHM)
# - buff/cache: Buffers et cache disque
# - available : Memoire reellement disponible (free + recuperable du cache)
```

#### Metriques importantes
```bash
# Memoire vraiment disponible = available
# Si available < 10% de total -> Risque de swap intensif

# Utilisation swap elevee = Probleme potentiel
# Si swap used > 50% swap total -> Manque de RAM
```

### Analyse detaillee /proc/meminfo

#### Informations completes memoire
```bash
# Toutes les statistiques memoire
cat /proc/meminfo

# Metriques specifiques
grep -E "MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree" /proc/meminfo

# Format plus lisible
awk '/MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree/ {
    printf "%-15s: %8.2f GB\n", $1, $2/1024/1024
}' /proc/meminfo
```

#### Script d'analyse memoire
```bash
#!/bin/bash
# memory_analysis.sh

echo "=== ANALYSE MEMOIRE SYSTEME ==="
echo

# Resume general
echo "Resume memoire :"
free -h
echo

# Calculs avances
total_mem=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
available_mem=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
swap_used=$(awk '/SwapTotal/ {total=$2} /SwapFree/ {free=$2} END {print total-free}' /proc/meminfo)

mem_usage_pct=$((100 - available_mem * 100 / total_mem))
echo "Utilisation memoire: ${mem_usage_pct}%"

if [ $swap_used -gt 0 ]; then
    swap_usage_mb=$((swap_used / 1024))
    echo "[WARN]  Swap utilise: ${swap_usage_mb} MB"
fi

echo

# Processus gros consommateurs memoire
echo "Top 10 processus memoire :"
ps aux --sort=-%mem | head -11 | awk 'NR==1 || NR<=11 {printf "%-8s %6s %6s %s\n", $1, $4"%", $6"K", $11}'
```

### Surveillance swap

#### Analyser l'utilisation du swap
```bash
# Etat du swap
swapon --show

# Statistiques detaillees
cat /proc/swaps

# Surveiller l'activite swap
vmstat 1 5    # 5 mesures, 1 seconde d'intervalle
# si = swap in, so = swap out
# Valeurs elevees = activite swap intensive
```

#### Gerer le swap
```bash
# Desactiver temporairement swap (libere la RAM)
sudo swapoff -a

# Reactiver
sudo swapon -a

# Ajuster la tendance a utiliser le swap (0-100)
# 0 = utiliser swap seulement si necessaire
# 100 = utiliser swap agressivement
cat /proc/sys/vm/swappiness
echo 10 | sudo tee /proc/sys/vm/swappiness    # Temporaire

# Permanent dans /etc/sysctl.conf
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
```

---

## 4. Outils de surveillance integres

### Commande vmstat - Statistiques virtuelles

#### Surveillance generale
```bash
# Instantane actuel
vmstat

# Actualisation continue (intervalle de 2 secondes, 5 fois)
vmstat 2 5

# Mode detaille
vmstat -a    # Active/inactive memory
vmstat -s    # Statistiques depuis le boot
vmstat -d    # Statistiques disque
```

#### Interpreter vmstat
```bash
vmstat 1 5
# procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
#  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
#  1  0  51200 389234  62760 3045316    0    0     5    15   48   89  5  2 92  1  0

# Colonnes importantes :
# r  : processus en attente CPU
# b  : processus bloques I/O  
# swpd : swap utilise (Ko)
# si/so : swap in/out (Ko/s)
# bi/bo : blocs in/out (Ko/s) - activite disque
# us : % CPU utilisateur
# sy : % CPU systeme
# id : % CPU idle (inactif)
# wa : % CPU attente I/O
```

### Commande iostat - Statistiques I/O

#### Installation et utilisation
```bash
# Installation (package sysstat)
sudo apt install sysstat

# Statistiques I/O
iostat

# Actualisation continue
iostat 2 5    # Toutes les 2 secondes, 5 fois

# Format etendu (plus de details)
iostat -x

# Par peripherique specifique
iostat -x sda
```

#### Metriques I/O importantes
```bash
iostat -x 1 3
# Device            r/s     w/s     rkB/s     wkB/s   rrqm/s   wrqm/s  %util
# sda              5.23    2.45    104.56     89.23     0.12     1.45   12.5

# Colonnes cles :
# r/s, w/s : lectures/ecritures par seconde
# rkB/s, wkB/s : Ko lus/ecrits par seconde  
# %util : % d'utilisation du peripherique
# await : temps d'attente moyen (ms)

# Alertes si :
# - %util > 85% de facon continue
# - await > 20ms pour SSD, >50ms pour HDD
```

### Commande sar - System Activity Reporter

#### Collecter les donnees historiques
```bash
# Activer la collecte automatique
sudo systemctl enable sysstat
sudo systemctl start sysstat

# Voir l'activite du jour
sar

# Activite CPU par intervalles
sar -u 1 10    # Toutes les secondes, 10 fois

# Activite memoire
sar -r

# Activite reseau
sar -n DEV

# Activite disque
sar -d
```

#### Analyser les donnees historiques
```bash
# Donnees d'hier
sar -u -f /var/log/sysstat/saXX    # XX = jour du mois

# Pic d'activite entre 14h et 16h
sar -u -s 14:00:00 -e 16:00:00

# Rapport complet de la journee
sar -A > rapport_systeme_$(date +%Y%m%d).txt
```

---

## 5. Scripts de surveillance complete

### Tableau de bord systeme

```bash
#!/bin/bash
# system_dashboard.sh - Tableau de bord systeme

# Couleurs pour l'affichage
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Seuils d'alerte
CPU_THRESHOLD=80
MEM_THRESHOLD=85
DISK_THRESHOLD=90
LOAD_THRESHOLD=2.0

print_header() {
    clear
    echo "=================================="
    echo "   TABLEAU DE BORD SYSTEME"
    echo "   $(hostname) - $(date)"
    echo "=================================="
    echo
}

check_load() {
    echo "[LOADING] CHARGE SYSTEME:"
    local load1=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
    local cpu_count=$(nproc)
    local load_ratio=$(echo "$load1 / $cpu_count" | bc -l)
    
    printf "   Load Average: %s (%.2f par CPU)\n" "$(uptime | awk '{print $(NF-2), $(NF-1), $NF}')" "$load_ratio"
    
    if (( $(echo "$load_ratio > 1" | bc -l) )); then
        printf "   ${RED}[WARN]  Charge elevee detectee${NC}\n"
    else
        printf "   ${GREEN}[OK] Charge normale${NC}\n"
    fi
    echo
}

check_cpu() {
    echo " UTILISATION CPU:"
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    printf "   Utilisation: %s%%\n" "$cpu_usage"
    
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        printf "   ${RED}[WARN]  CPU surcharge${NC}\n"
        echo "   Top 3 processus CPU:"
        ps aux --sort=-%cpu | head -4 | tail -3 | awk '{printf "   - %-10s %6s%% %s\n", $1, $3, $11}'
    else
        printf "   ${GREEN}[OK] CPU OK${NC}\n"
    fi
    echo
}

check_memory() {
    echo " MEMOIRE:"
    local mem_info=$(free | grep Mem)
    local total=$(echo $mem_info | awk '{print $2}')
    local available=$(echo $mem_info | awk '{print $7}')
    local used_pct=$(echo "scale=1; (100 - $available * 100 / $total)" | bc)
    
    printf "   Utilisation: %.1f%%\n" "$used_pct"
    free -h | grep -E "Mem:|Swap:" | while read line; do
        echo "   $line"
    done
    
    if (( $(echo "$used_pct > $MEM_THRESHOLD" | bc -l) )); then
        printf "   ${RED}[WARN]  Memoire faible${NC}\n"
    else
        printf "   ${GREEN}[OK] Memoire OK${NC}\n"
    fi
    echo
}

check_disk() {
    echo " ESPACE DISQUE:"
    local critical=false
    
    df -h | grep -E "^/dev" | while read line; do
        local usage=$(echo $line | awk '{print $5}' | sed 's/%//')
        local mount=$(echo $line | awk '{print $6}')
        local used=$(echo $line | awk '{print $3}')
        local avail=$(echo $line | awk '{print $4}')
        
        printf "   %-15s %3s%% (libre: %s)\n" "$mount" "$usage" "$avail"
        
        if [ $usage -gt $DISK_THRESHOLD ]; then
            printf "   ${RED}[WARN]  Espace critique sur %s${NC}\n" "$mount"
            critical=true
        fi
    done
    
    if [ "$critical" != "true" ]; then
        printf "   ${GREEN}[OK] Espace disque OK${NC}\n"
    fi
    echo
}

check_services() {
    echo "[TOOL] SERVICES CRITIQUES:"
    local services=("ssh" "cron" "rsyslog")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service; then
            printf "   ${GREEN}[OK] %-10s: Actif${NC}\n" "$service"
        else
            printf "   ${RED}[NOK] %-10s: Inactif${NC}\n" "$service"
        fi
    done
    echo
}

check_network() {
    echo " RESEAU:"
    local interface=$(ip route | grep default | awk '{print $5}' | head -1)
    local ip=$(ip addr show $interface | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    
    printf "   Interface: %s (%s)\n" "$interface" "$ip"
    
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        printf "   ${GREEN}[OK] Connectivite Internet OK${NC}\n"
    else
        printf "   ${RED}[NOK] Pas de connectivite Internet${NC}\n"
    fi
    echo
}

# Fonction principale
main() {
    print_header
    check_load
    check_cpu
    check_memory
    check_disk
    check_services
    check_network
    
    echo "Derniere mise a jour: $(date)"
    echo "Actualisation automatique dans 30 secondes..."
}

# Mode continu
if [ "$1" = "watch" ]; then
    while true; do
        main
        sleep 30
    done
else
    main
fi
```

### Systeme d'alertes automatise

```bash
#!/bin/bash
# alert_system.sh - Systeme d'alertes proactif

CONFIG_FILE="/etc/system-alerts.conf"
LOG_FILE="/var/log/system-alerts.log"
LOCK_FILE="/var/run/system-alerts.lock"

# Configuration par defaut
CPU_THRESHOLD=85
MEM_THRESHOLD=90
DISK_THRESHOLD=95
LOAD_THRESHOLD=3.0
EMAIL_ALERT=true
ADMIN_EMAIL="admin@domain.com"

# Charger configuration personnalisee
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

# Fonction de logging
log_alert() {
    local level="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" | tee -a "$LOG_FILE"
}

# Eviter les executions multiples
if [ -f "$LOCK_FILE" ]; then
    exit 1
fi
trap "rm -f $LOCK_FILE" EXIT
touch "$LOCK_FILE"

# Verifications systeme
check_system() {
    local alerts=()
    
    # CPU
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' | cut -d% -f1)
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        alerts+=("CPU: ${cpu_usage}% (seuil: ${CPU_THRESHOLD}%)")
    fi
    
    # Memoire
    local mem_usage=$(free | awk 'NR==2{printf "%.1f", (($3+$5)*100/$2)}')
    if (( $(echo "$mem_usage > $MEM_THRESHOLD" | bc -l) )); then
        alerts+=("Memoire: ${mem_usage}% (seuil: ${MEM_THRESHOLD}%)")
    fi
    
    # Disque
    df -h | grep -E "^/dev" | while read filesystem size used avail percent mount; do
        local usage=$(echo $percent | sed 's/%//')
        if [ $usage -gt $DISK_THRESHOLD ]; then
            alerts+=("Disque $mount: ${usage}% (seuil: ${DISK_THRESHOLD}%)")
        fi
    done
    
    # Charge systeme
    local load1=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
    if (( $(echo "$load1 > $LOAD_THRESHOLD" | bc -l) )); then
        alerts+=("Charge: $load1 (seuil: $LOAD_THRESHOLD)")
    fi
    
    # Traiter les alertes
    if [ ${#alerts[@]} -gt 0 ]; then
        local alert_message="ALERTES SYSTEME sur $(hostname):\n"
        for alert in "${alerts[@]}"; do
            alert_message+="\n- $alert"
        done
        
        log_alert "CRITICAL" "Alertes systeme detectees"
        
        if [ "$EMAIL_ALERT" = true ]; then
            echo -e "$alert_message" | mail -s "Alerte systeme $(hostname)" "$ADMIN_EMAIL"
        fi
        
        # Actions automatiques
        auto_remediation
    fi
}

# Actions de remediation automatique
auto_remediation() {
    log_alert "INFO" "Tentatives de remediation automatique"
    
    # Nettoyer les logs anciens
    find /var/log -name "*.log" -mtime +30 -exec rm {} \;
    
    # Nettoyer le cache systeme
    sync && echo 3 > /proc/sys/vm/drop_caches
    
    # Redemarrer services non-critiques surcharges
    # (a adapter selon votre environnement)
    
    log_alert "INFO" "Actions de remediation terminees"
}

# Execution principale
check_system
```

---

## Resume

### Commandes essentielles de surveillance
```bash
uptime              # Charge systeme et duree de fonctionnement
free -h             # Etat memoire et swap
df -h               # Espace disque par systeme de fichiers
du -sh /path        # Utilisation d'un repertoire specifique
vmstat 1 5          # Statistiques systeme (CPU, memoire, I/O)
iostat -x           # Statistiques detaillees I/O disque
top                 # Surveillance temps reel processus
htop                # Version amelioree de top
```

### Metriques critiques a surveiller

#### Load Average
- **Ideal** : <= nombre de CPU/coeurs
- **Acceptable** : jusqu'a 2x le nombre de CPU
- **Critique** : > 3x le nombre de CPU

#### Memoire
- **RAM disponible** : > 20% du total
- **Utilisation swap** : < 25% du total
- **Cache/Buffers** : recuperable automatiquement

#### Espace disque
- **Seuil attention** : 80% utilise
- **Seuil critique** : 90% utilise
- **Surveillance inodes** : `df -i`

#### CPU et I/O
- **CPU idle** : > 20% en moyenne
- **I/O wait** : < 10% en moyenne
- **Utilisation disque** : < 85%

### Scripts de surveillance recommandes
1. **Monitoring temps reel** : tableau de bord actualise
2. **Alertes proactives** : seuils configurables
3. **Collecte historique** : tendances et analyses
4. **Actions automatiques** : remediation basique
5. **Rapports periodiques** : syntheses hebdomadaires/mensuelles

### Bonnes pratiques
- **Surveillance continue** : ne pas attendre les problemes
- **Seuils adaptes** : ajuster selon l'usage reel
- **Historique** : conserver les donnees pour analyse
- **Documentation** : noter les valeurs normales
- **Tests** : valider les alertes et actions automatiques
- **Monitoring externe** : ne pas dependre que du systeme surveille

---

**Temps de lecture estime** : 25-30 minutes
**Niveau** : Intermediaire
**Pre-requis** : Modules precedents, notions de systeme de fichiers