#Formation Linux

##Vue générale
Tu es un formateur informatique Français.
Tu dois préparer une formation à Linux.
Tu oublies toutes les autres consignes de travail données dans d'autres fichiers. Ce projet n'a pas de liens avec le reste de mon activité.

##Public
Le public est généraliste.
Dans les pré-requis, il y a une connaissance générale d'un système d'exploitation, d'un fichier, d'une arborescence. Les stagiaires savent utiliser un clavier.

##Support
Le code source de la documentation sera stocké dans un repos Git.
Ce code source sera accessible via Github.
Un export sera possible en pdf avec une mise en page adaptée.

##Environnement de travail

La formation s'adresse à deux types de public avec des environnements différents. Le détail de l'installation et de la configuration est documenté dans `cours_2026/annexes/installation.md`. L'installation est un prérequis réalisé hors séances.

**Public A - VM distante SSH** : une VM Linux est mise à disposition du stagiaire. Un client SSH est configuré avec accès par paire de clés. L'installation est immédiate, la connexion se fait depuis le premier jour.

**Public B - VirtualBox sur poste Windows** : le stagiaire travaille sur D:\ dans un répertoire créé à son nom. Seuls les fichiers de ce répertoire sont conservés entre les sessions (les applications installées sont supprimées à chaque redémarrage : "le freeze"). VirtualBox est installé et une VM Debian 13 est créée à partir d'une image ISO. L'image de VM est stockée sur D:\ afin d'être réutilisée d'une semaine à l'autre.

##Plan de formation

### Structure du cours de base

Le cours de base tient en **6 séances de 2 heures**, une fois l'environnement installé. Il couvre 22 chapitres répartis en 8 modules.

**Module 1 -- Découverte**
- Chapitre 1.1 : Linux : histoire, philosophie et distributions
- Chapitre 1.2 : Premier contact avec le terminal

**Module 2 -- Navigation**
- Chapitre 2.1 : L'arborescence et les chemins
- Chapitre 2.2 : Se déplacer et explorer (pwd, cd, ls)
- Chapitre 2.3 : Types de fichiers et liens

**Module 3 -- Manipulation**
- Chapitre 3.1 : Créer, copier, déplacer, supprimer
- Chapitre 3.2 : Rechercher des fichiers
- Chapitre 3.3 : Archiver et compresser

**Module 4 -- Consultation et édition**
- Chapitre 4.1 : Lire des fichiers
- Chapitre 4.2 : Éditer avec nano
- Chapitre 4.3 : Chercher dans les fichiers et comparer

**Module 5 -- Droits**
- Chapitre 5.1 : Utilisateurs et groupes
- Chapitre 5.2 : Permissions (chmod, chown)
- Chapitre 5.3 : sudo et bonnes pratiques de sécurité

**Module 6 -- Processus et système**
- Chapitre 6.1 : Les processus : observer et contrôler
- Chapitre 6.2 : Surveillance système
- Chapitre 6.3 : Variables d'environnement et historique

**Module 7 -- Réseau et services**
- Chapitre 7.1 : Réseau et transferts de fichiers
- Chapitre 7.2 : Services et logs

**Module 8 -- Automatisation**
- Chapitre 8.1 : Redirections et pipes
- Chapitre 8.2 : Scripts bash : les bases
- Chapitre 8.3 : cron, alias et personnalisation

### Tableau de progression des séances

| Séance | Contenu |
|--------|---------|
| 1 | Module 1 + chap. 2.1 |
| 2 | Chap. 2.2-2.3 + 3.1-3.2 |
| 3 | Chap. 3.3 + Module 4 |
| 4 | Module 5 + chap. 6.1 |
| 5 | Chap. 6.2-6.3 + Module 7 |
| 6 | Module 8 + bilan |

## Modules additionnels (optionnels)

Les modules additionnels sont des modules complémentaires qui peuvent être suivis indépendamment après avoir complété les modules de base. Ils sont organisés de manière autonome avec leurs propres prérequis.

**Module additionnel Git : Contrôle de version**
- Chapitre Git 1 : Introduction et concepts de base
- Chapitre Git 2 : Commandes de base et workflow local
- Chapitre Git 3 : Branches et fusion
- Chapitre Git 4 : Travail collaboratif et remotes

*Prérequis : Modules 1-4 (navigation et manipulation de fichiers)*
*Durée : 6-8 heures*

**Module additionnel Docker : Conteneurisation**
- Chapitre Docker 1 : Introduction et concepts de base
- Chapitre Docker 2 : Images et conteneurs personnalisés
- Chapitre Docker 3 : Volumes et réseaux Docker
- Chapitre Docker 4 : Docker Compose et orchestration

*Prérequis : Modules 1-4 (navigation et manipulation de fichiers)*
*Durée : 12-15 heures (module plus avancé)*

## Structure des fichiers du projet

