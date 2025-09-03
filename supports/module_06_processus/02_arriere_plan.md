# Module 6.2 : Processus en arrière-plan et contrôle de jobs

## Objectifs d'apprentissage
- Comprendre les concepts de premier plan et arrière-plan
- Utiliser les opérateurs & et nohup pour les tâches longues
- Maîtriser les commandes jobs, fg, bg
- Gérer les sessions et les groupes de processus
- Utiliser screen et tmux pour la persistance

## Introduction

Linux permet d'exécuter des processus en **arrière-plan** (background), libérant le terminal pour d'autres tâches. Cette capacité est essentielle pour les tâches longues, les serveurs, et l'administration système efficace.

---

## 1. Concepts de premier plan vs arrière-plan

### Processus au premier plan (foreground)

#### Caractéristiques
- **Contrôle du terminal** : reçoit les entrées clavier
- **Affichage direct** : sortie visible immédiatement
- **Bloquant** : empêche d'autres commandes dans ce terminal
- **Signaux directs** : Ctrl+C, Ctrl+Z fonctionnent

```bash
# Exemple de processus au premier plan
sleep 30        # Bloque le terminal pendant 30 secondes
ping google.fr  # Affichage continu, bloque le terminal
```

### Processus en arrière-plan (background)

#### Caractéristiques
- **Libère le terminal** : permet d'autres commandes
- **Pas de contrôle clavier** : n'intercepte pas Ctrl+C
- **Exécution autonome** : continue sans interaction
- **Numérotation** : identifié par un numéro de job

```bash
# Exemple de processus en arrière-plan
sleep 30 &              # Libère immédiatement le terminal
ping google.fr &        # Ping en arrière-plan
```

---

## 2. Lancement en arrière-plan avec &

### Syntaxe de base

```bash
commande &              # Lancer directement en arrière-plan
commande args &         # Avec arguments
```

### Exemples pratiques

```bash
# Tâches longues en arrière-plan
find / -name "*.log" &                    # Recherche longue
cp -r /home/user/big_folder /backup/ &   # Copie volumineuse
rsync -av source/ destination/ &         # Synchronisation

# Surveillance continue
tail -f /var/log/syslog &                # Surveillance de logs
ping -c 1000 server.com &               # Test réseau long

# Applications graphiques (depuis terminal)
firefox &                               # Navigateur
gedit document.txt &                    # Éditeur
```

### Retour d'information du système

```bash
# Quand on lance une commande avec &
sleep 60 &

# Le système affiche :
[1] 12345
#│   │
#│   └── PID du processus
#└─── Numéro de job dans ce shell
```

### Redirection de sortie

```bash
# Problème : sortie mélangée avec le terminal
ping google.fr &        # Les pings s'affichent quand même

# Solution : redirection
ping google.fr > ping.log 2>&1 &        # Vers fichier
ping google.fr > /dev/null 2>&1 &       # Suppression complète
ping google.fr &> ping.log &            # Syntaxe courte bash
```

---

## 3. Gestion des jobs avec jobs, fg, bg

### Commande jobs - Lister les tâches

```bash
# Lancer plusieurs tâches
sleep 100 &
sleep 200 &
ping google.fr > /dev/null &
find / -name "*.conf" > find.log 2>&1 &

# Lister les jobs actifs
jobs

# Sortie exemple :
[1]   Running                 sleep 100 &
[2]-  Running                 sleep 200 &
[3]+  Running                 ping google.fr > /dev/null &
[4]   Running                 find / -name "*.conf" > find.log 2>&1 &
```

#### Options de jobs
```bash
jobs -l         # Avec PID
jobs -r         # Seulement les jobs running
jobs -s         # Seulement les jobs stopped
jobs %1         # Informations sur le job 1 seulement
```

### Contrôle des jobs

#### Suspendre un processus (Ctrl+Z)
```bash
# Lancer une commande au premier plan
sleep 300

# Appuyer sur Ctrl+Z
# [1]+  Stopped                 sleep 300

# Le processus est suspendu, pas arrêté
```

#### Commande bg - Reprendre en arrière-plan
```bash
# Après Ctrl+Z, reprendre en arrière-plan
bg              # Le job le plus récent
bg %1           # Job numéro 1 spécifiquement

# Le job passe de "Stopped" à "Running" en arrière-plan
```

