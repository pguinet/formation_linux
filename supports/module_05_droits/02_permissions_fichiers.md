# Permissions de fichiers et dossiers

## Principe des permissions UNIX

### Modèle de permissions
Chaque fichier et dossier possède trois niveaux de permissions pour trois catégories d'utilisateurs :

```
    Catégories         Permissions
    ──────────         ───────────
    Owner (u)          Read (r)
    Group (g)      ×   Write (w)
    Others (o)         Execute (x)
```

### Représentation des permissions

#### Format symbolique (lettres)
```bash
# Exemple : drwxr-xr--
# d = type (d=dossier, -=fichier, l=lien)
# rwx = owner (lecture, écriture, exécution)
# r-x = group (lecture, pas d'écriture, exécution)
# r-- = others (lecture seulement)
```

#### Format numérique (octal)
```bash
# Chaque permission a une valeur :
# r (read) = 4
# w (write) = 2  
# x (execute) = 1

# Exemples :
# 755 = rwxr-xr-x (4+2+1, 4+0+1, 4+0+1)
# 644 = rw-r--r-- (4+2+0, 4+0+0, 4+0+0)
# 600 = rw------- (4+2+0, 0+0+0, 0+0+0)
```

## Visualisation des permissions avec `ls -l`

### Lecture détaillée de `ls -l`
```bash
ls -l /etc/passwd
# -rw-r--r-- 1 root root 2847 Jan 15 08:30 /etc/passwd

# Décomposition :
# - : type de fichier (- = fichier régulier)
# rw- : permissions owner (root)
# r-- : permissions group (root)  
# r-- : permissions others
# 1 : nombre de liens
# root : propriétaire
# root : groupe
# 2847 : taille en octets
# Jan 15 08:30 : date de modification
# /etc/passwd : nom du fichier
```

### Types de fichiers courants
```bash
# Premier caractère indique le type :
ls -la /

# - : fichier régulier
# d : répertoire (directory)
# l : lien symbolique (link)
# c : périphérique caractère (character device)
# b : périphérique bloc (block device)
# p : pipe nommé (named pipe/FIFO)
# s : socket Unix
```

## Signification des permissions

### Pour les fichiers réguliers

#### Read (r) - Lecture
```bash
# Permet de lire le contenu du fichier
cat fichier.txt
less fichier.txt
grep "pattern" fichier.txt
```

#### Write (w) - Écriture
```bash
# Permet de modifier le contenu du fichier
echo "nouveau contenu" > fichier.txt
nano fichier.txt
sed -i 's/ancien/nouveau/' fichier.txt
```

#### Execute (x) - Exécution
```bash
# Permet d'exécuter le fichier s'il est exécutable
./script.sh
/usr/bin/python script.py

# Nécessaire aussi pour les binaires
/bin/ls
/usr/bin/vim
```

### Pour les répertoires

#### Read (r) - Listage
```bash
# Permet de lister le contenu du répertoire
ls repertoire/
find repertoire/
```

#### Write (w) - Modification
```bash
# Permet de créer, supprimer, renommer des fichiers dans le répertoire
touch repertoire/nouveau_fichier
rm repertoire/ancien_fichier
mv repertoire/fichier1 repertoire/fichier2
```

#### Execute (x) - Traversée
```bash
# Permet d'entrer dans le répertoire et d'accéder aux fichiers
cd repertoire/
cat repertoire/fichier.txt

# IMPORTANT : x est nécessaire pour accéder aux fichiers dans le répertoire
```

### Combinaisons courantes

#### Permissions typiques de fichiers
```bash
# 644 (rw-r--r--) : fichier de données classique
-rw-r--r-- document.txt

# 600 (rw-------) : fichier privé
-rw------- ~/.ssh/id_rsa

# 755 (rwxr-xr-x) : script exécutable
-rwxr-xr-x script.sh

# 666 (rw-rw-rw-) : fichier temporaire (rare)
```

#### Permissions typiques de répertoires
```bash
# 755 (rwxr-xr-x) : répertoire standard
drwxr-xr-x home/user/

# 700 (rwx------) : répertoire privé
drwx------ ~/.ssh/

# 775 (rwxrwxr-x) : répertoire de travail collaboratif
drwxrwxr-x /opt/shared/
```

## Modification des permissions avec `chmod`

### Syntaxe symbolique (lettres)

