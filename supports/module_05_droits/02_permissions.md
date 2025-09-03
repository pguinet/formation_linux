# Module 5.2 : Permissions et contrôle d'accès

## Objectifs d'apprentissage
- Comprendre le système de permissions Linux
- Utiliser chmod pour modifier les permissions
- Utiliser chown et chgrp pour changer la propriété
- Interpréter les permissions en octal et symbolique
- Gérer les permissions spéciales (sticky bit, SUID, SGID)

## Introduction

Le système de permissions Linux contrôle qui peut accéder à quoi et comment. Chaque fichier et répertoire a trois niveaux de permissions pour trois types d'acteurs différents.

---

## 1. Anatomie des permissions

### Affichage des permissions avec `ls -l`
```bash
ls -l exemple.txt
-rw-r--r-- 1 alice users 1234 déc 25 10:00 exemple.txt
│││││││││  │ │     │     │    │           │
│││││││││  │ │     │     │    └─ Date     └─ Nom
│││││││││  │ │     │     └─ Taille
│││││││││  │ └─ Propriétaire
│││││││││  └─ Nombre de liens
│└┼┼┼┼┼┼─ Permissions du groupe
│ └┼┼┼┼┼─ Permissions du propriétaire  
└──┴┴┴┴┴─ Type de fichier et permissions autres
```

### Structure des permissions (9 caractères)
```
rwx | rwx | rwx
│   │ │   │ │   
│   │ │   │ └─── Autres (others) - tous les autres utilisateurs
│   │ └───────── Groupe (group) - membres du groupe propriétaire
│   └─────────── Propriétaire (user/owner) - propriétaire du fichier
└─────────────── Type de fichier (-, d, l, etc.)
```

### Types de permissions
- **r (read)** = 4 : droit de lecture
- **w (write)** = 2 : droit d'écriture  
- **x (execute)** = 1 : droit d'exécution

---

## 2. Permissions sur les fichiers vs répertoires

### Sur les fichiers

#### Lecture (r)
```bash
# Permet de lire le contenu du fichier
cat fichier.txt
less fichier.txt
head fichier.txt
```

#### Écriture (w)  
```bash
# Permet de modifier le contenu du fichier
echo "nouveau contenu" > fichier.txt
nano fichier.txt
```

#### Exécution (x)
```bash
# Permet d'exécuter le fichier (script, programme)
./script.sh
./programme
```

### Sur les répertoires

#### Lecture (r)
```bash
# Permet de lister le contenu du répertoire
ls repertoire/
ls -l repertoire/
```

#### Écriture (w)
```bash
# Permet de créer/supprimer des fichiers dans le répertoire
touch repertoire/nouveau_fichier.txt
rm repertoire/fichier_existant.txt
mkdir repertoire/sous_dossier
```

#### Exécution (x)
```bash
# Permet de traverser le répertoire (cd dedans)
cd repertoire/
# Nécessaire pour accéder aux fichiers du répertoire
cat repertoire/fichier.txt
```

### Cas particuliers sur répertoires
```bash
# r-- : peut lister mais pas entrer
ls dossier/        # ✓ marche
cd dossier/        # ✗ Permission denied

# --x : peut entrer mais pas lister
ls dossier/        # ✗ Permission denied  
cd dossier/        # ✓ marche
cat dossier/file   # ✓ marche si on connaît le nom

# r-x : lecture normale du répertoire
ls dossier/        # ✓ marche
cd dossier/        # ✓ marche
```

---

## 3. Notation octale des permissions

### Conversion binaire → octal
```
rwx = 111₂ = 7₈
rw- = 110₂ = 6₈  
r-x = 101₂ = 5₈
r-- = 100₂ = 4₈
-wx = 011₂ = 3₈
-w- = 010₂ = 2₈
--x = 001₂ = 1₈
--- = 000₂ = 0₈
```

### Permissions courantes en octal
```bash
# Fichiers courants
644 = rw-r--r--  # Fichier normal (lecture pour tous, écriture pour le propriétaire)
755 = rwxr-xr-x  # Script exécutable
600 = rw-------  # Fichier privé (seul le propriétaire peut le lire/écrire)
666 = rw-rw-rw-  # Fichier partagé en écriture (rare et dangereux)

# Répertoires courants  
755 = rwxr-xr-x  # Répertoire normal
750 = rwxr-x---  # Répertoire de groupe
700 = rwx------  # Répertoire privé
777 = rwxrwxrwx  # Répertoire totalement ouvert (dangereux)
```

