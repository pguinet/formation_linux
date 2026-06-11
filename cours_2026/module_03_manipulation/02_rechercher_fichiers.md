# Chapitre 3.2 — Rechercher des fichiers

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - Utiliser `find` pour localiser des fichiers selon leur nom, leur type ou leur taille.
> - Retrouver l'emplacement d'une commande avec `which`.
> - Distinguer la recherche *de* fichiers (ce chapitre) de la recherche *dans* le contenu des fichiers (`grep`, traité au chapitre 4.3).
>
> **Durée en séance** : ~30 min.

---

## `find` — l'outil universel

`find` parcourt une arborescence en temps réel et retourne tous les éléments qui correspondent à vos critères. Contrairement à un simple listing, il descend dans tous les sous-répertoires et peut combiner plusieurs conditions.

### Syntaxe de base

```
find <chemin> [critères]
```

- `<chemin>` : le point de départ de la recherche. Utilisez `.` pour le répertoire courant ou un chemin absolu comme `/home`.
- Les critères sont optionnels ; sans critère, `find` liste tout ce qu'il rencontre.

### Rechercher par nom : `-name`

L'option `-name` accepte un nom exact ou un motif avec l'astérisque `*`.

```bash
# Trouver un fichier dont on connaît le nom exact
find . -name "rapport.txt"

# Trouver tous les fichiers .txt dans /home
find /home -name "*.txt"

# Recherche insensible à la casse (trouve rapport.txt, Rapport.TXT, etc.)
find . -iname "rapport*"
```

> **Remarque** : le motif doit être entre guillemets pour éviter que le shell l'interprète avant de passer la valeur à `find`.

### Filtrer par type : `-type`

Par défaut, `find` retourne à la fois des fichiers et des répertoires. L'option `-type` permet de préciser :

- `f` : fichiers ordinaires uniquement.
- `d` : répertoires uniquement.
- `l` : liens symboliques (voir chapitre 2.3).

```bash
# Uniquement les fichiers ordinaires nommés *.conf
find /etc -type f -name "*.conf"

# Uniquement les répertoires dont le nom contient "sauvegarde"
find . -type d -name "*sauvegarde*"

# Uniquement les liens symboliques
find /usr/bin -type l
```

Combiner `-type f` avec `-name` est la pratique la plus courante : cela évite de confondre un répertoire `notes/` avec un fichier `notes.txt`.

### Filtrer par taille : `-size`

L'option `-size` utilise des unités de mesure simples :

- `k` : kilo-octets (1 024 octets)
- `M` : méga-octets
- `G` : giga-octets
- `c` : octets

Un `+` devant la valeur signifie « plus grand que », un `-` signifie « plus petit que ».

```bash
# Fichiers de plus de 100 Mo (utile pour libérer de l'espace)
find /home -type f -size +100M

# Fichiers de moins de 1 ko (souvent des fichiers vides ou très courts)
find . -type f -size -1k

# Fichiers vides (taille exactement nulle)
find . -type f -empty
```

**Exemple concret :** identifier les fichiers qui occupent le plus de place dans votre dossier personnel :

```bash
find ~ -type f -size +10M
```

Cette commande liste tous vos fichiers de plus de 10 Mo — images, vidéos, archives — sans avoir à explorer manuellement chaque sous-dossier.

### Combiner plusieurs critères

Plusieurs critères placés à la suite se combinent avec un ET logique implicite. Voici quelques cas courants :

```bash
# Fichiers .log de plus de 50 Mo dans /var/log
find /var/log -type f -name "*.log" -size +50M

# Fichiers .sh dans le répertoire courant (scripts)
find . -type f -name "*.sh"
```