#### Commande fg - Ramener au premier plan
```bash
# Ramener un job en premier plan
fg              # Le job le plus récent (+)
fg %1           # Job numéro 1
fg %sleep       # Job contenant "sleep" dans la commande

# Le job redevient interactif
```

### Références aux jobs

```bash
# Différentes façons de référencer un job :
%1              # Job numéro 1
%+              # Job le plus récent (même que %%)
%-              # Job précédent
%%              # Job courant
%string         # Job dont la commande commence par "string"
%?string        # Job dont la commande contient "string"

# Exemples :
kill %1         # Tuer le job 1
kill %sleep     # Tuer le job commençant par "sleep"
kill %?ping     # Tuer le job contenant "ping"
```

---

## 4. Commande nohup - Persistance après déconnexion

### Problème des processus et HUP

#### Signal SIGHUP
```bash
# Quand on ferme un terminal, le shell envoie SIGHUP à tous ses enfants
# Par défaut, cela termine tous les processus lancés depuis ce terminal

# Exemple du problème :
ssh server.com
sleep 3600 &            # Tâche longue
exit                    # Fermeture SSH
# → Le sleep sera interrompu par SIGHUP
```

### Solution avec nohup

#### Syntaxe de base
```bash
nohup commande &
nohup commande > output.log 2>&1 &
```

#### Exemples pratiques
```bash
# Tâche longue persistante
nohup find / -name "*.log" > search.log 2>&1 &

# Script de sauvegarde
nohup ./backup_script.sh &

# Application qui doit tourner indéfiniment
nohup python web_server.py &

# Avec redirection personnalisée
nohup rsync -av /data/ /backup/ > rsync.log 2>&1 &
```

#### Fichier nohup.out par défaut
```bash
# Si pas de redirection spécifiée, nohup crée nohup.out
nohup sleep 300 &

# Vérifier le fichier de sortie
ls -la nohup.out
cat nohup.out

# Surveiller en temps réel
tail -f nohup.out
```

---

## 5. Sessions et groupes de processus

### Concepts avancés

#### Hiérarchie des processus
```
Session (SID)
│
├── Process Group Leader (PGID)
│   ├── Processus 1
│   └── Processus 2
│
└── Process Group Leader (PGID)
    ├── Processus 3
    └── Processus 4
```

#### Commandes de diagnostic
```bash
# Voir les identifiants de session et groupe
ps -eo pid,ppid,pgid,sid,tty,comm

# Processus de la session courante
ps -s $$

# Processus d'un groupe spécifique
ps -g 1234
```

### Contrôle des groupes de processus

#### Création de nouveaux groupes
```bash
# Lancer un processus dans un nouveau groupe
setsid commande

# Exemple : serveur web isolé
setsid python -m http.server 8080 &

# Vérifier l'isolation
ps -eo pid,pgid,sid,comm | grep python
```

#### Terminaison par groupe
```bash
# Tuer tout un groupe de processus
kill -TERM -PGID      # Groupe avec PGID
pkill -g PGID          # Alternative plus simple

# Exemple : pipeline complexe
tar czf - /home | ssh server 'cat > backup.tgz' &
PIPELINE_PID=$!

# Plus tard, tuer tout le pipeline
kill -TERM -$PIPELINE_PID
```

---

## 6. Screen et tmux - Gestionnaires de sessions

### Screen - Gestionnaire de terminal traditionnel

#### Installation et concepts de base
```bash
# Installation
sudo apt install screen

# Lancer une session screen
screen

# Lancer avec nom de session
screen -S ma_session
```

#### Commandes de base screen
```bash
# Dans screen (Ctrl+A puis lettre) :
Ctrl+A c        # Nouvelle fenêtre
Ctrl+A n        # Fenêtre suivante
Ctrl+A p        # Fenêtre précédente
Ctrl+A "        # Liste des fenêtres
Ctrl+A d        # Détacher (detach) la session
Ctrl+A k        # Tuer la fenêtre courante
Ctrl+A ?        # Aide

# Depuis l'extérieur :
screen -ls              # Lister les sessions
screen -r               # Réattacher la dernière session
screen -r nom_session   # Réattacher une session spécifique
screen -x               # Partager une session (multi-utilisateur)
```

