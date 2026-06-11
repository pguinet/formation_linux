# Chapitre 4.2 — Éditer avec nano

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - Créer et modifier un fichier texte directement dans le terminal avec nano.
> - Utiliser les raccourcis essentiels : sauvegarder, quitter, chercher, couper/coller.
> - Déchiffrer la barre de raccourcis affichée par nano.
> - Configurer la variable `EDITOR` pour définir votre éditeur par défaut.
>
> **Durée en séance** : ~30 min.

---

## Pourquoi éditer dans le terminal ?

Sur un serveur Linux, il n'y a généralement pas d'interface graphique. Si vous devez corriger
un fichier de configuration, ajouter une ligne à un script ou créer une note rapide, vous devez
le faire depuis le terminal lui-même. C'est aussi indispensable lors d'une connexion SSH à une
machine distante (voir l'annexe d'installation) : votre seule fenêtre sur le système, c'est ce terminal.
L'éditeur de texte en ligne de commande est donc un outil du quotidien, au même titre que `cd`
ou `ls`.

---

## nano — l'éditeur pour bien démarrer

### Ouvrir ou créer un fichier

La commande est la même que le fichier existe déjà ou non :

```bash
nano notes.txt
```

Si `notes.txt` n'existe pas, nano l'affiche comme vide et le créera sur le disque quand vous
sauvegarderez. Si le fichier existe, son contenu s'affiche immédiatement.

Pour éditer un fichier système (qui requiert des droits élevés), on préfixe avec `sudo` (voir chapitre 5.3) :

```bash
sudo nano /etc/hosts
```

Une option utile pour les débutants — afficher les numéros de ligne :

```bash
nano -l notes.txt
```

### L'interface en un coup d'oeil

Une fois nano ouvert, vous voyez trois zones :

```
  GNU nano 6.2              notes.txt              Modifié

Ceci est mon fichier de notes.
Il peut contenir autant de lignes que necessaire.
_

^G Aide        ^O Enreg.      ^W Chercher    ^K Couper
^X Quitter     ^R Lire fich.  ^\ Remplacer   ^U Coller
```

- La **barre de titre** (première ligne) : nom du fichier et état (« Modifié » si vous avez
  changé quelque chose depuis la dernière sauvegarde).
- La **zone de texte** (au milieu) : votre contenu. Vous tapez directement, sans mode particulier.
- La **barre de raccourcis** (deux dernières lignes) : les actions disponibles. Le symbole `^`
  signifie la touche `Ctrl`. Ainsi `^O` se lit « Ctrl+O ».

### Sauvegarder et quitter

| Action | Raccourci | Ce qui se passe |
|--------|-----------|-----------------|
| Sauvegarder | `Ctrl+O` | nano demande de confirmer le nom du fichier. Appuyez sur Entrée pour valider. |
| Quitter | `Ctrl+X` | Si le fichier a été modifié, nano vous demande si vous souhaitez sauvegarder (O/N). |

Astuce : `Ctrl+X` seul suffit pour quitter. Si le fichier a été modifié, nano propose de
sauvegarder — répondez `o` (oui) puis Entrée. Vous n'avez pas besoin de faire `Ctrl+O` avant.

### Chercher du texte

`Ctrl+W` ouvre la barre de recherche en bas de l'écran. Tapez votre terme et appuyez sur Entrée.
nano positionne le curseur sur la première occurrence. Appuyez de nouveau sur `Ctrl+W` puis Entrée
(sans rien retaper) pour passer à l'occurrence suivante.

Exemple : dans un fichier de configuration volumineux, pour retrouver le paramètre `port` :

```
Ctrl+W  ->  port  ->  Entrée
```

### Couper et coller une ligne

Ces deux raccourcis fonctionnent sur la ligne entière où se trouve le curseur :

- `Ctrl+K` : coupe la ligne (elle disparaît et est placée dans le presse-papier interne).
- `Ctrl+U` : colle la ligne coupée à l'endroit actuel du curseur.

C'est pratique pour déplacer une ligne : positionnez-vous dessus, `Ctrl+K`, déplacez le curseur
à destination, `Ctrl+U`.

Vous pouvez aussi appuyer plusieurs fois sur `Ctrl+K` pour couper plusieurs lignes consécutives,
puis `Ctrl+U` pour les recoller toutes d'un coup.

### Chercher et remplacer

