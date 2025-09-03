# TP 7.1 : Reseaux, services et logs systeme

## Objectifs
- Diagnostiquer et configurer la connectivite reseau
- Transferer des fichiers avec scp et rsync
- Gerer les services systeme avec systemctl
- Analyser les logs systeme et detecter les problemes
- Creer un environnement de surveillance complet

## Pre-requis
- Acces a un systeme Linux avec droits sudo
- Connexion reseau fonctionnelle
- Connaissances des modules precedents

## Duree estimee
- **Public accelere** : 120 minutes  
- **Public etale** : 180 minutes

---

## Partie A : Diagnostic et configuration reseau

### Exercice 1 : Exploration de la configuration reseau

#### Etape 1 : Inventaire de la configuration actuelle
```bash
# Creer un repertoire de travail
mkdir ~/tp_reseaux
cd ~/tp_reseaux

# Identifier les interfaces reseau
ip link show
ip -br link show

# Voir les adresses IP
ip addr show
ip -br addr show

# Table de routage
ip route show
ip route show default

# Creer un rapport de configuration
cat > config_reseau_initial.txt << EOF
=== CONFIGURATION RESEAU INITIALE ===
Date: $(date)

Interfaces reseau:
$(ip -br link show)

Adresses IP:
$(ip -br addr show)

Route par defaut:
$(ip route show default)

Serveurs DNS:
$(cat /etc/resolv.conf | grep nameserver)
EOF

cat config_reseau_initial.txt
```

**Questions d'analyse** :
- Combien d'interfaces reseau avez-vous ?
- Quelle est votre adresse IP principale ?
- Quelle est votre passerelle par defaut ?

#### Etape 2 : Tests de connectivite de base
```bash
# Test loopback
ping -c 3 127.0.0.1

# Test passerelle (si configuree)
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
if [ -n "$GATEWAY" ]; then
    echo "Test de la passerelle: $GATEWAY"
    ping -c 3 $GATEWAY
else
    echo "Aucune passerelle configuree"
fi

# Test DNS externe
ping -c 3 8.8.8.8

# Test resolution DNS
ping -c 3 google.com

# Test connectivite web
curl -I --connect-timeout 5 http://google.com
```

### Exercice 2 : Diagnostic approfondi avec outils reseau

#### Etape 1 : Analyse avec traceroute et outils avances
```bash
# Installation des outils de diagnostic
sudo apt update
sudo apt install -y traceroute netstat-nat dnsutils

# Tracer le chemin vers google.com
echo "Traceroute vers google.com:"
traceroute -I google.com | head -10

# Analyser les ports ouverts
echo -e "\nPorts TCP en ecoute:"
ss -tln

echo -e "\nPorts UDP en ecoute:"
ss -uln

# Test de resolution DNS
echo -e "\nTest DNS avec dig:"
dig google.com A +short
dig google.com MX +short
```

#### Etape 2 : Script de diagnostic automatise
```bash
# Creer un script de diagnostic reseau
cat > diagnostic_reseau.sh << 'EOF'
#!/bin/bash

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== DIAGNOSTIC RESEAU AUTOMATISE ==="
echo "Date: $(date)"
echo

# Test de connectivite
test_connectivity() {
    local host="$1"
    local name="$2"
    
    if ping -c 1 -W 2 "$host" > /dev/null 2>&1; then
        echo -e "[OK] $name ($host): ${GREEN}OK${NC}"
        return 0
    else
        echo -e "[NOK] $name ($host): ${RED}ECHEC${NC}"
        return 1
    fi
}

# Tests de connectivite
echo " TESTS DE CONNECTIVITE:"
test_connectivity "127.0.0.1" "Loopback"

GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
if [ -n "$GATEWAY" ]; then
    test_connectivity "$GATEWAY" "Passerelle"
else
    echo -e "[NOK] Passerelle: ${YELLOW}NON CONFIGUREE${NC}"
fi

test_connectivity "8.8.8.8" "DNS Google"
test_connectivity "1.1.1.1" "DNS Cloudflare"

# Test resolution DNS
echo -e "\n TESTS DNS:"
if nslookup google.com > /dev/null 2>&1; then
    echo -e "[OK] Resolution DNS: ${GREEN}OK${NC}"
else
    echo -e "[NOK] Resolution DNS: ${RED}ECHEC${NC}"
fi

# Test HTTP
echo -e "\n TESTS WEB:"
if curl -s -I --connect-timeout 5 http://google.com | grep -q "HTTP"; then
    echo -e "[OK] Connectivite HTTP: ${GREEN}OK${NC}"
else
    echo -e "[NOK] Connectivite HTTP: ${RED}ECHEC${NC}"
fi

# Informations systeme
echo -e "\n INFORMATIONS RESEAU:"
echo "Interface principale: $(ip route | grep default | awk '{print $5}' | head -1)"
echo "Adresse IP: $(ip route get 8.8.8.8 2>/dev/null | grep src | awk '{print $7}' | head -1)"
echo "DNS configures: $(cat /etc/resolv.conf | grep nameserver | wc -l)"

echo -e "\n=== FIN DIAGNOSTIC ==="
EOF

chmod +x diagnostic_reseau.sh
./diagnostic_reseau.sh
```

---

## Partie B : Transferts de fichiers

### Exercice 3 : Maitrise de scp

#### Etape 1 : Preparation des fichiers de test
```bash
# Creer des fichiers de test de differentes tailles
echo "Fichier de test simple" > petit_fichier.txt

# Fichier moyen (environ 1MB)
dd if=/dev/zero of=fichier_moyen.dat bs=1024 count=1024

# Creer une structure de repertoires
mkdir -p projet/{src,docs,config}
echo "print('Hello World')" > projet/src/main.py
echo "# Documentation du projet" > projet/docs/README.md
echo "debug=true" > projet/config/settings.ini

# Afficher ce qui a ete cree
ls -lah
tree projet/ 2>/dev/null || find projet/ -type f
```