#### Exemples d'usage screen
```bash
# Session de surveillance système
screen -S monitoring
top
# Ctrl+A c (nouvelle fenêtre)
tail -f /var/log/syslog
# Ctrl+A c (nouvelle fenêtre)  
htop
# Ctrl+A d (détacher)

# Plus tard, réattacher
screen -r monitoring
```

### tmux - Gestionnaire moderne

#### Installation et avantages
```bash
# Installation
sudo apt install tmux

# Avantages sur screen :
# - Interface plus moderne
# - Panneaux (splits horizontaux/verticaux)
# - Configuration plus flexible
# - Meilleur support souris
```

#### Commandes de base tmux
```bash
# Lancer tmux
tmux

# Sessions nommées
tmux new-session -s ma_session
tmux new -s ma_session          # Forme courte

# Commandes dans tmux (Ctrl+B puis touche) :
Ctrl+B c        # Nouvelle fenêtre
Ctrl+B n        # Fenêtre suivante
Ctrl+B p        # Fenêtre précédente
Ctrl+B w        # Liste des fenêtres
Ctrl+B d        # Détacher la session
Ctrl+B %        # Split vertical
Ctrl+B "        # Split horizontal
Ctrl+B o        # Changer de panneau
Ctrl+B x        # Fermer le panneau courant
Ctrl+B ?        # Aide

# Depuis l'extérieur :
tmux ls                     # Lister les sessions
tmux attach                 # Réattacher la dernière
tmux attach -t ma_session   # Réattacher session spécifique
tmux kill-session -t nom    # Tuer une session
```

#### Exemple d'usage avancé tmux
```bash
# Créer un environnement de développement
tmux new-session -s dev -d     # Session détachée

# Première fenêtre : éditeur
tmux send-keys -t dev:0 'cd /projet && vim' Enter

# Nouvelle fenêtre : serveur de test  
tmux new-window -t dev -n server
tmux send-keys -t dev:server 'cd /projet && python server.py' Enter

# Nouvelle fenêtre : surveillance
tmux new-window -t dev -n monitor
tmux send-keys -t dev:monitor 'htop' Enter

# Split pour les logs
tmux split-window -t dev:monitor -v
tmux send-keys -t dev:monitor 'tail -f /var/log/app.log' Enter

# Attacher à la session
tmux attach -t dev
```

---

## 7. Cas pratiques d'administration

### Déploiement et mise à jour de services

```bash
#!/bin/bash
# deploy_service.sh - Déploiement avec gestion des processus

SERVICE_NAME="mon_service"
SERVICE_DIR="/opt/mon_service"
LOG_FILE="/var/log/mon_service.log"

# Arrêter l'ancien service s'il existe
echo "Arrêt de l'ancien service..."
pkill -f "$SERVICE_NAME" || echo "Aucun service à arrêter"

# Attendre l'arrêt complet
sleep 5

# Déployer la nouvelle version
echo "Déploiement..."
cd "$SERVICE_DIR"
git pull origin main

# Redémarrer en arrière-plan avec nohup
echo "Redémarrage du service..."
nohup python "$SERVICE_DIR/server.py" > "$LOG_FILE" 2>&1 &

# Sauvegarder le PID
echo $! > /var/run/mon_service.pid

echo "Service déployé avec PID $!"
```

### Surveillance de processus critiques

```bash
#!/bin/bash
# watchdog.sh - Gardien de processus critiques

CRITICAL_SERVICES=("nginx" "mysql" "ssh")
CHECK_INTERVAL=60
LOG_FILE="/var/log/watchdog.log"

log_message() {
    echo "$(date): $1" | tee -a "$LOG_FILE"
}

check_service() {
    local service="$1"
    
    if pgrep "$service" > /dev/null; then
        return 0    # Service running
    else
        return 1    # Service down
    fi
}

restart_service() {
    local service="$1"
    log_message "ALERTE: $service est arrêté, tentative de redémarrage"
    
    systemctl start "$service" 2>&1 | tee -a "$LOG_FILE"
    
    if check_service "$service"; then
        log_message "SUCCESS: $service redémarré avec succès"
    else
        log_message "ERROR: Impossible de redémarrer $service"
        # Alerte mail/notification
        echo "Erreur critique sur $(hostname): $service ne redémarre pas" | \
        mail -s "Alerte système" admin@domain.com
    fi
}

# Boucle de surveillance
while true; do
    for service in "${CRITICAL_SERVICES[@]}"; do
        if ! check_service "$service"; then
            restart_service "$service"
        fi
    done
    
    sleep "$CHECK_INTERVAL"
done
```

