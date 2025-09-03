# Module 5.3 : Sudo et sécurité

## Objectifs d'apprentissage
- Comprendre le principe et l'utilité de sudo
- Configurer sudo avec visudo
- Maîtriser la syntaxe des règles sudoers
- Appliquer les bonnes pratiques de sécurité
- Surveiller et auditer l'usage de sudo

## Introduction

**Sudo** (Super User DO) permet d'exécuter des commandes avec les privilèges d'autres utilisateurs (généralement root) de manière contrôlée et auditée. C'est l'alternative sécurisée à l'utilisation directe du compte root.

---

## 1. Principe de sudo

### Pourquoi sudo ?

#### Problèmes avec root direct
```bash
# ✗ Problèmes de sécurité avec root
su -                    # Session complète en root
# • Tous les droits pendant toute la session
# • Risque d'erreur catastrophique  
# • Pas de traçabilité des actions
# • Partage du mot de passe root
```

#### Avantages de sudo
```bash
# ✓ Avantages de sudo
sudo commande          # Élévation ponctuelle
# • Élévation temporaire et contrôlée
# • Traçabilité : qui a fait quoi, quand
# • Granularité : permissions par commande
# • Pas besoin du mot de passe root
# • Timeout automatique
```

### Fonctionnement de sudo
```
Utilisateur demande → sudo vérifie → /etc/sudoers → Autorise/Refuse
     ↓                    ↓              ↓              ↓
"sudo ls /root"    Règles définies   Configuration   Exécution ou erreur
```

---

## 2. Utilisation de base de sudo

### Syntaxe générale
```bash
sudo [options] commande [arguments]
```

### Exemples d'usage courant
```bash
# Exécuter une commande en tant que root
sudo apt update
sudo systemctl restart nginx
sudo cat /etc/shadow

# Basculer vers un shell root temporaire
sudo -i                # Shell login complet
sudo -s                # Shell simple
sudo su -               # Équivalent à su -

# Exécuter en tant qu'autre utilisateur
sudo -u alice cat /home/alice/private.txt
sudo -u www-data whoami

# Éditer un fichier avec ses permissions élevées
sudo nano /etc/hosts
sudoedit /etc/ssh/sshd_config    # Plus sécurisé
```

### Gestion de la cache des credentials
```bash
# Valider les credentials (demande le mot de passe)
sudo -v

# Invalider la cache (force re-saisie)
sudo -k

# Voir le statut de la cache
sudo -n true && echo "Cache valide" || echo "Cache expirée"

# Exécuter avec renouvellement forcé du mot de passe
sudo -K commande
```

### Options utiles
```bash
# -l : lister les permissions sudo de l'utilisateur
sudo -l

# -u user : exécuter en tant qu'utilisateur spécifique  
sudo -u alice whoami

# -g group : exécuter avec groupe spécifique
sudo -g admin id

# -H : définir HOME sur l'utilisateur cible
sudo -H -u alice bash

# -E : préserver les variables d'environnement
sudo -E python script.py

# --preserve-env=VAR : préserver des variables spécifiques
sudo --preserve-env=PATH,HOME commande
```

---

## 3. Configuration avec visudo

### Le fichier /etc/sudoers

#### Sécurité du fichier
```bash
# TOUJOURS utiliser visudo pour éditer
sudo visudo

# ✗ JAMAIS éditer directement
sudo nano /etc/sudoers  # DANGEREUX !

# Pourquoi visudo ?
# • Vérification syntaxique avant sauvegarde  
# • Verrouillage pendant édition
# • Récupération en cas d'erreur
```

#### Structure du fichier
```bash
# Exemple de /etc/sudoers
# Voir le contenu
sudo cat /etc/sudoers
```

### Syntaxe de base des règles

#### Format général
```
user_or_group HOST=(TARGET_USER:TARGET_GROUP) COMMANDS
```

#### Éléments détaillés
- **user_or_group** : qui peut exécuter
- **HOST** : sur quelles machines (généralement ALL)  
- **TARGET_USER** : en tant que quel utilisateur (défaut: root)
- **TARGET_GROUP** : avec quel groupe (optionnel)
- **COMMANDS** : quelles commandes

### Exemples de règles sudoers