#### Structure de base
```bash
chmod [who][operation][permission] fichier

# who : u (user/owner), g (group), o (others), a (all)
# operation : + (ajouter), - (retirer), = (définir exactement)
# permission : r, w, x
```

#### Exemples pratiques
```bash
# Ajouter la permission d'exécution au propriétaire
chmod u+x script.sh

# Retirer l'écriture au groupe et autres
chmod go-w fichier.txt

# Donner toutes les permissions au propriétaire, lecture seule aux autres
chmod u=rwx,go=r fichier.conf

# Rendre un fichier exécutable pour tous
chmod a+x programme.bin

# Permissions complexes
chmod u=rwx,g=rx,o=r script.sh  # équivaut à 754
```

### Syntaxe numérique (octale)

#### Calcul des permissions
```bash
# Additionner les valeurs :
# r = 4, w = 2, x = 1

# Exemple pour 755 :
# Owner: r(4) + w(2) + x(1) = 7
# Group: r(4) + -(0) + x(1) = 5  
# Others: r(4) + -(0) + x(1) = 5
```

#### Permissions courantes
```bash
# 755 : rwxr-xr-x (scripts, exécutables)
chmod 755 script.sh

# 644 : rw-r--r-- (fichiers de données)
chmod 644 document.txt

# 600 : rw------- (fichiers privés)
chmod 600 ~/.ssh/id_rsa

# 666 : rw-rw-rw- (fichiers temporaires)
chmod 666 /tmp/temp_file

# 777 : rwxrwxrwx (toutes permissions - dangereux !)
chmod 777 fichier_test

# 000 : --------- (aucune permission)
chmod 000 fichier_bloque
```

### Options utiles de chmod

#### Récursif
```bash
# Appliquer aux répertoires et sous-répertoires
chmod -R 755 /opt/mon_projet/

# Attention : différencier fichiers et dossiers
find /opt/projet -type f -exec chmod 644 {} \;
find /opt/projet -type d -exec chmod 755 {} \;
```

#### Verbose (détaillé)
```bash
# Afficher les modifications effectuées
chmod -v 644 *.txt

# mode of 'file1.txt' changed from 0600 (rw-------) to 0644 (rw-r--r--)
```

#### Reference (référence)
```bash
# Copier les permissions d'un fichier existant
chmod --reference=fichier_modele nouveaux_fichiers*
```

## Modification des propriétaires avec `chown`

### Changement de propriétaire

#### Syntaxe de base
```bash
chown [utilisateur][:groupe] fichier

# Changer seulement le propriétaire
sudo chown alice fichier.txt

# Changer propriétaire et groupe
sudo chown alice:developers projet.txt

# Changer seulement le groupe (notation alternative)
sudo chown :www-data /var/www/html/index.html
```

#### Exemples pratiques
```bash
# Donner un fichier à un utilisateur
sudo chown john document.pdf

# Changer le propriétaire d'un répertoire et son contenu
sudo chown -R alice:alice /home/alice/

# Changer pour l'utilisateur web
sudo chown www-data:www-data /var/www/html/site/

# Copier la propriété d'un autre fichier
sudo chown --reference=/etc/passwd nouveau_fichier_config
```

### Changement de groupe avec `chgrp`

#### Utilisation de chgrp
```bash
# Changer seulement le groupe
sudo chgrp developers projet_code/

# Récursivement
sudo chgrp -R www-data /var/log/nginx/

# Avec affichage des modifications
sudo chgrp -v users *.txt
```

## Permissions spéciales avancées

### Sticky bit

#### Principe et utilisation
```bash
# Le sticky bit sur un répertoire empêche la suppression de fichiers
# par d'autres utilisateurs que le propriétaire

# Exemple typique : /tmp
ls -ld /tmp
# drwxrwxrwt 12 root root 4096 Jan 15 10:30 /tmp

# Le 't' final indique le sticky bit
```

#### Application du sticky bit
```bash
# Ajouter le sticky bit (symbolique)
chmod +t repertoire_partage/

# Ajouter le sticky bit (numérique)
chmod 1755 repertoire_partage/

# Exemple : créer un répertoire de partage sécurisé
mkdir /tmp/partage
chmod 1777 /tmp/partage
```

### SetUID et SetGID

#### SetUID (s sur owner)
```bash
# Le processus s'exécute avec les privilèges du propriétaire du fichier
# Exemple : passwd (s'exécute en root pour modifier /etc/shadow)
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root 68208 Nov 29 12:34 /usr/bin/passwd

# Appliquer SetUID
chmod u+s programme
chmod 4755 programme
```

