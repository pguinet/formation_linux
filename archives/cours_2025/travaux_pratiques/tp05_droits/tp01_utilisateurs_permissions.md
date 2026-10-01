# TP 5.1 : Gestion des utilisateurs et permissions

## Objectifs
- Créer et gérer des utilisateurs et groupes
- Configurer et modifier les permissions de fichiers
- Utiliser sudo de manière sécurisée
- Comprendre les implications sécuritaires

## Pré-requis
- Accès administrateur (sudo) sur le système
- Connaissances des modules précédents
- Terminal ouvert

## Durée estimée
- **Public accéléré** : 60 minutes
- **Public étalé** : 90 minutes

---

## Partie A : Gestion des utilisateurs et groupes

### Exercice 1 : Exploration de l'état actuel

#### Étape 1 : Identifier l'utilisateur courant
```bash
# 1. Votre identité
whoami
id

# 2. Vos groupes
groups

# 3. Utilisateurs du système
cat /etc/passwd | tail -10

# 4. Groupes disponibles
cat /etc/group | tail -10
```

**Questions** :
- Quel est votre UID ?
- À combien de groupes appartenez-vous ?
- Combien d'utilisateurs système (UID < 1000) voyez-vous ?

### Exercice 2 : Création d'utilisateurs de test

#### Étape 1 : Créer des utilisateurs
```bash
# Créer un répertoire de travail
sudo mkdir -p /tmp/tp_users
cd /tmp/tp_users

# Créer trois utilisateurs de test
sudo useradd -m -s /bin/bash alice
sudo useradd -m -s /bin/bash bob  
sudo useradd -m -s /bin/bash charlie

# Définir les mots de passe
sudo passwd alice     # Mot de passe : test123
sudo passwd bob       # Mot de passe : test123
sudo passwd charlie   # Mot de passe : test123
```

#### Étape 2 : Vérifier la création
```bash
# Vérifier dans /etc/passwd
tail -3 /etc/passwd

# Vérifier les répertoires home
ls -la /home/

# Tester la connexion d'alice
su - alice
whoami
exit
```

### Exercice 3 : Création et gestion de groupes

#### Étape 1 : Créer des groupes de travail
```bash
# Créer des groupes
sudo groupadd developers
sudo groupadd testers
sudo groupadd managers

# Vérifier la création
tail -3 /etc/group
getent group developers
```

#### Étape 2 : Assigner les utilisateurs aux groupes
```bash
# Ajouter alice au groupe developers
sudo usermod -aG developers alice

# Ajouter bob aux groupes developers et testers  
sudo usermod -aG developers,testers bob

# Ajouter charlie au groupe managers
sudo usermod -aG managers charlie

# Vérifier les assignations
groups alice
groups bob
groups charlie

# Voir les membres d'un groupe
getent group developers
```

---

## Partie B : Permissions de fichiers

### Exercice 4 : Comprendre les permissions de base

#### Étape 1 : Créer des fichiers de test
```bash
# Se placer dans un répertoire de travail
mkdir ~/tp_permissions
cd ~/tp_permissions

# Créer différents types de fichiers
touch fichier_normal.txt
echo "Contenu secret" > fichier_prive.txt
echo "#!/bin/bash\necho 'Hello World'" > script.sh

# Créer des répertoires
mkdir dossier_normal
mkdir dossier_prive
mkdir dossier_partage
```

#### Étape 2 : Examiner les permissions par défaut
```bash
# Voir les permissions
ls -la

# Comprendre umask
umask
# Calculer : 666 - umask = permissions par défaut des fichiers
# Calculer : 777 - umask = permissions par défaut des dossiers
```

**Questions** :
- Quelles sont les permissions par défaut de vos fichiers ?
- Quelles sont les permissions par défaut de vos dossiers ?
- Que signifie votre umask ?

### Exercice 5 : Modifier les permissions avec chmod

#### Étape 1 : Mode octal
```bash
# Rendre le script exécutable
chmod 755 script.sh
ls -l script.sh

# Fichier privé (lecture/écriture propriétaire seulement)
chmod 600 fichier_prive.txt
ls -l fichier_prive.txt

# Fichier lecture seule pour tous
chmod 644 fichier_normal.txt
ls -l fichier_normal.txt

# Tester l'exécution
./script.sh
```

#### Étape 2 : Mode symbolique
```bash
# Ajouter permission d'exécution au groupe
chmod g+x script.sh

# Retirer permission de lecture aux autres
chmod o-r fichier_normal.txt

# Donner tous les droits au propriétaire seulement
chmod u=rwx,go= dossier_prive

# Vérifier les résultats
ls -la
```

### Exercice 6 : Permissions sur répertoires

