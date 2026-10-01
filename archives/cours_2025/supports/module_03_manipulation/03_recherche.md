# Recherche de fichiers

## La commande `find` - L'outil de recherche universel

### Principe de base
`find` est la commande la plus puissante pour rechercher des fichiers et répertoires selon de multiples critères.

### Syntaxe générale
```bash
find [chemin] [critères] [actions]
```

### Recherche de base par nom

#### Recherche simple par nom exact
```bash
# Chercher un fichier spécifique depuis le répertoire courant
find . -name "fichier.txt"

# Chercher dans un répertoire spécifique
find /home -name "config.json"

# Chercher dans tout le système (peut être lent)
find / -name "passwd" 2>/dev/null
```

#### Recherche avec patterns (wildcards)
```bash
# Tous les fichiers .txt
find . -name "*.txt"

# Tous les fichiers commençant par "log"
find /var/log -name "log*"

# Fichiers avec pattern complexe
find . -name "backup_*_2024.sql"
```

#### Recherche insensible à la casse
```bash
# Chercher README, readme, ReadMe, etc.
find . -iname "readme*"

# Chercher des extensions variées
find . -iname "*.JPG"  # Trouve .jpg, .JPG, .Jpg, etc.
```

### Recherche par type de fichier

#### Option `-type`
```bash
# Fichiers ordinaires seulement
find . -type f -name "*.conf"

# Répertoires seulement
find . -type d -name "*backup*"

# Liens symboliques
find . -type l

# Fichiers exécutables
find /usr/bin -type f -executable
```

#### Types disponibles
- `f` : fichiers ordinaires
- `d` : répertoires
- `l` : liens symboliques
- `c` : périphériques caractères
- `b` : périphériques blocs
- `p` : pipes nommées
- `s` : sockets

### Recherche par taille

#### Syntaxe des tailles
```bash
# Fichiers plus gros que 100MB
find . -type f -size +100M

# Fichiers plus petits que 1KB
find . -type f -size -1k

# Fichiers d'exactement 512 octets
find . -type f -size 512c
```

#### Unités de taille
- `c` : octets (bytes)
- `k` : kilo-octets (1024 bytes)
- `M` : mega-octets (1024k)
- `G` : giga-octets (1024M)

#### Exemples pratiques
```bash
# Trouver les gros fichiers (plus de 500MB)
find /home -type f -size +500M

# Fichiers vides
find . -type f -empty

# Répertoires vides
find . -type d -empty

# Fichiers entre 1MB et 10MB
find . -type f -size +1M -size -10M
```

### Recherche par date et temps

#### Types de temps
- `mtime` : modification du contenu
- `atime` : dernier accès
- `ctime` : changement des métadonnées

#### Syntaxe temporelle
```bash
# Fichiers modifiés dans les dernières 24h
find . -type f -mtime -1

# Fichiers modifiés il y a plus de 7 jours
find . -type f -mtime +7

# Fichiers modifiés exactement il y a 3 jours
find . -type f -mtime 3
```

#### Recherche par minutes
```bash
# Fichiers modifiés dans les dernières 30 minutes
find . -type f -mmin -30

# Fichiers accédés dans les dernières 2 heures
find . -type f -amin -120
```

#### Exemples pratiques temporels
```bash
# Logs récents
find /var/log -type f -mtime -1

# Fichiers anciens à nettoyer
find /tmp -type f -mtime +30

# Fichiers modifiés aujourd'hui
find . -type f -mtime 0

# Fichiers créés cette semaine
find . -type f -ctime -7
```

### Recherche par permissions et propriétaire

#### Permissions
```bash
# Fichiers avec permissions spécifiques (lecture/écriture pour tous)
find . -type f -perm 666

# Fichiers avec au moins ces permissions
find . -type f -perm -644

# Fichiers exécutables par tous
find . -type f -perm -111
```

#### Propriétaire et groupe
```bash
# Fichiers appartenant à un utilisateur
find /home -user john

# Fichiers appartenant à un groupe
find /var/log -group adm

# Fichiers sans propriétaire (orphelins)
find / -nouser 2>/dev/null

# Fichiers sans groupe
find / -nogroup 2>/dev/null
```

