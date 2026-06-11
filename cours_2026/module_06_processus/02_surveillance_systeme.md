# Chapitre 6.2 — Surveillance système

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - lire la sortie de `df -h` pour connaître l'espace disque disponible sur chaque partition ;
> - utiliser `du -sh` pour mesurer la taille d'un répertoire et comprendre la différence avec `df` ;
> - interpréter la sortie de `free -h`, en particulier la colonne `available` et le rôle du cache ;
> - lire le load average affiché par `uptime` et en tirer une conclusion en une phrase.
>
> **Durée en séance** : ~30 min.

---

## Espace disque : `df` et `du`

### `df -h` — l'occupation de chaque partition

La commande `df` (« disk free ») donne, pour chaque système de fichiers monté, la taille totale, l'espace utilisé et l'espace disponible. L'option `-h` (*human-readable*) convertit les octets en Ko, Mo, Go ou To selon ce qui est le plus lisible.

```bash
df -h
```

Exemple de sortie :

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        20G   15G  4.2G  79%  /
/dev/sda2       100G   45G   50G  48%  /home
tmpfs           2.0G     0  2.0G   0%  /tmp
```

Ce qu'il faut lire en priorité :

- la colonne **Use%** : au-delà de 80 %, la partition mérite une surveillance renforcée ; au-delà de 90 %, c'est critique.
- la colonne **Avail** : c'est l'espace réellement libre que vous pouvez utiliser.
- le point de montage (**Mounted on**) : `/` c'est la racine du système, `/home` c'est vos données personnelles.

La ligne `tmpfs` correspond à de la mémoire vive utilisée comme disque (fichiers temporaires) ; elle n'est généralement pas à surveiller de la même façon.

Pour n'afficher que les partitions « physiques » (et écarter les pseudo-systèmes comme `tmpfs` ou `devtmpfs`) :

```bash
df -h -x tmpfs -x devtmpfs
```

### `du -sh` — la taille d'un répertoire

`df` travaille au niveau de la partition entière. Pour savoir *quelle partie* de cette partition est occupée, on utilise `du` (« disk usage »).

L'option `-s` (*summarize*) donne un total unique au lieu de détailler chaque sous-répertoire. L'option `-h` est, là encore, pour la lisibilité.

```bash
du -sh ~/Documents
du -sh /var/log
```

La différence fondamentale avec `df` :

| Commande | Unité de mesure | Réponse à la question |
|----------|-----------------|----------------------|
| `df -h`  | partition entière | Combien reste-t-il de libre sur `/home` ? |
| `du -sh` | répertoire donné  | Combien pèse ce dossier ? |

En pratique, les deux se complètent : `df` vous dit qu'une partition est pleine ; `du` vous dit *où*.

---

## Mémoire : `free -h`

La commande `free` affiche l'état de la RAM et du swap.

```bash
free -h
```

Exemple de sortie :

```
              total        used        free      shared  buff/cache   available
