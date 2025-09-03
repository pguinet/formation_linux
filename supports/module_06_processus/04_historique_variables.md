# Module 6.4 : Historique des commandes et variables d'environnement

## Objectifs d'apprentissage
- Maitriser l'historique des commandes avec history
- Configurer et personnaliser le comportement de l'historique
- Comprendre et utiliser les variables d'environnement
- Personnaliser l'environnement shell avec les fichiers de configuration
- Creer et gerer des alias pour optimiser le travail

## Introduction

L'**historique des commandes** et les **variables d'environnement** sont des elements essentiels pour une utilisation efficace du shell Linux. Ils permettent de retrouver facilement des commandes precedentes et de personnaliser l'environnement de travail.

---

## 1. Historique des commandes

### Commande history - Gerer l'historique

#### Utilisation de base
```bash
# Afficher tout l'historique
history

# Afficher les 20 dernieres commandes
history 20

# Rechercher dans l'historique
history | grep ssh
history | grep "git commit"

# Numerotation et format
history | tail -10
```

#### Exemple de sortie history
```bash
history | tail -5
#  501  ls -la
#  502  cd /var/log
#  503  sudo tail -f syslog
#  504  cd ~
#  505  history
```

### Navigation rapide dans l'historique

#### Raccourcis clavier essentiels
```bash
# Navigation
^           # Commande precedente
v           # Commande suivante
Ctrl+R      # Recherche interactive dans l'historique
Ctrl+G      # Annuler la recherche
Ctrl+P      # Precedente (equivalent a ^)
Ctrl+N      # Suivante (equivalent a v)

# Edition rapide
Ctrl+A      # Debut de ligne
Ctrl+E      # Fin de ligne
Ctrl+K      # Supprimer jusqu'a la fin
Ctrl+U      # Supprimer jusqu'au debut
```

#### Recherche interactive (Ctrl+R)
```bash
# Appuyer sur Ctrl+R, puis taper des lettres
(reverse-i-search)`ssh`: ssh user@server.com
#                   |        |
#                   |        +- Commande trouvee
#                   +- Texte recherche

# Navigation dans les resultats
Ctrl+R      # Resultat precedent  
Ctrl+S      # Resultat suivant (si configure)
Enter       # Executer la commande
Tab         # Editer la commande
Escape      # Utiliser sans executer
```

### Execution rapide depuis l'historique

#### Expansion d'historique avec !
```bash
# Par numero
!501        # Executer la commande numero 501
!-2         # Avant-derniere commande
!!          # Derniere commande (tres utile)

# Par recherche de debut
!ssh        # Derniere commande commencant par "ssh"
!git        # Derniere commande commencant par "git"

# Par recherche de contenu
!?config    # Derniere commande contenant "config"

# Substitution rapide
^ancien^nouveau     # Remplacer dans la derniere commande
sudo !!             # Relancer la derniere commande avec sudo
```

#### Exemples pratiques d'expansion
```bash
# Scenario : vous avez oublie sudo
chmod 644 /etc/hosts
# Permission denied

# Solution rapide :
sudo !!
# Equivalent a : sudo chmod 644 /etc/hosts

# Scenario : corriger une typo
cat /var/log/syslog | grep "eror"
# Aucun resultat (faute de frappe)

# Correction rapide :
^eror^error
# Equivalent a : cat /var/log/syslog | grep "error"
```

---

## 2. Configuration de l'historique

### Variables de configuration

#### Variables principales
```bash
# Voir la configuration actuelle
echo $HISTSIZE      # Taille en memoire
echo $HISTFILESIZE  # Taille dans le fichier
echo $HISTFILE      # Fichier d'historique
echo $HISTCONTROL   # Controle du comportement

# Configuration typique
export HISTSIZE=5000        # 5000 commandes en memoire
export HISTFILESIZE=10000   # 10000 commandes dans le fichier
export HISTFILE=~/.bash_history
```

#### Options de HISTCONTROL
```bash
# ignorespace : ignorer les commandes commencant par un espace
export HISTCONTROL=ignorespace

# ignoredups : ignorer les doublons consecutifs
export HISTCONTROL=ignoredups

# ignoreboth : combiner ignorespace et ignoredups  
export HISTCONTROL=ignoreboth

# erasedups : supprimer tous les anciens doublons
export HISTCONTROL=erasedups

# Exemples d'usage :
ls -la          # Enregistre
ls -la          # Ignore si ignoredups actif
 ls -la         # Ignore si ignorespace actif (espace au debut)
```

