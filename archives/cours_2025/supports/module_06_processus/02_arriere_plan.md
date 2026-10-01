# Processus en arriere-plan et controle de jobs

## Objectifs d'apprentissage
- Comprendre les concepts de premier plan et arriere-plan
- Utiliser les operateurs & et nohup pour les taches longues
- Maitriser les commandes jobs, fg, bg
- Gerer les sessions et les groupes de processus
- Utiliser screen et tmux pour la persistance

## Introduction

Linux permet d'executer des processus en **arriere-plan** (background), liberant le terminal pour d'autres taches. Cette capacite est essentielle pour les taches longues, les serveurs, et l'administration systeme efficace.

---

## 1. Concepts de premier plan vs arriere-plan

### Processus au premier plan (foreground)

#### Caracteristiques
- **Controle du terminal** : recoit les entrees clavier
- **Affichage direct** : sortie visible immediatement
- **Bloquant** : empeche d'autres commandes dans ce terminal
- **Signaux directs** : Ctrl+C, Ctrl+Z fonctionnent

```bash
# Exemple de processus au premier plan
sleep 30        # Bloque le terminal pendant 30 secondes
ping google.fr  # Affichage continu, bloque le terminal
```

### Processus en arriere-plan (background)

#### Caracteristiques
- **Libere le terminal** : permet d'autres commandes
- **Pas de controle clavier** : n'intercepte pas Ctrl+C
- **Execution autonome** : continue sans interaction
- **Numerotation** : identifie par un numero de job

```bash
# Exemple de processus en arriere-plan
sleep 30 &              # Libere immediatement le terminal
ping google.fr &        # Ping en arriere-plan
```

---

## 2. Lancement en arriere-plan avec &

### Syntaxe de base

```bash
commande &              # Lancer directement en arriere-plan
commande args &         # Avec arguments
```

### Exemples pratiques

```bash
# Taches longues en arriere-plan
find / -name "*.log" &                    # Recherche longue
cp -r /home/user/big_folder /backup/ &   # Copie volumineuse
rsync -av source/ destination/ &         # Synchronisation

# Surveillance continue
tail -f /var/log/syslog &                # Surveillance de logs
ping -c 1000 server.com &               # Test reseau long

# Applications graphiques (depuis terminal)
firefox &                               # Navigateur
gedit document.txt &                    # Editeur
```

### Retour d'information du systeme

```bash
# Quand on lance une commande avec &
sleep 60 &

# Le systeme affiche :
[1] 12345
#|   |
#|   +-- PID du processus
#+--- Numero de job dans ce shell
```

### Redirection de sortie

```bash
# Probleme : sortie melangee avec le terminal
ping google.fr &        # Les pings s'affichent quand meme

# Solution : redirection
ping google.fr > ping.log 2>&1 &        # Vers fichier
ping google.fr > /dev/null 2>&1 &       # Suppression complete
ping google.fr &> ping.log &            # Syntaxe courte bash
```

---

## 3. Gestion des jobs avec jobs, fg, bg

### Commande jobs - Lister les taches

```bash
# Lancer plusieurs taches
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

### Controle des jobs

#### Suspendre un processus (Ctrl+Z)
```bash
# Lancer une commande au premier plan
sleep 300

# Appuyer sur Ctrl+Z
# [1]+  Stopped                 sleep 300

# Le processus est suspendu, pas arrete
```

#### Commande bg - Reprendre en arriere-plan
```bash
# Apres Ctrl+Z, reprendre en arriere-plan
bg              # Le job le plus recent
bg %1           # Job numero 1 specifiquement

# Le job passe de "Stopped" a "Running" en arriere-plan
```

#### Commande fg - Ramener au premier plan
```bash
# Ramener un job en premier plan
fg              # Le job le plus recent (+)
fg %1           # Job numero 1
fg %sleep       # Job contenant "sleep" dans la commande

# Le job redevient interactif
```

### References aux jobs

```bash
# Differentes facons de referencer un job :
%1              # Job numero 1
%+              # Job le plus recent (meme que %%)
%-              # Job precedent
%%              # Job courant
%string         # Job dont la commande commence par "string"
%?string        # Job dont la commande contient "string"

