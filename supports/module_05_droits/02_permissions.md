# Module 5.2 : Permissions et controle d'acces

## Objectifs d'apprentissage
- Comprendre le systeme de permissions Linux
- Utiliser chmod pour modifier les permissions
- Utiliser chown et chgrp pour changer la propriete
- Interpreter les permissions en octal et symbolique
- Gerer les permissions speciales (sticky bit, SUID, SGID)

## Introduction

Le systeme de permissions Linux controle qui peut acceder a quoi et comment. Chaque fichier et repertoire a trois niveaux de permissions pour trois types d'acteurs differents.

---

## 1. Anatomie des permissions

### Affichage des permissions avec `ls -l`
```bash
ls -l exemple.txt
-rw-r--r-- 1 alice users 1234 dec 25 10:00 exemple.txt
|||||||||  | |     |     |    |           |
|||||||||  | |     |     |    +- Date     +- Nom
|||||||||  | |     |     +- Taille
|||||||||  | +- Proprietaire
|||||||||  +- Nombre de liens
|+++++++- Permissions du groupe
| ++++++- Permissions du proprietaire  
+--+++++- Type de fichier et permissions autres
```

### Structure des permissions (9 caracteres)
```
rwx | rwx | rwx
|   | |   | |   
|   | |   | +--- Autres (others) - tous les autres utilisateurs
|   | +--------- Groupe (group) - membres du groupe proprietaire
|   +----------- Proprietaire (user/owner) - proprietaire du fichier
+--------------- Type de fichier (-, d, l, etc.)
```

### Types de permissions
- **r (read)** = 4 : droit de lecture
- **w (write)** = 2 : droit d'ecriture  
- **x (execute)** = 1 : droit d'execution

---

## 2. Permissions sur les fichiers vs repertoires

### Sur les fichiers

#### Lecture (r)
```bash
# Permet de lire le contenu du fichier
cat fichier.txt
less fichier.txt
head fichier.txt
```

#### Ecriture (w)  
```bash
# Permet de modifier le contenu du fichier
echo "nouveau contenu" > fichier.txt
nano fichier.txt
```

#### Execution (x)
```bash
# Permet d'executer le fichier (script, programme)
./script.sh
./programme
```

### Sur les repertoires

#### Lecture (r)
```bash
# Permet de lister le contenu du repertoire
ls repertoire/
ls -l repertoire/
```

#### Ecriture (w)
```bash
# Permet de creer/supprimer des fichiers dans le repertoire
touch repertoire/nouveau_fichier.txt
rm repertoire/fichier_existant.txt
mkdir repertoire/sous_dossier
```

#### Execution (x)
```bash
# Permet de traverser le repertoire (cd dedans)
cd repertoire/
# Necessaire pour acceder aux fichiers du repertoire
cat repertoire/fichier.txt
```

### Cas particuliers sur repertoires
```bash
# r-- : peut lister mais pas entrer
ls dossier/        # [OK] marche
cd dossier/        # [NOK] Permission denied

# --x : peut entrer mais pas lister
ls dossier/        # [NOK] Permission denied  
cd dossier/        # [OK] marche
cat dossier/file   # [OK] marche si on connait le nom

# r-x : lecture normale du repertoire
ls dossier/        # [OK] marche
cd dossier/        # [OK] marche
```

---

## 3. Notation octale des permissions

### Conversion binaire -> octal
```
rwx = 1112 = 78
rw- = 1102 = 68  
r-x = 1012 = 58
r-- = 1002 = 48
-wx = 0112 = 38
-w- = 0102 = 28
--x = 0012 = 18
--- = 0002 = 08
```

### Permissions courantes en octal
```bash
# Fichiers courants
644 = rw-r--r--  # Fichier normal (lecture pour tous, ecriture pour le proprietaire)
755 = rwxr-xr-x  # Script executable
600 = rw-------  # Fichier prive (seul le proprietaire peut le lire/ecrire)
666 = rw-rw-rw-  # Fichier partage en ecriture (rare et dangereux)

# Repertoires courants  
755 = rwxr-xr-x  # Repertoire normal
750 = rwxr-x---  # Repertoire de groupe
700 = rwx------  # Repertoire prive
777 = rwxrwxrwx  # Repertoire totalement ouvert (dangereux)
```

### Calcul pratique
```
Proprietaire : rwx = 4+2+1 = 7
Groupe       : r-x = 4+0+1 = 5  
Autres       : r-- = 4+0+0 = 4
Resultat     : 754
```

