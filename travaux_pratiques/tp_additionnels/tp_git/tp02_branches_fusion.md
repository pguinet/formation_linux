# TP Git 2 : Branches et fusion

## Objectifs
- Créer et gérer des branches
- Basculer entre les branches
- Fusionner des branches (merge)
- Résoudre des conflits de fusion
- Comprendre les différents types de merge
- Appliquer un workflow de développement avec branches

## Prérequis
- Avoir terminé le TP1 (premiers pas avec Git)
- Maîtriser les commandes de base (add, commit, status, log)

---

## Partie 1 : Création et gestion des branches

### Exercice 1.1 : Explorer les branches existantes
```bash
# Créer un nouveau projet pour ce TP
mkdir tp-branches
cd tp-branches
git init

# Créer un fichier initial
echo "# Projet TP Branches" > README.md
git add README.md
git commit -m "Initial commit"

# Voir les branches
git branch
git branch --show-current
```

**Questions :**
1. Combien de branches voyez-vous ?
2. Comment Git indique-t-il la branche active ?

### Exercice 1.2 : Créer votre première branche
```bash
# Créer une branche sans basculer dessus
git branch feature-header

# Voir toutes les branches
git branch

# Créer et basculer sur une nouvelle branche
git checkout -b feature-footer

# Vérifier sur quelle branche vous êtes
git branch
```

**Questions :**
1. Quelle est la différence entre `git branch nom` et `git checkout -b nom` ?
2. Quel symbole indique la branche active ?

### Exercice 1.3 : Naviguer entre les branches
```bash
# Basculer sur master
git checkout master

# Basculer sur feature-header
git checkout feature-header

# Revenir à la branche précédente
git checkout -

# Utiliser la nouvelle syntaxe (Git 2.23+)
git switch master
git switch feature-footer
```

**Question :** Qu'observe-t-on dans le dossier de travail quand on change de branche ?

---

## Partie 2 : Développement sur des branches

### Exercice 2.1 : Développer sur feature-header
```bash
# S'assurer d'être sur la bonne branche
git switch feature-header

# Créer un header
echo "<header>
<h1>Mon Site Web</h1>
<nav>
  <a href='#'>Accueil</a>
  <a href='#'>À propos</a>
  <a href='#'>Contact</a>
</nav>
</header>" > header.html

# Commiter
git add header.html
git commit -m "Ajouter header avec navigation"

# Améliorer le header
echo "
<style>
header { background-color: #333; color: white; padding: 1rem; }
nav a { color: white; margin-right: 1rem; text-decoration: none; }
</style>" >> header.html

git add header.html
git commit -m "Ajouter styles pour le header"
```

### Exercice 2.2 : Développer sur feature-footer
```bash
# Basculer sur la branche footer
git switch feature-footer

# Créer un footer
echo "<footer>
<p>&copy; 2023 Mon Site Web. Tous droits réservés.</p>
<div>
  <a href='#'>Mentions légales</a> |
  <a href='#'>Politique de confidentialité</a>
</div>
</footer>" > footer.html

git add footer.html
git commit -m "Ajouter footer de base"

# Ajouter des styles
echo "
<style>
footer { 
  background-color: #f8f9fa; 
  padding: 2rem; 
  text-align: center; 
  border-top: 1px solid #ddd; 
}
footer a { color: #007bff; text-decoration: none; }
</style>" >> footer.html

git add footer.html
git commit -m "Styliser le footer"
```

### Exercice 2.3 : Visualiser l'historique des branches
```bash
# Voir l'historique de toutes les branches
git log --oneline --graph --all

# Voir seulement la branche courante
git log --oneline

# Comparer les branches
git log --oneline master..feature-header
git log --oneline master..feature-footer
```

**Questions :**
1. Comment l'historique diffère-t-il entre les branches ?
2. Que montrent les commandes de comparaison ?

---

## Partie 3 : Fusion simple (Fast-forward)

### Exercice 3.1 : Fusionner feature-header dans master
```bash
# Basculer sur master
git switch master

# Regarder le contenu avant fusion
ls -la
git log --oneline

# Fusionner feature-header
git merge feature-header

# Vérifier le résultat
ls -la
git log --oneline --graph

# Voir le type de fusion effectué
git log --oneline -n 3
```

**Questions :**
1. Quel type de fusion a été effectué (fast-forward ou three-way merge) ?
2. Pourquoi ce type de fusion a-t-il été possible ?

### Exercice 3.2 : Nettoyer après fusion
```bash
# Supprimer la branche fusionnée
git branch -d feature-header

# Vérifier les branches restantes
git branch
```

**Question :** Pourquoi peut-on supprimer sans risque une branche fusionnée ?

---

## Partie 4 : Fusion avec commit de merge

