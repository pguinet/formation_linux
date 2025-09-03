# Module 7.3 : Services système avec systemctl

## Objectifs d'apprentissage
- Comprendre le gestionnaire de services systemd
- Utiliser systemctl pour gérer les services
- Configurer le démarrage automatique des services
- Analyser les logs des services avec journalctl
- Créer et personnaliser des services simples

## Introduction

**systemd** est le système d'init moderne utilisé par la plupart des distributions Linux récentes. Il remplace les anciens systèmes SysV init et permet une gestion avancée des services système avec `systemctl`.

---

## 1. Comprendre systemd et les services

### Concepts fondamentaux

#### Qu'est-ce que systemd ?
- **Système d'init** : premier processus (PID 1) lancé au boot
- **Gestionnaire de services** : contrôle des démons système
- **Gestionnaire de sessions** : gestion des connexions utilisateur
- **Ordonnanceur** : démarre les services dans l'ordre correct

#### Types d'unités systemd
```bash
# Voir tous les types d'unités
systemctl list-unit-files --type=help

# Types principaux :
.service    # Services (démons, processus)
.target     # Groupes de services (runlevels)
.mount      # Points de montage
.socket     # Sockets réseau/IPC
.timer      # Tâches programmées (remplace cron)
.path       # Surveillance de fichiers/répertoires
```

### Architecture des services systemd

#### Emplacements des fichiers
```bash
# Services système (ne pas modifier)
/lib/systemd/system/
/usr/lib/systemd/system/

# Services système locaux
/etc/systemd/system/

# Services utilisateur
~/.config/systemd/user/
/usr/lib/systemd/user/

# Priorité : /etc/systemd/system/ > /lib/systemd/system/
```

---

## 2. Commande systemctl - Gestion des services

### Contrôle de base des services

#### États des services
```bash
# Voir l'état d'un service
systemctl status nginx
systemctl status ssh
systemctl status apache2

# Vérifier si un service est actif
systemctl is-active nginx
systemctl is-enabled nginx    # Démarrage automatique ?
systemctl is-failed nginx     # En échec ?
```

#### Démarrer/Arrêter les services
```bash
# Démarrer un service
sudo systemctl start nginx
sudo systemctl start ssh

# Arrêter un service
sudo systemctl stop nginx
sudo systemctl stop apache2

# Redémarrer un service
sudo systemctl restart nginx

# Recharger la configuration (sans redémarrer)
sudo systemctl reload nginx
sudo systemctl reload-or-restart nginx  # Reload ou restart si reload impossible
```

#### Activation/Désactivation au démarrage
```bash
# Activer au démarrage
sudo systemctl enable nginx
sudo systemctl enable ssh

# Désactiver au démarrage  
sudo systemctl disable apache2

# Activer et démarrer en une commande
sudo systemctl enable --now nginx

# Désactiver et arrêter
sudo systemctl disable --now apache2

# Masquer complètement un service (empêcher démarrage)
sudo systemctl mask apache2
sudo systemctl unmask apache2  # Réactiver
```

### Lister et rechercher des services

#### Lister les services
```bash
# Tous les services
systemctl list-units --type=service

# Services actifs seulement
systemctl list-units --type=service --state=active

# Services en échec
systemctl list-units --type=service --state=failed

# Services activés au démarrage
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

# Services liés au réseau
systemctl list-units --type=service | grep -E "(network|ssh|ftp|web)"
```

### Analyse détaillée des services

#### Informations détaillées
```bash
# État complet d'un service
systemctl status nginx -l    # Lignes complètes
systemctl status nginx -n 50 # 50 dernières lignes de log

# Propriétés d'un service
systemctl show nginx
systemctl show nginx --property=MainPID,LoadState,ActiveState

# Dépendances d'un service
systemctl list-dependencies nginx
systemctl list-dependencies nginx --reverse  # Qui dépend de nginx
```

#### Processus liés aux services
```bash
# Processus d'un service
systemctl status nginx | grep "Main PID"
ps aux | grep nginx

# Arbre des processus d'un service
systemd-cgls nginx.service

# Ressources utilisées
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

# Changer target par défaut
sudo systemctl set-default multi-user.target
sudo systemctl set-default graphical.target

# Targets principales
systemctl list-units --type=target

# Correspondance anciens runlevels :
# runlevel 0 → poweroff.target
# runlevel 1 → rescue.target
# runlevel 2,3,4 → multi-user.target
# runlevel 5 → graphical.target
# runlevel 6 → reboot.target
```

#### Services par target
```bash
# Voir quels services sont dans une target
systemctl list-dependencies multi-user.target
systemctl list-dependencies graphical.target

# Services qui démarrent avec le système
systemctl list-dependencies default.target
```

### Configuration système avec systemctl