# Exemples :
kill %1         # Tuer le job 1
kill %sleep     # Tuer le job commencant par "sleep"
kill %?ping     # Tuer le job contenant "ping"
```

---

## 4. Commande nohup - Persistance apres deconnexion

### Probleme des processus et HUP

#### Signal SIGHUP
```bash
# Quand on ferme un terminal, le shell envoie SIGHUP a tous ses enfants
# Par defaut, cela termine tous les processus lances depuis ce terminal

# Exemple du probleme :
ssh server.com
sleep 3600 &            # Tache longue
exit                    # Fermeture SSH
# -> Le sleep sera interrompu par SIGHUP
```

### Solution avec nohup

#### Syntaxe de base
```bash
nohup commande &
nohup commande > output.log 2>&1 &
```

#### Exemples pratiques
```bash
# Tache longue persistante
nohup find / -name "*.log" > search.log 2>&1 &

# Script de sauvegarde
nohup ./backup_script.sh &

# Application qui doit tourner indefiniment
nohup python web_server.py &

# Avec redirection personnalisee
nohup rsync -av /data/ /backup/ > rsync.log 2>&1 &
```

#### Fichier nohup.out par defaut
```bash
# Si pas de redirection specifiee, nohup cree nohup.out
nohup sleep 300 &

# Verifier le fichier de sortie
ls -la nohup.out
cat nohup.out

# Surveiller en temps reel
tail -f nohup.out
```

---

## 5. Sessions et groupes de processus

### Concepts avances

#### Hierarchie des processus
```
Session (SID)
|
+-- Process Group Leader (PGID)
|   +-- Processus 1
|   +-- Processus 2
|
+-- Process Group Leader (PGID)
    +-- Processus 3
    +-- Processus 4
```

#### Commandes de diagnostic
```bash
# Voir les identifiants de session et groupe
ps -eo pid,ppid,pgid,sid,tty,comm

# Processus de la session courante
ps -s $$

# Processus d'un groupe specifique
ps -g 1234
```

### Controle des groupes de processus

#### Creation de nouveaux groupes
```bash
# Lancer un processus dans un nouveau groupe
setsid commande

# Exemple : serveur web isole
setsid python -m http.server 8080 &

# Verifier l'isolation
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
Ctrl+A c        # Nouvelle fenetre
Ctrl+A n        # Fenetre suivante
Ctrl+A p        # Fenetre precedente
Ctrl+A "        # Liste des fenetres
Ctrl+A d        # Detacher (detach) la session
Ctrl+A k        # Tuer la fenetre courante
Ctrl+A ?        # Aide

# Depuis l'exterieur :
screen -ls              # Lister les sessions
screen -r               # Reattacher la derniere session
screen -r nom_session   # Reattacher une session specifique
screen -x               # Partager une session (multi-utilisateur)
```

#### Exemples d'usage screen
```bash
# Session de surveillance systeme
screen -S monitoring
top
# Ctrl+A c (nouvelle fenetre)
tail -f /var/log/syslog
# Ctrl+A c (nouvelle fenetre)  
htop
# Ctrl+A d (detacher)

# Plus tard, reattacher
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

# Sessions nommees
tmux new-session -s ma_session
tmux new -s ma_session          # Forme courte

# Commandes dans tmux (Ctrl+B puis touche) :
Ctrl+B c        # Nouvelle fenetre
Ctrl+B n        # Fenetre suivante
Ctrl+B p        # Fenetre precedente
Ctrl+B w        # Liste des fenetres
Ctrl+B d        # Detacher la session
Ctrl+B %        # Split vertical
Ctrl+B "        # Split horizontal
Ctrl+B o        # Changer de panneau
Ctrl+B x        # Fermer le panneau courant
Ctrl+B ?        # Aide

