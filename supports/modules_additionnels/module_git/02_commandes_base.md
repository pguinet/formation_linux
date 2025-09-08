# Module Git - Chapitre 2 : Commandes de base et workflow local

## Objectifs du chapitre
À l'issue de ce chapitre, vous serez capable de :
- Créer et initialiser un dépôt Git
- Gérer le cycle de vie des fichiers (ajout, modification, suppression)
- Effectuer des commits efficaces
- Consulter l'historique et les différences
- Utiliser les commandes fondamentales du workflow Git

---

## 1. Initialiser un dépôt Git

### Créer un nouveau dépôt
```bash
# Créer un dossier pour le projet
mkdir mon_projet
cd mon_projet

# Initialiser Git dans ce dossier
git init
```

**Résultat :**
```
Initialized empty Git repository in /home/user/mon_projet/.git/
```

### Que s'est-il passé ?
- Un dossier caché `.git/` a été créé
- Ce dossier contient toute la "magie" de Git
- Le dossier devient un **dépôt Git**

```bash
# Vérifier le contenu
ls -la
# On voit le dossier .git/

# Explorer le dossier .git (optionnel)
ls .git/
```

---

## 2. Le cycle de vie des fichiers dans Git

### États des fichiers
Un fichier dans Git peut être dans 4 états :

```
Non tracké     Modifié        En index       Committé
(Untracked)   (Modified)     (Staged)       (Committed)
     |             |             |              |
     |git add      |git add      |git commit    |
     +------------->+------------->+------------->|
                        |                       |
                        |        Modifié       |
                        +<---------------------+
```

1. **Non tracké** : nouveau fichier, Git l'ignore
2. **Modifié** : fichier tracké qui a été modifié
3. **En index** : modifications ajoutées à la zone d'index
4. **Committé** : modifications sauvegardées dans l'historique

### Vérifier l'état : git status
```bash
git status
```

**Exemple de sortie :**
```
On branch master

No commits yet

nothing to commit (create/copy files and use "git add" to track)
```

---

## 3. Ajouter des fichiers

### Créer et ajouter le premier fichier
```bash
# Créer un fichier
echo "# Mon Premier Projet" > README.md

# Vérifier l'état
git status
```

**Sortie :**
```
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	README.md

nothing added to commit but untracked files present (use "git add" to track them)
```

### La commande git add
```bash
# Ajouter un fichier spécifique
git add README.md

# Vérifier l'état
git status
```

**Sortie :**
```
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file:   README.md
```

### Variantes de git add
```bash
# Ajouter plusieurs fichiers
git add fichier1.txt fichier2.txt

# Ajouter tous les fichiers modifiés
git add .

# Ajouter tous les fichiers (même supprimés)
git add -A

# Ajouter de façon interactive
git add -i

# Ajouter seulement certaines parties d'un fichier
git add -p
```

---

## 4. Effectuer un commit

### Premier commit
```bash
git commit -m "Premier commit : ajout du README"
```

**Sortie :**
```
[master (root-commit) a1b2c3d] Premier commit : ajout du README
 1 file changed, 1 insertion(+)
 create mode 100644 README.md
```

### Anatomie d'un bon message de commit
Un bon message de commit doit :
- **Être concis** (moins de 50 caractères pour le titre)
- **Commencer par un verbe** à l'impératif
- **Expliquer le "pourquoi"** pas le "comment"

```bash
# ✅ Bons messages
git commit -m "Ajouter validation des emails"
git commit -m "Corriger bug de connexion timeout"
git commit -m "Améliorer performance de recherche"

# ❌ Mauvais messages
git commit -m "fix"
git commit -m "changement"
git commit -m "ça marche maintenant"
```

### Message multi-ligne
```bash
git commit -m "Ajouter système d'authentification

- Implémentation de la connexion utilisateur
- Ajout de la validation des mots de passe
- Tests unitaires pour les nouvelles fonctions"
```

### Commit sans passer par l'index
```bash
# Pour les fichiers déjà trackés
git commit -am "Message de commit"
# Équivaut à : git add -A && git commit -m "Message"
```

---

## 5. Consulter l'historique

### git log : l'historique des commits
```bash
# Historique complet
git log
```

**Sortie typique :**
```
commit a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0 (HEAD -> master)
Author: Votre Nom <votre.email@exemple.com>
Date:   Mon Dec 4 10:30:00 2023 +0100

    Premier commit : ajout du README
```

### Variantes de git log
```bash
# Historique condensé (une ligne par commit)
git log --oneline

# Avec graphique des branches
git log --graph

# Limiter le nombre de commits
git log -n 5

# Historique avec les fichiers modifiés
git log --stat

# Rechercher dans les messages
git log --grep="bug"

# Commits d'un auteur
git log --author="Votre Nom"

# Commits sur une période
git log --since="2023-12-01" --until="2023-12-31"
```

