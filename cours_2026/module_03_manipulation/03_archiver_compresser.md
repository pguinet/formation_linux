# Chapitre 3.3 — Archiver et compresser

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - Distinguer l'archivage de la compression et choisir le bon outil.
> - Créer, lister et extraire une archive avec `tar`.
> - Créer et extraire un fichier `.zip` pour les échanges avec Windows.
> - Identifier les principaux formats de compression et leurs compromis.
>
> **Durée en séance** : ~30 min.

---

## Archiver ou compresser ?

Ces deux opérations sont souvent confondues, mais elles répondent à des besoins différents.

**Archiver**, c'est rassembler plusieurs fichiers et répertoires en un seul fichier,
en préservant la structure, les droits et les métadonnées — mais sans réduire la taille.

**Compresser**, c'est réduire la taille d'un fichier en supprimant les redondances dans les
données — mais sans toucher à leur organisation.

En pratique, on fait les deux en même temps : on archive avec `tar`, puis on compresse
à la volée. On obtient ainsi un fichier `.tar.gz` (ou `.tar.bz2`, `.tar.xz`) qui est à
la fois regroupé et allégé.

---

## La commande `tar`

`tar` (abréviation de *Tape ARchive*) est l'outil universel d'archivage sous Linux.
Sa syntaxe peut sembler austère au premier abord, mais trois opérations couvrent 90 % des
usages : **créer**, **lister** et **extraire**.

### Moyen mnémotechnique

Retenez les trois lettres **c / t / x** avec la phrase :

```
Crée  -> c   (Create)
Table -> t   (Table of contents, c'est-à-dire lister)
eXtrait -> x (eXtract)
```

L'option `f` (pour *file*) indique le nom de l'archive ; elle est quasiment toujours
présente. L'option `z` active la compression gzip.

### Créer une archive

```bash
tar czf mon_archive.tar.gz repertoire/
```

Décomposé :

- `c` — crée l'archive
- `z` — compresse avec gzip
- `f` — le prochain argument est le nom de l'archive

Exemple concret : vous voulez sauvegarder votre répertoire de projets avant de partir
en congés.

```bash
tar czf sauvegarde_projets.tar.gz ~/projets/
```

La commande crée `sauvegarde_projets.tar.gz` dans le répertoire courant.
Votre répertoire `~/projets/` n'est pas modifié.

Pour voir ce que `tar` fait au fur et à mesure, ajoutez l'option `v` (*verbose*) :

```bash
tar czvf sauvegarde_projets.tar.gz ~/projets/
```

### Lister le contenu sans extraire

Avant d'extraire, il est prudent de regarder ce que contient une archive.

```bash
tar tzf mon_archive.tar.gz
```

- `t` — affiche la table des matières (*list*)
- `z` — indique que l'archive est compressée en gzip
- `f` — nom de l'archive

Exemple de sortie :

```
projets/
projets/rapport.odt
projets/script.sh
projets/donnees/
projets/donnees/resultats.csv
```

Si l'archive est volumineuse, vous pouvez filtrer avec un pipe :

```bash
tar tzf mon_archive.tar.gz | grep ".csv"
```

### Extraire une archive

```bash
tar xzf mon_archive.tar.gz
```

- `x` — extrait (*extract*)

Par défaut, `tar` extrait dans le répertoire courant, en recréant l'arborescence
telle qu'elle a été archivée.

Pour extraire ailleurs (par exemple, dans `/tmp/restauration/`) :

```bash
tar xzf mon_archive.tar.gz -C /tmp/restauration/
```

L'option `-C` (*change directory*) désigne le répertoire de destination,
qui doit exister au préalable :

```bash
mkdir -p /tmp/restauration/
tar xzf mon_archive.tar.gz -C /tmp/restauration/
```

### Tableau des options tar les plus utiles

| Option | Signification |
|--------|---------------|
| `c`    | Créer une archive |
| `t`    | Lister le contenu |
| `x`    | Extraire |
| `f`    | Nom de l'archive (obligatoire avec c, t, x) |
| `z`    | Compression gzip (.tar.gz) |
| `j`    | Compression bzip2 (.tar.bz2) |
| `J`    | Compression xz (.tar.xz) |
| `v`    | Afficher les fichiers traités (mode verbeux) |
| `-C`   | Répertoire de destination pour l'extraction |

---

## Le format ZIP — pour les échanges avec Windows

Le format `.zip` est natif sous Windows. Si vous devez transmettre une archive à
un correspondant Windows, ou si vous en recevez une, c'est le format à privilégier.