Mem:           8.0G        2.1G        1.2G        180M        4.7G        5.4G
Swap:          2.0G        256M        1.7G
```

### Lire la colonne `available`

La colonne qui compte vraiment est **available**, pas `free`. Voici pourquoi : Linux utilise la mémoire inutilisée comme cache disque (colonne `buff/cache`). Ce cache accélère les lectures, mais il est immédiatement récupérable si une application en a besoin. La colonne `free` ne compte pas ce cache récupérable ; `available`, elle, l'intègre.

Règle pratique : si `available` passe sous 10 % du `total`, le système risque de commencer à utiliser le swap de façon intensive, ce qui ralentit considérablement les performances.

### Le swap : indicateur de tension mémoire

Le swap est un espace sur le disque que le noyau utilise lorsque la RAM est saturée. Un swap non nul n'est pas forcément alarmant (Linux peut déplacer en swap des pages inactives de façon préventive), mais un **swap utilisé à plus de 50 %** du total est un signe que la machine manque de RAM.

### Résumé des colonnes

| Colonne      | Signification |
|--------------|---------------|
| `total`      | RAM physique installée |
| `used`       | occupée par les processus actifs |
| `free`       | complètement libre (souvent trompeur) |
| `buff/cache` | cache disque récupérable automatiquement |
| `available`  | mémoire réellement disponible pour une nouvelle appli |

---

## Charge et durée de fonctionnement : `uptime`

```bash
uptime
```

Exemple de sortie :

```
15:30:42 up 5 days,  2:15,  3 users,  load average: 0.75, 0.60, 0.45
```

La sortie se lit de gauche à droite :

- **heure actuelle** : 15:30:42
- **durée de fonctionnement** : 5 jours et 2 h 15 min depuis le dernier démarrage
- **utilisateurs connectés** : 3 sessions ouvertes
- **load average** : trois valeurs — charge moyenne sur **1 min**, **5 min** et **15 min**

### Interpréter le load average en une phrase

Le load average représente le nombre moyen de processus qui attendent ou utilisent le CPU. Pour un système à **N coeurs**, une valeur inférieure ou égale à **N** signifie que le processeur n'est pas saturé ; au-delà, des processus font la queue.

Exemple concret : sur une machine avec 2 coeurs, un load average de `1.50` sur 1 min est confortable ; un load average de `3.20` signifie que le CPU est débordé et que des processus attendent.

Pour connaître le nombre de coeurs disponibles :

```bash
nproc
```

### Les trois valeurs du load average

Les trois valeurs permettent de distinguer un pic passager d'une surcharge durable :

- Load 1 min élevé, 15 min bas : pic ponctuel, souvent sans gravité.
- Load 1 min et 15 min tous deux élevés : la machine est sous pression depuis longtemps.
- Load 1 min inférieur à 15 min : la charge est en train de diminuer.

---

## L'essentiel

| Commande | Usage type |
|----------|-----------|
| `df -h` | Voir l'espace libre et le taux d'occupation de chaque partition |
| `df -h -x tmpfs -x devtmpfs` | Idem, sans les systèmes de fichiers virtuels |
| `du -sh <dossier>` | Connaître la taille d'un répertoire précis |
| `du -h --max-depth=1 ~ \| sort -h` | Trouver les sous-dossiers les plus lourds de son home |
| `free -h` | État de la RAM — regarder la colonne `available` |
| `uptime` | Durée de fonctionnement et load average (1/5/15 min) |
| `nproc` | Nombre de coeurs CPU (pour interpréter le load average) |

---

## Pour aller plus loin

### Identifier ce qui prend de la place avec `du`

Pour trouver les sous-répertoires les plus volumineux à un niveau de profondeur donné, combinez `du` avec `sort` (voir chapitre 8.1 pour les pipes) :

```bash
# Les dossiers les plus lourds de son home, triés du plus léger au plus lourd
du -h --max-depth=1 ~ | sort -h

