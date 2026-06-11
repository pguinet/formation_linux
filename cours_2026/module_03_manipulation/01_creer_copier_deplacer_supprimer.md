# Chapitre 3.1 — Créer, copier, déplacer, supprimer

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - Créer des fichiers vides et des arborescences de répertoires.
> - Copier des fichiers et des répertoires entiers.
> - Déplacer et renommer en une seule commande.
> - Supprimer de façon sécurisée, en sachant que la suppression est définitive.
>
> **Durée en séance** : ~30 min.

---

## Créer des fichiers et des répertoires

### La commande `touch`

`touch` crée un fichier vide s'il n'existe pas encore. C'est la façon la plus rapide d'initialiser un fichier avant de le remplir.

```bash
# Créer un fichier vide
touch notes.txt

# Créer plusieurs fichiers d'un coup
touch config.json README.md .gitignore
```

Si le fichier existe déjà, `touch` met à jour sa date de modification sans en modifier le contenu — comportement utile dans certains scripts, mais sans importance pour l'usage courant.

### La commande `mkdir`

`mkdir` crée un répertoire. Sans option, elle échoue si le répertoire parent n'existe pas encore.

```bash
# Créer un répertoire simple
mkdir projets

# Créer plusieurs répertoires au même niveau
mkdir docs images scripts
```

**L'option `-p`** est celle que vous utiliserez le plus souvent : elle crée tous les répertoires intermédiaires manquants sans générer d'erreur si le répertoire existe déjà.

```bash
# Créer une arborescence en une seule commande
mkdir -p projets/webapp/src
mkdir -p projets/webapp/tests

# Astuce : accolades pour plusieurs sous-répertoires
mkdir -p projets/webapp/{src,tests,docs}
```

Sans `-p`, `mkdir projets/webapp/src` échoue si `projets/webapp/` n'existe pas.

---

## Copier des fichiers et des répertoires

### La commande `cp`

`cp` copie un fichier source vers une destination. Le fichier original reste intact.

```bash
# Copier un fichier dans le répertoire courant (nouveau nom)
cp rapport.txt rapport_sauvegarde.txt

# Copier un fichier dans un autre répertoire (même nom)
cp rapport.txt ~/Documents/

# Copier et renommer dans le même mouvement
cp rapport.txt ~/Documents/rapport_final.txt
```

**L'option `-r`** (récursif) est indispensable pour copier un répertoire et tout son contenu. Sans elle, `cp` refuse de copier un répertoire.

```bash
# Copier un répertoire complet
cp -r projets/ projets_sauvegarde/

# Copier vers un autre emplacement
cp -r projets/ ~/backup/
```

**L'option `-i`** (interactif) demande confirmation avant d'écraser un fichier existant. Utile quand on n'est pas sûr que la destination est vide.

```bash
cp -i nouveau.txt existant.txt
# cp: overwrite 'existant.txt'? y
```

Il est conseillé de prendre l'habitude de sauvegarder un fichier de configuration avant de le modifier :

```bash
cp /etc/hosts /etc/hosts.backup
```

---

## Déplacer et renommer

### La commande `mv`

`mv` déplace un fichier ou un répertoire. Contrairement à `cp`, l'original disparaît de son emplacement d'origine. `mv` sert également à renommer : renommer un fichier revient à le « déplacer » dans le même répertoire sous un nouveau nom.

**Renommer un fichier :**

```bash
# Renommer
mv ancien_nom.txt nouveau_nom.txt

# Changer l'extension
mv script.txt script.sh

# Renommer un répertoire
mv vieux_dossier nouveau_dossier
```

**Déplacer un fichier ou un répertoire :**

```bash
# Déplacer vers un autre répertoire
mv rapport.txt ~/Documents/

# Déplacer et renommer en une seule fois
mv rapport.txt ~/Documents/rapport_annuel.txt

# Déplacer plusieurs fichiers vers un répertoire
mv fichier1.txt fichier2.txt fichier3.txt ~/backup/
```

`mv` n'a pas besoin de `-r` pour déplacer un répertoire — il déplace le répertoire entier avec tout son contenu, à la différence de `cp`.

**L'option `-i`** joue le même rôle que pour `cp` : elle demande confirmation avant d'écraser un fichier de destination existant.

```bash
mv -i source.txt destination.txt
# mv: overwrite 'destination.txt'? n
```

---

## Supprimer des fichiers et des répertoires

### La commande `rm`