#### Étape 1 : Comprendre rwx sur répertoires
```bash
# Créer des fichiers dans les répertoires
echo "Contenu public" > dossier_normal/public.txt
echo "Contenu privé" > dossier_prive/prive.txt
echo "Contenu partagé" > dossier_partage/partage.txt

# Tester différentes permissions sur dossier_partage
chmod 755 dossier_partage  # rwxr-xr-x
ls dossier_partage/        # Devrait marcher
cd dossier_partage/        # Devrait marcher
cd ..

chmod 644 dossier_partage  # rw-r--r--  
ls dossier_partage/        # Devrait marcher
cd dossier_partage/        # Devrait échouer (pas d'x)
```

**Expériences** :
```bash
# Test 1 : r-- (lecture sans exécution)
chmod 644 dossier_partage
ls dossier_partage/        # Résultat ?
cd dossier_partage/        # Résultat ?

# Test 2 : --x (exécution sans lecture)
chmod 111 dossier_partage
ls dossier_partage/        # Résultat ?
cd dossier_partage/ && pwd && cd ..  # Résultat ?

# Test 3 : -wx (écriture + exécution)
chmod 311 dossier_partage
cd dossier_partage/
echo "nouveau" > nouveau.txt  # Résultat ?
ls                         # Résultat ?
cd ..

# Remettre permissions normales
chmod 755 dossier_partage
```

---

## Partie C : Changement de propriété

### Exercice 7 : chown et chgrp

#### Étape 1 : Changer le propriétaire
```bash
# Créer un fichier pour les tests
echo "Test propriété" > test_propriete.txt
ls -l test_propriete.txt

# Changer le propriétaire (nécessite sudo)
sudo chown alice test_propriete.txt
ls -l test_propriete.txt

# Changer propriétaire et groupe
sudo chown bob:developers test_propriete.txt  
ls -l test_propriete.txt

# Changer seulement le groupe
sudo chgrp testers test_propriete.txt
ls -l test_propriete.txt
```

#### Étape 2 : Permissions et propriété
```bash
# Test d'accès avec différents utilisateurs
echo "Contenu original" > test_acces.txt

# Donner à alice avec permissions restrictives
sudo chown alice:alice test_acces.txt
chmod 600 test_acces.txt

# Tester l'accès
cat test_acces.txt         # Vous (propriétaire original) ?
sudo -u alice cat test_acces.txt  # Alice (nouveau propriétaire) ?
sudo -u bob cat test_acces.txt    # Bob (autre utilisateur) ?
```

---

## Partie D : Configuration et utilisation de sudo

### Exercice 8 : Configuration de base de sudo

#### Étape 1 : Examiner la configuration actuelle
```bash
# Voir vos permissions sudo
sudo -l

# Examiner le fichier sudoers (REGARDER SEULEMENT)
sudo cat /etc/sudoers

# Voir les fichiers de configuration modulaires
sudo ls -la /etc/sudoers.d/
```

#### Étape 2 : Créer une configuration personnalisée
```bash
# Créer une règle pour alice (accès limité)
sudo visudo -f /etc/sudoers.d/alice-config

# Dans l'éditeur, ajouter :
alice ALL=(ALL) /usr/bin/systemctl status *
alice ALL=(ALL) /bin/cat /var/log/*
alice ALL=(ALL) NOPASSWD: /usr/bin/whoami

# Sauvegarder et quitter (Ctrl+X, Y, Enter si nano)
```

#### Étape 3 : Tester la configuration
```bash
# Tester avec alice
sudo -u alice sudo -l

# Tester les commandes autorisées
sudo -u alice sudo systemctl status ssh
sudo -u alice sudo whoami
sudo -u alice sudo cat /var/log/auth.log | tail -5

# Tester une commande non autorisée
sudo -u alice sudo apt update  # Devrait échouer
```

### Exercice 9 : Gestion de groupes avec sudo

#### Étape 1 : Configuration par groupe
```bash
# Créer une configuration pour le groupe developers
sudo visudo -f /etc/sudoers.d/developers-config

# Dans l'éditeur, ajouter :
%developers ALL=(www-data) NOPASSWD: /usr/bin/php
%developers ALL=(ALL) /usr/bin/systemctl restart nginx
%developers ALL=(ALL) /bin/chown * /var/www/*
```

#### Étape 2 : Tester les permissions de groupe
```bash
# Vérifier qu'alice est dans developers
groups alice

# Tester avec alice (membre de developers)
sudo -u alice sudo -l

# Créer un test
sudo mkdir -p /var/www/test
echo "<?php echo 'Hello from PHP'; ?>" | sudo tee /var/www/test/test.php

# Tester les commandes autorisées au groupe
sudo -u alice sudo -u www-data php -r "echo 'Test PHP OK\n';"
```

---

## Partie E : Permissions spéciales