### Traitement par lots en arrière-plan

```bash
#!/bin/bash
# batch_processor.sh - Traitement de fichiers par lots

INPUT_DIR="/data/input"
OUTPUT_DIR="/data/output"
PROCESSING_LOG="/var/log/batch_processing.log"
MAX_PARALLEL=4

# Fonction de traitement d'un fichier
process_file() {
    local input_file="$1"
    local output_file="$OUTPUT_DIR/$(basename "$input_file" .raw).processed"
    
    echo "$(date): Début traitement $input_file" >> "$PROCESSING_LOG"
    
    # Simulation de traitement long
    python process_data.py "$input_file" "$output_file" 2>> "$PROCESSING_LOG"
    
    if [ $? -eq 0 ]; then
        echo "$(date): Succès $input_file → $output_file" >> "$PROCESSING_LOG"
        # Archiver le fichier source
        mv "$input_file" "/data/processed/"
    else
        echo "$(date): ERREUR lors du traitement de $input_file" >> "$PROCESSING_LOG"
        mv "$input_file" "/data/failed/"
    fi
}

# Traitement en parallèle limité
job_count=0
for file in "$INPUT_DIR"/*.raw; do
    [ ! -f "$file" ] && continue
    
    # Lancer le traitement en arrière-plan
    process_file "$file" &
    
    job_count=$((job_count + 1))
    
    # Limiter le nombre de jobs parallèles
    if [ $job_count -ge $MAX_PARALLEL ]; then
        wait    # Attendre qu'au moins un job se termine
        job_count=0
    fi
done

# Attendre la fin de tous les jobs
wait

echo "$(date): Traitement par lots terminé" >> "$PROCESSING_LOG"
```

---

## 8. Techniques avancées

### Processus démons (daemons)

#### Création d'un démon simple
```bash
#!/bin/bash
# simple_daemon.sh - Créer un processus démon

# Fonction de daemonisation
daemonize() {
    # Fork et exit du parent
    if [ "$1" != "child" ]; then
        nohup "$0" child > /dev/null 2>&1 &
        exit 0
    fi
    
    # Le processus enfant continue
    # Changer de répertoire
    cd /
    
    # Créer une nouvelle session
    setsid
    
    # Rediriger les descripteurs standard
    exec </dev/null
    exec >/dev/null 2>&1
}

# Fonction principale du démon
daemon_main() {
    local pid_file="/var/run/simple_daemon.pid"
    echo $$ > "$pid_file"
    
    # Boucle principale
    while true; do
        # Travail du démon
        echo "$(date): Daemon heartbeat" >> /var/log/simple_daemon.log
        sleep 60
    done
}

# Point d'entrée
if [ "$1" = "child" ]; then
    daemon_main
else
    daemonize
fi
```

### Gestion de ressources

#### Limitation des ressources avec ulimit
```bash
# Limiter avant de lancer un processus
ulimit -t 3600      # Temps CPU max (secondes)
ulimit -v 1048576   # Mémoire virtuelle max (Ko)
ulimit -n 100       # Nombre de fichiers ouverts max

# Lancer le processus avec ces limites
./mon_processus &

# Vérifier les limites d'un processus
cat /proc/PID/limits
```

#### Monitoring des ressources
```bash
# Script de monitoring continu
#!/bin/bash
monitor_process() {
    local pid="$1"
    local log_file="monitor_$pid.log"
    
    echo "Monitoring PID $pid" > "$log_file"
    
    while kill -0 "$pid" 2>/dev/null; do
        # CPU et mémoire
        ps -p "$pid" -o pid,pcpu,pmem,vsz,rss,comm >> "$log_file"
        
        # Fichiers ouverts
        echo "Files: $(lsof -p "$pid" 2>/dev/null | wc -l)" >> "$log_file"
        
        sleep 10
    done
    
    echo "Process $pid terminated at $(date)" >> "$log_file"
}

# Utilisation
./long_running_app &
APP_PID=$!
monitor_process $APP_PID &
```

