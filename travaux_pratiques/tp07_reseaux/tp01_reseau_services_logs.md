# TP 7.1 : Réseaux, services et logs système

## Objectifs
- Diagnostiquer et configurer la connectivité réseau
- Transférer des fichiers avec scp et rsync
- Gérer les services système avec systemctl
- Analyser les logs système et détecter les problèmes
- Créer un environnement de surveillance complet

## Pré-requis
- Accès à un système Linux avec droits sudo
- Connexion réseau fonctionnelle
- Connaissances des modules précédents

## Durée estimée
- **Public accéléré** : 120 minutes  
- **Public étalé** : 180 minutes

---

## Partie A : Diagnostic et configuration réseau

### Exercice 1 : Exploration de la configuration réseau

#### Étape 1 : Inventaire de la configuration actuelle
```bash
# Créer un répertoire de travail
mkdir ~/tp_reseaux
cd ~/tp_reseaux

# Identifier les interfaces réseau
ip link show
ip -br link show

# Voir les adresses IP
ip addr show
ip -br addr show

# Table de routage
ip route show
ip route show default

# Créer un rapport de configuration
cat > config_reseau_initial.txt << EOF
=== CONFIGURATION RÉSEAU INITIALE ===
Date: $(date)

Interfaces réseau:
$(ip -br link show)

Adresses IP:
$(ip -br addr show)

Route par défaut:
$(ip route show default)

Serveurs DNS:
$(cat /etc/resolv.conf | grep nameserver)
EOF

cat config_reseau_initial.txt
```

**Questions d'analyse** :
- Combien d'interfaces réseau avez-vous ?
- Quelle est votre adresse IP principale ?
- Quelle est votre passerelle par défaut ?

#### Étape 2 : Tests de connectivité de base
```bash
# Test loopback
ping -c 3 127.0.0.1

# Test passerelle (si configurée)
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
if [ -n "$GATEWAY" ]; then
    echo "Test de la passerelle: $GATEWAY"
    ping -c 3 $GATEWAY
else
    echo "Aucune passerelle configurée"
fi

# Test DNS externe
ping -c 3 8.8.8.8

# Test résolution DNS
ping -c 3 google.com

# Test connectivité web
curl -I --connect-timeout 5 http://google.com
```

### Exercice 2 : Diagnostic approfondi avec outils réseau

#### Étape 1 : Analyse avec traceroute et outils avancés
```bash
# Installation des outils de diagnostic
sudo apt update
sudo apt install -y traceroute netstat-nat dnsutils

# Tracer le chemin vers google.com
echo "Traceroute vers google.com:"
traceroute -I google.com | head -10

# Analyser les ports ouverts
echo -e "\nPorts TCP en écoute:"
ss -tln

echo -e "\nPorts UDP en écoute:"
ss -uln

# Test de résolution DNS
echo -e "\nTest DNS avec dig:"
dig google.com A +short
dig google.com MX +short
```

#### Étape 2 : Script de diagnostic automatisé
```bash
# Créer un script de diagnostic réseau
cat > diagnostic_reseau.sh << 'EOF'
#!/bin/bash

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== DIAGNOSTIC RÉSEAU AUTOMATISÉ ==="
echo "Date: $(date)"
echo

# Test de connectivité
test_connectivity() {
    local host="$1"
    local name="$2"
    
    if ping -c 1 -W 2 "$host" > /dev/null 2>&1; then
        echo -e "✅ $name ($host): ${GREEN}OK${NC}"
        return 0
    else
        echo -e "❌ $name ($host): ${RED}ÉCHEC${NC}"
        return 1
    fi
}

# Tests de connectivité
echo "🔗 TESTS DE CONNECTIVITÉ:"
test_connectivity "127.0.0.1" "Loopback"

GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
if [ -n "$GATEWAY" ]; then
    test_connectivity "$GATEWAY" "Passerelle"
else
    echo -e "❌ Passerelle: ${YELLOW}NON CONFIGURÉE${NC}"
fi

test_connectivity "8.8.8.8" "DNS Google"
test_connectivity "1.1.1.1" "DNS Cloudflare"

# Test résolution DNS
echo -e "\n🌐 TESTS DNS:"
if nslookup google.com > /dev/null 2>&1; then
    echo -e "✅ Résolution DNS: ${GREEN}OK${NC}"
else
    echo -e "❌ Résolution DNS: ${RED}ÉCHEC${NC}"
fi

# Test HTTP
echo -e "\n🌍 TESTS WEB:"
if curl -s -I --connect-timeout 5 http://google.com | grep -q "HTTP"; then
    echo -e "✅ Connectivité HTTP: ${GREEN}OK${NC}"
else
    echo -e "❌ Connectivité HTTP: ${RED}ÉCHEC${NC}"
fi

# Informations système
echo -e "\n📊 INFORMATIONS RÉSEAU:"
echo "Interface principale: $(ip route | grep default | awk '{print $5}' | head -1)"
echo "Adresse IP: $(ip route get 8.8.8.8 2>/dev/null | grep src | awk '{print $7}' | head -1)"
echo "DNS configurés: $(cat /etc/resolv.conf | grep nameserver | wc -l)"

echo -e "\n=== FIN DIAGNOSTIC ==="
EOF

chmod +x diagnostic_reseau.sh
./diagnostic_reseau.sh
```

