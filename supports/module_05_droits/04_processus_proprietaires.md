# Module 5.4 : Processus et propriétaires

## Objectifs d'apprentissage
- Comprendre la relation entre processus et utilisateurs
- Identifier le propriétaire d'un processus
- Gérer les processus selon leur propriétaire
- Comprendre les implications sécuritaires
- Surveiller et contrôler l'exécution des processus

## Introduction

Dans Linux, chaque processus s'exécute dans le contexte d'un utilisateur spécifique. Cette propriété détermine les droits et ressources auxquels le processus peut accéder. Comprendre cette relation est crucial pour la sécurité et l'administration système.

---

## 1. Concepts fondamentaux

### Processus et identité utilisateur

#### Identifiants associés à un processus
```bash
# Chaque processus a plusieurs identifiants :
# - Real UID (RUID) : utilisateur qui a lancé le processus
# - Effective UID (EUID) : utilisateur effectif (pour permissions)  
# - Saved UID (SUID) : sauvegarde de l'UID effectif

# Voir les UIDs d'un processus
ps -eo pid,ruid,euid,suid,comm | head -10
```

#### Héritage des processus
```
Processus parent (UID 1000)
    │
    └─ Processus enfant (hérite UID 1000)
        │
        └─ Petit-fils (hérite UID 1000)
```

### Principe de sécurité
- **Isolation** : Chaque processus ne peut accéder qu'aux ressources autorisées à son propriétaire
- **Contrôle** : Seul le propriétaire (ou root) peut contrôler ses processus
- **Audit** : Traçabilité des actions par utilisateur

---

## 2. Identifier les propriétaires des processus

### Commande `ps` - Processus et propriétaires

#### Options de base
```bash
# Format simple avec propriétaire
ps aux

# Colonnes explicites
ps -eo pid,ppid,user,group,comm,args

# Processus d'un utilisateur spécifique
ps -u alice
ps aux | grep "^alice"

# Avec informations détaillées sur les UIDs
ps -eo pid,ruid,euid,suid,user,comm
```

#### Exemple d'analyse
```bash
# Analyser les processus système
ps aux | head -20

# Sortie exemple :
# USER   PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root     1  0.0  0.1 225316  9012 ?        Ss   10:00   0:01 /sbin/init
# root     2  0.0  0.0      0     0 ?        S    10:00   0:00 [kthreadd]
# www-data 1234 0.1 0.5 123456 12345 ?       S    10:05   0:00 nginx: worker
# alice   5678  0.2  1.0 234567 23456 pts/0  S+   10:10   0:05 python script.py
```

### Commande `top` et `htop` - Vue dynamique

#### top avec colonnes utilisateur
```bash
# Lancer top et afficher la colonne utilisateur
top
# Appuyer sur 'f' pour configurer les colonnes
# Sélectionner USER, RUID, EUID pour affichage

# Filtrer par utilisateur dans top
top -u alice       # Seulement les processus d'alice
```

#### htop (plus convivial)
```bash
# Installation si nécessaire
sudo apt install htop

# Lancement avec vue utilisateur
htop
# F4 pour filtrer par utilisateur
# F5 pour vue en arbre (montre les relations parent/enfant)
```

### Processus par utilisateur - Statistiques

#### Compter les processus par utilisateur
```bash
# Nombre de processus par utilisateur
ps aux | awk '{print $1}' | sort | uniq -c | sort -nr

# Plus lisible
ps -eo user | sort | uniq -c | sort -nr | head -10

# Processus avec le plus de CPU par utilisateur
ps aux | sort -k3 -nr | head -10

# Processus avec le plus de mémoire par utilisateur  
ps aux | sort -k4 -nr | head -10
```

---

## 3. Processus système vs processus utilisateur

### Processus système (root et services)

#### Processus root critiques
```bash
# Processus essentiels du système
ps aux | grep "^root" | grep -E "(init|kernel|kthread|systemd)"

# Services système
ps aux | grep -E "(sshd|cron|rsyslog|NetworkManager)"

# Exemples typiques :
# root         1  /sbin/init              # Processus père de tous
# root       123  [kthreadd]              # Threads noyau
# root       456  /usr/sbin/sshd -D       # Démon SSH
# root       789  /usr/sbin/cron -f       # Démon cron
```

