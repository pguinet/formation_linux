# Archivage et compression

## Concepts fondamentaux

### Différence archivage vs compression

**Archivage** : Regrouper plusieurs fichiers en un seul fichier
**Compression** : Réduire la taille d'un fichier en supprimant la redondance
**Archive compressée** : Combinaison des deux

### Avantages de l'archivage
- **Regroupement** : Un seul fichier à manipuler
- **Préservation** : Métadonnées et structure préservées
- **Transport** : Plus facile à déplacer/copier
- **Sauvegarde** : Snapshot cohérent d'un ensemble de fichiers

## La commande `tar` - L'archiveur universel

### Principe de tar
`tar` (Tape ARchive) est l'outil standard Unix/Linux pour créer des archives.

### Syntaxe générale
```bash
tar [options] [archive] [fichiers/répertoires]
```

### Options essentielles de tar

#### Options principales
- `c` : créer une archive
- `x` : extraire une archive
- `t` : lister le contenu d'une archive
- `v` : mode verbeux (afficher les détails)
- `f` : spécifier le nom du fichier archive

#### Options de compression
- `z` : compression gzip (.tar.gz)
- `j` : compression bzip2 (.tar.bz2)
- `J` : compression xz (.tar.xz)

### Créer des archives

#### Archive simple (sans compression)
```bash
# Créer une archive tar
tar -cvf mon_archive.tar dossier/

# Créer une archive de plusieurs éléments
tar -cvf backup.tar file1.txt file2.txt dossier/

# Archive avec chemin relatif
tar -cvf projet.tar projet/
```

#### Archives compressées

##### Gzip (extension .tar.gz ou .tgz)
```bash
# Créer une archive gzip
tar -czvf archive.tar.gz dossier/

# Version courte équivalente
tar -czf archive.tgz dossier/
```

##### Bzip2 (extension .tar.bz2)
```bash
# Créer une archive bzip2 (meilleure compression)
tar -cjvf archive.tar.bz2 dossier/
```

##### XZ (extension .tar.xz)
```bash
# Créer une archive xz (compression moderne)
tar -cJvf archive.tar.xz dossier/
```

### Extraire des archives

#### Extraction de base
```bash
# Extraire une archive tar
tar -xvf mon_archive.tar

# Extraire vers un répertoire spécifique
tar -xvf archive.tar -C /destination/

# Extraire avec préservation des permissions
tar -xpvf archive.tar
```

#### Extraction d'archives compressées
```bash
# tar détecte automatiquement la compression
tar -xvf archive.tar.gz
tar -xvf archive.tar.bz2
tar -xvf archive.tar.xz

# Ou spécifier explicitement
tar -xzvf archive.tar.gz
tar -xjvf archive.tar.bz2
tar -xJvf archive.tar.xz
```

#### Extraction sélective
```bash
# Extraire seulement certains fichiers
tar -xvf archive.tar dossier/fichier_specifique.txt

# Extraire avec pattern
tar -xvf archive.tar --wildcards "*.conf"

# Exclure certains fichiers pendant l'extraction
tar -xvf archive.tar --exclude="*.tmp"
```

### Lister le contenu d'archives

```bash
# Lister le contenu
tar -tvf archive.tar

# Lister avec détails (permissions, dates)
tar -tvf archive.tar.gz

# Chercher dans une archive
tar -tvf archive.tar | grep "config"
```

### Options avancées de tar

#### Exclusions lors de la création
```bash
# Exclure des fichiers par pattern
tar -czvf backup.tar.gz --exclude="*.tmp" --exclude="*.log" dossier/

# Exclure des répertoires
tar -czvf backup.tar.gz --exclude="node_modules" --exclude=".git" projet/

# Utiliser un fichier d'exclusion
echo "*.tmp" > exclude_list.txt
echo ".git/" >> exclude_list.txt
tar -czvf backup.tar.gz --exclude-from=exclude_list.txt projet/
```

#### Préservation des attributs
```bash
# Préserver les permissions et propriétaires
tar -czvpf backup.tar.gz dossier/

# Préserver les ACL et attributs étendus
tar --acls --xattrs -czvf backup.tar.gz dossier/
```

#### Archives incrémentales
```bash
# Première sauvegarde complète
tar -czvf backup_full.tar.gz --listed-incremental=backup.snar dossier/

# Sauvegarde incrémentale (seulement les changements)
tar -czvf backup_incr.tar.gz --listed-incremental=backup.snar dossier/
```

