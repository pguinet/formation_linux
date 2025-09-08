# Module Git - Chapitre 3 : Branches et fusion

## Objectifs du chapitre
À l'issue de ce chapitre, vous serez capable de :
- Comprendre le concept de branche dans Git
- Créer, basculer entre et supprimer des branches
- Fusionner des branches (merge)
- Gérer les conflits de fusion
- Utiliser des stratégies de fusion avancées
- Organiser un workflow avec des branches

---

## 1. Concept de branche

### Qu'est-ce qu'une branche ?
Une **branche** est une ligne de développement indépendante qui permet de :
- Développer plusieurs fonctionnalités **en parallèle**
- **Isoler** les modifications expérimentales
- Collaborer sans se **marcher dessus**
- Maintenir un **historique propre**

### Visualisation des branches
```
master:  A---B---C---F
              \     /
feature:       D---E
```

- La branche `master` contient A, B, C, F
- La branche `feature` a divergé en D, E
- F est la fusion de `feature` dans `master`

### Branches = pointeurs légers
En réalité, une branche Git n'est qu'un **pointeur** vers un commit :
- Très rapide à créer (quelques millisecondes)
- Prend très peu d'espace disque
- Encourager l'utilisation de branches !

---

## 2. Gestion des branches

### Voir les branches existantes
```bash
# Lister les branches locales
git branch

# Lister toutes les branches (locales et distantes)
git branch -a

# Voir la branche active
git branch --show-current
```

**Sortie typique :**
```
* master
  feature-login
  bugfix-typo
```
L'astérisque (*) indique la branche active.

### Créer une nouvelle branche
```bash
# Créer une branche (sans basculer dessus)
git branch nouvelle-fonctionnalite

# Créer et basculer immédiatement
git checkout -b nouvelle-fonctionnalite

# Alternative moderne (Git 2.23+)
git switch -c nouvelle-fonctionnalite
```

### Basculer entre les branches
```bash
# Basculer sur une branche existante
git checkout nom-branche

# Alternative moderne
git switch nom-branche

# Revenir à la branche précédente
git checkout -
git switch -
```

### Renommer une branche
```bash
# Renommer la branche courante
git branch -m nouveau-nom

# Renommer une autre branche
git branch -m ancien-nom nouveau-nom
```

### Supprimer une branche
```bash
# Supprimer une branche fusionnée
git branch -d nom-branche

# Forcer la suppression (branche non fusionnée)
git branch -D nom-branche
```

---

## 3. Workflow avec branches - Exemple pratique

### Scénario : Développer une nouvelle fonctionnalité

**1. Partir de la branche principale**
```bash
# S'assurer d'être sur master
git checkout master

# Mettre à jour (si nécessaire)
git pull origin master
```

**2. Créer une branche de fonctionnalité**
```bash
git checkout -b feature-login
```

**3. Développer la fonctionnalité**
```bash
# Créer des fichiers
echo "def login(username, password):" > login.py
echo "    # TODO: implement login" >> login.py

# Commiter les changements
git add login.py
git commit -m "Ajouter squelette fonction login"

# Continuer le développement
echo "    if username and password:" >> login.py
echo "        return True" >> login.py
echo "    return False" >> login.py

git add login.py
git commit -m "Implémenter logique de base du login"
```

**4. Pendant ce temps, master peut évoluer**
```bash
# Quelqu'un d'autre fait des commits sur master
git checkout master
echo "Version 1.1" > VERSION
git add VERSION
git commit -m "Bump version to 1.1"
```

**5. Visualiser l'état des branches**
```bash
git log --oneline --graph --all
```

---

## 4. Fusionner des branches (merge)

### Types de fusion

#### Fast-forward merge
Quand la branche de destination n'a pas évolué :

```
Avant:
master: A---B
             \
feature:      C---D

Après git merge:
master: A---B---C---D
```

#### Three-way merge
Quand les deux branches ont évolué :

```
Avant:
master:  A---B---E
              \
feature:       C---D

Après git merge:
master:  A---B---E---F
              \     /
feature:       C---D
```

### Effectuer une fusion

**1. Se positionner sur la branche de destination**
```bash
git checkout master
```

