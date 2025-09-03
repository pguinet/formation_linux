# Module 6.4 : Historique des commandes et variables d'environnement

## Objectifs d'apprentissage
- Maîtriser l'historique des commandes avec history
- Configurer et personnaliser le comportement de l'historique
- Comprendre et utiliser les variables d'environnement
- Personnaliser l'environnement shell avec les fichiers de configuration
- Créer et gérer des alias pour optimiser le travail

## Introduction

L'**historique des commandes** et les **variables d'environnement** sont des éléments essentiels pour une utilisation efficace du shell Linux. Ils permettent de retrouver facilement des commandes précédentes et de personnaliser l'environnement de travail.

---

## 1. Historique des commandes

### Commande history - Gérer l'historique

#### Utilisation de base
```bash
# Afficher tout l'historique
history

# Afficher les 20 dernières commandes
history 20

# Rechercher dans l'historique
history | grep ssh
history | grep "git commit"

# Numérotation et format
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
↑           # Commande précédente
↓           # Commande suivante
Ctrl+R      # Recherche interactive dans l'historique
Ctrl+G      # Annuler la recherche
Ctrl+P      # Précédente (équivalent à ↑)
Ctrl+N      # Suivante (équivalent à ↓)

# Édition rapide
Ctrl+A      # Début de ligne
Ctrl+E      # Fin de ligne
Ctrl+K      # Supprimer jusqu'à la fin
Ctrl+U      # Supprimer jusqu'au début
```

#### Recherche interactive (Ctrl+R)
```bash
# Appuyer sur Ctrl+R, puis taper des lettres
(reverse-i-search)`ssh`: ssh user@server.com
#                   │        │
#                   │        └─ Commande trouvée
#                   └─ Texte recherché

# Navigation dans les résultats
Ctrl+R      # Résultat précédent  
Ctrl+S      # Résultat suivant (si configuré)
Enter       # Exécuter la commande
Tab         # Éditer la commande
Escape      # Utiliser sans exécuter
```

### Exécution rapide depuis l'historique

#### Expansion d'historique avec !
```bash
# Par numéro
!501        # Exécuter la commande numéro 501
!-2         # Avant-dernière commande
!!          # Dernière commande (très utile)

# Par recherche de début
!ssh        # Dernière commande commençant par "ssh"
!git        # Dernière commande commençant par "git"

# Par recherche de contenu
!?config    # Dernière commande contenant "config"

# Substitution rapide
^ancien^nouveau     # Remplacer dans la dernière commande
sudo !!             # Relancer la dernière commande avec sudo
```

#### Exemples pratiques d'expansion
```bash
# Scénario : vous avez oublié sudo
chmod 644 /etc/hosts
# Permission denied

# Solution rapide :
sudo !!
# Équivalent à : sudo chmod 644 /etc/hosts

# Scénario : corriger une typo
cat /var/log/syslog | grep "eror"
# Aucun résultat (faute de frappe)

# Correction rapide :
^eror^error
# Équivalent à : cat /var/log/syslog | grep "error"
```

---

## 2. Configuration de l'historique

### Variables de configuration

#### Variables principales
```bash
# Voir la configuration actuelle
echo $HISTSIZE      # Taille en mémoire
echo $HISTFILESIZE  # Taille dans le fichier
echo $HISTFILE      # Fichier d'historique
echo $HISTCONTROL   # Contrôle du comportement

# Configuration typique
export HISTSIZE=5000        # 5000 commandes en mémoire
export HISTFILESIZE=10000   # 10000 commandes dans le fichier
export HISTFILE=~/.bash_history
```

#### Options de HISTCONTROL
```bash
# ignorespace : ignorer les commandes commençant par un espace
export HISTCONTROL=ignorespace

# ignoredups : ignorer les doublons consécutifs
export HISTCONTROL=ignoredups

# ignoreboth : combiner ignorespace et ignoredups  
export HISTCONTROL=ignoreboth

# erasedups : supprimer tous les anciens doublons
export HISTCONTROL=erasedups

# Exemples d'usage :
ls -la          # Enregistré
ls -la          # Ignoré si ignoredups actif
 ls -la         # Ignoré si ignorespace actif (espace au début)
```