#### SetGID (s sur group)
```bash
# Pour fichiers : s'exécute avec les privilèges du groupe
# Pour répertoires : nouveaux fichiers héritent du groupe du répertoire

# Exemple d'application
chmod g+s repertoire_collaboratif/
chmod 2755 repertoire_collaboratif/
```

### Permissions étendues - Résumé numérique

#### Format à 4 chiffres
```bash
# Format complet : [special][owner][group][others]
# Special permissions :
# 4 = SetUID
# 2 = SetGID  
# 1 = Sticky bit

# Exemples :
# 4755 : SetUID + rwxr-xr-x
# 2755 : SetGID + rwxr-xr-x
# 1755 : Sticky + rwxr-xr-x
# 6755 : SetUID+SetGID + rwxr-xr-x
```

## Umask - Permissions par défaut

### Principe du umask
```bash
# umask détermine les permissions par défaut des nouveaux fichiers
# Il "masque" (retire) des permissions de la valeur maximale

# Valeurs maximales par défaut :
# Fichiers : 666 (rw-rw-rw-)
# Répertoires : 777 (rwxrwxrwx)
```

### Fonctionnement du umask
```bash
# Voir le umask actuel
umask

# Voir en format symbolique
umask -S

# Calcul des permissions finales :
# Fichiers : 666 - umask
# Répertoires : 777 - umask

# Exemple avec umask 022 :
# Fichiers : 666 - 022 = 644 (rw-r--r--)
# Répertoires : 777 - 022 = 755 (rwxr-xr-x)
```

### Configuration du umask
```bash
# Changer temporairement
umask 027

# Test de création
touch test_file
mkdir test_dir
ls -l test_*

# Configuration permanente dans ~/.bashrc
echo "umask 027" >> ~/.bashrc

# Configuration système dans /etc/profile
```

### Umask courants et leur signification
```bash
# umask 022 (défaut Ubuntu) :
# Fichiers : 644 (rw-r--r--) - lecture pour tous
# Dossiers : 755 (rwxr-xr-x) - accès pour tous

# umask 027 (sécurisé) :
# Fichiers : 640 (rw-r-----) - groupe lecture, autres rien
# Dossiers : 750 (rwxr-x---) - groupe accès, autres rien

# umask 077 (très sécurisé) :
# Fichiers : 600 (rw-------) - propriétaire seulement
# Dossiers : 700 (rwx------) - propriétaire seulement
```

## Cas d'usage pratiques

### Sécurisation des fichiers sensibles

#### Clés SSH
```bash
# Répertoire .ssh
chmod 700 ~/.ssh/

# Clé privée
chmod 600 ~/.ssh/id_rsa

# Clé publique
chmod 644 ~/.ssh/id_rsa.pub

# Fichier de configuration
chmod 600 ~/.ssh/config

# Fichier authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

#### Fichiers de configuration
```bash
# Configuration avec mot de passe
chmod 600 config_avec_password.conf

# Configuration publique
chmod 644 config_publique.conf

