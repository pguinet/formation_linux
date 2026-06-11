# Chapitre 5.2 — Permissions (chmod, chown)

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - lire et interpréter les permissions affichées par `ls -l` ;
> - modifier les permissions d'un fichier ou d'un répertoire avec `chmod` ;
> - changer le propriétaire et le groupe d'un fichier avec `chown` et `chgrp` ;
> - reconnaître les permissions spéciales (setuid, setgid, sticky bit) et l'effet de l'umask.
>
> **Durée en séance** : ~30 min.

---

## Lire les permissions

### Ce qu'affiche `ls -l`

Chaque ligne produite par `ls -l` commence par une chaîne de dix caractères :

```
-rw-r--r-- 1 alice stagiaires 1234 11 juin 10:00 rapport.txt
```

Le premier caractère indique le **type** :

| Caractère | Type                  |
|-----------|-----------------------|
| `-`       | fichier ordinaire     |
| `d`       | répertoire            |
| `l`       | lien symbolique       |

Les neuf caractères suivants forment trois blocs de trois lettres (`rwx`) :

```
r w x | r - x | r - -
 (u)  |  (g)  |  (o)
```

- **u** (user) : le propriétaire du fichier
- **g** (group) : les membres du groupe associé
- **o** (others) : tous les autres utilisateurs

### Sens de r, w, x selon le type d'objet

| Permission | Sur un fichier                         | Sur un répertoire                           |
|------------|----------------------------------------|---------------------------------------------|
| `r` (4)    | lire le contenu (`cat`, `less`...)     | lister les entrées (`ls`)                   |
| `w` (2)    | modifier, tronquer, réécrire           | créer, renommer ou supprimer des entrées    |
| `x` (1)    | exécuter (script, binaire)             | traverser (entrer avec `cd`, accéder aux fichiers) |
| `-`        | permission absente                     | permission absente                          |

> **Point d'attention sur les répertoires** : le droit `x` est indispensable pour accéder
> aux fichiers qu'il contient. Sans lui, même connaître le nom d'un fichier ne suffit pas
> pour le lire. Le droit `r` seul permet de lister les noms mais pas d'accéder au contenu.

### Exemple de décomposition

```
drwxr-x---
^   --- u : rwx  (lecture, écriture, traversée)
 d  --- g : r-x  (lecture, traversée ; pas d'écriture)
    --- o : ---  (aucun accès)
```

Ce répertoire (`d`) appartient à son propriétaire en lecture/écriture/traversée,
son groupe peut le lister et y entrer, les autres n'y ont aucun accès.

---

## Modifier les permissions avec `chmod`

### Notation symbolique

La forme générale est : `chmod QUI OPERATION PERMISSIONS fichier`

| Lettre | Qui ?                              |
|--------|------------------------------------|
| `u`    | propriétaire (user)                |
| `g`    | groupe                             |
| `o`    | autres (others)                    |
| `a`    | tous (all = u + g + o)             |

| Symbole | Opération          |
|---------|--------------------|
| `+`     | ajouter            |
| `-`     | retirer            |
| `=`     | définir exactement |

Exemples courants :

```bash
# Rendre un script exécutable par son propriétaire
chmod u+x script.sh

# Retirer l'écriture au groupe et aux autres
chmod go-w rapport.txt

# Fixer exactement les permissions des autres à lecture seule
chmod o=r rapport.txt

# Plusieurs modifications en une commande
chmod u=rwx,g=rx,o= projet.sh
```

La notation symbolique est idéale pour des ajustements ciblés, car elle ne touche
que ce que vous désignez et laisse le reste en l'état.

### Notation octale

Chaque permission a une valeur numérique :

| Permission | Valeur |
|------------|--------|
| `r`        | 4      |
| `w`        | 2      |
| `x`        | 1      |
| `-`        | 0      |

On additionne les valeurs pour chaque bloc (u, g, o) :

```
rwxr-xr--
u : r(4)+w(2)+x(1) = 7
g : r(4)+w(0)+x(1) = 5
o : r(4)+w(0)+x(0) = 4
=> 754
```

Permissions les plus rencontrées :

