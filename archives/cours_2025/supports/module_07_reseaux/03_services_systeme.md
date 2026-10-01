# Services systeme avec systemctl

## Objectifs d'apprentissage
- Comprendre le gestionnaire de services systemd
- Utiliser systemctl pour gerer les services
- Configurer le demarrage automatique des services
- Analyser les logs des services avec journalctl
- Creer et personnaliser des services simples

## Introduction

**systemd** est le systeme d'init moderne utilise par la plupart des distributions Linux recentes. Il remplace les anciens systemes SysV init et permet une gestion avancee des services systeme avec `systemctl`.

---

## 1. Comprendre systemd et les services

### Concepts fondamentaux

#### Qu'est-ce que systemd ?
- **Systeme d'init** : premier processus (PID 1) lance au boot
- **Gestionnaire de services** : controle des demons systeme
- **Gestionnaire de sessions** : gestion des connexions utilisateur
- **Ordonnanceur** : demarre les services dans l'ordre correct

#### Types d'unites systemd
```bash
# Voir tous les types d'unites
systemctl list-unit-files --type=help

# Types principaux :
.service    # Services (demons, processus)
.target     # Groupes de services (runlevels)
.mount      # Points de montage
.socket     # Sockets reseau/IPC
.timer      # Taches programmees (remplace cron)
.path       # Surveillance de fichiers/repertoires
```

### Architecture des services systemd

#### Emplacements des fichiers
```bash
# Services systeme (ne pas modifier)
/lib/systemd/system/
/usr/lib/systemd/system/

# Services systeme locaux
/etc/systemd/system/

# Services utilisateur
~/.config/systemd/user/
/usr/lib/systemd/user/

# Priorite : /etc/systemd/system/ > /lib/systemd/system/
```

---

## 2. Commande systemctl - Gestion des services

### Controle de base des services

#### Etats des services
```bash
# Voir l'etat d'un service
systemctl status nginx
systemctl status ssh
systemctl status apache2

# Verifier si un service est actif
systemctl is-active nginx
systemctl is-enabled nginx    # Demarrage automatique ?
systemctl is-failed nginx     # En echec ?
```

#### Demarrer/Arreter les services
```bash
# Demarrer un service
sudo systemctl start nginx
sudo systemctl start ssh

# Arreter un service
sudo systemctl stop nginx
sudo systemctl stop apache2

# Redemarrer un service
sudo systemctl restart nginx

# Recharger la configuration (sans redemarrer)
sudo systemctl reload nginx
sudo systemctl reload-or-restart nginx  # Reload ou restart si reload impossible
```

#### Activation/Desactivation au demarrage
```bash
# Activer au demarrage
sudo systemctl enable nginx
sudo systemctl enable ssh

# Desactiver au demarrage  
sudo systemctl disable apache2

# Activer et demarrer en une commande
sudo systemctl enable --now nginx

# Desactiver et arreter
sudo systemctl disable --now apache2

# Masquer completement un service (empecher demarrage)
sudo systemctl mask apache2
sudo systemctl unmask apache2  # Reactiver
```

### Lister et rechercher des services

#### Lister les services
```bash
# Tous les services
systemctl list-units --type=service

# Services actifs seulement
systemctl list-units --type=service --state=active

# Services en echec
systemctl list-units --type=service --state=failed

# Services actives au demarrage
systemctl list-unit-files --type=service --state=enabled

# Format plus compact
systemctl list-units --type=service --no-pager
```

#### Rechercher des services
```bash
# Recherche par nom
systemctl list-units | grep nginx
systemctl list-unit-files | grep apache

# Recherche avec patterns
systemctl list-units '*ssh*'
systemctl list-units 'network*'

# Services lies au reseau
systemctl list-units --type=service | grep -E "(network|ssh|ftp|web)"
```

### Analyse detaillee des services