### Exercice 10 : SUID, SGID, et Sticky Bit

#### Étape 1 : Créer un répertoire de projet partagé
```bash
# Créer un répertoire pour projet collaboratif
sudo mkdir /tmp/projet_equipe
sudo chgrp developers /tmp/projet_equipe

# Appliquer SGID (héritage de groupe)
sudo chmod 2775 /tmp/projet_equipe
ls -ld /tmp/projet_equipe

# Tester l'héritage
sudo -u alice touch /tmp/projet_equipe/fichier_alice.txt
sudo -u bob touch /tmp/projet_equipe/fichier_bob.txt
ls -l /tmp/projet_equipe/

# Vérifier que les fichiers ont le bon groupe
```

#### Étape 2 : Créer un répertoire avec sticky bit
```bash
# Créer un répertoire temporaire partagé
sudo mkdir /tmp/partage_temporaire
sudo chmod 1777 /tmp/partage_temporaire
ls -ld /tmp/partage_temporaire

# Test du sticky bit
sudo -u alice touch /tmp/partage_temporaire/fichier_alice.txt
sudo -u bob touch /tmp/partage_temporaire/fichier_bob.txt

# Alice peut-elle supprimer le fichier de bob ?
sudo -u alice rm /tmp/partage_temporaire/fichier_bob.txt  # Devrait échouer

# Bob peut-il supprimer son propre fichier ?
sudo -u bob rm /tmp/partage_temporaire/fichier_bob.txt    # Devrait marcher
```

---

## Partie F : Surveillance et audit

### Exercice 11 : Surveiller l'utilisation des permissions

#### Étape 1 : Logs de sudo
```bash
# Voir les logs d'utilisation de sudo
sudo tail -20 /var/log/auth.log | grep sudo

# Filtrer par utilisateur
sudo grep "alice" /var/log/auth.log | grep sudo | tail -10
```

#### Étape 2 : Audit des permissions dangereuses
```bash
# Chercher les fichiers world-writable
find /tmp -type f -perm -o+w 2>/dev/null | head -10

# Chercher les programmes SUID
find /usr -type f -perm -u+s 2>/dev/null | head -10

# Vérifier les propriétaires des fichiers système
ls -la /etc/passwd /etc/shadow /etc/sudoers
```

---

## Partie G : Scénario réaliste

### Exercice 12 : Configuration d'environnement web

#### Contexte
Vous devez configurer un environnement pour une équipe web avec :
- Alice : développeuse principale (accès complet au code)
- Bob : développeur junior (accès limité)  
- Charlie : testeur (lecture seule + logs)

#### Étape 1 : Structure des répertoires
```bash
# Créer la structure
sudo mkdir -p /var/www/projet/{code,logs,config,backup}
sudo mkdir -p /var/www/projet/code/{public,private}

# Créer des fichiers de test
echo "<h1>Site Web</h1>" | sudo tee /var/www/projet/code/public/index.html
echo "config_db=localhost" | sudo tee /var/www/projet/config/database.conf
echo "$(date): Démarrage serveur" | sudo tee /var/www/projet/logs/access.log
```

#### Étape 2 : Configuration des permissions
```bash
# Propriétaires et groupes
sudo chown -R root:developers /var/www/projet/
sudo chown -R www-data:developers /var/www/projet/code/

# Permissions de base
sudo chmod -R 755 /var/www/projet/
sudo chmod -R 775 /var/www/projet/code/
sudo chmod 2775 /var/www/projet/code/    # SGID pour héritage

# Fichiers sensibles
sudo chmod 640 /var/www/projet/config/database.conf
sudo chown root:developers /var/www/projet/config/database.conf
```

#### Étape 3 : Configuration sudo spécialisée
```bash
# Configuration pour les rôles
sudo visudo -f /etc/sudoers.d/web-team

# Dans l'éditeur, ajouter :
# Alice : développeuse principale
alice ALL=(www-data) NOPASSWD: ALL
alice ALL=(ALL) /usr/bin/systemctl restart nginx, /usr/bin/systemctl reload nginx
alice ALL=(ALL) /bin/chown * /var/www/*

# Bob : développeur junior  
bob ALL=(www-data) /usr/bin/php /var/www/projet/code/*
bob ALL=(ALL) /usr/bin/systemctl status nginx
bob ALL=(ALL) NOPASSWD: /usr/bin/tail /var/www/projet/logs/*

# Charlie : testeur
charlie ALL=(ALL) NOPASSWD: /usr/bin/tail /var/www/projet/logs/*
charlie ALL=(ALL) NOPASSWD: /bin/cat /var/www/projet/logs/*
charlie ALL=(www-data) /usr/bin/php -l /var/www/projet/code/public/*
```

