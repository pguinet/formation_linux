# Module Git - Chapitre 4 : Travail collaboratif et remotes

## Objectifs du chapitre
À l'issue de ce chapitre, vous serez capable de :
- Comprendre le concept de dépôt distant (remote)
- Cloner un dépôt existant
- Synchroniser avec des dépôts distants (push, pull, fetch)
- Collaborer efficacement avec d'autres développeurs
- Utiliser GitHub/GitLab pour héberger des projets
- Gérer les conflits dans un contexte collaboratif
- Contribuer à des projets open source (fork, pull request)

---

## 1. Concept de dépôt distant (remote)

### Architecture distribuée de Git
```
Développeur A          Serveur central         Développeur B
+-------------+       +-------------+        +-------------+
| Dépôt local |<------+ Dépôt distant+------>| Dépôt local |
+-------------+       +-------------+        +-------------+
      ^                                             ^
      |                                             |
      v                                             v
+-------------+                               +-------------+
|Zone de      |                               |Zone de      |
|travail      |                               |travail      |
+-------------+                               +-------------+
```

### Qu'est-ce qu'un remote ?
Un **remote** est un dépôt Git hébergé ailleurs :
- Sur un serveur (GitHub, GitLab, Bitbucket)
- Sur un autre ordinateur du réseau
- Sur le même ordinateur (autre dossier)

### Pourquoi utiliser des remotes ?
- **Sauvegarde** centralisée du code
- **Collaboration** entre développeurs
- **Synchronisation** entre machines
- **Partage** public de projets
- **Intégration continue** et déploiement

---

## 2. Cloner un dépôt existant

### La commande git clone
```bash
# Cloner un dépôt depuis GitHub
git clone https://github.com/utilisateur/projet.git

# Cloner dans un dossier spécifique
git clone https://github.com/utilisateur/projet.git mon-dossier

# Cloner seulement la branche principale
git clone --single-branch https://github.com/utilisateur/projet.git

# Cloner avec un historique limité
git clone --depth 1 https://github.com/utilisateur/projet.git
```

### Que fait git clone ?
1. Crée un nouveau dossier
2. Initialise un dépôt Git local
3. Ajoute le dépôt source comme remote "origin"
4. Télécharge tout l'historique
5. Crée une branche locale trackant origin/master

### Vérifier les remotes
```bash
cd projet
git remote
# Sortie : origin

git remote -v
# Sortie :
# origin  https://github.com/utilisateur/projet.git (fetch)
# origin  https://github.com/utilisateur/projet.git (push)
```

---

## 3. Synchronisation avec les remotes

### Les trois commandes essentielles

#### git fetch : récupérer sans fusionner
```bash
# Récupérer toutes les nouveautés du remote
git fetch origin

# Récupérer une branche spécifique
git fetch origin master

# Voir ce qui a été récupéré
git log HEAD..origin/master --oneline
```

**git fetch** :
- Télécharge les nouveaux commits
- Met à jour les branches remote
- **Ne modifie pas** votre zone de travail

#### git pull : récupérer et fusionner
```bash
# Récupérer et fusionner master
git pull origin master

# Équivaut à :
git fetch origin master
git merge origin/master

# Pull avec rebase (historique plus propre)
git pull --rebase origin master
```

#### git push : envoyer ses commits
```bash
# Pousser la branche courante
git push origin master

# Pousser une nouvelle branche
git push -u origin nouvelle-branche
# Le -u (--set-upstream) lie la branche locale à la distante

# Pousser toutes les branches
git push --all origin

# Pousser les tags
git push --tags origin
```

### États des branches
```bash
# Voir l'état de synchronisation
git status
# Sortie possible :
# Your branch is ahead of 'origin/master' by 2 commits.

git log --oneline --graph origin/master..HEAD
# Voir les commits locaux pas encore poussés
```

---

## 4. Workflow collaboratif typique

### Scénario : Contribuer à un projet d'équipe

**1. Cloner le projet**
```bash
git clone https://github.com/entreprise/projet.git
cd projet
```

**2. Créer une branche de travail**
```bash
git checkout -b feature-nouvelle-fonctionnalite
```

**3. Développer la fonctionnalité**
```bash
# Modifier des fichiers
echo "nouvelle fonction" >> src/utils.py
git add src/utils.py
git commit -m "Ajouter fonction utilitaire"

# Plus de développement...
git add .
git commit -m "Ajouter tests pour nouvelle fonction"
```

**4. Synchroniser avec les dernières modifications**
```bash
# Récupérer les nouveautés
git fetch origin

# Vérifier s'il y a des changements sur master
git log HEAD..origin/master --oneline

# Si oui, mettre à jour sa branche
git checkout master
git pull origin master
git checkout feature-nouvelle-fonctionnalite
git merge master
# Ou : git rebase master
```

