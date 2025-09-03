# Module 7.4 : Logs systeme

## Objectifs d'apprentissage
- Comprendre l'architecture des logs Linux
- Naviguer dans /var/log et analyser les fichiers de logs
- Maitriser journalctl pour les logs systemd
- Configurer et personnaliser le logging
- Automatiser l'analyse et la surveillance des logs

## Introduction

Les **logs systeme** sont essentiels pour le diagnostic, la surveillance et la securite. Linux utilise principalement deux systemes : les logs traditionnels dans `/var/log` et le journal systemd accessible via `journalctl`.

---

## 1. Architecture des logs Linux

### Systemes de logging

#### Systeme traditionnel (rsyslog/syslog)
```bash
# Fichiers dans /var/log
/var/log/syslog          # Messages systeme generaux
/var/log/auth.log        # Authentifications
/var/log/kern.log        # Messages du noyau
/var/log/mail.log        # Serveur mail
/var/log/apache2/        # Serveur web Apache
/var/log/nginx/          # Serveur web Nginx
```

#### Systeme moderne (systemd journal)
```bash
# Journal binaire systemd
/var/log/journal/        # Logs persistants (si configure)
/run/log/journal/        # Logs temporaires (RAM)

# Consultation via journalctl
journalctl               # Tous les logs
journalctl -u service    # Logs d'un service
```

### Niveaux de logging (syslog)

#### Priorites des messages
```bash
0 - emerg    # Urgence (systeme inutilisable)
1 - alert    # Alerte (action immediate requise)
2 - crit     # Critique (conditions critiques)
3 - err      # Erreur (conditions d'erreur)
4 - warning  # Avertissement (conditions d'avertissement)
5 - notice   # Notice (normal mais significatif)
6 - info     # Information (messages informatifs)
7 - debug    # Debug (messages de debogage)
```

#### Facilites (sources des messages)
```bash
kern     # Messages du noyau
user     # Messages utilisateur
mail     # Systeme de mail
daemon   # Demons systeme
auth     # Securite/authentification
syslog   # Messages du systeme syslog
cron     # Demon cron
news     # Systeme de news USENET
uucp     # Systeme UUCP
local0-7 # Facilites locales personnalisees
```

---

## 2. Exploration de /var/log

### Fichiers de logs principaux

#### Logs systeme generaux
```bash
# Messages systeme principaux
cat /var/log/syslog | tail -20
less /var/log/syslog

# Messages avec timestamp plus precis
cat /var/log/messages    # Sur CentOS/RHEL

# Noyau seulement
cat /var/log/kern.log
dmesg                    # Messages du noyau en memoire

# Demarrage du systeme
cat /var/log/boot.log    # Si disponible
journalctl -b            # Via systemd
```

#### Logs de securite et authentification
```bash
# Authentifications
cat /var/log/auth.log
tail -f /var/log/auth.log

# Exemples de recherche dans auth.log
grep "Failed password" /var/log/auth.log
grep "sudo" /var/log/auth.log | tail -10
grep "session opened" /var/log/auth.log | grep "$(whoami)"

# Sur CentOS/RHEL
cat /var/log/secure
```

#### Logs d'applications

##### Serveurs web
```bash
# Apache
ls -la /var/log/apache2/
cat /var/log/apache2/access.log | tail -10
cat /var/log/apache2/error.log | tail -10

# Nginx  
ls -la /var/log/nginx/
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

##### Bases de donnees
```bash
# MySQL/MariaDB
cat /var/log/mysql/error.log
cat /var/log/mysql/mysql.log    # Si logging general active

# PostgreSQL
cat /var/log/postgresql/postgresql-*.log
```

##### Autres services
```bash
# Mail (Postfix)
cat /var/log/mail.log
cat /var/log/mail.err

# Cron
cat /var/log/cron.log
grep "CRON" /var/log/syslog

# FTP
cat /var/log/vsftpd.log    # Si vsftpd installe
```

### Navigation et analyse des logs

#### Commandes de base pour les logs
```bash
# Voir les dernieres lignes
tail /var/log/syslog
tail -n 50 /var/log/auth.log