## Compression de fichiers individuels

### Gzip - Compression standard
```bash
# Compresser un fichier (remplace l'original)
gzip fichier.txt
# Crée fichier.txt.gz

# Compresser en gardant l'original
gzip -c fichier.txt > fichier.txt.gz

# Décompresser
gunzip fichier.txt.gz
# ou
gzip -d fichier.txt.gz

# Voir le contenu sans décompresser
zcat fichier.txt.gz
zless fichier.txt.gz
```

### Bzip2 - Meilleure compression
```bash
# Compresser avec bzip2
bzip2 fichier.txt
# Crée fichier.txt.bz2

# Décompresser
bunzip2 fichier.txt.bz2
# ou
bzip2 -d fichier.txt.bz2

# Voir le contenu
bzcat fichier.txt.bz2
bzless fichier.txt.bz2
```

### XZ - Compression moderne
```bash
# Compresser avec xz
xz fichier.txt
# Crée fichier.txt.xz

# Décompresser
unxz fichier.txt.xz
# ou
xz -d fichier.txt.xz

# Voir le contenu
xzcat fichier.txt.xz
xzless fichier.txt.xz
```

## Formats d'archives populaires

### Archives ZIP
```bash
# Créer une archive zip
zip -r archive.zip dossier/

# Ajouter des fichiers à un zip existant
zip archive.zip nouveau_fichier.txt

# Extraire un zip
unzip archive.zip

# Lister le contenu d'un zip
unzip -l archive.zip

# Extraire vers un répertoire spécifique
unzip archive.zip -d /destination/
```

### Archives RAR (lecture seulement)
```bash
# Installer unrar
sudo apt-get install unrar

# Extraire un fichier RAR
unrar x archive.rar

# Lister le contenu
unrar l archive.rar
```

### Archives 7z
```bash
# Installer p7zip
sudo apt-get install p7zip-full

# Créer une archive 7z
7z a archive.7z dossier/

# Extraire
7z x archive.7z

# Lister le contenu
7z l archive.7z
```

## Cas d'usage pratiques

### Sauvegarde système
```bash
#!/bin/bash
# Script de sauvegarde automatique

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"
SOURCE_DIR="/home/important_data"

# Créer une sauvegarde compressée avec exclusions
tar -czvf "$BACKUP_DIR/backup_$DATE.tar.gz" \
    --exclude="*.tmp" \
    --exclude="*.cache" \
    --exclude=".git" \
    "$SOURCE_DIR"

echo "Sauvegarde créée : backup_$DATE.tar.gz"
```

### Archivage de logs
```bash
# Archiver les anciens logs
find /var/log -name "*.log" -mtime +7 -exec gzip {} \;

# Créer une archive des logs du mois dernier
tar -czvf logs_$(date -d "last month" +%Y%m).tar.gz /var/log/*.log-*
```

### Distribution de code source
```bash
# Créer une distribution propre du code
tar -czvf myproject-1.0.tar.gz \
    --exclude=".git" \
    --exclude="node_modules" \
    --exclude="*.pyc" \
    --exclude="__pycache__" \
    myproject/
```

### Migration de serveur
```bash
# Archiver les données utilisateur
tar -czvf users_data.tar.gz /home/

# Archiver la configuration système
tar -czvf system_config.tar.gz /etc/

# Sur le nouveau serveur
tar -xzvf users_data.tar.gz -C /
tar -xzvf system_config.tar.gz -C /
```

## Comparaison des méthodes de compression

### Tableau comparatif

| Format | Vitesse | Compression | Commande | Extension |
|--------|---------|-------------|----------|-----------|
| **tar** | Très rapide | Aucune | tar -cf | .tar |
| **gzip** | Rapide | Bonne | tar -czf | .tar.gz |
| **bzip2** | Moyen | Très bonne | tar -cjf | .tar.bz2 |
| **xz** | Lent | Excellente | tar -cJf | .tar.xz |
| **zip** | Rapide | Bonne | zip -r | .zip |
| **7z** | Moyen | Excellente | 7z a | .7z |

### Test de compression
```bash
# Créer un fichier test volumineux
dd if=/dev/zero of=test_file bs=1M count=100

# Tester différentes compressions
time gzip -c test_file > test.gz
time bzip2 -c test_file > test.bz2
time xz -c test_file > test.xz

# Comparer les tailles
ls -lh test*
```

