# Chapitre 8.1 — Redirections et pipes

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - Distinguer les trois flux standard (entrée, sortie, erreur) d'un processus Linux.
> - Rediriger ces flux vers des fichiers avec `>`, `>>`, `2>` et `<`.
> - Enchaîner des commandes avec le pipe `|` pour construire des traitements à la volée.
> - Utiliser `sort`, `uniq` et `wc` comme outils indispensables dans un pipeline.
>
> **Durée en séance** : ~30 min.

---

## Les trois flux standard

Sous Linux, tout programme communique via trois canaux prédéfinis, identifiés par un numéro appelé *descripteur de fichier* :

```
+------------+     stdin (0)     +------------+
|            | <---------------- |            |
|  clavier   |                   |  processus |
|  fichier   |     stdout (1)    |  (ls, grep |
|            | ----------------> |   cat...)  |
+------------+     stderr (2)    |            |
                   ------------> +------------+
                        |
                        v
                   terminal / fichier
```

- **stdin (0)** — l'entrée standard. Par défaut, le clavier.
- **stdout (1)** — la sortie standard. Par défaut, le terminal.
- **stderr (2)** — la sortie d'erreur. Par défaut, le terminal également.

Pourquoi deux sorties distinctes ? Pour pouvoir traiter résultats et erreurs séparément — enregistrer un rapport tout en laissant les erreurs s'afficher à l'écran, ou au contraire silencier les erreurs pour ne traiter que le résultat utile.

Exemple concret : la commande `ls /home /inexistant` produit à la fois une sortie normale (le contenu de `/home`) et un message d'erreur (répertoire introuvable). Ces deux flux arrivent séparément.

---

## Rediriger les flux

### Rediriger la sortie vers un fichier

L'opérateur `>` redirige stdout vers un fichier. Si le fichier existe, il est **écrasé** :

```bash
ls /etc > liste_etc.txt
```

Pour **ajouter** au lieu d'écraser, utilisez `>>` :

```bash
echo "---" >> journal.txt
date >> journal.txt
uptime >> journal.txt
```

Chaque exécution ajoute une ligne à la suite. C'est le mécanisme de base d'un fichier de log.

### Rediriger les erreurs

L'opérateur `2>` redirige uniquement stderr :

```bash
ls /home /inexistant > sorties.txt 2> erreurs.txt
```

Après exécution, `sorties.txt` contient le résultat normal et `erreurs.txt` contient le message d'erreur. Les deux flux ont été traités indépendamment.

### Rediriger l'entrée depuis un fichier

L'opérateur `<` fournit le contenu d'un fichier comme entrée standard :

```bash
sort < prenoms.txt
wc -l < prenoms.txt
```

C'est moins courant car la plupart des commandes acceptent un nom de fichier en argument, mais la syntaxe est utile dans certains scripts.

### Récapitulatif des quatre opérateurs

| Opérateur | Flux redirigé | Comportement |
|-----------|--------------|--------------|
| `>`       | stdout (1)   | Écrase le fichier |
| `>>`      | stdout (1)   | Ajoute au fichier |
| `2>`      | stderr (2)   | Écrase le fichier |
| `<`       | stdin (0)    | Lit depuis un fichier |

---

## Enchaîner : le pipe

### Principe

Le caractère `|` (barre verticale, ou *pipe*) connecte la sortie d'une commande à l'entrée de la suivante, **sans passer par un fichier intermédiaire** :

```
commande1 | commande2 | commande3
```

stdout de `commande1` devient stdin de `commande2`, et ainsi de suite. Le tout s'exécute en parallèle dans le même shell — les données circulent en flux continu.

### Exemples avec des commandes déjà vues

Compter le nombre de fichiers dans le répertoire courant :

```bash
ls | wc -l
```

Chercher un processus précis parmi tous les processus actifs :

```bash
ps aux | grep sshd
```

Retrouver dans l'historique toutes les commandes `find` déjà exécutées (voir chapitre 4.3 pour `grep`) :

```bash
history | grep find
```

Lister les fichiers `.conf` présents dans `/etc`, triés par ordre alphabétique :

```bash
ls /etc | grep ".conf" | sort
```

### Trois outils indispensables dans un pipeline

Ces commandes n'ont d'intérêt que combinées avec d'autres via le pipe :

**`wc`** — compte des lignes, mots ou caractères.

```bash
wc -l fichier.txt    # nombre de lignes d'un fichier
ls /etc | wc -l      # nombre d'entrées dans /etc
```