### Options avancées shopt

#### Commandes shopt pour l'historique
```bash
# Voir les options actuelles
shopt | grep hist

# Options utiles à activer
shopt -s histappend     # Ajouter à l'historique au lieu d'écraser
shopt -s histverify     # Vérifier les expansions ! avant exécution
shopt -s histreedit     # Permettre réédition des expansions échouées

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
# Éditer le fichier de configuration
nano ~/.bashrc

# Ajouter à la fin :
# Configuration historique personnalisée
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
#                   │    │                    │
#                   │    │                    └─ Commandes avec espace initial
#                   │    └─ Commandes exactes
#                   └─ Toutes commandes commençant par "ls"
```

---

## 3. Variables d'environnement

### Concepts de base

#### Types de variables
```bash
# Variable locale (shell courant seulement)
ma_variable="valeur"
echo $ma_variable

# Variable d'environnement (héritée par processus enfants)
export MA_VAR_GLOBALE="valeur globale"
echo $MA_VAR_GLOBALE

# Vérifier la différence
bash                    # Nouveau shell
echo $ma_variable       # Vide (variable locale)
echo $MA_VAR_GLOBALE    # Valeur présente (exportée)
exit
```

#### Variables standard importantes
```bash
# Variables système essentielles
echo $HOME              # Répertoire personnel
echo $USER              # Nom d'utilisateur
echo $PATH              # Chemins de recherche des commandes
echo $PWD               # Répertoire courant
echo $SHELL             # Shell par défaut
echo $TERM              # Type de terminal
echo $LANG              # Langue du système
echo $PS1               # Prompt principal
echo $PS2               # Prompt secondaire (continuation)

# Variables de session
echo $SSH_CLIENT        # Information client SSH (si applicable)
echo $DISPLAY           # Affichage X11 (si applicable)
echo $TMPDIR            # Répertoire temporaire
```

### Gestion des variables

#### Affichage et manipulation
```bash
# Lister toutes les variables d'environnement
env
printenv

# Variable spécifique
printenv HOME
echo $HOME

# Définir une variable temporaire
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

# Chaque répertoire séparé par :
# Linux cherche les commandes dans l'ordre de gauche à droite
```

##### Modifier PATH
```bash
# Ajouter un répertoire au début (priorité haute)
export PATH="/mon/nouveau/path:$PATH"

# Ajouter à la fin (priorité basse)
export PATH="$PATH:/mon/autre/path"

# Exemples pratiques
export PATH="$HOME/bin:$PATH"              # Scripts personnels
export PATH="$PATH:/opt/monapp/bin"        # Application spécifique
export PATH="/usr/local/python3.9/bin:$PATH"  # Version Python spécifique

# Vérifier qu'une commande est trouvée
which python
whereis python
type python
```

---

## 4. Personnalisation du shell

### Fichiers de configuration

#### Hiérarchie des fichiers bash
```bash
# Fichiers système (pour tous les utilisateurs)
/etc/profile            # Exécuté pour shells login
/etc/bash.bashrc        # Exécuté pour tous les shells bash
/etc/environment        # Variables d'environnement globales

# Fichiers utilisateur (dans $HOME)
~/.profile              # Exécuté pour shells login (tout shell POSIX)
~/.bashrc               # Exécuté pour shells bash interactifs non-login
~/.bash_profile         # Exécuté pour shells bash login (priorité sur .profile)
~/.bash_logout          # Exécuté à la déconnexion

# Ordre d'exécution pour shell bash login :
# 1. /etc/profile
# 2. ~/.bash_profile OU ~/.bash_login OU ~/.profile (premier trouvé)
# 3. ~/.bashrc (si appelé depuis .bash_profile)
```

#### Configuration personnelle dans ~/.bashrc
```bash
# Exemple de ~/.bashrc personnalisé
# Éditer le fichier
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

# === FONCTIONS PERSONNALISÉES ===
# Créer répertoire et s'y déplacer
mkcd() { mkdir -p "$1" && cd "$1"; }

# Recherche rapide de fichiers
ff() { find . -type f -name "*$1*"; }

# === PROMPT PERSONNALISÉ ===
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Recharger avec : source ~/.bashrc
```