#### Règles utilisateurs
```bash
# Accès root complet
alice ALL=(ALL:ALL) ALL

# Accès root avec mot de passe
bob ALL=(ALL) ALL

# Accès sans mot de passe (DANGEREUX en général)
charlie ALL=(ALL) NOPASSWD: ALL

# Commandes spécifiques seulement
dave ALL=(ALL) /usr/bin/systemctl, /usr/bin/apt

# Exécuter en tant qu'utilisateur spécifique
marie ALL=(www-data) /usr/bin/php, /bin/cat
```

#### Règles de groupes
```bash
# Membres du groupe sudo ont accès root
%sudo ALL=(ALL:ALL) ALL

# Groupe admin pour certaines commandes
%admin ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart *, /usr/bin/systemctl reload *

# Groupe developers pour les services web
%webdev ALL=(www-data) /usr/bin/php, /bin/chown
```

#### Règles avec restrictions
```bash
# Réseaux spécifiques
alice server1,server2=(ALL) ALL

# Exclusions de commandes
bob ALL=(ALL) ALL, !/bin/su, !/usr/bin/passwd root

# Horaires spécifiques (avec plugin)
charlie ALL=(ALL) NOPASSWD: /usr/bin/systemctl * apache2
```

---

## 4. Configuration avancée

### Alias pour simplifier les règles

#### Alias d'utilisateurs
```bash
# Définir des groupes d'utilisateurs
User_Alias ADMINS = alice, bob, charlie
User_Alias WEBDEV = marie, paul, sophie

# Utiliser les alias
ADMINS ALL=(ALL) ALL
WEBDEV ALL=(www-data) /usr/bin/php
```

#### Alias de commandes
```bash
# Grouper des commandes communes
Cmnd_Alias SERVICES = /usr/bin/systemctl start *, /usr/bin/systemctl stop *, /usr/bin/systemctl restart *
Cmnd_Alias NETWORKING = /sbin/ifconfig, /bin/netstat, /sbin/route
Cmnd_Alias PACKAGE_MGMT = /usr/bin/apt, /usr/bin/apt-get, /usr/bin/dpkg

# Utiliser les alias
%admin ALL=(ALL) SERVICES, NETWORKING
%developers ALL=(ALL) PACKAGE_MGMT
```

#### Alias d'hôtes
```bash
# Définir groupes de serveurs
Host_Alias WEBSERVERS = web1, web2, web3  
Host_Alias DATABASES = db1, db2

# Utiliser les alias
alice WEBSERVERS=(www-data) ALL
bob DATABASES=(mysql) ALL
```

### Options et paramètres

#### Variables de configuration
```bash
# Dans /etc/sudoers
Defaults env_reset                    # Nettoyer l'environnement
Defaults mail_badpass                 # Notifier les mauvais mots de passe
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults passwd_tries=3               # 3 essais de mot de passe max
Defaults passwd_timeout=5             # Timeout pour saisie mot de passe
Defaults timestamp_timeout=15         # Cache mot de passe 15 minutes
```

#### Paramètres par utilisateur/groupe
```bash
# Paramètres spécifiques pour un utilisateur
Defaults:alice timestamp_timeout=60, passwd_tries=5

# Paramètres pour un groupe
Defaults:%developers env_keep+="PYTHONPATH VIRTUAL_ENV"

# Paramètres par commande
Defaults!/usr/bin/passwd !env_reset   # Garder l'environnement pour passwd
```

### Fichiers sudoers.d

#### Organisation modulaire
```bash
# Répertoire des configurations additionnelles
ls /etc/sudoers.d/

# Créer des fichiers spécifiques par service/groupe
sudo visudo -f /etc/sudoers.d/webdev
sudo visudo -f /etc/sudoers.d/database-admins
sudo visudo -f /etc/sudoers.d/monitoring
```

#### Exemple de fichier modulaire
```bash
# /etc/sudoers.d/webdev
# Configuration pour les développeurs web

User_Alias WEBDEVS = alice, bob, marie
Cmnd_Alias WEB_SERVICES = /usr/bin/systemctl * nginx, /usr/bin/systemctl * apache2
Cmnd_Alias WEB_TOOLS = /usr/bin/tail /var/log/nginx/*, /usr/bin/tail /var/log/apache2/*

WEBDEVS ALL=(www-data) NOPASSWD: WEB_SERVICES, WEB_TOOLS
WEBDEVS ALL=(ALL) /usr/bin/systemctl reload nginx, /usr/bin/systemctl reload apache2
```

