# Alias et personnalisation

## Objectifs
- Comprendre le concept d'alias et leur utilite
- Apprendre a creer et gerer des alias
- Decouvrir la personnalisation du shell bash
- Maitriser la configuration des fichiers de profil
- Personnaliser l'invite de commande (prompt)

## 1. Introduction aux alias

Un **alias** est un raccourci qui permet de donner un nom court et memorable a une commande longue ou complexe. Les alias ameliorent l'efficacite et reduisent les erreurs de frappe.

### Avantages des alias

- **Gain de temps** : raccourcir les commandes frequentes
- **Reduction d'erreurs** : eviter les fautes de frappe
- **Standardisation** : unifier les options utilisees
- **Lisibilite** : noms plus explicites

## 2. Gestion des alias

### Creer un alias temporaire

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
# Afficher tous les alias definis
alias

# Afficher un alias specifique
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

Les alias permanents se definissent dans les fichiers de configuration du shell :

```bash
# Fichier personnel de l'utilisateur
~/.bashrc          # Charge a chaque nouveau shell interactif
~/.bash_aliases    # Fichier dedie aux alias (si inclus dans .bashrc)
~/.profile         # Charge au login

# Fichiers systeme (pour tous les utilisateurs)
/etc/bash.bashrc   # Configuration globale bash
/etc/profile       # Profil systeme global
```

### Edition du fichier ~/.bashrc

```bash
# Editer le fichier de configuration
nano ~/.bashrc

# Ajouter des alias a la fin du fichier
# Mes alias personnalises
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
```

### Recharger la configuration

```bash
# Methode 1 : recharger .bashrc
source ~/.bashrc

# Methode 2 : raccourci
. ~/.bashrc

# Methode 3 : ouvrir un nouveau terminal
```

## 4. Exemples d'alias utiles

### Navigation

```bash
# Remontee dans l'arborescence
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Repertoires frequents
alias home='cd ~'
alias docs='cd ~/Documents'
alias downloads='cd ~/Downloads'

# Retour au repertoire precedent
alias back='cd -'
```

### Listing ameliore

```bash
# Variants de ls
alias ll='ls -alF'              # Liste detaillee avec indicateurs
alias la='ls -A'                # Tout sauf . et ..
alias l='ls -CF'                # Compact avec indicateurs
alias lt='ls -ltr'              # Tri par date (recent en bas)
alias lh='ls -lh'               # Tailles lisibles
alias tree='tree -C'           # tree en couleur
```

### Commandes systeme

```bash
# Securite
alias rm='rm -i'                # Confirmation avant suppression
alias cp='cp -i'                # Confirmation avant ecrasement
alias mv='mv -i'                # Confirmation avant ecrasement

# Processus
alias ps='ps aux'               # Liste complete des processus
alias psg='ps aux | grep'       # Recherche de processus
alias top='htop'               # Interface amelioree (si installe)

# Espace disque
alias df='df -h'               # Tailles lisibles
alias du='du -h'               # Tailles lisibles
alias free='free -h'           # RAM en format lisible
```

### Reseau

```bash
# Reseau
alias ping='ping -c 5'         # Limite a 5 pings
alias wget='wget -c'           # Reprise de telechargement
alias ports='netstat -tulanp'  # Ports ouverts
```

### Git (si utilise)

```bash
# Raccourcis Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
```

### Alias avec parametres

```bash
# Fonction plutot qu'alias pour les parametres
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
            *)          echo "Format non supporte : '$1'" ;;
        esac
    else
        echo "Fichier '$1' non trouve"
    fi
}
```

## 5. Personnalisation de l'invite de commande

### Variable PS1

L'invite de commande est definie par la variable `PS1` :

```bash
# Voir l'invite actuelle
echo $PS1

# Invite simple
PS1="$ "

# Invite avec nom d'utilisateur et repertoire
PS1="\u@\h:\w$ "
```

### Codes de formatage

| Code | Signification |
|------|---------------|
| `\u` | Nom d'utilisateur |
| `\h` | Nom de machine (hostname) |
| `\H` | Nom complet de machine |
| `\w` | Repertoire courant complet |
| `\W` | Nom du repertoire courant |
| `\d` | Date |
| `\t` | Heure (HH:MM:SS) |
| `\T` | Heure (HH:MM:SS format 12h) |
| `\$` | $ pour utilisateur normal, # pour root |

### Couleurs

```bash
# Codes couleur ANSI
# \[\033[XXm\] ou XX est le code couleur
# \[\033[0m\] pour reset

# Exemple colore
PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
```

Codes couleur courants :
- 30-37 : couleurs de texte (noir, rouge, vert, jaune, bleu, magenta, cyan, blanc)
- 40-47 : couleurs de fond
- 01 : gras, 04 : souligne

### Exemples d'invites personnalisees

```bash
# Invite coloree avec Git (necessite git)
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)")\$ '

# Invite avec heure
PS1='[\t] \u@\h:\w\$ '

# Invite minimaliste
PS1='\W \$ '

# Invite avec code de retour de la derniere commande
PS1='\u@\h:\w [$(echo $?)] \$ '
```

## 6. Fichier ~/.bash_aliases dedie

### Creation du fichier separe

```bash
# Creer un fichier dedie aux alias
touch ~/.bash_aliases

# Editer le fichier
nano ~/.bash_aliases
```

### Contenu exemple de ~/.bash_aliases

```bash
#!/bin/bash
# ~/.bash_aliases - Alias personnalises

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'

# Listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -ltr'

# Securite
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Systeme
alias df='df -h'
alias free='free -h'
alias ps='ps auxf'

# Reseau
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
export EDITOR=nano                    # Editeur par defaut
export BROWSER=firefox               # Navigateur par defaut
export PATH="$PATH:$HOME/bin"        # Ajouter ~/bin au PATH
export HISTSIZE=1000                 # Taille historique
export HISTFILESIZE=2000             # Taille fichier historique
```

### Options du shell

```bash
# Dans ~/.bashrc
set -o vi                            # Mode vi pour l'edition
shopt -s autocd                      # cd automatique
shopt -s checkwinsize                # Ajuste taille fenetre
shopt -s histappend                  # Ajoute a l'historique
```

### Completion automatique

```bash
# Activer la completion avancee (si disponible)
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

# Archive complete
tar czf ~/config-backup.tar.gz ~/.bashrc ~/.bash_aliases ~/.profile
```

### Partage entre machines

```bash
# Copier sur une autre machine
scp ~/.bashrc ~/.bash_aliases user@machine:~/

# Ou via un depot Git (dotfiles)
git init ~/dotfiles
cp ~/.bashrc ~/.bash_aliases ~/dotfiles/
cd ~/dotfiles && git add . && git commit -m "Configuration initiale"
```

## Points cles a retenir

- **alias** cree des raccourcis de commandes
- Alias **temporaires** : `alias nom='commande'`
- Alias **permanents** : dans `~/.bashrc` ou `~/.bash_aliases`
- **Recharger** avec `source ~/.bashrc`
- Personnaliser l'**invite** avec `PS1`
- Organiser dans un **fichier dedie** pour la lisibilite
- **Sauvegarder** sa configuration

## Exercice pratique

1. Creer 5 alias utiles pour votre usage
2. Personnaliser votre invite de commande
3. Creer une fonction `mkcd` qui cree un repertoire et s'y deplace
4. Organiser vos alias dans `~/.bash_aliases`
5. Tester et ajuster votre configuration