#### Informations detaillees
```bash
# Etat complet d'un service
systemctl status nginx -l    # Lignes completes
systemctl status nginx -n 50 # 50 dernieres lignes de log

# Proprietes d'un service
systemctl show nginx
systemctl show nginx --property=MainPID,LoadState,ActiveState

# Dependances d'un service
systemctl list-dependencies nginx
systemctl list-dependencies nginx --reverse  # Qui depend de nginx
```

#### Processus lies aux services
```bash
# Processus d'un service
systemctl status nginx | grep "Main PID"
ps aux | grep nginx

# Arbre des processus d'un service
systemd-cgls nginx.service

# Ressources utilisees
systemd-cgtop    # Top des services systemd
```

---

## 3. Configuration et targets

### Targets systemd (runlevels)

#### Comprendre les targets
```bash
# Target actuel
systemctl get-default

# Changer de target temporairement
sudo systemctl isolate multi-user.target
sudo systemctl isolate graphical.target

# Changer target par defaut
sudo systemctl set-default multi-user.target
sudo systemctl set-default graphical.target

# Targets principales
systemctl list-units --type=target

# Correspondance anciens runlevels :
# runlevel 0 -> poweroff.target
# runlevel 1 -> rescue.target
# runlevel 2,3,4 -> multi-user.target
# runlevel 5 -> graphical.target
# runlevel 6 -> reboot.target
```

#### Services par target
```bash
# Voir quels services sont dans une target
systemctl list-dependencies multi-user.target
systemctl list-dependencies graphical.target

# Services qui demarrent avec le systeme
systemctl list-dependencies default.target
```

### Configuration systeme avec systemctl

#### Controle du systeme
```bash
# Redemarrer le systeme
sudo systemctl reboot

# Arreter le systeme
sudo systemctl poweroff
sudo systemctl halt

# Mode rescue (single user)
sudo systemctl rescue

# Mode emergency
sudo systemctl emergency

# Suspendre/Hibernation
sudo systemctl suspend
sudo systemctl hibernate
sudo systemctl hybrid-sleep
```

#### Recharger systemd
```bash
# Recharger systemd apres changement de configuration
sudo systemctl daemon-reload

# Necessaire apres :
# - Modification de fichiers .service
# - Creation de nouveaux services
# - Modification des dependances
```

---

## 4. Logs des services avec journalctl

### Utilisation de base de journalctl

#### Consulter les logs
```bash
# Tous les logs systeme
journalctl

# Logs d'un service specifique
journalctl -u nginx
journalctl -u ssh.service
journalctl -u apache2.service

# Logs en temps reel (comme tail -f)
journalctl -u nginx -f
journalctl -f    # Tous les services
```

#### Filtrage par temps
```bash
# Depuis aujourd'hui
journalctl --since today

# Depuis hier
journalctl --since yesterday

# Periode specifique
journalctl --since "2023-12-01" --until "2023-12-31"
journalctl --since "1 hour ago"
journalctl --since "30 min ago"

# Logs de demarrage
journalctl -b              # Boot actuel
journalctl -b -1           # Boot precedent
journalctl --list-boots    # Lister tous les boots
```

### Options avancees de journalctl

#### Niveaux de log
```bash
# Par niveau de priorite
journalctl -p err          # Erreurs seulement
journalctl -p warning      # Avertissements et plus grave
journalctl -p info         # Informations et plus grave

# Niveaux disponibles :
# emerg, alert, crit, err, warning, notice, info, debug
```

#### Format et affichage
```bash
# Format JSON
journalctl -u nginx -o json

# Format compact
journalctl -u nginx -o short

# Sans pagination
journalctl -u nginx --no-pager

# Nombres de lignes
journalctl -u nginx -n 50        # 50 dernieres lignes
journalctl -u nginx --lines=100  # 100 dernieres lignes

# Inverser l'ordre (plus recent en premier)
journalctl -u nginx -r
```