### Combinaison de critères

#### Opérateurs logiques
```bash
# ET logique (par défaut)
find . -name "*.txt" -size +1M

# OU logique
find . -name "*.txt" -o -name "*.md"

# NON logique
find . -type f ! -name "*.tmp"

# Parenthèses pour grouper
find . \( -name "*.txt" -o -name "*.md" \) -size +1k
```

#### Exemples complexes
```bash
# Fichiers .log plus gros que 10MB ET modifiés récemment
find /var/log -name "*.log" -size +10M -mtime -7

# Scripts shell OU Python dans /usr/local
find /usr/local -type f \( -name "*.sh" -o -name "*.py" \)

# Tous les fichiers SAUF les .tmp et .bak
find . -type f ! -name "*.tmp" ! -name "*.bak"
```

### Actions sur les résultats trouvés

#### Actions de base
```bash
# Affichage simple (par défaut)
find . -name "*.txt"

# Affichage détaillé
find . -name "*.txt" -ls

# Afficher seulement le nom de fichier
find . -name "*.txt" -printf "%f\n"
```

#### Exécuter des commandes
```bash
# Supprimer les fichiers trouvés
find . -name "*.tmp" -delete

# Exécuter une commande pour chaque fichier
find . -name "*.txt" -exec cat {} \;

# Exécuter avec confirmation
find . -name "*.bak" -exec rm -i {} \;

# Exécuter en lot (plus efficace)
find . -name "*.txt" -exec grep "pattern" {} +
```

#### Exemples d'actions pratiques
```bash
# Copier tous les .conf vers backup
find /etc -name "*.conf" -exec cp {} ~/backup/ \;

# Changer les permissions de tous les scripts
find . -name "*.sh" -exec chmod +x {} \;

# Afficher la taille des gros fichiers
find . -size +100M -exec ls -lh {} \;

# Compresser les anciens logs
find /var/log -name "*.log" -mtime +7 -exec gzip {} \;
```

## La commande `locate` - Recherche rapide par base de données

### Principe
`locate` utilise une base de données pré-indexée pour des recherches très rapides par nom.

### Installation et mise à jour
```bash
# Installer (si nécessaire)
sudo apt-get install mlocate

# Mettre à jour la base de données
sudo updatedb

# Vérifier la dernière mise à jour
ls -la /var/lib/mlocate/mlocate.db
```

### Utilisation de base
```bash
# Recherche simple
locate passwd

# Recherche avec pattern
locate "*.conf"

# Limiter le nombre de résultats
locate -l 10 "*.log"

# Recherche insensible à la casse
locate -i readme
```

### Avantages et limites
**Avantages :**
- Très rapide
- Recherche dans tout le système
- Simple d'utilisation

**Limites :**
- Base de données mise à jour quotidiennement seulement
- Recherche par nom uniquement
- Pas de critères avancés (taille, date, etc.)

### Comparaison `find` vs `locate`
```bash
# find : recherche en temps réel, lent mais à jour
find / -name "config.json" 2>/dev/null

# locate : recherche dans l'index, rapide mais peut être obsolète
locate config.json
```

## Les commandes `which` et `whereis`

### `which` - Localiser les exécutables
```bash
# Où se trouve la commande ls ?
which ls
# /bin/ls

# Plusieurs commandes
which python python3 pip
# /usr/bin/python
# /usr/bin/python3
# /usr/bin/pip

# Vérifier si une commande existe
which nonexistent_command
# which: no nonexistent_command in (/usr/bin:/bin:...)
```

### `whereis` - Localiser binaires, sources et manuels
```bash
# Informations complètes sur une commande
whereis ls
# ls: /bin/ls /usr/share/man/man1/ls.1.gz

# Seulement les binaires
whereis -b python
# python: /usr/bin/python /usr/bin/python3.9

# Seulement les manuels
whereis -m grep
# grep: /usr/share/man/man1/grep.1.gz
```

## Techniques avancées de recherche

