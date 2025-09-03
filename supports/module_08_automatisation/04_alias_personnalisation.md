# Chapitre 8.4 : Alias et personnalisation

## Objectifs
- Comprendre le concept d'alias et leur utilité
- Apprendre à créer et gérer des alias
- Découvrir la personnalisation du shell bash
- Maîtriser la configuration des fichiers de profil
- Personnaliser l'invite de commande (prompt)

## 1. Introduction aux alias

Un **alias** est un raccourci qui permet de donner un nom court et mémorable à une commande longue ou complexe. Les alias améliorent l'efficacité et réduisent les erreurs de frappe.

### Avantages des alias

- **Gain de temps** : raccourcir les commandes fréquentes
- **Réduction d'erreurs** : éviter les fautes de frappe
- **Standardisation** : unifier les options utilisées
- **Lisibilité** : noms plus explicites

## 2. Gestion des alias

### Créer un alias temporaire

```bash
# Syntaxe de base
alias nom='commande'

# Exemples simples
alias ll='ls -l'
alias la='ls -la'
alias l='ls -CF'

# Alias plus complexes
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
```

### Lister les alias

```bash
# Afficher tous les alias définis
alias

# Afficher un alias spécifique
alias ll

# Rechercher des alias contenant un motif
alias | grep ls
```

### Supprimer un alias

```bash
# Supprimer un alias temporaire
unalias ll

# Supprimer tous les alias
unalias -a
```

## 3. Alias permanents

### Fichiers de configuration

Les alias permanents se définissent dans les fichiers de configuration du shell :

```bash
# Fichier personnel de l'utilisateur
~/.bashrc          # Chargé à chaque nouveau shell interactif
~/.bash_aliases    # Fichier dédié aux alias (si inclus dans .bashrc)
~/.profile         # Chargé au login

# Fichiers système (pour tous les utilisateurs)
/etc/bash.bashrc   # Configuration globale bash
/etc/profile       # Profil système global
```

### Édition du fichier ~/.bashrc

```bash
# Éditer le fichier de configuration
nano ~/.bashrc

# Ajouter des alias à la fin du fichier
# Mes alias personnalisés
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
```

### Recharger la configuration

```bash
# Méthode 1 : recharger .bashrc
source ~/.bashrc

# Méthode 2 : raccourci
. ~/.bashrc

# Méthode 3 : ouvrir un nouveau terminal
```

## 4. Exemples d'alias utiles

### Navigation

```bash
# Remontée dans l'arborescence
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Répertoires fréquents
alias home='cd ~'
alias docs='cd ~/Documents'
alias downloads='cd ~/Downloads'

# Retour au répertoire précédent
alias back='cd -'
```

### Listing amélioré

```bash
# Variants de ls
alias ll='ls -alF'              # Liste détaillée avec indicateurs
alias la='ls -A'                # Tout sauf . et ..
alias l='ls -CF'                # Compact avec indicateurs
alias lt='ls -ltr'              # Tri par date (récent en bas)
alias lh='ls -lh'               # Tailles lisibles
alias tree='tree -C'           # tree en couleur
```

### Commandes système

```bash
# Sécurité
alias rm='rm -i'                # Confirmation avant suppression
alias cp='cp -i'                # Confirmation avant écrasement
alias mv='mv -i'                # Confirmation avant écrasement

# Processus
alias ps='ps aux'               # Liste complète des processus
alias psg='ps aux | grep'       # Recherche de processus
alias top='htop'               # Interface améliorée (si installé)

# Espace disque
alias df='df -h'               # Tailles lisibles
alias du='du -h'               # Tailles lisibles
alias free='free -h'           # RAM en format lisible
```

### Réseau

```bash
# Réseau
alias ping='ping -c 5'         # Limite à 5 pings
alias wget='wget -c'           # Reprise de téléchargement
alias ports='netstat -tulanp'  # Ports ouverts
```

### Git (si utilisé)

```bash
# Raccourcis Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
```

### Alias avec paramètres

```bash
# Fonction plutôt qu'alias pour les paramètres
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Recherche rapide
function ff() {
    find . -name "*$1*" -type f
}

# Extraction universelle
function extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)  tar xjf "$1"    ;;
            *.tar.gz)   tar xzf "$1"    ;;
            *.bz2)      bunzip2 "$1"    ;;
            *.rar)      unrar x "$1"    ;;
            *.gz)       gunzip "$1"     ;;
            *.tar)      tar xf "$1"     ;;
            *.tbz2)     tar xjf "$1"    ;;
            *.tgz)      tar xzf "$1"    ;;
            *.zip)      unzip "$1"      ;;
            *.Z)        uncompress "$1" ;;
            *.7z)       7z x "$1"       ;;
            *)          echo "Format non supporté : '$1'" ;;
        esac
    else
        echo "Fichier '$1' non trouvé"
    fi
}
```

