# TP 2 : Configuration de l'environnement

## Objectifs

À la fin de ce TP, vous saurez :
- Personnaliser votre environnement de travail
- Configurer des alias utiles
- Comprendre les fichiers de configuration du shell
- Optimiser votre utilisation du terminal

## Durée estimée
45 minutes

---

## Partie A : Exploration des fichiers de configuration

### Exercice 1 : Découvrir les fichiers cachés

1. **Afficher tous les fichiers de votre home**
   ```bash
   cd ~
   ls -la
   ```

2. **Identifier les fichiers de configuration** (commencent par un point)
   
   Recherchez et listez les fichiers suivants :
   - [ ] `.bashrc` (configuration du shell bash)
   - [ ] `.bash_history` (historique des commandes)
   - [ ] `.profile` (configuration générale du profil)

3. **Examiner le contenu de .bashrc**
   ```bash
   cat .bashrc
   ```

   **Question** : Que contient ce fichier ? Y a-t-il déjà des alias définis ?

### Exercice 2 : Comprendre la hiérarchie des fichiers de config

1. **Vérifier quel shell vous utilisez**
   ```bash
   echo $SHELL
   ps -p $$
   ```

2. **Comprendre l'ordre de chargement** :
   - `/etc/profile` (global)
   - `~/.profile` (utilisateur)
   - `~/.bashrc` (spécifique à bash)

---

## Partie B : Personnalisation avec des alias

### Exercice 3 : Créer vos premiers alias

1. **Ajouter des alias utiles à .bashrc**
   ```bash
   # Éditer le fichier .bashrc
   nano .bashrc
   
   # Ajouter à la fin du fichier les alias suivants :
   alias ll='ls -la'
   alias la='ls -A'  
   alias l='ls -CF'
   alias ..='cd ..'
   alias ...='cd ../..'
   alias grep='grep --color=auto'
   alias h='history'
   alias c='clear'
   ```

2. **Recharger la configuration**
   ```bash
   # Méthode 1 : recharger .bashrc
   source .bashrc
   
   # Méthode 2 : utiliser le raccourci
   . .bashrc
   ```

3. **Tester les alias**
   ```bash
   # Tester chaque alias
   ll
   la
   ..
   pwd
   ...
   pwd
   h
   c
   ```

### Exercice 4 : Alias personnalisés avancés

1. **Créer des alias utiles pour la formation**
   ```bash
   # Ajouter à .bashrc
   nano .bashrc
   
   # Ajouter ces alias :
   alias formation='cd ~/formation_linux'
   alias logs='cd /var/log'  
   alias ports='netstat -tuln'
   alias meminfo='free -h'
   alias diskinfo='df -h'
   ```

2. **Créer un répertoire pour la formation**
   ```bash
   mkdir ~/formation_linux
   ```

3. **Recharger et tester**
   ```bash
   source .bashrc
   formation
   pwd
   cd ~
   meminfo
   diskinfo
   ```

---

## Partie C : Configuration de l'historique

### Exercice 5 : Optimiser l'historique des commandes

1. **Configurer l'historique dans .bashrc**
   ```bash
   nano .bashrc
   
   # Ajouter ces lignes :
   export HISTSIZE=10000           # Nombre de commandes en mémoire
   export HISTFILESIZE=20000       # Nombre de commandes dans le fichier
   export HISTCONTROL=ignoredups   # Ignorer les doublons
   export HISTTIMEFORMAT="%d/%m/%Y %H:%M:%S "  # Ajouter timestamp
   ```

2. **Recharger la configuration**
   ```bash
   source .bashrc
   ```

3. **Tester l'historique amélioré**
   ```bash
   # Exécuter quelques commandes
   ls
   pwd
   date
   ls
   
   # Vérifier l'historique
   history | tail -10
   ```

### Exercice 6 : Recherche dans l'historique

1. **Utiliser la recherche interactive**
   - Appuyez sur **Ctrl+R**
   - Tapez `ls` puis naviguez avec Ctrl+R
   - Appuyez sur Entrée pour exécuter

2. **Utiliser les raccourcis d'historique**
   ```bash
   # Dernière commande
   !!
   
   # Avant-dernière commande  
   !-2
   
   # Dernière commande commençant par 'ls'
   !ls
   ```

---

## Partie D : Personnalisation du prompt

### Exercice 7 : Modifier l'apparence du prompt

1. **Comprendre la variable PS1**
   ```bash
   # Voir le prompt actuel
   echo $PS1
   ```

2. **Créer un prompt personnalisé**
   ```bash
   # Ajouter à .bashrc
   nano .bashrc
   
   # Ajouter cette ligne (choisir une couleur) :
   export PS1='\[\e[32m\]\u@\h:\w\$ \[\e[0m\]'  # Vert
   # OU
   export PS1='\[\e[34m\]\u@\h:\w\$ \[\e[0m\]'  # Bleu  
   # OU
   export PS1='\[\e[36m\]\u@\h:\w\$ \[\e[0m\]'  # Cyan
   ```