`Ctrl+\` (barre oblique inversée, parfois notée `^\`) lance le mode remplacement :

1. nano demande d'abord le texte à chercher.
2. Il demande ensuite le texte de remplacement.
3. Il propose de remplacer occurrence par occurrence (tapez `O` pour oui) ou toutes en une fois
   (tapez `A` pour « tout »).

Exemple concret : dans un fichier de configuration, remplacer `localhost` par `192.168.1.50` :

```
Ctrl+\  ->  localhost  ->  Entrée  ->  192.168.1.50  ->  Entrée  ->  A
```

### Exemple complet : créer un script avec nano

```bash
nano bonjour.sh
```

Dans nano, tapez :

```bash
#!/bin/bash
# Mon premier script
echo "Bonjour, $(whoami) !"
echo "Nous sommes le $(date '+%d/%m/%Y')"
```

Sauvegardez avec `Ctrl+O` puis Entrée, quittez avec `Ctrl+X`. Vérifiez le résultat :

```bash
bash bonjour.sh
```

---

## L'essentiel

| Raccourci | Usage type |
|-----------|------------|
| `nano fichier.txt` | Ouvrir (ou créer) un fichier |
| `nano -l fichier.txt` | Ouvrir avec numéros de ligne |
| `sudo nano /etc/hosts` | Éditer un fichier système |
| `Ctrl+O` | Sauvegarder (confirmer le nom avec Entrée) |
| `Ctrl+X` | Quitter (propose de sauvegarder si modifié) |
| `Ctrl+W` | Chercher un terme |
| `Ctrl+\` | Chercher et remplacer |
| `Ctrl+K` | Couper la ligne courante |
| `Ctrl+U` | Coller la ligne coupée |
| `Ctrl+G` | Afficher l'aide complète de nano |
| `^` dans la barre | Signifie la touche `Ctrl` |

---

## Pour aller plus loin

### Un mot sur vim

Si un jour vous ouvrez accidentellement `vim` (ou si un programme vous y propulse), voici le
strict minimum pour vous en sortir.

vim est un éditeur dit « modal » : selon le mode actif, les touches du clavier ont des fonctions
différentes. Quand vim s'ouvre, vous êtes en **mode Normal** — appuyer sur des lettres exécute
des commandes, il n'écrit pas de texte.

Pour écrire du texte, appuyez sur `i` : vous entrez en **mode Insertion** (la mention
`-- INSERTION --` apparaît en bas). Tapez votre texte normalement.

Pour revenir au **mode Normal**, appuyez sur `Echap`.

Depuis le mode Normal, tapez `:` pour entrer en **mode Commande** (une ligne apparaît en bas) :

| Commande | Action |
|----------|--------|
| `:w` | Sauvegarder |
| `:wq` | Sauvegarder et quitter |
| `:q!` | Quitter sans sauvegarder (force) |

En résumé, le flux minimal dans vim est :

```
ouverture  -->  i  -->  (écriture)  -->  Echap  -->  :wq  -->  Entrée
```

Si vous êtes bloqué et que rien ne répond, appuyez plusieurs fois sur `Echap`, puis tapez `:q!`
suivi de Entrée — cela quitte vim sans rien sauvegarder.

### La variable EDITOR

Certains programmes (git, crontab, visudo...) ouvrent automatiquement un éditeur pour vous
faire modifier un fichier. Ils consultent la variable d'environnement `EDITOR` pour savoir
lequel utiliser.

Pour définir nano comme éditeur par défaut de façon permanente, ajoutez cette ligne à votre
fichier `~/.bashrc` (voir chapitre 8.3 sur la personnalisation) :

```bash
export EDITOR=nano
```

Rechargez ensuite la configuration :

```bash
source ~/.bashrc
```

Vérifiez que la variable est bien prise en compte :

```bash
echo $EDITOR
```

Si vous préférez vim à terme, remplacez `nano` par `vim`. La plupart des systèmes Debian/Ubuntu
proposent également la commande `update-alternatives --config editor` pour gérer cela de façon
globale.

### Configurer nano selon ses préférences

nano lit le fichier `~/.nanorc` au démarrage. Voici une configuration raisonnable pour débuter :

```
set linenumbers    # numeros de ligne visibles
set softwrap       # retour a la ligne si la ligne est plus longue que l'ecran
set tabsize 4      # une tabulation = 4 espaces
```

Créez ce fichier avec... nano lui-même :

```bash
nano ~/.nanorc
```

---

## Exercices

### Exercice 1 — Premier fichier avec nano

Créez un répertoire de travail, ouvrez nano et créez un fichier contenant vos coordonnées
fictives (prénom, ville, centres d'intérêt), sauvegardez et vérifiez le résultat.

```bash
mkdir ~/tp_nano
nano ~/tp_nano/moi.txt
```

Saisissez au minimum trois lignes, sauvegardez avec `Ctrl+O` + Entrée, quittez avec `Ctrl+X`,
puis vérifiez le contenu :

```bash
cat ~/tp_nano/moi.txt
```

**Objectif** : comprendre que nano crée le fichier sur le disque uniquement quand on sauvegarde.

---

### Exercice 2 — Modifier un fichier de configuration

Créez le fichier `~/tp_nano/app.conf` avec nano et saisissez le contenu suivant :

```
[serveur]
hote=localhost
port=8080
debug=true

