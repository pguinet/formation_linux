# Comparaison de fichiers

## La commande `diff` - Comparer le contenu des fichiers

### Principe de diff
`diff` compare deux fichiers ligne par ligne et affiche les différences entre eux.

### Syntaxe de base
```bash
diff [options] fichier1 fichier2
```

### Utilisation simple
```bash
# Comparer deux fichiers
diff file1.txt file2.txt

# Comparer des répertoires
diff -r dir1/ dir2/

# Ignorer les différences de casse
diff -i file1.txt file2.txt
```

### Format de sortie de diff

#### Format par défaut
```bash
# Créons deux fichiers pour l'exemple
echo -e "ligne1\nligne2\nligne3" > file1.txt
echo -e "ligne1\nligne2 modifiée\nligne4" > file2.txt

diff file1.txt file2.txt
# Sortie :
# 2c2
# < ligne2
# ---
# > ligne2 modifiée
# 3c3
# < ligne3
# ---
# > ligne4
```

#### Interprétation des symboles
- `<` : ligne du premier fichier
- `>` : ligne du second fichier
- `---` : séparateur
- `2c2` : ligne 2 changée (changed)
- `3d3` : ligne 3 supprimée (deleted)
- `3a4` : ligne ajoutée (added) après la ligne 3

### Options importantes de diff

#### Format unifié (-u)
```bash
# Format unifié (plus lisible)
diff -u file1.txt file2.txt
# Sortie :
# --- file1.txt
# +++ file2.txt
# @@ -1,3 +1,3 @@
#  ligne1
# -ligne2
# +ligne2 modifiée
# -ligne3
# +ligne4
```

#### Format côte à côte (-y)
```bash
# Affichage côte à côte
diff -y file1.txt file2.txt
# Sortie :
# ligne1                ligne1
# ligne2              | ligne2 modifiée
# ligne3              | ligne4
```

#### Comparaison récursive (-r)
```bash
# Comparer des répertoires entiers
diff -r directory1/ directory2/

# Avec format unifié pour les répertoires
diff -ur directory1/ directory2/
```

### Options avancées de diff

#### Ignorer certaines différences
```bash
# Ignorer les espaces en fin de ligne
diff -b file1.txt file2.txt

# Ignorer tous les espaces
diff -w file1.txt file2.txt

# Ignorer les lignes vides
diff -B file1.txt file2.txt

# Ignorer la casse
diff -i file1.txt file2.txt
```

#### Contexte et présentation
```bash
# Afficher N lignes de contexte
diff -C 3 file1.txt file2.txt

# Format unifié avec contexte
diff -u -C 5 file1.txt file2.txt

# Pas de sortie si identiques (mode silencieux pour scripts)
diff -q file1.txt file2.txt
```

## Autres outils de comparaison

### La commande `cmp` - Comparaison binaire

#### Principe de cmp
`cmp` compare deux fichiers octet par octet et s'arrête à la première différence.

```bash
# Comparaison binaire
cmp file1.txt file2.txt
# Sortie si différent :
# file1.txt file2.txt differ: byte 10, line 2

# Mode silencieux (pour scripts)
cmp -s file1.txt file2.txt
echo $?  # 0 si identiques, 1 si différents

# Afficher toutes les différences
cmp -l file1.bin file2.bin
```

### La commande `comm` - Comparer des fichiers triés

#### Principe de comm
`comm` compare deux fichiers triés ligne par ligne et affiche trois colonnes.

```bash
# Créer des fichiers triés
echo -e "apple\nbanana\ncherry" > fruits1.txt
echo -e "banana\ncherry\ndate" > fruits2.txt

# Comparer avec comm
comm fruits1.txt fruits2.txt
# Colonne 1 : lignes uniquement dans fichier1
# Colonne 2 : lignes uniquement dans fichier2  
# Colonne 3 : lignes communes
```

#### Options de comm
```bash
# Supprimer certaines colonnes
comm -1 fruits1.txt fruits2.txt  # Sans colonne 1
comm -2 fruits1.txt fruits2.txt  # Sans colonne 2
comm -3 fruits1.txt fruits2.txt  # Sans colonne 3 (différences uniquement)

# Lignes communes seulement
comm -12 fruits1.txt fruits2.txt
```