Options utiles : `-l` (lignes), `-w` (mots), `-c` (octets).

**`sort`** — trie les lignes reçues sur stdin.

```bash
cat prenoms.txt | sort        # tri alphabétique
cat prenoms.txt | sort -r     # tri inverse
ps aux | sort -k3 -nr         # tri numérique inversé sur la 3e colonne (CPU)
```

Options utiles : `-r` (inversé), `-n` (numérique), `-k N` (colonne N).

**`uniq`** — supprime les lignes consécutives identiques. Il faut donc presque toujours trier avant :

```bash
cat villes.txt | sort | uniq          # valeurs uniques
cat villes.txt | sort | uniq -c       # avec comptage des occurrences
cat villes.txt | sort | uniq -d       # uniquement les doublons
```

### Pipeline complet : exemple réel

Quels sont les shells utilisés par les comptes du système, et combien de fois chacun ?

```bash
cut -d: -f7 /etc/passwd | sort | uniq -c | sort -nr
```

Décomposition :
1. `cut -d: -f7 /etc/passwd` — extrait la 7e colonne (le shell) de chaque ligne de `/etc/passwd`.
2. `sort` — trie pour regrouper les valeurs identiques.
3. `uniq -c` — compte les occurrences de chaque shell.
4. `sort -nr` — trie par fréquence décroissante.

---

## L'essentiel

| Syntaxe                  | Usage type                                      |
|--------------------------|-------------------------------------------------|
| `commande > fichier`     | Sauvegarder la sortie (écrase)                  |
| `commande >> fichier`    | Alimenter un journal (ajoute)                   |
| `commande 2> fichier`    | Capturer uniquement les erreurs                 |
| `commande < fichier`     | Fournir un fichier comme entrée                 |
| `cmd1 | cmd2`            | Envoyer la sortie de cmd1 vers l'entrée de cmd2 |
| `... | wc -l`            | Compter les lignes résultantes                  |
| `... | sort`             | Trier les lignes résultantes                    |
| `... | sort | uniq -c`   | Compter les occurrences distinctes              |
| `... | grep motif`       | Filtrer les lignes contenant un motif           |
| `... | head -10`         | Ne conserver que les 10 premières lignes        |

---

## Pour aller plus loin

### Combiner stdout et stderr : `2>&1`

Pour rediriger les deux flux vers le même fichier, il faut d'abord rediriger stdout puis y rattacher stderr :

```bash
ls /home /inexistant > tout.txt 2>&1
```

L'ordre compte : `2>&1` signifie « redirige stderr vers là où pointe stdout à cet instant ». Si l'on inverse, le résultat est incorrect.

Bash moderne propose une syntaxe raccourcie équivalente :

```bash
ls /home /inexistant &> tout.txt
```

### La poubelle système : `/dev/null`

`/dev/null` est un fichier spécial qui absorbe tout ce qu'on lui envoie. Il sert à silencier des sorties indésirables :

```bash
commande > /dev/null          # ignorer stdout
commande 2> /dev/null         # ignorer stderr
commande > /dev/null 2>&1     # ignorer tout
```

Exemple utile : vérifier si une commande réussit sans afficher quoi que ce soit :

```bash
grep -q "root" /etc/passwd && echo "Utilisateur root trouvé"
```

### Dupliquer le flux avec `tee`

`tee` écrit sur stdout **et** dans un fichier simultanément, comme un té de plomberie :

```bash
ps aux | tee processus_backup.txt | grep sshd
```

La liste complète des processus est sauvegardée, et seules les lignes `sshd` s'affichent. L'option `-a` permet d'ajouter au lieu d'écraser.

### Transformer stdin en arguments : `xargs`

Certaines commandes n'acceptent pas stdin (elles attendent des arguments). `xargs` fait le pont :

```bash
find . -name "*.log" | xargs wc -l
```

Sans `xargs`, `wc -l` ne saurait pas quoi compter. Avec `xargs`, il reçoit les noms de fichiers comme arguments.

L'option `-I {}` permet de contrôler l'emplacement de l'argument dans la commande cible :

```bash
find . -name "*.txt" | xargs -I {} cp {} ~/sauvegardes/
```

### Résumé des outils avancés