#### Etape 2 : Tests de transfert scp (simulation locale)
```bash
# Note: Pour cet exercice, nous simulons des transferts avec localhost
# Dans un vrai environnement, remplacez localhost par l'IP du serveur distant

# Test de transfert simple (necessite SSH configure)
echo "Test de transfert avec scp vers localhost..."

# Creer repertoire de destination
mkdir -p ~/transferts_test

# Test 1: Fichier simple
if command -v ssh >/dev/null && ssh -o ConnectTimeout=2 localhost exit 2>/dev/null; then
    echo "[OK] SSH disponible, test avec localhost"
    scp petit_fichier.txt localhost:~/transferts_test/
    scp localhost:~/transferts_test/petit_fichier.txt petit_fichier_retour.txt
    echo "Transfer reussi, verification:"
    diff petit_fichier.txt petit_fichier_retour.txt && echo "Fichiers identiques"
else
    echo "[INFO]  SSH non configure pour localhost, simulation..."
    cp petit_fichier.txt ~/transferts_test/
    cp ~/transferts_test/petit_fichier.txt petit_fichier_retour.txt
    echo "Simulation de transfert terminee"
fi

# Test 2: Repertoire complet  
echo -e "\nTest transfert de repertoire:"
# scp -r projet localhost:~/transferts_test/ (si SSH disponible)
cp -r projet ~/transferts_test/    # Simulation
echo "Verification du transfert de repertoire:"
ls -la ~/transferts_test/projet/
```

### Exercice 4 : Synchronisation avec rsync

#### Etape 1 : Synchronisation locale avec rsync
```bash
# Creer des donnees de test pour rsync
mkdir -p source_rsync destination_rsync

# Creer plusieurs fichiers dans la source
for i in {1..5}; do
    echo "Contenu du fichier $i - $(date)" > source_rsync/file$i.txt
done

mkdir source_rsync/subdir
echo "Fichier dans sous-repertoire" > source_rsync/subdir/nested.txt

echo "Contenu initial de la source:"
find source_rsync -type f -exec ls -la {} \;
```

#### Etape 2 : Tests de synchronisation
```bash
# Test 1: Synchronisation initiale
echo -e "\n=== TEST 1: Synchronisation initiale ==="
rsync -avzP --dry-run source_rsync/ destination_rsync/
echo "Dry-run termine, synchronisation reelle:"
rsync -avzP source_rsync/ destination_rsync/

echo "Verification destination:"
find destination_rsync -type f | wc -l

# Test 2: Synchronisation incrementale
echo -e "\n=== TEST 2: Synchronisation incrementale ==="
# Modifier un fichier existant
echo "Ligne ajoutee - $(date)" >> source_rsync/file1.txt
# Ajouter un nouveau fichier
echo "Nouveau fichier" > source_rsync/file6.txt
# Supprimer un fichier
rm source_rsync/file5.txt

echo "Changements dans la source:"
rsync -avzP --dry-run --delete source_rsync/ destination_rsync/
echo "Synchronisation des changements:"
rsync -avzP --delete source_rsync/ destination_rsync/

# Test 3: Synchronisation avec exclusions
echo -e "\n=== TEST 3: Synchronisation avec exclusions ==="
# Creer des fichiers a exclure
touch source_rsync/temp.tmp
touch source_rsync/backup.bak
mkdir source_rsync/cache
echo "fichier cache" > source_rsync/cache/data.cache

echo "Synchronisation avec exclusions:"
rsync -avzP \
  --exclude='*.tmp' \
  --exclude='*.bak' \
  --exclude='cache/' \
  source_rsync/ destination_rsync/

echo "Verification - les fichiers exclus ne doivent pas etre presents:"
find destination_rsync -name "*.tmp" -o -name "*.bak" -o -name "cache"
```

#### Etape 3 : Script de sauvegarde avec rsync
```bash
# Creer un script de sauvegarde
cat > backup_script.sh << 'EOF'
#!/bin/bash

# Configuration
SOURCE_DIR="$HOME/documents"  # Repertoire a sauvegarder
BACKUP_DIR="$HOME/backups"    # Repertoire de sauvegarde
LOG_FILE="$HOME/backup.log"   # Fichier de log

# Creer les repertoires s'ils n'existent pas
mkdir -p "$SOURCE_DIR" "$BACKUP_DIR"

# Fonction de logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Fonction de sauvegarde
perform_backup() {
    log_message "Debut de la sauvegarde"
    log_message "Source: $SOURCE_DIR"
    log_message "Destination: $BACKUP_DIR"
    
    # Creer quelques fichiers de test s'ils n'existent pas
    if [ ! -f "$SOURCE_DIR/document1.txt" ]; then
        echo "Document de test 1" > "$SOURCE_DIR/document1.txt"
        echo "Document de test 2" > "$SOURCE_DIR/document2.txt"
        mkdir -p "$SOURCE_DIR/projet"
        echo "Fichier projet" > "$SOURCE_DIR/projet/code.py"
    fi
    
    # Sauvegarde avec rsync
    if rsync -avz \
        --delete \
        --exclude='*.tmp' \
        --exclude='.cache/' \
        --log-file="$LOG_FILE.rsync" \
        "$SOURCE_DIR/" \
        "$BACKUP_DIR/"; then
        
        log_message "Sauvegarde reussie"
        
        # Statistiques
        local file_count=$(find "$BACKUP_DIR" -type f | wc -l)
        local backup_size=$(du -sh "$BACKUP_DIR" | cut -f1)
        log_message "Fichiers sauvegardes: $file_count"
        log_message "Taille totale: $backup_size"
    else
        log_message "ERREUR: Echec de la sauvegarde"
        return 1
    fi
}

# Execution
perform_backup
EOF

chmod +x backup_script.sh
./backup_script.sh

# Verifier le resultat
echo -e "\n=== RESULTAT DE LA SAUVEGARDE ==="
cat ~/backup.log | tail -10
echo -e "\nContenu sauvegarde:"
find ~/backups -type f | head -10
```

