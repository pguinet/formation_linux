# Chapitre 1.2 — Premier contact avec le terminal

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - distinguer terminal, shell et prompt ;
> - décomposer et saisir une commande Linux correctement ;
> - obtenir de l'aide sans quitter le terminal ;
> - gagner du temps grâce à la complétion et à l'historique.
>
> **Durée en séance** : ~30 min.

---

## Terminal, shell, prompt

### Qu'est-ce que le terminal ?

Lorsque vous ouvrez une fenêtre noire où vous pouvez taper des commandes, vous utilisez un **terminal** (ou émulateur de terminal). C'est simplement un affichage texte : il reçoit ce que vous tapez et affiche les réponses du système.

À l'intérieur du terminal s'exécute un **shell**, c'est-à-dire un interpréteur de commandes. Le shell lit ce que vous tapez, l'interprète, demande au système de l'exécuter, puis affiche le résultat. Sous Debian et Ubuntu, le shell par défaut est **bash** (Bourne Again SHell).

Retenez la distinction :

```
+-----------+       +-------+       +--------+
| Terminal  | <---> | Shell | <---> | Noyau  |
| (affiche) |       | (bash)|       | Linux  |
+-----------+       +-------+       +--------+
```

Le terminal est la fenêtre ; le shell est le programme qui tourne dedans ; le noyau Linux est le cœur du système que le shell interroge.

### Anatomie du prompt

Dès que le shell est prêt à recevoir une commande, il affiche une ligne d'invitation appelée **prompt** :

```
alice@debian:~$
```

Chaque élément a une signification précise :

| Élément       | Signification                                              |
|---------------|------------------------------------------------------------|
| `alice`       | Votre nom d'utilisateur                                    |
| `@`           | Séparateur                                                 |
| `debian`      | Nom de la machine                                          |
| `:`           | Séparateur                                                 |
| `~`           | Répertoire courant (`~` désigne votre dossier personnel)   |
| `$`           | Vous êtes un utilisateur ordinaire (`#` indique root)      |

Quand vous naviguez vers un autre dossier, le prompt se met à jour :

```
alice@debian:/var/log$
```

Vous savez ainsi en permanence où vous vous trouvez dans l'arborescence — c'est une information précieuse pour éviter de travailler dans le mauvais répertoire.

---

## Anatomie d'une commande

La structure générale d'une commande Linux est la suivante :

```
commande [options] [arguments]
```

- **commande** : le programme à exécuter.
- **options** : des modificateurs qui changent le comportement. Elles commencent par un tiret (`-l`) ou deux tirets (`--long`).
- **arguments** : les cibles sur lesquelles la commande opère (fichiers, répertoires, textes...).

### Exemple concret avec `ls`

```bash
ls -l /home
```

- `ls` : lister le contenu d'un répertoire.
- `-l` : format long (affiche les permissions, le propriétaire, la taille, la date).
- `/home` : le répertoire à examiner.

Résultat typique :

```
total 4
drwxr-xr-x 3 alice alice 4096 10 juin  09:15 alice
drwxr-xr-x 2 bob   bob   4096  8 juin  14:30 bob
```

On peut combiner plusieurs options courtes en une seule :

```bash
ls -la /home
# équivaut à : ls -l -a /home
# -a : afficher aussi les fichiers cachés (qui commencent par un point)
```

### Options courtes et options longues

La plupart des commandes proposent deux formes pour les options :

```bash
ls -l          # option courte  : un seul tiret, une lettre
ls --long      # option longue  : deux tirets, un mot complet
```

Les deux formes sont équivalentes. Les options courtes sont plus rapides à taper ; les options longues sont plus lisibles dans les scripts.

### Quelques commandes de repérage essentielles

Ces trois commandes vous serviront dès la première séance :

```bash
pwd        # Affiche le chemin du répertoire courant (Print Working Directory)
whoami     # Affiche votre nom d'utilisateur
hostname   # Affiche le nom de la machine
```

Elles ne prennent aucun argument et suffisent pour vous orienter après une connexion SSH sur un serveur inconnu.

---

## Obtenir de l'aide

Vous n'avez pas à mémoriser toutes les options de toutes les commandes. Linux fournit deux outils complémentaires pour consulter la documentation directement dans le terminal.

### La commande `man` (manuel)

```bash
man ls
```

`man` affiche le manuel complet de la commande. C'est la référence exhaustive : description, toutes les options, exemples, valeurs de retour.

Navigation à l'intérieur du manuel :

| Touche          | Action                                  |
|-----------------|-----------------------------------------|
| `Espace`        | Page suivante                           |
| `b`             | Page précédente                         |
| `/mot`          | Rechercher « mot » dans le manuel       |
| `n`             | Occurrence suivante de la recherche     |
| `q`             | Quitter le manuel                       |

Exemple de recherche : dans `man ls`, tapez `/sort` puis `n` pour passer d'une occurrence à l'autre et trouver rapidement les options de tri.

### L'option `--help`

```bash
ls --help
```

