# Gestion des processus

## Objectifs d'apprentissage
- Comprendre les concepts de processus sous Linux
- Utiliser les commandes ps, top, htop pour surveiller
- Gerer les processus avec kill et ses variantes
- Maitriser les signaux systeme
- Identifier et resoudre les problemes de processus

## Introduction

Un **processus** est un programme en cours d'execution. Linux est un systeme multitache qui peut executer plusieurs processus simultanement. La gestion efficace des processus est essentielle pour maintenir les performances et la stabilite du systeme.

---

## 1. Concepts fondamentaux des processus

### Qu'est-ce qu'un processus ?

#### Definition
Un processus est une instance d'un programme en cours d'execution, avec :
- **Code du programme** : instructions a executer
- **Donnees** : variables, memoire allouee
- **Etat d'execution** : registres, pile d'execution
- **Contexte** : environnement, repertoire de travail
- **Ressources** : fichiers ouverts, connexions reseau

#### Cycle de vie d'un processus
```
Creation -> Execution -> Suspension -> Reveil -> Terminaison
    ^         v           ^           v          v
   fork()   Running    Signal     Scheduled    exit()
```

### Attributs des processus

#### Identifiants
```bash
# PID : Process ID (identifiant unique)
echo $$                    # PID du shell courant

# PPID : Parent Process ID  
ps -eo pid,ppid,comm | grep $$

# PGID : Process Group ID
ps -eo pid,pgid,comm | grep $$

# SID : Session ID
ps -eo pid,sid,comm | grep $$
```

#### Etats des processus
- **R (Running)** : en cours d'execution ou pret
- **S (Sleeping)** : endormi (attente interruptible)
- **D (Uninterruptible)** : attente non-interruptible (I/O)
- **T (Stopped)** : arrete (suspendu)
- **Z (Zombie)** : termine mais non nettoye par le parent
- **I (Idle)** : processus noyau inactif

---

## 2. Commande ps - Lister les processus

### Syntaxe et options de base

#### Formats courants
```bash
# Affichage simple
ps

# Tous les processus de tous les utilisateurs
ps aux

# Format long avec informations detaillees
ps -ef

# Processus en format arbre
ps --forest
ps f
```

#### Colonnes importantes de `ps aux`
```bash
ps aux | head -5
# USER   PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root     1  0.1  0.1 225316  8364 ?        Ss   10:00   0:01 /sbin/init
# alice 1234  2.5  1.2 123456 23456 pts/0    S+   10:30   0:05 python script.py
```

**Explication des colonnes** :
- **USER** : utilisateur proprietaire
- **PID** : identifiant du processus
- **%CPU** : pourcentage d'utilisation CPU
- **%MEM** : pourcentage d'utilisation memoire
- **VSZ** : memoire virtuelle (Ko)
- **RSS** : memoire residente physique (Ko)
- **TTY** : terminal associe (? = aucun)
- **STAT** : etat du processus
- **START** : heure de demarrage
- **TIME** : temps CPU cumule
- **COMMAND** : commande executee

### Options avancees de ps

#### Selection personnalisee
```bash
# Format personnalise avec colonnes choisies
ps -eo pid,ppid,user,%cpu,%mem,comm

# Trier par utilisation CPU (descendant)
ps aux --sort=-%cpu | head -10

# Trier par utilisation memoire  
ps aux --sort=-%mem | head -10

# Processus d'un utilisateur specifique
ps -u alice
ps aux | grep "^alice"

# Processus avec un nom specifique
ps aux | grep nginx
pgrep nginx              # Plus direct
```

#### Filtrage et recherche
```bash
# Processus contenant un mot-cle
ps aux | grep python

# Processus par PID specifique
ps -p 1234

# Processus enfants d'un processus
ps --ppid 1234

# Processus dans un groupe specifique
ps -g 5678
```

---

## 3. Surveillance en temps reel avec top

### Utilisation de base de top

#### Lancement et interface
```bash
# Lancer top
top

# Interface top :
# - Ligne 1 : uptime, utilisateurs, charge systeme
# - Ligne 2 : nombre de processus et leurs etats
# - Ligne 3-4 : utilisation CPU
# - Ligne 5 : utilisation memoire
# - Lignes suivantes : liste des processus
```

#### Navigation dans top
```bash
# Commandes interactives dans top :
q            # Quitter
h            # Aide
k            # Tuer un processus (demande PID)
u            # Filtrer par utilisateur
M            # Trier par utilisation memoire
P            # Trier par utilisation CPU (defaut)
T            # Trier par temps CPU
c            # Afficher/masquer la ligne de commande complete
1            # Afficher/masquer tous les CPU individuellement
```