**2. Fusionner la branche**
```bash
git merge feature-login
```

**Sortie possible (fast-forward) :**
```
Updating a1b2c3d..e5f6g7h
Fast-forward
 login.py | 4 ++++
 1 file changed, 4 insertions(+)
 create mode 100644 login.py
```

**Sortie possible (three-way merge) :**
```
Merge made by the 'recursive' strategy.
 login.py | 4 ++++
 1 file changed, 4 insertions(+)
 create mode 100644 login.py
```

### Options de fusion
```bash
# Forcer un commit de merge (pas de fast-forward)
git merge --no-ff feature-login

# Fusion avec message personnalisé
git merge feature-login -m "Intégrer système de login"

# Simuler la fusion (dry-run)
git merge --no-commit --no-ff feature-login
```

---

## 5. Gestion des conflits

### Qu'est-ce qu'un conflit ?
Un **conflit** survient quand :
- Le même fichier a été modifié **sur les mêmes lignes**
- Dans les deux branches à fusionner
- Git ne peut pas décider automatiquement

### Exemple de conflit

**Fichier sur master :**
```python
def calculate(a, b):
    return a + b  # Addition simple
```

**Même fichier sur feature :**
```python
def calculate(a, b):
    return a * b  # Multiplication
```

### Résoudre un conflit

**1. Tentative de fusion**
```bash
git merge feature-math
```

**Sortie :**
```
Auto-merging calculate.py
CONFLICT (content): Merge conflict in calculate.py
Automatic merge failed; fix conflicts and then commit the result.
```

**2. Voir les fichiers en conflit**
```bash
git status
```

**Sortie :**
```
On branch master
You have unmerged paths.

Unmerged paths:
  (use "git add <file>..." to mark resolution)
	both modified:   calculate.py
```

**3. Contenu du fichier en conflit**
```python
def calculate(a, b):
<<<<<<< HEAD
    return a + b  # Addition simple
=======
    return a * b  # Multiplication
>>>>>>> feature-math
```

### Marqueurs de conflit
- `<<<<<<< HEAD` : début version branche courante
- `=======` : séparateur
- `>>>>>>> nom-branche` : fin version autre branche

**4. Résoudre manuellement**
```python
def calculate(a, b):
    # Décision : on garde la multiplication
    return a * b  # Multiplication
```

**5. Marquer comme résolu et finaliser**
```bash
# Ajouter le fichier résolu
git add calculate.py

# Vérifier l'état
git status

# Finaliser la fusion
git commit
```

Git ouvrira un éditeur avec un message de commit pré-rempli.

### Outils pour résoudre les conflits
```bash
# Utiliser un outil graphique
git mergetool

# Voir la différence en 3 voies
git diff

# Annuler la fusion en cours
git merge --abort
```

---

## 6. Stratégies de fusion avancées

### Rebase : alternative au merge

**Principe du rebase :**
```
Avant:
master:  A---B---E
              \
feature:       C---D

Après git rebase master:
master:  A---B---E
feature:          C'---D'
```

**Commandes :**
```bash
# Se positionner sur la branche à rebaser
git checkout feature-login

# Rebaser sur master
git rebase master

# Puis fusionner (fast-forward)
git checkout master
git merge feature-login
```

### Merge vs Rebase : quand utiliser quoi ?

| Merge | Rebase |
|-------|--------|
| Conserve l'historique réel | Linéarise l'historique |
| Crée des commits de merge | Pas de commits supplémentaires |
| Plus sûr pour débutants | Historique plus propre |
| Recommandé pour branches publiques | Jamais sur branches partagées |

### Squash merge
```bash
# Fusionner en écrasant les commits en un seul
git merge --squash feature-login
git commit -m "Ajouter système de login complet"
```

---

## 7. Workflows de branches courants

### Git Flow
```
master     ──●────●────●──   (releases)
            /      /      /
develop  ──●──●──●──●──●───   (intégration)
           │   ╱      ╱
features   │●─●    ●─●       (fonctionnalités)
           │       
hotfix   ──●─●               (corrections urgentes)
```

