# TP 6.1 : Gestion et surveillance des processus

## Objectifs
- Surveiller et analyser les processus en cours
- Utiliser ps, top, htop pour le monitoring
- Gerer les processus en arriere-plan avec &, nohup
- Configurer l'historique et les variables d'environnement
- Creer un systeme de surveillance personnalise

## Pre-requis
- Acces terminal Linux
- Connaissances des modules precedents
- Droits utilisateur normaux (pas forcement sudo)

## Duree estimee
- **Public accelere** : 90 minutes
- **Public etale** : 120 minutes

---

## Partie A : Exploration des processus

### Exercice 1 : Identification des processus courants

#### Etape 1 : Decouverte avec ps
```bash
# Creer un repertoire de travail
mkdir ~/tp_processus
cd ~/tp_processus

# Explorer les processus de base
ps                      # Processus du terminal courant
ps -u $USER             # Tous vos processus
ps aux | head -20       # Tous les processus (20 premiers)

# Identifier votre shell
echo $$                 # PID du shell courant
ps -p $$                # Details de votre shell
```

**Questions d'analyse** :
- Combien de processus sont actuellement en cours sur le systeme ?
- Quels sont les 5 processus qui consomment le plus de CPU ?
- Quels sont les 5 processus qui consomment le plus de memoire ?

```bash
# Repondre aux questions
ps aux | wc -l                           # Nombre total de processus
ps aux --sort=-%cpu | head -6            # Top 5 CPU
ps aux --sort=-%mem | head -6            # Top 5 memoire
```

#### Etape 2 : Analyse des processus systeme
```bash
# Processus root (systeme)
ps aux | grep "^root" | head -10

# Processus utilisateurs normaux
ps aux | awk '$3 >= 1000' | head -10

# Processus sans terminal (demons)
ps aux | grep "?" | head -10

# Arbre des processus
pstree | head -20
```

### Exercice 2 : Surveillance temps reel avec top

#### Etape 1 : Utilisation de base de top
```bash
# Lancer top
top

# Dans top, tester ces commandes :
# M : trier par memoire
# P : trier par CPU (defaut)
# T : trier par temps CPU
# k : tuer un processus
# u : filtrer par utilisateur
# 1 : afficher tous les CPU
# q : quitter
```

#### Etape 2 : Analyse de la charge systeme
```bash
# Observer ces metriques dans top :
# - Load average (ligne 1)
# - %CPU et %MEM par processus
# - Etats des processus (R, S, D, Z, T)

# En parallele, dans un autre terminal :
uptime                  # Charge systeme
free -h                 # Etat memoire
df -h                   # Espace disque

# Creer de la charge artificielle pour test
yes > /dev/null &       # Consommateur CPU
PID_CPU=$!

# Observer l'impact dans top, puis arreter
kill $PID_CPU
```

**Questions d'observation** :
- Quelle est la charge moyenne actuelle du systeme ?
- Combien de coeurs CPU a votre systeme ?
- Quelle est l'utilisation memoire globale ?

---

## Partie B : Gestion des processus

### Exercice 3 : Processus en arriere-plan

#### Etape 1 : Lancement en arriere-plan avec &
```bash
# Taches de test en arriere-plan
sleep 300 &                             # Tache simple
echo $!                                 # PID du dernier processus lance

ping google.fr > ping.log &            # Avec redirection
find / -name "*.conf" 2>/dev/null > find_results.txt &

# Verifier les jobs actifs
jobs
jobs -l                                 # Avec PID
```

#### Etape 2 : Controle des jobs (fg, bg, Ctrl+Z)
```bash
# Lancer une tache au premier plan
sleep 60

# Appuyer sur Ctrl+Z pour suspendre
# [1]+  Stopped                 sleep 60

# Reprendre en arriere-plan
bg %1

# Ramener au premier plan
fg %1

# Appuyer sur Ctrl+C pour arreter completement
```

#### Etape 3 : Gestion avancee des processus
```bash
# Lancer plusieurs taches
sleep 100 &
sleep 200 &
ping -c 100 localhost > ping_local.log &

# Lister et gerer
jobs                    # Liste des jobs
kill %1                 # Tuer le job 1
kill %ping              # Tuer le job contenant "ping"
killall sleep           # Tuer tous les processus sleep
```

### Exercice 4 : Persistance avec nohup

