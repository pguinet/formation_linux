# Premier contact avec le terminal

## Qu'est-ce que le terminal ?

Le **terminal** (ou console) est une interface en ligne de commande qui permet d'interagir avec le système d'exploitation en tapant des commandes textuelles.

### Vocabulaire important

- **Terminal** : Fenêtre qui affiche le shell
- **Shell** : Interpréteur de commandes (bash, zsh, etc.)
- **Ligne de commande** : Interface textuelle pour saisir des commandes
- **Invite de commande (prompt)** : Texte qui indique que le système attend une commande

### Pourquoi utiliser le terminal ?

**Avantages :**
- **Précision** : Actions exactes sans ambiguïté
- **Rapidité** : Plus rapide que l'interface graphique pour certaines tâches
- **Puissance** : Combinaison et automatisation de commandes
- **Universalité** : Même interface sur tous les systèmes Unix/Linux
- **Administration** : Seule interface disponible sur les serveurs

## Anatomie de l'invite de commande

```bash
utilisateur@nom-machine:~$
```

### Décomposition du prompt

- **utilisateur** : Votre nom d'utilisateur
- **@** : Séparateur
- **nom-machine** : Nom de l'ordinateur/serveur
- **:** : Séparateur
- **~** : Répertoire courant (~ = répertoire personnel)
- **$** : Vous êtes un utilisateur normal (# pour root)

### Exemples de prompts

```bash
# Utilisateur normal dans son home
john@debian:~$ 

# Utilisateur root
root@debian:/# 

# Utilisateur dans un autre répertoire
john@debian:/var/log$ 

# Invite SSH
john@serveur-distant:~$ 
```

## Premières commandes essentielles

### 1. Obtenir de l'aide

```bash
# Aide générale sur une commande
man ls          # Manuel complet de la commande ls
info ls         # Information GNU (alternative à man)
ls --help       # Aide rapide de la commande

# Navigation dans les manuels
# Espace : page suivante
# q : quitter
# /mot : rechercher "mot"
# n : occurrence suivante
```

### 2. Savoir où on est

```bash
# Afficher le répertoire courant
pwd             # Print Working Directory
# Sortie : /home/utilisateur

# Afficher son nom d'utilisateur
whoami
# Sortie : utilisateur

# Afficher des informations système
hostname        # Nom de la machine
date           # Date et heure actuelles
uptime         # Durée de fonctionnement du système
```

### 3. Explorer les fichiers

```bash
# Lister les fichiers du répertoire courant
ls              # Liste simple
ls -l           # Liste détaillée
ls -la          # Liste détaillée avec fichiers cachés
ls -lh          # Tailles lisibles par l'humain

# Exemples de sortie ls -la
total 28
drwxr-xr-x 3 john john 4096 Jan 15 10:30 .
drwxr-xr-x 3 root root 4096 Jan 10 09:00 ..
-rw-r--r-- 1 john john  220 Jan 10 09:00 .bash_logout
-rw-r--r-- 1 john john 3526 Jan 10 09:00 .bashrc
drwxr-xr-x 2 john john 4096 Jan 15 10:15 Documents
```

### 4. Se déplacer

```bash
# Changer de répertoire
cd Documents    # Aller dans le dossier Documents
cd ..          # Remonter d'un niveau
cd             # Retourner au répertoire personnel
cd ~           # Même chose (~ = home)
cd /           # Aller à la racine du système
cd -           # Retourner au répertoire précédent
```

## Structure de base d'une commande

```bash
commande [options] [arguments]
```

### Exemples

```bash
# Commande simple
ls

# Commande avec options
ls -l

# Commande avec options et arguments
ls -l /home

# Commande avec plusieurs options
ls -la /home

# Options courtes vs longues
ls -l          # Option courte
ls --long      # Option longue équivalente
```

### Types d'options

```bash
# Options courtes (un tiret, une lettre)
ls -l
ls -a
ls -h

# Combinaison d'options courtes
ls -la         # Équivaut à ls -l -a

# Options longues (deux tirets, mot complet)
ls --long
ls --all
ls --human-readable

# Options avec paramètres
head -n 5 fichier.txt        # Afficher 5 lignes
head --lines=5 fichier.txt   # Version longue
```

## Caractères spéciaux du shell

### Wildcards (jokers)

```bash
# * : n'importe quelle séquence de caractères
ls *.txt       # Tous les fichiers .txt
ls D*          # Tous les fichiers commençant par D

# ? : un seul caractère
ls fichier?.txt # fichier1.txt, fichierA.txt, etc.

# [] : un caractère parmi ceux listés
ls fichier[123].txt  # fichier1.txt, fichier2.txt, fichier3.txt
ls [a-z]*.txt        # Fichiers .txt commençant par une minuscule
```

### Redirection et pipes (aperçu)

```bash
# Redirection de sortie
ls > liste_fichiers.txt      # Écrire dans un fichier
ls >> liste_fichiers.txt     # Ajouter à un fichier

# Pipe : chaîner des commandes
ls -l | head -5              # 5 premières lignes de ls -l
```

## Historique des commandes

### Navigation dans l'historique

- **↑** (flèche haut) : Commande précédente
- **↓** (flèche bas) : Commande suivante
- **Ctrl+R** : Recherche dans l'historique
- **!!** : Répéter la dernière commande
- **!n** : Répéter la commande n° n

### Commandes d'historique

```bash
# Afficher l'historique
history

# Afficher les 10 dernières commandes
history | tail -10

# Effacer l'historique
history -c
```

## Complétion automatique

### Utilisation de Tab

```bash
# Complétion de commandes
ls Doc[Tab]     # Complète en Documents/

# Complétion de noms de fichiers
cat /etc/host[Tab]  # Complète en /etc/hosts

# Double Tab pour voir les options
ls --[Tab][Tab]     # Affiche toutes les options longues de ls
```

## Erreurs courantes et messages

### Messages d'erreur typiques

```bash
# Commande non trouvée
$ lss
bash: lss: command not found

# Permission refusée
$ cat /etc/shadow
cat: /etc/shadow: Permission denied

# Fichier ou répertoire inexistant
$ cd /inexistant
bash: cd: /inexistant: No such file or directory
```

### Codes de retour

```bash
# Vérifier le succès de la dernière commande
echo $?
# 0 = succès
# Autre valeur = erreur
```

## Bonnes pratiques débutant

### 1. Lisez les messages d'erreur
Ne pas ignorer les messages - ils donnent souvent la solution.

### 2. Utilisez l'aide
```bash
man commande    # Toujours commencer par lire le manuel
```

### 3. Soyez prudent avec les commandes destructives
```bash
# Toujours réfléchir avant :
rm -rf /        # DANGEREUX ! Ne jamais faire ça
sudo commande   # Réfléchir avant d'utiliser sudo
```

### 4. Utilisez la complétion Tab
Elle évite les erreurs de frappe et fait gagner du temps.

### 5. Organisez votre travail
```bash
# Créer des répertoires pour organiser
mkdir projets
cd projets
mkdir formation_linux
```

## Exercices pratiques

### Exercice 1 : Exploration de base
```bash
# 1. Afficher votre répertoire courant
pwd

# 2. Lister les fichiers avec détails
ls -la

# 3. Aller dans /tmp et revenir
cd /tmp
pwd
cd ~
pwd
```

### Exercice 2 : Utilisation de l'aide
```bash
# 1. Lire le manuel de la commande date
man date

# 2. Afficher la date au format personnalisé
date +"%d/%m/%Y %H:%M"
```

### Exercice 3 : Historique et complétion
```bash
# 1. Exécuter quelques commandes
ls
pwd
date
whoami

# 2. Utiliser l'historique pour répéter pwd
# Flèche haut jusqu'à pwd, puis Entrée

# 3. Utiliser Tab pour compléter
cd Doc[Tab]  # Si le répertoire Documents existe
```

## Points clés à retenir

- Le **terminal** est l'interface principale pour administrer Linux
- La **structure** : `commande [options] [arguments]`
- **pwd** pour savoir où on est, **ls** pour voir le contenu
- **Tab** pour la complétion, **↑/↓** pour l'historique
- **man commande** pour obtenir de l'aide
- Toujours **lire les messages d'erreur** attentivement
- **Pratiquer régulièrement** pour acquérir les automatismes