---

## Partie C : Gestion des services systeme

### Exercice 5 : Exploration des services avec systemctl

#### Etape 1 : Analyse des services existants
```bash
echo "=== ANALYSE DES SERVICES SYSTEME ==="

# Services actifs
echo "Services actifs:"
systemctl list-units --type=service --state=active | head -10

# Services en echec
echo -e "\nServices en echec:"
systemctl list-units --type=service --state=failed

# Services actives au demarrage
echo -e "\nServices actives au demarrage (premiers 10):"
systemctl list-unit-files --type=service --state=enabled | head -10

# Creer un rapport des services
cat > rapport_services.txt << EOF
=== RAPPORT SERVICES SYSTEME ===
Date: $(date)

Services actifs: $(systemctl list-units --type=service --state=active --no-legend | wc -l)
Services en echec: $(systemctl list-units --type=service --state=failed --no-legend | wc -l)
Services actives: $(systemctl list-unit-files --type=service --state=enabled --no-legend | wc -l)

Services critiques:
EOF

# Verifier quelques services critiques
for service in ssh cron rsyslog; do
    if systemctl is-active --quiet $service; then
        echo "[OK] $service: actif" >> rapport_services.txt
    else
        echo "[NOK] $service: inactif" >> rapport_services.txt
    fi
done

cat rapport_services.txt
```

#### Etape 2 : Gestion d'un service de test
```bash
# Creer un service simple pour les tests
sudo mkdir -p /opt/test-service

# Script du service
sudo tee /opt/test-service/service.py > /dev/null << 'EOF'
#!/usr/bin/env python3
import time
import sys
from datetime import datetime

def main():
    print("Service de test demarre")
    sys.stdout.flush()
    
    try:
        while True:
            print(f"Heartbeat: {datetime.now()}")
            sys.stdout.flush()
            time.sleep(30)
    except KeyboardInterrupt:
        print("Arret du service")
        sys.exit(0)

if __name__ == "__main__":
    main()
EOF

sudo chmod +x /opt/test-service/service.py

# Fichier de service systemd
sudo tee /etc/systemd/system/test-service.service > /dev/null << 'EOF'
[Unit]
Description=Service de test pour formation
After=network.target

[Service]
Type=simple
User=nobody
WorkingDirectory=/opt/test-service
ExecStart=/usr/bin/python3 /opt/test-service/service.py
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Recharger systemd
sudo systemctl daemon-reload

echo "Service de test cree et configure"
```

#### Etape 3 : Tests de gestion du service
```bash
echo "=== TESTS DE GESTION DU SERVICE ==="

# Test 1: Activation et demarrage
echo "1. Activation du service:"
sudo systemctl enable test-service
systemctl is-enabled test-service

echo -e "\n2. Demarrage du service:"
sudo systemctl start test-service
sleep 3
systemctl is-active test-service

# Test 2: Verification etat detaille
echo -e "\n3. Etat detaille:"
systemctl status test-service --no-pager

# Test 3: Consultation des logs
echo -e "\n4. Logs du service (5 dernieres lignes):"
journalctl -u test-service -n 5 --no-pager

# Test 4: Redemarrage
echo -e "\n5. Test redemarrage:"
sudo systemctl restart test-service
sleep 2
systemctl is-active test-service

# Test 5: Arret et desactivation
echo -e "\n6. Arret du service:"
sudo systemctl stop test-service
systemctl is-active test-service

echo -e "\n7. Desactivation:"
sudo systemctl disable test-service
systemctl is-enabled test-service

echo -e "\nTests de gestion termines"
```

### Exercice 6 : Creation d'un service personnalise

#### Etape 1 : Service de surveillance systeme
```bash
# Creer un script de surveillance
sudo mkdir -p /opt/system-monitor

sudo tee /opt/system-monitor/monitor.py > /dev/null << 'EOF'
#!/usr/bin/env python3
import time
import subprocess
import json
from datetime import datetime

def get_system_stats():
    stats = {}
    
    # Charge systeme
    with open('/proc/loadavg', 'r') as f:
        load = f.read().split()
        stats['load_1min'] = float(load[0])
    
    # Utilisation memoire
    with open('/proc/meminfo', 'r') as f:
        meminfo = {}
        for line in f:
            key, value = line.split(':')
            meminfo[key] = int(value.split()[0])
        
        total_mem = meminfo['MemTotal']
        available_mem = meminfo['MemAvailable']
        stats['memory_usage_pct'] = (total_mem - available_mem) / total_mem * 100
    
    # Espace disque /
    result = subprocess.run(['df', '/', '--output=pcent'], 
                          capture_output=True, text=True)
    if result.returncode == 0:
        disk_pct = result.stdout.split('\n')[1].strip().rstrip('%')
        stats['disk_usage_pct'] = float(disk_pct)
    
    return stats

def main():
    print("Demarrage du moniteur systeme")
    
    while True:
        try:
            stats = get_system_stats()
            timestamp = datetime.now().isoformat()
            
            log_entry = {
                'timestamp': timestamp,
                'stats': stats
            }
            
            # Log en JSON pour faciliter l'analyse
            print(json.dumps(log_entry))
            
            # Alertes simples
            if stats['load_1min'] > 2.0:
                print(f"ALERTE: Charge elevee: {stats['load_1min']}")
            
            if stats['memory_usage_pct'] > 80:
                print(f"ALERTE: Memoire elevee: {stats['memory_usage_pct']:.1f}%")
            
            if stats['disk_usage_pct'] > 85:
                print(f"ALERTE: Disque plein: {stats['disk_usage_pct']:.1f}%")
            
            time.sleep(60)  # Verification chaque minute
            
        except Exception as e:
            print(f"Erreur: {e}")
            time.sleep(10)

if __name__ == "__main__":
    main()
EOF

sudo chmod +x /opt/system-monitor/monitor.py

# Service systemd pour le moniteur
sudo tee /etc/systemd/system/system-monitor.service > /dev/null << 'EOF'
[Unit]
Description=Moniteur systeme personnalise
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
WorkingDirectory=/opt/system-monitor
ExecStart=/usr/bin/python3 /opt/system-monitor/monitor.py
Restart=always
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

echo "Service de monitoring systeme cree"
```

