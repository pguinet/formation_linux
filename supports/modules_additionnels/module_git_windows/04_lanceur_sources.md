# Git sous Windows 4 — Un lanceur toujours à jour dans sources

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - expliquer pourquoi la copie du script dans `sources\` vieillit ;
> - installer le lanceur `lancer_installation.bat` dans `sources\` ;
> - l'utiliser à chaque séance pour mettre à jour le dépôt et lancer la dernière version du script.
>
> **Durée en séance** : ~30 min.

---

À chaque séance, on réinstalle VirtualBox en double-cliquant sur le
script `installer_virtualbox.bat` de `D:\PrenomNOM\sources\` (voir l'annexe
« Installer Debian 13 dans VirtualBox »). Ce fichier est une copie,
téléchargée une fois. Or le script évolue : détection de Visual C++ déjà
présent, lancement automatique de VirtualBox... Votre copie, elle, reste
figée dans la version du jour où vous l'avez téléchargée.

Le dépôt cloné au chapitre précédent contient toujours la dernière
version du script, à condition de le mettre à jour. Ce chapitre met en
place un **lanceur** qui fait les deux d'un coup : il met le dépôt à
jour, puis lance la version du script qui s'y trouve.

## Pourquoi pas un simple raccourci ?

L'idée la plus simple serait un raccourci Windows, dans `sources\`, vers
le script du dépôt :

```
D:\PrenomNOM\formation_linux\ressources\scripts\installer_virtualbox.bat
```

Cela ne fonctionne pas : le script cherche les installeurs de
VirtualBox **dans son propre dossier**. Lancé depuis le dépôt, il les
chercherait dans `ressources\scripts\`, ne les trouverait pas, et
s'arrêterait avec le message « Il manque au moins un fichier ».

Le script accepte donc un **paramètre** : le dossier des installeurs.
Sans paramètre, il cherche dans son dossier, comme avant. Avec un
paramètre, il cherche dans le dossier indiqué. Le lanceur s'en sert pour
lancer le script du dépôt en lui indiquant `sources\`.

Autre avantage : le raccourci lancerait un script qui n'est jamais mis à
jour, alors que le lanceur commence par un `git pull`.

## Ce que fait le lanceur

Le lanceur `lancer_installation.bat` fait partie du dépôt, dans
`ressources\scripts\`, à côté du script d'installation. Une fois copié
dans `sources\`, il :

1. vérifie que le dépôt existe dans `D:\PrenomNOM\formation_linux` ;
2. met le dépôt à jour avec Git portable
   (`D:\PrenomNOM\PortableGit\cmd\git.exe`), comme un `git pull` dans
   Git Bash ;
3. lance le script `installer_virtualbox.bat` du dépôt, en lui
   indiquant le dossier `sources\` où se trouvent les installeurs.

Si la mise à jour est impossible (pas de réseau, Git absent), le lanceur
affiche un avertissement et lance quand même la version du script déjà
présente dans le dépôt : l'installation de VirtualBox n'est jamais
bloquée par Git.

Le cœur du lanceur tient en quelques lignes :

```
set "SOURCES=%~dp0"
for %%I in ("%~dp0..") do set "BASE=%%~fI"
set "GIT=%BASE%\PortableGit\cmd\git.exe"
set "DEPOT=%BASE%\formation_linux"
set "SCRIPT=%DEPOT%\ressources\scripts\installer_virtualbox.bat"