### Calcul pratique
```
Propriétaire : rwx = 4+2+1 = 7
Groupe       : r-x = 4+0+1 = 5  
Autres       : r-- = 4+0+0 = 4
Résultat     : 754
```

---

## 4. Commande chmod - Modifier les permissions

### Syntaxe générale
```bash
chmod [options] permissions fichier(s)
```

### Mode octal
```bash
# Définir les permissions absolues
chmod 644 fichier.txt     # rw-r--r--
chmod 755 script.sh       # rwxr-xr-x
chmod 700 repertoire/     # rwx------

# Appliquer récursivement sur un répertoire
chmod -R 755 dossier/
```

### Mode symbolique

#### Acteurs (qui)
- **u** : user (propriétaire)
- **g** : group (groupe)  
- **o** : others (autres)
- **a** : all (tous) = u+g+o

#### Opérations (quoi)
- **+** : ajouter permission
- **-** : retirer permission
- **=** : définir exactement ces permissions

#### Permissions (comment)
- **r** : read (lecture)
- **w** : write (écriture)
- **x** : execute (exécution)

### Exemples mode symbolique
```bash
# Ajouter permission d'exécution au propriétaire
chmod u+x script.sh

# Retirer permission d'écriture au groupe et autres
chmod go-w fichier.txt

# Donner tous les droits au propriétaire seulement
chmod u=rwx,go= fichier_prive.txt

# Ajouter lecture à tous
chmod a+r document.txt

# Permissions complexes
chmod u+rw,g+r,o-rwx fichier.txt
```

### Options utiles de chmod
```bash
# Récursif (répertoires et sous-répertoires)
chmod -R 755 /var/www/

# Verbose (afficher les changements)
chmod -v 644 *.txt

# Préserver les liens symboliques
chmod -h 755 lien_symbolique

# Mode référence (copier les permissions d'un autre fichier)
chmod --reference=fichier1.txt fichier2.txt
```

---

## 5. Commandes chown et chgrp - Changer la propriété

### chown - Changer le propriétaire

#### Syntaxe
```bash
chown [options] [propriétaire][:groupe] fichier(s)
```

#### Exemples
```bash
# Changer seulement le propriétaire
sudo chown alice fichier.txt

# Changer propriétaire et groupe
sudo chown alice:users fichier.txt

# Changer seulement le groupe (avec :)
sudo chown :www-data index.html

# Récursif sur un répertoire
sudo chown -R alice:alice /home/alice/

# Copier la propriété d'un autre fichier
sudo chown --reference=fichier1.txt fichier2.txt
```

### chgrp - Changer seulement le groupe
```bash
# Changer le groupe
sudo chgrp users fichier.txt

# Récursif
sudo chgrp -R www-data /var/www/

# Avec affichage des changements
sudo chgrp -v apache *.html
```

### Options communes chown/chgrp
```bash
# -R : récursif
# -v : verbose (afficher les changements)
# -c : afficher seulement quand il y a changement
# --reference=FILE : copier depuis un autre fichier
# -h : ne pas suivre les liens symboliques
```

---

## 6. Permissions spéciales

### SUID (Set User ID) - bit 4000

#### Principe
Quand un fichier avec SUID est exécuté, il s'exécute avec les droits du propriétaire du fichier, pas de l'utilisateur qui le lance.

#### Exemples système
```bash
# passwd permet de changer son mot de passe
ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root 68208 jul 14 22:36 /usr/bin/passwd
#   ↑
#   s = SUID bit activé

# ping nécessite les droits root pour créer des sockets
ls -l /bin/ping  
-rwsr-xr-x 1 root root 64424 jun 28 19:56 /bin/ping
```

#### Définir SUID
```bash
# Mode octal (4000 + permissions normales)
chmod 4755 programme

# Mode symbolique
chmod u+s programme

# Vérification : s remplace x dans les permissions propriétaire
ls -l programme
-rwsr-xr-x 1 alice users 12345 déc 25 10:00 programme
```

### SGID (Set Group ID) - bit 2000

#### Sur les fichiers
Le processus s'exécute avec les droits du groupe propriétaire du fichier.

#### Sur les répertoires (plus courant)
Tous les nouveaux fichiers créés dans ce répertoire héritent du groupe du répertoire.