# Depuis l'exterieur :
tmux ls                     # Lister les sessions
tmux attach                 # Reattacher la derniere
tmux attach -t ma_session   # Reattacher session specifique
tmux kill-session -t nom    # Tuer une session
```

#### Exemple d'usage avance tmux
```bash
# Creer un environnement de developpement
tmux new-session -s dev -d     # Session detachee

# Premiere fenetre : editeur
tmux send-keys -t dev:0 'cd /projet && vim' Enter

# Nouvelle fenetre : serveur de test  
tmux new-window -t dev -n server
tmux send-keys -t dev:server 'cd /projet && python server.py' Enter

# Nouvelle fenetre : surveillance
tmux new-window -t dev -n monitor
tmux send-keys -t dev:monitor 'htop' Enter

# Split pour les logs
tmux split-window -t dev:monitor -v
tmux send-keys -t dev:monitor 'tail -f /var/log/app.log' Enter

# Attacher a la session
tmux attach -t dev
```

---

## 7. Cas pratiques d'administration

### Deploiement et mise a jour de services

```bash
#!/bin/bash
# deploy_service.sh - Deploiement avec gestion des processus

SERVICE_NAME="mon_service"
SERVICE_DIR="/opt/mon_service"
LOG_FILE="/var/log/mon_service.log"

# Arreter l'ancien service s'il existe
echo "Arret de l'ancien service..."
pkill -f "$SERVICE_NAME" || echo "Aucun service a arreter"

# Attendre l'arret complet
sleep 5

# Deployer la nouvelle version
echo "Deploiement..."
cd "$SERVICE_DIR"
git pull origin main

# Redemarrer en arriere-plan avec nohup
echo "Redemarrage du service..."
nohup python "$SERVICE_DIR/server.py" > "$LOG_FILE" 2>&1 &

# Sauvegarder le PID
echo $! > /var/run/mon_service.pid

echo "Service deploye avec PID $!"
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
    log_message "ALERTE: $service est arrete, tentative de redemarrage"
    
    systemctl start "$service" 2>&1 | tee -a "$LOG_FILE"
    
    if check_service "$service"; then
        log_message "SUCCESS: $service redemarre avec succes"
    else
        log_message "ERROR: Impossible de redemarrer $service"
        # Alerte mail/notification
        echo "Erreur critique sur $(hostname): $service ne redemarre pas" | \
        mail -s "Alerte systeme" admin@domain.com
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

### Traitement par lots en arriere-plan

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
    
    echo "$(date): Debut traitement $input_file" >> "$PROCESSING_LOG"
    
    # Simulation de traitement long
    python process_data.py "$input_file" "$output_file" 2>> "$PROCESSING_LOG"
    
    if [ $? -eq 0 ]; then
        echo "$(date): Succes $input_file -> $output_file" >> "$PROCESSING_LOG"
        # Archiver le fichier source
        mv "$input_file" "/data/processed/"
    else
        echo "$(date): ERREUR lors du traitement de $input_file" >> "$PROCESSING_LOG"
        mv "$input_file" "/data/failed/"
    fi
}