| Octal | Symbolique  | Usage typique                   |
|-------|-------------|---------------------------------|
| 755   | rwxr-xr-x   | script ou répertoire accessible |
| 644   | rw-r--r--   | fichier de données ordinaire    |
| 600   | rw-------   | fichier privé (clé SSH, config) |
| 700   | rwx------   | répertoire strictement privé    |

```bash
# Appliquer en une commande
chmod 755 script.sh
chmod 644 document.txt
chmod 600 ~/.ssh/id_rsa
```

> **Conseil** : utilisez la notation octale quand vous voulez définir un état
> complet et connu, et la notation symbolique pour de petits ajustements.

### Option `-R` (récursif)

```bash
# Appliquer aux répertoires et tout leur contenu
chmod -R 755 /opt/mon_projet/
```

Utilisez `-R` avec précaution : les fichiers et les répertoires ont souvent
besoin de valeurs différentes. Une astuce pour différencier :

```bash
find /opt/mon_projet -type f -exec chmod 644 {} \;
find /opt/mon_projet -type d -exec chmod 755 {} \;
```

---

## Changer le propriétaire et le groupe

### `chown`

`chown` permet de changer le propriétaire, le groupe, ou les deux en même temps.
Son utilisation requiert les droits `sudo` (voir chapitre 5.3).

```bash
# Changer seulement le propriétaire
sudo chown alice rapport.txt

# Changer propriétaire ET groupe (séparés par :)
sudo chown alice:stagiaires rapport.txt

# Changer seulement le groupe (propriétaire vide devant :)
sudo chown :www-data index.html

# Appliquer récursivement
sudo chown -R alice:alice /home/alice/
```

### `chgrp`

`chgrp` est un raccourci pour changer uniquement le groupe :

```bash
sudo chgrp stagiaires rapport.txt
sudo chgrp -R www-data /var/www/html/
```

Les deux commandes suivantes sont équivalentes :

```bash
sudo chown :stagiaires rapport.txt
sudo chgrp stagiaires rapport.txt
```

### Exemple de configuration d'un répertoire de travail collaboratif

```bash
# Créer un groupe de projet
sudo groupadd equipe_projet

# Ajouter les membres (voir chapitre 5.1)
sudo usermod -aG equipe_projet alice
sudo usermod -aG equipe_projet bob

# Créer le répertoire et lui affecter le groupe
sudo mkdir /opt/projet_partage
sudo chgrp equipe_projet /opt/projet_partage
sudo chmod 775 /opt/projet_partage
```

Avec ces réglages, alice et bob (membres du groupe) peuvent lire et écrire ;
les autres utilisateurs ne peuvent que lire et traverser.

---

## L'essentiel

| Commande                   | Usage type                                          |
|----------------------------|-----------------------------------------------------|
| `ls -l fichier`            | Afficher les permissions et le propriétaire         |
| `chmod u+x fichier`        | Ajouter l'exécution pour le propriétaire            |
| `chmod go-w fichier`       | Retirer l'écriture au groupe et aux autres          |
| `chmod 644 fichier`        | Définir rw-r--r-- (fichier de données standard)     |
| `chmod 755 fichier`        | Définir rwxr-xr-x (script ou répertoire accessible) |
| `chmod -R 755 repertoire/` | Appliquer récursivement à tout un arbre             |
| `chown alice fichier`      | Changer le propriétaire                             |
| `chown alice:dev fichier`  | Changer le propriétaire et le groupe                |
| `chgrp dev fichier`        | Changer seulement le groupe                         |

---

## Pour aller plus loin

### L'umask : permissions par défaut

Lorsque vous créez un fichier ou un répertoire, Linux applique automatiquement un
masque de permissions appelé **umask**. Ce masque soustrait des permissions à la
valeur maximale théorique (666 pour les fichiers, 777 pour les répertoires).

```bash
# Afficher l'umask actuel
umask
# => 0022

# Calcul : permissions effectives = valeur maximale - umask
# Fichiers  : 666 - 022 = 644 (rw-r--r--)
# Dossiers  : 777 - 022 = 755 (rwxr-xr-x)
```

Modifier temporairement l'umask :

```bash
umask 027
touch nouveau.txt
# => permissions : 640 (rw-r-----)
```

