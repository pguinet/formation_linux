# Git sous Windows 3 — Cloner le dépôt de la formation

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - cloner le dépôt de la formation dans `D:\PrenomNOM\formation_linux` avec Git GUI ;
> - parcourir son historique avec gitk ;
> - faire les mêmes opérations dans Git Bash et mettre le dépôt à jour.
>
> **Durée en séance** : ~30 min.

---

Git est installé sur `D:` (voir chapitre Git sous Windows 2). On peut
maintenant récupérer une copie du dépôt de la formation : tous les
chapitres, les annexes, les scripts, et leur historique complet.

Le dépôt est public : aucun compte GitHub n'est nécessaire pour le
cloner ni pour le mettre à jour.

## L'adresse du dépôt

Sur GitHub, chaque dépôt a une adresse de clonage, qui se termine par
`.git`. Celle du dépôt de la formation est :

```
https://github.com/pguinet/formation_linux.git
```

On la retrouve sur la page du dépôt, avec le bouton vert **Code**,
onglet **HTTPS**.

Le clone sera rangé dans votre dossier sur `D:`, à côté des autres :

```
D:\PrenomNOM\
+-- formation_linux\    (le dépôt cloné)
+-- PortableGit\
+-- sources\
+-- VirtualBox\
```

## Cloner avec Git GUI

1. Lancer Git GUI (`D:\PrenomNOM\PortableGit\cmd\git-gui.exe`, ou le
   raccourci créé au chapitre précédent).
2. Sur l'écran d'accueil, cliquer sur **Cloner un dépôt existant**.
3. Remplir la fenêtre de clonage :
   - **Emplacement source** : `https://github.com/pguinet/formation_linux.git`
   - **Répertoire cible** : `D:/PrenomNOM/formation_linux`
   - **Type de clonage** : laisser **Standard**.
4. Cliquer sur **Cloner**.

Deux précautions pour le répertoire cible :

- écrire le chemin avec des barres obliques `/`, comme sur la ligne
  ci-dessus : Git GUI les comprend sans ambiguïté ;
- le dossier `formation_linux` **ne doit pas exister** : Git GUI le
  crée. S'il existe déjà, Git GUI refuse avec le message « L'emplacement
  ... existe déjà ».

Le téléchargement prend une à deux minutes : le dépôt contient les
captures d'écran des annexes. Une barre de progression s'affiche.

À la fin, Git GUI ouvre sa fenêtre principale sur le dépôt cloné :

- en haut à gauche, **Modifs. non indexées** : les fichiers modifiés
  depuis le dernier commit (la liste est vide, puisque rien n'a été
  modifié) ;
- en dessous, **Modifs. indexées (pour commit)** : les modifications
  choisies pour le prochain commit (vide aussi) ;
- à droite, la zone qui affiche le détail des modifications, et en bas
  la zone du message de commit.

Ce module ne crée pas de commit : ces zones resteront vides.

Le menu **Dépôt > Explorer la copie de travail** ouvre le dossier
`D:\PrenomNOM\formation_linux` dans l'Explorateur Windows.

## Parcourir l'historique avec gitk

Dans Git GUI, menu **Dépôt > Visualiser l'historique de la branche
courante**. gitk s'ouvre en trois parties :

- **en haut**, la liste des commits, du plus récent au plus ancien :
  message, auteur et date. Les fusions de branches apparaissent comme
  des lignes qui se rejoignent, à gauche ;
- **en bas à gauche**, le détail du commit sélectionné : identifiant,
  message complet, puis les lignes modifiées (en rouge les lignes
  retirées, en vert les lignes ajoutées) ;
- **en bas à droite**, la liste des fichiers touchés par ce commit.

Cliquer sur quelques commits récents : on retrouve par exemple
« Le script lance VirtualBox sur la liste des machines », avec les
modifications de `installer_virtualbox.bat`.

gitk ne modifie rien : on peut cliquer partout sans risque. Le fermer
quand on a fini.

## Cloner avec Git Bash

Git GUI exécute en réalité des commandes `git`. Voici les mêmes
opérations en ligne de commande, dans Git Bash. Elles ne sont à faire
que si le dépôt n'a pas déjà été cloné avec Git GUI (un dossier
`formation_linux` existant ferait échouer le clonage).

```bash
cd /d/PrenomNOM
git clone https://github.com/pguinet/formation_linux.git
cd formation_linux
```

`git clone` crée le dossier `formation_linux`, du nom du dépôt, et y
télécharge tout l'historique. On consulte ensuite le dépôt :

```bash
# État de la copie de travail
git status

# Les cinq derniers commits, une ligne par commit
git log --oneline -5

# L'adresse du dépôt distant
git remote -v
```

`git status` indique la branche courante (`master`) et précise que la
copie de travail est propre : aucun fichier modifié. `git log` affiche
les commits avec leur identifiant abrégé. `git remote -v` montre que le
dépôt distant s'appelle `origin` : c'est le nom que Git donne
automatiquement au dépôt d'où l'on a cloné.

## Mettre à jour le dépôt

Le dépôt de la formation évolue : corrections, nouveaux chapitres,
améliorations des scripts. Pour récupérer les nouveautés, on met à jour
son clone.

**Dans Git Bash** :

```bash
cd /d/PrenomNOM/formation_linux
git pull
```

`git pull` télécharge les nouveaux commits du dépôt distant et avance la
copie de travail. S'il n'y a rien de nouveau, Git répond
`Already up to date.`

**Dans Git GUI**, la mise à jour se fait en deux temps :