---

## Partie B : Transferts de fichiers

### Exercice 3 : Maîtrise de scp

#### Étape 1 : Préparation des fichiers de test
```bash
# Créer des fichiers de test de différentes tailles
echo "Fichier de test simple" > petit_fichier.txt

# Fichier moyen (environ 1MB)
dd if=/dev/zero of=fichier_moyen.dat bs=1024 count=1024

# Créer une structure de répertoires
mkdir -p projet/{src,docs,config}
echo "print('Hello World')" > projet/src/main.py
echo "# Documentation du projet" > projet/docs/README.md
echo "debug=true" > projet/config/settings.ini

# Afficher ce qui a été créé
ls -lah
tree projet/ 2>/dev/null || find projet/ -type f
```

#### Étape 2 : Tests de transfert scp (simulation locale)
```bash
# Note: Pour cet exercice, nous simulons des transferts avec localhost
# Dans un vrai environnement, remplacez localhost par l'IP du serveur distant

# Test de transfert simple (nécessite SSH configuré)
echo "Test de transfert avec scp vers localhost..."

# Créer répertoire de destination
mkdir -p ~/transferts_test

# Test 1: Fichier simple
if command -v ssh >/dev/null && ssh -o ConnectTimeout=2 localhost exit 2>/dev/null; then
    echo "✅ SSH disponible, test avec localhost"
    scp petit_fichier.txt localhost:~/transferts_test/
    scp localhost:~/transferts_test/petit_fichier.txt petit_fichier_retour.txt
    echo "Transfer réussi, vérification:"
    diff petit_fichier.txt petit_fichier_retour.txt && echo "Fichiers identiques"
else
    echo "ℹ️  SSH non configuré pour localhost, simulation..."
    cp petit_fichier.txt ~/transferts_test/
    cp ~/transferts_test/petit_fichier.txt petit_fichier_retour.txt
    echo "Simulation de transfert terminée"
fi

# Test 2: Répertoire complet  
echo -e "\nTest transfert de répertoire:"
# scp -r projet localhost:~/transferts_test/ (si SSH disponible)
cp -r projet ~/transferts_test/    # Simulation
echo "Vérification du transfert de répertoire:"
ls -la ~/transferts_test/projet/
```

### Exercice 4 : Synchronisation avec rsync

#### Étape 1 : Synchronisation locale avec rsync
```bash
# Créer des données de test pour rsync
mkdir -p source_rsync destination_rsync

# Créer plusieurs fichiers dans la source
for i in {1..5}; do
    echo "Contenu du fichier $i - $(date)" > source_rsync/file$i.txt
done

mkdir source_rsync/subdir
echo "Fichier dans sous-répertoire" > source_rsync/subdir/nested.txt

echo "Contenu initial de la source:"
find source_rsync -type f -exec ls -la {} \;
```

#### Étape 2 : Tests de synchronisation
```bash
# Test 1: Synchronisation initiale
echo -e "\n=== TEST 1: Synchronisation initiale ==="
rsync -avzP --dry-run source_rsync/ destination_rsync/
echo "Dry-run terminé, synchronisation réelle:"
rsync -avzP source_rsync/ destination_rsync/

echo "Vérification destination:"
find destination_rsync -type f | wc -l

# Test 2: Synchronisation incrémentale
echo -e "\n=== TEST 2: Synchronisation incrémentale ==="
# Modifier un fichier existant
echo "Ligne ajoutée - $(date)" >> source_rsync/file1.txt
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
# Créer des fichiers à exclure
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

echo "Vérification - les fichiers exclus ne doivent pas être présents:"
find destination_rsync -name "*.tmp" -o -name "*.bak" -o -name "cache"
```