Affiche un résumé rapide des options, directement dans le terminal sans ouvrir un pagineur. Idéal quand vous avez juste besoin d'un rappel rapide sur une option précise. La sortie est plus courte que `man` et s'adapte mieux aux débutants.

**Règle pratique** : commencez par `--help` pour un rappel rapide ; ouvrez `man` quand vous avez besoin d'informations détaillées.

---

## Travailler plus vite

### Complétion avec la touche Tab

Le shell peut compléter automatiquement les noms de commandes et de fichiers. Appuyez sur **Tab** après avoir tapé les premiers caractères :

```bash
ls Doc[Tab]          # Complète en "Documents/" si ce répertoire existe
man ls[Tab][Tab]     # Double Tab : affiche toutes les commandes qui commencent par "ls"
cat /etc/host[Tab]   # Complète en "/etc/hosts"
```

Si la complétion est ambiguë (plusieurs possibilités), appuyez une deuxième fois sur Tab pour afficher la liste des candidats. La complétion évite les fautes de frappe et vous épargne de devoir retenir les noms exacts de fichiers.

### Historique avec les flèches du clavier

Le shell mémorise les commandes que vous avez saisies dans un fichier `~/.bash_history`. Vous pouvez y naviguer sans les retaper :

| Touche    | Action                              |
|-----------|-------------------------------------|
| `Flèche haut`  | Commande précédente dans l'historique |
| `Flèche bas`   | Commande suivante                     |
| `Ctrl+R`  | Recherche interactive dans l'historique (voir chapitre 6.3) |

La recherche `Ctrl+R` est particulièrement puissante : tapez quelques lettres d'une ancienne commande et le shell retrouve la dernière correspondance. Appuyez à nouveau sur `Ctrl+R` pour remonter plus loin dans l'historique.

### Effacer l'écran et quitter

```bash
clear      # Efface le contenu affiché (le terminal reste ouvert)
exit       # Ferme la session shell (ou la fenêtre de terminal)
```

`clear` ne supprime rien : il fait simplement défiler l'affichage vers le bas. Vous pouvez remonter avec la barre de défilement de la fenêtre.

### Interrompre une commande en cours : Ctrl+C

Si une commande tourne trop longtemps ou si vous l'avez lancée par erreur, **Ctrl+C** l'interrompt immédiatement et vous rend la main sur le prompt :

```bash
ping 8.8.8.8
# ...la commande tourne en boucle...
# Appuyez sur Ctrl+C
^C
alice@debian:~$
```

`^C` est la notation conventionnelle pour Ctrl+C dans les terminaux. Ne confondez pas avec Ctrl+C dans les éditeurs graphiques : ici, c'est une interruption, pas une copie.

---

## L'essentiel

| Commande / Raccourci   | Usage type                                               |
|------------------------|----------------------------------------------------------|
| `pwd`                  | Afficher le répertoire courant                           |
| `whoami`               | Afficher son nom d'utilisateur                           |
| `ls -l /chemin`        | Lister le contenu d'un répertoire en format long         |
| `man commande`         | Ouvrir le manuel complet d'une commande                  |
| `commande --help`      | Afficher l'aide rapide d'une commande                    |
| `clear`                | Effacer l'affichage du terminal                          |
| `exit`                 | Fermer la session shell                                  |
| Tab                    | Compléter automatiquement une commande ou un chemin      |
| Flèche haut / Flèche bas | Naviguer dans l'historique des commandes               |
| Ctrl+C                 | Interrompre une commande en cours                        |

---

## Pour aller plus loin

### Raccourcis clavier du shell

Le shell bash intègre de nombreux raccourcis qui permettent de se déplacer et d'éditer la ligne de commande sans souris. Les plus utiles :

| Raccourci  | Effet                                              |
|------------|----------------------------------------------------|
| `Ctrl+A`   | Aller au début de la ligne                         |
| `Ctrl+E`   | Aller à la fin de la ligne                         |
| `Ctrl+U`   | Supprimer tout ce qui précède le curseur           |
| `Ctrl+K`   | Supprimer tout ce qui suit le curseur              |
| `Ctrl+W`   | Supprimer le mot à gauche du curseur               |
| `Ctrl+L`   | Effacer l'écran (équivalent à `clear`)             |
| `Ctrl+R`   | Recherche interactive dans l'historique (voir chapitre 6.3) |

Ces raccourcis sont hérités de l'éditeur Emacs. Ils fonctionnent dans bash, dans la plupart des éditeurs de ligne de commande, et même dans certains champs de formulaire graphiques.

### Les différents shells

Bash est le shell le plus répandu sous Linux, mais il en existe d'autres :

| Shell  | Particularités                                                |
|--------|---------------------------------------------------------------|
| `bash` | Référence sur toutes les distributions Linux                  |
| `zsh`  | Très populaire, complétion avancée, thèmes (Oh My Zsh)       |
| `fish` | Syntaxe simplifiée, suggestions automatiques, adapté aux débutants |
| `sh`   | Shell POSIX minimal, utilisé dans les scripts portables       |

