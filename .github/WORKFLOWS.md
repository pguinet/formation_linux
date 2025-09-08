# 🤖 Documentation des Workflows GitHub Actions

Ce fichier documente les workflows GitHub Actions qui automatisent la génération des PDFs de formation.

## 📋 Workflows disponibles

### 1. `build-pdfs.yml` - Build Production 📚

**Déclencheurs :**
- Push sur `master`/`main`
- Modification des fichiers dans `supports/`, `travaux_pratiques/`, `scripts/`
- Déclenchement manuel via GitHub UI

**Actions :**
- ✅ Installation de LaTeX et pandoc
- ✅ Génération des modules Git et Docker
- ✅ Upload des PDFs comme artifacts
- ✅ Création automatique d'une release avec les PDFs

**Artifacts générés :**
- `formation-linux-pdfs-{SHA}` - Tous les PDFs
- `module-git-pdf` - Module Git uniquement  
- `module-docker-pdf` - Module Docker uniquement

### 2. `test-build.yml` - Tests PR 🧪

**Déclencheurs :**
- Pull Requests vers `master`/`main`
- Modification des fichiers de contenu ou scripts

**Actions :**
- ✅ Test de compilation des modules
- ✅ Validation de la génération PDF
- ✅ Rapport de test dans la PR

### 3. `build-artifacts-only.yml` - Build Manuel 📦

**Déclencheurs :**
- Déclenchement manuel uniquement
- Utile si problème de permissions pour les releases

**Actions :**
- ✅ Génération des PDFs
- ✅ Upload artifacts uniquement (pas de release)
- ✅ Rapport détaillé des résultats

## 🚀 Utilisation

### Récupérer les PDFs automatiques

#### Option 1 : Depuis les Releases
1. Aller sur [Releases](../../releases)
2. Télécharger la dernière version
3. Les PDFs sont attachés comme assets

#### Option 2 : Depuis les Actions  
1. Aller sur [Actions](../../actions)
2. Cliquer sur un build réussi
3. Télécharger les artifacts en bas de page

#### Option 3 : Déclenchement manuel
1. Aller sur [Actions](../../actions/workflows/build-pdfs.yml)
2. Cliquer sur "Run workflow"
3. Attendre la fin du build (~5-10 minutes)

#### Option 4 : Build de contournement (si problème de permissions)
1. Aller sur [Actions](../../actions/workflows/build-artifacts-only.yml)
2. Cliquer sur "Run workflow" 
3. Télécharger les artifacts (pas de release créée)

### Pour les développeurs

#### Test local avant push
```bash
# Vérifier que les scripts fonctionnent
./scripts/build_git_module.sh
./scripts/build_docker_module.sh

# Vérifier les caractères Unicode
find supports/ travaux_pratiques/ -name "*.md" -exec grep -l "🔥\|⚠️\|✅" {} \;
```

#### Débugger un échec de build
1. Regarder les logs dans l'onglet Actions
2. Les erreurs LaTeX sont souvent liées aux caractères Unicode
3. Utiliser `./scripts/clean_unicode.sh` sur les fichiers problématiques

## 📋 Configuration

### Variables d'environnement
Aucune variable personnalisée n'est requise. Le workflow utilise :
- `GITHUB_TOKEN` (automatique)
- `github.sha`, `github.ref` (automatiques)

### Permissions requises
Le workflow a besoin des permissions pour :
- ✅ Lire le code source (`contents: read`)
- ✅ Écrire les releases (`contents: write`) 
- ✅ Upload des artifacts (automatique)

### Durée de rétention
- **Artifacts** : 90 jours
- **Releases** : Permanent
- **Logs de build** : 30 jours (paramètre GitHub)

## 🐛 Dépannage

### Problèmes courants

#### Erreur 403 lors de la création de release
```
⚠️ GitHub release failed with status: 403
```
**Solutions :**
1. **Vérifier les permissions du repository** (Settings → Actions → General)
2. **Utiliser le workflow de contournement** `build-artifacts-only.yml`
3. **Vérifier les tokens** dans les secrets du repository
4. **Alternative :** Récupérer les PDFs via les artifacts

#### Build qui échoue sur LaTeX
```
! LaTeX Error: Unicode character ⚠️ (U+26A0) not set up for use with LaTeX
```
**Solution :** Lancer `./scripts/clean_unicode.sh` sur le fichier problématique

#### Build lent ou timeout
```
timeout 300s ./scripts/build_docker_module.sh
```
**Solution :** Le timeout est normal sur les grosses documentations, augmenter si nécessaire

#### Pas d'artifacts générés
**Vérification :**
1. Le build s'est-il bien terminé ?
2. Y a-t-il des fichiers dans `build/**/*.pdf` ?
3. Les permissions GitHub sont-elles correctes ?

### Logs utiles
```bash
# Voir la taille des PDFs générés
find build/ -name "*.pdf" -exec ls -lh {} \;

# Vérifier les caractères problématiques
grep -r "🔥\|⚠️\|✅\|⏰" supports/ travaux_pratiques/

# Tester la génération manuelle
./scripts/build_modules_additionnels.sh
```

## 🔧 Maintenance

### Mise à jour des dépendances LaTeX
Si des nouveaux packages LaTeX sont nécessaires, les ajouter dans `build-pdfs.yml` :
```yaml
sudo apt-get install -y \
  texlive-latex-recommended \
  texlive-fonts-extra \
  # Nouveau package ici
```

### Optimisation des builds
- Utiliser le cache GitHub pour les dépendances LaTeX
- Paralléliser la génération des modules
- Compresser les artifacts volumineux

---

💡 **Tip :** Les workflows s'activent automatiquement dès que ce repository est poussé sur GitHub avec les workflows dans `.github/workflows/`.