#### Contrôle du système
```bash
# Redémarrer le système
sudo systemctl reboot

# Arrêter le système
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
# Recharger systemd après changement de configuration
sudo systemctl daemon-reload

# Nécessaire après :
# - Modification de fichiers .service
# - Création de nouveaux services
# - Modification des dépendances
```

---

## 4. Logs des services avec journalctl

### Utilisation de base de journalctl

#### Consulter les logs
```bash
# Tous les logs système
journalctl

# Logs d'un service spécifique
journalctl -u nginx
journalctl -u ssh.service
journalctl -u apache2.service

# Logs en temps réel (comme tail -f)
journalctl -u nginx -f
journalctl -f    # Tous les services
```

#### Filtrage par temps
```bash
# Depuis aujourd'hui
journalctl --since today

# Depuis hier
journalctl --since yesterday

# Période spécifique
journalctl --since "2023-12-01" --until "2023-12-31"
journalctl --since "1 hour ago"
journalctl --since "30 min ago"

# Logs de démarrage
journalctl -b              # Boot actuel
journalctl -b -1           # Boot précédent
journalctl --list-boots    # Lister tous les boots
```

### Options avancées de journalctl

#### Niveaux de log
```bash
# Par niveau de priorité
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
journalctl -u nginx -n 50        # 50 dernières lignes
journalctl -u nginx --lines=100  # 100 dernières lignes

# Inverser l'ordre (plus récent en premier)
journalctl -u nginx -r
```

#### Filtrage avancé
```bash
# Par PID
journalctl _PID=1234

# Par utilisateur
journalctl _UID=1000

# Par exécutable
journalctl /usr/sbin/nginx

# Recherche de texte
journalctl -u nginx | grep "error"
journalctl -g "Failed password"    # Grep intégré

# Statistiques
journalctl --disk-usage           # Espace utilisé par les logs
journalctl --vacuum-time=30d      # Supprimer logs > 30 jours
journalctl --vacuum-size=100M     # Limiter à 100MB
```

---

## 5. Création de services personnalisés

### Structure d'un fichier de service

#### Service simple
```bash
# Créer un fichier de service
sudo nano /etc/systemd/system/mon-service.service

# Contenu type :
[Unit]
Description=Mon service personnalisé
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
After=              # Démarrer après ces services
Before=             # Démarrer avant ces services
Requires=           # Dépendances obligatoires
Wants=              # Dépendances recommandées
Conflicts=          # Services incompatibles
```

##### Section [Service]
```bash
Type=               # simple, forking, oneshot, notify, idle
User=               # Utilisateur d'exécution
Group=              # Groupe d'exécution
WorkingDirectory=   # Répertoire de travail
ExecStart=          # Commande de démarrage
ExecStop=           # Commande d'arrêt
ExecReload=         # Commande de rechargement
Restart=            # always, on-failure, no, on-success
RestartSec=         # Délai avant redémarrage (secondes)
Environment=        # Variables d'environnement
EnvironmentFile=    # Fichier de variables
```

##### Section [Install]
```bash
WantedBy=           # Target qui active ce service
RequiredBy=         # Target qui nécessite ce service
Alias=              # Noms alternatifs
```

### Exemples de services personnalisés

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

# Timer associé : /etc/systemd/system/backup-daily.timer
[Unit]
Description=Exécute la sauvegarde quotidienne
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

### Activation et test des services personnalisés

#### Déploiement d'un service
```bash
# 1. Créer le fichier .service
sudo nano /etc/systemd/system/mon-service.service

# 2. Recharger systemd
sudo systemctl daemon-reload

# 3. Activer le service
sudo systemctl enable mon-service.service

# 4. Démarrer le service
sudo systemctl start mon-service

# 5. Vérifier l'état
systemctl status mon-service

# 6. Voir les logs
journalctl -u mon-service -f
```

#### Tests et validation
```bash
# Test de syntaxe (systemd récent)
systemd-analyze verify /etc/systemd/system/mon-service.service

# Test de démarrage
sudo systemctl start mon-service
systemctl is-active mon-service

# Test d'activation automatique
sudo systemctl disable mon-service
sudo systemctl enable mon-service
systemctl is-enabled mon-service

# Test de redémarrage après crash
sudo kill -9 $(systemctl show --property=MainPID --value mon-service)
sleep 5
systemctl status mon-service  # Doit être redémarré automatiquement
```

---

## 6. Cas pratiques et dépannage

### Gestion des services courants

#### Services web
```bash
# Apache
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl reload apache2      # Recharger config
journalctl -u apache2 -f           # Logs en temps réel

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

#### Services de base de données
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

#### Services système essentiels
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

### Dépannage des services

#### Service qui ne démarre pas
```bash
# Étapes de diagnostic
# 1. Vérifier l'état détaillé
systemctl status monservice -l

# 2. Voir les logs complets
journalctl -u monservice -n 100

# 3. Vérifier la configuration
systemd-analyze verify /etc/systemd/system/monservice.service