#### Etape 2 : Test du service de monitoring
```bash
echo "=== TEST DU SERVICE DE MONITORING ==="

# Demarrer le service
sudo systemctl start system-monitor
sleep 3

# Verifier qu'il fonctionne
systemctl status system-monitor --no-pager

# Observer les logs en temps reel (quelques secondes)
echo -e "\nLogs du service (10 dernieres secondes):"
timeout 10 journalctl -u system-monitor -f --no-pager || true

# Statistiques du service
echo -e "\nStatistiques du service:"
journalctl -u system-monitor --since "1 minute ago" --no-pager | tail -5

# Arreter le service
sudo systemctl stop system-monitor

echo -e "\nTest du service de monitoring termine"
```

---

## Partie D : Analyse des logs systeme

### Exercice 7 : Exploration des logs avec journalctl

#### Etape 1 : Navigation de base dans les logs
```bash
echo "=== EXPLORATION DES LOGS SYSTEME ==="

# Informations generales sur le journal
echo "Utilisation de l'espace par les logs:"
journalctl --disk-usage

# Logs depuis le dernier boot
echo -e "\nMessages depuis le dernier demarrage (10 derniers):"
journalctl -b --no-pager | tail -10

# Logs d'erreur recents
echo -e "\nErreurs recentes:"
journalctl -p err --since "24 hours ago" --no-pager | head -10

# Logs des services systeme importants
echo -e "\nDernieres activites SSH:"
journalctl -u ssh --no-pager | tail -5 2>/dev/null || echo "Service SSH non trouve"

echo -e "\nDernieres activites cron:"
journalctl -u cron --no-pager | tail -5 2>/dev/null || echo "Service cron non trouve"
```

#### Etape 2 : Analyse detaillee avec filtres
```bash
# Creer un script d'analyse des logs
cat > analyze_logs.sh << 'EOF'
#!/bin/bash

echo "=== ANALYSE AVANCEE DES LOGS ==="
echo "Date: $(date)"
echo

# Fonction pour afficher section
print_section() {
    echo "===================="
    echo "$1"
    echo "===================="
}

# 1. Erreurs systeme recentes
print_section "ERREURS SYSTEME (24H)"
error_count=$(journalctl -p err --since "24 hours ago" --no-pager -q | wc -l)
echo "Nombre d'erreurs: $error_count"

if [ $error_count -gt 0 ]; then
    echo "Dernieres erreurs:"
    journalctl -p err --since "24 hours ago" --no-pager -q | tail -5
else
    echo "[OK] Aucune erreur recente"
fi
echo

# 2. Authentifications
print_section "AUTHENTIFICATIONS SSH"
if journalctl -u ssh --since "24 hours ago" --no-pager -q > /dev/null 2>&1; then
    auth_success=$(journalctl --since "24 hours ago" --no-pager -q | grep -c "Accepted password" || echo "0")
    auth_failed=$(journalctl --since "24 hours ago" --no-pager -q | grep -c "Failed password" || echo "0")
    
    echo "Connexions reussies (24h): $auth_success"
    echo "Tentatives echouees (24h): $auth_failed"
    
    if [ $auth_failed -gt 0 ]; then
        echo "[WARN] Dernieres tentatives echouees:"
        journalctl --since "24 hours ago" --no-pager -q | grep "Failed password" | tail -3
    fi
else
    echo "Service SSH non surveille par systemd"
fi
echo

# 3. Services en echec
print_section "SERVICES EN ECHEC"
failed_services=$(systemctl list-units --type=service --state=failed --no-legend --no-pager | wc -l)
echo "Services en echec: $failed_services"

if [ $failed_services -gt 0 ]; then
    echo "Services concernes:"
    systemctl list-units --type=service --state=failed --no-legend --no-pager
fi
echo

# 4. Activite systeme
print_section "ACTIVITE SYSTEME"
boot_time=$(journalctl --list-boots --no-pager | tail -1 | awk '{print $3, $4}')
echo "Dernier demarrage: $boot_time"

# Messages importants recents
important_count=$(journalctl -p warning --since "24 hours ago" --no-pager -q | wc -l)
echo "Messages importants (warnings+) 24h: $important_count"

if [ $important_count -gt 0 ] && [ $important_count -lt 20 ]; then
    echo "Messages recents:"
    journalctl -p warning --since "24 hours ago" --no-pager -q | tail -3
fi

echo
echo "=== FIN ANALYSE ==="
EOF

chmod +x analyze_logs.sh
./analyze_logs.sh
```

### Exercice 8 : Surveillance et alertes automatisees