| Syntaxe               | Effet                                            |
|-----------------------|--------------------------------------------------|
| `cmd > f 2>&1`        | Fusionner stdout et stderr dans un fichier       |
| `cmd &> f`            | Idem, syntaxe courte (bash uniquement)           |
| `cmd > /dev/null`     | Silencier la sortie                              |
| `cmd | tee f`         | Sortie à l'écran ET dans un fichier              |
| `cmd | tee -a f`      | Sortie à l'écran ET ajout dans un fichier        |
| `cmd | xargs autre`   | Passer les résultats comme arguments             |

---

## Exercices

### Exercice 1 — Inventaire des processus

Affichez uniquement les 5 processus qui consomment le plus de mémoire vive, avec leur propriétaire et leur nom.

Indice : `ps aux` affiche les colonnes `%MEM` en position 4 et le nom en position 11.

---

### Exercice 2 — Compter les erreurs d'un journal

Créez un fichier `journal.log` contenant les lignes suivantes, puis répondez aux questions en une seule commande chacune :

```bash
echo "INFO: démarrage du service" > journal.log
echo "ERREUR: connexion refusée" >> journal.log
echo "INFO: utilisateur connecté" >> journal.log
echo "ERREUR: fichier introuvable" >> journal.log
echo "WARNING: espace disque faible" >> journal.log
echo "ERREUR: timeout réseau" >> journal.log
```

a) Combien de lignes de type `ERREUR` contient le fichier ?  
b) Affichez uniquement les lignes `INFO`, triées par ordre alphabétique.  
c) Combien de mots au total contient le fichier ?

---

### Exercice 3 — Fréquence des commandes utilisées

En combinant `history`, `awk`, `sort` et `uniq`, affichez vos 10 commandes les plus fréquemment tapées, avec leur nombre d'occurrences.

Indice : `awk '{print $2}'` extrait la deuxième colonne de chaque ligne de `history`.

---

### Exercice 4 — Taille des répertoires personnels

Listez tous les répertoires présents dans `/home`, triés par ordre alphabétique inverse, et enregistrez ce résultat dans un fichier `repertoires_home.txt` **tout en l'affichant à l'écran**.

Indice : `tee`.

---

### Exercice 5 — Shells du système

Sans ouvrir le fichier `/etc/passwd` dans un éditeur, répondez en une seule commande : quels shells sont utilisés sur ce système, et par combien de comptes chacun ?

Indice : le shell se trouve dans la 7e colonne, séparateur `:`.

---

### Exercice 6 — Rapport vers fichier

Redirigez dans un fichier `rapport_systeme.txt` les informations suivantes, les unes après les autres (utilisez `>>`) :
- La date et l'heure actuelles.
- Le nombre de processus actifs.
- L'espace disque disponible sur la partition racine.

Vérifiez le contenu final avec `cat rapport_systeme.txt`.

---

### Solutions

**Exercice 1**

```bash
ps aux | sort -k4 -nr | head -5 | awk '{print $1, $4, $11}'
```

`sort -k4 -nr` trie sur la colonne 4 (`%MEM`) de façon numérique décroissante. `head -5` ne garde que les cinq premières lignes. `awk` extrait propriétaire, pourcentage mémoire et nom.

---

**Exercice 2a** — Compter les erreurs :

```bash
grep "ERREUR" journal.log | wc -l
```

Résultat attendu : `3`

**Exercice 2b** — Lignes INFO triées :

```bash
grep "INFO" journal.log | sort
```

**Exercice 2c** — Nombre total de mots :

```bash
wc -w < journal.log
```

---

**Exercice 3**

```bash
history | awk '{print $2}' | sort | uniq -c | sort -nr | head -10
```

Étapes : `awk` extrait le nom de la commande (2e colonne), `sort` regroupe les occurrences identiques, `uniq -c` les compte, `sort -nr` trie par fréquence décroissante, `head -10` limite à 10 résultats.

---

**Exercice 4**

```bash
ls /home | sort -r | tee repertoires_home.txt
```

`sort -r` trie en ordre inverse. `tee` affiche à l'écran et écrit dans le fichier simultanément.

---

**Exercice 5**

```bash
cut -d: -f7 /etc/passwd | sort | uniq -c | sort -nr
```

`cut -d: -f7` extrait la 7e colonne en utilisant `:` comme séparateur. Le reste du pipeline compte et trie les occurrences.

---

**Exercice 6**

```bash
date >> rapport_systeme.txt
ps aux | wc -l >> rapport_systeme.txt
df -h / | tail -1 >> rapport_systeme.txt
cat rapport_systeme.txt
```

Chaque commande ajoute sa sortie au fichier. `df -h /` affiche les informations de la partition racine ; `tail -1` élimine la ligne d'en-tête.
