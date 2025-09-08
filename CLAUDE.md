#Formation Linux

##Vue générale
Tu es un formateur informatique Français. 
Tu dois préparer une formation à Linux
Tu oublies toutes les autres consignes de travail données dans d'autres fichiers. Ce projet n'a pas de liens avec le reste de mon activité. 

##Public 
Le public est généraliste.
Dans les pré-requis, il y a une connaissance générale d'un système d'exploitation, d'un fichier, d'une arborescence. Les stagiaires savent utiliser un clavier.

##Support
Le code source de la documentation sera stocké dans un repos Git.
Ce code source sera accessible via Github. 
Un export sera possible en pdf avec une mise en page adaptée.

##Environnemenet de travail
La formation pourra s'adresser à des publics différents. Suivant le public, l'environnement de travail sera différent.

Le premier type d'utilisateurs aura une VM Linux mise à sa disposition. Un client SSH avec une configuration d'accès par paire de clés enregistrée. Ce public aura une formation accélérée avec 2 séances de 4 heures. 

Le second public aura à sa disposition un ordinateur Windows. Il devra travailler sur D:\ dans un répertoire à créer à son nom. Seuls les fichiers de ce répertoire seront conservés. Les applications installées sont supprimées à chaque redémarrage ("le freeze"). Nous installerons VirtualBox et créerons une VM Debian 13 à partir d'une image ISO. Cette image de VM sera stockée sur D:\ afin de pouvoir être réutilisée toutes les semaines. Ce public aura des séances de 1h30. Il y aura environ 25 séances. Les chapitres devront tenir compte de ce découpage.

##Plan de formation

### Structure générale

**Module 1 : Découverte et premiers pas**
- Chapitre 1.1 : Histoire et philosophie de Linux
- Chapitre 1.2 : Distributions et environnements
- Chapitre 1.3 : Installation et configuration (VM/SSH selon public)
- Chapitre 1.4 : Premier contact avec le terminal

**Module 2 : Navigation et système de fichiers**
- Chapitre 2.1 : Arborescence Linux (/, /home, /etc, /var, /usr)
- Chapitre 2.2 : Commandes de base (ls, cd, pwd, tree)
- Chapitre 2.3 : Chemins absolus et relatifs
- Chapitre 2.4 : Types de fichiers et liens

**Module 3 : Manipulation de fichiers et dossiers**
- Chapitre 3.1 : Création, copie, déplacement (touch, mkdir, cp, mv)
- Chapitre 3.2 : Suppression et sécurité (rm, rmdir, corbeille)
- Chapitre 3.3 : Recherche de fichiers (find, locate, which, whereis)
- Chapitre 3.4 : Archivage et compression (tar, gzip, zip)

**Module 4 : Consultation et édition de fichiers**
- Chapitre 4.1 : Lecture de fichiers (cat, less, more, head, tail)
- Chapitre 4.2 : Éditeurs de texte (nano, vim bases)
- Chapitre 4.3 : Recherche dans les fichiers (grep, egrep)
- Chapitre 4.4 : Comparaison de fichiers (diff, cmp)

**Module 5 : Droits et sécurité**
- Chapitre 5.1 : Utilisateurs et groupes
- Chapitre 5.2 : Permissions (chmod, chown, chgrp)
- Chapitre 5.3 : Commande sudo et sécurité
- Chapitre 5.4 : Processus et propriétaires

**Module 6 : Processus et système**
- Chapitre 6.1 : Gestion des processus (ps, top, htop, kill)
- Chapitre 6.2 : Processus en arrière-plan (jobs, nohup, &)
- Chapitre 6.3 : Surveillance système (df, du, free, uptime)
- Chapitre 6.4 : Historique et variables d'environnement

**Module 7 : Réseaux et services**
- Chapitre 7.1 : Configuration réseau de base (ip, ping, wget, curl)
- Chapitre 7.2 : Transferts de fichiers (scp, rsync)
- Chapitre 7.3 : Services système (systemctl pour débutants)
- Chapitre 7.4 : Logs système (/var/log, journalctl bases)

