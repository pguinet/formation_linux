# Chapitre 4.1 — Lire des fichiers

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - choisir la bonne commande selon la taille du fichier à consulter ;
> - naviguer dans un fichier long avec `less` ;
> - afficher le début ou la fin d'un fichier avec `head` et `tail` ;
> - surveiller un fichier de log en temps réel.
>
> **Durée en séance** : ~30 min.

---

## Afficher d'un bloc : `cat`

`cat` (abréviation de *concatenate*) lit un ou plusieurs fichiers et envoie leur contenu
sur le terminal. C'est la commande la plus directe — et la plus souvent mal utilisée.

```bash
# Afficher un fichier court
cat /etc/hostname

# Numéroter les lignes (pratique pour déboguer)
cat -n /etc/hosts

# Concaténer deux fichiers dans un troisième
cat partie1.txt partie2.txt > complet.txt
```

### Quand NE PAS utiliser `cat`

`cat` affiche l'intégralité du fichier d'un seul coup : si le fichier comporte des
milliers de lignes, le contenu défile trop vite pour être lu et peut saturer votre
émulateur de terminal.

Règle pratique : avant d'utiliser `cat` sur un fichier inconnu, vérifiez sa taille :

```bash
ls -lh fichier_inconnu.txt
```

- Fichier de quelques dizaines de lignes : `cat` convient.
- Fichier de plusieurs centaines de lignes ou plus : préférez `less`.

---

## Lire page par page : `less`

`less` est le paginateur de référence sous Linux. Il affiche le fichier un écran à la
fois et permet de naviguer librement, vers l'avant comme vers l'arrière.

```bash
less /var/log/syslog
```

### Commandes de navigation essentielles dans `less`

| Touche          | Action                              |
|-----------------|-------------------------------------|
| Espace          | Page suivante                       |
| b               | Page précédente                     |
| g               | Aller au début du fichier           |
| G               | Aller à la fin du fichier           |
| /motif          | Rechercher vers le bas              |
| n               | Occurrence suivante                 |
| N               | Occurrence précédente               |
| q               | Quitter                             |

**Exemple concret — rechercher les erreurs dans un log :**

```bash
less /var/log/syslog
# Dans less, tapez : /error
# Puis appuyez sur n pour passer à l'occurrence suivante
```

### Option utile : numéroter les lignes

```bash
less -N /etc/ssh/sshd_config
```

L'affichage des numéros de ligne facilite les références croisées avec un collègue ou
une documentation.

### Pourquoi `less` plutôt que `more` ?

`more` est l'ancêtre de `less` : il ne permet de défiler que vers l'avant et son jeu de
commandes est très limité. Dans la pratique, `less` le remplace avantageusement dans
tous les cas. Vous pouvez néanmoins croiser `more` sur des systèmes anciens ou dans des
scripts hérités (voir la section « Pour aller plus loin »).

---

## Début et fin d'un fichier : `head` et `tail`

Quand vous n'avez besoin que d'une partie d'un fichier, `head` et `tail` évitent
d'ouvrir un paginateur.

### `head` — les premières lignes

Par défaut, `head` affiche les 10 premières lignes :

```bash
head /etc/passwd
```

Pour choisir le nombre de lignes :

```bash
head -n 20 /etc/passwd
# Forme abrégée équivalente :
head -20 /etc/passwd
```

Exemple d'usage courant : voir l'en-tête d'un fichier CSV avant de le traiter.

```bash
head -5 donnees.csv
```

### `tail` — les dernières lignes

`tail` fonctionne de façon symétrique :

```bash
tail /var/log/auth.log          # 10 dernières lignes
tail -n 50 /var/log/syslog      # 50 dernières lignes
```

**Extraire une plage de lignes au milieu d'un fichier** en combinant les deux commandes (l'enchaînement par | est expliqué au chapitre 8.1) :

```bash
# Afficher les lignes 20 à 30
head -30 fichier.txt | tail -11
```

### `tail -f` — suivre un fichier en temps réel

