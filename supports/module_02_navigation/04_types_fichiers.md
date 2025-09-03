# Types de fichiers et liens

## Les types de fichiers sous Linux

Dans Linux, tout est fichier, mais il existe plusieurs **types** de fichiers identifiables par la première lettre dans `ls -l`.

### Visualisation des types
```bash
ls -la /dev/ | head -10
# Exemple de sortie :
crw-rw-rw- 1 root root     1,   3 Jan 15 10:30 null
brw-rw---- 1 root disk     8,   0 Jan 15 10:30 sda
drwxr-xr-x 2 root root  4096 Jan 15 10:30 shm
-rw-r--r-- 1 root root   123 Jan 15 10:30 version
lrwxrwxrwx 1 root root    13 Jan 15 10:30 fd -> /proc/self/fd
```

## Types de fichiers principaux

### 1. Fichiers ordinaires (`-`)
**Caractère** : `-` (tiret)
**Description** : Fichiers de données classiques

```bash
-rw-r--r-- 1 john john 1024 Jan 15 10:30 document.txt
-rwxr-xr-x 1 john john 8192 Jan 15 10:30 script.sh
```

**Exemples** :
- Documents texte (`.txt`, `.md`)
- Images (`.jpg`, `.png`)  
- Programmes exécutables
- Archives (`.tar`, `.zip`)
- Fichiers de configuration

### 2. Répertoires (`d`)
**Caractère** : `d` (directory)
**Description** : Conteneurs pour organiser les fichiers

```bash
drwxr-xr-x 2 john john 4096 Jan 15 10:30 Documents
drwx------ 2 john john 4096 Jan 15 10:30 .ssh
```

**Commandes spécifiques** :
```bash
mkdir nouveau_dossier     # Créer un répertoire
rmdir dossier_vide        # Supprimer un répertoire vide
```

### 3. Liens symboliques (`l`)  
**Caractère** : `l` (link)
**Description** : Raccourcis pointant vers d'autres fichiers

```bash
lrwxrwxrwx 1 root root 13 Jan 15 10:30 fd -> /proc/self/fd
lrwxrwxrwx 1 john john  9 Jan 15 10:30 latest -> file-2024
```

### 4. Fichiers de périphériques

#### Périphériques caractères (`c`)
**Description** : Périphériques qui traitent les données caractère par caractère

```bash
crw-rw-rw- 1 root root 1, 3 Jan 15 10:30 null
crw--w---- 1 root tty  4, 0 Jan 15 10:30 tty0
```

**Exemples** : terminaux, ports série, `/dev/null`

#### Périphériques blocs (`b`)
**Description** : Périphériques qui traitent les données par blocs

```bash
brw-rw---- 1 root disk 8, 0 Jan 15 10:30 sda
brw-rw---- 1 root disk 8, 1 Jan 15 10:30 sda1
```

**Exemples** : disques durs, partitions, CD-ROM

### 5. Autres types spéciaux

#### Pipes nommées (`p`)
**Description** : Communication entre processus
```bash
prw-r--r-- 1 john john 0 Jan 15 10:30 mon_pipe
```

#### Sockets (`s`)
**Description** : Communication réseau ou locale
```bash
srwxrwxrwx 1 mysql mysql 0 Jan 15 10:30 mysql.sock
```

## Les liens dans Linux

Il existe deux types de liens : **symboliques** et **physiques** (hard links).

### Liens symboliques (soft links)

#### Définition
Un lien symbolique est un **fichier spécial** qui contient le chemin vers un autre fichier ou répertoire.

#### Création
```bash
ln -s /chemin/vers/fichier_original nom_du_lien
```

#### Exemples pratiques
```bash
# Créer un lien vers un fichier
ln -s /home/john/Documents/rapport.pdf rapport_actuel.pdf

# Créer un lien vers un répertoire
ln -s /var/log/apache2 logs_apache

# Lien avec chemin relatif
ln -s ../Documents/projet projet_courant
```

#### Caractéristiques des liens symboliques
- **Fichier indépendant** avec son propre inode
- **Contient le chemin** vers la cible (texte)
- **Peut pointer** vers des fichiers inexistants
- **Peut traverser** les systèmes de fichiers
- **Suppression** : ne supprime que le lien, pas la cible

#### Visualisation
```bash
ls -la
lrwxrwxrwx 1 john john   24 Jan 15 10:30 rapport_actuel.pdf -> /home/john/Documents/rapport.pdf
lrwxrwxrwx 1 john john   15 Jan 15 10:30 logs_apache -> /var/log/apache2
```

### Liens physiques (hard links)

#### Définition
Un lien physique est un **nom supplémentaire** pour un fichier existant. Les deux noms pointent vers le même contenu.

#### Création
```bash
ln fichier_original nouveau_nom
```

#### Exemples
```bash
# Créer un hard link
ln rapport.txt sauvegarde_rapport.txt

# Vérifier les liens
ls -li rapport.txt sauvegarde_rapport.txt
# 1234567 -rw-r--r-- 2 john john 1024 Jan 15 10:30 rapport.txt
# 1234567 -rw-r--r-- 2 john john 1024 Jan 15 10:30 sauvegarde_rapport.txt
```