`rm` supprime des fichiers. La suppression est **définitive** : il n'y a pas de corbeille en ligne de commande sous Linux. Un fichier effacé avec `rm` est immédiatement perdu, sans possibilité de récupération simple.

```bash
# Supprimer un fichier
rm fichier_inutile.txt

# Supprimer plusieurs fichiers
rm temp1.txt temp2.txt temp3.txt

# Supprimer avec un joker
rm *.log
```

> **Attention — il n'y a PAS de corbeille.**
> Contrairement à un gestionnaire de fichiers graphique, `rm` ne déplace
> pas les fichiers dans une corbeille : ils sont supprimés immédiatement et
> définitivement. Avant toute suppression, vérifiez ce que vous allez effacer.

**L'option `-i`** (interactif) demande une confirmation pour chaque fichier avant de le supprimer. C'est le filet de sécurité à utiliser par défaut, surtout avec les jokers.

```bash
rm -i *.txt
# rm: remove regular file 'doc1.txt'? y
# rm: remove regular file 'doc2.txt'? n
```

**L'option `-r`** (récursif) permet de supprimer un répertoire et tout son contenu. Elle doit être maniée avec précaution.

```bash
# Supprimer un répertoire et son contenu, avec confirmation
rm -ri vieux_projet/
```

### La commande `rmdir`

`rmdir` supprime un répertoire **uniquement s'il est vide**. C'est une sécurité utile : elle échoue avec un message d'erreur explicite si le répertoire contient encore des fichiers.

```bash
# Réussit si le répertoire est vide
rmdir dossier_vide/

# Échoue si le répertoire n'est pas vide
rmdir dossier_plein/
# rmdir: failed to remove 'dossier_plein/': Directory not empty
```

---

## L'essentiel

| Commande | Usage type |
|----------|------------|
| `touch fichier.txt` | Créer un fichier vide |
| `mkdir -p a/b/c` | Créer une arborescence de répertoires |
| `cp source dest` | Copier un fichier |
| `cp -r source/ dest/` | Copier un répertoire entier |
| `mv ancien nouveau` | Renommer un fichier ou répertoire |
| `mv fichier /autre/chemin/` | Déplacer un fichier |
| `rm fichier.txt` | Supprimer un fichier (définitif) |
| `rm -i *.txt` | Supprimer avec confirmation (recommandé) |
| `rm -ri dossier/` | Supprimer un répertoire avec confirmation |
| `rmdir dossier/` | Supprimer un répertoire vide uniquement |

---

## Pour aller plus loin

### `cp -a` : préserver tous les attributs

L'option `-a` (archive) est équivalente à `-dpR` : elle copie récursivement tout en préservant les permissions, les horodatages et les liens symboliques. Indispensable pour les sauvegardes qui doivent être fidèles à l'original.

```bash
# Sauvegarde avec préservation complète des attributs
cp -a projets/ projets_backup/

# Vérifier que les permissions sont bien copiées
ls -la projets/fichier.sh
ls -la projets_backup/fichier.sh
```

Sans `-a`, une simple `cp -r` recrée les fichiers avec vos permissions par défaut, ce qui peut différer de l'original.

### Les dangers de `rm -rf` et comment s'en prémunir

La combinaison `rm -rf` supprime récursivement et de force, sans aucune confirmation. Elle est très efficace... et très dangereuse.

Deux risques majeurs à connaître :

- **Un joker mal placé** : `rm -rf *.log` dans le mauvais répertoire peut supprimer des fichiers précieux.
- **Une variable vide** : si `$DOSSIER` est vide, `rm -rf $DOSSIER/` devient `rm -rf /` — ce qui tente d'effacer tout le système.

**Garde-fou no 1 — vérifier avec `echo` avant d'utiliser un joker :**

```bash
# Avant de supprimer, affichez ce qui va l'être
echo rm -rf *.log
# Si la liste est correcte, relancez sans echo
rm -rf *.log
```

**Garde-fou no 2 — utiliser la syntaxe `${VAR:?}` dans les scripts :**

```bash
# Arrête le script avec une erreur si DOSSIER est vide ou non défini
rm -rf "${DOSSIER:?variable DOSSIER vide ou non definie}/"
```

**Garde-fou no 3 — l'alias `rm -i` dans votre configuration :**

```bash
# A ajouter dans ~/.bashrc pour que rm demande toujours confirmation
alias rm='rm -i'
```

### `trash-cli` : une vraie corbeille en ligne de commande

`trash-cli` est un utilitaire qui déplace les fichiers vers la corbeille standard (`~/.local/share/Trash/`), compatible avec les gestionnaires de fichiers graphiques. Il s'installe via le gestionnaire de paquets.