# Scripts d'administration
chmod 700 admin_scripts/
chmod 755 admin_scripts/*.sh
```

### Serveur web

#### Permissions Apache/Nginx
```bash
# Répertoires web
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Fichiers web statiques
sudo find /var/www/html -type f -exec chmod 644 {} \;

# Scripts CGI/PHP exécutables
sudo chmod 755 /var/www/html/cgi-bin/*.cgi

# Répertoires de cache/upload (écriture nécessaire)
sudo chmod 775 /var/www/html/uploads/
sudo chmod 775 /var/www/html/cache/
```

### Projets collaboratifs

#### Répertoire de projet partagé
```bash
# Créer groupe projet
sudo groupadd projet_web

# Ajouter utilisateurs au groupe
sudo usermod -aG projet_web alice
sudo usermod -aG projet_web bob

# Créer répertoire projet
sudo mkdir /opt/projet_web
sudo chgrp projet_web /opt/projet_web
sudo chmod 2775 /opt/projet_web  # SetGID pour héritage du groupe

# Test : nouveaux fichiers hériteront du groupe projet_web
```

## Diagnostiquer les problèmes de permissions

### Erreurs courantes et solutions

#### "Permission denied" lors de l'exécution
```bash
# Problème : fichier pas exécutable
ls -l script.sh
# -rw-r--r-- 1 user user 156 Jan 15 10:30 script.sh

# Solution :
chmod +x script.sh
# ou
chmod 755 script.sh
```

#### "Permission denied" lors de l'accès à un répertoire
```bash
# Problème : pas de permission x sur le répertoire
ls -ld mon_repertoire/
# drw-r--r-- 2 user user 4096 Jan 15 10:30 mon_repertoire

# Solution :
chmod u+x mon_repertoire/
```

#### Impossible de modifier un fichier
```bash
# Vérifier propriétaire et permissions
ls -l fichier.txt
id  # vérifier mon identité

# Solutions possibles :
sudo chmod u+w fichier.txt          # si problème de permissions
sudo chown $(whoami) fichier.txt    # si problème de propriétaire
```

### Commandes d'audit et diagnostic
```bash
# Trouver fichiers avec permissions spéciales
find /home -perm /4000  # SetUID
find /home -perm /2000  # SetGID  
find /home -perm /1000  # Sticky

# Trouver fichiers accessibles en écriture par tous
find /etc -perm -002 -type f

# Trouver fichiers sans propriétaire
find /home -nouser -o -nogroup

# Vérifier permissions d'un chemin complet
namei -l /path/to/file
```

## Scripts d'automatisation des permissions

### Script de sécurisation automatique
```bash
#!/bin/bash
# secure_permissions.sh - Sécuriser les permissions des fichiers importants

# Répertoires utilisateur
find /home -name ".ssh" -type d -exec chmod 700 {} \;
find /home -name ".ssh" -type d -exec find {} -name "id_*" -not -name "*.pub" -exec chmod 600 {} \; \;

# Scripts système
find /usr/local/bin -name "*.sh" -exec chmod 755 {} \;

# Fichiers de configuration
find /etc -name "*.conf" -exec chmod 644 {} \;

# Logs accessibles au groupe adm seulement
find /var/log -type f -exec chmod 640 {} \;
find /var/log -type f -exec chgrp adm {} \;

echo "Sécurisation terminée"
```

### Fonction de diagnostic rapide
```bash
check_perms() {
    local file="$1"
    
    if [ ! -e "$file" ]; then
        echo "Fichier $file inexistant"
        return 1
    fi
    
    echo "=== Analyse de $file ==="
    ls -ld "$file"
    
    echo "Propriétaire : $(stat -c %U:%G "$file")"
    echo "Permissions octales : $(stat -c %a "$file")"
    
    # Test d'accès
    [ -r "$file" ] && echo "✓ Lisible" || echo "✗ Pas lisible"
    [ -w "$file" ] && echo "✓ Modifiable" || echo "✗ Pas modifiable"  
    [ -x "$file" ] && echo "✓ Exécutable" || echo "✗ Pas exécutable"
}

# Usage : check_perms /etc/passwd
```

## Points clés à retenir

- **Trois niveaux** : owner, group, others
- **Trois permissions** : read (4), write (2), execute (1)
- **Deux formats** : symbolique (rwx) et numérique (755)
- **Différences fichiers/dossiers** : x = exécution vs traversée
- **Commandes principales** : chmod, chown, chgrp
- **Permissions spéciales** : SetUID (4), SetGID (2), Sticky (1)
- **umask** : permissions par défaut = max - umask
- **Sécurité** : principe du moindre privilège
- **Diagnostics** : ls -l, stat, namei -l

## Exercices pratiques

### Exercice 1 : Permissions de base
```bash
# Créer des fichiers tests
touch fichier_normal.txt
touch fichier_prive.txt  
touch script.sh

# Appliquer permissions appropriées
chmod 644 fichier_normal.txt
chmod 600 fichier_prive.txt
chmod 755 script.sh

# Vérifier
ls -l fichier* script*
```

### Exercice 2 : Répertoire collaboratif
```bash
# Créer répertoire projet
mkdir projet_equipe

# Appliquer permissions collaboratives
chmod 775 projet_equipe/
chmod g+s projet_equipe/  # SetGID

# Test avec différents utilisateurs
```

### Exercice 3 : Diagnostic et réparation
```bash
# Simuler problème
echo "#!/bin/bash" > test_script.sh
echo "echo 'Hello world'" >> test_script.sh

# Essayer d'exécuter (va échouer)
./test_script.sh

# Diagnostiquer et réparer
ls -l test_script.sh
chmod +x test_script.sh
./test_script.sh
```