#### Caractéristiques des liens physiques
- **Même inode** que le fichier original
- **Compteur de liens** incrémenté
- **Impossible** pour les répertoires (sauf cas spéciaux)
- **Limité** au même système de fichiers
- **Suppression** : le fichier existe tant qu'un lien existe

## Commandes pour gérer les liens

### Créer des liens
```bash
# Lien symbolique
ln -s cible lien_symbolique

# Lien physique  
ln cible lien_physique

# Lien symbolique vers répertoire
ln -s /path/to/directory nom_raccourci

# Forcer la création (écraser si existe)
ln -sf nouvelle_cible lien_existant
```

### Identifier les liens
```bash
# Voir les liens symboliques
ls -la | grep "^l"

# Voir le nombre de liens physiques (3ème colonne)
ls -li

# Trouver tous les liens physiques d'un fichier
find . -inum $(stat -c %i fichier.txt)
```

### Gérer les liens cassés
```bash
# Trouver les liens symboliques cassés
find . -type l -xtype l

# Supprimer les liens cassés
find . -type l -xtype l -delete
```

## Exemples pratiques d'utilisation

### 1. Versioning de fichiers
```bash
# Structure de versions
ls -la
-rw-r--r-- 1 john john 1024 Jan 10 10:30 config-2024-01-10.txt
-rw-r--r-- 1 john john 1156 Jan 15 10:30 config-2024-01-15.txt
lrwxrwxrwx 1 john john   20 Jan 15 10:30 config-latest.txt -> config-2024-01-15.txt

# Utiliser toujours config-latest.txt
cat config-latest.txt

# Mettre à jour vers nouvelle version
ln -sf config-2024-01-20.txt config-latest.txt
```

### 2. Organisation de projets
```bash
# Liens vers répertoires fréquents
ln -s /var/log/nginx logs_nginx
ln -s /etc/apache2 config_apache  
ln -s /home/john/projets/webapp webapp_dev

# Navigation rapide
cd logs_nginx    # Au lieu de cd /var/log/nginx
```

### 3. Sauvegarde avec liens physiques
```bash
# Sauvegarde efficace (même contenu, pas de duplication)
ln fichier_important.txt sauvegarde/fichier_important.txt

# Modification du contenu : visible dans les deux "fichiers"
echo "Nouvelle ligne" >> fichier_important.txt
cat sauvegarde/fichier_important.txt  # Contient aussi la nouvelle ligne
```

## Différences importantes

### Liens symboliques vs liens physiques

| Aspect | Lien symbolique | Lien physique |
|--------|-----------------|---------------|
| **Type** | Fichier spécial | Nom supplémentaire |
| **Inode** | Différent | Identique |
| **Systèmes de fichiers** | Peut traverser | Limité à un seul |
| **Cible supprimée** | Lien cassé | Toujours valide |
| **Répertoires** | Possible | Impossible |
| **Espace disque** | Quelques octets | Aucun (shared) |

### Comportement avec les commandes

```bash
# Suppression de la cible
rm fichier_original

# Lien symbolique : devient cassé
ls -la lien_sym
lrwxrwxrwx 1 john john 15 Jan 15 10:30 lien_sym -> fichier_original (en rouge)

# Lien physique : toujours fonctionnel
cat lien_hard  # Affiche toujours le contenu
```

## Commandes utiles pour explorer les types

### Identifier le type d'un élément
```bash
# Avec ls -l (première colonne)
ls -l fichier
-rw-r--r-- 1 john john 1024 Jan 15 10:30 fichier

# Avec file (plus détaillé)
file fichier
# fichier: ASCII text

file /dev/null
# /dev/null: character special (1/3)
```

### Explorer les périphériques
```bash
# Lister les périphériques
ls -la /dev/ | head -20

# Périphériques de stockage
ls -la /dev/sd*  # SATA/SCSI disks
ls -la /dev/hd*  # IDE disks (ancien)
```

### Analyser les inodes
```bash
# Afficher les numéros d'inodes
ls -li

# Informations détaillées sur un fichier
stat fichier.txt
```

## Points clés à retenir

- **Types principaux** : `-` fichier, `d` répertoire, `l` lien symbolique
- **Périphériques** : `c` caractère, `b` bloc
- **Lien symbolique** : raccourci vers un autre fichier/répertoire
- **Lien physique** : nom supplémentaire pour le même contenu
- **`ln -s`** pour liens symboliques, **`ln`** pour liens physiques
- **Liens cassés** quand la cible est supprimée (seulement symboliques)
- **`file`** pour identifier le type de contenu
- **`stat`** pour informations détaillées sur un fichier

## Exercices pratiques

### Exercice 1 : Explorer les types
```bash
# Explorer /dev et identifier les types
ls -la /dev/ | head -10
# Identifier : caractères, blocs, liens

# Explorer votre home
ls -la ~ | grep "^l"  # Liens symboliques existants
```

### Exercice 2 : Créer des liens
```bash
# Créer un fichier test
echo "Contenu test" > original.txt

# Créer les deux types de liens
ln -s original.txt lien_symbolique.txt
ln original.txt lien_physique.txt

# Comparer
ls -li *.txt
```

### Exercice 3 : Test de suppression
```bash
# Supprimer l'original
rm original.txt

# Tester les liens
cat lien_symbolique.txt  # Erreur
cat lien_physique.txt    # Fonctionne encore
```