### Exercice 4.1 : Préparer une situation de three-way merge
```bash
# Pendant que feature-footer existait, faire évoluer master
echo "# Projet TP Branches

Ce projet démontre l'utilisation des branches Git.

## Fonctionnalités
- Header avec navigation
- Footer (en développement)" > README.md

git add README.md
git commit -m "Améliorer documentation du projet"

# Ajouter un fichier principal
echo "<!DOCTYPE html>
<html>
<head>
    <title>Mon Site Web</title>
</head>
<body>
    <main>
        <h2>Bienvenue !</h2>
        <p>Contenu principal du site.</p>
    </main>
</body>
</html>" > index.html

git add index.html
git commit -m "Ajouter page principale"

# Visualiser la divergence
git log --oneline --graph --all
```

### Exercice 4.2 : Effectuer un three-way merge
```bash
# Fusionner feature-footer
git merge feature-footer

# Examiner le commit de merge créé
git log --oneline --graph -n 5

# Voir les détails du commit de merge
git show HEAD
```

**Questions :**
1. Pourquoi un commit de merge a-t-il été créé cette fois ?
2. Combien de parents a le commit de merge ?

---

## Partie 5 : Gestion des conflits

### Exercice 5.1 : Créer volontairement un conflit
```bash
# Créer deux branches qui modifieront le même fichier
git checkout -b branch-a
git checkout -b branch-b

# Sur branch-b : modifier le README
echo "# Projet TP Branches - Version B

Ce projet est un exemple avancé de Git.

## Fonctionnalités principales
- Interface utilisateur moderne
- Footer informatif" > README.md

git add README.md
git commit -m "Version B: mise à jour description"

# Basculer sur branch-a
git switch branch-a

# Sur branch-a : modifier différemment le README
echo "# Projet TP Branches - Version A

Ce projet illustre les branches et fusions Git.

## Composants
- Header stylisé
- Contenu principal
- Footer complet" > README.md

git add README.md
git commit -m "Version A: restructurer description"

# Fusionner branch-a dans master
git switch master
git merge branch-a

# Tenter de fusionner branch-b (conflit attendu)
git merge branch-b
```

### Exercice 5.2 : Résoudre le conflit
```bash
# Voir l'état du conflit
git status

# Examiner le fichier en conflit
cat README.md
```

**Le fichier devrait contenir quelque chose comme :**
```
# Projet TP Branches - Version A
<<<<<<< HEAD
Ce projet illustre les branches et fusions Git.

## Composants
- Header stylisé
- Contenu principal
- Footer complet
=======
Ce projet est un exemple avancé de Git.

## Fonctionnalités principales
- Interface utilisateur moderne
- Footer informatif
>>>>>>> branch-b
```

**Résoudre le conflit :**
```bash
# Éditer le fichier pour résoudre le conflit
nano README.md
```

**Contenu résolu suggéré :**
```
# Projet TP Branches

Ce projet illustre les branches et fusions Git avec des exemples pratiques.

## Fonctionnalités
- Header stylisé avec navigation
- Interface utilisateur moderne  
- Contenu principal
- Footer informatif et complet
```

```bash
# Marquer le conflit comme résolu
git add README.md

# Vérifier l'état
git status

# Finaliser la fusion
git commit

# Git ouvrira un éditeur avec un message pré-rempli
# Vous pouvez modifier ou garder le message par défaut
```

### Exercice 5.3 : Vérifier la résolution
```bash
# Voir le résultat final
git log --oneline --graph -n 7

# Examiner le commit de merge
git show HEAD

# Nettoyer les branches
git branch -d branch-a branch-b feature-footer
```

**Question :** Comment peut-on annuler une fusion en cours si on ne veut pas résoudre le conflit maintenant ?

---

## Partie 6 : Stratégies de fusion avancées

### Exercice 6.1 : Merge avec --no-ff
```bash
# Créer une branche pour tester le --no-ff
git checkout -b feature-contact

# Ajouter une page de contact
echo "<!DOCTYPE html>
<html>
<head>
    <title>Contact - Mon Site Web</title>
</head>
<body>
    <h1>Nous contacter</h1>
    <form>
        <label>Nom: <input type='text' name='nom'></label><br>
        <label>Email: <input type='email' name='email'></label><br>
        <label>Message: <textarea name='message'></textarea></label><br>
        <button type='submit'>Envoyer</button>
    </form>
</body>
</html>" > contact.html

git add contact.html
git commit -m "Ajouter page de contact"

# Fusionner avec --no-ff pour forcer un commit de merge
git switch master
git merge --no-ff feature-contact -m "Intégrer page de contact"

# Comparer avec l'historique
git log --oneline --graph -n 5
```

**Question :** Quelle est la différence visuelle dans l'historique avec --no-ff ?