#### Filtrage avance
```bash
# Par PID
journalctl _PID=1234

# Par utilisateur
journalctl _UID=1000

# Par executable
journalctl /usr/sbin/nginx

# Recherche de texte
journalctl -u nginx | grep "error"
journalctl -g "Failed password"    # Grep integre

# Statistiques
journalctl --disk-usage           # Espace utilise par les logs
journalctl --vacuum-time=30d      # Supprimer logs > 30 jours
journalctl --vacuum-size=100M     # Limiter a 100MB
```

---

## 5. Creation de services personnalises

### Structure d'un fichier de service

#### Service simple
```bash
# Creer un fichier de service
sudo nano /etc/systemd/system/mon-service.service

# Contenu type :
[Unit]
Description=Mon service personnalise
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/mon-app
ExecStart=/opt/mon-app/start.sh
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=10

[Install]  
WantedBy=multi-user.target
```

#### Sections et directives importantes

##### Section [Unit]
```bash
Description=         # Description du service
After=              # Demarrer apres ces services
Before=             # Demarrer avant ces services
Requires=           # Dependances obligatoires
Wants=              # Dependances recommandees
Conflicts=          # Services incompatibles
```

##### Section [Service]
```bash
Type=               # simple, forking, oneshot, notify, idle
User=               # Utilisateur d'execution
Group=              # Groupe d'execution
WorkingDirectory=   # Repertoire de travail
ExecStart=          # Commande de demarrage
ExecStop=           # Commande d'arret
ExecReload=         # Commande de rechargement
Restart=            # always, on-failure, no, on-success
RestartSec=         # Delai avant redemarrage (secondes)
Environment=        # Variables d'environnement
EnvironmentFile=    # Fichier de variables
```

##### Section [Install]
```bash
WantedBy=           # Target qui active ce service
RequiredBy=         # Target qui necessite ce service
Alias=              # Noms alternatifs
```

### Exemples de services personnalises

#### Service web Python simple
```bash
# /etc/systemd/system/webapp.service
[Unit]
Description=Application Web Python
After=network.target

[Service]
Type=simple
User=webapp
Group=webapp
WorkingDirectory=/opt/webapp
Environment=PYTHONPATH=/opt/webapp
ExecStart=/usr/bin/python3 /opt/webapp/app.py
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

#### Service de sauvegarde
```bash
# /etc/systemd/system/backup-daily.service
[Unit]
Description=Sauvegarde quotidienne
Wants=backup-daily.timer

[Service]
Type=oneshot
User=backup
ExecStart=/usr/local/bin/backup-script.sh
StandardOutput=journal
StandardError=journal

# Timer associe : /etc/systemd/system/backup-daily.timer
[Unit]
Description=Execute la sauvegarde quotidienne
Requires=backup-daily.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

#### Service avec fichier d'environnement
```bash
# Service : /etc/systemd/system/myapp.service
[Unit]
Description=Mon application
After=network.target postgresql.service

[Service]
Type=simple
User=myapp
WorkingDirectory=/opt/myapp
EnvironmentFile=/etc/myapp/environment
ExecStart=/opt/myapp/bin/server
Restart=on-failure

[Install]
WantedBy=multi-user.target

# Fichier d'environnement : /etc/myapp/environment
DATABASE_URL=postgresql://user:pass@localhost/mydb
API_KEY=secret_key_here
DEBUG=false
PORT=8080
```

### Activation et test des services personnalises

#### Deploiement d'un service
```bash
# 1. Creer le fichier .service
sudo nano /etc/systemd/system/mon-service.service

# 2. Recharger systemd
sudo systemctl daemon-reload

# 3. Activer le service
sudo systemctl enable mon-service.service

# 4. Demarrer le service
sudo systemctl start mon-service

# 5. Verifier l'etat
systemctl status mon-service

# 6. Voir les logs
journalctl -u mon-service -f
```

