# Formation Linux

## Vue d'ensemble

Cette formation s'adresse à un public généraliste souhaitant découvrir et maîtriser les bases de Linux.

**Prérequis :** connaissance générale d'un système d'exploitation, notion de fichier et d'arborescence, savoir utiliser un clavier.

Le cours théorique de base est organisé en **6 séances de 2 heures**, une fois l'environnement installé.
Guides d'installation : `cours_2026/annexes/installation_ssh.md` (VM distante, SSH) et
`cours_2026/annexes/installation_virtualbox.md` (Debian 13 dans VirtualBox, poste Windows du CID).

Chaque chapitre contient :
- la théorie vue en séance (environ 30 minutes),
- une section **L'essentiel** servant de mémo,
- une section **Pour aller plus loin** (lecture optionnelle),
- des exercices avec solutions à faire en autonomie.


## Plan du cours (`cours_2026/`)

### Module 1 -- Découverte

- 1.1 Linux : histoire, philosophie et distributions
- 1.2 Premier contact avec le terminal

### Module 2 -- Navigation

- 2.1 L'arborescence et les chemins
- 2.2 Se déplacer et explorer (pwd, cd, ls)
- 2.3 Types de fichiers et liens

### Module 3 -- Manipulation

- 3.1 Créer, copier, déplacer, supprimer
- 3.2 Rechercher des fichiers
- 3.3 Archiver et compresser

### Module 4 -- Consultation et édition

- 4.1 Lire des fichiers
- 4.2 Éditer avec nano
- 4.3 Chercher dans les fichiers et comparer

### Module 5 -- Droits

- 5.1 Utilisateurs et groupes
- 5.2 Permissions (chmod, chown)
- 5.3 sudo et bonnes pratiques de sécurité

### Module 6 -- Processus et système

- 6.1 Les processus : observer et contrôler
- 6.2 Surveillance système
- 6.3 Variables d'environnement et historique

### Module 7 -- Réseau et services

- 7.1 Réseau et transferts de fichiers
- 7.2 Services et logs

### Module 8 -- Automatisation

- 8.1 Redirections et pipes
- 8.2 Scripts bash : les bases
- 8.3 cron, alias et personnalisation

### Annexe

- Se connecter à sa VM distante (SSH)
- Installer Debian 13 dans VirtualBox (illustré, avec le script `ressources/scripts/installer_virtualbox.bat`)


## Tableau des séances (indicatif)

| Séance | Contenu |
|--------|---------|
| 1 | Module 1 + chap. 2.1 (découverte, terminal, arborescence) |
| 2 | Chap. 2.2-2.3 + 3.1-3.2 (navigation, manipulation, recherche) |
| 3 | Chap. 3.3 + Module 4 (archivage, lecture, édition, grep) |
| 4 | Module 5 + chap. 6.1 (droits, processus) |
| 5 | Chap. 6.2-6.3 + Module 7 (surveillance, environnement, réseau, services) |
| 6 | Module 8 + bilan (redirections, scripts, cron) |


## Modules additionnels

Ces modules sont autonomes et peuvent être suivis après les modules de base (1 à 4 minimum).

### Module Git -- Contrôle de version (6-8h)

Introduction à Git : concepts de base, workflow local, branches et fusion, travail collaboratif.

Contenu : `supports/modules_additionnels/module_git/`
TP : `travaux_pratiques/tp_additionnels/tp_git/`

### Module Docker -- Conteneurisation (12-15h)

Introduction à Docker : images et conteneurs, volumes et réseaux, Docker Compose.

Contenu : `supports/modules_additionnels/module_docker/`
TP : `travaux_pratiques/tp_additionnels/tp_docker/`


## Structure du dépôt

```
formation_linux/
|
+-- cours_2026/                  # Cours de référence (refonte 2026)
|   +-- module_01_decouverte/
|   +-- module_02_navigation/
|   +-- module_03_manipulation/
|   +-- module_04_consultation/
|   +-- module_05_droits/
|   +-- module_06_processus/
|   +-- module_07_reseaux/
|   +-- module_08_automatisation/
|   +-- annexes/
|       +-- installation_ssh.md
|       +-- installation_virtualbox.md
|
+-- supports/
|   +-- modules_additionnels/    # Modules additionnels (contenu)
|       +-- module_git/
|       +-- module_docker/
|
+-- travaux_pratiques/
|   +-- tp_additionnels/         # Modules additionnels (TP)
|       +-- tp_git/
|       +-- tp_docker/
|
+-- archives/
|   +-- cours_2025/              # Ancien cours de base (référence, figé)
|       +-- supports/            # Modules 01-08
|       +-- travaux_pratiques/   # TP 01-08
|       +-- evaluations/         # Quiz et évaluations de l'ancien cours
|
+-- ressources/                  # Images, schémas, références
+-- pdf/                         # Génération des PDF (./pdf/build)
```


## Génération PDF

Les PDF de la formation (un par module, plus les modules additionnels et les deux annexes d'installation) sont disponibles dans les [Releases](../../releases/latest) du dépôt.

Pour les générer localement, Docker suffit :

```bash
./pdf/build
```

Les PDF sont produits dans `build/pdf/`.


## Licence

Ce projet est mis à disposition selon les termes de la
[Licence Creative Commons Attribution - Pas d'Utilisation Commerciale - Partage dans les Mêmes Conditions 4.0 International](http://creativecommons.org/licenses/by-nc-sa/4.0/).

Vous êtes autorisé à partager et adapter ce contenu, sous les conditions suivantes :
attribution obligatoire, usage non commercial, partage dans les mêmes conditions.

**Auteur :** Formation Linux
