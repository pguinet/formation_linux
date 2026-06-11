# Formation Linux

## Vue d'ensemble

Cette formation s'adresse a un public generaliste souhaitant decouvrir et maitriser les bases de Linux.

**Prerequis :** connaissance generale d'un systeme d'exploitation, notion de fichier et d'arborescence, savoir utiliser un clavier.

Le cours theorique de base est organise en **6 seances de 2 heures**, une fois l'environnement installe.
Guide d'installation : `cours_2026/annexes/installation.md`

Chaque chapitre contient :
- la theorie vue en seance (environ 30 minutes),
- une section **L'essentiel** servant de memo,
- une section **Pour aller plus loin** (lecture optionnelle),
- des exercices avec solutions a faire en autonomie.


## Plan du cours (`cours_2026/`)

### Module 1 -- Decouverte

- 1.1 Linux : histoire, philosophie et distributions
- 1.2 Premier contact avec le terminal

### Module 2 -- Navigation

- 2.1 L'arborescence et les chemins
- 2.2 Se deplacer et explorer (pwd, cd, ls)
- 2.3 Types de fichiers et liens

### Module 3 -- Manipulation

- 3.1 Creer, copier, deplacer, supprimer
- 3.2 Rechercher des fichiers
- 3.3 Archiver et compresser

### Module 4 -- Consultation et edition

- 4.1 Lire des fichiers
- 4.2 Editer avec nano
- 4.3 Chercher dans les fichiers et comparer

### Module 5 -- Droits

- 5.1 Utilisateurs et groupes
- 5.2 Permissions (chmod, chown)
- 5.3 sudo et bonnes pratiques de securite

### Module 6 -- Processus et systeme

- 6.1 Les processus : observer et controler
- 6.2 Surveillance systeme
- 6.3 Variables d'environnement et historique

### Module 7 -- Reseau et services

- 7.1 Reseau et transferts de fichiers
- 7.2 Services et logs

### Module 8 -- Automatisation

- 8.1 Redirections et pipes
- 8.2 Scripts bash : les bases
- 8.3 cron, alias et personnalisation

### Annexe

- Guide d'installation de l'environnement (VM SSH ou VirtualBox/Debian 13)


## Tableau des seances (indicatif)

| Seance | Contenu |
|--------|---------|
| 1 | Module 1 + chap. 2.1 (decouverte, terminal, arborescence) |
| 2 | Chap. 2.2-2.3 + 3.1-3.2 (navigation, manipulation, recherche) |
| 3 | Chap. 3.3 + Module 4 (archivage, lecture, edition, grep) |
| 4 | Module 5 + chap. 6.1 (droits, processus) |
| 5 | Chap. 6.2-6.3 + Module 7 (surveillance, environnement, reseau, services) |
| 6 | Module 8 + bilan (redirections, scripts, cron) |


## Modules additionnels

Ces modules sont autonomes et peuvent etre suivis apres les modules de base (1 a 4 minimum).

### Module Git -- Controle de version (6-8h)

Introduction a Git : concepts de base, workflow local, branches et fusion, travail collaboratif.

Contenu : `supports/modules_additionnels/module_git/`
TP : `travaux_pratiques/tp_additionnels/tp_git/`

### Module Docker -- Conteneurisation (12-15h)

Introduction a Docker : images et conteneurs, volumes et reseaux, Docker Compose.

Contenu : `supports/modules_additionnels/module_docker/`
TP : `travaux_pratiques/tp_additionnels/tp_docker/`


## Structure du depot

```
formation_linux/
|
+-- cours_2026/                  # Cours de reference (refonte 2026)
|   +-- module_01_decouverte/
|   +-- module_02_navigation/
|   +-- module_03_manipulation/
|   +-- module_04_consultation/
|   +-- module_05_droits/
|   +-- module_06_processus/
|   +-- module_07_reseaux/
|   +-- module_08_automatisation/
|   +-- annexes/
|       +-- installation.md
|
+-- supports/                    # Ancien materiau (reference)
|   +-- module_0X_*/
|   +-- modules_additionnels/
|       +-- module_git/
|       +-- module_docker/
|
+-- travaux_pratiques/           # Ancien materiau (reference)
|   +-- tp0X_*/
|   +-- tp_additionnels/
|       +-- tp_git/
|       +-- tp_docker/
|
+-- evaluations/                 # Quiz et exercices
+-- ressources/                  # Images, schemas, references
+-- scripts/                     # Scripts de generation PDF
```


## Generation PDF

La chaine de generation est en cours de refonte et ne couvre pas encore `cours_2026/`.

Les PDFs actuellement generes par GitHub Actions couvrent l'ancien contenu (`supports/`).
Pour suivre l'avancement ou declencher manuellement une generation, consulter l'onglet Actions du depot.


## Licence

Ce projet est mis a disposition selon les termes de la
[Licence Creative Commons Attribution - Pas d'Utilisation Commerciale - Partage dans les Memes Conditions 4.0 International](http://creativecommons.org/licenses/by-nc-sa/4.0/).

Vous etes autorise a partager et adapter ce contenu, sous les conditions suivantes :
attribution obligatoire, usage non commercial, partage dans les memes conditions.

**Auteur :** Formation Linux