3. **Comprendre les codes du prompt** :
   - `\u` : nom d'utilisateur
   - `\h` : nom d'hôte
   - `\w` : répertoire courant complet
   - `\W` : répertoire courant (nom seulement)
   - `\$` : $ pour utilisateur normal, # pour root

4. **Tester le nouveau prompt**
   ```bash
   source .bashrc
   # Observer le changement de couleur
   cd /tmp
   cd ~
   ```

---

## Partie E : Variables d'environnement

### Exercice 8 : Explorer les variables importantes

1. **Afficher les variables d'environnement**
   ```bash
   # Toutes les variables
   env
   
   # Variables spécifiques importantes
   echo $HOME
   echo $USER  
   echo $PATH
   echo $SHELL
   echo $LANG
   ```

2. **Comprendre PATH**
   ```bash
   # Afficher PATH de manière lisible
   echo $PATH | tr ':' '\n'
   
   # Trouver où est une commande
   which ls
   which bash
   ```

### Exercice 9 : Ajouter des variables personnalisées

1. **Créer des variables pour la formation**
   ```bash
   # Ajouter à .bashrc
   nano .bashrc
   
   # Ajouter ces variables :
   export FORMATION_DIR="$HOME/formation_linux"
   export EDITOR="nano"
   export PAGER="less"
   ```

2. **Utiliser les variables**
   ```bash
   source .bashrc
   echo $FORMATION_DIR
   cd $FORMATION_DIR
   ```

---

## Partie F : Configuration avancée

### Exercice 10 : Fonctions bash utiles

1. **Créer des fonctions personnalisées**
   ```bash
   # Ajouter à .bashrc
   nano .bashrc
   
   # Ajouter ces fonctions :
   
   # Fonction pour créer et aller dans un répertoire
   mkcd() {
       mkdir -p "$1" && cd "$1"
   }
   
   # Fonction pour chercher un fichier
   find_file() {
       find . -name "*$1*" -type f
   }
   
   # Fonction pour voir les processus d'un utilisateur
   myps() {
       ps aux | grep $USER
   }
   ```

2. **Tester les fonctions**
   ```bash
   source .bashrc
   
   # Tester mkcd
   mkcd test_fonction
   pwd
   cd ..
   
   # Tester find_file
   find_file bashrc
   
   # Tester myps
   myps
   ```

---

## Partie G : Sauvegarde et validation

### Exercice 11 : Sauvegarder sa configuration

1. **Créer une copie de sauvegarde**
   ```bash
   cp .bashrc .bashrc.backup
   ```

2. **Vérifier que tout fonctionne**
   ```bash
   # Simuler une nouvelle connexion
   bash
   
   # Tester tous les alias et fonctions
   ll
   formation
   mkcd test_final
   ```

### Exercice 12 : Documentation personnelle

1. **Créer un fichier de notes**
   ```bash
   cd $FORMATION_DIR
   nano mes_alias.txt
   ```

2. **Documenter vos personnalisations**
   ```
   Mes alias personnalisés :
   - ll : liste détaillée
   - formation : aller au répertoire de formation  
   - mkcd : créer et aller dans un répertoire
   - ...
   
   Variables importantes :
   - $FORMATION_DIR : répertoire de travail
   - $EDITOR : éditeur par défaut
   - ...
   ```

---

## Validation des acquis

### Vérification fonctionnelle

Testez que vous avez bien configuré :
- [ ] Alias `ll`, `la`, `..`, `...`
- [ ] Alias `formation` fonctionnel  
- [ ] Historique avec timestamps
- [ ] Prompt coloré
- [ ] Fonction `mkcd` opérationnelle
- [ ] Variable `FORMATION_DIR` définie

### Questions de compréhension

1. **Où sont stockés les alias personnalisés ?**
2. **Comment recharger la configuration sans se déconnecter ?**
3. **Quelle est la différence entre une variable et un alias ?**
4. **Comment voir toutes les variables d'environnement ?**

---

## Solutions

### Solutions questions
1. Dans le fichier `~/.bashrc`
2. `source ~/.bashrc` ou `. ~/.bashrc`
3. Alias = raccourci de commande, Variable = stockage de valeur
4. `env` ou `printenv`

### Vérification finale
```bash
# Cette commande doit fonctionner pour valider le TP
formation && ll && echo "Configuration réussie !"
```

---

## Pour aller plus loin

### Personnalisations avancées optionnelles

```bash
# Completion automatique améliorée
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Alias Git (si Git installé)
alias gs='git status'
alias ga='git add'
alias gc='git commit'

# Fonction de recherche dans l'historique
h() {
    history | grep "$1"
}
```

### Configuration système (nécessite sudo)

```bash
# Personnaliser le message du jour (MOTD)
sudo nano /etc/motd

# Configuration globale pour tous les utilisateurs  
sudo nano /etc/bash.bashrc
```