# Chapitre 2.1 — L'arborescence et les chemins

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - décrire la structure en arbre du système de fichiers Linux et situer les principaux répertoires ;
> - distinguer un chemin absolu d'un chemin relatif et les utiliser à bon escient ;
> - employer les raccourcis `.`, `..` et `~` pour naviguer efficacement.
>
> **Durée en séance** : ~30 min.

---

## Tout part de la racine

Sous Windows, les fichiers sont répartis entre des lecteurs identifiés par des lettres : `C:\`, `D:\`, etc.
Sous Linux, il n'existe qu'**un seul point de départ** pour l'ensemble du système : la **racine**, notée `/`
(un simple slash).

Tous les répertoires, tous les fichiers, tous les périphériques sont des branches ou des feuilles de cet
arbre unique. Monter une clé USB, un disque réseau ou une partition supplémentaire ne crée pas un
nouveau lecteur — cela « greffe » une nouvelle branche dans l'arbre existant.

Voici une représentation simplifiée de l'arborescence :

```
/
+-- bin/
+-- boot/
+-- dev/
+-- etc/
+-- home/
|   +-- alice/
|   +-- bob/
+-- lib/
+-- root/
+-- tmp/
+-- usr/
|   +-- bin/
|   +-- lib/
|   +-- local/
|   +-- share/
+-- var/
    +-- log/
    +-- cache/