#### Étape 3 : Script de sauvegarde avec rsync
```bash
# Créer un script de sauvegarde
cat > backup_script.sh << 'EOF'
#!/bin/bash

# Configuration
SOURCE_DIR="$HOME/documents"  # Répertoire à sauvegarder
BACKUP_DIR="$HOME/backups"    # Répertoire de sauvegarde
LOG_FILE="$HOME/backup.log"   # Fichier de log

# Créer les répertoires s'ils n'existent pas
mkdir -p "$SOURCE_DIR" "$BACKUP_DIR"

# Fonction de logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Fonction de sauvegarde
perform_backup() {
    log_message "Début de la sauvegarde"
    log_message "Source: $SOURCE_DIR"
    log_message "Destination: $BACKUP_DIR"
    
    # Créer quelques fichiers de test s'ils n'existent pas
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
        
        log_message "Sauvegarde réussie"
        
        # Statistiques
        local file_count=$(find "$BACKUP_DIR" -type f | wc -l)
        local backup_size=$(du -sh "$BACKUP_DIR" | cut -f1)
        log_message "Fichiers sauvegardés: $file_count"
        log_message "Taille totale: $backup_size"
    else
        log_message "ERREUR: Échec de la sauvegarde"
        return 1
    fi
}

# Exécution
perform_backup
EOF

chmod +x backup_script.sh
./backup_script.sh

# Vérifier le résultat
echo -e "\n=== RÉSULTAT DE LA SAUVEGARDE ==="
cat ~/backup.log | tail -10
echo -e "\nContenu sauvegardé:"
find ~/backups -type f | head -10
```

---

## Partie C : Gestion des services système

### Exercice 5 : Exploration des services avec systemctl

#### Étape 1 : Analyse des services existants
```bash
echo "=== ANALYSE DES SERVICES SYSTÈME ==="

# Services actifs
echo "Services actifs:"
systemctl list-units --type=service --state=active | head -10

# Services en échec
echo -e "\nServices en échec:"
systemctl list-units --type=service --state=failed

# Services activés au démarrage
echo -e "\nServices activés au démarrage (premiers 10):"
systemctl list-unit-files --type=service --state=enabled | head -10

# Créer un rapport des services
cat > rapport_services.txt << EOF
=== RAPPORT SERVICES SYSTÈME ===
Date: $(date)

Services actifs: $(systemctl list-units --type=service --state=active --no-legend | wc -l)
Services en échec: $(systemctl list-units --type=service --state=failed --no-legend | wc -l)
Services activés: $(systemctl list-unit-files --type=service --state=enabled --no-legend | wc -l)

Services critiques:
EOF

# Vérifier quelques services critiques
for service in ssh cron rsyslog; do
    if systemctl is-active --quiet $service; then
        echo "✅ $service: actif" >> rapport_services.txt
    else
        echo "❌ $service: inactif" >> rapport_services.txt
    fi
done

cat rapport_services.txt
```

#### Étape 2 : Gestion d'un service de test
```bash
# Créer un service simple pour les tests
sudo mkdir -p /opt/test-service

# Script du service
sudo tee /opt/test-service/service.py > /dev/null << 'EOF'
#!/usr/bin/env python3
import time
import sys
from datetime import datetime

def main():
    print("Service de test démarré")
    sys.stdout.flush()
    
    try:
        while True:
            print(f"Heartbeat: {datetime.now()}")
            sys.stdout.flush()
            time.sleep(30)
    except KeyboardInterrupt:
        print("Arrêt du service")
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

echo "Service de test créé et configuré"
```

#### Étape 3 : Tests de gestion du service
```bash
echo "=== TESTS DE GESTION DU SERVICE ==="

# Test 1: Activation et démarrage
echo "1. Activation du service:"
sudo systemctl enable test-service
systemctl is-enabled test-service

echo -e "\n2. Démarrage du service:"
sudo systemctl start test-service
sleep 3
systemctl is-active test-service

# Test 2: Vérification état détaillé
echo -e "\n3. État détaillé:"
systemctl status test-service --no-pager

# Test 3: Consultation des logs
echo -e "\n4. Logs du service (5 dernières lignes):"
journalctl -u test-service -n 5 --no-pager

# Test 4: Redémarrage
echo -e "\n5. Test redémarrage:"
sudo systemctl restart test-service
sleep 2
systemctl is-active test-service

# Test 5: Arrêt et désactivation
echo -e "\n6. Arrêt du service:"
sudo systemctl stop test-service
systemctl is-active test-service

echo -e "\n7. Désactivation:"
sudo systemctl disable test-service
systemctl is-enabled test-service

echo -e "\nTests de gestion terminés"
```

### Exercice 6 : Création d'un service personnalisé

#### Étape 1 : Service de surveillance système
```bash
# Créer un script de surveillance
sudo mkdir -p /opt/system-monitor

sudo tee /opt/system-monitor/monitor.py > /dev/null << 'EOF'
#!/usr/bin/env python3
import time
import subprocess
import json
from datetime import datetime

def get_system_stats():
    stats = {}
    
    # Charge système
    with open('/proc/loadavg', 'r') as f:
        load = f.read().split()
        stats['load_1min'] = float(load[0])
    
    # Utilisation mémoire
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
    print("Démarrage du moniteur système")
    
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
                print(f"ALERTE: Charge élevée: {stats['load_1min']}")
            
            if stats['memory_usage_pct'] > 80:
                print(f"ALERTE: Mémoire élevée: {stats['memory_usage_pct']:.1f}%")
            
            if stats['disk_usage_pct'] > 85:
                print(f"ALERTE: Disque plein: {stats['disk_usage_pct']:.1f}%")
            
            time.sleep(60)  # Vérification chaque minute
            
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
Description=Moniteur système personnalisé
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

echo "Service de monitoring système créé"
```