**5. Pousser sa branche**
```bash
git push -u origin feature-nouvelle-fonctionnalite
```

**6. Créer une Pull Request / Merge Request**
Sur GitHub/GitLab : proposer la fusion de sa branche

**7. Après acceptation, nettoyer**
```bash
git checkout master
git pull origin master
git branch -d feature-nouvelle-fonctionnalite
```

---

## 5. Gestion des conflits distants

### Conflit lors d'un push

**Scénario :** Votre collègue a poussé des modifications avant vous.

```bash
git push origin master
```

**Erreur :**
```
! [rejected]        master -> master (non-fast-forward)
error: failed to push some refs to 'origin'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
```

**Solution :**
```bash
# 1. Récupérer les modifications distantes
git pull origin master

# 2a. Si pas de conflit : fusion automatique
# Les commits sont maintenant fusionnés

# 2b. Si conflit : résoudre manuellement
# Éditer les fichiers en conflit
git add fichier-resolu.txt
git commit

# 3. Pousser le résultat
git push origin master
```

### Éviter les commits de merge
```bash
# Utiliser rebase pour un historique linéaire
git pull --rebase origin master

# Si conflit pendant le rebase
# 1. Résoudre le conflit
# 2. Ajouter les fichiers résolus
git add .
# 3. Continuer le rebase
git rebase --continue

# Ou abandonner le rebase
git rebase --abort
```

---

## 6. Plateformes de collaboration

### GitHub : concepts de base

#### Repository (Dépôt)
- Héberge votre projet Git
- Interface web pour navigation
- Outils de collaboration intégrés

#### Fork
- Copie personnelle d'un projet
- Permet de proposer des modifications
- Base du développement open source

#### Pull Request (PR)
- Proposition de modification
- Discussion et review de code
- Tests automatiques (CI/CD)

#### Issues
- Système de tickets/bugs
- Discussion autour des fonctionnalités
- Gestion de projet

### Workflow GitHub

**1. Fork du projet**
```
Projet original → Clic "Fork" → Votre fork
```

**2. Cloner votre fork**
```bash
git clone https://github.com/votre-nom/projet.git
```

**3. Ajouter le dépôt original comme upstream**
```bash
git remote add upstream https://github.com/proprietaire-original/projet.git
git remote -v
# origin    https://github.com/votre-nom/projet.git (fetch)
# origin    https://github.com/votre-nom/projet.git (push)
# upstream  https://github.com/proprietaire-original/projet.git (fetch)
# upstream  https://github.com/proprietaire-original/projet.git (push)
```

**4. Créer une branche pour votre contribution**
```bash
git checkout -b fix-bug-authentification
```

**5. Développer et pousser**
```bash
# Développement...
git push origin fix-bug-authentification
```

**6. Créer la Pull Request**
- Aller sur GitHub
- Cliquer "New Pull Request"
- Sélectionner les branches
- Décrire les modifications

**7. Maintenir la PR à jour**
```bash
# Récupérer les nouveautés du projet original
git fetch upstream
git checkout master
git merge upstream/master
git push origin master

# Mettre à jour sa branche
git checkout fix-bug-authentification
git merge master
git push origin fix-bug-authentification
```

---

## 7. Bonnes pratiques collaboratives

### Messages de commit
```bash
# Format conventionnel
git commit -m "feat: ajouter système d'authentification"
git commit -m "fix: corriger bug de validation email"
git commit -m "docs: mettre à jour README avec nouvelles instructions"

# Types courants :
# feat: nouvelle fonctionnalité
# fix: correction de bug
# docs: documentation
# style: formatage, points-virgules manquants
# refactor: refactorisation du code
# test: ajouter des tests
# chore: maintenance, mise à jour dépendances
```

### Branches
```bash
# Nommage descriptif
feature/user-registration
bugfix/login-timeout
hotfix/security-vulnerability
docs/api-documentation

# Préfixes d'équipe
alice/feature-search
bob/refactor-database
```