Pour savoir quel shell vous utilisez :

```bash
echo $SHELL
```

Dans le cadre de cette formation, nous travaillons exclusivement avec bash. Les concepts vus ici (prompt, historique, complétion) fonctionnent de la même façon sous zsh.

### La commande `apropos`

Si vous ne connaissez pas le nom exact d'une commande, `apropos` effectue une recherche par mot-clé dans les descriptions courtes de tous les manuels installés :

```bash
apropos "liste fichiers"
apropos network
```

La base de données est parfois à mettre à jour avec `sudo mandb` si les résultats semblent incomplets.

### La commande `info`

```bash
info ls
```

`info` est le système de documentation du projet GNU. Il présente l'information sous forme de pages hypertexte navigables avec les flèches et la touche Entrée. Certains programmes GNU (comme `ls`, `cp`, `tar`) ont des pages `info` plus complètes que leurs pages `man`.

---

## Exercices

### Exercice 1 — Se repérer dans le terminal

Ouvrez un terminal et exécutez les commandes suivantes dans l'ordre. Notez ce qu'affiche chacune.

1. Affichez votre répertoire courant.
2. Affichez votre nom d'utilisateur.
3. Listez le contenu de votre répertoire personnel en format long.
4. Listez le même répertoire en incluant les fichiers cachés.

### Exercice 2 — Consulter l'aide

1. Ouvrez le manuel de la commande `ls`.
2. Dans ce manuel, recherchez le mot `sort` avec la touche `/`.
3. Identifiez l'option qui trie les fichiers par taille.
4. Quittez le manuel avec `q`.
5. Affichez ensuite l'aide rapide de la commande `pwd`.

### Exercice 3 — La complétion Tab

1. Tapez `ls /et` puis appuyez sur Tab. Que se passe-t-il ?
2. Tapez `man ls` puis appuyez sur Tab deux fois. Que voyez-vous ?
3. Tapez `cd /home/` puis Tab. Quels répertoires sont proposés ?

### Exercice 4 — L'historique de commandes

1. Exécutez les commandes suivantes une à une :
   ```bash
   date
   whoami
   pwd
   hostname
   ```
2. Utilisez la flèche haut pour retrouver la commande `whoami` sans la retaper.
3. Appuyez sur Ctrl+R, tapez `dat` et observez la suggestion proposée par le shell.
4. Appuyez sur Entrée pour exécuter la commande trouvée.

### Exercice 5 — Interrompre une commande

1. Lancez la commande suivante :
   ```bash
   ping 127.0.0.1
   ```
2. Observez que la commande tourne en boucle et affiche des lignes en continu.
3. Interrompez-la avec Ctrl+C.
4. Vérifiez que le prompt est revenu et que vous pouvez à nouveau saisir des commandes.

---

### Solutions

**Exercice 1**

```bash
# 1. Répertoire courant
pwd
# Résultat attendu : /home/votre_utilisateur (ou /root si vous êtes root)

# 2. Nom d'utilisateur
whoami
# Résultat attendu : votre_utilisateur

# 3. Liste en format long
ls -l
# Affiche les permissions, propriétaire, taille et date de chaque fichier

# 4. Liste avec fichiers cachés
ls -la
# Inclut les fichiers dont le nom commence par un point (.bashrc, .profile, etc.)
```

**Exercice 2**

```bash
# 1. Ouvrir le manuel de ls
man ls

# 2. Dans le manuel, taper :
/sort
# Le curseur saute à la première occurrence du mot "sort"

# 3. L'option qui trie par taille est -S (majuscule S)

# 4. Quitter le manuel
q

# 5. Aide de pwd
# pwd est une commande interne du shell : son aide s'obtient avec help pwd
help pwd
```

**Exercice 3**

1. Après `ls /et` + Tab, le shell complète automatiquement en `ls /etc/` car c'est le seul répertoire qui commence par `/et`.
2. Après `man ls` + Tab deux fois, le shell affiche toutes les commandes dont le nom commence par `ls` : `ls`, `lsblk`, `lscpu`, `lsmod`, etc.
3. Après `cd /home/` + Tab, le shell liste les sous-répertoires présents dans `/home` (les noms des utilisateurs du système).

**Exercice 4**

```bash
# 1. Exécuter les quatre commandes
date
whoami
pwd
hostname

# 2. Appuyer plusieurs fois sur la flèche haut
# L'historique remonte : hostname -> pwd -> whoami
# Appuyer sur Entrée pour exécuter whoami

# 3. Ctrl+R, puis taper "dat"
# Le shell affiche : (reverse-i-search)`dat': date
# Appuyer sur Entrée pour relancer date
```

**Exercice 5**

```bash
# 1. Lancer ping
ping 127.0.0.1
# Le terminal affiche des lignes de type :
# 64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.04 ms
# 64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.03 ms
# ...

# 3. Appuyer sur Ctrl+C
# Le terminal affiche ^C et les statistiques ping, puis rend la main

# 4. Le prompt réapparait, vous pouvez saisir une nouvelle commande
```