#### Options de lancement
```bash
# Actualisation personnalisee (toutes les 2 secondes)
top -d 2

# Filtrer par utilisateur des le lancement
top -u alice

# Mode batch (non-interactif, pour scripts)
top -b -n 1    # Une seule iteration

# Limiter le nombre de processus affiches
top -n 1 | head -20
```

### Commande htop (alternative amelioree)

#### Installation et utilisation
```bash
# Installation (si pas disponible)
sudo apt install htop    # Debian/Ubuntu
sudo yum install htop    # CentOS/RHEL

# Lancement
htop
```

#### Avantages de htop
- **Interface coloree** : plus lisible
- **Navigation souris** : clic pour selectionner
- **Arbre des processus** : vue hierarchique (F5)
- **Filtrage facile** : F4 pour filtrer
- **Tri multi-colonnes** : F6 pour configurer
- **Actions rapides** : F9 pour kill, F7/F8 pour nice

#### Raccourcis htop essentiels
```bash
F1    # Aide
F2    # Configuration
F3    # Rechercher processus
F4    # Filtrer par nom
F5    # Vue en arbre
F6    # Trier par colonne
F7    # Diminuer priorite (nice +)
F8    # Augmenter priorite (nice -)
F9    # Envoyer signal (kill)
F10   # Quitter
```

---

## 4. Gestion des signaux systeme

### Concepts des signaux

#### Qu'est-ce qu'un signal ?
Un signal est un mecanisme de communication entre processus ou du systeme vers les processus. Il permet d'interrompre, terminer, ou notifier un processus.

#### Signaux courants
```bash
# Lister tous les signaux disponibles
kill -l

# Signaux les plus importants :
1  SIGHUP    # Hangup - redemarrer/recharger config
2  SIGINT    # Interrupt - Ctrl+C
3  SIGQUIT   # Quit - Ctrl+\
9  SIGKILL   # Kill force - non interceptable
15 SIGTERM   # Terminate proprement (defaut de kill)
18 SIGCONT   # Continue - reprendre processus suspendu  
19 SIGSTOP   # Stop - suspendre processus
20 SIGTSTP   # Terminal stop - Ctrl+Z
```

### Commande kill - Envoyer des signaux

#### Syntaxe de base
```bash
kill [signal] PID

# Exemples :
kill 1234        # SIGTERM par defaut (terminaison propre)
kill -9 1234     # SIGKILL (force, non interceptable)
kill -15 1234    # SIGTERM explicite
kill -HUP 1234   # SIGHUP (recharger config)
kill -STOP 1234  # Suspendre
kill -CONT 1234  # Reprendre
```

#### Formats de signaux
```bash
# Trois formats equivalents :
kill -9 1234
kill -KILL 1234  
kill -SIGKILL 1234

# Tester si un processus existe (sans le tuer)
kill -0 1234 && echo "Processus existe" || echo "Processus inexistant"
```

### Commandes apparentees

#### killall - Tuer par nom
```bash
# Tuer tous les processus avec un nom donne
killall firefox
killall -9 python
killall -HUP nginx

# Tuer avec confirmation
killall -i firefox

# Mode verbose
killall -v python

# Par utilisateur
killall -u alice python
```

#### pkill - Tuer avec criteres avances
```bash
# Tuer par nom (expression reguliere)
pkill firefox
pkill "^chrome"

# Par utilisateur
pkill -u alice

# Par groupe de processus
pkill -g 1234

# Par terminal
pkill -t pts/0

# Combinaisons
pkill -u alice python    # Processus python d'alice
```

#### pgrep - Trouver les PID
```bash
# Trouver les PID par nom
pgrep firefox

# Avec informations detaillees
pgrep -l firefox    # Affiche nom + PID
pgrep -f python     # Recherche dans la ligne de commande complete

# Par utilisateur
pgrep -u alice

# Plus ancien/recent
pgrep -o firefox    # Plus ancien
pgrep -n firefox    # Plus recent
```

---

## 5. Cas pratiques de gestion

### Diagnostic de processus problematiques

#### Processus consommant trop de CPU
```bash
# Identifier les gros consommateurs
top -o %CPU | head -20
ps aux --sort=-%cpu | head -10

# Analyser un processus specifique
ps -p 1234 -o pid,ppid,user,%cpu,%mem,comm,args
top -p 1234    # Monitoring temps reel d'un PID

# Historique d'utilisation CPU
pidstat -p 1234 1    # Si outil sysstat installe
```

#### Processus consommant trop de memoire
```bash
# Gros consommateurs memoire
ps aux --sort=-%mem | head -10

# Detail memoire d'un processus
cat /proc/1234/status | grep -i mem
pmap 1234    # Cartographie memoire detaillee

# Fuites memoire potentielles (surveillance dans le temps)
while true; do
    ps -p 1234 -o pid,%mem,vsz,rss,comm
    sleep 5
done
```