---

## 5. Cas pratiques et scénarios

### Scenario 1 : Administrateur système junior
```bash
# Créer un utilisateur avec privilèges limités
sudo useradd -m -s /bin/bash junior-admin

# Configuration sudo spécifique
sudo visudo -f /etc/sudoers.d/junior-admin

# Contenu du fichier :
junior-admin ALL=(ALL) /usr/bin/systemctl status *
junior-admin ALL=(ALL) /usr/bin/systemctl start *, /usr/bin/systemctl stop *
junior-admin ALL=(ALL) /usr/bin/tail /var/log/*
junior-admin ALL=(ALL) /bin/cat /var/log/*
junior-admin ALL=(ALL) !/usr/bin/systemctl * ssh*, !/usr/bin/systemctl * networking
```

### Scenario 2 : Développeur avec accès base de données
```bash
# Configuration pour développeur accédant à MySQL
sudo visudo -f /etc/sudoers.d/db-developer

# Contenu :
Cmnd_Alias MYSQL_CMDS = /usr/bin/mysql, /usr/bin/mysqldump, /usr/bin/mysqlcheck
Cmnd_Alias MYSQL_SERVICE = /usr/bin/systemctl restart mysql, /usr/bin/systemctl reload mysql

alice ALL=(mysql) NOPASSWD: MYSQL_CMDS
alice ALL=(ALL) MYSQL_SERVICE
```

### Scenario 3 : Utilisateur de sauvegarde automatisée
```bash
# Compte pour scripts de sauvegarde
sudo useradd -r -s /bin/bash backup-user

# Configuration sudo
sudo visudo -f /etc/sudoers.d/backup-system  

# Contenu :
backup-user ALL=(ALL) NOPASSWD: /bin/tar, /usr/bin/rsync, /bin/cp
backup-user ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop *, /usr/bin/systemctl start *
backup-user ALL=(ALL) NOPASSWD: /usr/sbin/lvm*
```

### Scenario 4 : Monitoring et surveillance
```bash
# Utilisateur pour outils de monitoring
sudo visudo -f /etc/sudoers.d/monitoring

# Contenu :
Cmnd_Alias MONITORING = /bin/cat /proc/*, /usr/bin/netstat, /bin/ps, /usr/bin/top
Cmnd_Alias LOG_ACCESS = /usr/bin/tail /var/log/*, /bin/cat /var/log/*
Cmnd_Alias SYSTEM_INFO = /bin/df, /usr/bin/du, /usr/bin/free, /usr/bin/uptime

nagios ALL=(ALL) NOPASSWD: MONITORING, LOG_ACCESS, SYSTEM_INFO
```

---

## 6. Sécurité et bonnes pratiques

### Principe de moindre privilège

#### ✗ Configurations dangereuses à éviter
```bash
# Accès root total sans restriction (trop permissif)
alice ALL=(ALL) NOPASSWD: ALL

# Wildcards dangereux
bob ALL=(ALL) /bin/*          # Accès à tous les binaires !

# Commandes pouvant donner un shell
charlie ALL=(ALL) /bin/su, /usr/bin/sudo, /bin/bash
```

#### ✓ Bonnes pratiques
```bash
# Accès spécifique par tâche
alice ALL=(ALL) /usr/bin/systemctl restart nginx
alice ALL=(www-data) /usr/bin/php /var/www/scripts/deploy.php

# Grouper les permissions logiquement
%webdev ALL=(www-data) /usr/bin/composer, /usr/bin/npm, /usr/bin/yarn

# Utiliser des chemins absolus
bob ALL=(ALL) /usr/bin/apt update, /usr/bin/apt upgrade
```

### Configuration sécurisée

#### Paramètres de sécurité recommandés
```bash
# Dans /etc/sudoers
Defaults env_reset                    # Nettoyer l'environnement
Defaults use_pty                      # Utiliser un pseudo-terminal  
Defaults log_input, log_output        # Enregistrer tout
Defaults requiretty                   # Exiger un terminal (empêche scripts)
Defaults !visiblepw                   # Masquer mot de passe
Defaults always_set_home              # Définir HOME correctement
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
```