## Applications pratiques de la comparaison

### Comparaison de fichiers de configuration
```bash
# Comparer configuration avant/après modification
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
# Modifier le fichier...
diff -u /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf

# Ignorer les commentaires lors de la comparaison
diff <(grep -v '^#' file1.conf) <(grep -v '^#' file2.conf)
```

### Comparaison de logs
```bash
# Comparer les logs d'hier et d'aujourd'hui
diff /var/log/syslog.1 /var/log/syslog | head -20

# Voir les nouvelles entrées seulement
comm -13 <(sort old_log.txt) <(sort new_log.txt)
```

### Vérification d'intégrité
```bash
# Comparer avec une somme de contrôle
md5sum file1.txt > file1.md5
# Plus tard...
md5sum -c file1.md5

# Comparer deux arborescences
diff -r --brief dir1/ dir2/
```

## Outils de comparaison avancés

### `vimdiff` - Comparaison visuelle avec vim
```bash
# Interface graphique dans vim
vimdiff file1.txt file2.txt

# Navigation dans vimdiff :
# ]c : différence suivante
# [c : différence précédente  
# do : récupérer (obtain) du fichier opposé
# dp : pousser (put) vers le fichier opposé
```

### `meld` - Comparateur graphique (si disponible)
```bash
# Interface graphique moderne
meld file1.txt file2.txt

# Pour les répertoires
meld dir1/ dir2/
```

### `colordiff` - diff avec couleurs
```bash
# Installation sur Ubuntu/Debian
sudo apt-get install colordiff

# Utilisation identique à diff mais avec couleurs
colordiff -u file1.txt file2.txt
```

## Génération et application de patches

### Créer un patch avec diff
```bash
# Créer un patch
diff -u original.txt modified.txt > changes.patch

# Format de patch standard
diff -Naur original_directory/ modified_directory/ > project.patch
```

### Appliquer un patch
```bash
# Appliquer un patch avec patch
patch < changes.patch

# Appliquer à un fichier spécifique
patch original.txt < changes.patch

# Test sans application (dry-run)
patch --dry-run < changes.patch

# Annuler un patch
patch -R < changes.patch
```

### Patch pour répertoires
```bash
# Créer un patch complet de projet
diff -Naur project_v1/ project_v2/ > project_v1_to_v2.patch

# Appliquer dans le répertoire cible
cd project_v1/
patch -p1 < ../project_v1_to_v2.patch
```

## Scripts de comparaison automatisée

### Script de sauvegarde avec comparaison
```bash
#!/bin/bash
# backup_with_diff.sh

SOURCE_DIR="/etc"
BACKUP_DIR="/backup/etc"
CURRENT_BACKUP="$BACKUP_DIR/current"
PREVIOUS_BACKUP="$BACKUP_DIR/previous"

# Déplacer l'ancienne sauvegarde
if [ -d "$CURRENT_BACKUP" ]; then
    mv "$CURRENT_BACKUP" "$PREVIOUS_BACKUP"
fi

# Créer nouvelle sauvegarde
cp -r "$SOURCE_DIR" "$CURRENT_BACKUP"

# Comparer avec la précédente si elle existe
if [ -d "$PREVIOUS_BACKUP" ]; then
    echo "=== Différences depuis la dernière sauvegarde ==="
    diff -r "$PREVIOUS_BACKUP" "$CURRENT_BACKUP" | head -20
fi
```

### Surveillance de modifications
```bash
#!/bin/bash
# watch_changes.sh

FILE_TO_WATCH="/etc/hosts"
REFERENCE_FILE="/tmp/hosts.ref"

# Créer référence si pas existante
if [ ! -f "$REFERENCE_FILE" ]; then
    cp "$FILE_TO_WATCH" "$REFERENCE_FILE"
    echo "Référence créée"
    exit 0
fi

# Comparer
if ! diff -q "$FILE_TO_WATCH" "$REFERENCE_FILE" > /dev/null; then
    echo "ALERTE : $FILE_TO_WATCH a été modifié!"
    echo "Différences :"
    diff -u "$REFERENCE_FILE" "$FILE_TO_WATCH"
    
    # Mettre à jour la référence
    cp "$FILE_TO_WATCH" "$REFERENCE_FILE"
else
    echo "Aucun changement détecté"
fi
```