# Même chose dans /var (nécessite souvent sudo)
sudo du -h --max-depth=1 /var | sort -h
```

L'option `--max-depth=1` évite de descendre dans tous les sous-dossiers, ce qui rendrait la sortie illisible. L'option `-h` de `sort` comprend les suffixes K, M, G.

Pour trouver les fichiers individuels les plus lourds (pas seulement les dossiers) :

```bash
find ~ -type f -size +100M 2>/dev/null
```

### `vmstat` — vue d'ensemble CPU, mémoire et I/O

`vmstat` donne en une seule ligne un instantané des ressources système. Appelé avec un intervalle et un compteur, il rafraîchit l'affichage en continu :

```bash
vmstat 2 5    # 5 mesures toutes les 2 secondes
```

Les colonnes utiles pour un débutant :

- `r` : processus en attente du CPU (si régulièrement > nombre de coeurs, le CPU est saturé)
- `si` / `so` : pages échangées en entrée/sortie depuis le swap — des valeurs non nulles persistantes signalent un manque de RAM
- `id` : pourcentage du temps CPU inactif — un `id` proche de 0 signifie un CPU très sollicité

### `/proc/meminfo` — les chiffres bruts de la mémoire

Le fichier `/proc/meminfo` expose les statistiques mémoire du noyau en temps réel. `free` en est une présentation simplifiée. Pour les valeurs précises en kilo-octets :

```bash
grep -E "MemTotal|MemAvailable|SwapTotal|SwapFree" /proc/meminfo
```

### Interpréter finement le load average

Le load average de Linux ne compte pas uniquement les processus en attente de CPU : il inclut aussi ceux qui attendent une opération d'entrée/sortie (lecture disque, réseau). Un load élevé avec un CPU idle important peut donc trahir un problème de disque plutôt que de processeur. `vmstat` permet de distinguer les deux : une colonne `wa` (I/O wait) élevée dans la section CPU confirme l'hypothèse disque.

---

## Exercices

### Exercice 1 — Lire l'espace disque

Exécutez `df -h` sur votre machine et répondez aux questions suivantes :

1. Quelle est la partition la plus remplie (en pourcentage) ?
2. Combien d'espace libre reste-t-il sur la partition qui contient `/home` (ou sur `/` si `/home` n'est pas une partition séparée) ?
3. Listez uniquement les partitions physiques en excluant `tmpfs` et `devtmpfs`.

### Exercice 2 — Trouver le plus gros répertoire de son home

Identifiez quel sous-répertoire de votre dossier personnel occupe le plus de place.

1. Utilisez `du -h --max-depth=1 ~` pour lister les tailles.
2. Triez la sortie pour faire apparaître le plus lourd en dernier.
3. Entrez dans ce répertoire et relancez la commande pour descendre d'un niveau.

### Exercice 3 — Vérifier la mémoire disponible

1. Exécutez `free -h` et notez la valeur de la colonne `available`.
2. Calculez mentalement ou avec `echo` si cette valeur représente plus ou moins de 20 % du `total`.
3. Observez la colonne `buff/cache` : est-elle importante ? Que se passerait-il si une application demandait plus de mémoire ?

### Exercice 4 — Interpréter le load average

1. Exécutez `uptime` et relevez les trois valeurs du load average.
2. Exécutez `nproc` pour connaître le nombre de coeurs.
3. La charge est-elle normale, élevée ou critique ? Justifiez en une phrase.
4. Relancez `uptime` 30 secondes plus tard : la valeur sur 1 min a-t-elle changé ? Et celle sur 15 min ?

### Exercice 5 — Rapport système en une commande

Rédigez une seule ligne de commande qui affiche successivement la charge système, la mémoire disponible et l'occupation du disque racine. Vous utiliserez le point-virgule pour enchaîner les commandes (voir chapitre 8.1 pour aller plus loin avec les pipes).

```bash
uptime ; free -h ; df -h /
```

Vérifiez que vous savez lire les trois blocs de sortie sans les confondre.

### Exercice 6 — Trouver les sous-dossiers lourds dans `/var/log`

Avec les droits administrateur (`sudo`), analysez l'espace occupé dans `/var/log` :

1. Listez les sous-dossiers d'un seul niveau de profondeur triés par taille.
2. Identifiez le dossier ou fichier le plus lourd.
3. Cherchez les fichiers de plus de 10 Mo dans `/var/log` avec `find`.

---

### Solutions

#### Solution exercice 1

```bash
# 1. Partition la plus remplie
df -h | sort -k 5 -nr | head -3

# 2. Espace libre sur /home (ou /)
df -h /home
# ou si /home n'est pas séparé :
df -h /

# 3. Sans tmpfs ni devtmpfs
df -h -x tmpfs -x devtmpfs
```

#### Solution exercice 2

```bash
# Étape 1 et 2 : taille des sous-dossiers du home, triée
du -h --max-depth=1 ~ | sort -h

# Le plus lourd apparaît en dernière ligne.
# Étape 3 : descendre dans ce répertoire (exemple : ~/Videos)
du -h --max-depth=1 ~/Videos | sort -h
```

#### Solution exercice 3

```bash
free -h
# Repérer la ligne Mem:, colonne "available"
# Exemple : total = 8.0G, available = 5.4G
# => 5.4 / 8.0 = 67 % -> largement au-dessus de 20 %, pas d'inquiétude

# La colonne buff/cache (ex: 4.7G) est de la mémoire récupérable.
# Si une application demandait 4 Go supplémentaires, le noyau libèrerait
# une partie du cache pour la lui donner.
```

#### Solution exercice 4

```bash
uptime
# exemple : load average: 0.42, 0.35, 0.28
nproc
# exemple : 4

# Interprétation : 0.42 < 4 coeurs, la charge est très faible.
# La valeur sur 1 min peut varier d'une mesure à l'autre ;
# celle sur 15 min est beaucoup plus stable.
```

#### Solution exercice 5

```bash
uptime ; free -h ; df -h /
```

La sortie comporte trois blocs distincts : une ligne pour `uptime`, le tableau à deux lignes de `free`, puis le tableau à deux lignes de `df`. Chaque bloc répond à une question différente : durée/charge, mémoire, espace disque.

#### Solution exercice 6

```bash
# 1. Sous-dossiers de /var/log triés par taille
sudo du -h --max-depth=1 /var/log | sort -h

# 2. Le plus lourd est la dernière ligne de la sortie précédente.

# 3. Fichiers de plus de 10 Mo dans /var/log
sudo find /var/log -type f -size +10M
```