#### Variables d'environnement
```bash
# Variables sûres à préserver
Defaults env_keep += "LANG LANGUAGE LINGUAS LC_* _XKB_CHARSET"
Defaults env_keep += "HOME EDITOR VISUAL"

# Variables dangereuses à supprimer
Defaults env_delete += "LD_LIBRARY_PATH LD_PRELOAD"
```

### Authentification et sessions

#### Gestion des mots de passe
```bash
# Paramètres temporels  
Defaults timestamp_timeout=5          # Cache courte (5 minutes)
Defaults passwd_timeout=1             # 1 minute pour saisir mot de passe
Defaults passwd_tries=3               # Max 3 essais

# Par utilisateur
Defaults:alice timestamp_timeout=0    # Toujours demander le mot de passe
```

#### Restriction par terminal et réseau
```bash
# Seulement depuis console physique
alice console=(ALL) ALL

# Restriction réseau (avec plugin)
alice ALL=(ALL) ALL @ 192.168.1.0/24
```

---

## 7. Surveillance et audit

### Logs de sudo

#### Fichiers de logs
```bash
# Logs système généraux
sudo tail -f /var/log/auth.log | grep sudo

# Logs spécifiques sudo (si configurés)
sudo tail -f /var/log/sudo.log

# Avec syslog
tail -f /var/log/syslog | grep sudo
```

#### Configuration de logs avancés
```bash
# Dans /etc/sudoers - logs détaillés
Defaults log_input, log_output
Defaults iolog_dir="/var/log/sudo-io"
Defaults logfile="/var/log/sudo.log"
Defaults syslog=authpriv
```

### Surveillance en temps réel

#### Script de monitoring
```bash
#!/bin/bash
# monitor_sudo.sh - Surveillance des commandes sudo

# Suivre les logs en temps réel
tail -f /var/log/auth.log | while read line; do
    if echo "$line" | grep -q "COMMAND="; then
        echo "$(date): SUDO utilisé - $line" | \
        sed 's/.*USER=\([^[:space:]]*\).* COMMAND=\(.*\)/Utilisateur: \1, Commande: \2/'
    fi
done
```

#### Alertes automatiques
```bash
# Configuration syslog pour alertes
# Dans /etc/rsyslog.d/sudo.conf
authpriv.*  /var/log/sudo.log
authpriv.*  @@log-server.domain.com:514

# Script d'alerte sur commandes sensibles
#!/bin/bash
# sudo_alert.sh
tail -f /var/log/auth.log | grep "COMMAND=" | while read line; do
    if echo "$line" | grep -E "(rm -rf|dd if=|mkfs|fdisk)" > /dev/null; then
        echo "ALERTE: Commande dangereuse détectée: $line" | \
        mail -s "Alerte sudo dangereuse" admin@domain.com
    fi
done
```

### Audit et reporting

#### Rapport d'usage sudo
```bash
#!/bin/bash
# sudo_report.sh - Rapport d'usage sudo

echo "=== Rapport d'usage SUDO $(date) ==="
echo

echo "Utilisateurs avec accès sudo:"
grep -E "^[^#].*ALL.*ALL" /etc/sudoers /etc/sudoers.d/* 2>/dev/null | \
    cut -d: -f2 | awk '{print $1}' | sort -u

echo -e "\nCommandes sudo les plus utilisées (dernières 24h):"
grep "$(date -d '1 day ago' '+%b %d')" /var/log/auth.log | \
    grep "COMMAND=" | \
    sed 's/.*COMMAND=\([^[:space:]]*\).*/\1/' | \
    sort | uniq -c | sort -nr | head -10

echo -e "\nUtilisateurs sudo les plus actifs (dernières 24h):"  
grep "$(date -d '1 day ago' '+%b %d')" /var/log/auth.log | \
    grep "COMMAND=" | \
    sed 's/.*USER=\([^[:space:]]*\).*/\1/' | \
    sort | uniq -c | sort -nr | head -10

echo -e "\nCommandes sudo échouées (dernières 24h):"
grep "$(date -d '1 day ago' '+%b %d')" /var/log/auth.log | \
    grep "sudo.*authentication failure" | wc -l
```

---

## 8. Dépannage et résolution de problèmes

### Erreurs communes