### Exercice 6.2 : Squash merge
```bash
# Créer une branche avec plusieurs petits commits
git checkout -b feature-improvements

# Premier petit commit
echo "/* Base styles */" > styles.css
git add styles.css
git commit -m "Ajouter fichier CSS de base"

# Deuxième petit commit  
echo "body { font-family: Arial, sans-serif; }" >> styles.css
git add styles.css
git commit -m "Définir police par défaut"

# Troisième petit commit
echo "h1 { color: #333; }" >> styles.css
git add styles.css
git commit -m "Styliser les titres h1"

# Voir l'historique de la branche
git log --oneline -n 4

# Fusionner en squashant tous les commits en un seul
git switch master
git merge --squash feature-improvements
git commit -m "Ajouter styles CSS complets pour le site"

# Comparer les historiques
git log --oneline -n 3
git branch -d feature-improvements
```

**Question :** Quand est-il préférable d'utiliser squash merge ?

---

## Partie 7 : Workflow pratique

### Exercice 7.1 : Simuler un workflow d'équipe
**Scénario :** Vous travaillez sur un projet avec des collègues. Vous devez ajouter une fonctionnalité pendant qu'un collègue travaille sur autre chose.

```bash
# Étape 1: Partir d'une base propre
git switch master

# Étape 2: Créer votre branche de fonctionnalité
git checkout -b feature/user-profile

# Étape 3: Développer votre fonctionnalité
echo "<!DOCTYPE html>
<html>
<head>
    <title>Profil Utilisateur</title>
</head>
<body>
    <h1>Mon Profil</h1>
    <div class='profile'>
        <img src='avatar.png' alt='Avatar'>
        <h2>Nom d'utilisateur</h2>
        <p>Membre depuis: 2023</p>
    </div>
</body>
</html>" > profile.html

git add profile.html
git commit -m "Ajouter page de profil utilisateur"

# Styles pour le profil
echo "
.profile { 
    max-width: 600px; 
    margin: 0 auto; 
    padding: 2rem; 
    text-align: center; 
}
.profile img { 
    border-radius: 50%; 
    width: 150px; 
    height: 150px; 
}" >> styles.css

git add styles.css
git commit -m "Ajouter styles pour la page de profil"
```

### Exercice 7.2 : Simuler le travail d'un collègue
```bash
# Pendant ce temps, votre collègue travaille sur master
git switch master

# Le collègue ajoute une fonctionnalité
echo "
// Navigation mobile
function toggleMobileMenu() {
    const nav = document.querySelector('nav');
    nav.classList.toggle('mobile-open');
}" > mobile.js

git add mobile.js
git commit -m "Ajouter navigation mobile"

# Il met aussi à jour le README
echo "
## Structure du projet
- index.html : page principale
- header.html : en-tête du site
- footer.html : pied de page
- contact.html : page de contact
- styles.css : feuilles de style
- mobile.js : fonctionnalités mobiles" >> README.md

git add README.md
git commit -m "Documenter la structure du projet"
```

### Exercice 7.3 : Intégrer votre travail
```bash
# Voir l'état des branches
git log --oneline --graph --all -n 10

# Fusionner votre travail
git merge feature/user-profile

# Vérifier le résultat
git log --oneline --graph -n 8
git branch -d feature/user-profile
```

---

## Partie 8 : Exercices avancés

### Défi 1 : Résolution de conflit complexe
Créez une situation où le même fichier est modifié sur plusieurs lignes différentes par deux branches, puis résolvez le conflit en gardant les modifications des deux branches.

### Défi 2 : Workflow Gitflow simplifié
Implémentez un workflow avec :
- Une branche `develop` pour l'intégration
- Des branches `feature/*` pour les nouvelles fonctionnalités
- Une branche `hotfix/*` pour les corrections urgentes sur master

### Défi 3 : Historique propre
Créez un projet avec plusieurs branches et utilisez différentes stratégies de fusion pour maintenir un historique lisible et logique.

---

## Solutions et vérifications

### Solution Exercice 5.2 - Annuler une fusion en cours
```bash
# Si en cours de résolution de conflit
git merge --abort

# Retourne à l'état avant la tentative de fusion
```

### Vérification finale
À la fin de ce TP, votre projet devrait avoir :
```bash
# Structure de fichiers
ls -la
# README.md  contact.html  footer.html  header.html  index.html  mobile.js  profile.html  styles.css

# Historique avec différents types de merges
git log --oneline --graph
```

---

## Points d'évaluation

**Compétences acquises :**
- ✅ Créer et gérer des branches
- ✅ Naviguer entre les branches
- ✅ Comprendre les différents types de merge
- ✅ Résoudre des conflits de fusion
- ✅ Appliquer des stratégies de fusion appropriées
- ✅ Maintenir un historique propre et lisible

**Questions de révision :**
1. Quand utilise-t-on `--no-ff` lors d'un merge ?
2. Quelle est la différence entre `git branch -d` et `git branch -D` ?
3. Comment voir quelles branches ont été fusionnées dans master ?
4. Que se passe-t-il si on essaie de supprimer une branche non fusionnée ?

---

## Prochaines étapes

Pour le prochain TP sur la collaboration :
- Familiarisez-vous avec les concepts de remote et origin
- Créez un compte sur GitHub ou GitLab
- Explorez les commandes `git remote`, `git fetch`, `git push`, `git pull`