### Options avancees shopt

#### Commandes shopt pour l'historique
```bash
# Voir les options actuelles
shopt | grep hist

# Options utiles a activer
shopt -s histappend     # Ajouter a l'historique au lieu d'ecraser
shopt -s histverify     # Verifier les expansions ! avant execution
shopt -s histreedit     # Permettre reedition des expansions echouees

# Option pour inclure timestamp
shopt -s histappend
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
```

#### Historique avec timestamp
```bash
# Activer les timestamps
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

# L'historique affichera maintenant :
history | tail -5
#  501  2023-12-25 14:30:15 ls -la
#  502  2023-12-25 14:30:20 cd /var/log  
#  503  2023-12-25 14:30:25 sudo tail -f syslog
#  504  2023-12-25 14:30:30 cd ~
#  505  2023-12-25 14:30:35 history
```

### Configuration persistante

#### Fichier ~/.bashrc
```bash
# Editer le fichier de configuration
nano ~/.bashrc

# Ajouter a la fin :
# Configuration historique personnalisee
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
export HISTIGNORE="ls:ll:la:pwd:clear:history:exit"

# Options shell
shopt -s histappend
shopt -s histverify
shopt -s histreedit

# Recharger la configuration
source ~/.bashrc
```

#### Ignorer certaines commandes
```bash
# HISTIGNORE permet d'exclure des commandes
export HISTIGNORE="ls:ll:la:pwd:clear:history:exit:bg:fg:jobs"

# Format avec patterns :
export HISTIGNORE="ls*:pwd:clear:history:exit:[ ]*"
#                   |    |                    |
#                   |    |                    +- Commandes avec espace initial
#                   |    +- Commandes exactes
#                   +- Toutes commandes commencant par "ls"
```

---

## 3. Variables d'environnement

### Concepts de base

#### Types de variables
```bash
# Variable locale (shell courant seulement)
ma_variable="valeur"
echo $ma_variable

# Variable d'environnement (heritee par processus enfants)
export MA_VAR_GLOBALE="valeur globale"
echo $MA_VAR_GLOBALE

# Verifier la difference
bash                    # Nouveau shell
echo $ma_variable       # Vide (variable locale)
echo $MA_VAR_GLOBALE    # Valeur presente (exportee)
exit
```

#### Variables standard importantes
```bash
# Variables systeme essentielles
echo $HOME              # Repertoire personnel
echo $USER              # Nom d'utilisateur
echo $PATH              # Chemins de recherche des commandes
echo $PWD               # Repertoire courant
echo $SHELL             # Shell par defaut
echo $TERM              # Type de terminal
echo $LANG              # Langue du systeme
echo $PS1               # Prompt principal
echo $PS2               # Prompt secondaire (continuation)

# Variables de session
echo $SSH_CLIENT        # Information client SSH (si applicable)
echo $DISPLAY           # Affichage X11 (si applicable)
echo $TMPDIR            # Repertoire temporaire
```

### Gestion des variables

#### Affichage et manipulation
```bash
# Lister toutes les variables d'environnement
env
printenv

# Variable specifique
printenv HOME
echo $HOME

# Definir une variable temporaire
export EDITOR=nano
export BROWSER=firefox

# Supprimer une variable
unset ma_variable
unset MA_VAR_GLOBALE
```

#### Variable PATH - Chemins de commandes

##### Comprendre PATH
```bash
# Voir le PATH actuel
echo $PATH
# Exemple : /usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games

# Chaque repertoire separe par :
# Linux cherche les commandes dans l'ordre de gauche a droite
```

##### Modifier PATH
```bash
# Ajouter un repertoire au debut (priorite haute)
export PATH="/mon/nouveau/path:$PATH"

# Ajouter a la fin (priorite basse)
export PATH="$PATH:/mon/autre/path"

# Exemples pratiques
export PATH="$HOME/bin:$PATH"              # Scripts personnels
export PATH="$PATH:/opt/monapp/bin"        # Application specifique
export PATH="/usr/local/python3.9/bin:$PATH"  # Version Python specifique

# Verifier qu'une commande est trouvee
which python
whereis python
type python
```

---

## 4. Personnalisation du shell

### Fichiers de configuration