[base_de_donnees]
hote=localhost
port=5432
nom=mabase
```

Puis, sans fermer et rouvrir le fichier (restez dans nano) :

1. Cherchez `localhost` avec `Ctrl+W`.
2. Utilisez `Ctrl+\` pour remplacer toutes les occurrences de `localhost` par `127.0.0.1`.
3. Sauvegardez et quittez.

Vérifiez qu'aucun `localhost` ne subsiste :

```bash
grep localhost ~/tp_nano/app.conf
```

La commande ne doit rien afficher.

---

### Exercice 3 — Couper et réorganiser des lignes

Créez le fichier `~/tp_nano/liste.txt` avec ce contenu (dans cet ordre) :

```
Troisieme element
Premier element
Deuxieme element
```

Utilisez nano pour remettre les lignes dans le bon ordre (Premier, Deuxième, Troisième) en
vous aidant uniquement de `Ctrl+K` et `Ctrl+U`.

Vérifiez :

```bash
cat ~/tp_nano/liste.txt
```

---

### Exercice 4 — Créer un script bash avec nano

Créez le fichier `~/tp_nano/info_systeme.sh` avec nano et saisissez :

```bash
#!/bin/bash
# Affichage d'informations systeme

echo "Utilisateur : $(whoami)"
echo "Repertoire  : $(pwd)"
echo "Date        : $(date '+%d/%m/%Y %H:%M')"
echo "Systeme     : $(uname -s) $(uname -r)"
```

Sauvegardez, quittez et lancez le script :

```bash
bash ~/tp_nano/info_systeme.sh
```

**Objectif** : prendre l'habitude du cycle « nano -> Ctrl+O -> Ctrl+X -> bash script.sh ».

---

### Exercice 5 — Découvrir vim (optionnel)

Si vous avez terminé les exercices précédents, tentez cette séquence dans vim :

```bash
vim ~/tp_nano/test_vim.txt
```

1. Appuyez sur `i` (mode Insertion).
2. Tapez deux ou trois lignes de texte quelconque.
3. Appuyez sur `Echap` (retour en mode Normal).
4. Tapez `:wq` puis Entrée pour sauvegarder et quitter.
5. Vérifiez le contenu avec `cat ~/tp_nano/test_vim.txt`.

Si vous vous retrouvez bloqué : `Echap` (plusieurs fois si besoin), puis `:q!` + Entrée.

---

### Solutions

#### Solution exercice 1

```bash
mkdir ~/tp_nano
nano ~/tp_nano/moi.txt
# Contenu (exemple) :
# Prénom : Alice
# Ville : Lyon
# Centres d'intérêt : Linux, photographie, randonnée
# Ctrl+O  -> Entrée  -> Ctrl+X
cat ~/tp_nano/moi.txt
# Affiche les trois lignes saisies
```

#### Solution exercice 2

Après avoir saisi le contenu initial et sauvegardé (`Ctrl+O`, Entrée) :

```
Ctrl+\
  Texte a chercher    : localhost
  Texte de remplacement : 127.0.0.1
  Remplacer cette occurrence ? -> A  (pour tout remplacer)
Ctrl+O  ->  Entrée
Ctrl+X
```

Vérification :

```bash
grep localhost ~/tp_nano/app.conf
# (aucune sortie -> succès)
grep 127.0.0.1 ~/tp_nano/app.conf
# hote=127.0.0.1  (apparaît deux fois)
```

#### Solution exercice 3

```bash
nano ~/tp_nano/liste.txt
```

Étapes dans nano :

1. Placez le curseur sur « Troisieme element » (ligne 1).
2. `Ctrl+K` — la ligne est coupée.
3. Déplacez le curseur après « Deuxieme element » (fin du fichier).
4. `Ctrl+U` — la ligne est collée en troisième position.

Résultat attendu :

```
Premier element
Deuxieme element
Troisieme element
```

#### Solution exercice 4

```bash
nano ~/tp_nano/info_systeme.sh
# Saisir le contenu indiqué, puis :
# Ctrl+O  ->  Entrée  ->  Ctrl+X
chmod +x ~/tp_nano/info_systeme.sh
bash ~/tp_nano/info_systeme.sh
# Affichage exemple :
# Utilisateur : alice
# Repertoire  : /home/alice
# Date        : 11/06/2026 14:23
# Systeme     : Linux 6.1.0-21-amd64
```

#### Solution exercice 5

```bash
vim ~/tp_nano/test_vim.txt
# i            -> passe en mode Insertion
# (saisie de texte)
# Echap        -> retour en mode Normal
# :wq  Entrée  -> sauvegarde et quitte
cat ~/tp_nano/test_vim.txt
# Affiche le texte saisi
```

En cas de blocage : `Echap Echap :q! Entrée` — quitte vim sans rien sauvegarder.