### GitHub Flow (plus simple)
```
master  ──●────●────●────●──
           ╲    ╱    ╱
features   ●──●    ●──●      
```

### Workflow d'équipe recommandé
1. **master/main** : code production
2. **develop** : intégration continue
3. **feature/*** : nouvelles fonctionnalités  
4. **hotfix/*** : corrections urgentes

---

## 8. Bonnes pratiques avec les branches

### Nommage des branches
```bash
# ✅ Bons noms
feature/user-authentication
bugfix/login-timeout
hotfix/security-patch
docs/api-documentation

# ❌ Mauvais noms
branch1
test
ma-branche
```

### Cycle de vie d'une branche
1. **Créer** depuis master/develop
2. **Développer** en commits atomiques
3. **Tester** la fonctionnalité
4. **Fusionner** vers la branche principale
5. **Supprimer** la branche

### Commits sur les branches
```bash
# Commits fréquents et descriptifs
git commit -m "Ajouter formulaire de connexion"
git commit -m "Valider format email"
git commit -m "Ajouter tests unitaires login"
```

### Avant de fusionner
```bash
# 1. Mettre à jour master
git checkout master
git pull origin master

# 2. Fusionner master dans feature (résoudre conflits)
git checkout feature-login
git merge master

# 3. Tester que tout fonctionne
# ... tests ...

# 4. Fusionner feature dans master
git checkout master
git merge feature-login
```

---

## 9. Visualisation et outils

### Visualiser l'arbre des branches
```bash
# Graphique simple
git log --oneline --graph

# Graphique détaillé
git log --oneline --graph --all --decorate

# Avec dates
git log --oneline --graph --all --since="1 week ago"
```

### Outils graphiques
```bash
# Outil intégré à Git
gitk --all

# Autres outils populaires
# - SourceTree (GUI)
# - GitKraken (commercial)
# - VS Code Git Graph (extension)
```

### Alias utiles
```bash
git config --global alias.tree "log --oneline --graph --all"
git config --global alias.branches "branch -a"
git config --global alias.unstage "reset HEAD --"

# Usage
git tree
git branches
```

---

## 10. Scénarios d'exercices pratiques

### Exercice 1 : Workflow complet
```bash
# 1. Créer un projet
git init mon-site-web
cd mon-site-web
echo "<h1>Mon Site</h1>" > index.html
git add index.html
git commit -m "Initial commit"

# 2. Créer une branche feature
git checkout -b feature-navbar

# 3. Développer la navbar
echo "<nav><a href='#'>Accueil</a></nav>" >> index.html
git add index.html
git commit -m "Ajouter navbar"

# 4. Retourner sur master et créer autre feature
git checkout master
git checkout -b feature-footer

# 5. Développer le footer
echo "<footer>Copyright 2023</footer>" >> index.html
git add index.html
git commit -m "Ajouter footer"

# 6. Fusionner navbar
git checkout master
git merge feature-navbar

# 7. Fusionner footer (conflit attendu !)
git merge feature-footer
# Résoudre le conflit manuellement
```

### Exercice 2 : Résolution de conflit
**Objectif :** Créer volontairement un conflit et le résoudre.

---

## Points clés à retenir

1. **Branches = lignes de développement** parallèles
2. **git branch** : gérer les branches
3. **git checkout/switch** : basculer entre branches
4. **git merge** : fusionner des branches
5. **Conflits** : résoudre manuellement quand Git ne peut pas
6. **Fast-forward vs Three-way merge**
7. **Workflow** : créer → développer → tester → fusionner → supprimer

---

## Commandes essentielles - Aide-mémoire

```bash
# Gestion des branches
git branch                    # lister
git branch nom               # créer
git checkout -b nom          # créer et basculer
git checkout nom             # basculer
git branch -d nom            # supprimer

# Fusion
git merge branche            # fusionner
git merge --no-ff branche    # forcer commit merge
git merge --abort            # annuler fusion

# Visualisation
git log --oneline --graph --all
git branch -a
git status
```

---

## Pour la suite

Au chapitre suivant, nous découvrirons le **travail collaboratif** avec les dépôts distants (remote), les commandes `push`, `pull`, `fetch`, et les plateformes comme GitHub/GitLab.