```

Le séparateur entre les éléments d'un chemin est le **slash** `/` (et non l'antislash `\` de Windows).
La casse est aussi importante : `Rapport.txt` et `rapport.txt` sont deux fichiers distincts.

---

## Les répertoires à connaître

| Répertoire | Rôle principal |
|------------|----------------|
| `/home`    | Répertoires personnels des utilisateurs (ex. `/home/alice`) |
| `/etc`     | Fichiers de configuration du système (texte, lisibles) |
| `/var`     | Données variables : journaux (`/var/log`), caches, files d'attente |
| `/usr`     | Programmes et bibliothèques installés pour tous les utilisateurs |
| `/tmp`     | Fichiers temporaires — contenu effacé régulièrement ou au démarrage |
| `/root`    | Répertoire personnel du super-utilisateur `root` (distinct de `/`) |

> **Analogie Windows (approximative) :**
> `/etc` ~ `C:\Windows\System32\drivers\etc`, `/home` ~ `C:\Users`,
> `/usr` ~ `C:\Program Files`, `/tmp` ~ `C:\Temp`.

---

## Chemins absolus et relatifs

À tout moment, vous vous trouvez dans un répertoire appelé **répertoire courant** (ou répertoire de
travail). La commande `pwd` l'affiche ; `cd` permet d'en changer (voir chapitre 2.2).

Pour désigner un fichier ou un répertoire, il faut lui indiquer son **chemin** (path). Il en existe deux
formes.

### Le chemin absolu

Un chemin absolu **commence obligatoirement par `/`**. Il décrit la route complète depuis la racine,
sans ambiguïté, quel que soit l'endroit où vous vous trouvez.

```
/home/alice/Documents/rapport.txt
/etc/passwd
/var/log/syslog
```

Un chemin absolu fonctionne depuis n'importe quel répertoire courant. C'est le format à privilégier
dans les scripts (voir chapitre 8.2).

### Le chemin relatif

Un chemin relatif **ne commence pas par `/`**. Il est interprété à partir du répertoire courant.

Supposons que le répertoire courant soit `/home/alice` :

| Chemin relatif        | Chemin absolu équivalent              |
|-----------------------|---------------------------------------|
| `Documents/rapport.txt` | `/home/alice/Documents/rapport.txt` |
| `../bob/notes.txt`    | `/home/bob/notes.txt`                 |
| `./script.sh`         | `/home/alice/script.sh`               |

Les chemins relatifs sont plus courts à taper lors d'une session interactive ; ils deviennent risqués
dans les scripts, car ils dépendent de l'endroit où le script est lancé.

### Les raccourcis indispensables

Trois raccourcis simplifient la navigation et peuvent s'utiliser aussi bien en chemin absolu
qu'en chemin relatif :

| Symbole | Signification |
|---------|---------------|
| `.`     | Répertoire courant lui-même |
| `..`    | Répertoire parent (un niveau au-dessus) |
| `~`     | Répertoire personnel de l'utilisateur connecté |

Exemples avec `~` :

```
~/Documents            -- /home/alice/Documents  (si connecté en tant qu'alice)
~/Documents/rapport.txt
~/../bob/              -- /home/bob/
```

Le tilde `~` est une expansion réalisée par le shell avant d'envoyer la commande au système : il est
remplacé par la valeur de la variable `$HOME` (`/home/alice` pour alice, `/root` pour root).

### Comparer les deux approches depuis un même point

Situation de départ : répertoire courant = `/home/alice/Documents/travail`

```
Objectif : aller dans /home/alice/Pictures

  Chemin absolu : /home/alice/Pictures
  Chemin relatif : ../../Pictures
```

```
Objectif : aller dans /var/log

  Chemin absolu : /var/log
  Chemin relatif : ../../../../var/log
```

On voit que plus la destination est éloignée dans l'arbre, plus le chemin relatif peut devenir
difficile à lire. Pour des répertoires très éloignés du point de départ, le chemin absolu est
souvent plus lisible et moins sujet aux erreurs.

### Erreurs courantes à éviter

**Mélanger les deux styles :**

```
# Depuis /home/alice :
ls etc/passwd       -- cherche /home/alice/etc/passwd (n'existe pas)
ls /etc/passwd      -- correct, chemin absolu
```

**Espaces dans un nom de fichier :**

```
cd Mon Dossier      -- interprété comme deux arguments distincts
cd "Mon Dossier"    -- correct, avec guillemets
cd Mon\ Dossier     -- correct, avec echappement
```

---

## L'essentiel

| Notion | Règle à retenir |
|--------|-----------------|
| Racine | `/` — unique point de départ de toute l'arborescence |
| Séparateur | `/` (slash), pas `\` (antislash) |
| Sensibilité à la casse | `Fichier.txt` et `fichier.txt` sont distincts |
| Chemin absolu | Commence par `/` — valable depuis n'importe où |
| Chemin relatif | Ne commence pas par `/` — dépend du répertoire courant |
| `.` | Répertoire courant |
| `..` | Répertoire parent |
| `~` | Répertoire personnel (`/home/alice` pour alice) |
| `/home` | Répertoires personnels des utilisateurs |
| `/etc` | Configuration système |
| `/var/log` | Journaux système |
| `/tmp` | Fichiers temporaires, effacés régulièrement |

---

## Pour aller plus loin

### Le standard FHS

L'organisation de l'arborescence Linux est définie par le **Filesystem Hierarchy Standard** (FHS),
publié par la Linux Foundation. Ce document spécifie quels types de fichiers doivent se trouver
dans quels répertoires, afin que les distributions et les logiciels soient cohérents entre eux.

La plupart des distributions (Debian, Ubuntu, Fedora, etc.) respectent le FHS, ce qui vous permet de
retrouver vos repères sur n'importe quelle machine Linux.

### Répertoires moins visibles mais utiles

**`/proc` — système de fichiers virtuel**

`/proc` n'existe pas sur le disque : il est généré dynamiquement par le noyau. On y trouve des
informations sur les processus en cours et l'état du système.

```bash
cat /proc/cpuinfo       # Informations sur le processeur
cat /proc/meminfo       # Utilisation de la mémoire
ls /proc/1/             # Informations sur le processus numéro 1 (init/systemd)
```

**`/sys` — interface sysfs**

Similaire à `/proc`, `/sys` expose la hiérarchie du matériel et des pilotes. Il est surtout utilisé
par les outils d'administration système avancés.

**`/dev` — périphériques**

Sous Linux, les périphériques matériels sont représentés par des fichiers spéciaux dans `/dev`.

```
/dev/sda        -- premier disque dur ou SSD
/dev/sda1       -- première partition de ce disque
/dev/null       -- "trou noir" : toute donnée y est ignorée
/dev/zero       -- source infinie de zéros binaires
/dev/random     -- source de données aléatoires
```

**`/opt` — logiciels optionnels**

Certains éditeurs installent leurs logiciels dans `/opt` pour ne pas mélanger leurs fichiers avec
ceux gérés par le gestionnaire de paquets (ex. `/opt/google/chrome`).

**`/srv` — données de services**

Destiné aux données servies par les services système : fichiers d'un site web (`/srv/www`),
données FTP (`/srv/ftp`), etc. Peu utilisé en pratique, souvent remplacé par des conventions
propres à chaque distribution.

### Liens symboliques

L'arborescence comporte de nombreux **liens symboliques** (raccourcis). Par exemple, sur les
systèmes récents, `/bin` est souvent un lien vers `/usr/bin`. La commande `ls -la /bin` révèle
ce type de lien :

```
lrwxrwxrwx 1 root root 7 jan.  1 00:00 /bin -> usr/bin
```

Le premier caractère `l` indique un lien symbolique (voir chapitre 2.3).

---

## Exercices

### Exercice 1 — Identifier le type de chemin

Classez chacun des éléments suivants comme **absolu** ou **relatif** :

1. `/etc/passwd`
2. `Documents/rapport.txt`
3. `../bob/notes.txt`
4. `/home/alice/Pictures`
5. `./script.sh`
6. `~`

---

### Exercice 2 — Quel chemin absolu correspond à... ?

Répertoire courant : `/home/alice`

Donnez le chemin absolu correspondant à chacun des chemins relatifs suivants :

1. `Documents/rapport.txt`
2. `../bob/photo.jpg`
3. `../../etc/passwd`
4. `./script.sh`

---

### Exercice 3 — Convertir en chemin relatif

Répertoire courant : `/home/alice/Documents`

Donnez un chemin relatif équivalent pour atteindre chacun des chemins absolus suivants :

1. `/home/alice/Documents/travail/notes.txt`
2. `/home/alice/Pictures/vacances.jpg`
3. `/home/bob/projets/`
4. `/etc/hosts`

---

### Exercice 4 — Navigation à la main

Répertoire courant : `/usr/local/bin`

En utilisant uniquement des chemins relatifs (pas de `/` en début de chemin), quelle séquence de
répertoires vous permet d'atteindre `/var/log` ?

Écrivez la réponse sous la forme d'un seul chemin relatif (ex. `../../quelque/chose`).

---

### Exercice 5 — Prédire la position

Vous partez de `/home/alice`. Quelle est votre position après avoir exécuté chacune de ces
commandes dans l'ordre ?

```
cd ..
cd ..
cd usr
cd share
cd ../bin
```

Position finale : ?

---

### Exercice 6 — Rôle des répertoires

Associez chaque répertoire à sa description :

| Répertoire | Description |
|------------|-------------|
| A. `/etc`  | 1. Journaux et données variables du système |
| B. `/home` | 2. Fichiers temporaires, effacés régulièrement |
| C. `/var`  | 3. Fichiers de configuration système |
| D. `/tmp`  | 4. Répertoires personnels des utilisateurs |
| E. `/usr`  | 5. Programmes et bibliothèques pour tous les utilisateurs |

---

### Solutions

**Exercice 1**

1. `/etc/passwd` — **absolu** (commence par `/`)
2. `Documents/rapport.txt` — **relatif**
3. `../bob/notes.txt` — **relatif**
4. `/home/alice/Pictures` — **absolu**
5. `./script.sh` — **relatif**
6. `~` — **relatif** (raccourci, interprété par le shell à partir de `$HOME`)

---

**Exercice 2** (répertoire courant : `/home/alice`)

1. `Documents/rapport.txt` -> `/home/alice/Documents/rapport.txt`
2. `../bob/photo.jpg` -> `/home/bob/photo.jpg`
3. `../../etc/passwd` -> `/etc/passwd`
4. `./script.sh` -> `/home/alice/script.sh`

---

**Exercice 3** (répertoire courant : `/home/alice/Documents`)

1. `/home/alice/Documents/travail/notes.txt` -> `travail/notes.txt`
2. `/home/alice/Pictures/vacances.jpg` -> `../Pictures/vacances.jpg`
3. `/home/bob/projets/` -> `../../bob/projets/`
4. `/etc/hosts` -> `../../../etc/hosts`

---

**Exercice 4** (départ : `/usr/local/bin`)

Il faut remonter de 3 niveaux (`/usr/local/bin` -> `/usr/local` -> `/usr` -> `/`) puis descendre
dans `var/log` :

```
../../../var/log
```

---

**Exercice 5** (départ : `/home/alice`)

```
cd ..        --> /home
cd ..        --> /
cd usr       --> /usr
cd share     --> /usr/share
cd ../bin    --> /usr/bin
```

Position finale : `/usr/bin`

---

**Exercice 6**

| Répertoire | Description |
|------------|-------------|
| A. `/etc`  | 3. Fichiers de configuration système |
| B. `/home` | 4. Répertoires personnels des utilisateurs |
| C. `/var`  | 1. Journaux et données variables du système |
| D. `/tmp`  | 2. Fichiers temporaires, effacés régulièrement |
| E. `/usr`  | 5. Programmes et bibliothèques pour tous les utilisateurs |