# Suivre en temps reel
tail -f /var/log/syslog
tail -f /var/log/auth.log

# Voir le debut d'un fichier
head /var/log/syslog
head -n 20 /var/log/kern.log

# Navigation interactive
less /var/log/syslog       # j/k pour navigation, /pattern pour recherche
more /var/log/auth.log
```

#### Recherche et filtrage
```bash
# Recherche simple
grep "error" /var/log/syslog
grep -i "failed" /var/log/auth.log    # Insensible a la casse

# Recherche avec contexte
grep -A 5 -B 5 "error" /var/log/syslog    # 5 lignes avant/apres

# Recherche dans plusieurs fichiers
grep "ssh" /var/log/auth.log /var/log/syslog

# Recherche recursive
grep -r "error" /var/log/

# Compter les occurrences
grep -c "Failed password" /var/log/auth.log

# Recherche avec regex
grep -E "(error|warning|critical)" /var/log/syslog
```

#### Analyse par periode
```bash
# Logs du jour (via grep sur la date)
grep "$(date '+%b %d')" /var/log/syslog

# Logs d'hier
grep "$(date -d yesterday '+%b %d')" /var/log/syslog

# Recherche sur periode specifique
awk '/Dec 25 10:00/,/Dec 25 11:00/' /var/log/syslog

# Logs entre deux timestamps avec sed
sed -n '/Dec 25 10:00:00/,/Dec 25 11:00:00/p' /var/log/syslog
```

---

## 3. Maitrise de journalctl

### Consultation des logs systemd

#### Affichage de base
```bash
# Tous les logs
journalctl

# Avec pagination
journalctl | less

# Sans pagination  
journalctl --no-pager

# Format de sortie court
journalctl -o short    # Format par defaut
journalctl -o json     # Format JSON
journalctl -o verbose  # Format detaille
```

#### Filtrage par service
```bash
# Logs d'un service specifique
journalctl -u nginx
journalctl -u ssh.service
journalctl -u apache2.service

# Plusieurs services
journalctl -u nginx -u apache2

# Pattern de services
journalctl -u 'ssh*'
```

#### Filtrage temporel
```bash
# Depuis une date
journalctl --since "2023-12-01"
journalctl --since "2023-12-01 14:30:00"
journalctl --since yesterday
journalctl --since "1 hour ago"
journalctl --since "30 min ago"

# Jusqu'a une date
journalctl --until "2023-12-31"
journalctl --until "1 hour ago"

# Periode specifique
journalctl --since "2023-12-01" --until "2023-12-31"
journalctl --since "09:00" --until "17:00"
```

#### Filtrage par boot
```bash
# Boot actuel
journalctl -b
journalctl -b 0

# Boot precedent
journalctl -b -1

# Lister tous les boots
journalctl --list-boots

# Boot specifique
journalctl -b <boot_id>
```

### Options avancees de journalctl

#### Suivi en temps reel
```bash
# Suivre tous les logs
journalctl -f

# Suivre un service
journalctl -u nginx -f

# Suivre avec nombre de lignes initial
journalctl -n 50 -f
journalctl -u apache2 -n 100 -f
```

#### Filtrage par priorite
```bash
# Erreurs seulement
journalctl -p err

# Avertissements et plus grave
journalctl -p warning

# Niveaux disponibles :
journalctl -p emerg     # 0
journalctl -p alert     # 1
journalctl -p crit      # 2
journalctl -p err       # 3
journalctl -p warning   # 4
journalctl -p notice    # 5
journalctl -p info      # 6
journalctl -p debug     # 7
```

#### Filtrage par processus et utilisateur
```bash
# Par PID
journalctl _PID=1234

# Par nom d'executable
journalctl /usr/sbin/nginx

# Par utilisateur (UID)
journalctl _UID=1000
journalctl _UID=0    # Root

# Par nom d'utilisateur
journalctl _COMM=sshd
```

#### Recherche dans les logs
```bash
# Recherche de texte (grep integre)
journalctl -g "error"
journalctl -u nginx -g "404"

# Recherche insensible a la casse
journalctl -g "(?i)error"