```bash
# Créer un répertoire de projet partagé
sudo mkdir /projet
sudo chgrp developers /projet
sudo chmod 2775 /projet

# Vérification
ls -ld /projet
drwxrwsr-x 2 root developers 4096 déc 25 10:00 /projet
#      ↑
#      s = SGID bit activé

# Test : tous les fichiers créés seront du groupe developers
cd /projet
touch fichier_test.txt
ls -l fichier_test.txt
-rw-rw-r-- 1 alice developers 0 déc 25 10:01 fichier_test.txt
#                  ↑
#                  automatiquement groupe 'developers'
```

#### Définir SGID
```bash
# Mode octal (2000 + permissions normales)
chmod 2775 repertoire/

# Mode symbolique  
chmod g+s repertoire/
```

### Sticky Bit - bit 1000

#### Principe
Sur un répertoire avec sticky bit, seul le propriétaire d'un fichier (ou root) peut supprimer ce fichier, même si d'autres ont les droits d'écriture sur le répertoire.

#### Exemple : /tmp
```bash
# Le répertoire /tmp utilise le sticky bit
ls -ld /tmp
drwxrwxrwt 15 root root 4096 déc 25 10:00 /tmp
#        ↑
#        t = sticky bit activé

# Chacun peut créer des fichiers, mais seulement le propriétaire peut les supprimer
```

#### Définir sticky bit
```bash
# Mode octal (1000 + permissions normales)  
chmod 1777 repertoire_partage/

# Mode symbolique
chmod +t repertoire_partage/

# Vérification
ls -ld repertoire_partage/
drwxrwxrwt 2 root root 4096 déc 25 10:00 repertoire_partage/
```

### Combinaisons des bits spéciaux
```bash
# Tous les bits spéciaux
chmod 7755 fichier    # SUID + SGID + Sticky + rwxr-xr-x

# Affichage quand x n'est pas défini  
chmod 4644 fichier    # SUID sans exécution
ls -l fichier
-rwSr--r-- 1 alice users 0 déc 25 10:00 fichier
# ↑
# S majuscule = SUID défini mais pas d'exécution
```

---

## 7. Cas pratiques et scénarios

### Scenario 1 : Site web partagé
```bash
# Créer un répertoire pour un site web géré par plusieurs développeurs
sudo mkdir /var/www/project
sudo chgrp webdev /var/www/project
sudo chmod 2775 /var/www/project

# Tous les fichiers créés seront du groupe webdev
# Tous les développeurs du groupe peuvent modifier
```

### Scenario 2 : Script d'administration
```bash
# Script qui doit être exécutable par tous mais modifiable seulement par root
sudo chmod 755 /usr/local/bin/backup_script.sh
sudo chown root:root /usr/local/bin/backup_script.sh
```

### Scenario 3 : Répertoire de dépôt temporaire
```bash
# Créer un répertoire où chacun peut déposer des fichiers
# mais ne peut supprimer que ses propres fichiers
sudo mkdir /shared/drop
sudo chmod 1777 /shared/drop
```

### Scenario 4 : Fichiers de configuration sensibles
```bash
# Fichier de configuration accessible seulement par le service
sudo chown mysql:mysql /etc/mysql/my.cnf
sudo chmod 640 /etc/mysql/my.cnf
# Propriétaire mysql : lecture + écriture  
# Groupe mysql : lecture seulement
# Autres : aucun accès
```

---

## 8. Outils de diagnostic des permissions

### umask - Masque de création par défaut
```bash
# Voir l'umask courant
umask
# Sortie : 0022 (octal)

# Conversion : permissions par défaut = 777 - umask pour répertoires
#                                    = 666 - umask pour fichiers

# Avec umask 022 :
# Répertoires : 777 - 022 = 755 (rwxr-xr-x)
# Fichiers    : 666 - 022 = 644 (rw-r--r--)

# Changer l'umask temporairement
umask 027  # Plus restrictif

# Permanent : dans ~/.bashrc
echo "umask 027" >> ~/.bashrc
```

### Diagnostic des problèmes de permissions
```bash
# Vérifier les permissions d'un chemin complet
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
# Trouver les fichiers avec permissions particulières
find /home -perm 777                    # Permissions exactes
find /var -perm -u+s                    # Fichiers avec SUID
find /tmp -perm /o+w                    # Fichiers écriture pour others

# Fichiers avec permissions dangereuses
find /home -type f -perm -o+w ! -perm /o+t  # Écriture others sans sticky bit

# Fichiers sans propriétaire
find /var -nouser -o -nogroup
```

---

## 9. ACL - Listes de contrôle d'accès (avancé)