---

## 4. Commande chmod - Modifier les permissions

### Syntaxe generale
```bash
chmod [options] permissions fichier(s)
```

### Mode octal
```bash
# Definir les permissions absolues
chmod 644 fichier.txt     # rw-r--r--
chmod 755 script.sh       # rwxr-xr-x
chmod 700 repertoire/     # rwx------

# Appliquer recursivement sur un repertoire
chmod -R 755 dossier/
```

### Mode symbolique

#### Acteurs (qui)
- **u** : user (proprietaire)
- **g** : group (groupe)  
- **o** : others (autres)
- **a** : all (tous) = u+g+o

#### Operations (quoi)
- **+** : ajouter permission
- **-** : retirer permission
- **=** : definir exactement ces permissions

#### Permissions (comment)
- **r** : read (lecture)
- **w** : write (ecriture)
- **x** : execute (execution)

### Exemples mode symbolique
```bash
# Ajouter permission d'execution au proprietaire
chmod u+x script.sh

# Retirer permission d'ecriture au groupe et autres
chmod go-w fichier.txt

# Donner tous les droits au proprietaire seulement
chmod u=rwx,go= fichier_prive.txt

# Ajouter lecture a tous
chmod a+r document.txt

# Permissions complexes
chmod u+rw,g+r,o-rwx fichier.txt
```

### Options utiles de chmod
```bash
# Recursif (repertoires et sous-repertoires)
chmod -R 755 /var/www/

# Verbose (afficher les changements)
chmod -v 644 *.txt

# Preserver les liens symboliques
chmod -h 755 lien_symbolique

# Mode reference (copier les permissions d'un autre fichier)
chmod --reference=fichier1.txt fichier2.txt
```

---

## 5. Commandes chown et chgrp - Changer la propriete

### chown - Changer le proprietaire

#### Syntaxe
```bash
chown [options] [proprietaire][:groupe] fichier(s)
```

#### Exemples
```bash
# Changer seulement le proprietaire
sudo chown alice fichier.txt

# Changer proprietaire et groupe
sudo chown alice:users fichier.txt

# Changer seulement le groupe (avec :)
sudo chown :www-data index.html

# Recursif sur un repertoire
sudo chown -R alice:alice /home/alice/

# Copier la propriete d'un autre fichier
sudo chown --reference=fichier1.txt fichier2.txt
```

### chgrp - Changer seulement le groupe
```bash
# Changer le groupe
sudo chgrp users fichier.txt

# Recursif
sudo chgrp -R www-data /var/www/

# Avec affichage des changements
sudo chgrp -v apache *.html
```

### Options communes chown/chgrp
```bash
# -R : recursif
# -v : verbose (afficher les changements)
# -c : afficher seulement quand il y a changement
# --reference=FILE : copier depuis un autre fichier
# -h : ne pas suivre les liens symboliques
```

---

## 6. Permissions speciales

### SUID (Set User ID) - bit 4000

#### Principe
Quand un fichier avec SUID est execute, il s'execute avec les droits du proprietaire du fichier, pas de l'utilisateur qui le lance.

#### Exemples systeme
```bash
# passwd permet de changer son mot de passe
ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root 68208 jul 14 22:36 /usr/bin/passwd
#   ^
#   s = SUID bit active

# ping necessite les droits root pour creer des sockets
ls -l /bin/ping  
-rwsr-xr-x 1 root root 64424 jun 28 19:56 /bin/ping
```

#### Definir SUID
```bash
# Mode octal (4000 + permissions normales)
chmod 4755 programme

# Mode symbolique
chmod u+s programme

# Verification : s remplace x dans les permissions proprietaire
ls -l programme
-rwsr-xr-x 1 alice users 12345 dec 25 10:00 programme
```

### SGID (Set Group ID) - bit 2000

#### Sur les fichiers
Le processus s'execute avec les droits du groupe proprietaire du fichier.

#### Sur les repertoires (plus courant)
Tous les nouveaux fichiers crees dans ce repertoire heritent du groupe du repertoire.

```bash
# Creer un repertoire de projet partage
sudo mkdir /projet
sudo chgrp developers /projet
sudo chmod 2775 /projet

# Verification
ls -ld /projet
drwxrwsr-x 2 root developers 4096 dec 25 10:00 /projet
#      ^
#      s = SGID bit active

# Test : tous les fichiers crees seront du groupe developers
cd /projet
touch fichier_test.txt
ls -l fichier_test.txt
-rw-rw-r-- 1 alice developers 0 dec 25 10:01 fichier_test.txt
#                  ^
#                  automatiquement groupe 'developers'
```