#### Tests et validation
```bash
# Test de syntaxe (systemd recent)
systemd-analyze verify /etc/systemd/system/mon-service.service

# Test de demarrage
sudo systemctl start mon-service
systemctl is-active mon-service

# Test d'activation automatique
sudo systemctl disable mon-service
sudo systemctl enable mon-service
systemctl is-enabled mon-service

# Test de redemarrage apres crash
sudo kill -9 $(systemctl show --property=MainPID --value mon-service)
sleep 5
systemctl status mon-service  # Doit etre redemarre automatiquement
```

---

## 6. Cas pratiques et depannage

### Gestion des services courants

#### Services web
```bash
# Apache
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl reload apache2      # Recharger config
journalctl -u apache2 -f           # Logs en temps reel

# Nginx  
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl reload nginx
nginx -t                           # Test configuration
journalctl -u nginx -f

# PHP-FPM
sudo systemctl enable php7.4-fpm
sudo systemctl start php7.4-fpm
systemctl status php7.4-fpm
```

#### Services de base de donnees
```bash
# MySQL/MariaDB
sudo systemctl enable mysql
sudo systemctl start mysql
systemctl status mysql
journalctl -u mysql -n 50

# PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql
systemctl status postgresql
sudo -u postgres psql -c "SELECT version();"

# MongoDB
sudo systemctl enable mongod
sudo systemctl start mongod
systemctl status mongod
```

#### Services systeme essentiels
```bash
# SSH
systemctl status ssh
sudo systemctl enable ssh

# Cron
systemctl status cron
journalctl -u cron

# Rsyslog
systemctl status rsyslog
journalctl -u rsyslog

# NetworkManager
systemctl status NetworkManager
journalctl -u NetworkManager -f
```

### Depannage des services

#### Service qui ne demarre pas
```bash
# Etapes de diagnostic
# 1. Verifier l'etat detaille
systemctl status monservice -l

# 2. Voir les logs complets
journalctl -u monservice -n 100

# 3. Verifier la configuration
systemd-analyze verify /etc/systemd/system/monservice.service

# 4. Verifier les permissions
ls -la /etc/systemd/system/monservice.service

# 5. Test manuel de la commande
sudo -u serviceuser /path/to/command

# 6. Verifier les dependances
systemctl list-dependencies monservice
```

#### Service qui s'arrete de facon inattendue
```bash
# Analyser les logs lors de l'arret
journalctl -u monservice --since "10 minutes ago"

# Voir les signaux recus
journalctl -u monservice | grep -i signal

# Verifier la configuration restart
systemctl show monservice --property=Restart,RestartSec

# Monitoring continu
watch -n 5 'systemctl status monservice'
```

#### Performance et ressources
```bash
# Ressources utilisees par les services
systemd-cgtop

# Detail d'un service
systemctl show monservice --property=MemoryCurrent,CPUUsageNSec

# Limiter les ressources d'un service
# Dans le fichier .service :
[Service]
MemoryLimit=512M
CPUQuota=50%
```

### Scripts d'administration

#### Script de monitoring des services
```bash
#!/bin/bash
# service_monitor.sh - Surveillance des services critiques

SERVICES=("nginx" "mysql" "ssh" "cron")
LOG_FILE="/var/log/service_monitor.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

check_service() {
    local service="$1"
    
    if systemctl is-active --quiet "$service"; then
        log_message "[OK] $service: OK"
        return 0
    else
        log_message "[NOK] $service: ECHEC - Tentative de redemarrage"
        
        # Tentative de redemarrage
        if sudo systemctl restart "$service"; then
            sleep 5
            if systemctl is-active --quiet "$service"; then
                log_message "[OK] $service: Redemarre avec succes"
                return 0
            fi
        fi
        
        log_message "[NOK] $service: Impossible de redemarrer"
        return 1
    fi
}

main() {
    log_message "Debut du monitoring des services"
    local failed_services=()
    
    for service in "${SERVICES[@]}"; do
        if ! check_service "$service"; then
            failed_services+=("$service")
        fi
    done
    
    if [ ${#failed_services[@]} -gt 0 ]; then
        log_message "ALERTE: Services en echec: ${failed_services[*]}"
        # Envoyer email d'alerte si configure
        echo "Services en echec sur $(hostname): ${failed_services[*]}" | \
            mail -s "Alerte services systeme" admin@domain.com 2>/dev/null
    fi
    
    log_message "Fin du monitoring"
}

main
```