# Traitement en parallele limite
job_count=0
for file in "$INPUT_DIR"/*.raw; do
    [ ! -f "$file" ] && continue
    
    # Lancer le traitement en arriere-plan
    process_file "$file" &
    
    job_count=$((job_count + 1))
    
    # Limiter le nombre de jobs paralleles
    if [ $job_count -ge $MAX_PARALLEL ]; then
        wait    # Attendre qu'au moins un job se termine
        job_count=0
    fi
done

# Attendre la fin de tous les jobs
wait

echo "$(date): Traitement par lots termine" >> "$PROCESSING_LOG"
```

---

## 8. Techniques avancees

### Processus demons (daemons)

#### Creation d'un demon simple
```bash
#!/bin/bash
# simple_daemon.sh - Creer un processus demon

# Fonction de daemonisation
daemonize() {
    # Fork et exit du parent
    if [ "$1" != "child" ]; then
        nohup "$0" child > /dev/null 2>&1 &
        exit 0
    fi
    
    # Le processus enfant continue
    # Changer de repertoire
    cd /
    
    # Creer une nouvelle session
    setsid
    
    # Rediriger les descripteurs standard
    exec </dev/null
    exec >/dev/null 2>&1
}

# Fonction principale du demon
daemon_main() {
    local pid_file="/var/run/simple_daemon.pid"
    echo $$ > "$pid_file"
    
    # Boucle principale
    while true; do
        # Travail du demon
        echo "$(date): Daemon heartbeat" >> /var/log/simple_daemon.log
        sleep 60
    done
}

# Point d'entree
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
ulimit -v 1048576   # Memoire virtuelle max (Ko)
ulimit -n 100       # Nombre de fichiers ouverts max

# Lancer le processus avec ces limites
./mon_processus &

# Verifier les limites d'un processus
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
        # CPU et memoire
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

## 9. Depannage des processus en arriere-plan

### Processus perdus

#### Retrouver des processus
```bash
# Rechercher par nom
pgrep -f "mon_script"
ps aux | grep "mon_processus"

# Rechercher par utilisateur
ps -u $USER

# Processus sans terminal (probablement en arriere-plan)
ps aux | grep "?"

# Processus avec nohup
ps aux | grep nohup
```

#### Reattacher un processus detache
```bash
# Impossible de reattacher directement, mais :
# 1. Trouver le PID
PID=$(pgrep mon_processus)

# 2. Surveiller sa sortie (si redirigee)
tail -f /path/to/output.log

# 3. Envoyer des signaux pour controler
kill -USR1 $PID    # Si le processus gere ce signal
```

### Processus zombies en arriere-plan

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

# Executer periodiquement
while true; do
    cleanup_zombies
    sleep 300    # Toutes les 5 minutes
done
```

---

## Resume

### Commandes essentielles
```bash
command &           # Lancer en arriere-plan
jobs               # Lister les jobs
jobs -l            # Jobs avec PID
fg %1              # Ramener job 1 au premier plan
bg %1              # Reprendre job 1 en arriere-plan
kill %1            # Tuer le job 1
nohup command &    # Persistant apres deconnexion
disown %1          # Detacher job du shell

# Ctrl+Z             # Suspendre processus courant
# Ctrl+C             # Interrompre processus courant
```

### References aux jobs
```bash
%1, %2, %3...      # Par numero
%%                 # Job courant (le plus recent)
%+                 # Job courant (identique a %%)
%-                 # Job precedent
%string            # Job commencant par "string"
%?string           # Job contenant "string"
```

### Gestionnaires de sessions
```bash
# Screen
screen -S nom      # Nouvelle session nommee
screen -ls         # Lister sessions
screen -r nom      # Reattacher session
# Ctrl+A d          # Detacher
# Ctrl+A c          # Nouvelle fenetre

# Tmux  
tmux new -s nom    # Nouvelle session nommee
tmux ls            # Lister sessions
tmux attach -t nom # Reattacher session
# Ctrl+B d          # Detacher
# Ctrl+B c          # Nouvelle fenetre
# Ctrl+B %          # Split vertical
# Ctrl+B "          # Split horizontal
```

### Etats des jobs
- **Running** : en cours d'execution
- **Stopped** : suspendu (Ctrl+Z)
- **Done** : termine normalement
- **Exit** : termine avec code d'erreur
- **Killed** : tue par signal

### Cas d'usage typiques
- **Taches longues** : `nohup long_task.sh &`
- **Surveillance** : `tail -f logfile &`
- **Services** : `nohup ./server.py > server.log 2>&1 &`
- **Deploiement** : `tmux` ou `screen` pour persistance
- **Traitement par lots** : jobs paralleles avec controle

### Bonnes pratiques
- **Redirection** : toujours rediriger stdout/stderr pour les taches en arriere-plan
- **Nommage** : utiliser des sessions nommees avec screen/tmux
- **Monitoring** : surveiller les processus critiques
- **Nettoyage** : gerer la fin de vie des processus
- **Documentation** : noter les processus en cours pour l'equipe

---

**Temps de lecture estime** : 30-35 minutes
**Niveau** : Intermediaire
**Pre-requis** : Module 6.1 (Gestion des processus), notions de terminal