L'option `-f` (*follow*) est indispensable pour surveiller un fichier de log qui grossit :
`tail` affiche les nouvelles lignes au fur et à mesure qu'elles sont ajoutées, sans quitter
le terminal.

```bash
tail -f /var/log/syslog
```

Pour arrêter le suivi, appuyez sur **Ctrl+C**.

Exemple pratique — simuler l'arrivée de nouvelles lignes :

```bash
# Terminal 1 : surveiller le fichier
tail -f /tmp/mon_log.txt

# Terminal 2 : ajouter du contenu
echo "Nouvelle entrée de log" >> /tmp/mon_log.txt
```

Vous verrez la nouvelle ligne apparaître immédiatement dans le premier terminal.

> Note : `tail -f` est souvent utilisé pour surveiller les journaux de services système.
> Vous approfondirez ce sujet au chapitre 7.2 consacré aux logs système.

---

## L'essentiel

| Commande       | Usage type                                              |
|----------------|---------------------------------------------------------|
| `cat fichier`  | Afficher un fichier court en une seule fois             |
| `cat -n`       | Afficher avec numéros de lignes                         |
| `less fichier` | Naviguer dans un fichier long (Espace, b, /motif, q)    |
| `less -N`      | Idem avec numérotation des lignes                       |
| `head fichier` | Voir les 10 premières lignes                            |
| `head -n N`    | Voir les N premières lignes                             |
| `tail fichier` | Voir les 10 dernières lignes                            |
| `tail -n N`    | Voir les N dernières lignes                             |
| `tail -f`      | Suivre un fichier en temps réel (logs)                  |

---

## Pour aller plus loin

### `more` — l'ancêtre de `less`

`more` existe depuis les origines d'Unix. Il ouvre un fichier et permet d'avancer page
par page avec Espace, ou ligne par ligne avec Entrée. La navigation arrière n'est pas
disponible sur toutes les versions. Aujourd'hui, `less` le remplace dans la quasi-
totalité des situations. Vous pouvez le rencontrer dans des scripts anciens ou sur des
distributions minimalistes.

```bash
more /etc/passwd
```

### `wc` — compter les lignes, mots et caractères

Avant d'explorer un fichier, il est souvent utile d'en connaître la taille en lignes :

```bash
wc -l /etc/passwd       # Nombre de lignes
wc -w fichier.txt       # Nombre de mots
wc -c fichier.txt       # Nombre de caractères (octets)
```

`wc` s'utilise fréquemment en fin de pipeline pour compter des résultats. La recherche
dans les fichiers est abordée au chapitre 4.3, et l'enchaînement de commandes par pipe au chapitre 8.1.

### `nl` — numéroter les lignes

`nl` numérote les lignes d'un fichier, en sautant les lignes vides par défaut :

```bash
nl /etc/hosts
```