#### Etape 1 : Comprendre le probleme HUP
```bash
# Creer un script de test
cat > long_task.sh << 'EOF'
#!/bin/bash
echo "Debut de la tache longue : $(date)"
for i in {1..60}; do
    echo "Iteration $i : $(date)"
    sleep 2
done
echo "Fin de la tache : $(date)"
EOF

chmod +x long_task.sh
```

#### Etape 2 : Test avec et sans nohup
```bash
# Test 1 : sans nohup (dans un nouveau terminal si possible)
./long_task.sh &
# Fermer le terminal -> processus interrompu

# Test 2 : avec nohup
nohup ./long_task.sh &
# Fermer le terminal -> processus continue

# Verifier la sortie
cat nohup.out

# Avec redirection personnalisee
nohup ./long_task.sh > ma_sortie.log 2>&1 &
tail -f ma_sortie.log
```

---

## Partie C : Surveillance systeme

### Exercice 5 : Monitoring des ressources

#### Etape 1 : Surveillance de base
```bash
# Etat general du systeme
uptime                  # Charge et duree de fonctionnement
free -h                 # Memoire
df -h                   # Espace disque
lscpu                   # Information CPU

# Creer un rapport systeme
cat > rapport_systeme.txt << EOF
=== RAPPORT SYSTEME $(date) ===

Charge systeme:
$(uptime)

Utilisation memoire:
$(free -h)

Espace disque:
$(df -h)

Processus les plus consommateurs:
$(ps aux --sort=-%cpu | head -10)
EOF

cat rapport_systeme.txt
```

#### Etape 2 : Surveillance continue
```bash
# Script de monitoring simple
cat > monitor.sh << 'EOF'
#!/bin/bash
while true; do
    clear
    echo "=== SURVEILLANCE SYSTEME $(date) ==="
    echo
    echo "Charge systeme:"
    uptime
    echo
    echo "Top 5 processus CPU:"
    ps aux --sort=-%cpu | head -6
    echo
    echo "Top 5 processus memoire:"
    ps aux --sort=-%mem | head -6
    echo
    echo "Actualisation dans 10 secondes... (Ctrl+C pour arreter)"
    sleep 10
done
EOF

chmod +x monitor.sh

# Lancer en arriere-plan
nohup ./monitor.sh > monitor.log 2>&1 &
MONITOR_PID=$!

# Laisser tourner quelques minutes, puis arreter
sleep 60
kill $MONITOR_PID
```

### Exercice 6 : Analyse des logs et alertes

#### Etape 1 : Creation d'un systeme d'alerte simple
```bash
# Script d'alerte sur charge CPU
cat > cpu_alert.sh << 'EOF'
#!/bin/bash

CPU_THRESHOLD=50  # Seuil d'alerte CPU en %
LOG_FILE="cpu_alerts.log"

while true; do
    # Recuperer l'utilisation CPU
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    
    # Convertir en nombre entier pour comparaison
    CPU_INT=${CPU_USAGE%.*}
    
    if [ "$CPU_INT" -gt "$CPU_THRESHOLD" ]; then
        echo "$(date): ALERTE CPU $CPU_USAGE% > $CPU_THRESHOLD%" | tee -a "$LOG_FILE"
        
        # Top 3 des processus consommateurs
        echo "Top 3 processus:" >> "$LOG_FILE"
        ps aux --sort=-%cpu | head -4 | tail -3 >> "$LOG_FILE"
        echo "---" >> "$LOG_FILE"
    fi
    
    sleep 30
done
EOF

chmod +x cpu_alert.sh

# Lancer l'alerte en arriere-plan
./cpu_alert.sh &
ALERT_PID=$!

# Creer de la charge pour tester
yes > /dev/null &
LOAD_PID=$!

# Attendre quelques alertes
sleep 120

# Arreter la charge et les alertes
kill $LOAD_PID $ALERT_PID

# Verifier les alertes
cat cpu_alerts.log
```

---

## Partie D : Historique et personnalisation

### Exercice 7 : Maitrise de l'historique

#### Etape 1 : Navigation dans l'historique
```bash
# Explorer l'historique actuel
history | tail -20

# Recherche dans l'historique (Ctrl+R)
# Appuyer sur Ctrl+R puis taper : ssh
# Naviguer avec Ctrl+R pour d'autres resultats

# Expansion d'historique
!!                      # Repeter derniere commande
sudo !!                 # Derniere commande avec sudo
!ps                     # Derniere commande commencant par "ps"
!?grep                  # Derniere commande contenant "grep"

# Substitution rapide
echo "Helllo World"
^ll^l                   # Corriger la faute de frappe
```