Pour le rendre permanent, ajoutez la ligne `umask 027` dans votre `~/.bashrc`.

### Bits spéciaux : setuid, setgid, sticky bit

Ces trois bits apparaissent dans `ls -l` à la place du `x` :

| Bit     | Octal | Où       | `ls -l` | Effet                                                        |
|---------|-------|----------|---------|--------------------------------------------------------------|
| setuid  | 4000  | fichier  | `s` (u) | Le processus s'exécute avec les droits du propriétaire       |
| setgid  | 2000  | répertoire | `s` (g) | Les nouveaux fichiers héritent du groupe du répertoire     |
| sticky  | 1000  | répertoire | `t` (o) | Seul le propriétaire d'un fichier peut le supprimer        |

Exemple de `setuid` sur la commande système `passwd` :

```bash
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root 68208 ...
#     ^
#     s = setuid actif : s'exécute en root même lancé par un utilisateur ordinaire
```

Le répertoire `/tmp` utilise le sticky bit (`t`) :

```bash
ls -ld /tmp
# drwxrwxrwt 12 root root 4096 ...
#          ^
#          t = sticky : vous ne pouvez supprimer que vos propres fichiers
```

Appliquer le setgid sur un répertoire de projet collaboratif :

```bash
# 2775 = setgid + rwxrwxr-x
sudo chmod 2775 /opt/projet_partage
```

Si le `x` correspondant n'est pas positionné, la lettre devient majuscule (`S` ou `T`),
signalant que le bit spécial est présent mais sans effet réel.

### ACL : contrôle d'accès étendu

Les ACL (Access Control Lists) permettent d'accorder des droits à des utilisateurs
ou groupes supplémentaires, au-delà du trio u/g/o :

```bash
# Voir les ACL d'un fichier (un + après les permissions signale une ACL)
getfacl rapport.txt

# Accorder la lecture à l'utilisateur charlie sans changer le groupe
setfacl -m u:charlie:r-- rapport.txt

# Retirer l'ACL
setfacl -x u:charlie rapport.txt
```

Les ACL sont utiles quand deux utilisateurs doivent avoir des droits différents
sur le même fichier sans partager de groupe commun. Ils constituent un sujet
avancé couvert dans les ressources complémentaires.

---

## Exercices

### Exercice 1 — Lire des permissions

Observez la sortie suivante et répondez aux questions :

```
-rwxr-x--- 1 alice projet 2048 11 juin 10:00 deploy.sh
drwxrwsr-x 2 root  projet 4096 11 juin  9:00 /opt/site
```

a) Qui peut exécuter `deploy.sh` ?
b) Que signifie le `s` dans les permissions de `/opt/site` ?
c) Un utilisateur qui n'est ni `alice` ni membre du groupe `projet`
   peut-il lire `deploy.sh` ?

---

### Exercice 2 — Fichiers de permissions différentes

Créez trois fichiers et appliquez les permissions correspondantes :

```bash
mkdir ~/tp_permissions
cd ~/tp_permissions
touch notes.txt cle_privee.txt backup.sh
```

- `notes.txt` : lisible par tous, modifiable seulement par le propriétaire
- `cle_privee.txt` : accessible seulement par le propriétaire (lecture/écriture)
- `backup.sh` : exécutable par le propriétaire et le groupe, lecture seule pour les autres

Vérifiez avec `ls -l`.

---

### Exercice 3 — Notation symbolique

À partir d'un fichier `config.txt` avec les permissions `rw-r--r--` (644), obtenez
`rwxr-x---` (750) en **deux commandes symboliques** (sans utiliser la notation octale).

---

### Exercice 4 — Répertoire de travail partagé

Deux utilisateurs, `alice` et `bob`, doivent partager un répertoire `/tmp/equipe` :
- Ils appartiennent tous deux au groupe `equipe`.
- Chacun doit pouvoir créer et modifier des fichiers.
- Un utilisateur ne doit pas pouvoir supprimer les fichiers d'un autre.
- Les fichiers créés dans le répertoire doivent hériter du groupe `equipe`.

Écrivez les commandes `chmod` et `chown`/`chgrp` nécessaires
(la création du groupe et des utilisateurs est traitée au chapitre 5.1).