#### Étape 4 : Tests de validation
```bash
# Test Alice (développeuse principale)
sudo -u alice sudo -u www-data touch /var/www/projet/code/public/alice_test.php
sudo -u alice sudo systemctl status nginx

# Test Bob (développeur junior)
sudo -u bob sudo -u www-data php -r "echo 'Bob test OK\n';"
sudo -u bob sudo tail -5 /var/www/projet/logs/access.log

# Test Charlie (testeur)  
sudo -u charlie sudo cat /var/www/projet/logs/access.log | tail -3
sudo -u charlie sudo -u www-data php -l /var/www/projet/code/public/index.html

# Test des restrictions (devrait échouer)
sudo -u bob sudo systemctl restart nginx         # Bob ne peut pas redémarrer
sudo -u charlie sudo -u www-data touch /var/www/projet/code/test.php  # Charlie ne peut pas créer
```

---

## Questions de validation

### Quiz de compréhension

1. **Permissions de fichiers**
   - Que signifie la permission 644 ?
   - Quelle est la différence entre 755 et 644 ?
   - Pourquoi 777 est-il dangereux ?

2. **Utilisateurs et groupes**
   - Quelle est la différence entre groupe primaire et secondaire ?
   - Comment ajouter un utilisateur à plusieurs groupes ?
   - Que se passe-t-il quand on supprime un utilisateur avec `userdel -r` ?

3. **sudo**
   - Pourquoi utilise-t-on `visudo` et non `nano /etc/sudoers` ?
   - Quelle est la différence entre `sudo -i` et `sudo -s` ?
   - Comment limiter sudo à certaines commandes ?

4. **Permissions spéciales**
   - À quoi sert le bit SGID sur un répertoire ?
   - Quand utilise-t-on le sticky bit ?
   - Donnez un exemple d'usage légitime du SUID.

---

## Nettoyage

### Suppression des utilisateurs de test
```bash
# Supprimer les utilisateurs créés
sudo userdel -r alice
sudo userdel -r bob  
sudo userdel -r charlie

# Supprimer les groupes
sudo groupdel developers
sudo groupdel testers
sudo groupdel managers

# Nettoyer les fichiers sudo
sudo rm -f /etc/sudoers.d/alice-config
sudo rm -f /etc/sudoers.d/developers-config
sudo rm -f /etc/sudoers.d/web-team

# Nettoyer les répertoires de test
sudo rm -rf /tmp/tp_users
sudo rm -rf /tmp/projet_equipe
sudo rm -rf /tmp/partage_temporaire
sudo rm -rf /var/www/projet
rm -rf ~/tp_permissions
```

---

## Solutions des exercices

### Solutions principales

#### Exercice 5 - Résultats chmod
```bash
# Après chmod 755 script.sh
-rwxr-xr-x 1 user user script.sh

# Après chmod 600 fichier_prive.txt  
-rw------- 1 user user fichier_prive.txt

# Après chmod 644 fichier_normal.txt
-rw-r--r-- 1 user user fichier_normal.txt
```

#### Exercice 6 - Tests répertoires
```bash
# chmod 644 dossier/ :
ls dossier/    # ✓ Marche (r)
cd dossier/    # ✗ Permission denied (pas d'x)

# chmod 111 dossier/ :
ls dossier/    # ✗ Permission denied (pas de r)  
cd dossier/    # ✓ Marche (x présent)

# chmod 311 dossier/ :
cd dossier/ && touch new.txt    # ✓ Marche (w+x)
ls              # ✗ Permission denied (pas de r)
```

---

## Points clés à retenir

### Commandes essentielles
```bash
# Gestion utilisateurs
useradd -m -s /bin/bash username
usermod -aG group username
userdel -r username

# Gestion groupes  
groupadd groupname
gpasswd -a username groupname
groupdel groupname

# Permissions
chmod 755 file        # Octal
chmod u+x file        # Symbolique  
chown user:group file # Propriétaire
chgrp group file      # Groupe

# Sudo
sudo -l              # Voir permissions
visudo               # Éditer configuration
sudo -u user command # Exécuter comme user
```

### Permissions courantes
- **644** : Fichier normal (rw-r--r--)
- **755** : Exécutable/répertoire (rwxr-xr-x)
- **600** : Fichier privé (rw-------)
- **2775** : Répertoire avec SGID (rwxrwsr-x)
- **1777** : Répertoire temporaire avec sticky (rwxrwxrwt)

### Sécurité
- **Moindre privilège** : donner seulement les droits nécessaires
- **Audit régulier** : vérifier permissions et utilisation sudo
- **Configuration modulaire** : utiliser /etc/sudoers.d/
- **Tests** : valider les configurations avant déploiement

---

**Temps estimé total** : 90-120 minutes selon le public
**Difficulté** : Intermédiaire
**Validation** : Quiz + exercices pratiques réussis