## 5. Personnalisation de l'invite de commande

### Variable PS1

L'invite de commande est définie par la variable `PS1` :

```bash
# Voir l'invite actuelle
echo $PS1

# Invite simple
PS1="$ "

# Invite avec nom d'utilisateur et répertoire
PS1="\u@\h:\w$ "
```

### Codes de formatage

| Code | Signification |
|------|---------------|
| `\u` | Nom d'utilisateur |
| `\h` | Nom de machine (hostname) |
| `\H` | Nom complet de machine |
| `\w` | Répertoire courant complet |
| `\W` | Nom du répertoire courant |
| `\d` | Date |
| `\t` | Heure (HH:MM:SS) |
| `\T` | Heure (HH:MM:SS format 12h) |
| `\$` | $ pour utilisateur normal, # pour root |

### Couleurs

```bash
# Codes couleur ANSI
# \[\033[XXm\] où XX est le code couleur
# \[\033[0m\] pour reset

# Exemple coloré
PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
```

Codes couleur courants :
- 30-37 : couleurs de texte (noir, rouge, vert, jaune, bleu, magenta, cyan, blanc)
- 40-47 : couleurs de fond
- 01 : gras, 04 : souligné

### Exemples d'invites personnalisées

```bash
# Invite colorée avec Git (nécessite git)
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)")\$ '

# Invite avec heure
PS1='[\t] \u@\h:\w\$ '

# Invite minimaliste
PS1='\W \$ '

# Invite avec code de retour de la dernière commande
PS1='\u@\h:\w [$(echo $?)] \$ '
```

## 6. Fichier ~/.bash_aliases dédié

### Création du fichier séparé

```bash
# Créer un fichier dédié aux alias
touch ~/.bash_aliases

# Éditer le fichier
nano ~/.bash_aliases
```

### Contenu exemple de ~/.bash_aliases

```bash
#!/bin/bash
# ~/.bash_aliases - Alias personnalisés

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'

# Listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -ltr'

# Sécurité
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Système
alias df='df -h'
alias free='free -h'
alias ps='ps auxf'

# Réseau
alias ping='ping -c 5'

# Applications
alias nano='nano -w'
alias grep='grep --color=auto'

# Fonctions utiles
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Recherche rapide dans l'historique
hgrep() {
    history | grep "$1"
}
```

### Activation du fichier

Dans `~/.bashrc`, s'assurer que cette section existe :

```bash
# Alias definitions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
```

## 7. Autres personnalisations

### Variables d'environnement

```bash
# Dans ~/.bashrc
export EDITOR=nano                    # Éditeur par défaut
export BROWSER=firefox               # Navigateur par défaut
export PATH="$PATH:$HOME/bin"        # Ajouter ~/bin au PATH
export HISTSIZE=1000                 # Taille historique
export HISTFILESIZE=2000             # Taille fichier historique
```

### Options du shell

```bash
# Dans ~/.bashrc
set -o vi                            # Mode vi pour l'édition
shopt -s autocd                      # cd automatique
shopt -s checkwinsize                # Ajuste taille fenêtre
shopt -s histappend                  # Ajoute à l'historique
```

### Complétion automatique

```bash
# Activer la complétion avancée (si disponible)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
```

## 8. Sauvegarde et partage de configuration

### Sauvegarde

```bash
# Sauvegarder sa configuration
cp ~/.bashrc ~/.bashrc.backup
cp ~/.bash_aliases ~/.bash_aliases.backup

# Archive complète
tar czf ~/config-backup.tar.gz ~/.bashrc ~/.bash_aliases ~/.profile
```

### Partage entre machines

```bash
# Copier sur une autre machine
scp ~/.bashrc ~/.bash_aliases user@machine:~/

# Ou via un dépôt Git (dotfiles)
git init ~/dotfiles
cp ~/.bashrc ~/.bash_aliases ~/dotfiles/
cd ~/dotfiles && git add . && git commit -m "Configuration initiale"
```

## Points clés à retenir

- **alias** crée des raccourcis de commandes
- Alias **temporaires** : `alias nom='commande'`
- Alias **permanents** : dans `~/.bashrc` ou `~/.bash_aliases`
- **Recharger** avec `source ~/.bashrc`
- Personnaliser l'**invite** avec `PS1`
- Organiser dans un **fichier dédié** pour la lisibilité
- **Sauvegarder** sa configuration

## Exercice pratique

1. Créer 5 alias utiles pour votre usage
2. Personnaliser votre invite de commande
3. Créer une fonction `mkcd` qui crée un répertoire et s'y déplace
4. Organiser vos alias dans `~/.bash_aliases`
5. Tester et ajuster votre configuration