#### Utilisateurs système (services)
```bash
# Processus des utilisateurs système
ps aux | grep -E "^(www-data|mysql|postfix|nobody)"

# Exemples :
# www-data  1234  nginx: worker process
# mysql     5678  /usr/sbin/mysqld
# postfix   9012  /usr/lib/postfix/master
# nobody    3456  /usr/bin/dnsmasq
```

### Processus utilisateurs normaux

#### Identification des processus utilisateur
```bash
# Processus d'utilisateurs humains (UID >= 1000)
ps -eo pid,user,uid,comm | awk '$3 >= 1000 {print}'

# Sessions utilisateurs actives
ps aux | grep -E "^(alice|bob|charlie)"

# Processus graphiques typiques
ps aux | grep -E "(gnome|kde|xorg|firefox|chrome)"
```

---

## 4. Gestion des processus par propriétaire

### Signaux et contrôle des processus

#### Qui peut contrôler quels processus ?
```bash
# Règles de base :
# 1. Un utilisateur ne peut contrôler que SES processus
# 2. Root peut contrôler TOUS les processus
# 3. Exception : processus avec même EUID

# Tester les permissions
kill -0 PID    # Test si on peut envoyer un signal (sans le faire)
echo $?        # 0 = autorisé, 1 = refusé
```

#### Envoyer des signaux par propriétaire
```bash
# Terminer tous ses processus firefox
killall -u alice firefox

# Terminer proprement tous les processus d'un utilisateur
sudo pkill -TERM -u bob

# Forcer l'arrêt des processus d'un utilisateur (DANGEREUX)
sudo pkill -KILL -u charlie

# Envoyer signal spécifique
sudo pkill -HUP -u www-data nginx    # Recharger config nginx
```

#### Limitations sécuritaires
```bash
# ✗ Un utilisateur normal ne peut pas :
kill 1         # Tuer init (PID 1)
kill -9 456    # Tuer un processus root (si pas propriétaire)
killall -u root sshd  # Tuer les processus d'un autre utilisateur

# ✓ Un utilisateur peut :
kill $$        # Tuer son propre shell
killall firefox  # Tuer ses propres processus firefox
kill -STOP PID   # Suspendre ses processus
```

### Gestion par groupes de processus

#### Process Groups et Sessions
```bash
# Voir les groupes de processus
ps -eo pid,pgid,sid,user,comm

# Tuer un groupe de processus entier
kill -TERM -GROUP_ID
pkill -g GROUP_ID

# Processus en arrière-plan
jobs           # Voir les jobs du shell courant
kill %1        # Tuer le job numéro 1
```

---

## 5. Sécurité et escalade de privilèges

### SUID et changement d'identité effective

#### Programmes SUID courants
```bash
# Lister les programmes avec bit SUID
find /usr/bin -type f -perm -u+s -ls

# Exemples importants :
ls -l /usr/bin/passwd    # -rwsr-xr-x root root
ls -l /usr/bin/sudo      # -rwsr-xr-x root root  
ls -l /bin/ping          # -rwsr-xr-x root root
```

#### Fonctionnement SUID
```bash
# Quand alice exécute passwd :
alice$ passwd
# Le processus passwd s'exécute avec EUID=0 (root)
# mais RUID=1000 (alice)
# Cela permet de modifier /etc/shadow tout en gardant une trace
```

### Surveillance des changements d'identité

#### Processus suspects
```bash
# Détecter les processus avec SUID actif
ps -eo pid,user,ruid,euid,comm | awk '$2 != $3 {print}'

# Surveiller les nouveaux processus root
# (utile pour détecter les tentatives d'escalade)
while true; do
    ps -eo pid,ppid,user,comm --no-headers | grep "^[[:space:]]*[0-9]*[[:space:]]*[0-9]*[[:space:]]*root" > /tmp/root_procs_new
    if ! cmp -s /tmp/root_procs_old /tmp/root_procs_new 2>/dev/null; then
        echo "$(date): Nouveaux processus root détectés:"
        diff /tmp/root_procs_old /tmp/root_procs_new 2>/dev/null | grep "^>"
    fi
    mv /tmp/root_procs_new /tmp/root_procs_old
    sleep 5
done
```

---

## 6. Cas pratiques de diagnostic

### Scenario 1 : Service web compromis

#### Investigation
```bash
# 1. Identifier les processus web
ps aux | grep -E "(apache|nginx|php)"

# 2. Vérifier les propriétaires
ls -la /var/www/html/
ps aux | grep www-data

# 3. Rechercher des processus suspects avec www-data
ps -f -U www-data

# 4. Vérifier les connexions réseau
sudo netstat -tulpn | grep ":80\|:443"
sudo ss -tulpn | grep www-data
```