#### Script de deploiement de service
```bash
#!/bin/bash
# deploy_service.sh - Deploiement automatise de service

SERVICE_NAME="$1"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <service_name>"
    exit 1
fi

deploy_service() {
    echo "Deploiement du service $SERVICE_NAME..."
    
    # Arreter l'ancien service s'il existe
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "Arret de l'ancien service..."
        sudo systemctl stop "$SERVICE_NAME"
    fi
    
    # Sauvegarder l'ancienne configuration
    if [ -f "$SERVICE_FILE" ]; then
        sudo cp "$SERVICE_FILE" "${SERVICE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Copier le nouveau fichier de service
    sudo cp "./${SERVICE_NAME}.service" "$SERVICE_FILE"
    
    # Recharger systemd
    sudo systemctl daemon-reload
    
    # Activer et demarrer
    sudo systemctl enable "$SERVICE_NAME"
    sudo systemctl start "$SERVICE_NAME"
    
    # Verifier le demarrage
    sleep 3
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "[OK] Service $SERVICE_NAME deploye avec succes"
        systemctl status "$SERVICE_NAME" --no-pager
    else
        echo "[NOK] Echec du deploiement"
        journalctl -u "$SERVICE_NAME" -n 20 --no-pager
        exit 1
    fi
}

deploy_service
```

---

## Resume

### Commandes systemctl essentielles
```bash
# Controle des services
sudo systemctl start service     # Demarrer
sudo systemctl stop service      # Arreter  
sudo systemctl restart service   # Redemarrer
sudo systemctl reload service    # Recharger config
sudo systemctl status service    # Etat du service

# Activation au demarrage
sudo systemctl enable service    # Activer au boot
sudo systemctl disable service   # Desactiver au boot
sudo systemctl enable --now service  # Activer + demarrer

# Information et listing
systemctl list-units --type=service     # Tous les services
systemctl list-units --state=failed     # Services en echec
systemctl is-active service             # Verifier si actif
systemctl is-enabled service            # Verifier si active
```

### Commandes journalctl essentielles
```bash
# Consultation des logs
journalctl -u service              # Logs d'un service
journalctl -u service -f           # En temps reel
journalctl -u service -n 50        # 50 dernieres lignes
journalctl --since today          # Depuis aujourd'hui
journalctl -p err                  # Erreurs seulement
```

### Structure de service systemd
```bash
[Unit]
Description=Description du service
After=network.target

[Service]  
Type=simple
User=username
ExecStart=/path/to/command
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### Targets principales
- **poweroff.target** : Arret systeme
- **rescue.target** : Mode rescue (single user)
- **multi-user.target** : Multi-utilisateur, pas de GUI
- **graphical.target** : Multi-utilisateur avec GUI
- **reboot.target** : Redemarrage

### Workflow de creation de service
1. **Creer** le fichier .service dans `/etc/systemd/system/`
2. **Recharger** systemd : `sudo systemctl daemon-reload`
3. **Activer** : `sudo systemctl enable service`
4. **Demarrer** : `sudo systemctl start service`
5. **Verifier** : `systemctl status service`
6. **Tester** : `journalctl -u service -f`

### Bonnes pratiques
- **Utilisateurs specifiques** : ne pas executer en root sauf necessite
- **Restart policies** : configurer redemarrage automatique
- **Logs structures** : utiliser journalctl plutot que fichiers
- **Tests** : valider les services avant deploiement
- **Sauvegarde config** : garder les anciennes configurations
- **Monitoring** : surveiller les services critiques

---

**Temps de lecture estime** : 30-35 minutes
**Niveau** : Intermediaire
**Pre-requis** : Administration de base Linux, notions de services systeme