# 🤝 Guide de contribution

## 🚀 Démarrage rapide

### Modifier le contenu

1. **Fork** le repository
2. **Cloner** votre fork localement  
3. **Modifier** les fichiers Markdown dans `cours_2026/` (cours de base) ou dans les modules additionnels (`supports/modules_additionnels/`, `travaux_pratiques/tp_additionnels/`)
4. **Tester** localement (optionnel) :
   ```bash
   ./scripts/build_git_module.sh        # Test module Git
   ./scripts/build_docker_module.sh     # Test module Docker
   ```
5. **Commit** et **push** vos modifications
6. **Créer** une Pull Request

### 🤖 Tests automatiques

Dès que vous créez une PR, GitHub Actions va :
- ✅ Tester la génération des PDFs
- ✅ Vérifier qu'il n'y a pas d'erreurs LaTeX  
- ✅ Afficher un rapport dans la PR

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
- Amélioration des scripts de génération
- Optimisation des workflows GitHub Actions
- Correction de bugs de génération PDF

**Fichiers concernés :**
- `scripts/`
- `.github/workflows/`

### 📖 Documentation
- Mise à jour du README
- Amélioration de CLAUDE.md
- Documentation des workflows

## ⚠️ Points d'attention

### Caractères Unicode
**❌ Éviter :** `🔥 ⚠️ ✅ → ← ↑ ↓ ┌ └ ├ ┤ ●`  
**✅ Utiliser :** `[FIRE] [WARN] [OK] -> <- ^ v + + + + *`

**Pourquoi ?** LaTeX ne supporte pas tous les caractères Unicode.

### Accents français
**✅ Conserver :** `é è à ç ù œ « »`  
Ces caractères sont correctement supportés par la configuration LaTeX.

### Test avant contribution
```bash
# Vérifier les caractères problématiques
grep -r "🔥\|⚠️\|✅\|→" cours_2026/ supports/ travaux_pratiques/

# Nettoyer si nécessaire  
./scripts/clean_unicode.sh fichier-problematique.md
```

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

📖 **Documentation workflows** : Voir [.github/WORKFLOWS.md](.github/WORKFLOWS.md) pour les détails techniques.

## 📋 Checklist avant PR

- [ ] Les modifications sont testées (ou les tests automatiques passent)
- [ ] Les accents français sont préservés
- [ ] Pas d'emojis ou caractères Unicode problématiques
- [ ] Le contenu suit la structure existante
- [ ] Les exemples de code sont fonctionnels

## 🐛 Signaler un problème

### Bug de génération PDF
1. Aller dans [Issues](../../issues)
2. Utiliser le template "Bug PDF"  
3. Inclure les logs d'erreur depuis Actions

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