#### "User is not in the sudoers file"
```bash
# Problème : utilisateur pas autorisé
sudo: alice is not in the sudoers file. This incident will be reported.

# Solutions :
# 1. Ajouter au groupe sudo (Debian/Ubuntu)  
sudo usermod -aG sudo alice

# 2. Ajouter au groupe wheel (CentOS/RHEL)
sudo usermod -aG wheel alice

# 3. Configuration directe dans sudoers
sudo visudo
# Ajouter : alice ALL=(ALL:ALL) ALL
```

#### "Sorry, try again" (mot de passe incorrect)
```bash
# Vérifications :
# 1. Mot de passe utilisateur (pas root)
whoami  # Confirmer l'utilisateur courant

# 2. Cache des credentials
sudo -k  # Invalider la cache
sudo -v  # Revalider

# 3. Configuration PAM
sudo cat /etc/pam.d/sudo
```

#### Problèmes de PATH
```bash
# Commande introuvable avec sudo
sudo: command-not-found: command not found

# Solution : vérifier secure_path
sudo grep secure_path /etc/sudoers

# Ou utiliser le chemin complet
sudo /full/path/to/command
```

### Tests et validation

#### Tester les règles sudo
```bash
# Voir ses permissions sudo
sudo -l

# Tester une règle spécifique
sudo -l -U alice                    # Permissions d'alice
sudo -l -U alice systemctl         # Permissions pour systemctl

# Simulation (dry-run)
sudo -v && echo "Authentification OK" || echo "Échec"
```

#### Validation du fichier sudoers
```bash
# Vérifier la syntaxe sans éditer
sudo visudo -c

# Tester avec un fichier spécifique
sudo visudo -c -f /etc/sudoers.d/webdev

# Mode debug  
sudo -D9 commande               # Maximum de debug info
```

### Récupération d'urgence

#### Fichier sudoers corrompu
```bash
# Méthode 1 : Boot en mode single user
# Au boot, ajouter 'single' aux paramètres kernel

# Méthode 2 : Utiliser su si mot de passe root connu
su -
visudo

# Méthode 3 : Boot depuis un LiveCD/USB
# Monter le système et éditer sudoers
```

---

## 9. Alternatives et outils complémentaires

### PolicyKit (pour desktop)
```bash
# Equivalent de sudo pour environnements graphiques
pkexec command

# Configuration dans /etc/polkit-1/
sudo cat /etc/polkit-1/localauthority/50-local.d/
```

### doas (alternative minimaliste)
```bash
# Installation sur certaines distributions
sudo apt install doas

# Configuration simple dans /etc/doas.conf
permit alice
permit alice as root
deny alice cmd /bin/su
```

### sudo-rs (réécriture en Rust)
```bash
# Alternative moderne avec meilleure sécurité
# Syntaxe compatible avec sudo traditionnel
```

---

## Résumé

### Commandes essentielles
```bash
sudo command           # Exécuter avec privilèges
sudo -l               # Lister permissions
sudo -u user command  # Exécuter comme utilisateur
sudo -i               # Shell root interactif
sudo -s               # Shell root simple
sudo -v               # Valider credentials
sudo -k               # Invalider cache
visudo                # Éditer sudoers sécurisé
```

### Configuration de base
```bash
# Fichier principal : /etc/sudoers
# Fichiers modulaires : /etc/sudoers.d/

# Syntaxe : USER HOST=(TARGET) COMMANDS
alice ALL=(ALL:ALL) ALL                    # Accès complet
bob ALL=(www-data) /usr/bin/php           # Commande spécifique
%admin ALL=(ALL) NOPASSWD: /usr/bin/systemctl   # Groupe sans mot de passe
```

### Sécurité
- **Principe de moindre privilège** : donner seulement les permissions nécessaires
- **Utiliser visudo** : toujours pour éditer les configurations  
- **Logs et audit** : surveiller l'usage de sudo
- **Éviter NOPASSWD** : sauf pour automatisation contrôlée
- **Chemins absolus** : utiliser des chemins complets dans les règles

### Bonnes pratiques
- **Modularité** : utiliser /etc/sudoers.d/ pour organiser
- **Test** : valider avec `sudo -l` et `visudo -c`
- **Documentation** : commenter les règles complexes  
- **Révision** : auditer régulièrement les permissions
- **Formation** : sensibiliser les utilisateurs aux bonnes pratiques

---

**Temps de lecture estimé** : 35-40 minutes
**Niveau** : Intermédiaire à avancé
**Pré-requis** : Modules 5.1 et 5.2 (Utilisateurs et permissions)