#### Étape 2 : Test du service de monitoring
```bash
echo "=== TEST DU SERVICE DE MONITORING ==="

# Démarrer le service
sudo systemctl start system-monitor
sleep 3

# Vérifier qu'il fonctionne
systemctl status system-monitor --no-pager

# Observer les logs en temps réel (quelques secondes)
echo -e "\nLogs du service (10 dernières secondes):"
timeout 10 journalctl -u system-monitor -f --no-pager || true

# Statistiques du service
echo -e "\nStatistiques du service:"
journalctl -u system-monitor --since "1 minute ago" --no-pager | tail -5

# Arrêter le service
sudo systemctl stop system-monitor

echo -e "\nTest du service de monitoring terminé"
```

---

## Partie D : Analyse des logs système

### Exercice 7 : Exploration des logs avec journalctl

#### Étape 1 : Navigation de base dans les logs
```bash
echo "=== EXPLORATION DES LOGS SYSTÈME ==="

# Informations générales sur le journal
echo "Utilisation de l'espace par les logs:"
journalctl --disk-usage

# Logs depuis le dernier boot
echo -e "\nMessages depuis le dernier démarrage (10 derniers):"
journalctl -b --no-pager | tail -10

# Logs d'erreur récents
echo -e "\nErreurs récentes:"
journalctl -p err --since "24 hours ago" --no-pager | head -10

# Logs des services système importants
echo -e "\nDernières activités SSH:"
journalctl -u ssh --no-pager | tail -5 2>/dev/null || echo "Service SSH non trouvé"

echo -e "\nDernières activités cron:"
journalctl -u cron --no-pager | tail -5 2>/dev/null || echo "Service cron non trouvé"
```

#### Étape 2 : Analyse détaillée avec filtres
```bash
# Créer un script d'analyse des logs
cat > analyze_logs.sh << 'EOF'
#!/bin/bash

echo "=== ANALYSE AVANCÉE DES LOGS ==="
echo "Date: $(date)"
echo

# Fonction pour afficher section
print_section() {
    echo "===================="
    echo "$1"
    echo "===================="
}

# 1. Erreurs système récentes
print_section "ERREURS SYSTÈME (24H)"
error_count=$(journalctl -p err --since "24 hours ago" --no-pager -q | wc -l)
echo "Nombre d'erreurs: $error_count"

if [ $error_count -gt 0 ]; then
    echo "Dernières erreurs:"
    journalctl -p err --since "24 hours ago" --no-pager -q | tail -5
else
    echo "✅ Aucune erreur récente"
fi
echo

# 2. Authentifications
print_section "AUTHENTIFICATIONS SSH"
if journalctl -u ssh --since "24 hours ago" --no-pager -q > /dev/null 2>&1; then
    auth_success=$(journalctl --since "24 hours ago" --no-pager -q | grep -c "Accepted password" || echo "0")
    auth_failed=$(journalctl --since "24 hours ago" --no-pager -q | grep -c "Failed password" || echo "0")
    
    echo "Connexions réussies (24h): $auth_success"
    echo "Tentatives échouées (24h): $auth_failed"
    
    if [ $auth_failed -gt 0 ]; then
        echo "⚠️ Dernières tentatives échouées:"
        journalctl --since "24 hours ago" --no-pager -q | grep "Failed password" | tail -3
    fi
else
    echo "Service SSH non surveillé par systemd"
fi
echo

# 3. Services en échec
print_section "SERVICES EN ÉCHEC"
failed_services=$(systemctl list-units --type=service --state=failed --no-legend --no-pager | wc -l)
echo "Services en échec: $failed_services"

if [ $failed_services -gt 0 ]; then
    echo "Services concernés:"
    systemctl list-units --type=service --state=failed --no-legend --no-pager
fi
echo

# 4. Activité système
print_section "ACTIVITÉ SYSTÈME"
boot_time=$(journalctl --list-boots --no-pager | tail -1 | awk '{print $3, $4}')
echo "Dernier démarrage: $boot_time"

# Messages importants récents
important_count=$(journalctl -p warning --since "24 hours ago" --no-pager -q | wc -l)
echo "Messages importants (warnings+) 24h: $important_count"

if [ $important_count -gt 0 ] && [ $important_count -lt 20 ]; then
    echo "Messages récents:"
    journalctl -p warning --since "24 hours ago" --no-pager -q | tail -3
fi

echo
echo "=== FIN ANALYSE ==="
EOF

chmod +x analyze_logs.sh
./analyze_logs.sh
```

### Exercice 8 : Surveillance et alertes automatisées

