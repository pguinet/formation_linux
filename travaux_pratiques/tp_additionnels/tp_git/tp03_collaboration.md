# TP Git 3 : Travail collaboratif avec les remotes

## Objectifs
- Comprendre les dépôts distants (remotes)
- Cloner des dépôts existants
- Synchroniser avec des dépôts distants (push, pull, fetch)
- Collaborer sur GitHub/GitLab
- Gérer les conflits en contexte collaboratif
- Contribuer à des projets open source (fork, pull request)

## Prérequis
- Avoir terminé les TP1 et TP2
- Avoir un compte GitHub ou GitLab
- Connaître les bases des branches et de la fusion

---

## Partie 1 : Configuration pour la collaboration

### Exercice 1.1 : Vérifier la configuration SSH

**Option A : Utiliser SSH (recommandé)**
```bash
# Vérifier si une clé SSH existe
ls -la ~/.ssh/

# Si pas de clé, en créer une
ssh-keygen -t ed25519 -C "votre.email@exemple.com"

# Ajouter la clé à l'agent SSH
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copier la clé publique
cat ~/.ssh/id_ed25519.pub
```

**Ajouter la clé sur GitHub :**
1. Aller sur GitHub.com → Settings → SSH and GPG keys
2. Cliquer "New SSH key"
3. Coller la clé publique
4. Tester la connexion : `ssh -T git@github.com`

**Option B : Utiliser HTTPS avec token**
```bash
# Configurer le cache des credentials
git config --global credential.helper cache

# Le token sera demandé lors du premier push
```

### Exercice 1.2 : Créer un dépôt sur GitHub
1. Aller sur GitHub.com
2. Cliquer "New repository"
3. Nom : `tp-collaboration-git`
4. Description : `TP sur la collaboration Git`
5. Public ou privé au choix
6. **NE PAS** initialiser avec README, .gitignore ou licence
7. Créer le dépôt

---

## Partie 2 : Premier push vers un remote

### Exercice 2.1 : Connecter un projet local à GitHub
```bash
# Créer un nouveau projet local
mkdir tp-collaboration-git
cd tp-collaboration-git
git init

# Créer du contenu initial
echo "# TP Collaboration Git

Ce projet illustre la collaboration avec Git et GitHub.

## Objectifs
- Apprendre git push, pull, fetch
- Collaborer avec d'autres développeurs
- Gérer les conflits distants" > README.md

git add README.md
git commit -m "Initial commit: ajouter README"

# Ajouter le remote (remplacer par votre URL GitHub)
git remote add origin git@github.com:VOTRE-NOM/tp-collaboration-git.git

# Vérifier les remotes
git remote -v
```

### Exercice 2.2 : Premier push
```bash
# Pousser vers GitHub
git push -u origin master

# Le -u lie la branche locale à la branche distante
# Vérifier sur GitHub que le projet est bien en ligne
```

**Questions :**
1. Que fait le flag `-u` dans `git push -u` ?
2. Que se passe-t-il si on essaie de pousser sans `-u` la première fois ?

### Exercice 2.3 : Ajouter du contenu et pousser
```bash
# Créer une structure de projet
mkdir src tests docs
echo "// Fichier principal de l'application" > src/main.js
echo "# Documentation technique" > docs/tech.md
echo "// Tests unitaires" > tests/main.test.js

git add .
git commit -m "Ajouter structure du projet"

# Pousser les nouveaux commits
git push

# Noter qu'on n'a plus besoin de spécifier origin master
```

---

## Partie 3 : Cloner et collaborer

### Exercice 3.1 : Simuler un deuxième développeur
```bash
# Dans un autre dossier, cloner le dépôt
cd ..
mkdir collaborateur
cd collaborateur

git clone git@github.com:VOTRE-NOM/tp-collaboration-git.git projet-clone
cd projet-clone

# Examiner ce qui a été cloné
git log --oneline
git remote -v
git branch -a
```

**Questions :**
1. Combien de branches locales voyez-vous après le clone ?
2. Que signifient les branches `origin/master` dans `git branch -a` ?