### Gestion des processus zombie

#### Identifier les zombies
```bash
# Processus avec etat Z (zombie)
ps aux | awk '$8 ~ /Z/ {print}'
ps -eo pid,ppid,state,comm | grep "Z"

# Compter les zombies
ps aux | awk '$8 ~ /Z/' | wc -l
```

#### Resoudre les zombies
```bash
# Les zombies ne peuvent pas etre tues directement
# Il faut tuer le processus parent ou lui envoyer SIGCHLD

# Trouver le parent d'un zombie
ps -eo pid,ppid,state,comm | grep "Z"

# Envoyer signal au parent pour qu'il nettoie
kill -CHLD <PPID>

# Si le parent ne coopere pas, le tuer
kill <PPID>
```

### Processus bloques (etat D)

#### Identification
```bash
# Processus en attente non-interruptible (souvent I/O)
ps aux | awk '$8 ~ /D/ {print}'

# Souvent lies a des problemes de stockage ou reseau
# Surveillance des I/O
iostat -x 1    # Si outil sysstat installe
```

#### Diagnostic avance
```bash
# Voir ce qu'attend le processus
cat /proc/1234/stack      # Stack trace du noyau
cat /proc/1234/wchan      # Fonction d'attente
lsof -p 1234              # Fichiers ouverts par le processus
```

---

## 6. Scripts de surveillance automatisee

### Script de monitoring des processus

```bash
#!/bin/bash
# process_monitor.sh - Surveillance automatique des processus

LOGFILE="/var/log/process_monitor.log"
CPU_THRESHOLD=80    # Seuil CPU en %
MEM_THRESHOLD=80    # Seuil memoire en %

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOGFILE"
}

# Surveiller utilisation CPU
check_cpu() {
    ps aux --sort=-%cpu | awk 'NR==2 {
        if($3 > '$CPU_THRESHOLD') 
            print "ALERTE CPU: Processus " $2 " (" $11 ") utilise " $3 "% CPU"
    }'
}

# Surveiller utilisation memoire  
check_memory() {
    ps aux --sort=-%mem | awk 'NR==2 {
        if($4 > '$MEM_THRESHOLD')
            print "ALERTE MEM: Processus " $2 " (" $11 ") utilise " $4 "% memoire"  
    }'
}

# Surveiller processus zombies
check_zombies() {
    zombie_count=$(ps aux | awk '$8 ~ /Z/' | wc -l)
    if [ "$zombie_count" -gt 0 ]; then
        echo "ALERTE: $zombie_count processus zombies detectes"
        ps aux | awk '$8 ~ /Z/ {print "  Zombie PID " $2 " PPID " $3 " CMD " $11}'
    fi
}

# Boucle principale
while true; do
    cpu_alert=$(check_cpu)
    mem_alert=$(check_memory)
    zombie_alert=$(check_zombies)
    
    [ -n "$cpu_alert" ] && log_message "$cpu_alert"
    [ -n "$mem_alert" ] && log_message "$mem_alert"
    [ -n "$zombie_alert" ] && log_message "$zombie_alert"
    
    sleep 60    # Verification chaque minute
done
```

### Script de nettoyage automatique

```bash
#!/bin/bash
# cleanup_processes.sh - Nettoyage automatique des processus

# Configuration
MAX_CPU_TIME=3600      # 1 heure en secondes
USERS_TO_CHECK=("alice" "bob" "charlie")
DRY_RUN=true          # true = simulation, false = action reelle

cleanup_long_running() {
    local user="$1"
    
    echo "Verification des processus de $user..."
    
    # Processus tournant depuis plus de MAX_CPU_TIME
    ps -u "$user" -o pid,etime,comm --no-headers | while read pid etime comm; do
        # Convertir etime en secondes (simple approximation)
        if echo "$etime" | grep -q ":"; then
            hours=$(echo "$etime" | cut -d: -f1)
            minutes=$(echo "$etime" | cut -d: -f2)
            seconds=$((hours * 3600 + minutes * 60))
            
            if [ "$seconds" -gt "$MAX_CPU_TIME" ]; then
                echo "  Processus long: PID $pid ($comm) - $etime"
                
                if [ "$DRY_RUN" = false ]; then
                    echo "    Arret du processus $pid"
                    kill -TERM "$pid"
                    sleep 5
                    # Kill force si toujours vivant
                    kill -0 "$pid" 2>/dev/null && kill -KILL "$pid"
                else
                    echo "    [SIMULATION] Arreterait le processus $pid"
                fi
            fi
        fi
    done
}

# Nettoyer pour chaque utilisateur
for user in "${USERS_TO_CHECK[@]}"; do
    if id "$user" >/dev/null 2>&1; then
        cleanup_long_running "$user"
    else
        echo "Utilisateur $user non trouve"
    fi
done
```