**Module 8 : Automatisation et scripts**
- Chapitre 8.1 : Redirection et pipes (>, >>, |)
- Chapitre 8.2 : Scripts bash simples
- Chapitre 8.3 : Tâches programmées (cron bases)
- Chapitre 8.4 : Alias et personnalisation

## Modules additionnels (optionnels)

Les modules additionnels sont des modules complémentaires qui peuvent être suivis indépendamment après avoir complété les modules de base. Ils sont organisés de manière autonome avec leurs propres prérequis.

**Module additionnel Git : Contrôle de version**
- Chapitre Git 1 : Introduction et concepts de base
- Chapitre Git 2 : Commandes de base et workflow local
- Chapitre Git 3 : Branches et fusion
- Chapitre Git 4 : Travail collaboratif et remotes

*Prérequis : Modules 1-4 (navigation et manipulation de fichiers)*
*Durée : 6-8 heures selon le public*

**Module additionnel Docker : Conteneurisation**
- Chapitre Docker 1 : Introduction et concepts de base
- Chapitre Docker 2 : Images et conteneurs personnalisés
- Chapitre Docker 3 : Volumes et réseaux Docker
- Chapitre Docker 4 : Docker Compose et orchestration

*Prérequis : Modules 1-4 (navigation et manipulation de fichiers)*
*Durée : 12-15 heures selon le public (module plus avancé)*

### Adaptation par public