#### Definir SGID
```bash
# Mode octal (2000 + permissions normales)
chmod 2775 repertoire/

# Mode symbolique  
chmod g+s repertoire/
```

### Sticky Bit - bit 1000

#### Principe
Sur un repertoire avec sticky bit, seul le proprietaire d'un fichier (ou root) peut supprimer ce fichier, meme si d'autres ont les droits d'ecriture sur le repertoire.

#### Exemple : /tmp
```bash
# Le repertoire /tmp utilise le sticky bit
ls -ld /tmp
drwxrwxrwt 15 root root 4096 dec 25 10:00 /tmp
#        ^
#        t = sticky bit active

# Chacun peut creer des fichiers, mais seulement le proprietaire peut les supprimer
```

#### Definir sticky bit
```bash
# Mode octal (1000 + permissions normales)  
chmod 1777 repertoire_partage/

# Mode symbolique
chmod +t repertoire_partage/

# Verification
ls -ld repertoire_partage/
drwxrwxrwt 2 root root 4096 dec 25 10:00 repertoire_partage/
```

### Combinaisons des bits speciaux
```bash
# Tous les bits speciaux
chmod 7755 fichier    # SUID + SGID + Sticky + rwxr-xr-x

# Affichage quand x n'est pas defini  
chmod 4644 fichier    # SUID sans execution
ls -l fichier
-rwSr--r-- 1 alice users 0 dec 25 10:00 fichier
# ^
# S majuscule = SUID defini mais pas d'execution
```

---

## 7. Cas pratiques et scenarios

### Scenario 1 : Site web partage
```bash
# Creer un repertoire pour un site web gere par plusieurs developpeurs
sudo mkdir /var/www/project
sudo chgrp webdev /var/www/project
sudo chmod 2775 /var/www/project

# Tous les fichiers crees seront du groupe webdev
# Tous les developpeurs du groupe peuvent modifier
```

### Scenario 2 : Script d'administration
```bash
# Script qui doit etre executable par tous mais modifiable seulement par root
sudo chmod 755 /usr/local/bin/backup_script.sh
sudo chown root:root /usr/local/bin/backup_script.sh
```

### Scenario 3 : Repertoire de depot temporaire
```bash
# Creer un repertoire ou chacun peut deposer des fichiers
# mais ne peut supprimer que ses propres fichiers
sudo mkdir /shared/drop
sudo chmod 1777 /shared/drop
```

### Scenario 4 : Fichiers de configuration sensibles
```bash
# Fichier de configuration accessible seulement par le service
sudo chown mysql:mysql /etc/mysql/my.cnf
sudo chmod 640 /etc/mysql/my.cnf
# Proprietaire mysql : lecture + ecriture  
# Groupe mysql : lecture seulement
# Autres : aucun acces
```

---

## 8. Outils de diagnostic des permissions

### umask - Masque de creation par defaut
```bash
# Voir l'umask courant
umask
# Sortie : 0022 (octal)

# Conversion : permissions par defaut = 777 - umask pour repertoires
#                                    = 666 - umask pour fichiers

# Avec umask 022 :
# Repertoires : 777 - 022 = 755 (rwxr-xr-x)
# Fichiers    : 666 - 022 = 644 (rw-r--r--)

# Changer l'umask temporairement
umask 027  # Plus restrictif

# Permanent : dans ~/.bashrc
echo "umask 027" >> ~/.bashrc
```

### Diagnostic des problemes de permissions
```bash
# Verifier les permissions d'un chemin complet
namei -l /var/www/html/index.php

# Exemple de sortie :
# f: /var/www/html/index.php
# drwxr-xr-x root root /
# drwxr-xr-x root root var  
# drwxr-xr-x root root www
# drwxr-xr-x www-data www-data html
# -rw-r--r-- www-data www-data index.php
```

### find avec tests de permissions
```bash
# Trouver les fichiers avec permissions particulieres
find /home -perm 777                    # Permissions exactes
find /var -perm -u+s                    # Fichiers avec SUID
find /tmp -perm /o+w                    # Fichiers ecriture pour others

# Fichiers avec permissions dangereuses
find /home -type f -perm -o+w ! -perm /o+t  # Ecriture others sans sticky bit

# Fichiers sans proprietaire
find /var -nouser -o -nogroup
```

---

## 9. ACL - Listes de controle d'acces (avance)

