# Commandes de base

## La commande `ls` - Lister les fichiers

`ls` (list) est LA commande fondamentale pour explorer le contenu des répertoires.

### Syntaxe de base
```bash
ls [options] [répertoire]
```

### Utilisation simple
```bash
# Lister le répertoire courant
ls

# Lister un répertoire spécifique
ls /home
ls /etc
```

### Options essentielles de `ls`

#### `-l` : Format long (détaillé)
```bash
ls -l
# Résultat :
-rw-r--r-- 1 john john 1024 Jan 15 10:30 document.txt
drwxr-xr-x 2 john john 4096 Jan 15 09:15 Pictures
```

**Signification des colonnes** :
1. **Permissions** : `-rw-r--r--` (type + droits)
2. **Liens** : `1` (nombre de liens physiques)
3. **Propriétaire** : `john` 
4. **Groupe** : `john`
5. **Taille** : `1024` octets
6. **Date** : `Jan 15 10:30`
7. **Nom** : `document.txt`

#### `-a` : Afficher tous les fichiers (y compris cachés)
```bash
ls -a
# Affiche aussi : .bashrc, .profile, .ssh/, etc.
```

#### `-h` : Tailles lisibles par l'humain
```bash
ls -lh
# Tailles en K, M, G au lieu d'octets
-rw-r--r-- 1 john john 1.5K Jan 15 10:30 document.txt
```

#### `-t` : Trier par date de modification
```bash
ls -lt
# Le plus récent en premier
```

#### `-r` : Ordre inverse
```bash
ls -ltr
# Plus ancien en premier (très utile pour les logs)
```

#### `-S` : Trier par taille
```bash
ls -lS
# Le plus gros en premier
```

### Combinaisons d'options courantes
```bash
ls -la          # Tout afficher en format long
ls -lah         # Format long, tout, tailles lisibles  
ls -ltr         # Format long, par date, ordre inverse
ls -laS         # Tout afficher, trié par taille
```

## La commande `cd` - Changer de répertoire

### Syntaxe
```bash
cd [répertoire]
```

### Utilisations courantes
```bash
# Aller dans un répertoire
cd /etc
cd Documents
cd /home/john

# Aller au répertoire personnel
cd
cd ~

# Remonter d'un niveau  
cd ..

# Remonter de plusieurs niveaux
cd ../..
cd ../../etc

# Retourner au répertoire précédent
cd -
```

### Raccourcis utiles
- `cd` seul → répertoire personnel
- `cd ~` → répertoire personnel  
- `cd ..` → répertoire parent
- `cd -` → répertoire précédent
- `cd /` → racine du système

## La commande `pwd` - Afficher le répertoire courant

### Utilité
- **Savoir où on se trouve** dans l'arborescence
- **Vérifier** après un `cd`
- **Référence** pour les chemins relatifs

```bash
pwd
# Exemple de résultat : /home/john/Documents
```

### Intégration dans des scripts
```bash
echo "Je suis dans $(pwd)"
# Résultat : Je suis dans /home/john/Documents
```

## La commande `tree` - Visualisation arborescente

### Installation si nécessaire
```bash
# Sur Debian/Ubuntu
sudo apt-get install tree

# Sur CentOS/RHEL
sudo yum install tree
```

### Utilisation
```bash
# Arborescence du répertoire courant
tree

# Arborescence d'un répertoire spécifique  
tree /etc

# Limiter la profondeur
tree -L 2 /

# Afficher aussi les fichiers cachés
tree -a

# Afficher seulement les répertoires
tree -d
```

### Exemple de sortie
```
/home/john
├── Documents
│   ├── rapport.pdf
│   └── notes.txt
├── Pictures
│   └── vacances.jpg
└── Videos
    └── demo.mp4
```

## Utilisation combinée des commandes

### Navigation efficace
```bash
# Exploration systématique
pwd                    # Où suis-je ?
ls -la                 # Que contient ce répertoire ?
cd Documents           # Aller dans Documents
pwd                    # Vérifier la position
ls -lh                 # Voir le contenu
cd ..                  # Revenir au parent
```

### Patterns de navigation courants

#### Explorer un répertoire système
```bash
cd /var/log
pwd
ls -ltr               # Voir les logs par date
cd /etc
ls -la | grep conf    # Chercher les fichiers de config
```