#### Hierarchie des fichiers bash
```bash
# Fichiers systeme (pour tous les utilisateurs)
/etc/profile            # Execute pour shells login
/etc/bash.bashrc        # Execute pour tous les shells bash
/etc/environment        # Variables d'environnement globales

# Fichiers utilisateur (dans $HOME)
~/.profile              # Execute pour shells login (tout shell POSIX)
~/.bashrc               # Execute pour shells bash interactifs non-login
~/.bash_profile         # Execute pour shells bash login (priorite sur .profile)
~/.bash_logout          # Execute a la deconnexion

# Ordre d'execution pour shell bash login :
# 1. /etc/profile
# 2. ~/.bash_profile OU ~/.bash_login OU ~/.profile (premier trouve)
# 3. ~/.bashrc (si appele depuis .bash_profile)
```

#### Configuration personnelle dans ~/.bashrc
```bash
# Exemple de ~/.bashrc personnalise
# Editer le fichier
nano ~/.bashrc

# === CONFIGURATION HISTORIQUE ===
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
export HISTIGNORE="ls:ll:pwd:clear:history:exit"
shopt -s histappend

# === VARIABLES D'ENVIRONNEMENT ===
export EDITOR=nano
export BROWSER=firefox
export LESS='-R'        # Couleurs dans less
export GREP_COLOR='1;31'   # Couleurs grep

# === PERSONNALISATION PATH ===
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# === ALIASES ===
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# === FONCTIONS PERSONNALISEES ===
# Creer repertoire et s'y deplacer
mkcd() { mkdir -p "$1" && cd "$1"; }

# Recherche rapide de fichiers
ff() { find . -type f -name "*$1*"; }

# === PROMPT PERSONNALISE ===
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Recharger avec : source ~/.bashrc
```

### Personnalisation du prompt (PS1)

#### Comprendre PS1
```bash
# Variables de prompt
echo $PS1      # Prompt principal
echo $PS2      # Prompt de continuation

# Codes d'echappement utiles
\u      # Nom d'utilisateur
\h      # Nom d'hote (court)
\H      # Nom d'hote (complet)
\w      # Repertoire courant (chemin complet)
\W      # Repertoire courant (nom seulement)
\d      # Date
\t      # Heure (format 24h)
\T      # Heure (format 12h)
\$      # $ pour utilisateur normal, # pour root
```

#### Exemples de prompts personnalises
```bash
# Prompt simple avec couleurs
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# Resultat : user@hostname:~/directory$

# Prompt avec heure
export PS1='[\t] \u@\h:\w\$ '
# Resultat : [14:30:25] user@hostname:~/directory$

# Prompt avec git branch (necessite fonction git)
git_branch() {
    git branch 2>/dev/null | grep '^*' | colrm 1 2
}
export PS1='\u@\h:\w$(git_branch)\$ '

# Prompt multi-lignes
export PS1='\n+-[\[\033[01;32m\]\u@\h\[\033[00m\]] - [\[\033[01;34m\]\w\[\033[00m\]]\n+-\$ '
```

---

## 5. Alias - Raccourcis de commandes

### Creer et utiliser des alias

#### Syntaxe de base
```bash
# Creer un alias
alias nom='commande'

# Exemples simples
alias ll='ls -la'
alias la='ls -A'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Utiliser l'alias
ll          # Equivalent a : ls -la
..          # Equivalent a : cd ..
```

#### Alias avec arguments
```bash
# Alias ne peut pas prendre d'arguments directement
# Utiliser des fonctions pour cela

# [NOK] Incorrect (ne marche pas)
alias search='find . -name'

# [OK] Correct avec fonction
search() { find . -name "*$1*"; }

# Ou alias avec placeholder pour arguments communs
alias psg='ps aux | grep'
# Usage : psg firefox
```

### Alias utiles pour l'administration

#### Navigation et fichiers
```bash
alias ll='ls -alF'
alias la='ls -A' 
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'           # Retour repertoire precedent

# Securite
alias rm='rm -i'            # Confirmation avant suppression
alias cp='cp -i'            # Confirmation avant ecrasement
alias mv='mv -i'            # Confirmation avant ecrasement
alias ln='ln -i'            # Confirmation avant ecrasement
```