"%GIT%" -C "%DEPOT%" pull --ff-only
call "%SCRIPT%" "%SOURCES:~0,-1%"
```

- `%~dp0` est le dossier du lanceur (`D:\PrenomNOM\sources\`), et la
  ligne `for` en déduit le dossier parent, `D:\PrenomNOM` : le lanceur
  fonctionne quel que soit le nom de votre dossier ;
- `git -C DOSSIER pull` met à jour le dépôt situé dans `DOSSIER`, sans
  avoir à s'y déplacer ;
- `--ff-only` n'autorise que l'avance simple du dépôt : si des fichiers
  du dépôt ont été modifiés à la main, Git refuse sans rien écraser (voir
  chapitre Git sous Windows 3) ;
- `call` lance le script du dépôt et lui passe le dossier `sources\`
  (sans sa barre finale) en paramètre.

Le fichier complet ajoute les vérifications et les messages d'erreur.
Son contenu est consultable dans le dépôt, avec n'importe quel éditeur
de texte ou dans Git Bash :

```bash
cat /d/PrenomNOM/formation_linux/ressources/scripts/lancer_installation.bat
```

## Installer le lanceur dans sources

Une seule fois, copier le lanceur du dépôt vers `sources\`.

**Dans l'Explorateur** : ouvrir
`D:\PrenomNOM\formation_linux\ressources\scripts\`, clic droit sur
`lancer_installation.bat`, **Copier**, puis ouvrir
`D:\PrenomNOM\sources\` et **Coller**. Il faut bien copier, et non
déplacer : le fichier doit rester dans le dépôt, sinon Git le
signalerait comme supprimé.

**Dans Git Bash**, la même opération :

```bash
cp /d/PrenomNOM/formation_linux/ressources/scripts/lancer_installation.bat /d/PrenomNOM/sources/
```

Le dossier `sources\` contient maintenant :

```
D:\PrenomNOM\sources\
+-- Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack
+-- VirtualBox-7.2.20-175154-Win.exe
+-- debian-13.7.0-amd64-DVD-1.iso
+-- PortableGit-2.56.0.2-64-bit.7z.exe
+-- installer_virtualbox.bat      (ancienne copie, gardée en secours)
+-- lancer_installation.bat       (le lanceur)
```

L'ancienne copie `installer_virtualbox.bat` peut rester : elle sert de
secours si le dépôt est abîmé.

Le lanceur lui-même change rarement : c'est le script qu'il lance qui
évolue, et celui-là est mis à jour à chaque séance.

## À chaque séance

Au début de chaque séance, au lieu de lancer `installer_virtualbox.bat` :

1. Double-cliquer sur `D:\PrenomNOM\sources\lancer_installation.bat`.
2. Le lanceur affiche la mise à jour du dépôt :

   ```
   Depot : D:\PrenomNOM\formation_linux
   Already up to date.
     OK : depot a jour.
   ```

   ou, s'il y a des nouveautés, la liste des fichiers mis à jour.
3. Le script d'installation prend le relais, exactement comme avant :
   installation de VirtualBox, réenregistrement de la VM, lancement de
   VirtualBox et résumé final.

Le dossier des installeurs affiché par le script est bien
`D:\PrenomNOM\sources\`, même si le script lancé est celui du dépôt.

## En cas de problème

| Message du lanceur | Cause et solution |
|--------------------|-------------------|
| `Depot introuvable` | Le dépôt n'est pas dans `D:\PrenomNOM\formation_linux` : le cloner (chapitre Git sous Windows 3), ou lancer en attendant `installer_virtualbox.bat` |
| `Git introuvable` | Git portable n'est pas dans `D:\PrenomNOM\PortableGit` : l'extraire (chapitre Git sous Windows 2). Le script présent est lancé quand même |
| `Mise a jour impossible` | Pas de réseau, ou fichiers du dépôt modifiés : vérifier avec `git status` dans Git Bash. Le script présent est lancé quand même |
| `Script introuvable dans le depot` | Le dépôt est incomplet : le supprimer et le cloner à nouveau |

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| `lancer_installation.bat` | Lanceur : met à jour le dépôt puis lance le script d'installation |
| `ressources\scripts\` | Dossier du dépôt qui contient le lanceur et le script |
| `installer_virtualbox.bat DOSSIER` | Lancer le script en lui indiquant le dossier des installeurs |
| `%~dp0` | Dans un `.bat`, le dossier du script en cours |
| `git -C DOSSIER pull` | Mettre à jour le dépôt situé dans `DOSSIER` |
| `--ff-only` | N'accepter que l'avance simple, sans écraser de modification |
| `cp SOURCE DESTINATION` | Copier un fichier dans Git Bash |

## Pour aller plus loin

**Lancer le script du dépôt à la main.** Le paramètre du script peut
servir sans le lanceur, depuis une Invite de commandes :

```
D:\PrenomNOM\formation_linux\ressources\scripts\installer_virtualbox.bat D:\PrenomNOM\sources
```

C'est exactement ce que fait le lanceur, après la mise à jour.

**Mettre aussi les PDF à jour.** Le dépôt contient les sources des
supports, au format Markdown (`.md`), lisibles dans n'importe quel
éditeur de texte. Les PDF, eux, ne sont pas dans le dépôt : ils sont
générés automatiquement et publiés dans les « Releases » du dépôt sur
GitHub, où l'on télécharge toujours la dernière version.

**Pourquoi pas un lien symbolique ?** Windows sait créer des liens
symboliques (commande `mklink`), qui feraient apparaître le script du
dépôt dans `sources\`. Mais leur création demande en général des droits
d'administrateur, que les postes du CID n'accordent pas. Le lanceur
n'a pas cette contrainte.

**Adapter le lanceur.** Le lanceur suppose les noms de dossiers de ce
module : `PortableGit`, `formation_linux` et `sources`, tous trois dans
le même dossier parent. Pour une autre organisation, copier le lanceur
ailleurs que dans le dépôt (pour ne pas bloquer les mises à jour), puis
modifier les lignes `set "GIT=..."` et `set "DEPOT=..."`.

## Exercices

**Exercice 1.** Expliquez pourquoi un raccourci vers le script du dépôt
ne suffit pas pour réinstaller VirtualBox.

**Exercice 2.** Copiez le lanceur dans `sources\`, avec l'Explorateur ou
avec Git Bash. Vérifiez ensuite avec `git status` que le dépôt n'a pas
été modifié.

**Exercice 3.** Lancez `lancer_installation.bat`. Quelle ligne indique
que le dépôt a été mis à jour ? Quel dossier des installeurs le script
affiche-t-il ?

**Exercice 4.** Dans le lanceur, quelle ligne met le dépôt à jour ?
Quel est le rôle de l'option `--ff-only` ?

**Exercice 5.** Que se passe-t-il si vous lancez le lanceur sans réseau ?
L'installation de VirtualBox est-elle bloquée ?

### Solutions

**Solution 1.** Le script cherche les installeurs de VirtualBox dans son
propre dossier. Lancé depuis le dépôt (même par un raccourci), il les
chercherait dans `ressources\scripts\` et s'arrêterait faute de
fichiers. De plus, un raccourci ne met pas le dépôt à jour.

**Solution 2.** Avec Git Bash :

```bash
cp /d/PrenomNOM/formation_linux/ressources/scripts/lancer_installation.bat /d/PrenomNOM/sources/
cd /d/PrenomNOM/formation_linux
git status
```

`git status` indique que la copie de travail est propre : une copie ne
modifie pas le dépôt. Un déplacement, lui, ferait apparaître le lanceur
comme supprimé.

**Solution 3.** La ligne `OK : depot a jour.` confirme la mise à jour
(précédée de `Already up to date.` s'il n'y avait rien de nouveau). Le
script affiche `Dossier des installeurs : D:\PrenomNOM\sources\`.

**Solution 4.** La ligne `"%GIT%" -C "%DEPOT%" pull --ff-only`.
L'option `--ff-only` n'accepte que l'avance simple du dépôt jusqu'aux
nouveaux commits : si des fichiers du dépôt ont été modifiés à la main,
la mise à jour est refusée plutôt que d'écraser ou de mélanger les
modifications.

**Solution 5.** `git pull` échoue : le lanceur affiche « Mise a jour
impossible » puis lance quand même la version du script déjà présente
dans le dépôt. L'installation de VirtualBox se fait normalement, avec
la version du script récupérée lors de la dernière mise à jour.
