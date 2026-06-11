# Chapitre 2.3 — Types de fichiers et liens

> **Objectifs** : à la fin de ce chapitre, vous saurez :
>
> - Reconnaître le type d'un fichier grâce au premier caractère de `ls -l` ;
> - Utiliser la commande `file` pour identifier le contenu d'un fichier ;
> - Créer un lien symbolique avec `ln -s` et comprendre ce qui se passe lorsque la cible est supprimée ;
> - Distinguer lien symbolique et lien physique (notions de base).
>
> **Durée en séance** : ~30 min.

---

## Tout est fichier

La philosophie fondatrice de Linux peut se résumer en trois mots : **tout est fichier**.
Un document texte, un répertoire, un disque dur, un port série, une connexion réseau —
tous sont représentés par le même mécanisme unifié : le fichier.

Cette abstraction présente un avantage considérable : les mêmes commandes (`cat`, `cp`,
`rm`...) fonctionnent sur des objets très différents, ce qui simplifie l'apprentissage et
l'écriture de scripts.

### Le premier caractère de `ls -l`

Vous avez appris au chapitre 2.2 à lire la sortie de `ls -l`. Le **tout premier caractère**
de chaque ligne indique le type du fichier :

| Caractère | Type | Exemple courant |
|-----------|------|-----------------|
| `-`       | Fichier ordinaire (données, texte, programme) | `rapport.txt`, `script.sh` |
| `d`       | Répertoire | `Documents/`, `/etc/` |
| `l`       | Lien symbolique | `logs -> /var/log/nginx` |
| `c`       | Périphérique caractère | `/dev/null`, `/dev/tty` |
| `b`       | Périphérique bloc | `/dev/sda` (disque) |

Pour l'instant, concentrez-vous sur les trois premiers : `-`, `d` et `l`.
Ils représentent la quasi-totalité de ce que vous rencontrerez au quotidien.

```bash
ls -l ~/Documents
# -rw-r--r-- 1 alice alice 4096 jan.  10 09:00 notes.txt
# drwxr-xr-x 2 alice alice 4096 jan.  10 09:00 photos
# lrwxrwxrwx 1 alice alice   11 jan.  10 09:00 liens -> /var/log
```

Dans cet exemple :
- `notes.txt` est un fichier ordinaire (`-`) ;
- `photos` est un répertoire (`d`) ;
- `liens` est un lien symbolique (`l`) qui pointe vers `/var/log`.

---

## Identifier le contenu d'un fichier : `file`

Sous Linux, **l'extension d'un fichier n'a aucune valeur légale** : le système ne s'y fie
pas pour décider comment traiter le fichier. Un fichier nommé `photo.txt` peut très bien
contenir une image JPEG, et inversement.

La commande `file` examine les premiers octets d'un fichier — ce qu'on appelle le
**nombre magique** — pour en déduire le contenu réel :

```bash
file rapport.txt
# rapport.txt: ASCII text

file /bin/ls
# /bin/ls: ELF 64-bit LSB pie executable, x86-64, ...

file /dev/null
# /dev/null: character special (1/3)

file /etc
# /etc: directory
```

`file` reconnaît des centaines de formats : texte, exécutables compilés, images, archives,
scripts, PDF, etc. Utilisez-la dès que vous n'êtes pas sûr du contenu d'un fichier, ou
pour diagnostiquer pourquoi un fichier refuse de s'ouvrir.

---

## Les liens symboliques

### À quoi sert un lien symbolique ?

Un lien symbolique est un **raccourci** : un fichier spécial dont l'unique contenu est le
chemin vers un autre fichier ou répertoire, que l'on appelle la **cible**. Lorsque vous
accédez au lien, le système vous redirige automatiquement vers la cible.

Les usages courants :
- **Raccourcir un chemin long** : `ln -s /var/log/nginx logs_nginx` vous évite de taper le
  chemin complet à chaque fois.
- **Pointer toujours vers la version courante** : `config-latest -> config-v2.1.txt`. Pour
  passer à la v2.2, il suffit de mettre à jour le lien — les scripts qui lisent
  `config-latest` n'ont pas à changer.
- **Rendre un répertoire accessible depuis plusieurs endroits** sans dupliquer les données.

### Créer un lien symbolique

La syntaxe est `ln -s cible nom_du_lien` :

```bash
# Lien vers un fichier
ln -s /home/alice/Documents/rapport.pdf rapport_actuel.pdf

# Lien vers un repertoire
ln -s /var/log/nginx logs_nginx

# Voir ce qui a ete cree
ls -l rapport_actuel.pdf
# lrwxrwxrwx 1 alice alice 32 jan. 10 09:00 rapport_actuel.pdf -> /home/alice/Documents/rapport.pdf
```

La flèche `->` indique la cible du lien. La taille affichée (ici 32) est la longueur du
chemin stocké, pas la taille du fichier cible.

### Le lien cassé

Si la cible est supprimée ou déplacée, le lien **devient cassé** (dangling link) :
il continue d'exister, mais toute tentative d'y accéder échoue avec une erreur
"Aucun fichier ou dossier de ce type".