### Personnalisation du prompt (PS1)

#### Comprendre PS1
```bash
# Variables de prompt
echo $PS1      # Prompt principal
echo $PS2      # Prompt de continuation

# Codes d'échappement utiles
\u      # Nom d'utilisateur
\h      # Nom d'hôte (court)
\H      # Nom d'hôte (complet)
\w      # Répertoire courant (chemin complet)
\W      # Répertoire courant (nom seulement)
\d      # Date
\t      # Heure (format 24h)
\T      # Heure (format 12h)
\$      # $ pour utilisateur normal, # pour root
```

#### Exemples de prompts personnalisés
```bash
# Prompt simple avec couleurs
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# Résultat : user@hostname:~/directory$

# Prompt avec heure
export PS1='[\t] \u@\h:\w\$ '
# Résultat : [14:30:25] user@hostname:~/directory$

# Prompt avec git branch (nécessite fonction git)
git_branch() {
    git branch 2>/dev/null | grep '^*' | colrm 1 2
}
export PS1='\u@\h:\w$(git_branch)\$ '

# Prompt multi-lignes
export PS1='\n┌─[\[\033[01;32m\]\u@\h\[\033[00m\]] ─ [\[\033[01;34m\]\w\[\033[00m\]]\n└─\$ '
```

---

## 5. Alias - Raccourcis de commandes

### Créer et utiliser des alias

#### Syntaxe de base
```bash
# Créer un alias
alias nom='commande'

# Exemples simples
alias ll='ls -la'
alias la='ls -A'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Utiliser l'alias
ll          # Équivalent à : ls -la
..          # Équivalent à : cd ..
```

#### Alias avec arguments
```bash
# Alias ne peut pas prendre d'arguments directement
# Utiliser des fonctions pour cela

# ✗ Incorrect (ne marche pas)
alias search='find . -name'

# ✓ Correct avec fonction
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
alias -- -='cd -'           # Retour répertoire précédent

# Sécurité
alias rm='rm -i'            # Confirmation avant suppression
alias cp='cp -i'            # Confirmation avant écrasement
alias mv='mv -i'            # Confirmation avant écrasement
alias ln='ln -i'            # Confirmation avant écrasement
```

#### Commandes système
```bash
# Surveillance
alias h='history'
alias j='jobs -l'
alias ps='ps auxf'          # Format étendu avec arbre
alias psg='ps aux | grep'   # Recherche processus
alias df='df -h'            # Format lisible
alias du='du -ch'           # Format lisible avec total
alias free='free -h'        # Format lisible

# Réseau
alias ports='netstat -tulanp'
alias listening='ss -tuln'
alias ping='ping -c 5'      # Limiter à 5 pings

# Logs
alias syslog='sudo tail -f /var/log/syslog'
alias messages='sudo tail -f /var/log/messages'
alias auth='sudo tail -f /var/log/auth.log'
```

#### Alias avancés avec couleurs
```bash
# Grep avec couleurs
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto' 
alias egrep='egrep --color=auto'

# ls avec couleurs
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

# Différences avec couleurs
alias diff='diff --color=auto'
```

### Gestion des alias

#### Lister et supprimer
```bash
# Voir tous les alias
alias

# Voir un alias spécifique
alias ll

# Supprimer un alias
unalias ll
unalias -a      # Supprimer tous les alias
```

#### Alias temporaires vs permanents
```bash
# Alias temporaire (session courante)
alias temp='echo "Temporaire"'

# Alias permanent (ajouter à ~/.bashrc)
echo "alias perm='echo \"Permanent\"'" >> ~/.bashrc
source ~/.bashrc
```

---

## 6. Fonctions shell personnalisées

### Créer des fonctions utiles

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

##### Navigation améliorée
```bash
# Créer répertoire et s'y déplacer
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

# Usage : up 3  # Équivalent à cd ../../../
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
    echo "Emplacement : $(which "$1" 2>/dev/null || echo "Non trouvé dans PATH")"
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
            *)           echo "Format non supporté : '$1'" ;;
        esac
    else
        echo "Fichier non trouvé : '$1'"
    fi
}

# Création d'archive rapide
tardir() {
    tar czf "${1%/}.tar.gz" "$1"
}
```