Pour exclure un motif, utilisez `!` (le point d'exclamation) avant le critère :

```bash
# Tous les fichiers sauf les .tmp
find . -type f ! -name "*.tmp"
```

---

## Où est cette commande ? — `which`

Quand vous tapez une commande comme `ls` ou `python3`, le shell la cherche dans une liste de répertoires définie par la variable `PATH`. `which` révèle quel fichier exécutable sera lancé.

```bash
which ls
# /usr/bin/ls

which python3
# /usr/bin/python3

which nano
# /usr/bin/nano
```

Si la commande est introuvable dans le `PATH`, `which` ne retourne rien (ou affiche un message d'erreur). C'est un moyen rapide de vérifier qu'un logiciel est bien installé et accessible :

```bash
which git
# /usr/bin/git

which monprogramme
# (aucune sortie : le programme n'est pas dans le PATH)
```

---

## Précision importante : recherche *de* fichiers vs recherche *dans* les fichiers

`find` localise des fichiers selon leurs attributs (nom, taille, type, date...). Il ne lit pas leur contenu.

Pour chercher une chaîne de caractères à l'intérieur d'un fichier — par exemple tous les fichiers qui contiennent le mot « erreur » — vous utiliserez `grep`, présenté au **chapitre 4.3**.

---

## L'essentiel

| Commande | Usage type |
|----------|-----------|
| `find . -name "*.txt"` | Trouver tous les fichiers .txt à partir du répertoire courant |
| `find /home -type f -name "rapport*"` | Fichiers dont le nom commence par « rapport » |
| `find . -type d` | Lister uniquement les répertoires |
| `find . -type f -size +10M` | Fichiers de plus de 10 Mo |
| `find . -type f -empty` | Fichiers vides |
| `find . -type f ! -name "*.tmp"` | Tous les fichiers sauf les .tmp |
| `which python3` | Afficher le chemin complet d'une commande |

---

## Pour aller plus loin

### `locate` et `updatedb` — recherche rapide par index

`locate` recherche dans une base de données pré-construite au lieu de parcourir le disque en temps réel. Il est donc beaucoup plus rapide, mais peut retourner des résultats obsolètes si la base n'a pas été mise à jour récemment.

```bash
# Rechercher rapidement un fichier par nom
locate passwd

# Mettre à jour la base de données (nécessite les droits administrateur)
sudo updatedb
```

`locate` est pratique pour des recherches rapides dans tout le système. Réservez `find` quand vous avez besoin de critères de taille, de date ou de type, ou quand vous venez de créer un fichier (la base de `locate` est mise à jour une fois par jour).

### `whereis` — binaires, manuels et sources

`whereis` va plus loin que `which` : il cherche non seulement l'exécutable, mais aussi les pages de manuel et les fichiers sources associés à une commande.

```bash
whereis ls
# ls: /usr/bin/ls /usr/share/man/man1/ls.1.gz

whereis python3
# python3: /usr/bin/python3 /usr/share/man/man1/python3.1.gz
```

### `-mtime` — rechercher par date de modification

L'option `-mtime` filtre les fichiers selon leur date de dernière modification. L'unité est le jour ; le signe `+` signifie « il y a plus de N jours » et `-` signifie « modifié dans les N derniers jours ».

```bash
# Fichiers modifiés dans les dernières 24 heures
find . -type f -mtime -1

# Fichiers non modifiés depuis plus de 30 jours (candidats à l'archivage)
find /tmp -type f -mtime +30
```

Pour une granularité en minutes, utilisez `-mmin` :

```bash
# Fichiers modifiés dans les 10 dernières minutes
find . -type f -mmin -10
```

### `-exec` — agir sur les fichiers trouvés

`-exec` permet d'exécuter une commande pour chaque fichier retourné par `find`. Le symbole `{}` représente le fichier courant et la séquence `\;` termine la commande.

```bash
# Afficher les détails de chaque fichier .log trouvé
find /var/log -type f -name "*.log" -exec ls -lh {} \;

# Compter les lignes de chaque fichier .md
find . -name "*.md" -exec wc -l {} \;
```

> **Prudence :** `-exec rm {} \;` supprime sans confirmation. Toujours tester d'abord sans l'action pour vérifier la liste des fichiers retournés.

### Limiter la profondeur avec `-maxdepth`

Sur de grandes arborescences, `-maxdepth` évite de descendre trop profondément :

```bash
# Chercher uniquement dans le répertoire courant, sans descendre
find . -maxdepth 1 -name "*.txt"
```

---

## Exercices

Pour ces exercices, on suppose que vous avez créé l'arborescence suivante lors du chapitre 3.1 (ou vous pouvez la recréer avec les commandes ci-dessous) :

```
# Recréer rapidement l'arborescence de travail
mkdir -p ~/tp_module03/projets/webapp/{frontend,backend,docs}
mkdir -p ~/tp_module03/archives
touch ~/tp_module03/projets/webapp/frontend/index.html
touch ~/tp_module03/projets/webapp/frontend/style.css
touch ~/tp_module03/projets/webapp/backend/app.py
touch ~/tp_module03/projets/webapp/backend/config.py
touch ~/tp_module03/projets/webapp/docs/README.md
touch ~/tp_module03/archives/backup_2024.tar.gz
touch ~/tp_module03/notes.txt
touch ~/tp_module03/temp.tmp
```

Placez-vous dans ce répertoire avant de commencer :

```bash
cd ~/tp_module03
```

---

**Exercice 1** — Retrouver un fichier par son nom

Trouvez le fichier `README.md` dans l'arborescence `~/tp_module03` à l'aide de `find`.

**Exercice 2** — Lister les fichiers Python

Listez tous les fichiers dont l'extension est `.py` dans le sous-répertoire `projets/`.

**Exercice 3** — Lister uniquement les répertoires

Affichez uniquement les répertoires (pas les fichiers) contenus dans `~/tp_module03` et ses sous-dossiers.

**Exercice 4** — Exclure les fichiers temporaires

Listez tous les fichiers de `~/tp_module03` en excluant ceux dont l'extension est `.tmp`.

**Exercice 5** — Localiser une commande

Affichez le chemin complet de la commande `find` elle-même, puis vérifiez si `locate` est disponible sur votre système.

---

### Solutions

**Exercice 1**

```bash
find ~/tp_module03 -name "README.md"
# Résultat attendu :
# /home/<votre_nom>/tp_module03/projets/webapp/docs/README.md
```

**Exercice 2**

```bash
find ~/tp_module03/projets -name "*.py"
# Résultat attendu :
# .../projets/webapp/backend/app.py
# .../projets/webapp/backend/config.py
```

**Exercice 3**

```bash
find ~/tp_module03 -type d
# Retourne tous les répertoires de l'arborescence :
# ~/tp_module03
# ~/tp_module03/projets
# ~/tp_module03/projets/webapp
# ~/tp_module03/projets/webapp/frontend
# ~/tp_module03/projets/webapp/backend
# ~/tp_module03/projets/webapp/docs
# ~/tp_module03/archives
```

**Exercice 4**

```bash
find ~/tp_module03 -type f ! -name "*.tmp"
# Tous les fichiers sauf temp.tmp :
# .../notes.txt
# .../index.html
# .../style.css
# .../app.py
# .../config.py
# .../README.md
# .../backup_2024.tar.gz
```

**Exercice 5**

```bash
which find
# /usr/bin/find

which locate
# /usr/bin/locate   (si locate est installé)
# (aucune sortie si locate n'est pas disponible)
```

Si `locate` est absent, vous pouvez l'installer avec :

```bash
sudo apt install mlocate
```