#### Etape 1 : Script de surveillance des logs
```bash
# Creer un script de surveillance proactive
cat > log_monitor.sh << 'EOF'
#!/bin/bash

# Configuration
ALERT_FILE="/tmp/log_alerts.txt"
LOG_FILE="/tmp/log_monitor.log"
CHECK_PERIOD_HOURS=1

# Fonction de logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Initialiser fichier d'alertes
> "$ALERT_FILE"

log_message "Debut de la surveillance des logs"

# 1. Verifier erreurs critiques recentes
check_critical_errors() {
    local errors=$(journalctl -p crit --since "${CHECK_PERIOD_HOURS} hours ago" --no-pager -q | wc -l)
    
    if [ $errors -gt 0 ]; then
        log_message "ALERTE: $errors erreurs critiques detectees"
        echo "ERREURS CRITIQUES: $errors" >> "$ALERT_FILE"
        journalctl -p crit --since "${CHECK_PERIOD_HOURS} hours ago" --no-pager -q | tail -3 >> "$ALERT_FILE"
        echo "---" >> "$ALERT_FILE"
        return 1
    fi
    
    return 0
}

# 2. Verifier echecs d'authentification
check_auth_failures() {
    local failed_auths=$(journalctl --since "${CHECK_PERIOD_HOURS} hours ago" --no-pager -q | grep -c "Failed password" || echo "0")
    
    if [ $failed_auths -gt 10 ]; then  # Plus de 10 echecs = suspect
        log_message "ALERTE: $failed_auths tentatives d'authentification echouees"
        echo "AUTHENTIFICATION: $failed_auths echecs" >> "$ALERT_FILE"
        journalctl --since "${CHECK_PERIOD_HOURS} hours ago" --no-pager -q | grep "Failed password" | tail -5 >> "$ALERT_FILE"
        echo "---" >> "$ALERT_FILE"
        return 1
    fi
    
    return 0
}

# 3. Verifier services en echec
check_failed_services() {
    local failed_services=$(systemctl list-units --type=service --state=failed --no-legend --no-pager)
    
    if [ -n "$failed_services" ]; then
        log_message "ALERTE: Services en echec detectes"
        echo "SERVICES EN ECHEC:" >> "$ALERT_FILE"
        echo "$failed_services" >> "$ALERT_FILE"
        echo "---" >> "$ALERT_FILE"
        return 1
    fi
    
    return 0
}

# 4. Verifier espace disque via logs
check_disk_warnings() {
    local disk_warnings=$(journalctl --since "${CHECK_PERIOD_HOURS} hours ago" --no-pager -q | grep -i "no space left\|disk full\|filesystem.*full" | wc -l)
    
    if [ $disk_warnings -gt 0 ]; then
        log_message "ALERTE: $disk_warnings avertissements d'espace disque"
        echo "ESPACE DISQUE: $disk_warnings avertissements" >> "$ALERT_FILE"
        journalctl --since "${CHECK_PERIOD_HOURS} hours ago" --no-pager -q | grep -i "no space left\|disk full\|filesystem.*full" | tail -3 >> "$ALERT_FILE"
        echo "---" >> "$ALERT_FILE"
        return 1
    fi
    
    return 0
}

# Executer toutes les verifications
alerts=0

check_critical_errors || ((alerts++))
check_auth_failures || ((alerts++))
check_failed_services || ((alerts++))
check_disk_warnings || ((alerts++))

# Resume
if [ $alerts -gt 0 ]; then
    log_message "$alerts types d'alertes detectees"
    echo
    echo "=== ALERTES DETECTEES ==="
    cat "$ALERT_FILE"
    echo "========================="
    
    # Simuler envoi d'alerte (remplacer par vraie commande mail)
    echo "Alertes systeme sur $(hostname) - $(date)" > /tmp/alert_email.txt
    cat "$ALERT_FILE" >> /tmp/alert_email.txt
    log_message "Alerte sauvegardee dans /tmp/alert_email.txt"
else
    log_message "Aucune alerte detectee"
    echo "[OK] Surveillance OK - Aucune alerte"
fi

log_message "Fin de la surveillance"
EOF

chmod +x log_monitor.sh
./log_monitor.sh
```

#### Etape 2 : Configuration pour surveillance continue
```bash
# Script de surveillance en boucle (pour demonstration)
cat > continuous_monitor.sh << 'EOF'
#!/bin/bash

INTERVAL=300  # 5 minutes
LOG_FILE="/tmp/continuous_monitor.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

log_message "Demarrage de la surveillance continue (intervalle: ${INTERVAL}s)"

# Fonction de nettoyage
cleanup() {
    log_message "Arret de la surveillance"
    exit 0
}

trap cleanup INT TERM

# Boucle de surveillance
while true; do
    log_message "Execution du controle de surveillance"
    ./log_monitor.sh >> "$LOG_FILE" 2>&1
    
    log_message "Prochain controle dans ${INTERVAL} secondes"
    sleep $INTERVAL
done
EOF

chmod +x continuous_monitor.sh

# Tester la surveillance (30 secondes seulement)
echo "Test de surveillance continue (30 secondes)..."
timeout 30 ./continuous_monitor.sh || true

echo -e "\nLogs de surveillance:"
tail -10 /tmp/continuous_monitor.log 2>/dev/null || echo "Aucun log genere"
```

---

## Partie E : Projet integre - Centre de controle systeme

### Exercice 9 : Tableau de bord unifie

