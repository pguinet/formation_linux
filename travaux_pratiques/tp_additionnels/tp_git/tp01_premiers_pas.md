# TP Git 1 : Premiers pas avec Git

## Objectifs
- Installer et configurer Git
- Créer un premier dépôt local
- Maîtriser les commandes de base (add, commit, status, log)
- Comprendre le cycle de vie des fichiers dans Git

## Prérequis
- Avoir accès à un terminal Linux
- Avoir suivi le chapitre 1 du module Git

---

## Partie 1 : Installation et configuration

### Exercice 1.1 : Vérifier l'installation
```bash
# Vérifier que Git est installé
git --version
```

**Question :** Quelle version de Git avez-vous ?

### Exercice 1.2 : Configuration initiale
```bash
# Configurer votre identité
git config --global user.name "Votre Prénom Nom"
git config --global user.email "votre.email@exemple.com"

# Configurer l'éditeur
git config --global core.editor nano

# Vérifier la configuration
git config --list | grep -E "(user|core)"
```

**Question :** Pourquoi est-il important de configurer son nom et son email ?

---

## Partie 2 : Premier dépôt Git

### Exercice 2.1 : Créer un projet
```bash
# Créer un dossier pour le projet
mkdir mon-premier-repo
cd mon-premier-repo

# Initialiser Git
git init
```

**Questions :**
1. Que s'est-il passé après `git init` ?
2. Listez le contenu du dossier avec `ls -la`. Que voyez-vous ?

### Exercice 2.2 : Premier fichier et premier commit
```bash
# Créer un fichier README
echo "# Mon Premier Dépôt Git" > README.md

# Vérifier l'état du dépôt
git status
```

**Questions :**
1. Dans quel état est le fichier README.md ?
2. Que signifie "Untracked files" ?

```bash
# Ajouter le fichier à l'index
git add README.md

# Vérifier l'état
git status
```

**Question :** Comment l'état a-t-il changé après `git add` ?

```bash
# Effectuer le premier commit
git commit -m "Initial commit: ajouter README"

# Vérifier l'état
git status
```

**Question :** Que signifie "nothing to commit, working tree clean" ?

---

## Partie 3 : Cycle de vie des fichiers

### Exercice 3.1 : Ajouter plus de contenu
```bash
# Créer plusieurs fichiers
echo "print('Bonjour le monde!')" > hello.py
mkdir docs
echo "# Documentation" > docs/guide.md
echo "temp.log" > .gitignore

# Vérifier l'état
git status
```

**Questions :**
1. Combien de fichiers non trackés voyez-vous ?
2. Pourquoi est-il utile d'avoir un fichier .gitignore ?

### Exercice 3.2 : Ajouter fichiers par fichier vs en masse
```bash
# Ajouter un fichier spécifique
git add hello.py

# Vérifier l'état
git status

# Ajouter le reste
git add docs/ .gitignore

# Vérifier l'état
git status

# Commiter
git commit -m "Ajouter script Python, documentation et gitignore"
```

**Question :** Quelle est la différence entre `git add fichier.txt` et `git add .` ?

### Exercice 3.3 : Modifier des fichiers existants
```bash
# Modifier le README
echo "
Ce projet sert à apprendre Git.

## Contenu
- hello.py : script Python simple
- docs/ : documentation" >> README.md

# Vérifier l'état
git status
```

**Questions :**
1. Dans quel état est maintenant README.md ?
2. Quelle est la différence entre "modified" et "new file" ?

```bash
# Voir les modifications
git diff README.md

# Ajouter et commiter
git add README.md
git commit -m "Améliorer description du projet"
```

**Question :** À quoi sert la commande `git diff` ?

---

## Partie 4 : Consulter l'historique

### Exercice 4.1 : Explorer l'historique
```bash
# Voir l'historique complet
git log

# Voir l'historique condensé
git log --oneline

# Voir les statistiques des commits
git log --stat
```

**Questions :**
1. Combien de commits avez-vous effectués ?
2. Que représente le hash affiché par `git log --oneline` ?