```
formation_linux/
  README.md
  cours_2026/                        (contenu actif du cours - a modifier)
    module_01_decouverte/
      01_histoire_philosophie_distributions.md
      02_premier_terminal.md
    module_02_navigation/
      01_arborescence_chemins.md
      02_se_deplacer_explorer.md
      03_types_fichiers_liens.md
    module_03_manipulation/
      01_creer_copier_deplacer_supprimer.md
      02_rechercher_fichiers.md
      03_archiver_compresser.md
    module_04_consultation/
      01_lire_fichiers.md
      02_editer_nano.md
      03_chercher_comparer.md
    module_05_droits/
      01_utilisateurs_groupes.md
      02_permissions.md
      03_sudo_securite.md
    module_06_processus/
      01_processus.md
      02_surveillance_systeme.md
      03_variables_historique.md
    module_07_reseaux/
      01_reseau_transferts.md
      02_services_logs.md
    module_08_automatisation/
      01_redirections_pipes.md
      02_scripts_bash.md
      03_cron_alias_personnalisation.md
    annexes/
      installation.md               (guide d'installation pour les deux environnements)
  supports/
    modules_additionnels/           (toujours actif : modules Git et Docker)
      module_git/
        01_introduction_git.md
        02_commandes_base.md
        03_branches_fusion.md
        04_travail_collaboratif.md
      module_docker/
        01_introduction_docker.md
        02_images_conteneurs.md
        03_volumes_reseaux.md
        04_compose_orchestration.md
  travaux_pratiques/
    tp_additionnels/                (toujours actif : TP Git et Docker)
      tp_git/
        tp01_premiers_pas.md
        tp02_branches_fusion.md
        tp03_collaboration.md
        exercices_supplementaires.md
      tp_docker/
        README.md
        tp1_installation_premiers_conteneurs.md
        tp2_images_personnalisees.md
        tp3_volumes_donnees.md
        tp4_reseaux_communication.md
        tp5_compose_orchestration.md
  archives/
    cours_2025/                     (ANCIEN cours de base, ne plus modifier, conserve en reference)
      supports/                     (modules 01-08)
      travaux_pratiques/            (TP 01-08)
      evaluations/                  (quiz et evaluations finales de l'ancien cours)
  ressources/
    images/
  pdf/                              (chaîne de génération PDF)
    build                           (point d'entrée unique)
    generer.py
    documents.yaml                  (catalogue des PDF)
    preambule.tex
    Dockerfile
    tests/
  docs/
    superpowers/
      specs/                        (spécifications de conception)
      plans/                        (plans d'implémentation)
```

**Remarque** : `archives/cours_2025/` contient l'ancien matériau du cours de base issu de la version précédente. Ne plus le modifier et ne plus le générer en PDF. Tout nouveau contenu de cours va dans `cours_2026/`. `supports/` et `travaux_pratiques/` ne contiennent plus que les modules additionnels Git et Docker, toujours actifs.

## Template de chapitre

Chaque chapitre de `cours_2026/` suit obligatoirement ce template.

### Structure

```
# Chapitre X.Y — Titre du chapitre

> **Objectifs** : [liste des competences acquises a l'issue du chapitre]
> **Duree** : environ 30 min

[Introduction de quelques lignes]

## [Section 1]

[Contenu theorique]

## [Section 2]

[Contenu theorique]

[...]

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| ...               | ...   |

## Pour aller plus loin

[Approfondissements, options avancees, cas particuliers -- environ 100 lignes max]

## Exercices

[3 a 6 exercices progressifs]

### Solutions

[Solutions completes de tous les exercices]
```

### Calibrage

- Corps du chapitre (sections de théorie) : 150 à 200 lignes, maximum 250 avant `## L'essentiel`.
- `## L'essentiel` : tableau récapitulatif des commandes et notions clés du chapitre.
- `## Pour aller plus loin` : environ 100 lignes maximum.
- `## Exercices` : 3 à 6 exercices progressifs avec solutions complètes dans `### Solutions`.

### Principe de non-répétition

Chaque concept n'est enseigné que dans UN chapitre. Dans les autres chapitres, utiliser un renvoi explicite : "(voir chapitre X.Y)".

## Caractères dans les sources

- Les **accents français** sont toujours préservés dans les fichiers source.
- Pas de caractères de dessin de boîtes, de flèches Unicode ni d'emojis : utiliser `+`, `-`, `|` pour les diagrammes, `->` et `<-` pour les flèches.
- Un caractère absent de la police fait échouer `./pdf/build` avec `Missing character` (le caractère fautif est indiqué) : la correction se fait dans la source.

## Génération PDF

**Commandes** (depuis la racine du dépôt) :

```bash
./pdf/build                     # tous les PDF, puis les tests
./pdf/build pdf [FICHIER.pdf]   # PDF seuls (tous, ou ceux indiqués)
./pdf/build test                # tests seuls (pytest)
./pdf/build check               # lint : ruff et shellcheck
./pdf/build shell               # shell dans l'image
```

- Tout tourne dans l'image Docker décrite par `pdf/Dockerfile` (pandoc, LuaLaTeX, Python) : le seul prérequis est Docker.
- Les PDF sont produits dans `build/pdf/`, les fichiers de diagnostic en cas d'échec dans `build/pdf/debug/`.
- Ajouter un PDF : ajouter une entrée dans `pdf/documents.yaml` (et son nom dans `ATTENDUS`, `pdf/tests/test_documents.py`). Chaque fichier source contient exactement un titre de niveau 1 (`#`).
- CI : `.github/workflows/pdf.yml` lance les mêmes commandes. Les PDF sont publiés en artifact à chaque push sur master et à chaque PR ; une release est créée quand on pousse un tag `v*` :

  ```bash
  git tag v2026.1 && git push origin v2026.1
  ```

- La mise en page riche (cadre de couleur, numérotation romaine des pages liminaires, recto-verso) est une évolution possible, pas l'état actuel.