```bash
# On cree un lien, puis on supprime la cible
echo "contenu" > fichier.txt
ln -s fichier.txt raccourci.txt
rm fichier.txt

# Le lien existe toujours mais est inutilisable
ls -la raccourci.txt
# lrwxrwxrwx 1 alice alice 10 jan. 10 09:00 raccourci.txt -> fichier.txt

cat raccourci.txt
# cat: raccourci.txt: Aucun fichier ou dossier de ce type
```

Dans un terminal couleur, un lien cassé apparaît souvent en rouge pour le signaler.

Pour retrouver les liens cassés dans un répertoire :

```bash
find . -type l -xtype l
```

### Modifier via un lien

Accéder à un fichier via son lien symbolique est identique à y accéder directement :
toute écriture est répercutée dans le fichier cible.

```bash
echo "ajout" >> raccourci.txt   # écrit dans fichier.txt
diff raccourci.txt fichier.txt  # aucune difference
```

---

## L'essentiel

| Commande | Usage type |
|----------|------------|
| `ls -l fichier` | Voir le type (1er caractère), les permissions et les informations du fichier |
| `file fichier` | Identifier le contenu réel d'un fichier (independamment de son extension) |
| `ln -s cible lien` | Créer un lien symbolique pointant vers `cible` |
| `ln -sf nouvelle_cible lien` | Mettre à jour un lien symbolique existant |
| `find . -type l -xtype l` | Lister les liens symboliques cassés dans le répertoire courant |

**Premier caractère de `ls -l` :** `-` fichier ordinaire, `d` répertoire, `l` lien symbolique.

---

## Pour aller plus loin

### Les liens physiques et les inodes

Chaque fichier sur un disque Linux possède un identifiant unique appelé **inode**, qui
stocke les métadonnées du fichier (taille, permissions, dates) et l'adresse des blocs
de données. Le nom que vous voyez dans le répertoire n'est qu'une **entrée de répertoire**
pointant vers cet inode.

Un **lien physique** (hard link) est simplement un deuxième nom pointant vers le même
inode — et donc vers les mêmes données sur le disque :

```bash
ln fichier_original.txt deuxieme_nom.txt
ls -li fichier_original.txt deuxieme_nom.txt
# 1234567 -rw-r--r-- 2 alice alice 512 jan. 10 fichier_original.txt
# 1234567 -rw-r--r-- 2 alice alice 512 jan. 10 deuxieme_nom.txt
```

Le numéro `1234567` (en première colonne avec `-i`) est l'inode : **les deux fichiers
partagent le même**. Le chiffre `2` dans la troisième colonne est le compteur de liens :
il y a deux entrées de répertoire pour cet inode.

Supprimer un nom ne détruit le fichier que lorsque le compteur tombe à zéro — c'est-à-dire
quand tous les noms ont été supprimés.

Différences clés avec les liens symboliques :

| | Lien symbolique | Lien physique |
|-|-----------------|---------------|
| Inode | Propre inode | Meme inode que la cible |
| Survit à la suppression de la cible ? | Non (lien cassé) | Oui |
| Peut traverser des systèmes de fichiers ? | Oui | Non |
| Peut pointer vers un répertoire ? | Oui | Non (en règle générale) |

En pratique, les liens symboliques couvrent 95 % des besoins. Les liens physiques sont
surtout utiles pour des sauvegardes incrémentales efficaces (outils comme `rsync --link-dest`).

### Les fichiers spéciaux dans `/dev`

Le répertoire `/dev` contient des fichiers spéciaux qui représentent les périphériques
matériels et quelques abstractions utiles :

- `/dev/null` : périphérique caractère (`c`). Tout ce qu'on y écrit est ignoré ; toute
  lecture retourne immédiatement. Utile pour supprimer une sortie : `commande > /dev/null`.
- `/dev/zero` : génère un flux infini d'octets nuls. Utile pour effacer un fichier ou
  créer un fichier vide d'une taille donnée.
- `/dev/sda`, `/dev/sda1` : périphériques blocs (`b`) représentant un disque et sa première
  partition.
- `/dev/tty` : terminal courant.

```bash
ls -la /dev/null /dev/zero /dev/sda
# crw-rw-rw- 1 root root 1, 3 jan. 10 /dev/null
# crw-rw-rw- 1 root root 1, 5 jan. 10 /dev/zero
# brw-rw---- 1 root disk 8, 0 jan. 10 /dev/sda
```

### Linux et les extensions de fichiers

Contrairement à Windows, Linux **n'utilise pas l'extension** pour décider comment traiter
un fichier. L'extension n'est qu'une convention pratique pour les utilisateurs. Ce qui
compte réellement :

- Le **bit exécutable** (permissions, chapitre 5.2) pour les programmes et scripts ;
- Les **premiers octets du fichier** (nombre magique) que `file` lit pour identifier le
  contenu.

Vous pouvez renommer `script.sh` en `script.txt` : il demeurera exécutable si le bit est
positionné, et la commande `file` continuera à l'identifier correctement.

---

## Exercices

### Exercice 1 — Identifier les types dans votre répertoire personnel

