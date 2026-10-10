# Git sous Windows 2 — Installer Git sur le lecteur D

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - télécharger et vérifier Git for Windows en version portable ;
> - l'extraire dans `D:\PrenomNOM\PortableGit`, où il survit au freeze ;
> - lancer Git Bash, Git GUI et gitk, et vérifier l'installation.
>
> **Durée en séance** : ~30 min.

---

Les postes du CID sont figés : tout ce qui est installé sur `C:`
disparaît au redémarrage (voir l'annexe « Installer Debian 13 dans
VirtualBox »). Un Git installé de façon classique, dans
`C:\Program Files`, serait donc à réinstaller à chaque séance.

Git for Windows existe heureusement en **version portable** : un
dossier autonome, qui fonctionne là où on le pose, sans installation ni
droits d'administrateur. Placé sur `D:`, il survit au freeze : on
l'installe une seule fois.

## Ce que contient Git for Windows

Git for Windows réunit :

- **git**, le logiciel lui-même, utilisable en ligne de commande ;
- **Git Bash**, un terminal bash qui offre sous Windows les commandes
  vues dans le cours Linux (`ls`, `cd`, `pwd`, `cat`...) en plus de
  `git` ;
- **Git GUI**, une interface graphique pour cloner un dépôt, voir les
  fichiers modifiés et créer des commits ;
- **gitk**, une interface graphique pour parcourir l'historique.

La version portable contient tout cela, dans un dossier d'environ
400 Mo une fois extrait.

## Télécharger la version portable

La page officielle de téléchargement pour Windows est :

<https://git-scm.com/downloads/win>

Dans la rubrique « Portable ("thumbdrive edition") », choisir la version
64 bits. Le lien direct de la version vérifiée le 10 octobre 2026 est :

- Fichier : `PortableGit-2.56.0.2-64-bit.7z.exe` (60 Mo)
- Lien : <https://github.com/git-for-windows/git/releases/download/v2.56.0.windows.2/PortableGit-2.56.0.2-64-bit.7z.exe>