#### Retour rapide au home
```bash
cd /var/log/apache2   # Aller quelque part de profond
cd                    # Retour direct au home
pwd                   # Vérifier : /home/username
```

#### Navigation avec historique
```bash
cd /etc
cd /var/log  
cd -                  # Retour à /etc
cd -                  # Retour à /var/log
```

## Options avancées et astuces

### `ls` avec filtres
```bash
# Fichiers d'un type donné
ls *.txt              # Tous les .txt
ls *.conf             # Tous les .conf
ls -la D*             # Tout ce qui commence par D

# Par extension avec ls long
ls -la | grep "\.log$"  # Tous les fichiers .log
```

### Affichage personnalisé
```bash
# Colonnes personnalisées
ls -la --time-style="+%d/%m/%Y %H:%M"

# Format de couleur (si supporté)
ls --color=always
```

### Navigation avec complétion
```bash
# Utiliser Tab pour compléter
cd /var/l[Tab]        # Complète en /var/log/
ls /etc/ap[Tab]       # Complète en /etc/apache2/ ou /etc/apt/
```

## Gestion des erreurs courantes

### Messages d'erreur et solutions

#### "Permission denied"
```bash
ls /root
# ls: cannot open directory '/root': Permission denied
# Solution : Utiliser sudo ou changer de répertoire
```

#### "No such file or directory"
```bash
cd /inexistant
# bash: cd: /inexistant: No such file or directory  
# Solution : Vérifier l'orthographe et l'existence
```

#### "Not a directory"
```bash
cd /etc/passwd
# bash: cd: /etc/passwd: Not a directory
# Solution : passwd est un fichier, pas un répertoire
```

### Vérifications avant navigation
```bash
# Vérifier qu'un répertoire existe
ls -ld /path/to/directory

# Vérifier les permissions
ls -la /path/to/parent/
```

## Bonnes pratiques

### 1. Toujours savoir où on est
```bash
# Habitude à prendre
pwd && ls -la
```

### 2. Explorer avant d'agir
```bash
# Avant de faire des modifications
cd /target/directory
pwd                   # Confirmer la position
ls -la                # Voir le contenu
```

### 3. Utiliser les alias pour gagner du temps
```bash
# Dans ~/.bashrc
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
```

### 4. Navigation sécurisée
```bash
# Utiliser les chemins absolus pour les scripts
cd /home/user/data    # Plutôt que cd ../data
```

## Combinaisons de commandes utiles

### Exploration rapide
```bash
# Une ligne pour explorer
pwd && echo "Contenu :" && ls -lah
```

### Navigation avec contexte
```bash
# Voir où on va avant d'y aller
ls -ld /target/directory && cd /target/directory
```

### Historique de navigation
```bash
# Historique des répertoires visités
dirs -v               # Afficher la pile de répertoires
pushd /new/path       # Aller vers un nouveau répertoire (pile)
popd                  # Retourner au répertoire précédent (pile)
```

## Points clés à retenir

- **`ls`** : lister les fichiers (`-l` détaillé, `-a` tout, `-h` lisible)
- **`cd`** : changer de répertoire (`~` home, `..` parent, `-` précédent)  
- **`pwd`** : afficher la position actuelle
- **`tree`** : visualisation arborescente (si installé)
- **Tab** : complétion automatique des chemins
- **Toujours vérifier** sa position avec `pwd`
- **Explorer** avec `ls` avant de naviguer avec `cd`

## Exercices pratiques

### Exercice 1 : Navigation de base
```bash
pwd                    # Noter la position
cd /                   # Aller à la racine
ls -la                 # Explorer
cd home                # Aller dans home
ls                     # Voir les utilisateurs
cd ~                   # Retour au home
pwd                    # Vérifier
```

### Exercice 2 : Exploration système
```bash
cd /etc
ls -la | head -10      # 10 premiers éléments
cd /var/log
ls -ltr | tail -5      # 5 derniers logs modifiés
cd -                   # Retour à /etc
```

### Exercice 3 : Utilisation de tree
```bash
tree -L 2 /home        # Arborescence home sur 2 niveaux
tree -d /usr           # Seulement les répertoires de /usr
```