#### Étape 1 : Script de surveillance des logs
```bash
# Créer un script de surveillance proactive
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

log_message "Début de la surveillance des logs"

# 1. Vérifier erreurs critiques récentes
check_critical_errors() {
    local errors=$(journalctl -p crit --since "${CHECK_PERIOD_HOURS} hours ago" --no-pager -q | wc -l)
    
    if [ $errors -gt 0 ]; then
        log_message "ALERTE: $errors erreurs critiques détectées"
        echo "ERREURS CRITIQUES: $errors" >> "$ALERT_FILE"
        journalctl -p crit --since "${CHECK_PERIOD_HOURS} hours ago" --no-pager -q | tail -3 >> "$ALERT_FILE"
        echo "---" >> "$ALERT_FILE"
        return 1
    fi
    
    return 0
}

# 2. Vérifier échecs d'authentification
check_auth_failures() {
    local failed_auths=$(journalctl --since "${CHECK_PERIOD_HOURS} hours ago" --no-pager -q | grep -c "Failed password" || echo "0")
    
    if [ $failed_auths -gt 10 ]; then  # Plus de 10 échecs = suspect
        log_message "ALERTE: $failed_auths tentatives d'authentification échouées"
        echo "AUTHENTIFICATION: $failed_auths échecs" >> "$ALERT_FILE"
        journalctl --since "${CHECK_PERIOD_HOURS} hours ago" --no-pager -q | grep "Failed password" | tail -5 >> "$ALERT_FILE"
        echo "---" >> "$ALERT_FILE"
        return 1
    fi
    
    return 0
}

# 3. Vérifier services en échec
check_failed_services() {
    local failed_services=$(systemctl list-units --type=service --state=failed --no-legend --no-pager)
    
    if [ -n "$failed_services" ]; then
        log_message "ALERTE: Services en échec détectés"
        echo "SERVICES EN ÉCHEC:" >> "$ALERT_FILE"
        echo "$failed_services" >> "$ALERT_FILE"
        echo "---" >> "$ALERT_FILE"
        return 1
    fi
    
    return 0
}

# 4. Vérifier espace disque via logs
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

# Exécuter toutes les vérifications
alerts=0

check_critical_errors || ((alerts++))
check_auth_failures || ((alerts++))
check_failed_services || ((alerts++))
check_disk_warnings || ((alerts++))

# Résumé
if [ $alerts -gt 0 ]; then
    log_message "$alerts types d'alertes détectées"
    echo
    echo "=== ALERTES DÉTECTÉES ==="
    cat "$ALERT_FILE"
    echo "========================="
    
    # Simuler envoi d'alerte (remplacer par vraie commande mail)
    echo "Alertes système sur $(hostname) - $(date)" > /tmp/alert_email.txt
    cat "$ALERT_FILE" >> /tmp/alert_email.txt
    log_message "Alerte sauvegardée dans /tmp/alert_email.txt"
else
    log_message "Aucune alerte détectée"
    echo "✅ Surveillance OK - Aucune alerte"
fi

log_message "Fin de la surveillance"
EOF

chmod +x log_monitor.sh
./log_monitor.sh
```

#### Étape 2 : Configuration pour surveillance continue
```bash
# Script de surveillance en boucle (pour démonstration)
cat > continuous_monitor.sh << 'EOF'
#!/bin/bash

INTERVAL=300  # 5 minutes
LOG_FILE="/tmp/continuous_monitor.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

log_message "Démarrage de la surveillance continue (intervalle: ${INTERVAL}s)"

# Fonction de nettoyage
cleanup() {
    log_message "Arrêt de la surveillance"
    exit 0
}

trap cleanup INT TERM

# Boucle de surveillance
while true; do
    log_message "Exécution du contrôle de surveillance"
    ./log_monitor.sh >> "$LOG_FILE" 2>&1
    
    log_message "Prochain contrôle dans ${INTERVAL} secondes"
    sleep $INTERVAL
done
EOF

chmod +x continuous_monitor.sh

# Tester la surveillance (30 secondes seulement)
echo "Test de surveillance continue (30 secondes)..."
timeout 30 ./continuous_monitor.sh || true

echo -e "\nLogs de surveillance:"
tail -10 /tmp/continuous_monitor.log 2>/dev/null || echo "Aucun log généré"
```

---

## Partie E : Projet intégré - Centre de contrôle système

### Exercice 9 : Tableau de bord unifié

#### Étape 1 : Script de tableau de bord complet
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
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗"
    echo -e "║           CENTRE DE CONTRÔLE SYSTÈME            ║"
    echo -e "║              $(hostname) - $(date '+%H:%M:%S')              ║"
    echo -e "╚══════════════════════════════════════════════════╝${NC}"
    echo
}