##### Surveillance système
```bash
# Surveillance processus
psgrep() {
    ps aux | grep -v grep | grep "$1"
}

# Top 10 processus CPU
topcpu() {
    ps aux --sort=-%cpu | head -11
}

# Top 10 processus mémoire
topmem() {
    ps aux --sort=-%mem | head -11
}

# Surveiller un fichier log avec couleurs
logwatch() {
    tail -f "$1" | grep --color=auto -E "ERROR|WARN|FAIL|.*"
}
```

---

## 7. Configuration avancée et scripts

### Script de configuration automatique

```bash
#!/bin/bash
# setup_environment.sh - Configuration automatique environnement

BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d)"
BASHRC="$HOME/.bashrc"

# Créer sauvegarde
backup_config() {
    echo "Sauvegarde de la configuration actuelle..."
    mkdir -p "$BACKUP_DIR"
    cp "$BASHRC" "$BACKUP_DIR/bashrc_backup" 2>/dev/null || true
    echo "Sauvegarde dans : $BACKUP_DIR"
}

# Configuration historique optimisée
setup_history() {
    echo "Configuration de l'historique..."
    cat >> "$BASHRC" << 'EOF'

# === CONFIGURATION HISTORIQUE OPTIMISÉE ===
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

# Sécurité  
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

# Fonctions personnalisées
setup_functions() {
    echo "Configuration des fonctions..."
    cat >> "$BASHRC" << 'EOF'

# === FONCTIONS PERSONNALISÉES ===
# Créer répertoire et s'y déplacer
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
            *)           echo "Format non supporté : '$1'" ;;
        esac
    else
        echo "Fichier non trouvé : '$1'"
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

# Prompt personnalisé
setup_prompt() {
    echo "Configuration du prompt..."
    cat >> "$BASHRC" << 'EOF'

# === PROMPT PERSONNALISÉ ===
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
    echo "Configuration terminée !"
    echo "Redémarrez votre terminal ou exécutez : source ~/.bashrc"
    echo "Sauvegarde de l'ancienne config : $BACKUP_DIR"
}

# Exécution
main
```

---

## Résumé

### Commandes historique essentielles
```bash
history              # Voir tout l'historique
history 20           # 20 dernières commandes
!!                   # Dernière commande
!ssh                 # Dernière commande commençant par "ssh"
!?config             # Dernière commande contenant "config"
^old^new             # Substituer dans la dernière commande
Ctrl+R               # Recherche interactive
```

### Variables importantes
```bash
# Historique
HISTSIZE=10000       # Taille en mémoire
HISTFILESIZE=20000   # Taille dans fichier
HISTCONTROL=ignoreboth   # Comportement
HISTIGNORE="ls:pwd"  # Commandes à ignorer

# Environnement  
PATH                 # Chemins de recherche commandes
HOME                 # Répertoire personnel
USER                 # Utilisateur courant
EDITOR               # Éditeur par défaut
PS1                  # Prompt principal
```

### Fichiers de configuration
```bash
~/.bashrc            # Configuration bash interactive
~/.bash_profile      # Configuration bash login
~/.profile           # Configuration shell générale
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

### Fonctions recommandées
```bash
mkcd() { mkdir -p "$1" && cd "$1"; }     # Créer et aller
ff() { find . -name "*$1*"; }           # Recherche fichier
extract() { ... }                       # Extraction archives
psgrep() { ps aux | grep "$1"; }        # Recherche processus
```

### Bonnes pratiques
- **Sauvegarde** : toujours sauvegarder avant modification
- **Test** : tester les modifications avec `source ~/.bashrc`
- **Documentation** : commenter les personnalisations
- **Modularité** : séparer les configurations par thème
- **Portabilité** : éviter les dépendances système spécifiques

---

**Temps de lecture estimé** : 35-40 minutes
**Niveau** : Intermédiaire à avancé  
**Pré-requis** : Utilisation de base du shell, navigation fichiers