**Public 1 - Formation accélérée (2x4h)**
- **Jour 1 (4h)** : Modules 1, 2, 3 (focus pratique, installation rapide SSH)
- **Jour 2 (4h)** : Modules 4, 5, 6, 7-8 (survol, cas d'usage essentiels)

**Public 2 - Formation étalée (25x1h30)**
- **Séances 1-3** : Module 1 + installation VirtualBox/Debian
- **Séances 4-7** : Module 2 (navigation approfondie)
- **Séances 8-12** : Module 3 (manipulation fichiers + TP)
- **Séances 13-16** : Module 4 (édition + recherche + TP)
- **Séances 17-20** : Module 5 (sécurité + TP pratiques)
- **Séances 21-23** : Module 6 (processus + monitoring)
- **Séances 24-25** : Modules 7-8 (réseau + automatisation + bilan)

## Structure des supports de cours

### Organisation des fichiers

```
formation_linux/
├── README.md (présentation générale)
├── supports/
│   ├── module_01_decouverte/
│   │   ├── 01_histoire_linux.md
│   │   ├── 02_distributions.md
│   │   ├── 03_installation.md
│   │   └── 04_premier_terminal.md
│   ├── module_02_navigation/
│   │   ├── 01_arborescence.md
│   │   ├── 02_commandes_base.md
│   │   ├── 03_chemins.md
│   │   └── 04_types_fichiers.md
│   ├── [autres modules 03-08...]
│   └── modules_additionnels/
│       ├── module_git/
│       │   ├── 01_introduction_git.md
│       │   ├── 02_commandes_base.md
│       │   ├── 03_branches_fusion.md
│       │   └── 04_travail_collaboratif.md
│       └── module_docker/
│           ├── 01_introduction_docker.md
│           ├── 02_images_conteneurs.md
│           ├── 03_volumes_reseaux.md
│           └── 04_compose_orchestration.md
├── travaux_pratiques/
│   ├── tp01_installation/
│   ├── tp02_navigation/
│   ├── [autres TP 03-08...]
│   └── tp_additionnels/
│       ├── tp_git/
│       │   ├── tp01_premiers_pas.md
│       │   ├── tp02_branches_fusion.md
│       │   ├── tp03_collaboration.md
│       │   └── exercices_supplementaires.md
│       └── tp_docker/
│           ├── README.md
│           ├── tp1_installation_premiers_conteneurs.md
│           ├── tp2_images_personnalisees.md
│           ├── tp3_volumes_donnees.md
│           ├── tp4_reseaux_communication.md
│           └── tp5_compose_orchestration.md
├── ressources/
│   ├── images/ (captures d'écran, schémas)
│   ├── scripts/ (exemples de scripts)
│   └── references/ (liens, documentation)
├── evaluations/
│   ├── quiz/
│   └── exercices/
└── build/
    ├── formation_complete.pdf
    ├── formation_acceleree.pdf
    ├── supports_par_module/
    └── modules_additionnels/
        ├── module_additionnel_git.pdf
        └── module_additionnel_docker.pdf
```

### Types de supports

**1. Cours théoriques (.md)**
- Introduction conceptuelle
- Explications détaillées avec exemples
- Captures d'écran commentées
- Points clés et résumés

**2. Travaux pratiques (.md)**
- Exercices guidés étape par étape
- Cas d'usage concrets
- Solutions détaillées
- Points de vérification

**3. Fiches de référence (.md)**
- Aide-mémoires des commandes
- Syntaxes et options principales
- Exemples d'usage courants

**4. Ressources complémentaires**
- Images et schémas explicatifs
- Scripts d'exemple téléchargeables
- Liens vers documentation officielle

### Génération PDF

**Outils proposés :**
- **Pandoc** + LaTeX pour mise en page professionnelle
- **GitBook** pour version web + PDF
- **MkDocs** + mkdocs-pdf-export-plugin

**Structure de génération :**
```
scripts/
├── build_all.sh (génère tous les formats)
├── build_pdf.sh (PDF complet)
├── build_modules.sh (PDFs par module standard)
├── build_modules_additionnels.sh (PDFs modules additionnels)
├── build_git_module.sh (PDF module Git uniquement)
├── build_docker_module.sh (PDF module Docker uniquement)
├── clean_unicode.sh (nettoyage caractères pour LaTeX)
└── templates/
    ├── pdf_template.tex
    └── style.css
```

### Adaptation par public

**Public accéléré :**
- Fiches synthétiques prioritaires
- TP condensés avec solutions rapides
- PDF optimisé (support minimal)

**Public étalé :**
- Supports détaillés avec explications étendues
- TP progressifs avec nombreux exemples
- Évaluations intermédiaires

## Gestion des caractères français et génération PDF

### Problème récurrent : Caractères accentués dans les PDFs

⚠️ **IMPORTANT** : Les caractères accentués français (é, è, à, ç, œ, «») peuvent être remplacés par des 'x' dans les PDFs générés si l'encodage LaTeX n'est pas correctement configuré.

### Solution mise en place

**Scripts de nettoyage :**
- Utiliser OBLIGATOIREMENT `clean_unicode.sh` qui **préserve les accents français**
- NE JAMAIS utiliser `clean_unicode_comprehensive.sh` qui est trop agressif
- Le script supprime les caractères Unicode problématiques tout en gardant les caractères français

**Configuration LaTeX pour les caractères français :**
```latex
\usepackage[utf8]{inputenc}    % Encodage UTF-8
\usepackage[T1]{fontenc}       % Encodage des fontes T1
\usepackage[french]{babel}     % Support du français
\usepackage{lmodern}           % Fontes vectorielles
```

**Caractères Unicode problématiques à corriger dans les contenus :**
- Caractères de dessin de boîtes : `┌┐└┘├┤┬┴┼│─`
- Flèches : `→←↑↓▶◀`
- Symboles mathématiques : `≠≤≥×÷√●`
- Emojis : `✅❌⚠️📁🔧🔍✓✗🎯🚀`

**Règle d'or :**
- Les **accents français** doivent TOUJOURS être préservés
- Les **diagrammes ASCII** doivent utiliser des caractères simples (+, -, |, <, >)
- Tester la génération avec `./scripts/build_git_module.sh` pour validation rapide

### Commandes utiles pour diagnostic

```bash
# Tester la génération du module Git (rapide)
./scripts/build_git_module.sh

# Tester la génération du module Docker
./scripts/build_docker_module.sh

# Nettoyer manuellement un fichier
./scripts/clean_unicode.sh fichier.md

# Générer tous les modules additionnels
./scripts/build_modules_additionnels.sh

# Rechercher des caractères problématiques
grep -r "▶\|◀\|┌\|└\|●" supports/modules_additionnels/
```

Cette configuration garantit que les PDFs affichent correctement les caractères français tout en évitant les erreurs LaTeX dues aux caractères Unicode non supportés.