# 1. État réseau
check_network() {
    echo -e "${CYAN}🌐 ÉTAT RÉSEAU${NC}"
    
    # Interface principale
    local main_if=$(ip route | grep default | awk '{print $5}' | head -1)
    local main_ip=$(ip addr show $main_if 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -1)
    echo "  Interface: $main_if ($main_ip)"
    
    # Tests de connectivité
    local connectivity=""
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        connectivity="${GREEN}✓ Internet OK${NC}"
    else
        connectivity="${RED}✗ Internet KO${NC}"
    fi
    echo -e "  Connectivité: $connectivity"
    
    # DNS
    if nslookup google.com > /dev/null 2>&1; then
        echo -e "  DNS: ${GREEN}✓ OK${NC}"
    else
        echo -e "  DNS: ${RED}✗ KO${NC}"
    fi
    echo
}

# 2. Services critiques  
check_services() {
    echo -e "${CYAN}🔧 SERVICES CRITIQUES${NC}"
    
    local services=("ssh" "cron" "systemd-journald" "rsyslog")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $service"
        else
            echo -e "  ${RED}✗${NC} $service"
        fi
    done
    echo
}

# 3. Ressources système
check_resources() {
    echo -e "${CYAN}📊 RESSOURCES SYSTÈME${NC}"
    
    # Charge système
    local load=$(cat /proc/loadavg | cut -d' ' -f1)
    local load_color=$GREEN
    if (( $(echo "$load > 2.0" | bc -l 2>/dev/null || echo "0") )); then
        load_color=$RED
    elif (( $(echo "$load > 1.0" | bc -l 2>/dev/null || echo "0") )); then
        load_color=$YELLOW
    fi
    echo -e "  Charge: ${load_color}$load${NC}"
    
    # Mémoire
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
    echo -e "  Mémoire: ${mem_color}${mem_pct}%${NC}"
    
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

# 4. Logs récents
check_logs() {
    echo -e "${CYAN}📝 ACTIVITÉ RÉCENTE${NC}"
    
    # Erreurs récentes
    local errors=$(journalctl -p err --since "1 hour ago" --no-pager -q | wc -l)
    if [ $errors -gt 0 ]; then
        echo -e "  ${RED}⚠${NC} $errors erreurs (1h)"
    else
        echo -e "  ${GREEN}✓${NC} Pas d'erreurs récentes"
    fi
    
    # Connexions SSH
    local ssh_conn=$(journalctl --since "24 hours ago" --no-pager -q | grep -c "Accepted password" 2>/dev/null || echo "0")
    echo "  Connexions SSH (24h): $ssh_conn"
    
    # Dernière activité
    echo "  Dernière activité:"
    journalctl --since "10 minutes ago" --no-pager -q | tail -2 | while read line; do
        echo "    $(echo "$line" | cut -c1-60)..."
    done
    echo
}

# 5. Alertes système
check_alerts() {
    echo -e "${CYAN}🚨 ALERTES${NC}"
    
    local alert_count=0
    
    # Services en échec
    local failed_services=$(systemctl list-units --type=service --state=failed --no-legend --no-pager | wc -l)
    if [ $failed_services -gt 0 ]; then
        echo -e "  ${RED}●${NC} $failed_services services en échec"
        ((alert_count++))
    fi
    
    # Tentatives d'authentification suspectes
    local failed_auth=$(journalctl --since "1 hour ago" --no-pager -q | grep -c "Failed password" 2>/dev/null || echo "0")
    if [ $failed_auth -gt 5 ]; then
        echo -e "  ${RED}●${NC} $failed_auth tentatives d'auth échouées (1h)"
        ((alert_count++))
    fi
    
    if [ $alert_count -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Aucune alerte active"
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
    echo -e "${BLUE}Actualisation automatique dans ${REFRESH_INTERVAL}s (Ctrl+C pour arrêter)${NC}"
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

#### Étape 2 : Test du tableau de bord
```bash
echo "=== TEST DU TABLEAU DE BORD ==="

# Test ponctuel
./system_dashboard.sh

echo -e "\n=== TEST EN MODE CONTINU (30 SECONDES) ==="
timeout 30 ./system_dashboard.sh continuous || true

echo -e "\nTableau de bord testé avec succès"
```

---

## Partie F : Validation et nettoyage

### Exercice 10 : Tests de validation finale

#### Étape 1 : Vérification des compétences acquises
```bash
# Script de validation des acquis
cat > validation_competences.sh << 'EOF'
#!/bin/bash

score=0
total=0

echo "=== VALIDATION DES COMPÉTENCES ACQUISES ==="
echo

test_skill() {
    local description="$1"
    local command="$2"
    local expected_result="$3"
    
    echo -n "Test: $description... "
    ((total++))
    
    if eval "$command" >/dev/null 2>&1; then
        echo "✅ OK"
        ((score++))
    else
        echo "❌ KO"
    fi
}

# Tests réseau
echo "📡 COMPÉTENCES RÉSEAU:"
test_skill "Configuration IP visible" "ip addr show | grep -q 'inet '"
test_skill "Route par défaut configurée" "ip route show default | grep -q via"
test_skill "DNS fonctionnel" "nslookup google.com"
test_skill "Connectivité Internet" "ping -c 1 -W 3 8.8.8.8"

echo

# Tests transferts
echo "📁 COMPÉTENCES TRANSFERTS:"
test_skill "rsync disponible" "command -v rsync"
test_skill "scp disponible" "command -v scp"
test_skill "Fichiers de test créés" "test -f petit_fichier.txt && test -d projet"

echo

# Tests services
echo "🔧 COMPÉTENCES SERVICES:"
test_skill "systemctl fonctionnel" "systemctl list-units --type=service"
test_skill "journalctl accessible" "journalctl --no-pager -n 1"
test_skill "Service de test créé" "test -f /etc/systemd/system/test-service.service"

echo

# Tests logs
echo "📋 COMPÉTENCES LOGS:"
test_skill "Logs système accessibles" "test -r /var/log/syslog || journalctl --no-pager -n 1"
test_skill "Analyse logs fonctionnelle" "test -x ./analyze_logs.sh"
test_skill "Monitoring créé" "test -x ./log_monitor.sh"

echo

# Tests scripts
echo "⚙️ COMPÉTENCES SCRIPTS:"
test_skill "Dashboard créé" "test -x ./system_dashboard.sh"
test_skill "Diagnostic réseau" "test -x ./diagnostic_reseau.sh"
test_skill "Script sauvegarde" "test -x ./backup_script.sh"

echo
echo "=== RÉSULTATS ==="
echo "Score: $score/$total ($(( score * 100 / total ))%)"

if [ $score -eq $total ]; then
    echo "🎉 Excellent! Toutes les compétences maîtrisées!"
elif [ $score -gt $(( total * 3 / 4 )) ]; then
    echo "👍 Très bien! La plupart des compétences acquises."
elif [ $score -gt $(( total / 2 )) ]; then
    echo "👌 Bien. Quelques points à revoir."
else
    echo "📚 À retravailler. Reprendre certains exercices."
fi
EOF

chmod +x validation_competences.sh
./validation_competences.sh
```

#### Étape 2 : Documentation des acquis
```bash
# Créer un résumé de ce qui a été appris
cat > competences_acquises.md << 'EOF'
# Compétences acquises - Module 7 : Réseaux, Services et Logs

## Réseau et connectivité
- ✅ Diagnostic réseau avec `ip`, `ping`, `traceroute`
- ✅ Configuration des interfaces réseau
- ✅ Tests de connectivité automatisés
- ✅ Résolution de problèmes réseau

## Transferts de fichiers
- ✅ Maîtrise de `scp` pour transferts ponctuels
- ✅ Utilisation avancée de `rsync` pour synchronisation
- ✅ Scripts de sauvegarde automatisés
- ✅ Gestion des transferts longs et reprises

## Services système
- ✅ Gestion des services avec `systemctl`
- ✅ Création de services personnalisés
- ✅ Configuration des services systemd
- ✅ Surveillance et maintenance des services

## Logs et surveillance
- ✅ Navigation dans les logs avec `journalctl`
- ✅ Analyse des logs système traditionnels
- ✅ Scripts de surveillance automatisée
- ✅ Détection d'anomalies et alertes

## Intégration et automatisation
- ✅ Tableau de bord système unifié
- ✅ Scripts de diagnostic multi-domaines
- ✅ Surveillance proactive
- ✅ Documentation et validation

## Fichiers créés durant le TP
EOF

# Lister les fichiers créés
echo "- $(find . -name "*.sh" -type f | wc -l) scripts shell" >> competences_acquises.md
echo "- $(find . -name "*.py" -type f | wc -l) scripts Python" >> competences_acquises.md
echo "- $(find . -name "*.txt" -o -name "*.md" -type f | wc -l) fichiers de documentation" >> competences_acquises.md

echo "" >> competences_acquises.md
echo "### Scripts principaux créés:" >> competences_acquises.md
find . -name "*.sh" -type f -exec basename {} \; | sort >> competences_acquises.md

cat competences_acquises.md
```

### Exercice 11 : Nettoyage et finalisation

#### Étape 1 : Nettoyage des services de test
```bash
echo "=== NETTOYAGE DES SERVICES DE TEST ==="

# Arrêter et supprimer les services de test
if systemctl is-active --quiet test-service 2>/dev/null; then
    echo "Arrêt du service test-service..."
    sudo systemctl stop test-service
fi

if systemctl is-enabled --quiet test-service 2>/dev/null; then
    echo "Désactivation du service test-service..."
    sudo systemctl disable test-service
fi

if systemctl is-active --quiet system-monitor 2>/dev/null; then
    echo "Arrêt du service system-monitor..."
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
    echo "Services de test supprimés"
else
    echo "Services de test conservés"
fi
```

#### Étape 2 : Archivage des travaux
```bash
# Créer une archive des travaux du TP
echo "=== ARCHIVAGE DES TRAVAUX ==="

ARCHIVE_NAME="tp_reseaux_services_$(date +%Y%m%d_%H%M%S).tar.gz"

# Créer l'archive
tar czf "$ARCHIVE_NAME" \
    --exclude='*.dat' \
    --exclude='source_rsync' \
    --exclude='destination_rsync' \
    --exclude='backups' \
    *.sh *.txt *.md projet/ 2>/dev/null

if [ -f "$ARCHIVE_NAME" ]; then
    echo "✅ Archive créée: $ARCHIVE_NAME"
    echo "Taille: $(du -h "$ARCHIVE_NAME" | cut -f1)"
    echo "Contenu:"
    tar tzf "$ARCHIVE_NAME" | head -20
    
    if [ $(tar tzf "$ARCHIVE_NAME" | wc -l) -gt 20 ]; then
        echo "... et $(( $(tar tzf "$ARCHIVE_NAME" | wc -l) - 20 )) autres fichiers"
    fi
else
    echo "❌ Erreur lors de la création de l'archive"
fi

# Nettoyage optionnel des fichiers temporaires
echo -e "\nFichiers temporaires créés:"
ls -la /tmp/*monitor* /tmp/*alert* /tmp/*backup* 2>/dev/null || echo "Aucun fichier temporaire"

read -p "Nettoyer les fichiers temporaires? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f /tmp/*monitor* /tmp/*alert* /tmp/*backup* 2>/dev/null
    echo "Fichiers temporaires nettoyés"
fi

echo -e "\n=== TP TERMINÉ ==="
echo "Travaux archivés dans: $ARCHIVE_NAME"
echo "Compétences validées: Réseaux, Services système, Logs"
echo "Durée totale estimée: $(date '+%H:%M:%S')"
```

---

## Questions de validation

### Quiz de compréhension

1. **Réseau**
   - Comment diagnostiquer un problème de connectivité réseau ?
   - Quelle est la différence entre `ip addr` et `ifconfig` ?
   - Comment tracer le chemin vers une destination ?

2. **Transferts**
   - Quand utiliser `scp` vs `rsync` ?
   - Comment reprendre un transfert interrompu ?
   - Comment exclure des fichiers avec rsync ?

3. **Services**
   - Comment créer un service systemd personnalisé ?
   - Quelle est la différence entre `enable` et `start` ?
   - Comment voir les logs d'un service spécifique ?

4. **Logs**
   - Où sont stockés les logs système traditionnels ?
   - Comment filtrer les logs par priorité avec journalctl ?
   - Comment configurer la rotation des logs ?

### Exercices de révision

```bash
# 1. Créer un script qui teste la connectivité vers plusieurs serveurs
#    et envoie une alerte si plus de 50% sont injoignables

# 2. Automatiser la sauvegarde quotidienne d'un répertoire
#    avec rotation et compression

# 3. Créer un service qui surveille l'espace disque
#    et redémarre des services non-critiques si nécessaire

# 4. Analyser les logs pour détecter des tentatives d'intrusion
#    et bloquer automatiquement les IP suspectes
```

---

## Solutions des exercices

### Solutions principales

#### Exercice 2 - Diagnostic réseau
```bash
# Test de connectivité complet
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

## Points clés à retenir

### Commandes réseau essentielles
```bash
ip addr show              # Adresses IP
ip route show            # Table de routage
ping -c 3 host          # Test connectivité
traceroute host         # Tracer chemin
dig domain.com          # Requête DNS
ss -tuln               # Ports ouverts
curl -I url            # Test HTTP
```

### Transferts de fichiers
```bash
# scp
scp file user@host:/path/           # Fichier simple
scp -r dir/ user@host:/path/        # Répertoire

# rsync  
rsync -avzP src/ dest/              # Synchronisation
rsync -avzP --delete src/ dest/     # Avec suppression
rsync -avzP --exclude='*.tmp' src/ dest/  # Avec exclusions
```

### Gestion des services
```bash
systemctl status service           # État du service
sudo systemctl start/stop service  # Démarrer/arrêter
sudo systemctl enable/disable service  # Activation boot
journalctl -u service -f           # Logs en temps réel
```

### Analyse des logs
```bash
journalctl -b                      # Logs du boot
journalctl -p err                  # Erreurs seulement
journalctl --since yesterday       # Depuis hier
journalctl -u service              # Logs d'un service
tail -f /var/log/syslog           # Suivi temps réel
```

### Bonnes pratiques
- **Diagnostic méthodique** : tester par couches (physique → application)
- **Scripts robustes** : gestion d'erreurs et logging
- **Surveillance proactive** : détecter avant que ça casse
- **Documentation** : commenter les configurations
- **Sauvegardes régulières** : automatiser et tester les restaurations

---

**Temps estimé total** : 180-240 minutes selon le public
**Difficulté** : Intermédiaire à avancé
**Validation** : Fonctionnalités opérationnelles + quiz + scripts fonctionnels