---

### Exercice 5 — Diagnostiquer une erreur

Un collègue se plaint : "je ne peux pas entrer dans le dossier `rapports/`,
pourtant `ls -ld rapports/` me donne `drw-r--r--`."

Expliquez la cause et proposez la commande minimale pour corriger le problème
sans accorder plus de droits que nécessaire.

---

### Exercice 6 — Umask et création de fichiers

Vous souhaitez que vos prochains fichiers soient créés en `640` (rw-r-----) et
vos répertoires en `750` (rwxr-x---).

a) Quelle valeur d'umask faut-il appliquer ?
b) Écrivez la commande pour l'appliquer temporairement.
c) Comment le rendre permanent ?

---

### Solutions

#### Solution exercice 1

a) `alice` (propriétaire) et les membres du groupe `projet` peuvent exécuter
   `deploy.sh`. Les autres n'ont aucun droit (`---`).

b) Le `s` dans le bloc groupe (`rwxrwsr-x`) indique le bit **setgid** sur le
   répertoire : tout fichier créé dans `/opt/site` héritera automatiquement du
   groupe `projet`, quel que soit le groupe primaire du créateur.

c) Non — les permissions pour les autres (`---`) interdisent toute lecture,
   écriture ou exécution.

---

#### Solution exercice 2

```bash
chmod 644 notes.txt         # rw-r--r--
chmod 600 cle_privee.txt    # rw-------
chmod 754 backup.sh         # rwxr-xr--
```

Vérification :

```bash
ls -l ~/tp_permissions
# -rw-r--r-- 1 user user notes.txt
# -rw------- 1 user user cle_privee.txt
# -rwxr-xr-- 1 user user backup.sh
```

---

#### Solution exercice 3

L'état initial est `rw-r--r--` (644), l'état cible est `rwxr-x---` (750).

```bash
# Ajouter x au propriétaire et au groupe
chmod ug+x config.txt       # => rwxr-xr--

# Retirer toutes les permissions aux autres
chmod o= config.txt         # => rwxr-x---
```

On aurait également pu écrire en une commande :
`chmod ug+x,o= config.txt`

---

#### Solution exercice 4

```bash
# Créer le répertoire et lui affecter le groupe
sudo mkdir /tmp/equipe
sudo chgrp equipe /tmp/equipe

# rwxrwx--- avec setgid (2) et sticky bit (1) => 3770
# setgid : héritage du groupe pour les nouveaux fichiers
# sticky : seul le propriétaire d'un fichier peut le supprimer
sudo chmod 3770 /tmp/equipe

# Vérification
ls -ld /tmp/equipe
# drwxrws--T 2 root equipe 4096 ...
```

Détail des bits :
- `3` = setgid (2) + sticky (1)
- `7` = rwx pour le propriétaire (root ou tout autre compte admin)
- `7` = rwx pour le groupe equipe (alice et bob)
- `0` = aucun droit pour les autres

---

#### Solution exercice 5

Le répertoire `rapports/` a les permissions `drw-r--r--` : le bit `x` est absent
pour toutes les catégories. Or `x` est indispensable pour **entrer** dans un
répertoire (`cd`) et accéder à ses fichiers.

Correction minimale — accorder la traversée au propriétaire sans changer les
droits du groupe et des autres :

```bash
chmod u+x rapports/
```

Si d'autres utilisateurs doivent également y entrer :

```bash
chmod a+x rapports/    # ou : chmod 755 rapports/
```

---

#### Solution exercice 6

a) La valeur d'umask souhaitée se calcule ainsi :
   - Fichiers : 666 - 640 = 026, mais le calcul est un masquage binaire, pas une
     soustraction simple. Umask **027** donne :
     - Fichiers : 666 AND NOT(027) = 640 (rw-r-----)
     - Répertoires : 777 AND NOT(027) = 750 (rwxr-x---)

b) Appliquer temporairement :

```bash
umask 027
```

c) Pour le rendre permanent, ajoutez la ligne suivante dans `~/.bashrc` :

```bash
echo "umask 027" >> ~/.bashrc
```

Le changement sera effectif à la prochaine ouverture de terminal.