# Recherche avec regex
journalctl -g "error|warning|critical"
```

### Gestion de l'espace journal

#### Information sur l'espace utilise
```bash
# Espace utilise par les logs
journalctl --disk-usage

# Statistiques detaillees
journalctl --verify
```

#### Nettoyage des logs
```bash
# Supprimer logs plus anciens que X jours
sudo journalctl --vacuum-time=30d

# Limiter la taille totale
sudo journalctl --vacuum-size=100M

# Garder seulement N fichiers
sudo journalctl --vacuum-files=5

# Nettoyage jusqu'a une date
sudo journalctl --vacuum-time=2023-01-01
```

---

## 4. Configuration du logging

### Configuration de systemd-journald

#### Fichier de configuration principal
```bash
# Configuration par defaut
cat /etc/systemd/journald.conf

# Options principales a modifier
sudo nano /etc/systemd/journald.conf

# Exemple de configuration personnalisee :
[Journal]
Storage=persistent          # auto, volatile, persistent, none
Compress=yes               # Compresser les logs
Seal=yes                   # Etancheite cryptographique
SplitMode=uid              # Separer par utilisateur
SyncIntervalSec=5m         # Intervalle de synchronisation
RateLimitIntervalSec=30s   # Fenetre de limitation de debit
RateLimitBurst=1000        # Messages max dans la fenetre
SystemMaxUse=4G            # Taille max sur disque
SystemKeepFree=1G          # Espace libre minimum
SystemMaxFileSize=128M     # Taille max par fichier
MaxRetentionSec=1month     # Retention maximum
```

#### Appliquer la configuration
```bash
# Redemarrer journald
sudo systemctl restart systemd-journald

# Verifier l'etat
systemctl status systemd-journald

# Forcer la synchronisation
sudo systemctl kill --signal=SIGUSR1 systemd-journald
```

### Configuration de rsyslog

#### Configuration principale
```bash
# Fichier principal
cat /etc/rsyslog.conf

# Repertoire de configuration modulaire
ls /etc/rsyslog.d/

# Exemple de regle personnalisee
sudo nano /etc/rsyslog.d/50-custom.conf

# Contenu exemple :
# Logs d'authentification SSH vers fichier separe
:programname, isequal, "sshd" /var/log/ssh.log
& stop

# Logs d'erreurs critiques vers fichier special
*.crit /var/log/critical.log

# Logs vers serveur distant
*.* @@log-server.domain.com:514
```

#### Rediriger logs par service
```bash
# Creer regle pour nginx
sudo nano /etc/rsyslog.d/49-nginx.conf

# Contenu :
if $programname == 'nginx' then {
    /var/log/nginx/nginx-rsyslog.log
    stop
}

# Redemarrer rsyslog
sudo systemctl restart rsyslog
```

### Rotation des logs avec logrotate

#### Configuration logrotate
```bash
# Configuration principale
cat /etc/logrotate.conf

# Configurations par application
ls /etc/logrotate.d/

# Exemple pour nginx
cat /etc/logrotate.d/nginx

# Exemple de configuration personnalisee
sudo nano /etc/logrotate.d/myapp