#### Commandes systeme
```bash
# Surveillance
alias h='history'
alias j='jobs -l'
alias ps='ps auxf'          # Format etendu avec arbre
alias psg='ps aux | grep'   # Recherche processus
alias df='df -h'            # Format lisible
alias du='du -ch'           # Format lisible avec total
alias free='free -h'        # Format lisible

# Reseau
alias ports='netstat -tulanp'
alias listening='ss -tuln'
alias ping='ping -c 5'      # Limiter a 5 pings

# Logs
alias syslog='sudo tail -f /var/log/syslog'
alias messages='sudo tail -f /var/log/messages'
alias auth='sudo tail -f /var/log/auth.log'
```

#### Alias avances avec couleurs
```bash
# Grep avec couleurs
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto' 
alias egrep='egrep --color=auto'

# ls avec couleurs
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

# Differences avec couleurs
alias diff='diff --color=auto'
```

### Gestion des alias

#### Lister et supprimer
```bash
# Voir tous les alias
alias

# Voir un alias specifique
alias ll

# Supprimer un alias
unalias ll
unalias -a      # Supprimer tous les alias
```

#### Alias temporaires vs permanents
```bash
# Alias temporaire (session courante)
alias temp='echo "Temporaire"'

# Alias permanent (ajouter a ~/.bashrc)
echo "alias perm='echo \"Permanent\"'" >> ~/.bashrc
source ~/.bashrc
```

---

## 6. Fonctions shell personnalisees

### Creer des fonctions utiles

#### Syntaxe de base
```bash
# Syntaxe fonction
nom_fonction() {
    commandes
}

# Ou
function nom_fonction {
    commandes
}
```

#### Fonctions d'administration utiles

##### Navigation amelioree
```bash
# Creer repertoire et s'y deplacer
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Remonter de n niveaux
up() {
    local levels=${1:-1}
    local path=""
    for ((i=1; i<=levels; i++)); do
        path+="../"
    done
    cd "$path"
}

# Usage : up 3  # Equivalent a cd ../../../
```

##### Recherche et information
```bash
# Recherche de fichiers intelligente
ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

# Recherche dans le contenu des fichiers
fif() {
    grep -r -l "$1" . 2>/dev/null
}

# Information sur commande
cmdinfo() {
    echo "=== INFORMATIONS SUR LA COMMANDE : $1 ==="
    echo "Type : $(type "$1")"
    echo "Emplacement : $(which "$1" 2>/dev/null || echo "Non trouve dans PATH")"
    echo "Manuel disponible :"
    man "$1" 2>/dev/null | head -5 || echo "Pas de manuel"
}
```

##### Archives et compression
```bash
# Extraction intelligente
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "Format non supporte : '$1'" ;;
        esac
    else
        echo "Fichier non trouve : '$1'"
    fi
}

# Creation d'archive rapide
tardir() {
    tar czf "${1%/}.tar.gz" "$1"
}
```

##### Surveillance systeme
```bash
# Surveillance processus
psgrep() {
    ps aux | grep -v grep | grep "$1"
}

# Top 10 processus CPU
topcpu() {
    ps aux --sort=-%cpu | head -11
}

# Top 10 processus memoire
topmem() {
    ps aux --sort=-%mem | head -11
}

# Surveiller un fichier log avec couleurs
logwatch() {
    tail -f "$1" | grep --color=auto -E "ERROR|WARN|FAIL|.*"
}
```

---

## 7. Configuration avancee et scripts

### Script de configuration automatique