#### Etape 1 : Script de tableau de bord complet
```bash
cat > system_dashboard.sh << 'EOF'
#!/bin/bash

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REFRESH_INTERVAL=30
ALERT_THRESHOLDS="load:2.0,memory:80,disk:85"

print_header() {
    clear
    echo -e "${BLUE}????????????????????????????????????????????????????"
    echo -e "?           CENTRE DE CONTROLE SYSTEME            ?"
    echo -e "?              $(hostname) - $(date '+%H:%M:%S')              ?"
    echo -e "????????????????????????????????????????????????????${NC}"
    echo
}

# 1. Etat reseau
check_network() {
    echo -e "${CYAN} ETAT RESEAU${NC}"
    
    # Interface principale
    local main_if=$(ip route | grep default | awk '{print $5}' | head -1)
    local main_ip=$(ip addr show $main_if 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -1)
    echo "  Interface: $main_if ($main_ip)"
    
    # Tests de connectivite
    local connectivity=""
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        connectivity="${GREEN}[OK] Internet OK${NC}"
    else
        connectivity="${RED}[NOK] Internet KO${NC}"
    fi
    echo -e "  Connectivite: $connectivity"
    
    # DNS
    if nslookup google.com > /dev/null 2>&1; then
        echo -e "  DNS: ${GREEN}[OK] OK${NC}"
    else
        echo -e "  DNS: ${RED}[NOK] KO${NC}"
    fi
    echo
}

# 2. Services critiques  
check_services() {
    echo -e "${CYAN}[TOOL] SERVICES CRITIQUES${NC}"
    
    local services=("ssh" "cron" "systemd-journald" "rsyslog")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service 2>/dev/null; then
            echo -e "  ${GREEN}[OK]${NC} $service"
        else
            echo -e "  ${RED}[NOK]${NC} $service"
        fi
    done
    echo
}

# 3. Ressources systeme
check_resources() {
    echo -e "${CYAN} RESSOURCES SYSTEME${NC}"
    
    # Charge systeme
    local load=$(cat /proc/loadavg | cut -d' ' -f1)
    local load_color=$GREEN
    if (( $(echo "$load > 2.0" | bc -l 2>/dev/null || echo "0") )); then
        load_color=$RED
    elif (( $(echo "$load > 1.0" | bc -l 2>/dev/null || echo "0") )); then
        load_color=$YELLOW
    fi
    echo -e "  Charge: ${load_color}$load${NC}"
    
    # Memoire
    local mem_info=$(free | grep Mem)
    local total_mem=$(echo $mem_info | awk '{print $2}')
    local used_mem=$(echo $mem_info | awk '{print $3}')
    local mem_pct=$(( used_mem * 100 / total_mem ))
    
    local mem_color=$GREEN
    if [ $mem_pct -gt 80 ]; then
        mem_color=$RED
    elif [ $mem_pct -gt 60 ]; then
        mem_color=$YELLOW
    fi
    echo -e "  Memoire: ${mem_color}${mem_pct}%${NC}"
    
    # Disque
    local disk_pct=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    local disk_color=$GREEN
    if [ $disk_pct -gt 85 ]; then
        disk_color=$RED
    elif [ $disk_pct -gt 70 ]; then
        disk_color=$YELLOW
    fi
    echo -e "  Disque /: ${disk_color}${disk_pct}%${NC}"
    echo
}

# 4. Logs recents
check_logs() {
    echo -e "${CYAN} ACTIVITE RECENTE${NC}"
    
    # Erreurs recentes
    local errors=$(journalctl -p err --since "1 hour ago" --no-pager -q | wc -l)
    if [ $errors -gt 0 ]; then
        echo -e "  ${RED}?${NC} $errors erreurs (1h)"
    else
        echo -e "  ${GREEN}[OK]${NC} Pas d'erreurs recentes"
    fi
    
    # Connexions SSH
    local ssh_conn=$(journalctl --since "24 hours ago" --no-pager -q | grep -c "Accepted password" 2>/dev/null || echo "0")
    echo "  Connexions SSH (24h): $ssh_conn"
    
    # Derniere activite
    echo "  Derniere activite:"
    journalctl --since "10 minutes ago" --no-pager -q | tail -2 | while read line; do
        echo "    $(echo "$line" | cut -c1-60)..."
    done
    echo
}

# 5. Alertes systeme
check_alerts() {
    echo -e "${CYAN} ALERTES${NC}"
    
    local alert_count=0
    
    # Services en echec
    local failed_services=$(systemctl list-units --type=service --state=failed --no-legend --no-pager | wc -l)
    if [ $failed_services -gt 0 ]; then
        echo -e "  ${RED}?${NC} $failed_services services en echec"
        ((alert_count++))
    fi
    
    # Tentatives d'authentification suspectes
    local failed_auth=$(journalctl --since "1 hour ago" --no-pager -q | grep -c "Failed password" 2>/dev/null || echo "0")
    if [ $failed_auth -gt 5 ]; then
        echo -e "  ${RED}?${NC} $failed_auth tentatives d'auth echouees (1h)"
        ((alert_count++))
    fi
    
    if [ $alert_count -eq 0 ]; then
        echo -e "  ${GREEN}[OK]${NC} Aucune alerte active"
    fi
    echo
}

# Fonction principale
main() {
    print_header
    check_network
    check_services
    check_resources
    check_logs
    check_alerts
    echo -e "${BLUE}Actualisation automatique dans ${REFRESH_INTERVAL}s (Ctrl+C pour arreter)${NC}"
}

# Mode continu ou ponctuel
if [ "$1" = "continuous" ]; then
    while true; do
        main
        sleep $REFRESH_INTERVAL
    done
else
    main
fi
EOF

chmod +x system_dashboard.sh
```

#### Etape 2 : Test du tableau de bord
```bash
echo "=== TEST DU TABLEAU DE BORD ==="

# Test ponctuel
./system_dashboard.sh

echo -e "\n=== TEST EN MODE CONTINU (30 SECONDES) ==="
timeout 30 ./system_dashboard.sh continuous || true

echo -e "\nTableau de bord teste avec succes"
```

---

## Partie F : Validation et nettoyage

### Exercice 10 : Tests de validation finale