### Créer une archive ZIP

```bash
zip -r archive.zip repertoire/
```

L'option `-r` est indispensable : elle demande à `zip` de descendre
récursivement dans les sous-répertoires. Sans elle, les dossiers
seraient ignorés.

Exemple : archiver un répertoire de documents pour l'envoyer par courriel.

```bash
zip -r rapport_mensuel.zip ~/documents/rapport/
```

### Lister et extraire un ZIP

```bash
# Lister le contenu sans extraire
unzip -l archive.zip

# Extraire dans le répertoire courant
unzip archive.zip

# Extraire vers un répertoire précis
unzip archive.zip -d /tmp/extraction/
```

L'utilitaire `unzip` est distinct de `zip`. Il est généralement déjà installé,
mais si ce n'est pas le cas : `sudo apt install unzip`.

---

## L'essentiel

| Commande | Usage type |
|----------|------------|
| `tar czf archive.tar.gz repertoire/` | Créer une archive compressée (gzip) |
| `tar tzf archive.tar.gz` | Lister le contenu d'une archive |
| `tar xzf archive.tar.gz` | Extraire une archive dans le répertoire courant |
| `tar xzf archive.tar.gz -C /dest/` | Extraire vers un répertoire précis |
| `tar xzf archive.tar.gz chemin/fichier` | Extraire un seul fichier de l'archive |
| `zip -r archive.zip repertoire/` | Créer une archive ZIP (échanges Windows) |
| `unzip archive.zip -d /dest/` | Extraire un ZIP vers un répertoire précis |
| `unzip -l archive.zip` | Lister le contenu d'un ZIP |

---

## Pour aller plus loin

### `gzip` et `gunzip` en standalone

`gzip` peut compresser un fichier unique sans archivage préalable.
Attention : par défaut, il remplace le fichier d'origine par le fichier compressé.

```bash
# Compresser un fichier (l'original est supprimé)
gzip rapport.odt
# Résultat : rapport.odt.gz

# Compresser en conservant l'original
gzip -k rapport.odt
# Résultat : rapport.odt et rapport.odt.gz coexistent

# Décompresser
gunzip rapport.odt.gz
# ou : gzip -d rapport.odt.gz
```

`gzip` est rarement utilisé seul sur des répertoires — pour cela, on passe par `tar`.

### `bzip2` et `xz` — quand la taille compte

`bzip2` et `xz` sont deux algorithmes de compression plus poussés que gzip.
Le tableau ci-dessous résume les compromis :

| Outil | Extension | Vitesse | Taux de compression |
|-------|-----------|---------|---------------------|
| gzip  | .gz       | Rapide  | Correct             |
| bzip2 | .bz2      | Moyen   | Bon                 |
| xz    | .xz       | Lent    | Excellent           |

Pour une sauvegarde quotidienne automatisée, gzip est souvent le bon choix
(vitesse acceptable, compression suffisante). Pour une archive destinée à être
conservée longtemps ou distribuée, xz réduit davantage la taille.

Avec `tar`, on remplace simplement l'option `z` :

```bash
# bzip2
tar cjf archive.tar.bz2 repertoire/

# xz
tar cJf archive.tar.xz repertoire/
```

La même substitution fonctionne pour lister (`t`) et extraire (`x`) — ou mieux encore,
on peut omettre l'option de compression : tar détecte automatiquement le format.

```bash
# tar détecte la compression tout seul
tar tf archive.tar.bz2
tar xf archive.tar.xz -C /destination/
```

### Extraire un seul fichier

Cette technique fonctionne avec tous les formats tar :

```bash
# Identifier le chemin exact dans l'archive
tar tf archive.tar.bz2 | grep "config"

# Extraire ce fichier uniquement
tar xf archive.tar.bz2 chemin/exact/config.ini
```

---

## Exercices

### Exercice 1 — Sauvegarder une arborescence

Créez la structure de fichiers suivante dans votre répertoire personnel :

```
tp_archivage/
+-- src/
|   +-- main.sh
+-- docs/
|   +-- README.md
+-- config/
    +-- parametres.txt
```

Pour créer rapidement cette structure :

```bash
mkdir -p ~/tp_archivage/{src,docs,config}
echo "#!/bin/bash" > ~/tp_archivage/src/main.sh
echo "# Documentation" > ~/tp_archivage/docs/README.md
echo "DEBUG=false" > ~/tp_archivage/config/parametres.txt
```