#### Signes d'alerte
```bash
# Processus www-data qui ne devrait pas exister :
# - Shells (/bin/bash, /bin/sh)
# - Éditeurs (vi, nano)  
# - Outils réseau (nc, wget, curl exécutés directement)
# - Processus de cryptominage
# - Connexions sortantes non légitimes
```

### Scenario 2 : Utilisateur avec trop de processus

#### Diagnostic des ressources
```bash
# Compter les processus par utilisateur
ps aux | awk '{print $1}' | sort | uniq -c | sort -nr

# Utilisation CPU par utilisateur
ps aux | awk '{user[$1]+=$3} END {for(u in user) print user[u]"%", u}' | sort -nr

# Utilisation mémoire par utilisateur  
ps aux | awk '{user[$1]+=$4} END {for(u in user) print user[u]"%", u}' | sort -nr

# Processus les plus consommateurs d'un utilisateur
ps aux | grep "^alice" | sort -k3 -nr | head -10
```

#### Limitation des ressources (ulimit)
```bash
# Voir les limites actuelles
ulimit -a

# Limites spécifiques aux processus
ulimit -u    # Nombre max de processus utilisateur

# Définir des limites (dans /etc/security/limits.conf)
alice soft nproc 100    # Max 100 processus
alice hard nproc 200    # Limite absolue 200
```

### Scenario 3 : Processus orphelin ou zombie

#### Identifier les problèmes
```bash
# Processus zombies (état Z)
ps aux | grep " Z "

# Processus orphelins (PPID = 1)
ps -eo pid,ppid,user,stat,comm | grep " 1 "

# Processus avec beaucoup d'enfants
ps --forest -eo pid,ppid,user,comm | less
```

#### Diagnostic parent/enfant
```bash
# Voir l'arbre des processus
pstree -p alice         # Arbre des processus d'alice
pstree -p 1234         # Arbre depuis le PID 1234

# Relation parent-enfant détaillée
ps -eo pid,ppid,user,stat,comm --forest
```

---

## 7. Scripts d'automatisation et monitoring

### Script de surveillance des processus utilisateur

```bash
#!/bin/bash
# monitor_user_processes.sh - Surveillance des processus par utilisateur

LOGFILE="/var/log/user_processes.log"
ALERT_THRESHOLD=50  # Seuil d'alerte (nb processus)

# Fonction de logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOGFILE"
}

# Surveillance continue
while true; do
    # Compter processus par utilisateur
    ps aux | awk 'NR>1 {count[$1]++} END {for (user in count) print count[user], user}' | \
    while read count user; do
        if [ "$count" -gt "$ALERT_THRESHOLD" ]; then
            log_message "ALERTE: Utilisateur $user a $count processus (seuil: $ALERT_THRESHOLD)"
            
            # Détails des processus
            ps aux | grep "^$user" | head -10 >> "$LOGFILE"
        fi
    done
    
    sleep 60  # Vérification chaque minute
done
```

### Script d'audit des permissions sur processus

```bash
#!/bin/bash
# audit_process_security.sh - Audit sécurité des processus

echo "=== AUDIT SÉCURITÉ DES PROCESSUS $(date) ==="
echo

# 1. Processus avec SUID actif
echo "1. Processus avec changement d'identité effective:"
ps -eo pid,user,ruid,euid,comm | awk 'NR>1 && $2 != $3 {print}' | head -20
echo

# 2. Processus root non-système suspects
echo "2. Processus root suspects (non dans /usr/sbin, /sbin):"
ps aux | grep "^root" | grep -v -E "/(sbin|usr/sbin)/" | \
grep -v -E "(kernel|kthread|migration|rcu_|watchdog)" | head -10
echo

# 3. Processus utilisateurs avec connexions réseau
echo "3. Processus utilisateurs avec connexions réseau actives:"
for user in $(ps aux | awk 'NR>1 && $3 >= 1000 {print $1}' | sort -u); do
    if [ -n "$(sudo netstat -tulpn 2>/dev/null | grep "$user")" ]; then
        echo "Utilisateur $user a des connexions réseau actives:"
        sudo netstat -tulpn | grep "$user" | head -5
        echo
    fi
done

# 4. Processus consommant le plus de ressources par utilisateur  
echo "4. Top 5 processus CPU par utilisateur:"
ps aux | sort -k3 -nr | head -20 | awk '{print $1, $3"%", $11}' | \
awk '{user[$1]+=$2; if(count[$1]++ < 5) detail[$1] = detail[$1] $2 "% " $3 "; "} 
     END {for(u in user) print u":", user[u]"% total -", detail[u]}'
```