#### Etape 2 : Configuration de l'historique
```bash
# Voir la configuration actuelle
echo "HISTSIZE: $HISTSIZE"
echo "HISTFILESIZE: $HISTFILESIZE" 
echo "HISTCONTROL: $HISTCONTROL"
echo "HISTFILE: $HISTFILE"

# Configuration temporaire amelioree
export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

# Tester avec quelques commandes
ls
pwd
ls
history | tail -5       # Observer les timestamps et deduplication
```

### Exercice 8 : Variables d'environnement et personnalisation

#### Etape 1 : Explorer les variables importantes
```bash
# Variables systeme essentielles
echo "Utilisateur: $USER"
echo "Repertoire personnel: $HOME"
echo "Shell: $SHELL"
echo "PATH: $PATH"
echo "Editeur: $EDITOR"

# Lister toutes les variables
env | head -20
printenv | grep -E "(HOME|USER|PATH|SHELL)" | sort
```

#### Etape 2 : Personnalisation du PATH
```bash
# Creer un repertoire pour scripts personnels
mkdir -p ~/bin

# Creer un script utile
cat > ~/bin/sysinfo << 'EOF'
#!/bin/bash
echo "=== INFORMATIONS SYSTEME ==="
echo "Utilisateur: $(whoami)"
echo "Hote: $(hostname)"
echo "Uptime: $(uptime)"
echo "Espace disque:"
df -h | head -5
echo "Charge: $(cat /proc/loadavg)"
EOF

chmod +x ~/bin/sysinfo

# Ajouter au PATH temporairement
export PATH="$HOME/bin:$PATH"

# Tester le script
sysinfo
which sysinfo
```

#### Etape 3 : Alias et fonctions utiles
```bash
# Creer des alias pratiques
alias ll='ls -la'
alias ..='cd ..'
alias df='df -h'
alias free='free -h'
alias psg='ps aux | grep'

# Tester les alias
ll
..
pwd
cd tp_processus

# Creer des fonctions utiles
mkcd() { mkdir -p "$1" && cd "$1"; }
ff() { find . -name "*$1*"; }

# Tester les fonctions
mkcd test_fonction
pwd
cd ..
ff "*.sh"
```

---

## Partie E : Projet integre - Tableau de bord systeme

### Exercice 9 : Creation d'un tableau de bord

#### Etape 1 : Script de tableau de bord
```bash
cat > dashboard.sh << 'EOF'
#!/bin/bash

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    clear
    echo "=================================="
    echo "    TABLEAU DE BORD SYSTEME"
    echo "    $(hostname) - $(date)"
    echo "=================================="
    echo
}

system_info() {
    echo -e "${GREEN} INFORMATIONS SYSTEME${NC}"
    echo "  Utilisateur : $(whoami)"
    echo "  Uptime      : $(uptime -p)"
    echo "  Processeurs : $(nproc) CPU"
    echo
}

load_info() {
    echo -e "${GREEN}[FAST] CHARGE SYSTEME${NC}"
    load_avg=$(uptime | awk -F'load average: ' '{print $2}')
    echo "  Load Average: $load_avg"
    
    # Alerte si charge > 2.0
    load1=$(echo $load_avg | cut -d, -f1 | xargs)
    if (( $(echo "$load1 > 2.0" | bc -l 2>/dev/null || echo "0") )); then
        echo -e "  ${RED}[WARN]  Charge elevee detectee${NC}"
    else
        echo -e "  ${GREEN}[OK] Charge normale${NC}"
    fi
    echo
}

memory_info() {
    echo -e "${GREEN} MEMOIRE${NC}"
    free -h | head -2 | while read line; do
        echo "  $line"
    done
    echo
}

disk_info() {
    echo -e "${GREEN} ESPACE DISQUE${NC}"
    df -h | grep -E "^/dev" | head -5 | while read line; do
        usage=$(echo $line | awk '{print $5}' | sed 's/%//')
        if [ "$usage" -gt "90" ]; then
            echo -e "  ${RED}$line${NC}"
        elif [ "$usage" -gt "80" ]; then
            echo -e "  ${YELLOW}$line${NC}"
        else
            echo "  $line"
        fi
    done
    echo
}

process_info() {
    echo -e "${GREEN}[LOADING] TOP 5 PROCESSUS CPU${NC}"
    ps aux --sort=-%cpu | head -6 | tail -5 | while read line; do
        echo "  $line"
    done
    echo
}

network_info() {
    echo -e "${GREEN} RESEAU${NC}"
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        echo -e "  ${GREEN}[OK] Connectivite Internet OK${NC}"
    else
        echo -e "  ${RED}[NOK] Pas de connectivite Internet${NC}"
    fi
    echo
}

# Fonction principale
main() {
    print_header
    system_info
    load_info
    memory_info
    disk_info
    process_info
    network_info
    echo "Derniere mise a jour: $(date)"
}

# Execution
if [ "$1" = "loop" ]; then
    while true; do
        main
        echo "Actualisation dans 30 secondes... (Ctrl+C pour arreter)"
        sleep 30
    done
else
    main
fi
EOF

chmod +x dashboard.sh
```

