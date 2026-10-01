# 🤝 Guide de contribution

## 🚀 Démarrage rapide

### Modifier le contenu

1. **Fork** le repository
2. **Cloner** votre fork localement  
3. **Modifier** les fichiers Markdown dans `cours_2026/` (cours de base) ou dans les modules additionnels (`supports/modules_additionnels/`, `travaux_pratiques/tp_additionnels/`)
4. **Tester** localement (optionnel, Docker requis) :
   ```bash
   ./pdf/build                          # Génère les 11 PDF et lance les tests
   ```
5. **Commit** et **push** vos modifications
6. **Créer** une Pull Request

### 🤖 Tests automatiques

Dès que vous créez une PR, le workflow GitHub Actions `PDF` lance les mêmes commandes qu'en local :
- `./pdf/build check` : vérification du code de la chaîne (lint) ;
- `./pdf/build pdf` : génération des 11 PDF ;
- `./pdf/build test` : tests des PDF produits, résultat visible dans la PR.

En local, `./pdf/build` seul enchaîne la génération et les tests, sans le lint : si vous modifiez `pdf/`, lancez aussi `./pdf/build check`.

**Pas besoin d'installer LaTeX localement !**

## 📝 Types de contributions

### 📚 Contenu pédagogique
- Amélioration des explications
- Ajout d'exemples pratiques
- Correction de fautes de frappe
- Mise à jour des références

**Fichiers concernés :**
- `cours_2026/module_*/` (modules de base 01-08, exercices inclus dans chaque chapitre)
- `supports/modules_additionnels/module_*/` (modules additionnels)
- `travaux_pratiques/tp_additionnels/` (TP des modules additionnels)

`archives/cours_2025/` contient l'ancien cours de base : il est conservé en référence et ne doit plus être modifié.

### 🔧 Scripts et outils
- Amélioration de la chaîne de génération PDF
- Optimisation du workflow GitHub Actions
- Correction de bugs de génération PDF

**Fichiers concernés :**
- `pdf/` (point d'entrée `./pdf/build`, catalogue `documents.yaml`, tests)
- `.github/workflows/pdf.yml`

### 📖 Documentation
- Mise à jour du README
- Amélioration de CLAUDE.md

## ⚠️ Points d'attention

### Caractères Unicode
**❌ Éviter :** `🔥 ⚠️ ✅ → ← ↑ ↓ ┌ └ ├ ┤ ●`  
**✅ Utiliser :** `[FIRE] [WARN] [OK] -> <- ^ v + + + + *`

**Pourquoi ?** La police utilisée pour les PDF ne contient pas tous les caractères Unicode.

### Accents français
**✅ Conserver :** `é è à ç ù œ « »`  
Ces caractères sont correctement supportés par la configuration LaTeX.

### Test avant contribution
```bash
./pdf/build
```

Un caractère absent de la police fait échouer la génération avec `Missing character` : le message indique le caractère fautif, à corriger dans la source.

## 🔄 Workflow de contribution

### Pour les modifications mineures
1. Éditer directement sur GitHub (icône crayon)
2. GitHub Actions testera automatiquement
3. Merger après validation

### Pour les modifications importantes
1. **Fork** + clone local
2. **Créer une branche** : `git checkout -b amelioration-module-docker`
3. **Faire les modifications**
4. **Tester localement** (optionnel)
5. **Commit** : `git commit -m "Amélioration exemples Docker"`
6. **Push** : `git push origin amelioration-module-docker`
7. **Pull Request** sur GitHub

📖 **Génération PDF** : voir la section « Génération PDF » de [CLAUDE.md](CLAUDE.md#génération-pdf) pour les détails techniques.

## 📋 Checklist avant PR

- [ ] Les modifications sont testées (ou les tests automatiques passent)
- [ ] Les accents français sont préservés
- [ ] Pas d'emojis ou caractères Unicode problématiques
- [ ] Le contenu suit la structure existante
- [ ] Les exemples de code sont fonctionnels

## 🐛 Signaler un problème

### Bug de génération PDF
1. Aller dans [Issues](../../issues)
2. Ouvrir une issue en joignant l'artifact de diagnostic (`debug-...`) du run Actions en échec

### Erreur de contenu
1. Aller dans [Issues](../../issues)
2. Préciser le module et chapitre concerné
3. Proposer une correction si possible

### Amélioration suggérée
1. Aller dans [Issues](../../issues)
2. Utiliser le label "enhancement"
3. Décrire l'amélioration souhaitée

## ❓ Questions fréquentes

### "Mon PDF ne se génère pas"
➡️ Vérifiez les logs dans Actions. C'est souvent un caractère Unicode problématique.

### "Comment ajouter un nouveau module ?"
➡️ Pour le cours de base, suivre le template de chapitre de `cours_2026/` (voir CLAUDE.md). Pour un module additionnel, suivre la structure de `supports/modules_additionnels/` et créer les TP dans `travaux_pratiques/tp_additionnels/`.

### "Puis-je modifier les workflows ?"
➡️ Oui ! Mais testez d'abord dans un fork pour éviter de casser la génération pour tout le monde.

### "Comment récupérer les PDFs les plus récents ?"
➡️ [Releases](../../releases/latest) ou artifacts depuis [Actions](../../actions)

---

## 🎯 Objectif

Maintenir une formation Linux de **qualité professionnelle**, **toujours à jour**, et **facilement accessible** grâce à l'automatisation.

**Merci pour votre contribution !** 🚀