Créez ensuite une archive compressée `tp_archivage.tar.gz` dans votre répertoire
personnel, puis vérifiez son contenu sans l'extraire.

---

### Exercice 2 — Restaurer ailleurs

En utilisant l'archive créée à l'exercice 1, extrayez son contenu dans
le répertoire `/tmp/restauration/` (à créer au préalable).

Vérifiez que les fichiers ont bien été restaurés avec leur arborescence.

---

### Exercice 3 — Inspecter avant d'extraire

En utilisant l'archive `~/tp_archivage.tar.gz` créée à l'exercice 1,
listez son contenu pour vérifier qu'elle ne contient pas de chemin
commençant par `/` (chemin absolu), ce qui pourrait écraser des fichiers
système.

```bash
tar tzf ~/tp_archivage.tar.gz | grep "^/"
```

Si cette commande ne retourne rien, l'archive est sans danger à extraire.

---

### Exercice 4 — Extraction sélective

À partir de l'archive `tp_archivage.tar.gz` créée à l'exercice 1,
extrayez uniquement le fichier `tp_archivage/config/parametres.txt`
dans votre répertoire courant.

---

### Exercice 5 — ZIP pour Windows

Créez une archive ZIP du répertoire `tp_archivage/` nommée
`tp_archivage.zip`. Listez ensuite son contenu avec `unzip -l`,
puis extrayez-la dans `/tmp/zip_extract/`.

---

### Exercice 6 — Comparer gzip et xz

Créez deux archives du répertoire `tp_archivage/`, l'une en gzip
et l'autre en xz. Comparez leur taille avec `ls -lh`.

Note : sur des fichiers aussi petits, la différence sera minime ;
l'écart devient significatif sur de grands volumes de données.

---

### Solutions

**Exercice 1**

```bash
# Créer l'arborescence
mkdir -p ~/tp_archivage/{src,docs,config}
echo "#!/bin/bash" > ~/tp_archivage/src/main.sh
echo "# Documentation" > ~/tp_archivage/docs/README.md
echo "DEBUG=false" > ~/tp_archivage/config/parametres.txt

# Créer l'archive dans le répertoire personnel
cd ~
tar czf tp_archivage.tar.gz tp_archivage/

# Vérifier le contenu
tar tzf tp_archivage.tar.gz
```

Résultat attendu de la vérification :

```
tp_archivage/
tp_archivage/src/
tp_archivage/src/main.sh
tp_archivage/docs/
tp_archivage/docs/README.md
tp_archivage/config/
tp_archivage/config/parametres.txt
```

---

**Exercice 2**

```bash
# Créer le répertoire de destination
mkdir -p /tmp/restauration/

# Extraire l'archive vers ce répertoire
tar xzf ~/tp_archivage.tar.gz -C /tmp/restauration/

# Vérifier
ls -R /tmp/restauration/
```

---

**Exercice 3**

```bash
# Vérifier qu'aucun chemin absolu n'est présent
tar tzf ~/tp_archivage.tar.gz | grep "^/"
```

Aucune ligne ne devrait s'afficher : l'archive est sûre.

---

**Exercice 4**

```bash
# Depuis le répertoire personnel
cd ~

# Extraire un seul fichier (le chemin doit correspondre exactement
# à ce qu'affiche tar tzf)
tar xzf tp_archivage.tar.gz tp_archivage/config/parametres.txt

# Vérifier
cat tp_archivage/config/parametres.txt
```

---

**Exercice 5**

```bash
cd ~

# Créer le ZIP
zip -r tp_archivage.zip tp_archivage/

# Lister le contenu
unzip -l tp_archivage.zip

# Extraire dans /tmp/zip_extract/
mkdir -p /tmp/zip_extract/
unzip tp_archivage.zip -d /tmp/zip_extract/

# Vérifier
ls /tmp/zip_extract/
```

---

**Exercice 6**

```bash
cd ~

# Archive gzip
tar czf tp_archivage_gzip.tar.gz tp_archivage/

# Archive xz
tar cJf tp_archivage_xz.tar.xz tp_archivage/

# Comparer les tailles
ls -lh tp_archivage_gzip.tar.gz tp_archivage_xz.tar.xz
```

Sur un répertoire de quelques octets, les deux fichiers auront une taille
similaire. Sur un projet réel de plusieurs centaines de mégaoctets,
xz produit en général un fichier 20 à 40 % plus petit que gzip,
au prix d'un temps de compression plus long.