#### Etape 1 : Verification des competences acquises
```bash
# Script de validation des acquis
cat > validation_competences.sh << 'EOF'
#!/bin/bash

score=0
total=0

echo "=== VALIDATION DES COMPETENCES ACQUISES ==="
echo

test_skill() {
    local description="$1"
    local command="$2"
    local expected_result="$3"
    
    echo -n "Test: $description... "
    ((total++))
    
    if eval "$command" >/dev/null 2>&1; then
        echo "[OK] OK"
        ((score++))
    else
        echo "[NOK] KO"
    fi
}

# Tests reseau
echo " COMPETENCES RESEAU:"
test_skill "Configuration IP visible" "ip addr show | grep -q 'inet '"
test_skill "Route par defaut configuree" "ip route show default | grep -q via"
test_skill "DNS fonctionnel" "nslookup google.com"
test_skill "Connectivite Internet" "ping -c 1 -W 3 8.8.8.8"

echo

# Tests transferts
echo "[DIR] COMPETENCES TRANSFERTS:"
test_skill "rsync disponible" "command -v rsync"
test_skill "scp disponible" "command -v scp"
test_skill "Fichiers de test crees" "test -f petit_fichier.txt && test -d projet"

echo

# Tests services
echo "[TOOL] COMPETENCES SERVICES:"
test_skill "systemctl fonctionnel" "systemctl list-units --type=service"
test_skill "journalctl accessible" "journalctl --no-pager -n 1"
test_skill "Service de test cree" "test -f /etc/systemd/system/test-service.service"

echo

# Tests logs
echo " COMPETENCES LOGS:"
test_skill "Logs systeme accessibles" "test -r /var/log/syslog || journalctl --no-pager -n 1"
test_skill "Analyse logs fonctionnelle" "test -x ./analyze_logs.sh"
test_skill "Monitoring cree" "test -x ./log_monitor.sh"

echo

# Tests scripts
echo "? COMPETENCES SCRIPTS:"
test_skill "Dashboard cree" "test -x ./system_dashboard.sh"
test_skill "Diagnostic reseau" "test -x ./diagnostic_reseau.sh"
test_skill "Script sauvegarde" "test -x ./backup_script.sh"

echo
echo "=== RESULTATS ==="
echo "Score: $score/$total ($(( score * 100 / total ))%)"

if [ $score -eq $total ]; then
    echo "[PARTY] Excellent! Toutes les competences maitrisees!"
elif [ $score -gt $(( total * 3 / 4 )) ]; then
    echo " Tres bien! La plupart des competences acquises."
elif [ $score -gt $(( total / 2 )) ]; then
    echo " Bien. Quelques points a revoir."
else
    echo "[BOOKS] A retravailler. Reprendre certains exercices."
fi
EOF

chmod +x validation_competences.sh
./validation_competences.sh
```

#### Etape 2 : Documentation des acquis
```bash
# Creer un resume de ce qui a ete appris
cat > competences_acquises.md << 'EOF'
# Competences acquises - Module 7 : Reseaux, Services et Logs

## Reseau et connectivite
- [OK] Diagnostic reseau avec `ip`, `ping`, `traceroute`
- [OK] Configuration des interfaces reseau
- [OK] Tests de connectivite automatises
- [OK] Resolution de problemes reseau

## Transferts de fichiers
- [OK] Maitrise de `scp` pour transferts ponctuels
- [OK] Utilisation avancee de `rsync` pour synchronisation
- [OK] Scripts de sauvegarde automatises
- [OK] Gestion des transferts longs et reprises

## Services systeme
- [OK] Gestion des services avec `systemctl`
- [OK] Creation de services personnalises
- [OK] Configuration des services systemd
- [OK] Surveillance et maintenance des services

## Logs et surveillance
- [OK] Navigation dans les logs avec `journalctl`
- [OK] Analyse des logs systeme traditionnels
- [OK] Scripts de surveillance automatisee
- [OK] Detection d'anomalies et alertes

## Integration et automatisation
- [OK] Tableau de bord systeme unifie
- [OK] Scripts de diagnostic multi-domaines
- [OK] Surveillance proactive
- [OK] Documentation et validation

## Fichiers crees durant le TP
EOF

# Lister les fichiers crees
echo "- $(find . -name "*.sh" -type f | wc -l) scripts shell" >> competences_acquises.md
echo "- $(find . -name "*.py" -type f | wc -l) scripts Python" >> competences_acquises.md
echo "- $(find . -name "*.txt" -o -name "*.md" -type f | wc -l) fichiers de documentation" >> competences_acquises.md

echo "" >> competences_acquises.md
echo "### Scripts principaux crees:" >> competences_acquises.md
find . -name "*.sh" -type f -exec basename {} \; | sort >> competences_acquises.md

cat competences_acquises.md
```

### Exercice 11 : Nettoyage et finalisation

#### Etape 1 : Nettoyage des services de test
```bash
echo "=== NETTOYAGE DES SERVICES DE TEST ==="

# Arreter et supprimer les services de test
if systemctl is-active --quiet test-service 2>/dev/null; then
    echo "Arret du service test-service..."
    sudo systemctl stop test-service
fi

if systemctl is-enabled --quiet test-service 2>/dev/null; then
    echo "Desactivation du service test-service..."
    sudo systemctl disable test-service
fi

if systemctl is-active --quiet system-monitor 2>/dev/null; then
    echo "Arret du service system-monitor..."
    sudo systemctl stop system-monitor
fi

# Supprimer les fichiers de services (optionnel)
read -p "Supprimer les fichiers de services de test? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -f /etc/systemd/system/test-service.service
    sudo rm -f /etc/systemd/system/system-monitor.service
    sudo rm -rf /opt/test-service
    sudo rm -rf /opt/system-monitor
    sudo systemctl daemon-reload
    echo "Services de test supprimes"
else
    echo "Services de test conserves"
fi
```