---

## 7. Outils complementaires

### pstree - Arbre des processus

```bash
# Arbre de tous les processus
pstree

# Arbre avec PID
pstree -p

# Arbre d'un utilisateur
pstree alice

# Arbre depuis un processus specifique
pstree 1234

# Avec arguments de commandes
pstree -a
```

### lsof - Fichiers ouverts

```bash
# Fichiers ouverts par un processus
lsof -p 1234

# Processus utilisant un fichier
lsof /var/log/syslog

# Processus utilisant un port reseau
lsof -i :80
lsof -i tcp:22

# Processus d'un utilisateur
lsof -u alice
```

### pidof - Trouver les PID

```bash
# PID d'un processus par nom
pidof nginx
pidof python

# Tous les PID (meme nom, plusieurs processus)
pidof firefox
```

### Outils systeme avances

#### iotop - Surveillance I/O
```bash
# Installation
sudo apt install iotop

# Surveillance I/O en temps reel
sudo iotop

# Mode batch
sudo iotop -b -n 3
```

#### atop - Surveillance avancee
```bash
# Installation  
sudo apt install atop

# Surveillance complete systeme
atop

# Historique (si logging active)
atop -r /var/log/atop/atop_20231225
```

---

## 8. Resolution de problemes courants

### Processus qui ne repond plus

#### Diagnostic
```bash
# Verifier l'etat du processus
ps -p 1234 -o pid,stat,comm

# Si etat D (non-interruptible) :
cat /proc/1234/wchan      # Fonction d'attente
lsof -p 1234              # Fichiers/ressources ouverts

# Si etat T (stopped) :
kill -CONT 1234           # Reprendre l'execution
```

#### Escalade de force
```bash
# Tentative douce
kill -TERM 1234
sleep 5

# Verifier si toujours actif
kill -0 1234 && {
    echo "Processus toujours actif, force brute..."
    kill -KILL 1234
}
```

### Systeme surcharge

#### Identification rapide
```bash
# Charge systeme
uptime
cat /proc/loadavg

# Top 10 processus CPU
ps aux --sort=-%cpu | head -11

# Top 10 processus memoire
ps aux --sort=-%mem | head -11

# Processus les plus recents
ps aux --sort=start_time | tail -10
```

#### Actions d'urgence
```bash
# Tuer les gros consommateurs non-essentiels
pkill -f "firefox|chrome|libreoffice"

# Limiter les nouveaux processus
ulimit -u 100    # Max 100 processus par utilisateur

# Surveillance continue
watch -n 1 'ps aux --sort=-%cpu | head -10'
```

---

## Resume

### Commandes essentielles
```bash
ps aux              # Lister tous les processus
ps -ef              # Format long avec relations parent/enfant
top                 # Surveillance temps reel
htop                # Top ameliore (si disponible)
kill PID            # Terminer processus (SIGTERM)
kill -9 PID         # Forcer terminaison (SIGKILL)
killall nom         # Tuer tous les processus avec ce nom
pkill -u user       # Tuer tous les processus d'un utilisateur
pgrep nom           # Trouver PID par nom
pstree              # Arbre des processus
```

### Signaux importants
- **SIGTERM (15)** : terminaison propre (defaut)
- **SIGKILL (9)** : terminaison forcee (non interceptable)
- **SIGHUP (1)** : recharger configuration
- **SIGSTOP/SIGCONT** : suspendre/reprendre
- **SIGINT (2)** : interruption (Ctrl+C)

### Etats des processus
- **R** : Running (en cours)
- **S** : Sleeping (endormi)
- **D** : Uninterruptible sleep (attente I/O)
- **T** : Stopped (suspendu)
- **Z** : Zombie (termine mais pas nettoye)

### Surveillance
- **CPU** : top, htop, ps --sort=-%cpu
- **Memoire** : top, htop, ps --sort=-%mem  
- **I/O** : iotop, iostat
- **Historique** : atop, pidstat

### Bonnes pratiques
- **Signaux escalades** : TERM puis KILL
- **Surveillance reguliere** : identifier les problemes tot
- **Scripts de monitoring** : automatiser la surveillance
- **Documentation** : noter les processus legitimes
- **Prudence avec SIGKILL** : risque de corruption de donnees

---

**Temps de lecture estime** : 25-30 minutes
**Niveau** : Intermediaire
**Pre-requis** : Navigation de base et permissions (modules 2-5)