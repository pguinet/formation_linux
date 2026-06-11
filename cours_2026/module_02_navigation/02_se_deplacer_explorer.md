# Chapitre 2.2 — Se déplacer et explorer (pwd, cd, ls)

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - Connaître votre position dans l'arborescence à tout moment avec `pwd`.
> - Vous déplacer efficacement d'un répertoire à un autre avec `cd`.
> - Lister et analyser le contenu d'un répertoire avec `ls` et ses principales options.
> - Combiner ces trois commandes pour naviguer avec assurance dans le système.
>
> **Durée en séance** : ~30 min.

---

## Où suis-je ? La commande `pwd`

Dès que vous ouvrez un terminal, vous vous trouvez dans un répertoire précis. Ce répertoire est appelé le **répertoire courant** ou **répertoire de travail**. La commande `pwd` (Print Working Directory) l'affiche immédiatement :

```bash
pwd
```

Exemple de résultat :

```
/home/alice
```

Ce chemin absolu vous indique exactement où vous êtes dans l'arborescence — ici, dans le répertoire personnel de l'utilisatrice `alice` (voir chapitre 2.1 pour le rappel sur les chemins absolus et l'arborescence).

**Quand utiliser `pwd` ?**

Prenez l'habitude de le taper chaque fois que vous avez un doute. C'est la première réaction à adopter lorsque quelque chose ne se passe pas comme prévu : vérifier sa position évite la grande majorité des erreurs de débutant.

```bash
pwd
# /home/alice/Documents
```

---

## Se déplacer : la commande `cd`

`cd` (Change Directory) est la commande de déplacement. Sa syntaxe de base est :

```bash
cd chemin
```

où `chemin` peut être absolu (commence par `/`) ou relatif (depuis votre position courante). La distinction entre chemin absolu et chemin relatif est expliquée au chapitre 2.3 ; retenez pour l'instant que `/etc` est absolu et que `Documents` est relatif.

### Aller dans un répertoire précis

```bash
cd /etc
pwd
# /etc

cd /var/log
pwd
# /var/log
```

Ces deux exemples utilisent des chemins absolus : ils fonctionnent quel que soit votre point de départ.

### Remonter vers le répertoire parent

Le répertoire parent est symbolisé par `..` (deux points). C'est l'une des notations les plus utilisées :

```bash
cd /var/log
cd ..
pwd
# /var
```

On peut enchaîner plusieurs remontées en une seule commande :

```bash
cd ../..
pwd
# /
```

### Revenir au répertoire personnel

Votre répertoire personnel (par exemple `/home/alice`) dispose de raccourcis dédiés :

```bash
cd
# équivalent à : cd ~
pwd
# /home/alice
```

`cd` sans argument et `cd ~` font exactement la même chose : ils vous ramènent chez vous, peu importe votre position de départ.

### Retourner au répertoire précédent

Le tiret `-` mémorise votre emplacement précédent et vous y ramène en une frappe :

```bash
cd /etc
cd /var/log
cd -
pwd
# /etc
```

C'est particulièrement utile pour basculer entre deux répertoires fréquemment visités. Répéter `cd -` fait l'aller-retour indéfiniment.

### Erreurs courantes

Si vous saisissez un chemin inexistant, le shell l'indique clairement :

```bash
cd /inexistant
# bash: cd: /inexistant: No such file or directory
```

Si vous tentez d'entrer dans un fichier (et non un répertoire) :

```bash
cd /etc/passwd
# bash: cd: /etc/passwd: Not a directory
```

Dans les deux cas, votre position courante est inchangée — vérifiez avec `pwd`.

---

## Lister le contenu : la commande `ls`

`ls` (List) affiche le contenu d'un répertoire. Sans argument, elle liste le répertoire courant :

```bash
ls
```

Exemple de résultat dans `/home/alice` :

```
Documents  Images  Musique  notes.txt  script.sh
```

Vous pouvez aussi lister n'importe quel répertoire sans vous y déplacer :

```bash
ls /etc
ls /var/log
```

### Format long : `ls -l`

L'option `-l` affiche une ligne détaillée par élément :

```bash
ls -l
```

Résultat type :

```
-rw-r--r-- 1 alice alice 2048 06 juin 14:22 notes.txt
drwxr-xr-x 3 alice alice 4096 01 juin 09:15 Documents
```

Chaque ligne se lit de gauche à droite :

| Colonne   | Exemple          | Signification                                   |
|-----------|------------------|-------------------------------------------------|
| Type + permissions | `-rw-r--r--` | `-` = fichier ordinaire, `d` = répertoire. Les 9 caractères suivants indiquent les droits (voir chapitre 5.2 pour le détail) |
| Liens     | `1`              | Nombre de liens physiques vers cet élément      |
| Propriétaire | `alice`       | Nom de l'utilisateur propriétaire               |
| Groupe    | `alice`          | Nom du groupe propriétaire                      |
| Taille    | `2048`           | Taille en octets                                |
| Date      | `06 juin 14:22`  | Dernière modification                           |
| Nom       | `notes.txt`      | Nom du fichier ou du répertoire                 |

Retenez simplement que le premier caractère distingue les types d'éléments : `-` pour un fichier ordinaire, `d` pour un répertoire. Les permissions feront l'objet du chapitre 5.2.

### Afficher les fichiers cachés : `ls -a`

Sous Linux, un fichier dont le nom commence par un point est **caché** — il n'apparaît pas avec `ls` simple. L'option `-a` (all) les inclut :

```bash
ls -a
```

Résultat type dans le répertoire personnel :

```
.  ..  .bashrc  .profile  .ssh  Documents  notes.txt
```

Deux entrées sont toujours présentes : `.` (le répertoire courant lui-même) et `..` (son parent). Les fichiers comme `.bashrc` ou `.profile` contiennent la configuration personnelle du shell.

### Tailles lisibles par l'humain : `ls -lh`

Par défaut, `ls -l` affiche les tailles en octets bruts. L'option `-h` (human-readable) les reformate en kilo-octets, méga-octets ou giga-octets selon le cas :

```bash
ls -lh
```

Résultat :

```
-rw-r--r-- 1 alice alice 2,0K 06 juin 14:22 notes.txt
drwxr-xr-x 3 alice alice 4,0K 01 juin 09:15 Documents
-rw-r--r-- 1 alice alice 1,5M 03 juin 11:00 archive.tar.gz
```

`-h` n'a d'effet qu'associé à `-l` : sans le format long, il n'y a pas de colonne de taille à reformater.

### Combiner les options

Les options de `ls` se combinent en une seule chaîne. La combinaison la plus utile en pratique est `ls -la` ou `ls -lah` :

```bash
ls -la       # Format long + fichiers cachés
ls -lah      # Format long + fichiers cachés + tailles lisibles
```

---

## L'essentiel

| Commande      | Usage type                                          |
|---------------|-----------------------------------------------------|
| `pwd`         | Afficher le chemin du répertoire courant            |
| `cd /chemin`  | Aller dans un répertoire via un chemin absolu       |
| `cd répertoire` | Aller dans un répertoire via un chemin relatif   |
| `cd`          | Retourner au répertoire personnel                   |
| `cd ..`       | Remonter d'un niveau vers le répertoire parent      |
| `cd -`        | Revenir au répertoire précédent                     |
| `ls`          | Lister le contenu du répertoire courant             |
| `ls -l`       | Affichage détaillé (permissions, taille, date...)   |
| `ls -a`       | Inclure les fichiers cachés (nom commençant par `.`) |
| `ls -lh`      | Format long avec tailles lisibles (K, M, G)         |
| `ls -la`      | Format long + tous les fichiers (cachés inclus)     |

---

## Pour aller plus loin

### Tris avec `ls`

`ls` propose plusieurs critères de tri qui s'avèrent très pratiques selon le contexte :

```bash
ls -lt       # Trier par date de modification, le plus récent en premier
ls -lS       # Trier par taille, le plus gros en premier
ls -lr       # Inverser l'ordre de tri (applicable à tout critère)
```

On les combine souvent :

```bash
ls -ltr      # Par date, ordre croissant : les plus anciens en tête
             # Très utile pour les journaux système (/var/log)

ls -lSr      # Par taille, ordre croissant : les plus petits en tête
```

Exemple concret dans les journaux système :

```bash
cd /var/log
ls -ltr | tail -5
# Affiche les 5 fichiers modifiés le plus récemment
```

### La commande `tree`

`tree` dessine l'arborescence complète à partir d'un répertoire. Elle n'est pas installée par défaut sur toutes les distributions :

```bash
sudo apt install tree    # Debian / Ubuntu
```

Utilisation courante :

```bash
tree                     # Arborescence du répertoire courant
tree /home               # Arborescence de /home
tree -L 2 /              # Limiter la profondeur à 2 niveaux
tree -d /usr             # Afficher uniquement les répertoires
tree -a                  # Inclure les fichiers cachés
```

La profondeur `-L 2` est particulièrement utile pour avoir une vue d'ensemble sans être noyé dans les détails :

```bash
tree -L 2 /home
# /home
# +-- alice
#     +-- Documents
#     +-- Images
#     +-- notes.txt
```

Note : `tree` utilise des caractères graphiques pour ses lignes de dessin. Certains terminaux ou exports PDF préfèrent la version ASCII simple obtenue avec `tree --charset ascii`.

### Combinaisons courantes

Voici quelques enchainements fréquents que vous utiliserez régulièrement :

```bash
ls -latr           # Tout afficher, par date croissante : idéal pour retrouver
                   # le fichier le plus récemment modifié dans un grand répertoire

ls -lah            # Format complet avec tailles lisibles : la vue la plus
                   # informative au quotidien

ls -lS /var/log    # Trouver les fichiers de journaux les plus volumineux
                   # sans quitter son répertoire courant
```

### La complétion automatique

La touche `Tab` complète automatiquement les chemins. Si vous tapez `cd /var/l` puis appuyez sur `Tab`, le shell complète en `cd /var/log/` s'il n'y a qu'une seule possibilité. S'il y en a plusieurs, un second appui sur `Tab` affiche la liste. C'est une habitude qui économise beaucoup de frappe et évite les erreurs de saisie.

---

## Exercices

Ces exercices se réalisent dans un terminal connecté à votre système Linux (VM ou session SSH). Aucune connaissance préalable de `mkdir` ou d'autres commandes n'est requise.

### Exercice 1 — Repérage initial

1. Ouvrez un terminal. Affichez votre répertoire courant.
2. Listez le contenu de ce répertoire en format long, fichiers cachés inclus, avec des tailles lisibles.
3. Notez le nom d'au moins un fichier caché que vous observez.

### Exercice 2 — Exploration de la racine

1. Allez à la racine du système de fichiers.
2. Affichez son contenu en format simple, puis en format long.
3. Repérez les répertoires `etc`, `home`, `var` et `usr`. Sont-ils des fichiers ou des répertoires ? (Indice : regardez le premier caractère de chaque ligne dans `ls -l`.)

### Exercice 3 — Navigation relative et absolue

À partir de la racine `/` :

1. Allez dans `/usr/bin` en une seule commande avec un chemin absolu.
2. Remontez de deux niveaux avec un chemin relatif. Où vous trouvez-vous ?
3. Allez dans `/var/log` avec un chemin absolu.
4. Revenez au répertoire précédent sans retaper son chemin.

### Exercice 4 — Retour au répertoire personnel

1. Depuis `/var/log`, revenez à votre répertoire personnel en utilisant `cd` seul.
2. Vérifiez votre position.
3. Allez dans `/etc` puis revenez à votre répertoire personnel en utilisant `cd ~` cette fois.
4. Les deux méthodes sont-elles équivalentes ?

### Exercice 5 — Maîtrise de `ls`

1. Allez dans `/var/log`.
2. Affichez les fichiers triés par date de modification, du plus ancien au plus récent.
3. Affichez les 5 fichiers les plus volumineux (du plus gros au plus petit).
4. Listez le contenu de `/etc` depuis `/var/log` sans vous y déplacer.

### Exercice 6 — Défi navigation

Vous partez de `/usr/local/bin`. Allez jusqu'à `/var/log` en utilisant **uniquement des chemins relatifs** — aucun chemin absolu autorisé.

Indice : comptez les niveaux à remonter avant de redescendre.

---

### Solutions

**Exercice 1**

```bash
pwd
ls -lah
```

Les fichiers cachés commencent par `.` : `.bashrc`, `.profile`, `.ssh` sont les plus fréquents dans un répertoire personnel.

---

**Exercice 2**

```bash
cd /
ls
ls -l
```

Les lignes commençant par `d` dans `ls -l` désignent des répertoires : `etc`, `home`, `var` et `usr` sont tous des répertoires (`drwxr-xr-x` ou similaire en première colonne).

---

**Exercice 3**

```bash
cd /usr/bin
pwd
# /usr/bin

cd ../..
pwd
# /

cd /var/log
pwd
# /var/log

cd -
pwd
# /usr/bin  (ou le répertoire précédent)
```

Note : après l'étape 2, vous êtes en `/`. `cd -` au point 4 vous ramène à `/var/log`, qui était la position précédente.

---

**Exercice 4**

```bash
cd /var/log
cd
pwd
# /home/alice  (ou votre répertoire personnel)

cd /etc
cd ~
pwd
# /home/alice
```

Oui, `cd` seul et `cd ~` sont strictement équivalents : les deux ramènent au répertoire personnel.

---

**Exercice 5**

```bash
cd /var/log
ls -ltr
ls -lS | head -5
ls /etc
```

`ls -ltr` trie par date croissante (le plus ancien en premier, le plus récent en dernier). `ls -lS` trie par taille décroissante ; `head -5` limite l'affichage aux 5 premiers. La dernière commande liste `/etc` sans quitter `/var/log`.

---

**Exercice 6**

```bash
cd /usr/local/bin
cd ../../..    # /usr/local/bin -> /usr/local -> /usr -> /
cd var
cd log
pwd
# /var/log
```

Explication : depuis `/usr/local/bin`, il faut remonter trois niveaux (`../../../`) pour atteindre la racine `/`, puis descendre dans `var` puis `log`. On peut aussi tout écrire en une seule commande :

```bash
cd ../../../var/log
```