## Vérification d'intégrité

### Checksums pour vérifier l'intégrité
```bash
# Créer des checksums
md5sum archive.tar.gz > archive.md5
sha256sum archive.tar.gz > archive.sha256

# Vérifier l'intégrité
md5sum -c archive.md5
sha256sum -c archive.sha256
```

### Test d'archives
```bash
# Tester une archive tar
tar -tf archive.tar.gz > /dev/null && echo "Archive OK"

# Tester un zip
unzip -t archive.zip

# Tester un 7z
7z t archive.7z
```

## Automatisation et scripts

### Script de sauvegarde rotatif
```bash
#!/bin/bash
# backup_rotate.sh

BACKUP_DIR="/backup"
SOURCE="/home/data"
KEEP_DAYS=7

# Créer la sauvegarde du jour
DATE=$(date +%Y%m%d)
tar -czvf "$BACKUP_DIR/backup_$DATE.tar.gz" "$SOURCE"

# Supprimer les anciennes sauvegardes
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +$KEEP_DAYS -delete

echo "Sauvegarde terminée et rotation effectuée"
```

### Fonction de restauration
```bash
restore_backup() {
    local backup_file="$1"
    local restore_path="${2:-/tmp/restore}"
    
    if [ ! -f "$backup_file" ]; then
        echo "Erreur : $backup_file n'existe pas"
        return 1
    fi
    
    mkdir -p "$restore_path"
    echo "Restauration de $backup_file vers $restore_path"
    tar -xzvf "$backup_file" -C "$restore_path"
    echo "Restauration terminée"
}

# Usage
restore_backup backup_20240115.tar.gz /tmp/restore
```

## Bonnes pratiques

### 1. Nommage des archives
```bash
# Inclure la date et version
projet_v1.2_20240115.tar.gz
backup_system_20240115_143000.tar.bz2

# Être descriptif
database_backup_mysql_production_20240115.tar.xz
```

### 2. Choix du format
- **tar.gz** : Usage général, bon équilibre
- **tar.bz2** : Archivage long terme, meilleure compression
- **tar.xz** : Archives importantes, compression maximale
- **zip** : Compatibilité Windows, distribution

### 3. Vérification systématique
```bash
# Toujours tester après création
tar -tzf archive.tar.gz > /dev/null && echo "Archive valide"

# Vérifier avant extraction importante
tar -tvf archive.tar.gz | head -10
```

### 4. Sécurité
```bash
# Éviter l'extraction dans des répertoires sensibles
tar -tf suspicious.tar | grep "\.\./"  # Chercher les path traversal

# Extraire dans un répertoire dédié
mkdir /tmp/extract_safe
tar -xzf archive.tar.gz -C /tmp/extract_safe
```

## Points clés à retenir

- **`tar`** : outil principal d'archivage Linux
- **Options essentielles** : `-c` créer, `-x` extraire, `-t` lister, `-v` verbeux, `-f` fichier
- **Compression** : `-z` gzip, `-j` bzip2, `-J` xz
- **Exclusions** : `--exclude` pour filtrer le contenu
- **Formats** : .tar.gz (standard), .tar.bz2 (compression), .tar.xz (maximum)
- **Vérification** : toujours tester les archives créées
- **Sécurité** : attention aux chemins dans les archives
- **Automation** : scripts pour sauvegardes automatiques

## Exercices pratiques

### Exercice 1 : Création d'archives
```bash
# Créer une structure de test
mkdir -p test_archive/{docs,images,scripts}
touch test_archive/docs/{readme.txt,manual.pdf}
touch test_archive/images/{photo1.jpg,photo2.png}
touch test_archive/scripts/{backup.sh,deploy.py}

# Créer différents types d'archives
tar -cvf test.tar test_archive/
tar -czvf test.tar.gz test_archive/
tar -cjvf test.tar.bz2 test_archive/

# Comparer les tailles
ls -lh test.tar*
```

### Exercice 2 : Extraction et vérification
```bash
# Créer un répertoire de test
mkdir extract_test
cd extract_test

# Extraire l'archive
tar -xzvf ../test.tar.gz

# Vérifier le contenu
tree test_archive/
```

### Exercice 3 : Archive avec exclusions
```bash
# Créer une archive en excluant certains fichiers
tar -czvf projet_clean.tar.gz \
    --exclude="*.tmp" \
    --exclude="*.log" \
    --exclude=".git" \
    test_archive/
```