#### Etape 2 : Test du tableau de bord
```bash
# Test simple
./dashboard.sh

# Mode continu
./dashboard.sh loop &
DASH_PID=$!

# Laisser tourner 2 minutes
sleep 120

# Arreter
kill $DASH_PID
```

### Exercice 10 : Configuration permanente

#### Etape 1 : Sauvegarde et personnalisation ~/.bashrc
```bash
# Sauvegarder la configuration actuelle
cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d)

# Ajouter nos personnalisations
cat >> ~/.bashrc << 'EOF'

# === PERSONNALISATIONS TP PROCESSUS ===
# Historique ameliore
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
shopt -s histappend

# Variables d'environnement
export EDITOR=nano
export PATH="$HOME/bin:$PATH"

# Alias utiles
alias ll='ls -alF'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias df='df -h'
alias free='free -h'
alias psg='ps aux | grep'

# Fonctions personnalisees
mkcd() { mkdir -p "$1" && cd "$1"; }
ff() { find . -name "*$1*"; }
psgrep() { ps aux | grep -v grep | grep "$1"; }

# Monitoring rapide
topcpu() { ps aux --sort=-%cpu | head -11; }
topmem() { ps aux --sort=-%mem | head -11; }

EOF

# Recharger la configuration
source ~/.bashrc

# Tester les nouvelles fonctionnalites
ll
topcpu
psgrep bash
```

---

## Partie F : Validation et nettoyage

### Exercice 11 : Tests de validation

#### Etape 1 : Verifications fonctionnelles
```bash
# Test historique
history | tail -10      # Doit avoir timestamps
echo "test" && !!       # Repetition commande

# Test variables
echo $HISTSIZE          # Doit etre 10000
echo $PATH | grep "$HOME/bin"  # Doit contenir ~/bin

# Test alias
ll                      # Doit fonctionner
topcpu                  # Doit afficher top processus

# Test fonctions
mkcd test_final
pwd                     # Doit etre dans test_final
cd ..
```

#### Etape 2 : Performance et surveillance
```bash
# Creer une charge controlee
for i in {1..3}; do
    yes > /dev/null &
done
LOAD_PIDS=$(jobs -p)

# Observer avec les outils
./dashboard.sh
topcpu
top -n 1

# Nettoyer la charge
kill $LOAD_PIDS

# Verifier l'etat final
uptime
free -h
```

### Exercice 12 : Nettoyage et documentation

#### Etape 1 : Nettoyage des processus de test
```bash
# Arreter tous les processus en cours
jobs
killall yes sleep ping 2>/dev/null || true
killall -u $USER dashboard.sh monitor.sh cpu_alert.sh 2>/dev/null || true

# Verifier qu'il n'y a plus de processus orphelins
ps -u $USER | grep -E "(sleep|yes|ping|dashboard|monitor)" || echo "Nettoyage OK"
```