# Contenu :
/var/log/myapp/*.log {
    daily              # Rotation quotidienne
    missingok          # Pas d'erreur si fichier absent
    rotate 52          # Garder 52 versions (1 an)
    compress           # Compresser les anciennes versions
    delaycompress      # Ne pas compresser la derniere version
    notifempty         # Ne pas tourner si vide
    create 0640 www-data adm    # Permissions nouveau fichier
    sharedscripts      # Script unique pour tous les fichiers
    postrotate         # Action apres rotation
        /bin/systemctl reload nginx > /dev/null 2>&1 || true
    endscript
}
```

#### Test et execution de logrotate
```bash
# Test d'une configuration
sudo logrotate -d /etc/logrotate.d/nginx    # Dry run

# Forcer une rotation
sudo logrotate -f /etc/logrotate.d/nginx

# Executer toutes les rotations
sudo logrotate /etc/logrotate.conf

# Voir l'etat de logrotate
cat /var/lib/logrotate/status
```

---

## 5. Analyse et surveillance des logs

### Scripts d'analyse automatisee

#### Analyse des tentatives d'intrusion
```bash
#!/bin/bash
# analyze_auth.sh - Analyse des logs d'authentification

LOG_FILE="/var/log/auth.log"
REPORT_FILE="/tmp/auth_report.txt"

echo "=== RAPPORT D'ANALYSE SECURITE $(date) ===" > "$REPORT_FILE"
echo >> "$REPORT_FILE"

# Tentatives de connexion echouees
echo "TENTATIVES DE CONNEXION ECHOUEES :" >> "$REPORT_FILE"
echo "==================================" >> "$REPORT_FILE"
grep "Failed password" "$LOG_FILE" | tail -20 >> "$REPORT_FILE"
echo >> "$REPORT_FILE"

# Top 10 IP sources d'attaques
echo "TOP 10 IP SOURCES D'ATTAQUES :" >> "$REPORT_FILE"
echo "==============================" >> "$REPORT_FILE"
grep "Failed password" "$LOG_FILE" | \
    grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | \
    sort | uniq -c | sort -nr | head -10 >> "$REPORT_FILE"
echo >> "$REPORT_FILE"

# Connexions reussies
echo "CONNEXIONS REUSSIES RECENTES :" >> "$REPORT_FILE"
echo "==============================" >> "$REPORT_FILE"
grep "Accepted password" "$LOG_FILE" | tail -10 >> "$REPORT_FILE"
echo >> "$REPORT_FILE"

# Utilisation de sudo
echo "UTILISATION DE SUDO :" >> "$REPORT_FILE"
echo "=====================" >> "$REPORT_FILE"
grep "sudo" "$LOG_FILE" | tail -10 >> "$REPORT_FILE"

# Afficher le rapport
cat "$REPORT_FILE"
```

#### Surveillance des erreurs systeme
```bash
#!/bin/bash
# monitor_errors.sh - Surveillance des erreurs systeme

LOG_SOURCES=(
    "/var/log/syslog"
    "/var/log/kern.log"
    "/var/log/apache2/error.log"
    "/var/log/nginx/error.log"
)

ERROR_PATTERNS=(
    "error"
    "critical"
    "failed"
    "panic"
    "segfault"
    "out of memory"
)

ALERT_FILE="/tmp/error_alerts.txt"
> "$ALERT_FILE"

echo "=== SURVEILLANCE ERREURS SYSTEME $(date) ==="

for log_file in "${LOG_SOURCES[@]}"; do
    if [[ -f "$log_file" ]]; then
        echo -e "\n[SEARCH] Analyse de $log_file"
        
        for pattern in "${ERROR_PATTERNS[@]}"; do
            # Chercher erreurs des dernieres 24h
            error_count=$(grep -c -i "$pattern" "$log_file" 2>/dev/null || echo "0")
            
            if [[ $error_count -gt 0 ]]; then
                echo "  [WARN]  '$pattern': $error_count occurrences"
                echo "Fichier: $log_file - Pattern: $pattern - Count: $error_count" >> "$ALERT_FILE"
                
                # Afficher les 3 dernieres occurrences
                grep -i "$pattern" "$log_file" | tail -3 | while read line; do
                    echo "    $line"
                done
            fi
        done
    else
        echo "[NOK] Fichier non trouve : $log_file"
    fi
done

# Envoyer alerte si erreurs critiques
if [[ -s "$ALERT_FILE" ]]; then
    echo -e "\n Envoi d'alerte pour erreurs detectees"
    mail -s "Erreurs systeme detectees sur $(hostname)" admin@domain.com < "$ALERT_FILE" 2>/dev/null || \
    echo "Mail non configure - Alerte stockee dans $ALERT_FILE"
fi
```

#### Tableau de bord des logs
```bash
#!/bin/bash
# log_dashboard.sh - Tableau de bord des logs

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    clear
    echo -e "${BLUE}=================================="
    echo -e "    TABLEAU DE BORD LOGS"
    echo -e "    $(hostname) - $(date)"
    echo -e "==================================${NC}"
    echo
}

system_logs_summary() {
    echo -e "${GREEN} RESUME LOGS SYSTEME${NC}"
    echo "  Derniere activite systeme:"
    tail -3 /var/log/syslog | while read line; do
        echo "    $line"
    done
    echo
}

auth_summary() {
    echo -e "${GREEN} RESUME AUTHENTIFICATION${NC}"
    
    # Connexions SSH reussies aujourd'hui
    ssh_success=$(grep "$(date '+%b %d')" /var/log/auth.log 2>/dev/null | grep -c "Accepted password" || echo "0")
    echo -e "  Connexions SSH reussies aujourd'hui: ${GREEN}$ssh_success${NC}"
    
    # Tentatives echouees aujourd'hui
    ssh_failed=$(grep "$(date '+%b %d')" /var/log/auth.log 2>/dev/null | grep -c "Failed password" || echo "0")
    if [[ $ssh_failed -gt 10 ]]; then
        echo -e "  Tentatives SSH echouees aujourd'hui: ${RED}$ssh_failed${NC}"
    else
        echo -e "  Tentatives SSH echouees aujourd'hui: ${YELLOW}$ssh_failed${NC}"
    fi
    
    # Derniere connexion reussie
    last_login=$(grep "Accepted password" /var/log/auth.log 2>/dev/null | tail -1 | awk '{print $1, $2, $3}' || echo "Aucune")
    echo "  Derniere connexion reussie: $last_login"
    echo
}

service_errors() {
    echo -e "${GREEN}[WARN]  ERREURS DE SERVICES${NC}"
    
    # Erreurs systemd dernieres 24h
    systemd_errors=$(journalctl --since "24 hours ago" -p err --no-pager -q 2>/dev/null | wc -l || echo "0")
    if [[ $systemd_errors -gt 0 ]]; then
        echo -e "  Erreurs systemd (24h): ${RED}$systemd_errors${NC}"
        echo "  Dernieres erreurs:"
        journalctl --since "24 hours ago" -p err --no-pager -q 2>/dev/null | tail -2 | while read line; do
            echo "    $line"
        done
    else
        echo -e "  Erreurs systemd (24h): ${GREEN}0${NC}"
    fi
    echo
}

web_logs_summary() {
    echo -e "${GREEN} LOGS SERVEURS WEB${NC}"
    
    # Apache si present
    if [[ -f /var/log/apache2/access.log ]]; then
        apache_requests=$(grep "$(date '+%d/%b/%Y')" /var/log/apache2/access.log 2>/dev/null | wc -l || echo "0")
        echo "  Requetes Apache aujourd'hui: $apache_requests"
        
        apache_errors=$(grep "$(date '+%Y/%m/%d')" /var/log/apache2/error.log 2>/dev/null | wc -l || echo "0")
        echo "  Erreurs Apache aujourd'hui: $apache_errors"
    fi
    
    # Nginx si present
    if [[ -f /var/log/nginx/access.log ]]; then
        nginx_requests=$(grep "$(date '+%d/%b/%Y')" /var/log/nginx/access.log 2>/dev/null | wc -l || echo "0")
        echo "  Requetes Nginx aujourd'hui: $nginx_requests"
        
        nginx_errors=$(grep "$(date '+%Y/%m/%d')" /var/log/nginx/error.log 2>/dev/null | wc -l || echo "0")
        echo "  Erreurs Nginx aujourd'hui: $nginx_errors"
    fi
    echo
}

disk_usage_logs() {
    echo -e "${GREEN} UTILISATION DISQUE /var/log${NC}"
    local log_usage=$(du -sh /var/log 2>/dev/null | cut -f1)
    echo "  Espace utilise par /var/log: $log_usage"
    
    echo "  Plus gros fichiers de log:"
    du -h /var/log/* 2>/dev/null | sort -hr | head -5 | while read size file; do
        echo "    $size - $file"
    done
    echo
}

main() {
    print_header
    system_logs_summary
    auth_summary
    service_errors
    web_logs_summary
    disk_usage_logs
    echo "Derniere mise a jour: $(date)"
}

# Mode continu ou ponctuel
if [[ "$1" == "watch" ]]; then
    while true; do
        main
        echo "Actualisation dans 60 secondes... (Ctrl+C pour arreter)"
        sleep 60
    done
else
    main
fi
```

### Surveillance avec logwatch

#### Installation et configuration de logwatch
```bash
# Installation
sudo apt install logwatch    # Debian/Ubuntu
sudo yum install logwatch     # CentOS/RHEL

# Configuration principale
sudo nano /etc/logwatch/conf/logwatch.conf

# Parametres importants :
# Detail = High               # Niveau de detail
# MailTo = admin@domain.com   # Destinataire
# Range = yesterday           # Periode analysee
# Service = All               # Services a analyser

# Test d'execution
sudo logwatch --detail High --range yesterday --print

# Execution avec envoi mail
sudo logwatch --detail High --range yesterday --mailto admin@domain.com
```

#### Personnalisation de logwatch
```bash
# Services personnalises
ls /usr/share/logwatch/scripts/services/

# Configuration par service
ls /etc/logwatch/conf/services/

# Exemple de configuration SSH
sudo nano /etc/logwatch/conf/services/sshd.conf

# Contenu :
*OnlyService = sshd
*RemoveHeaders
```

---

## Resume

### Fichiers de logs essentiels
```bash
# Logs systeme principaux
/var/log/syslog          # Messages generaux
/var/log/auth.log        # Authentifications
/var/log/kern.log        # Noyau
/var/log/cron.log        # Taches cron
/var/log/mail.log        # Mail

# Logs d'applications
/var/log/apache2/        # Apache
/var/log/nginx/          # Nginx
/var/log/mysql/          # MySQL
```

### Commandes journalctl essentielles
```bash
journalctl                    # Tous les logs
journalctl -u service         # Logs d'un service
journalctl -f                 # Suivi temps reel
journalctl -b                 # Boot actuel
journalctl --since yesterday  # Depuis hier
journalctl -p err             # Erreurs seulement
journalctl --disk-usage       # Espace utilise
```

### Commandes d'analyse des logs
```bash
# Navigation de base
tail -f /var/log/syslog      # Suivi temps reel
head -n 100 /var/log/auth.log   # 100 premieres lignes
less /var/log/syslog         # Navigation interactive

# Recherche et filtrage
grep "error" /var/log/syslog # Recherche simple
grep -c "Failed" /var/log/auth.log  # Compter occurrences
awk '/ERROR/,/END/' log.txt  # Recherche entre patterns
```

### Configuration importante
```bash
# systemd-journald
/etc/systemd/journald.conf   # Configuration journal
Storage=persistent           # Logs persistants
SystemMaxUse=1G             # Taille max

# rsyslog
/etc/rsyslog.conf           # Configuration principale
/etc/rsyslog.d/             # Configurations modulaires

# logrotate
/etc/logrotate.conf         # Configuration principale
/etc/logrotate.d/           # Configurations par service
```

### Maintenance des logs
```bash
# Nettoyage journal systemd
sudo journalctl --vacuum-time=30d    # Supprimer > 30 jours
sudo journalctl --vacuum-size=100M   # Limiter a 100MB

# Rotation manuelle
sudo logrotate -f /etc/logrotate.d/nginx  # Forcer rotation

# Monitoring espace disque
du -sh /var/log              # Taille totale
find /var/log -size +100M    # Fichiers > 100MB
```

### Patterns de recherche utiles
```bash
# Securite
grep "Failed password" /var/log/auth.log
grep "sudo" /var/log/auth.log
journalctl -g "authentication failure"

# Erreurs systeme
grep -i "error\|critical\|fail" /var/log/syslog
journalctl -p err --since yesterday

# Performance
grep "out of memory" /var/log/kern.log
journalctl -g "killed process"
```

### Bonnes pratiques
- **Surveillance reguliere** : verifier les logs quotidiennement
- **Rotation configuree** : eviter l'explosion de l'espace disque
- **Alertes automatisees** : scripts pour detecter anomalies
- **Sauvegarde logs critiques** : conserver traces importantes
- **Analyse proactive** : detecter problemes avant escalade
- **Centralisation** : considerer serveur de logs central pour infrastructures

---

**Temps de lecture estime** : 35-40 minutes
**Niveau** : Intermediaire a avance
**Pre-requis** : Administration Linux de base, systemd, navigation fichiers