### Exercice 4.2 : Examiner un commit spécifique
```bash
# Voir les détails du dernier commit
git show

# Voir un commit spécifique (remplacer xxxxx par les premiers caractères du hash)
git show xxxxx
```

**Question :** Que montre la commande `git show` ?

---

## Partie 5 : Exercices pratiques

### Exercice 5.1 : Simuler un projet simple
Créez un petit projet de calculatrice avec les fichiers suivants :

1. **calculator.py** - Script principal
```python
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

if __name__ == "__main__":
    print("Calculatrice simple")
    print("5 + 3 =", add(5, 3))
    print("5 - 3 =", subtract(5, 3))
```

2. **tests.py** - Tests simples
```python
from calculator import add, subtract

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    print("Tests addition: OK")

def test_subtract():
    assert subtract(5, 3) == 2
    assert subtract(0, 1) == -1
    print("Tests soustraction: OK")

if __name__ == "__main__":
    test_add()
    test_subtract()
    print("Tous les tests passent!")
```

3. **requirements.txt** - Dépendances (vide pour cet exercice)

**Consignes :**
- Créer chaque fichier individuellement
- Faire un commit après chaque fichier avec un message descriptif
- Modifier calculator.py pour ajouter la multiplication
- Modifier tests.py pour tester la multiplication
- Faire un commit pour ces modifications

### Exercice 5.2 : Gérer les erreurs
```bash
# Créer un fichier avec une erreur volontaire
echo "Fichier temporaire à supprimer" > temp.txt
git add temp.txt
```

Maintenant, vous réalisez que vous ne voulez PAS commiter ce fichier.

**Questions :**
1. Comment retirer le fichier de l'index (unstage) ?
2. Comment supprimer complètement le fichier ?

---

## Partie 6 : Défis supplémentaires

### Défi 1 : Messages de commit
Refaites l'exercice 5.1 en respectant ces règles pour les messages de commit :
- Commencer par un verbe à l'impératif
- Rester sous 50 caractères pour le titre
- Expliquer le "pourquoi" pas le "quoi"

### Défi 2 : Organisation des commits
Créez un projet "blog" avec cette structure :
```
blog/
├── articles/
│   ├── 2023-12-01-premier-article.md
│   └── 2023-12-02-deuxieme-article.md
├── templates/
│   ├── header.html
│   └── footer.html
├── style.css
└── index.html
```

**Consignes :**
- Organisez vos commits logiquement (par fonctionnalité, pas par fichier)
- Un commit pour la structure de base
- Un commit pour les templates
- Un commit pour les articles
- Un commit pour le style

---

## Solutions et corrections

### Solution Exercice 5.2
```bash
# Retirer de l'index
git reset HEAD temp.txt
# ou avec Git moderne :
git restore --staged temp.txt

# Supprimer le fichier
rm temp.txt
```

### Vérification finale
À la fin de ce TP, votre historique devrait ressembler à :
```bash
git log --oneline
# Exemple de sortie attendue :
# abc1234 Ajouter tests pour multiplication
# def5678 Implémenter fonction multiplication
# ghi9012 Ajouter tests simples
# jkl3456 Ajouter calculatrice de base
# mno7890 Améliorer description du projet
# pqr1234 Ajouter script Python, documentation et gitignore
# stu5678 Initial commit: ajouter README
```

---

## Points d'évaluation

**Compétences acquises :**
- ✅ Initialiser un dépôt Git
- ✅ Configurer Git correctement
- ✅ Comprendre les états des fichiers (untracked, modified, staged, committed)
- ✅ Utiliser add, commit, status, log efficacement
- ✅ Écrire des messages de commit clairs
- ✅ Naviguer dans l'historique des commits

**Questions de révision :**
1. Quelle est la différence entre `git add .` et `git add -A` ?
2. Comment modifier le message du dernier commit ?
3. Comment voir les modifications non indexées ?
4. Que se passe-t-il si on oublie de configurer user.name et user.email ?

---

## Pour aller plus loin

Avant le prochain TP, explorez :
- Les alias Git pour raccourcir les commandes
- La commande `git commit --amend`
- Les options de `git log` (--graph, --author, --since)
- La différence entre `git diff`, `git diff --cached` et `git diff HEAD`