### git show : détails d'un commit
```bash
# Détails du dernier commit
git show

# Détails d'un commit spécifique
git show a1b2c3d

# Seulement les fichiers modifiés
git show --name-only a1b2c3d
```

---

## 6. Voir les différences

### git diff : comparer les versions
```bash
# Différences entre zone de travail et index
git diff

# Différences entre index et dernier commit
git diff --cached

# Différences entre zone de travail et dernier commit
git diff HEAD

# Différences entre deux commits
git diff a1b2c3d e5f6g7h

# Différences sur un fichier spécifique
git diff README.md
```

**Exemple de sortie :**
```diff
diff --git a/README.md b/README.md
index 1234567..abcdefg 100644
--- a/README.md
+++ b/README.md
@@ -1 +1,3 @@
 # Mon Premier Projet
+
+Ce projet sert d'exemple pour apprendre Git.
```

### Comprendre la sortie de git diff
- `---` : version ancienne
- `+++` : version nouvelle
- `@@` : numéros de lignes
- `-` : ligne supprimée
- `+` : ligne ajoutée
- (espace) : ligne inchangée

---

## 7. Workflow complet - Exemple pratique

### Scénario : Ajouter du contenu au projet
```bash
# 1. Créer de nouveaux fichiers
echo "print('Hello World')" > hello.py
mkdir docs
echo "# Documentation" > docs/guide.md

# 2. Vérifier l'état
git status

# 3. Ajouter à l'index
git add hello.py docs/

# 4. Vérifier ce qui va être commité
git status
git diff --cached

# 5. Commiter
git commit -m "Ajouter script Python et documentation"

# 6. Vérifier l'historique
git log --oneline
```

### Modifier un fichier existant
```bash
# 1. Modifier le README
echo "
## Description
Ce projet contient des exemples Git." >> README.md

# 2. Voir les modifications
git diff README.md

# 3. Ajouter et commiter
git add README.md
git commit -m "Améliorer description du projet"
```

---

## 8. Annuler des modifications

### Annuler des modifications non indexées
```bash
# Restaurer un fichier à sa version du dernier commit
git checkout -- fichier.txt

# Restaurer tous les fichiers
git checkout -- .

# Alternative moderne (Git 2.23+)
git restore fichier.txt
```

### Retirer de l'index (unstage)
```bash
# Retirer un fichier de l'index
git reset HEAD fichier.txt

# Alternative moderne
git restore --staged fichier.txt
```

### Modifier le dernier commit
```bash
# Modifier le message du dernier commit
git commit --amend -m "Nouveau message"

# Ajouter des fichiers au dernier commit
git add fichier_oublie.txt
git commit --amend --no-edit
```

---

## 9. Ignorer des fichiers : .gitignore

### Créer un fichier .gitignore
```bash
# Créer le fichier
nano .gitignore
```

**Contenu typique :**
```
# Fichiers temporaires
*.tmp
*.log
*~

# Dossiers de build
build/
dist/
target/

# Fichiers de l'IDE
.vscode/
.idea/
*.swp

# Dépendances
node_modules/
__pycache__/

# Fichiers système
.DS_Store
Thumbs.db
```

### Patterns dans .gitignore
```bash
# Fichier spécifique
config.ini

# Extension
*.log

# Dossier
temp/

# Tout sauf...
*
!*.py
!README.md

# Commentaire
# Ceci est un commentaire
```

### Ajouter .gitignore au dépôt
```bash
git add .gitignore
git commit -m "Ajouter fichier .gitignore"
```

---

## 10. Raccourcis et bonnes pratiques

### Alias Git utiles
```bash
# Configuration d'alias
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.visual '!gitk'

# Utilisation
git st        # au lieu de git status
git co master # au lieu de git checkout master
```

### Bonnes pratiques
1. **Commitez souvent** avec des messages clairs
2. **Testez avant de commiter**
3. **Un commit = une fonctionnalité/correction**
4. **Utilisez .gitignore** dès le début
5. **Révisez vos commits** avec `git log` et `git diff`

---

## Points clés à retenir

1. **git init** : initialise un dépôt
2. **git add** : ajoute à l'index
3. **git commit** : sauvegarde dans l'historique
4. **git status** : état du dépôt
5. **git log** : historique des commits
6. **git diff** : voir les différences
7. **Workflow** : modifier → add → commit

---

## Commandes essentielles - Aide-mémoire

```bash
# Initialisation et configuration
git init
git config --global user.name "Nom"
git config --global user.email "email@exemple.com"

# Cycle de base
git status
git add <fichier>
git commit -m "message"

# Consulter
git log
git log --oneline
git diff
git show

# Annuler
git checkout -- <fichier>    # annuler modifications
git reset HEAD <fichier>      # retirer de l'index
git commit --amend           # modifier dernier commit
```

---

## Pour la suite

Au chapitre suivant, nous verrons comment travailler avec les **branches** pour développer plusieurs fonctionnalités en parallèle et gérer les **fusions** (merge).