#### Etape 2 : Archivage des travaux
```bash
# Creer une archive des travaux du TP
echo "=== ARCHIVAGE DES TRAVAUX ==="

ARCHIVE_NAME="tp_reseaux_services_$(date +%Y%m%d_%H%M%S).tar.gz"

# Creer l'archive
tar czf "$ARCHIVE_NAME" \
    --exclude='*.dat' \
    --exclude='source_rsync' \
    --exclude='destination_rsync' \
    --exclude='backups' \
    *.sh *.txt *.md projet/ 2>/dev/null

if [ -f "$ARCHIVE_NAME" ]; then
    echo "[OK] Archive creee: $ARCHIVE_NAME"
    echo "Taille: $(du -h "$ARCHIVE_NAME" | cut -f1)"
    echo "Contenu:"
    tar tzf "$ARCHIVE_NAME" | head -20
    
    if [ $(tar tzf "$ARCHIVE_NAME" | wc -l) -gt 20 ]; then
        echo "... et $(( $(tar tzf "$ARCHIVE_NAME" | wc -l) - 20 )) autres fichiers"
    fi
else
    echo "[NOK] Erreur lors de la creation de l'archive"
fi

# Nettoyage optionnel des fichiers temporaires
echo -e "\nFichiers temporaires crees:"
ls -la /tmp/*monitor* /tmp/*alert* /tmp/*backup* 2>/dev/null || echo "Aucun fichier temporaire"

read -p "Nettoyer les fichiers temporaires? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f /tmp/*monitor* /tmp/*alert* /tmp/*backup* 2>/dev/null
    echo "Fichiers temporaires nettoyes"
fi

echo -e "\n=== TP TERMINE ==="
echo "Travaux archives dans: $ARCHIVE_NAME"
echo "Competences validees: Reseaux, Services systeme, Logs"
echo "Duree totale estimee: $(date '+%H:%M:%S')"
```

---

## Questions de validation

### Quiz de comprehension

1. **Reseau**
   - Comment diagnostiquer un probleme de connectivite reseau ?
   - Quelle est la difference entre `ip addr` et `ifconfig` ?
   - Comment tracer le chemin vers une destination ?

2. **Transferts**
   - Quand utiliser `scp` vs `rsync` ?
   - Comment reprendre un transfert interrompu ?
   - Comment exclure des fichiers avec rsync ?

3. **Services**
   - Comment creer un service systemd personnalise ?
   - Quelle est la difference entre `enable` et `start` ?
   - Comment voir les logs d'un service specifique ?

4. **Logs**
   - Ou sont stockes les logs systeme traditionnels ?
   - Comment filtrer les logs par priorite avec journalctl ?
   - Comment configurer la rotation des logs ?

### Exercices de revision

```bash
# 1. Creer un script qui teste la connectivite vers plusieurs serveurs
#    et envoie une alerte si plus de 50% sont injoignables

# 2. Automatiser la sauvegarde quotidienne d'un repertoire
#    avec rotation et compression

# 3. Creer un service qui surveille l'espace disque
#    et redemarre des services non-critiques si necessaire

# 4. Analyser les logs pour detecter des tentatives d'intrusion
#    et bloquer automatiquement les IP suspectes
```

---

## Solutions des exercices

### Solutions principales

#### Exercice 2 - Diagnostic reseau
```bash
# Test de connectivite complet
ping -c 1 127.0.0.1 && echo "Loopback OK"
ping -c 1 $(ip route | grep default | awk '{print $3}') && echo "Passerelle OK"
ping -c 1 8.8.8.8 && echo "Internet OK"
nslookup google.com && echo "DNS OK"
```

#### Exercice 4 - Rsync avec exclusions
```bash
rsync -avzP \
  --exclude='*.tmp' \
  --exclude='cache/' \
  --delete \
  source/ destination/
```

#### Exercice 6 - Service systemd
```bash
# Service de base
[Unit]
Description=Mon service
After=network.target

[Service]
Type=simple
ExecStart=/path/to/script
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

---

## Points cles a retenir

### Commandes reseau essentielles
```bash
ip addr show              # Adresses IP
ip route show            # Table de routage
ping -c 3 host          # Test connectivite
traceroute host         # Tracer chemin
dig domain.com          # Requete DNS
ss -tuln               # Ports ouverts
curl -I url            # Test HTTP
```

### Transferts de fichiers
```bash
# scp
scp file user@host:/path/           # Fichier simple
scp -r dir/ user@host:/path/        # Repertoire

# rsync  
rsync -avzP src/ dest/              # Synchronisation
rsync -avzP --delete src/ dest/     # Avec suppression
rsync -avzP --exclude='*.tmp' src/ dest/  # Avec exclusions
```

### Gestion des services
```bash
systemctl status service           # Etat du service
sudo systemctl start/stop service  # Demarrer/arreter
sudo systemctl enable/disable service  # Activation boot
journalctl -u service -f           # Logs en temps reel
```

### Analyse des logs
```bash
journalctl -b                      # Logs du boot
journalctl -p err                  # Erreurs seulement
journalctl --since yesterday       # Depuis hier
journalctl -u service              # Logs d'un service
tail -f /var/log/syslog           # Suivi temps reel
```

### Bonnes pratiques
- **Diagnostic methodique** : tester par couches (physique -> application)
- **Scripts robustes** : gestion d'erreurs et logging
- **Surveillance proactive** : detecter avant que ca casse
- **Documentation** : commenter les configurations
- **Sauvegardes regulieres** : automatiser et tester les restaurations

---

**Temps estime total** : 180-240 minutes selon le public
**Difficulte** : Intermediaire a avance
**Validation** : Fonctionnalites operationnelles + quiz + scripts fonctionnels