### Introduction aux ACL
Les permissions traditionnelles (rwx pour user/group/others) sont parfois limitantes. Les ACL permettent de définir des permissions plus granulaires.

### Vérifier le support ACL
```bash
# Vérifier si le système de fichiers supporte les ACL
mount | grep acl

# Installer les outils ACL (si nécessaire)
sudo apt install acl        # Debian/Ubuntu
sudo yum install acl        # CentOS/RHEL
```

### Commandes de base ACL
```bash
# Voir les ACL d'un fichier
getfacl fichier.txt

# Définir une ACL (donner lecture à alice)
setfacl -m u:alice:r-- fichier.txt

# Donner rwx à un groupe spécifique
setfacl -m g:developers:rwx repertoire/

# ACL par défaut pour un répertoire (héritage)
setfacl -d -m g:developers:rwx repertoire/

# Supprimer une ACL
setfacl -x u:alice fichier.txt

# Supprimer toutes les ACL
setfacl -b fichier.txt
```

### Exemple d'ACL en pratique
```bash
# Créer un projet avec ACL complexes
mkdir projet_special
setfacl -m u:alice:rwx projet_special/      # Alice : accès total
setfacl -m u:bob:r-x projet_special/        # Bob : lecture + parcours
setfacl -m g:managers:rwx projet_special/   # Groupe managers : accès total

# Définir les ACL par défaut (héritage)
setfacl -d -m u:alice:rwx projet_special/
setfacl -d -m g:managers:rwx projet_special/

# Vérifier
getfacl projet_special/
```

---

## 10. Sécurité et bonnes pratiques

### Principe du moindre privilège
```bash
# Toujours donner le minimum de permissions nécessaires

# ✗ Mauvais : trop permissif
chmod 777 fichier.txt

# ✓ Bon : juste ce qu'il faut
chmod 644 fichier.txt     # Lecture pour tous, écriture pour le propriétaire
```

### Permissions sur répertoires
```bash
# Structure web typique
/var/www/html/
├── index.html (644)      # Lecture pour tous
├── images/ (755)         # Traversable et listable  
├── config/ (750)         # Accès limité au groupe
└── admin/ (700)          # Privé au propriétaire
```

### Audit régulier
```bash
# Script de vérification des permissions dangereuses
#!/bin/bash
echo "=== Fichiers world-writable ==="
find /home -type f -perm -o+w

echo "=== Fichiers avec SUID ==="  
find /usr -type f -perm -u+s

echo "=== Répertoires sans sticky bit mais world-writable ==="
find /tmp -type d -perm -o+w ! -perm /o+t
```

### Fichiers sensibles à protéger
```bash
# Fichiers de mots de passe
sudo chmod 600 ~/.ssh/id_rsa              # Clé SSH privée
sudo chmod 600 /etc/shadow                # Mots de passe système
sudo chmod 600 ~/.netrc                   # Credentials réseau

# Fichiers de configuration  
sudo chmod 644 ~/.bashrc                  # Configuration shell
sudo chmod 640 /etc/mysql/my.cnf          # Config base données
```

---

## Résumé

### Commandes essentielles
```bash
ls -l              # Voir les permissions
chmod 755 file     # Modifier permissions (octal)
chmod u+x file     # Modifier permissions (symbolique)
chown user file    # Changer propriétaire
chgrp group file   # Changer groupe
chown user:group file  # Changer propriétaire et groupe
umask              # Voir masque de création par défaut
```

### Permissions courantes
```bash
# Fichiers
644 (rw-r--r--)    # Fichier normal
755 (rwxr-xr-x)    # Script exécutable
600 (rw-------)    # Fichier privé

# Répertoires  
755 (rwxr-xr-x)    # Répertoire normal
750 (rwxr-x---)    # Répertoire de groupe
700 (rwx------)    # Répertoire privé
1777 (rwxrwxrwt)   # Répertoire temporaire (/tmp)
```

### Bits spéciaux
- **SUID (4000)** : exécution avec droits du propriétaire
- **SGID (2000)** : héritage de groupe sur répertoires
- **Sticky (1000)** : protection contre suppression dans /tmp

### Principe de sécurité
- **Moindre privilège** : donner seulement les permissions nécessaires
- **Audit régulier** : vérifier les permissions sensibles
- **Protection des fichiers critiques** : SSH keys, passwords, config

---

**Temps de lecture estimé** : 30-35 minutes
**Niveau** : Intermédiaire  
**Pré-requis** : Module 5.1 (Utilisateurs et groupes)