1. Affichez le contenu de votre répertoire personnel avec `ls -la`.
2. Notez un exemple de chacun des types rencontrés (fichier ordinaire, répertoire, lien
   symbolique si présent).
3. Affichez le contenu de `/dev` avec `ls -la /dev | head -20` et identifiez au moins un
   périphérique caractère et un périphérique bloc.

### Exercice 2 — Utiliser `file`

Dans votre répertoire personnel, exécutez :

```bash
file ~/.bashrc
file /bin/bash
file /etc/passwd
file /dev/null
```

Pour chaque fichier, notez ce que `file` vous indique et comparez avec ce que `ls -l`
vous montre (premier caractère).

### Exercice 3 — Créer et observer un lien symbolique

1. Créez un fichier de test et un lien symbolique vers ce fichier :

   ```bash
   mkdir -p ~/tp_liens && cd ~/tp_liens
   echo "Bonjour depuis l'original" > original.txt
   ln -s original.txt raccourci.txt
   ```

2. Listez le contenu du répertoire avec `ls -la` et repérez la flèche `->`.
3. Lisez le fichier via le lien : `cat raccourci.txt`. Le résultat est-il identique à
   `cat original.txt` ?
4. Ajoutez une ligne via le lien : `echo "ligne ajoutee" >> raccourci.txt`. Vérifiez que
   `original.txt` contient bien cette nouvelle ligne.

### Exercice 4 — Provoquer et observer un lien cassé

Suite à l'exercice précédent, dans `~/tp_liens` :

1. Supprimez le fichier original : `rm original.txt`.
2. Essayez de lire le raccourci : `cat raccourci.txt`. Quelle erreur obtenez-vous ?
3. Listez à nouveau avec `ls -la`. Que voyez-vous de particulier ?
4. Retrouvez les liens cassés du répertoire :

   ```bash
   find . -type l -xtype l
   ```

### Exercice 5 — Lien vers un répertoire et mise à jour

1. Créez deux versions d'un répertoire de configuration :

   ```bash
   mkdir -p ~/tp_liens/config-v1 ~/tp_liens/config-v2
   echo "parametres version 1" > ~/tp_liens/config-v1/app.conf
   echo "parametres version 2" > ~/tp_liens/config-v2/app.conf
   ```

2. Créez un lien symbolique `config-courante` pointant vers `config-v1` :

   ```bash
   cd ~/tp_liens
   ln -s config-v1 config-courante
   cat config-courante/app.conf
   ```

3. Mettez à jour le lien pour pointer vers `config-v2` sans changer le nom `config-courante` :

   ```bash
   ln -sf config-v2 config-courante
   cat config-courante/app.conf
   ```

   Vérifiez que vous lisez maintenant la version 2.

### Exercice 6 — Nettoyage

Supprimez le répertoire de travail à la fin :

```bash
rm -rf ~/tp_liens
```

---

### Solutions

**Exercice 1**

Dans un répertoire personnel typique, `ls -la ~` montre :
- Des fichiers ordinaires (`-`) : `.bashrc`, `.profile`, `notes.txt`...
- Des répertoires (`d`) : `Documents/`, `Téléchargements/`, `.config/`...
- Des liens symboliques (`l`) possibles selon la distribution : `.local/share/applications`
  peut parfois être un lien.

Dans `/dev`, exemples courants :
- Périphérique caractère : `/dev/null` (1ère lettre `c`)
- Périphérique bloc : `/dev/sda` ou `/dev/vda` (1ère lettre `b`)

**Exercice 2**

Résultats attendus :
- `~/.bashrc` : `ASCII text` — c'est un fichier texte ordinaire.
- `/bin/bash` : `ELF 64-bit LSB pie executable, x86-64...` — exécutable compilé.
- `/etc/passwd` : `ASCII text` — fichier de configuration texte.
- `/dev/null` : `character special (1/3)` — périphérique caractère.

**Exercice 3**

Après `ls -la`, vous devez voir une ligne de la forme :
```
lrwxrwxrwx 1 alice alice 11 jan. 10 09:00 raccourci.txt -> original.txt
```
Le `l` en tête confirme que c'est un lien symbolique.
`cat raccourci.txt` et `cat original.txt` affichent le même contenu, car le lien redirige
transparents vers l'original. Après `echo "ligne ajoutee" >> raccourci.txt`, la ligne
apparaît bien dans `original.txt` : le lien écrit dans la cible.

**Exercice 4**

Après `rm original.txt` :
- `cat raccourci.txt` produit : `cat: raccourci.txt: Aucun fichier ou dossier de ce type`.
- `ls -la` montre toujours `raccourci.txt -> original.txt`, souvent affiché en rouge.
- `find . -type l -xtype l` retourne `./raccourci.txt` : lien symbolique cassé détecté.

**Exercice 5**

- Après `ln -s config-v1 config-courante`, `cat config-courante/app.conf` affiche
  `parametres version 1`.
- Après `ln -sf config-v2 config-courante`, `cat config-courante/app.conf` affiche
  `parametres version 2`. L'option `-f` (force) écrase l'ancien lien sans erreur.
  `ls -la config-courante` montre désormais `config-courante -> config-v2`.
