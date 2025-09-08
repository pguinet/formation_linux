# Module Git - Chapitre 1 : Introduction et concepts de base

## Prérequis
- Avoir suivi les modules 1 à 4 de la formation Linux
- Maîtriser les commandes de base du terminal (cd, ls, mkdir, touch, etc.)
- Savoir éditer des fichiers avec nano ou vim

## Objectifs du chapitre
À l'issue de ce chapitre, vous serez capable de :
- Comprendre ce qu'est un système de contrôle de version
- Expliquer les concepts fondamentaux de Git
- Distinguer Git des autres systèmes de versioning
- Installer et configurer Git sur votre système

---

## 1. Qu'est-ce qu'un système de contrôle de version ?

### Problème sans versioning
Imaginez que vous travaillez sur un projet important :
- `mon_projet.txt` (version initiale)
- `mon_projet_v2.txt` (après modifications)
- `mon_projet_final.txt` (version finale... ou pas ?)
- `mon_projet_final_VRAIMENT.txt` (la vraie version finale)
- `mon_projet_backup_20241201.txt` (sauvegarde)

**Problèmes rencontrés :**
- Quelle est la vraie dernière version ?
- Quelles modifications ont été apportées entre les versions ?
- Comment revenir à une version antérieure ?
- Comment collaborer à plusieurs sur le même projet ?

### Solution : le contrôle de version
Un **système de contrôle de version** (VCS - Version Control System) permet de :
- **Traquer les modifications** de fichiers dans le temps
- **Conserver l'historique** complet des changements
- **Collaborer** efficacement à plusieurs
- **Revenir** à des versions antérieures
- **Comparer** les différentes versions
- **Gérer les conflits** lors de modifications simultanées

---

## 2. Git : présentation générale

### Qu'est-ce que Git ?
Git est un **système de contrôle de version distribué** créé par Linus Torvalds en 2005 pour le développement du noyau Linux.

### Caractéristiques principales
- **Distribué** : chaque développeur a une copie complète de l'historique
- **Rapide** : optimisé pour la vitesse
- **Intégrité** : utilise des sommes de contrôle (hash SHA-1)
- **Branching** : création et fusion de branches très efficace
- **Open Source** : libre et gratuit

### Git vs autres systèmes
| Caractéristique | Git | SVN | CVS |
|-----------------|-----|-----|-----|
| Architecture | Distribué | Centralisé | Centralisé |
| Vitesse | Très rapide | Moyen | Lent |
| Branches | Excellentes | Correctes | Basiques |
| Hors ligne | Complet | Limité | Non |

---

## 3. Concepts fondamentaux

### Le dépôt (Repository)
Un **dépôt** (ou repo) est un dossier contenant :
- Vos fichiers de projet
- L'historique complet des modifications
- Les métadonnées Git (dossier `.git/`)

### Les trois zones de Git

```
Zone de travail     Zone d'index        Dépôt local
(Working Directory) (Staging Area)      (Repository)
+-----------------+ +-----------------+ +-----------------+
| Fichiers        | | Modifications   | | Commits         |
| modifiés        | | prêtes pour     | | (historique)    |
|                 | | commit          | |                 |
+-----------------+ +-----------------+ +-----------------+
        |                    |                    |
        |   git add          |   git commit       |
        +-------------------->+-------------------->|
```

1. **Zone de travail** : vos fichiers actuels
2. **Zone d'index** : préparation des modifications à enregistrer
3. **Dépôt local** : historique des commits

### Les commits
Un **commit** est un instantané de votre projet à un moment donné :
- Contient les modifications apportées
- A un identifiant unique (hash SHA-1)
- Inclut un message descriptif
- Pointe vers le commit parent

---

## 4. Installation et configuration

### Installation de Git

**Sur Debian/Ubuntu :**
```bash
sudo apt update
sudo apt install git
```

**Sur CentOS/RHEL :**
```bash
sudo yum install git
# ou sur les versions récentes :
sudo dnf install git
```

**Vérification :**
```bash
git --version
```

### Configuration initiale
Git a besoin de connaître votre identité pour les commits :

```bash
# Configuration globale (pour tous les projets)
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@exemple.com"

# Configuration de l'éditeur par défaut
git config --global core.editor nano

# Vérification de la configuration
git config --list
```

### Niveaux de configuration
1. **Système** (`--system`) : pour tous les utilisateurs
2. **Global** (`--global`) : pour l'utilisateur courant
3. **Local** (défaut) : pour le projet courant

---

## 5. Aide et documentation

### Commandes d'aide
```bash
# Aide générale
git help

# Aide pour une commande spécifique
git help add
git help commit

# Version courte de l'aide
git add --help
```

### Structure de la documentation Git
- `git help tutorial` : tutoriel pour débutants
- `git help workflows` : workflows courants
- `git help everyday` : commandes quotidiennes

---

## Points clés à retenir

1. **Git est distribué** : chaque développeur a l'historique complet
2. **Trois zones** : travail, index, dépôt local
3. **Les commits** sont des instantanés permanents
4. **Configuration obligatoire** : nom et email
5. **Git track les modifications**, pas les fichiers

---

## Pour aller plus loin

- Site officiel : [git-scm.com](https://git-scm.com)
- Documentation : [git-scm.com/doc](https://git-scm.com/doc)
- Tutoriel interactif : [learngitbranching.js.org](https://learngitbranching.js.org)

---

## Exercice de validation

**Question :** Expliquez en vos propres mots la différence entre un système centralisé (comme SVN) et un système distribué (comme Git).

**Réponse attendue :** Dans un système centralisé, il y a un serveur central qui contient l'historique complet, et les développeurs n'ont que des copies de travail. Dans un système distribué comme Git, chaque développeur a une copie complète de l'historique, ce qui permet de travailler hors ligne et améliore la résilience.