# 4. Vérifier les permissions
ls -la /etc/systemd/system/monservice.service

# 5. Test manuel de la commande
sudo -u serviceuser /path/to/command

# 6. Vérifier les dépendances
systemctl list-dependencies monservice
```

#### Service qui s'arrête de façon inattendue
```bash
# Analyser les logs lors de l'arrêt
journalctl -u monservice --since "10 minutes ago"

# Voir les signaux reçus
journalctl -u monservice | grep -i signal

# Vérifier la configuration restart
systemctl show monservice --property=Restart,RestartSec

# Monitoring continu
watch -n 5 'systemctl status monservice'
```

#### Performance et ressources
```bash
# Ressources utilisées par les services
systemd-cgtop

# Détail d'un service
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
        log_message "✅ $service: OK"
        return 0
    else
        log_message "❌ $service: ÉCHEC - Tentative de redémarrage"
        
        # Tentative de redémarrage
        if sudo systemctl restart "$service"; then
            sleep 5
            if systemctl is-active --quiet "$service"; then
                log_message "✅ $service: Redémarré avec succès"
                return 0
            fi
        fi
        
        log_message "❌ $service: Impossible de redémarrer"
        return 1
    fi
}

main() {
    log_message "Début du monitoring des services"
    local failed_services=()
    
    for service in "${SERVICES[@]}"; do
        if ! check_service "$service"; then
            failed_services+=("$service")
        fi
    done
    
    if [ ${#failed_services[@]} -gt 0 ]; then
        log_message "ALERTE: Services en échec: ${failed_services[*]}"
        # Envoyer email d'alerte si configuré
        echo "Services en échec sur $(hostname): ${failed_services[*]}" | \
            mail -s "Alerte services système" admin@domain.com 2>/dev/null
    fi
    
    log_message "Fin du monitoring"
}

main
```

#### Script de déploiement de service
```bash
#!/bin/bash
# deploy_service.sh - Déploiement automatisé de service

SERVICE_NAME="$1"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <service_name>"
    exit 1
fi

deploy_service() {
    echo "Déploiement du service $SERVICE_NAME..."
    
    # Arrêter l'ancien service s'il existe
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "Arrêt de l'ancien service..."
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
    
    # Activer et démarrer
    sudo systemctl enable "$SERVICE_NAME"
    sudo systemctl start "$SERVICE_NAME"
    
    # Vérifier le démarrage
    sleep 3
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "✅ Service $SERVICE_NAME déployé avec succès"
        systemctl status "$SERVICE_NAME" --no-pager
    else
        echo "❌ Échec du déploiement"
        journalctl -u "$SERVICE_NAME" -n 20 --no-pager
        exit 1
    fi
}

deploy_service
```

---

## Résumé

### Commandes systemctl essentielles
```bash
# Contrôle des services
sudo systemctl start service     # Démarrer
sudo systemctl stop service      # Arrêter  
sudo systemctl restart service   # Redémarrer
sudo systemctl reload service    # Recharger config
sudo systemctl status service    # État du service

# Activation au démarrage
sudo systemctl enable service    # Activer au boot
sudo systemctl disable service   # Désactiver au boot
sudo systemctl enable --now service  # Activer + démarrer

# Information et listing
systemctl list-units --type=service     # Tous les services
systemctl list-units --state=failed     # Services en échec
systemctl is-active service             # Vérifier si actif
systemctl is-enabled service            # Vérifier si activé
```

### Commandes journalctl essentielles
```bash
# Consultation des logs
journalctl -u service              # Logs d'un service
journalctl -u service -f           # En temps réel
journalctl -u service -n 50        # 50 dernières lignes
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
- **poweroff.target** : Arrêt système
- **rescue.target** : Mode rescue (single user)
- **multi-user.target** : Multi-utilisateur, pas de GUI
- **graphical.target** : Multi-utilisateur avec GUI
- **reboot.target** : Redémarrage

### Workflow de création de service
1. **Créer** le fichier .service dans `/etc/systemd/system/`
2. **Recharger** systemd : `sudo systemctl daemon-reload`
3. **Activer** : `sudo systemctl enable service`
4. **Démarrer** : `sudo systemctl start service`
5. **Vérifier** : `systemctl status service`
6. **Tester** : `journalctl -u service -f`

### Bonnes pratiques
- **Utilisateurs spécifiques** : ne pas exécuter en root sauf nécessité
- **Restart policies** : configurer redémarrage automatique
- **Logs structurés** : utiliser journalctl plutôt que fichiers
- **Tests** : valider les services avant déploiement
- **Sauvegarde config** : garder les anciennes configurations
- **Monitoring** : surveiller les services critiques

---

**Temps de lecture estimé** : 30-35 minutes
**Niveau** : Intermédiaire
**Pré-requis** : Administration de base Linux, notions de services système