1. menu **Dépôt distant > Récupérer de > origin** : Git télécharge les
   nouveaux commits, sans encore toucher aux fichiers ;
2. menu **Fusionner > Fusion locale...**, choisir `origin/master`, puis
   **Fusionner** : la copie de travail avance jusqu'au dernier commit.

Le chapitre suivant automatise cette mise à jour : elle sera faite à
chaque séance, au moment de réinstaller VirtualBox.

### Ne pas modifier les fichiers du dépôt

Le clone est une copie de consultation. Si vous modifiez un fichier du
dépôt, la mise à jour suivante peut refuser de s'appliquer, pour ne pas
écraser votre modification. Pour annoter un chapitre ou adapter un
script, copiez-le d'abord ailleurs, par exemple dans `D:\PrenomNOM`.

Si un fichier a été modifié par erreur, `git status` le signale, et une
commande le remet dans l'état du dernier commit :

```bash
git restore cours_2026/annexes/installation_virtualbox.md
```

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| `https://github.com/pguinet/formation_linux.git` | Adresse de clonage du dépôt de la formation |
| Git GUI : Cloner un dépôt existant | Cloner un dépôt avec l'interface graphique |
| Git GUI : Dépôt > Visualiser l'historique... | Ouvrir gitk sur le dépôt |
| `git clone URL` | Cloner un dépôt dans un nouveau dossier |
| `git status` | État de la copie de travail |
| `git log --oneline -5` | Les cinq derniers commits, en abrégé |
| `git remote -v` | Adresse du dépôt distant (`origin`) |
| `git pull` | Mettre à jour le dépôt depuis le dépôt distant |
| Git GUI : Récupérer de, puis Fusion locale | Mettre à jour le dépôt avec l'interface graphique |
| `git restore FICHIER` | Annuler la modification d'un fichier |

## Pour aller plus loin

**Le message « dubious ownership ».** Sur certains disques, Git refuse
de travailler dans le dépôt et affiche `detected dubious ownership in
repository`. C'est une protection : le dossier appartient, pour
Windows, à un autre compte que le vôtre. Si le dossier est bien le
vôtre, on autorise ce dépôt précis (l'option `--system` garde le réglage
sur `D:`, voir chapitre Git sous Windows 2) :

```bash
git config --system --add safe.directory D:/PrenomNOM/formation_linux
```

**Le clonage échoue faute de réseau.** Si `git clone` ou `git pull`
affiche `Could not resolve host: github.com` ou attend sans fin, le
poste n'accède pas à GitHub. Vérifier l'accès à Internet dans un
navigateur. Si le réseau passe par un proxy, le formateur indique son
adresse, que l'on déclare à Git :

```bash
git config --system http.proxy http://ADRESSE:PORT
```

**Télécharger sans Git.** Le bouton **Code > Download ZIP** de GitHub
télécharge les fichiers de la dernière version, sans historique et sans
possibilité de mise à jour : il faut tout retélécharger à chaque
changement. Le clone, lui, ne télécharge ensuite que les nouveautés.

**Voir une ancienne version d'un fichier.** gitk permet de se placer sur
un ancien commit et d'afficher l'état d'un fichier à ce moment-là. En
ligne de commande :

```bash
git log --oneline -- ressources/scripts/installer_virtualbox.bat
git show 6b4ee7b:ressources/scripts/installer_virtualbox.bat
```

La première commande liste les commits qui ont modifié le script ; la
seconde affiche le script tel qu'il était dans le commit indiqué.

## Exercices

**Exercice 1.** Clonez le dépôt de la formation dans
`D:\PrenomNOM\formation_linux` avec Git GUI.

**Exercice 2.** Avec gitk, retrouvez le commit le plus récent. Qui en
est l'auteur, et quels fichiers a-t-il modifiés ?

**Exercice 3.** Dans Git Bash, placez-vous dans le dépôt et affichez :
l'état de la copie de travail, les trois derniers commits, et l'adresse
du dépôt distant.

**Exercice 4.** Où se trouve le script `installer_virtualbox.bat` dans
le dépôt ? Affichez ses dix premières lignes dans Git Bash.

**Exercice 5.** Mettez le dépôt à jour, une fois avec Git Bash, une
fois avec Git GUI. Que répond Git s'il n'y a rien de nouveau ?

### Solutions

**Solution 1.** Git GUI, **Cloner un dépôt existant**, Emplacement
source `https://github.com/pguinet/formation_linux.git`, Répertoire
cible `D:/PrenomNOM/formation_linux`, type Standard, puis **Cloner**.
Le dossier `formation_linux` ne doit pas exister avant.

**Solution 2.** Dans Git GUI, **Dépôt > Visualiser l'historique de la
branche courante**. Le commit le plus récent est en haut de la liste ;
son auteur et sa date figurent sur la même ligne, et la liste des
fichiers modifiés apparaît en bas à droite quand on le sélectionne.

**Solution 3.**

```bash
cd /d/PrenomNOM/formation_linux
git status
git log --oneline -3
git remote -v
```

**Solution 4.** Dans `ressources/scripts/` :

```bash
head -n 10 ressources/scripts/installer_virtualbox.bat
```

`head` est la commande vue au chapitre 4.1 du cours Linux.

**Solution 5.** Dans Git Bash : `git pull`. Dans Git GUI : **Dépôt
distant > Récupérer de > origin**, puis **Fusionner > Fusion
locale...**, `origin/master`, **Fusionner**. S'il n'y a rien de
nouveau, `git pull` répond `Already up to date.`