### Pull Requests efficaces
1. **Titre clair** et descriptif
2. **Description détaillée** du problème résolu
3. **Tests** inclus si nécessaire
4. **Captures d'écran** pour l'UI
5. **Référencer les issues** (#123)
6. **Garder les PR petites** (< 400 lignes)

### Code Review
```bash
# Récupérer une PR localement pour tester
git fetch origin pull/123/head:pr-123
git checkout pr-123
# Tester les modifications...
```

---

## 8. Gestion des remotes multiples

### Ajouter des remotes additionnels
```bash
# Ajouter un remote
git remote add backup https://gitlab.com/user/projet.git

# Lister les remotes
git remote -v

# Pousser vers un remote spécifique
git push backup master

# Récupérer depuis un remote spécifique
git fetch backup
```

### Changer l'URL d'un remote
```bash
# HTTPS vers SSH
git remote set-url origin git@github.com:user/repo.git

# Vérifier le changement
git remote -v
```

### Supprimer un remote
```bash
git remote remove backup
```

---

## 9. Authentification et sécurité

### Authentification HTTPS avec tokens
Depuis 2021, GitHub exige des tokens personnels :

1. Générer un token sur GitHub : Settings > Developer settings > Personal access tokens
2. Utiliser le token comme mot de passe :
```bash
git clone https://github.com/user/repo.git
# Username: votre-nom-utilisateur
# Password: ghp_votre_token_personnel
```

### Authentification SSH (recommandée)
**1. Générer une clé SSH**
```bash
ssh-keygen -t ed25519 -C "votre.email@exemple.com"
```

**2. Ajouter la clé à l'agent SSH**
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**3. Copier la clé publique**
```bash
cat ~/.ssh/id_ed25519.pub
```

**4. Ajouter sur GitHub**
Settings > SSH and GPG keys > New SSH key

**5. Utiliser l'URL SSH**
```bash
git clone git@github.com:user/repo.git

# Ou changer un remote existant
git remote set-url origin git@github.com:user/repo.git
```

---

## 10. Exercices pratiques avancés

### Exercice 1 : Workflow complet GitHub

**Objectif :** Simuler une contribution open source

```bash
# 1. Fork un projet sur GitHub (par l'interface web)

# 2. Cloner votre fork
git clone https://github.com/VOTRE-NOM/projet-exemple.git
cd projet-exemple

# 3. Configurer upstream
git remote add upstream https://github.com/PROPRIETAIRE/projet-exemple.git

# 4. Créer une branche
git checkout -b amelioration-readme

# 5. Faire des modifications
echo "## Installation\n\n\`\`\`bash\nnpm install\n\`\`\`" >> README.md
git add README.md
git commit -m "docs: améliorer section installation"

# 6. Pousser vers votre fork
git push origin amelioration-readme

# 7. Créer une PR sur GitHub
```

### Exercice 2 : Résolution de conflit collaboratif

**Scénario :** Deux développeurs modifient le même fichier

```bash
# Développeur 1
echo "Version 1" > fichier.txt
git add fichier.txt
git commit -m "Version 1"
git push origin master

# Développeur 2 (en parallèle, sans pull)
echo "Version 2" > fichier.txt
git add fichier.txt
git commit -m "Version 2"
git push origin master  # ← ÉCHEC

# Résolution
git pull origin master  # ← CONFLIT
# Résoudre manuellement...
git add fichier.txt
git commit -m "Résoudre conflit versions"
git push origin master
```

---

## 11. Outils et configurations utiles

### Configuration Git pour la collaboration
```bash
# Configurer pull pour faire rebase par défaut
git config --global pull.rebase true

# Couleurs dans le terminal
git config --global color.ui auto

# Éditeur par défaut
git config --global core.editor "code --wait"  # VS Code
git config --global core.editor "nano"         # Nano

# Aliases pour la collaboration
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
git config --global alias.pushup 'push -u origin HEAD'
```

### Fichier .gitconfig type
```ini
[user]
    name = Votre Nom
    email = votre.email@exemple.com

[core]
    editor = nano
    autocrlf = input

[push]
    default = simple

[pull]
    rebase = true

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    tree = log --oneline --graph --all
```

---

## Points clés à retenir

1. **Remote** : dépôt distant pour collaboration
2. **git clone** : copier un dépôt distant
3. **git fetch** : récupérer sans fusionner
4. **git pull** : récupérer et fusionner
5. **git push** : envoyer ses commits
6. **Fork + PR** : workflow open source
7. **Upstream** : dépôt original d'un fork
8. **Authentification** : SSH recommandée

---

## Commandes essentielles - Aide-mémoire

```bash
# Clone et remotes
git clone <url>
git remote -v
git remote add upstream <url>

# Synchronisation
git fetch origin
git pull origin master
git push origin master
git push -u origin branche

# Workflow GitHub
git checkout -b feature-branch
git push origin feature-branch
# → Créer PR sur GitHub

# Mise à jour fork
git fetch upstream
git checkout master
git merge upstream/master
git push origin master
```

---

## Ressources supplémentaires

- [GitHub Guides](https://guides.github.com/)
- [GitLab Documentation](https://docs.gitlab.com/)
- [Git Book - Distributed Git](https://git-scm.com/book/en/v2/Distributed-Git-Distributed-Workflows)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [SSH Key Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

## Conclusion du module Git

Félicitations ! Vous maîtrisez maintenant :
- Les **concepts fondamentaux** de Git
- Le **workflow local** (add, commit, branches)
- La **collaboration** avec les remotes
- Les **bonnes pratiques** professionnelles

**Prochaines étapes suggérées :**
- Pratiquer sur vos propres projets
- Contribuer à des projets open source
- Explorer les workflows avancés (Git Flow, GitHub Actions)
- Approfondir la résolution de conflits complexes