### Exercice 3.2 : Le collaborateur apporte des modifications
```bash
# Créer une nouvelle fonctionnalité
git checkout -b feature-authentication

# Développer la fonctionnalité
echo "function login(username, password) {
    // TODO: implémenter la logique de connexion
    console.log('Tentative de connexion:', username);
    return false;
}

function logout() {
    console.log('Déconnexion de l\\'utilisateur');
}

module.exports = { login, logout };" > src/auth.js

git add src/auth.js
git commit -m "Ajouter module d'authentification de base"

# Ajouter des tests
echo "const { login, logout } = require('../src/auth');

test('login should return false for invalid credentials', () => {
    const result = login('test', 'wrongpassword');
    expect(result).toBe(false);
});

test('logout should not throw error', () => {
    expect(() => logout()).not.toThrow();
});" > tests/auth.test.js

git add tests/auth.test.js
git commit -m "Ajouter tests pour le module auth"

# Pousser la branche
git push -u origin feature-authentication
```

---

## Partie 4 : Synchronisation et fetch vs pull

### Exercice 4.1 : Récupérer les modifications (développeur original)
```bash
# Retourner au projet original
cd ../../tp-collaboration-git

# Voir l'état actuel
git log --oneline
git branch -a

# Récupérer les informations du remote sans fusionner
git fetch origin

# Maintenant voir les branches
git branch -a
git log --oneline --graph --all
```

**Questions :**
1. Que fait `git fetch` exactement ?
2. Quelle est la différence entre les branches `master` et `origin/master` ?

### Exercice 4.2 : Examiner les modifications distantes
```bash
# Voir ce qui est nouveau sur origin/feature-authentication
git log origin/feature-authentication --oneline

# Voir les différences
git diff master origin/feature-authentication

# Créer une branche locale pour tester la feature
git checkout -b feature-authentication origin/feature-authentication

# Examiner les fichiers
ls src/
cat src/auth.js
```

### Exercice 4.3 : Fusionner la feature
```bash
# Retourner sur master
git checkout master

# Fusionner la feature branch
git merge feature-authentication

# Pousser le résultat
git push origin master

# Nettoyer
git branch -d feature-authentication
```

---

## Partie 5 : Gestion des conflits distants

### Exercice 5.1 : Créer une situation de conflit

**Développeur 1 (projet original) :**
```bash
# Modifier le README
echo "
## Installation

\`\`\`bash
npm install
npm test
\`\`\`

## Utilisation

Ce projet nécessite Node.js version 14 ou supérieure." >> README.md

git add README.md
git commit -m "Ajouter instructions d'installation"
git push origin master
```

**Développeur 2 (projet cloné) - EN PARALLÈLE :**
```bash
# Aller dans le projet cloné
cd ../collaborateur/projet-clone

# Modifier le README différemment (sans pull avant)
echo "
## Développement

\`\`\`bash
git clone <url>
cd projet
npm install
\`\`\`

## Technologies utilisées
- Node.js
- Jest pour les tests" >> README.md

git add README.md
git commit -m "Ajouter section développement"

# Tentative de push (échec attendu)
git push origin master
```

### Exercice 5.2 : Résoudre le conflit de push
```bash
# Erreur attendue : push rejected (non-fast-forward)
# Récupérer les modifications distantes
git pull origin master

# Conflit attendu dans README.md
git status
cat README.md
```

**Le fichier devrait contenir des marqueurs de conflit :**
```markdown
Ce projet illustre la collaboration avec Git et GitHub.

## Objectifs
- Apprendre git push, pull, fetch
- Collaborer avec d'autres développeurs
- Gérer les conflits distants
<<<<<<< HEAD

## Développement

```bash
git clone <url>
cd projet
npm install
```

## Technologies utilisées
- Node.js
- Jest pour les tests
=======

## Installation

```bash
npm install
npm test
```

## Utilisation

Ce projet nécessite Node.js version 14 ou supérieure.
>>>>>>> origin/master
```

**Résoudre le conflit :**
```bash
# Éditer le README pour combiner les deux versions
nano README.md
```

**Version résolue suggérée :**
```markdown
# TP Collaboration Git

Ce projet illustre la collaboration avec Git et GitHub.

## Objectifs
- Apprendre git push, pull, fetch
- Collaborer avec d'autres développeurs
- Gérer les conflits distants

## Installation

```bash
git clone <url>
cd projet
npm install
npm test
```

## Développement

Ce projet nécessite Node.js version 14 ou supérieure.

## Technologies utilisées
- Node.js
- Jest pour les tests
```

```bash
# Finaliser la résolution
git add README.md
git commit -m "Résoudre conflit README: combiner installation et développement"
git push origin master
```

---

## Partie 6 : Pull Requests / Merge Requests

### Exercice 6.1 : Créer une Pull Request sur GitHub