#### Etape 2 : Documentation des acquis
```bash
# Creer un resume des apprentissages
cat > tp_processus_resume.md << 'EOF'
# Resume TP Processus et Surveillance

## Commandes maitrisees
- `ps aux` : lister tous les processus
- `top` / `htop` : surveillance temps reel
- `jobs`, `bg`, `fg` : gestion des jobs
- `nohup` : processus persistants
- `kill`, `killall` : terminaison processus

## Outils de surveillance
- `uptime` : charge systeme
- `free -h` : memoire
- `df -h` : espace disque
- Scripts personnalises de monitoring

## Personnalisations appliquees
- Historique etendu (10000 commandes)
- Alias utiles (ll, df, free, psg)
- Fonctions personnalisees (mkcd, ff, topcpu)
- PATH etendu avec ~/bin

## Fichiers crees
- ~/bin/sysinfo : informations systeme
- dashboard.sh : tableau de bord
- Configuration dans ~/.bashrc

## Points cles retenus
- Surveillance proactive necessaire
- Processus en arriere-plan avec &
- nohup pour persistance
- Configuration environment dans ~/.bashrc
EOF

cat tp_processus_resume.md
```

---

## Questions de validation

### Quiz pratique

1. **Gestion des processus**
   - Comment lancer une commande en arriere-plan ?
   - Quelle est la difference entre `kill PID` et `kill -9 PID` ?
   - Comment faire persister un processus apres deconnexion ?

2. **Surveillance**
   - Comment voir les 5 processus qui consomment le plus de CPU ?
   - Que signifie un load average de 2.5 sur un systeme 4 coeurs ?
   - Comment surveiller l'utilisation memoire en temps reel ?

3. **Historique et environment**
   - Comment rechercher une commande dans l'historique ?
   - Ou definir des alias permanents ?
   - Comment ajouter un repertoire au PATH ?

### Exercices de revision
```bash
# 1. Creer une surveillance personnalisee qui alerte si :
#    - Load average > 1.5
#    - Utilisation memoire > 80%
#    - Espace disque > 85%

# 2. Configurer un environnement avec :
#    - Historique de 50000 commandes avec timestamps
#    - Aliases pour administration systeme
#    - Fonctions de recherche et navigation

# 3. Creer un script de nettoyage qui :
#    - Trouve les processus anciens de plus de 2h
#    - Les affiche avec confirmation
#    - Les termine proprement
```

---

## Solutions des exercices

### Solutions principales

#### Exercice 3 - Gestion jobs
```bash
# Lancer en arriere-plan
sleep 300 &            # Job 1
ping google.fr &       # Job 2

# Controler
jobs                   # Lister
fg %1                  # Ramener job 1
# Ctrl+Z                # Suspendre
bg %1                  # Reprendre en arriere-plan
kill %2                # Tuer job 2
```

#### Exercice 5 - Surveillance
```bash
# Commandes de base
ps aux --sort=-%cpu | head -6    # Top CPU
ps aux --sort=-%mem | head -6    # Top memoire
uptime                           # Charge systeme
free -h                          # Memoire
df -h                           # Disque
```

#### Exercice 8 - Personnalisation
```bash
# Dans ~/.bashrc
export HISTSIZE=10000
export PATH="$HOME/bin:$PATH"
alias ll='ls -alF'
mkcd() { mkdir -p "$1" && cd "$1"; }
```

---

## Points cles a retenir

### Commandes essentielles
```bash
# Processus
ps aux                 # Tous les processus
top                    # Surveillance temps reel
jobs                   # Jobs du shell
kill PID               # Terminer processus
nohup command &        # Processus persistant

# Surveillance
uptime                 # Charge systeme
free -h               # Memoire
df -h                 # Espace disque
vmstat                # Statistiques VM

# Historique
history               # Voir l'historique
!!                    # Derniere commande
Ctrl+R                # Recherche interactive
```

### Variables importantes
```bash
HISTSIZE=10000        # Taille historique memoire
HISTFILESIZE=20000    # Taille historique fichier
HISTCONTROL=ignoreboth # Controle historique
PATH=$HOME/bin:$PATH   # Chemins executables
EDITOR=nano           # Editeur par defaut
```

### Bonnes pratiques
- **Surveillance proactive** : monitorer regulierement le systeme
- **Processus propres** : toujours nettoyer les processus de test
- **Configuration documentee** : commenter les personnalisations
- **Sauvegarde config** : sauvegarder avant modifications
- **Tests reguliers** : valider les configurations

---

**Temps estime total** : 120-150 minutes selon le public  
**Difficulte** : Intermediaire
**Validation** : Exercices pratiques + quiz + configuration fonctionnelle