### Introduction aux ACL
Les permissions traditionnelles (rwx pour user/group/others) sont parfois limitantes. Les ACL permettent de definir des permissions plus granulaires.

### Verifier le support ACL
```bash
# Verifier si le systeme de fichiers supporte les ACL
mount | grep acl

# Installer les outils ACL (si necessaire)
sudo apt install acl        # Debian/Ubuntu
sudo yum install acl        # CentOS/RHEL
```

### Commandes de base ACL
```bash
# Voir les ACL d'un fichier
getfacl fichier.txt

# Definir une ACL (donner lecture a alice)
setfacl -m u:alice:r-- fichier.txt

# Donner rwx a un groupe specifique
setfacl -m g:developers:rwx repertoire/

# ACL par defaut pour un repertoire (heritage)
setfacl -d -m g:developers:rwx repertoire/

# Supprimer une ACL
setfacl -x u:alice fichier.txt

# Supprimer toutes les ACL
setfacl -b fichier.txt
```

### Exemple d'ACL en pratique
```bash
# Creer un projet avec ACL complexes
mkdir projet_special
setfacl -m u:alice:rwx projet_special/      # Alice : acces total
setfacl -m u:bob:r-x projet_special/        # Bob : lecture + parcours
setfacl -m g:managers:rwx projet_special/   # Groupe managers : acces total

# Definir les ACL par defaut (heritage)
setfacl -d -m u:alice:rwx projet_special/
setfacl -d -m g:managers:rwx projet_special/

# Verifier
getfacl projet_special/
```

---

## 10. Securite et bonnes pratiques

### Principe du moindre privilege
```bash
# Toujours donner le minimum de permissions necessaires

# [NOK] Mauvais : trop permissif
chmod 777 fichier.txt

# [OK] Bon : juste ce qu'il faut
chmod 644 fichier.txt     # Lecture pour tous, ecriture pour le proprietaire
```

### Permissions sur repertoires
```bash
# Structure web typique
/var/www/html/
+-- index.html (644)      # Lecture pour tous
+-- images/ (755)         # Traversable et listable  
+-- config/ (750)         # Acces limite au groupe
+-- admin/ (700)          # Prive au proprietaire
```

### Audit regulier
```bash
# Script de verification des permissions dangereuses
#!/bin/bash
echo "=== Fichiers world-writable ==="
find /home -type f -perm -o+w

echo "=== Fichiers avec SUID ==="  
find /usr -type f -perm -u+s

echo "=== Repertoires sans sticky bit mais world-writable ==="
find /tmp -type d -perm -o+w ! -perm /o+t
```

### Fichiers sensibles a proteger
```bash
# Fichiers de mots de passe
sudo chmod 600 ~/.ssh/id_rsa              # Cle SSH privee
sudo chmod 600 /etc/shadow                # Mots de passe systeme
sudo chmod 600 ~/.netrc                   # Credentials reseau

# Fichiers de configuration  
sudo chmod 644 ~/.bashrc                  # Configuration shell
sudo chmod 640 /etc/mysql/my.cnf          # Config base donnees
```

---

## Resume

### Commandes essentielles
```bash
ls -l              # Voir les permissions
chmod 755 file     # Modifier permissions (octal)
chmod u+x file     # Modifier permissions (symbolique)
chown user file    # Changer proprietaire
chgrp group file   # Changer groupe
chown user:group file  # Changer proprietaire et groupe
umask              # Voir masque de creation par defaut
```

### Permissions courantes
```bash
# Fichiers
644 (rw-r--r--)    # Fichier normal
755 (rwxr-xr-x)    # Script executable
600 (rw-------)    # Fichier prive

# Repertoires  
755 (rwxr-xr-x)    # Repertoire normal
750 (rwxr-x---)    # Repertoire de groupe
700 (rwx------)    # Repertoire prive
1777 (rwxrwxrwt)   # Repertoire temporaire (/tmp)
```

### Bits speciaux
- **SUID (4000)** : execution avec droits du proprietaire
- **SGID (2000)** : heritage de groupe sur repertoires
- **Sticky (1000)** : protection contre suppression dans /tmp

### Principe de securite
- **Moindre privilege** : donner seulement les permissions necessaires
- **Audit regulier** : verifier les permissions sensibles
- **Protection des fichiers critiques** : SSH keys, passwords, config

---

**Temps de lecture estime** : 30-35 minutes
**Niveau** : Intermediaire  
**Pre-requis** : Module 5.1 (Utilisateurs et groupes)