```bash
# Installation sur Debian/Ubuntu
sudo apt install trash-cli

# Utilisation
trash-put fichier.txt       # Envoyer dans la corbeille
trash-list                  # Voir le contenu de la corbeille
trash-restore               # Restaurer un fichier
trash-empty                 # Vider la corbeille
```

`trash-cli` est recommandé dès que vous travaillez sur votre propre espace personnel et que vous risquez de faire des erreurs. Sur un serveur ou dans un script de production, on s'en passe généralement.

---

## Exercices

### Exercice 1 — Créer une arborescence de projet

Depuis votre répertoire personnel, créez en une seule commande `mkdir -p` l'arborescence suivante, puis vérifiez le résultat avec `ls -R monprojet/` (ou `tree monprojet/` si disponible) :

```
monprojet/
+-- src/
+-- tests/
+-- docs/
```

Créez ensuite trois fichiers vides : `monprojet/src/main.py`, `monprojet/README.md` et `monprojet/docs/guide.md`.

### Exercice 2 — Copier et sauvegarder

1. Copiez le fichier `monprojet/README.md` sous le nom `README.md.bak` dans le même répertoire.
2. Copiez le répertoire `monprojet/` entier vers `monprojet_backup/` en préservant les attributs (option `-a`).
3. Vérifiez que les deux arborescences ont le même contenu.

### Exercice 3 — Renommer et déplacer

1. Renommez `monprojet/src/main.py` en `monprojet/src/app.py`.
2. Déplacez `monprojet/docs/guide.md` vers `monprojet/README_guide.md` (à la racine de `monprojet/`).
3. Listez le contenu de `monprojet/` pour vérifier le résultat attendu.

### Exercice 4 — Suppression sécurisée

1. Créez trois fichiers temporaires dans `monprojet/` : `temp1.tmp`, `temp2.tmp`, `brouillon.bak`.
2. Avant de supprimer, affichez la liste de ces fichiers avec `ls monprojet/*.tmp monprojet/*.bak`.
3. Supprimez-les avec `rm -i`, en répondant `y` à chaque confirmation.
4. Vérifiez que `monprojet/src/app.py` est toujours présent.

### Exercice 5 — Répertoires vides et non vides

1. Créez un répertoire vide `a_supprimer/`.
2. Supprimez-le avec `rmdir` — cela doit réussir.
3. Recréez `a_supprimer/` et ajoutez-y un fichier : `touch a_supprimer/test.txt`.
4. Tentez `rmdir a_supprimer/` — notez le message d'erreur.
5. Supprimez le répertoire et son contenu avec `rm -ri a_supprimer/`.

### Exercice 6 — Garde-fou avant suppression par joker

Placez-vous dans `monprojet/` et créez les fichiers suivants :
`log_2024.log`, `log_2025.log`, `rapport.pdf`.

Avant de supprimer les logs, utilisez `echo` pour vérifier la liste :

```bash
echo rm *.log
```

Si la liste est correcte, lancez la vraie suppression. Vérifiez ensuite que `rapport.pdf` est intact.

---

### Solutions

#### Solution exercice 1

```bash
mkdir -p monprojet/{src,tests,docs}
touch monprojet/src/main.py monprojet/README.md monprojet/docs/guide.md
ls -R monprojet/
```

#### Solution exercice 2

```bash
cp monprojet/README.md monprojet/README.md.bak
cp -a monprojet/ monprojet_backup/
ls -R monprojet_backup/
```

#### Solution exercice 3

```bash
mv monprojet/src/main.py monprojet/src/app.py
mv monprojet/docs/guide.md monprojet/README_guide.md
ls monprojet/
```

#### Solution exercice 4

```bash
touch monprojet/temp1.tmp monprojet/temp2.tmp monprojet/brouillon.bak
ls monprojet/*.tmp monprojet/*.bak
rm -i monprojet/*.tmp monprojet/*.bak
ls monprojet/src/
```

#### Solution exercice 5

```bash
mkdir a_supprimer
rmdir a_supprimer

mkdir a_supprimer
touch a_supprimer/test.txt
rmdir a_supprimer
# rmdir: failed to remove 'a_supprimer': Directory not empty

rm -ri a_supprimer
```

#### Solution exercice 6

```bash
cd monprojet
touch log_2024.log log_2025.log rapport.pdf
echo rm *.log
# affiche : rm log_2024.log log_2025.log
rm *.log
ls
# rapport.pdf doit toujours apparaître
cd ..
```