Contrairement à `cat -n`, `nl` offre des options de format plus fines (numérotation à
partir d'un certain numéro, style de numérotation...). Pour un usage courant, `cat -n`
suffit.

### Lire un fichier compressé avec `zless`

Les fichiers compressés en `.gz` (voir chapitre 3.3) ne peuvent pas être ouverts
directement avec `less`. La commande `zless` fait l'équivalent, en décompressant à la
volée :

```bash
zless /var/log/syslog.2.gz
```

Il existe également `zcat` (équivalent de `cat`) et `zgrep` (équivalent de `grep` —
voir chapitre 4.3) pour les fichiers compressés.

### Combiner `head` et `tail` pour extraire une section précise

Pour afficher exactement les lignes 40 à 55 d'un fichier :

```bash
head -55 fichier.txt | tail -16
```

La logique : `head -55` conserve les 55 premières lignes, puis `tail -16` en extrait les
16 dernières, soit les lignes 40 à 55.

---

## Exercices

### Exercice 1 — Explorer `/etc/passwd`

`/etc/passwd` est le fichier qui répertorie les comptes d'utilisateurs du système.
Chaque ligne décrit un compte.

1. Affichez les 5 premières lignes du fichier.
2. Affichez les 5 dernières lignes du fichier.
3. Comptez le nombre total d'entrées (lignes) dans ce fichier.
4. Ouvrez le fichier avec `less`. Cherchez la ligne contenant `root` en tapant `/root`,
   puis quittez avec `q`.

---

### Exercice 2 — Suivre un fichier qui grossit

Cet exercice simule la surveillance d'un journal applicatif.

1. Créez un fichier de log vide :

```bash
touch /tmp/journal.log
```

2. Dans votre terminal, lancez la surveillance en temps réel :

```bash
tail -f /tmp/journal.log
```

3. Ouvrez un **second terminal** (ou un second onglet) et ajoutez des entrées :

```bash
echo "$(date) INFO  Démarrage de l'application" >> /tmp/journal.log
echo "$(date) INFO  Connexion acceptée" >> /tmp/journal.log
echo "$(date) ERROR Echec de lecture du fichier de configuration" >> /tmp/journal.log
```

4. Observez les lignes apparaître dans le premier terminal au fil des ajouts.
5. Arrêtez la surveillance avec **Ctrl+C**.

---

### Exercice 3 — Choisir le bon outil

Pour chacun des scénarios suivants, indiquez la commande la mieux adaptée
et justifiez brièvement votre choix.

a. Vous souhaitez voir si votre nom d'hôte est bien configuré dans `/etc/hostname`
   (fichier d'une ligne).

b. Vous devez parcourir un fichier de configuration de 800 lignes pour trouver
   la section `[database]`.

c. Un service vient de démarrer et vous voulez voir ses 20 derniers messages de log
   dans `/var/log/syslog`.

d. Vous voulez savoir combien de lignes contient un fichier avant de décider
   comment le traiter.

---

### Exercice 4 — Extraire une plage de lignes

Créez un fichier de 100 lignes numérotées :

```bash
seq 1 100 > /tmp/nombres.txt
```

1. Affichez les lignes 45 à 55 en combinant `head` et `tail`.
2. Vérifiez votre résultat en ouvrant le fichier avec `less -N` et en naviguant jusqu'à
   la ligne 45.

---

### Solutions

#### Solution — Exercice 1

```bash
# 1. Cinq premières lignes
head -5 /etc/passwd

# 2. Cinq dernières lignes
tail -5 /etc/passwd

# 3. Nombre de lignes
wc -l /etc/passwd

# 4. Navigation dans less
less /etc/passwd
# Dans less : tapez /root puis Entrée, puis q pour quitter
```

---

#### Solution — Exercice 2

```bash
# Terminal 1
tail -f /tmp/journal.log

# Terminal 2 (les trois commandes echo décrites dans l'énoncé)
echo "$(date) INFO  Démarrage de l'application" >> /tmp/journal.log
echo "$(date) INFO  Connexion acceptée" >> /tmp/journal.log
echo "$(date) ERROR Echec de lecture du fichier de configuration" >> /tmp/journal.log

# Revenir au terminal 1 et appuyer sur Ctrl+C pour arrêter
```

---

#### Solution — Exercice 3

a. `cat /etc/hostname` — le fichier est minuscule (une ligne), `cat` est parfait.

b. `less /etc/chemin/vers/fichier.conf` — 800 lignes, navigation libre nécessaire.
   Dans `less`, tapez `/database` pour atteindre la section directement.

c. `tail -20 /var/log/syslog` — on veut exactement les 20 dernières lignes,
   sans besoin de navigation.

d. `wc -l fichier.txt` — `wc` donne le nombre de lignes sans afficher le contenu.

---

#### Solution — Exercice 4

```bash
# 1. Afficher les lignes 45 à 55 (11 lignes)
head -55 /tmp/nombres.txt | tail -11

# 2. Vérification visuelle
less -N /tmp/nombres.txt
# Dans less, tapez 45g pour aller directement à la ligne 45
```