### Recherche avec expressions régulières
```bash
# Utiliser regex avec find
find . -regex ".*\.\(txt\|md\|rst\)"

# find avec grep pour le contenu
find . -name "*.py" -exec grep -l "import pandas" {} \;
```

### Optimisation des performances
```bash
# Limiter la profondeur de recherche
find . -maxdepth 2 -name "*.txt"

# Exclure certains répertoires
find / -path "/proc" -prune -o -name "*.conf" -print

# Recherche parallèle (GNU parallel)
find . -name "*.txt" | parallel -j 4 wc -l
```

### Scripts de recherche personnalisés
```bash
#!/bin/bash
# Fonction de recherche intelligente
smart_find() {
    local pattern="$1"
    local dir="${2:-.}"
    
    echo "=== Recherche par nom ==="
    find "$dir" -iname "*$pattern*" -type f
    
    echo -e "\n=== Recherche dans le contenu ==="
    find "$dir" -type f -exec grep -l "$pattern" {} \; 2>/dev/null
}

# Usage
smart_find "config" /etc
```

## Cas d'usage pratiques

### Administration système
```bash
# Trouver les fichiers de configuration modifiés récemment
find /etc -name "*.conf" -mtime -7 -ls

# Identifier les gros fichiers qui consomment de l'espace
find / -type f -size +100M -exec du -h {} \; 2>/dev/null

# Trouver les fichiers sans propriétaire (sécurité)
find / -nouser -o -nogroup 2>/dev/null

# Scripts avec permissions trop permissives
find /usr/local -type f -perm -002 -exec ls -la {} \;
```

### Développement
```bash
# Trouver tous les fichiers Python contenant une fonction
find . -name "*.py" -exec grep -l "def main" {} \;

# Fichiers modifiés pendant le développement
find . -name "*.js" -mmin -60

# Nettoyer les fichiers de compilation
find . -name "*.pyc" -o -name "__pycache__" -type d -exec rm -rf {} +

# Trouver les imports non utilisés
find . -name "*.py" -exec grep "^import\|^from" {} \; | sort | uniq
```

### Maintenance et nettoyage
```bash
# Fichiers temporaires anciens
find /tmp -type f -mtime +7 -delete

# Logs volumineux
find /var/log -name "*.log" -size +50M

# Duplicatas potentiels (par taille)
find . -type f -exec ls -la {} \; | sort -k5,5n | uniq -f4 -d

# Fichiers cachés suspects dans le home
find ~ -name ".*" -type f -size +1M
```

## Points clés à retenir

- **`find`** : outil principal, très puissant, recherche en temps réel
- **`locate`** : rapide mais base de données (updatedb)
- **`which`** : localiser les commandes dans le PATH
- **`whereis`** : binaires + manuels + sources
- **Critères combinables** : nom, taille, date, permissions, propriétaire
- **Actions possibles** : affichage, suppression, exécution de commandes
- **Performance** : utiliser -maxdepth, exclure /proc, /sys
- **Sécurité** : rediriger stderr vers /dev/null pour éviter les erreurs

## Exercices pratiques

### Exercice 1 : Recherches de base
```bash
# Trouver tous les fichiers .txt dans votre home
find ~ -name "*.txt"

# Trouver les répertoires nommés "backup"
find / -type d -name "*backup*" 2>/dev/null

# Fichiers plus gros que 10MB
find . -size +10M
```

### Exercice 2 : Recherche avancée
```bash
# Fichiers .log modifiés dans les 3 derniers jours
find /var/log -name "*.log" -mtime -3

# Scripts exécutables dans /usr/local
find /usr/local -type f -executable -name "*.sh"

# Fichiers appartenant à root dans /home
sudo find /home -user root
```

### Exercice 3 : Actions sur les résultats
```bash
# Créer des fichiers tests
mkdir test_search
cd test_search
touch file1.txt file2.log old_backup.bak
echo "content" > file3.txt

# Supprimer les .bak
find . -name "*.bak" -delete

# Afficher le contenu des .txt
find . -name "*.txt" -exec cat {} \;
```