### Automatisation du nettoyage

```bash
#!/bin/bash
# cleanup_user_processes.sh - Nettoyage automatique des processus

# Configuration
MAX_PROCESSES_PER_USER=100
USERS_TO_CHECK=("alice" "bob" "charlie")
DRY_RUN=true  # Changer en false pour actions réelles

cleanup_user() {
    local user="$1"
    local count=$(ps -u "$user" --no-headers | wc -l)
    
    if [ "$count" -gt "$MAX_PROCESSES_PER_USER" ]; then
        echo "Utilisateur $user: $count processus (limite: $MAX_PROCESSES_PER_USER)"
        
        # Identifier les processus à nettoyer
        # (ici: processus dormants depuis plus de 1 heure)
        local old_processes=$(ps -u "$user" -o pid,etime,comm | \
                             awk 'NR>1 && $2 ~ /[0-9]:[0-9][0-9]:[0-9][0-9]/ {print $1}')
        
        for pid in $old_processes; do
            if [ "$DRY_RUN" = true ]; then
                echo "  [DRY RUN] Tuerait le processus $pid"
            else
                echo "  Arrêt du processus $pid"
                sudo kill -TERM "$pid"
            fi
        done
    fi
}

# Vérifier chaque utilisateur
for user in "${USERS_TO_CHECK[@]}"; do
    cleanup_user "$user"
done
```

---

## 8. Outils avancés de surveillance

### systemd et cgroups

#### Surveillance par service systemd
```bash
# Processus par service
systemctl status nginx
systemctl status mysql

# Ressources utilisées par service
systemd-cgtop

# Limites par service
systemctl show nginx --property=TasksMax,MemoryLimit
```

#### Control Groups (cgroups)
```bash
# Voir l'organisation en cgroups
systemd-cgls

# Statistiques par cgroup
cat /sys/fs/cgroup/system.slice/nginx.service/cgroup.procs
cat /sys/fs/cgroup/system.slice/nginx.service/memory.current
```

### Surveillance avec psacct/acct

#### Installation et activation
```bash
# Installation (accounting des processus)
sudo apt install acct

# Activation
sudo accton /var/log/wtmp

# Statistiques d'utilisation
ac                    # Temps de connexion par utilisateur
sa                    # Statistiques d'exécution des commandes
lastcomm alice        # Dernières commandes d'alice
```

---

## Résumé

### Concepts clés
- **Chaque processus a un propriétaire** : défini par RUID, EUID, SUID
- **Héritage** : processus enfant hérite de l'utilisateur parent
- **Isolation** : processus ne peut accéder qu'aux ressources de son propriétaire
- **Contrôle** : seul le propriétaire (ou root) peut contrôler ses processus
- **SUID** : permet changement temporaire d'identité effective

### Commandes essentielles
```bash
ps aux                 # Voir tous les processus avec propriétaires
ps -u user             # Processus d'un utilisateur spécifique  
ps -eo pid,user,comm   # Format personnalisé
top -u user            # Processus actifs d'un utilisateur
kill PID               # Terminer un processus (si propriétaire)
killall -u user cmd    # Terminer tous les processus cmd de user
pkill -u user          # Terminer tous les processus d'un utilisateur
pstree -p              # Arbre des processus avec PID
```

### Surveillance et sécurité
- **Audit régulier** : surveiller les processus système et utilisateur
- **Détection d'anomalies** : processus suspects, escalade de privilèges
- **Limitation de ressources** : ulimit, cgroups pour contrôler l'usage
- **Logs et traçabilité** : enregistrer les activités des processus
- **Nettoyage automatique** : scripts de maintenance préventive

### Bonnes pratiques
- **Moindre privilège** : processus avec droits minimaux nécessaires
- **Isolation** : séparer les services par utilisateur système
- **Monitoring** : surveiller activité et ressources par utilisateur
- **Réaction rapide** : détecter et traiter les processus malveillants
- **Documentation** : maintenir une cartographie des processus légitimes

---

**Temps de lecture estimé** : 30-35 minutes
**Niveau** : Intermédiaire
**Pré-requis** : Modules 5.1, 5.2, 5.3 et notions de base des processus