Enregistrer le fichier dans `D:\PrenomNOM\sources\`, à côté des
installeurs de VirtualBox. Une version plus récente convient aussi : seul
le nom du fichier change.

### Vérifier le fichier

Comme pour les fichiers de VirtualBox, on vérifie l'empreinte SHA256 du
téléchargement (la méthode est détaillée dans l'annexe VirtualBox, section
« Vérifier les fichiers téléchargés »). Dans une Invite de commandes :

```
cd /d D:\PrenomNOM\sources
certutil -hashfile PortableGit-2.56.0.2-64-bit.7z.exe SHA256
```

L'empreinte attendue, relevée le 10 octobre 2026 sur le fichier
officiel, est :

```
075e158ef8e1f0ab80b347e245405d3eca735c2dc88fd8e032e137d0ca61f61b
```

Les empreintes officielles de chaque version sont publiées en bas de la
page de la version sur GitHub (lien « Releases » de
`github.com/git-for-windows/git`).

## Extraire Git dans D:\PrenomNOM\PortableGit

Le fichier téléchargé est une archive auto-extractible : un programme
qui se décompresse lui-même.

1. Double-cliquer sur `PortableGit-2.56.0.2-64-bit.7z.exe`. Si Windows
   affiche « Windows a protégé votre ordinateur », cliquer sur
   **Informations complémentaires**, puis **Exécuter quand même**.
2. Une petite fenêtre demande le dossier de destination. Remplacer le
   chemin proposé par :

   ```
   D:\PrenomNOM\PortableGit
   ```

3. Cliquer sur **OK**. L'extraction dure une à deux minutes. Une
   fenêtre noire peut s'ouvrir brièvement à la fin : c'est le script de
   finalisation de Git, qui se ferme seul.

Aucune autorisation d'administrateur n'est demandée : tout se passe dans
votre dossier.

Votre dossier ressemble maintenant à ceci :

```
D:\PrenomNOM\
+-- PortableGit\        (Git for Windows, version portable)
+-- sources\            (installeurs, image de Debian, scripts)
+-- VirtualBox\         (la machine virtuelle)
```

L'archive `PortableGit-...7z.exe` peut rester dans `sources\` : elle
permet de réinstaller Git si le dossier `PortableGit` est abîmé.

## Les programmes utiles

Dans `D:\PrenomNOM\PortableGit`, trois programmes nous intéressent :

| Programme | Emplacement | Rôle |
|-----------|-------------|------|
| Git Bash | `git-bash.exe` | terminal bash avec `git` |
| Git GUI | `cmd\git-gui.exe` | interface graphique principale |
| gitk | `cmd\gitk.exe` | historique des commits |

On les lance par un double-clic dans l'Explorateur. Le menu Démarrer et
le bureau font partie du profil Windows, effacé au freeze : un raccourci
posé sur le bureau disparaîtrait. Pour un accès rapide, créer plutôt les
raccourcis dans `D:\PrenomNOM` : clic droit sur `git-bash.exe` ou
`git-gui.exe`, puis **Créer un raccourci** (sous Windows 11, d'abord
**Afficher d'autres options**), et déplacer le raccourci créé dans
`D:\PrenomNOM`.

## Vérifier l'installation avec Git Bash

Double-cliquer sur `git-bash.exe`. Une fenêtre de terminal s'ouvre,
avec une invite de ce genre :

```
PrenomNOM@POSTE-CID MINGW64 ~
$
```

Taper :

```bash
git --version
```

Git affiche sa version :

```
git version 2.56.0.windows.2
```

Git Bash utilise des chemins à la façon de Linux : le lecteur `D:`
s'écrit `/d`, et les barres obliques vont dans l'autre sens.

```bash
cd /d/PrenomNOM
pwd
ls
```

`pwd` affiche `/d/PrenomNOM`, et `ls` liste `PortableGit`, `sources` et
`VirtualBox`. Les commandes de navigation sont celles du cours Linux
(voir chapitre 2.2). Taper `exit` pour fermer la fenêtre.

## Découvrir Git GUI et gitk

Double-cliquer sur `cmd\git-gui.exe`. Sans dépôt ouvert, Git GUI
affiche un écran d'accueil avec trois choix :

- **Créer nouveau dépôt** ;
- **Cloner un dépôt existant** : c'est ce que fera le chapitre suivant ;
- **Ouvrir un dépôt existant**.

Git GUI s'affiche dans la langue de Windows : en français sur les postes
du CID. Sur un Windows en anglais, les mêmes choix s'appellent « Create
New Repository », « Clone Existing Repository » et « Open Existing
Repository ».

gitk, lui, a besoin d'un dépôt pour afficher son historique : on le
lancera depuis Git GUI, une fois le dépôt de la formation cloné.
Fermer Git GUI pour l'instant (menu **Dépôt > Quitter**).

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| Version portable | Git dans un dossier autonome, sans installation ni droits admin |
| `PortableGit-...-64-bit.7z.exe` | Archive auto-extractible de la version portable |
| `D:\PrenomNOM\PortableGit` | Dossier de Git, conservé malgré le freeze |
| `certutil -hashfile FICHIER SHA256` | Calculer l'empreinte d'un fichier sous Windows |
| `git-bash.exe` | Terminal bash avec `git` et les commandes Linux |
| `cmd\git-gui.exe` | Interface graphique principale de Git |
| `cmd\gitk.exe` | Interface graphique de l'historique |
| `git --version` | Afficher la version de Git installée |
| `/d/PrenomNOM` | Chemin de `D:\PrenomNOM` dans Git Bash |

## Pour aller plus loin

**Déclarer son identité.** Pour créer des commits, Git a besoin d'un nom
et d'une adresse électronique. La commande habituelle,
`git config --global`, enregistre ces réglages dans le profil Windows,
sur `C:` : ils disparaîtraient au freeze. Avec la version portable, on
peut les enregistrer dans le dossier de Git lui-même, sur `D:`, avec
l'option `--system` :

```bash
git config --system user.name "Prénom Nom"
git config --system user.email "prenom.nom@example.org"
git config --system --list
```

Ce module ne crée pas de commit : cette étape est facultative.

**Les trois niveaux de configuration.** Git lit ses réglages à trois
endroits, du plus général au plus précis : `--system` (le dossier de
Git, ici `PortableGit\etc\gitconfig`), `--global` (le profil de
l'utilisateur) et `--local` (le dépôt, dans `.git\config`). Un réglage
plus précis l'emporte sur un réglage plus général.

**Git en dehors de Git Bash.** Le dossier `PortableGit\cmd` contient
aussi `git.exe`, utilisable depuis une Invite de commandes ou depuis un
script `.bat` en donnant son chemin complet :

```
D:\PrenomNOM\PortableGit\cmd\git.exe --version
```

C'est ainsi que le lanceur du chapitre 4 appelle Git.

**Installation classique.** Sur un poste personnel, l'installeur
habituel de Git for Windows (même page de téléchargement) installe Git
pour tous les utilisateurs, ajoute Git Bash et Git GUI au menu Démarrer
et au clic droit de l'Explorateur, et propose de nombreuses options. Au
CID, la version portable reste préférable à cause du freeze.

## Exercices

**Exercice 1.** Pourquoi installe-t-on Git en version portable sur `D:`
plutôt qu'avec l'installeur classique ?

**Exercice 2.** Téléchargez la version portable, vérifiez son empreinte
et extrayez-la dans `D:\PrenomNOM\PortableGit`.

**Exercice 3.** Dans Git Bash, affichez la version de Git, puis placez
vous dans votre dossier sur `D:` et listez son contenu.

**Exercice 4.** Créez dans `D:\PrenomNOM` un raccourci vers Git GUI,
puis ouvrez Git GUI avec ce raccourci. Quels sont les trois choix de
l'écran d'accueil ?

**Exercice 5.** Dans Git Bash, quel est le chemin du dossier
`D:\PrenomNOM\sources` ? Vérifiez-le avec `ls`.

### Solutions

**Solution 1.** Le disque `C:` est remis à zéro à chaque redémarrage :
un Git installé dans `C:\Program Files` disparaîtrait d'une séance à
l'autre. La version portable, posée sur `D:`, est conservée et
fonctionne sans droits d'administrateur.

**Solution 2.** Suivre les sections « Télécharger la version
portable », « Vérifier le fichier » et « Extraire Git ». La commande
`certutil` doit afficher l'empreinte attendue ; sinon, supprimer le
fichier et le télécharger à nouveau.

**Solution 3.**

```bash
git --version
cd /d/PrenomNOM
ls
```

La première commande affiche `git version 2.56.0.windows.2` (ou une
version plus récente) ; `ls` liste `PortableGit`, `sources` et
`VirtualBox`.

**Solution 4.** Dans `D:\PrenomNOM\PortableGit\cmd`, clic droit sur
`git-gui.exe`, **Créer un raccourci** (sous Windows 11, d'abord
**Afficher d'autres options**), puis déplacer le raccourci dans `D:\PrenomNOM`. Un double-clic ouvre Git GUI,
qui propose : **Créer nouveau dépôt**, **Cloner un dépôt existant** et
**Ouvrir un dépôt existant**.

**Solution 5.** `/d/PrenomNOM/sources` :

```bash
ls /d/PrenomNOM/sources
```

La commande liste les installeurs de VirtualBox, l'image de Debian, le
script `installer_virtualbox.bat` et l'archive de Git portable.