```bash
#!/bin/bash
# setup_environment.sh - Configuration automatique environnement

BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d)"
BASHRC="$HOME/.bashrc"

# Creer sauvegarde
backup_config() {
    echo "Sauvegarde de la configuration actuelle..."
    mkdir -p "$BACKUP_DIR"
    cp "$BASHRC" "$BACKUP_DIR/bashrc_backup" 2>/dev/null || true
    echo "Sauvegarde dans : $BACKUP_DIR"
}

# Configuration historique optimisee
setup_history() {
    echo "Configuration de l'historique..."
    cat >> "$BASHRC" << 'EOF'

# === CONFIGURATION HISTORIQUE OPTIMISEE ===
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
export HISTIGNORE="ls:ll:la:pwd:clear:history:exit:bg:fg:jobs"

# Options bash pour historique
shopt -s histappend
shopt -s histverify
shopt -s histreedit

EOF
}

# Alias utiles
setup_aliases() {
    echo "Configuration des alias..."
    cat >> "$BASHRC" << 'EOF'

# === ALIAS UTILES ===
# Navigation
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'

# Securite  
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Surveillance
alias df='df -h'
alias du='du -ch'
alias free='free -h'
alias ps='ps auxf'
alias psg='ps aux | grep'

# Logs
alias syslog='sudo tail -f /var/log/syslog'
alias auth='sudo tail -f /var/log/auth.log'

# Couleurs
alias grep='grep --color=auto'
alias ls='ls --color=auto'

EOF
}

# Fonctions personnalisees
setup_functions() {
    echo "Configuration des fonctions..."
    cat >> "$BASHRC" << 'EOF'

# === FONCTIONS PERSONNALISEES ===
# Creer repertoire et s'y deplacer
mkcd() { mkdir -p "$1" && cd "$1"; }

# Recherche de fichiers
ff() { find . -type f -iname "*$1*" 2>/dev/null; }

# Extraction intelligente
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.tar)       tar xf "$1"     ;;
            *.zip)       unzip "$1"      ;;
            *)           echo "Format non supporte : '$1'" ;;
        esac
    else
        echo "Fichier non trouve : '$1'"
    fi
}

# Surveillance processus  
psgrep() { ps aux | grep -v grep | grep "$1"; }
topcpu() { ps aux --sort=-%cpu | head -11; }
topmem() { ps aux --sort=-%mem | head -11; }

EOF
}

# Variables d'environnement
setup_environment() {
    echo "Configuration des variables d'environnement..."
    cat >> "$BASHRC" << 'EOF'

# === VARIABLES D'ENVIRONNEMENT ===
export EDITOR=nano
export LESS='-R'
export GREP_COLOR='1;31'
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

EOF
}

# Prompt personnalise
setup_prompt() {
    echo "Configuration du prompt..."
    cat >> "$BASHRC" << 'EOF'

# === PROMPT PERSONNALISE ===
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

EOF
}

# Fonction principale
main() {
    echo "=== CONFIGURATION AUTOMATIQUE ENVIRONNEMENT SHELL ==="
    echo
    
    backup_config
    setup_history
    setup_aliases
    setup_functions
    setup_environment
    setup_prompt
    
    echo
    echo "Configuration terminee !"
    echo "Redemarrez votre terminal ou executez : source ~/.bashrc"
    echo "Sauvegarde de l'ancienne config : $BACKUP_DIR"
}

# Execution
main
```

---

## Resume

### Commandes historique essentielles
```bash
history              # Voir tout l'historique
history 20           # 20 dernieres commandes
!!                   # Derniere commande
!ssh                 # Derniere commande commencant par "ssh"
!?config             # Derniere commande contenant "config"
^old^new             # Substituer dans la derniere commande
Ctrl+R               # Recherche interactive
```

### Variables importantes
```bash
# Historique
HISTSIZE=10000       # Taille en memoire
HISTFILESIZE=20000   # Taille dans fichier
HISTCONTROL=ignoreboth   # Comportement
HISTIGNORE="ls:pwd"  # Commandes a ignorer

# Environnement  
PATH                 # Chemins de recherche commandes
HOME                 # Repertoire personnel
USER                 # Utilisateur courant
EDITOR               # Editeur par defaut
PS1                  # Prompt principal
```

### Fichiers de configuration
```bash
~/.bashrc            # Configuration bash interactive
~/.bash_profile      # Configuration bash login
~/.profile           # Configuration shell generale
/etc/bash.bashrc     # Configuration globale bash
```

### Alias utiles de base
```bash
alias ll='ls -alF'
alias ..='cd ..'
alias df='df -h'
alias free='free -h'
alias grep='grep --color=auto'
alias rm='rm -i'
alias psg='ps aux | grep'
```

### Fonctions recommandees
```bash
mkcd() { mkdir -p "$1" && cd "$1"; }     # Creer et aller
ff() { find . -name "*$1*"; }           # Recherche fichier
extract() { ... }                       # Extraction archives
psgrep() { ps aux | grep "$1"; }        # Recherche processus
```

### Bonnes pratiques
- **Sauvegarde** : toujours sauvegarder avant modification
- **Test** : tester les modifications avec `source ~/.bashrc`
- **Documentation** : commenter les personnalisations
- **Modularite** : separer les configurations par theme
- **Portabilite** : eviter les dependances systeme specifiques

---

**Temps de lecture estime** : 35-40 minutes
**Niveau** : Intermediaire a avance  
**Pre-requis** : Utilisation de base du shell, navigation fichiers