**Préparer une nouvelle fonctionnalité :**
```bash
# Créer une branche pour une nouvelle feature
git checkout -b feature-user-management

# Développer la fonctionnalité
echo "class UserManager {
    constructor() {
        this.users = new Map();
    }

    addUser(id, userData) {
        if (this.users.has(id)) {
            throw new Error('User already exists');
        }
        this.users.set(id, userData);
        return userData;
    }

    getUser(id) {
        return this.users.get(id);
    }

    deleteUser(id) {
        return this.users.delete(id);
    }

    getAllUsers() {
        return Array.from(this.users.values());
    }
}

module.exports = UserManager;" > src/user-manager.js

git add src/user-manager.js
git commit -m "Ajouter classe UserManager"

# Ajouter des tests
echo "const UserManager = require('../src/user-manager');

describe('UserManager', () => {
    let userManager;

    beforeEach(() => {
        userManager = new UserManager();
    });

    test('should add a new user', () => {
        const userData = { name: 'John', email: 'john@example.com' };
        const result = userManager.addUser('user1', userData);
        expect(result).toEqual(userData);
        expect(userManager.getUser('user1')).toEqual(userData);
    });

    test('should throw error when adding duplicate user', () => {
        const userData = { name: 'John', email: 'john@example.com' };
        userManager.addUser('user1', userData);
        expect(() => userManager.addUser('user1', userData)).toThrow('User already exists');
    });

    test('should delete user', () => {
        const userData = { name: 'John', email: 'john@example.com' };
        userManager.addUser('user1', userData);
        expect(userManager.deleteUser('user1')).toBe(true);
        expect(userManager.getUser('user1')).toBeUndefined();
    });
});" > tests/user-manager.test.js

git add tests/user-manager.test.js
git commit -m "Ajouter tests complets pour UserManager"

# Pousser la branche
git push -u origin feature-user-management
```

### Exercice 6.2 : Créer la Pull Request sur GitHub
1. Aller sur GitHub
2. Vous devriez voir "Compare & pull request" pour votre branche
3. Cliquer dessus
4. Rédiger une description détaillée :

```markdown
## Ajout du système de gestion d'utilisateurs

### Changements apportés
- Nouvelle classe `UserManager` pour gérer les utilisateurs
- Méthodes CRUD complètes (create, read, update, delete)
- Tests unitaires complets avec Jest
- Gestion des erreurs appropriée

### Tests
- ✅ Ajout d'utilisateurs
- ✅ Gestion des doublons
- ✅ Suppression d'utilisateurs
- ✅ Récupération des données

### Comment tester
```bash
npm test tests/user-manager.test.js
```

### Points d'attention
- La classe utilise une Map pour un accès rapide O(1)
- Gestion des erreurs explicite pour les cas d'edge
- Interface simple et intuitive
```

5. Créer la Pull Request

### Exercice 6.3 : Reviewer et fusionner
1. Examiner les fichiers changés sur GitHub
2. Ajouter des commentaires si nécessaire
3. Approuver la PR
4. Fusionner (Merge pull request)
5. Supprimer la branche sur GitHub

**Puis localement :**
```bash
# Retourner sur master et mettre à jour
git checkout master
git pull origin master

# Supprimer la branche locale
git branch -d feature-user-management
```

---

## Partie 7 : Contribuer à un projet open source

### Exercice 7.1 : Forker un projet
1. Trouver un projet simple sur GitHub (ou utiliser un projet de démo)
2. Cliquer "Fork" pour créer votre copie
3. Cloner votre fork :
```bash
cd ..
git clone git@github.com:VOTRE-NOM/projet-forke.git
cd projet-forke
```

### Exercice 7.2 : Configurer les remotes
```bash
# Ajouter le dépôt original comme upstream
git remote add upstream git@github.com:PROPRIETAIRE-ORIGINAL/projet-original.git

# Vérifier les remotes
git remote -v
# origin    : votre fork
# upstream  : projet original
```

### Exercice 7.3 : Contribuer une amélioration
```bash
# S'assurer d'être à jour avec upstream
git fetch upstream
git checkout master
git merge upstream/master

# Créer une branche pour votre contribution
git checkout -b fix-typo-readme

# Faire une petite amélioration (corriger une typo, améliorer la doc...)
# Éditer un fichier
nano README.md

git add README.md
git commit -m "docs: corriger typo dans README"

# Pousser vers votre fork
git push -u origin fix-typo-readme
```