## Comparaison de données structurées

### Fichiers CSV
```bash
# Comparer des CSV (ignorer l'ordre des lignes)
diff <(sort file1.csv) <(sort file2.csv)

# Comparer seulement certaines colonnes avec awk
diff <(awk -F',' '{print $1,$3}' file1.csv | sort) \
     <(awk -F',' '{print $1,$3}' file2.csv | sort)
```

### Fichiers JSON
```bash
# Comparer JSON formatés
diff <(python -m json.tool file1.json) <(python -m json.tool file2.json)

# Avec jq si disponible
diff <(jq -S . file1.json) <(jq -S . file2.json)
```

### Fichiers de configuration
```bash
# Ignorer commentaires et lignes vides
diff <(grep -v '^#' config1.conf | grep -v '^$' | sort) \
     <(grep -v '^#' config2.conf | grep -v '^$' | sort)
```

## Optimisation et bonnes pratiques

### Performance sur gros fichiers
```bash
# Comparaison rapide (arrêt à première différence)
diff -q large_file1.txt large_file2.txt

# Limiter la sortie diff
diff file1.txt file2.txt | head -20

# Utiliser cmp pour les fichiers binaires volumineux
cmp large_binary1.bin large_binary2.bin
```

### Automatisation et scripts
```bash
# Fonction de comparaison avec rapport
compare_files() {
    local file1="$1"
    local file2="$2"
    
    if [ ! -f "$file1" ] || [ ! -f "$file2" ]; then
        echo "Erreur : fichiers manquants"
        return 1
    fi
    
    echo "Comparaison de $file1 et $file2"
    echo "Taille 1: $(stat -c%s "$file1") octets"
    echo "Taille 2: $(stat -c%s "$file2") octets"
    
    if diff -q "$file1" "$file2" > /dev/null; then
        echo "Les fichiers sont identiques"
    else
        echo "Les fichiers diffèrent :"
        diff -u "$file1" "$file2" | head -10
    fi
}
```

### Intégration avec Git
```bash
# Comparer avec version précédente dans Git
git diff HEAD~1 filename

# Comparer deux branches
git diff branch1..branch2

# Utiliser diff externe avec Git
git config diff.tool vimdiff
git difftool file.txt
```

## Points clés à retenir

- **`diff`** : outil principal de comparaison de fichiers
- **Formats** : défaut, unifié (-u), côte à côte (-y)
- **`cmp`** : comparaison binaire, arrêt à première différence
- **`comm`** : comparaison de fichiers triés en colonnes
- **Patches** : `diff -u` pour créer, `patch` pour appliquer
- **Options utiles** : `-i` (casse), `-w` (espaces), `-r` (récursif)
- **Outils visuels** : vimdiff, meld pour interface graphique
- **Scripts** : automatiser surveillance et comparaisons
- **Performance** : `-q` pour test rapide, cmp pour binaires

## Exercices pratiques

### Exercice 1 : Comparaison de base
```bash
# Créer deux fichiers similaires
echo -e "ligne1\nligne2\nligne3" > test1.txt
echo -e "ligne1\nligne2 modifiée\nligne4" > test2.txt

# Comparer avec différents formats
diff test1.txt test2.txt
diff -u test1.txt test2.txt
diff -y test1.txt test2.txt
```

### Exercice 2 : Comparaison de répertoires
```bash
# Créer deux structures similaires
mkdir -p dir1 dir2
echo "content1" > dir1/file1.txt
echo "content2" > dir1/file2.txt
echo "content1" > dir2/file1.txt
echo "different content" > dir2/file2.txt

# Comparer récursivement
diff -r dir1/ dir2/
```

### Exercice 3 : Création et application de patch
```bash
# Modifier un fichier
cp test1.txt original.txt
echo "nouvelle ligne" >> test1.txt

# Créer patch
diff -u original.txt test1.txt > changes.patch

# Appliquer patch
cp original.txt restored.txt
patch restored.txt < changes.patch
```