---

## 9. Dépannage des processus en arrière-plan

### Processus perdus

#### Retrouver des processus
```bash
# Rechercher par nom
pgrep -f "mon_script"
ps aux | grep "mon_processus"

# Rechercher par utilisateur
ps -u $USER

# Processus sans terminal (probablement en arrière-plan)
ps aux | grep "?"

# Processus avec nohup
ps aux | grep nohup
```

#### Réattacher un processus détaché
```bash
# Impossible de réattacher directement, mais :
# 1. Trouver le PID
PID=$(pgrep mon_processus)

# 2. Surveiller sa sortie (si redirigée)
tail -f /path/to/output.log

# 3. Envoyer des signaux pour contrôler
kill -USR1 $PID    # Si le processus gère ce signal
```

### Processus zombies en arrière-plan

#### Nettoyage des zombies
```bash
# Identifier les processus parents de zombies
ps -eo pid,ppid,state,comm | awk '$3=="Z" {print "Zombie PID " $1 " PPID " $2}'

# Script de nettoyage automatique
#!/bin/bash
cleanup_zombies() {
    ps -eo pid,ppid,state | awk '$3=="Z" {print $2}' | sort -u | while read ppid; do
        if [ -n "$ppid" ] && [ "$ppid" != "1" ]; then
            echo "Tentative nettoyage zombies du parent $ppid"
            kill -CHLD "$ppid" 2>/dev/null
        fi
    done
}

# Exécuter périodiquement
while true; do
    cleanup_zombies
    sleep 300    # Toutes les 5 minutes
done
```

---

## Résumé

### Commandes essentielles
```bash
command &           # Lancer en arrière-plan
jobs               # Lister les jobs
jobs -l            # Jobs avec PID
fg %1              # Ramener job 1 au premier plan
bg %1              # Reprendre job 1 en arrière-plan
kill %1            # Tuer le job 1
nohup command &    # Persistant après déconnexion
disown %1          # Détacher job du shell

# Ctrl+Z             # Suspendre processus courant
# Ctrl+C             # Interrompre processus courant
```

### Références aux jobs
```bash
%1, %2, %3...      # Par numéro
%%                 # Job courant (le plus récent)
%+                 # Job courant (identique à %%)
%-                 # Job précédent
%string            # Job commençant par "string"
%?string           # Job contenant "string"
```

### Gestionnaires de sessions
```bash
# Screen
screen -S nom      # Nouvelle session nommée
screen -ls         # Lister sessions
screen -r nom      # Réattacher session
# Ctrl+A d          # Détacher
# Ctrl+A c          # Nouvelle fenêtre

# Tmux  
tmux new -s nom    # Nouvelle session nommée
tmux ls            # Lister sessions
tmux attach -t nom # Réattacher session
# Ctrl+B d          # Détacher
# Ctrl+B c          # Nouvelle fenêtre
# Ctrl+B %          # Split vertical
# Ctrl+B "          # Split horizontal
```

### États des jobs
- **Running** : en cours d'exécution
- **Stopped** : suspendu (Ctrl+Z)
- **Done** : terminé normalement
- **Exit** : terminé avec code d'erreur
- **Killed** : tué par signal

### Cas d'usage typiques
- **Tâches longues** : `nohup long_task.sh &`
- **Surveillance** : `tail -f logfile &`
- **Services** : `nohup ./server.py > server.log 2>&1 &`
- **Déploiement** : `tmux` ou `screen` pour persistance
- **Traitement par lots** : jobs parallèles avec contrôle

### Bonnes pratiques
- **Redirection** : toujours rediriger stdout/stderr pour les tâches en arrière-plan
- **Nommage** : utiliser des sessions nommées avec screen/tmux
- **Monitoring** : surveiller les processus critiques
- **Nettoyage** : gérer la fin de vie des processus
- **Documentation** : noter les processus en cours pour l'équipe

---

**Temps de lecture estimé** : 30-35 minutes
**Niveau** : Intermédiaire
**Pré-requis** : Module 6.1 (Gestion des processus), notions de terminal