### Exercice 7.4 : Créer une Pull Request vers upstream
1. Aller sur GitHub (votre fork)
2. Créer une PR vers le projet original
3. Suivre les guidelines du projet
4. Attendre review des mainteneurs

---

## Partie 8 : Workflows avancés

### Exercice 8.1 : Maintenir un fork à jour
```bash
# Récupérer les dernières modifications d'upstream
git fetch upstream

# Fusionner dans votre master local
git checkout master
git merge upstream/master

# Pousser vers votre fork
git push origin master

# Mettre à jour une branche de feature
git checkout ma-feature-branch
git merge master  # ou git rebase master
git push origin ma-feature-branch
```

### Exercice 8.2 : Utiliser git pull avec rebase
```bash
# Configurer pull pour faire rebase par défaut
git config --global pull.rebase true

# Ou pour un seul pull
git pull --rebase origin master
```

**Question :** Quelle est la différence entre `git pull` et `git pull --rebase` ?

---

## Partie 9 : Bonnes pratiques collaboratives

### Exercice 9.1 : Messages de commit conventionnels
Pratiquez avec ces formats :
```bash
git commit -m "feat: ajouter authentification OAuth"
git commit -m "fix: corriger validation email"
git commit -m "docs: mettre à jour README installation"
git commit -m "style: formater code selon ESLint"
git commit -m "refactor: extraire logique validation dans utils"
git commit -m "test: ajouter tests pour API users"
git commit -m "chore: mettre à jour dépendances"
```

### Exercice 9.2 : Créer un .gitignore efficace
```bash
echo "# Dependencies
node_modules/
npm-debug.log*

# Environment variables
.env
.env.local

# IDE
.vscode/
.idea/
*.swp

# Build outputs
dist/
build/

# OS generated files
.DS_Store
Thumbs.db

# Test coverage
coverage/

# Logs
*.log" > .gitignore

git add .gitignore
git commit -m "chore: ajouter .gitignore complet"
git push origin master
```

---

## Partie 10 : Exercices de récapitulation

### Défi 1 : Workflow complet
1. Forker un projet
2. Cloner votre fork
3. Créer une branche feature
4. Développer une fonctionnalité
5. Tester localement
6. Pousser vers votre fork
7. Créer une Pull Request
8. Gérer les reviews
9. Fusionner et nettoyer

### Défi 2 : Résolution de conflit complexe
Simulez une situation où :
- Deux développeurs modifient le même fichier
- Les modifications touchent des lignes qui se chevauchent
- Résolvez en gardant le meilleur des deux mondes

### Défi 3 : Maintenir plusieurs remotes
Configurez un projet avec :
- origin : votre fork
- upstream : projet original
- backup : serveur de backup
Maintenez tout synchronisé.

---

## Solutions et vérifications

### Vérification finale
```bash
# Votre projet devrait avoir :
git log --oneline --graph -n 10
git remote -v
git branch -a

# Structure finale attendue :
# src/
#   ├── main.js
#   ├── auth.js
#   └── user-manager.js
# tests/
#   ├── main.test.js
#   ├── auth.test.js
#   └── user-manager.test.js
# docs/
#   └── tech.md
# README.md
# .gitignore
```

---

## Points d'évaluation

**Compétences acquises :**
- ✅ Configurer et utiliser SSH/HTTPS pour GitHub
- ✅ Connecter un projet local à un remote
- ✅ Comprendre fetch vs pull vs push
- ✅ Résoudre des conflits distants
- ✅ Créer et gérer des Pull Requests
- ✅ Contribuer à des projets open source
- ✅ Maintenir des forks synchronisés
- ✅ Appliquer les bonnes pratiques collaboratives

**Questions de révision :**
1. Quelle est la différence entre `git fetch` et `git pull` ?
2. Comment récupérer une branche créée par un collaborateur ?
3. Que faire quand `git push` est rejeté ?
4. Comment maintenir un fork à jour avec le projet upstream ?
5. Quels sont les avantages d'utiliser SSH plutôt qu'HTTPS ?

---

## Ressources pour aller plus loin

- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [GitLab Flow](https://docs.gitlab.com/ee/topics/gitlab_flow.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Best Practices](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project)
- [Open Source Guide](https://opensource.guide/how-to-contribute/)

Félicitations ! Vous maîtrisez maintenant le travail collaboratif avec Git. Vous êtes prêt à contribuer à des projets d'équipe et open source professionnels.