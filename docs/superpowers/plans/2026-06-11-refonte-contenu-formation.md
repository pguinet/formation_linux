# Refonte du contenu de la formation Linux — Plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructurer les 8 modules de base (33 chapitres, ~18 800 lignes) en 22 chapitres « théorie / pour aller plus loin / exercices » tenant sur 6 séances de 2h, plus un guide d'installation en annexe.

**Architecture:** Un fichier markdown par chapitre dans `supports/module_XX_*/`, conforme au template en trois parties. Chaque tâche fusionne/condense des fichiers sources existants, recycle les TP correspondants en exercices, supprime les sources consommées et committe. Spec de référence : `docs/superpowers/specs/2026-06-11-refonte-contenu-formation-design.md`.

**Tech Stack:** Markdown français, git. Pas de code. La génération PDF est hors périmètre.

---

## AMENDEMENT 2026-06-11 (prévaut sur les tâches ci-dessous)

Décision en cours d'exécution : le nouveau cours est construit dans un
nouveau dossier **`cours_2026/`** pour éliminer tout risque d'écrasement.
Conséquences :

1. Tous les chemins `Create:` des tâches deviennent
   `cours_2026/module_XX_*/...` et `cours_2026/annexes/...` (mêmes noms de
   fichiers, mêmes répertoires de modules que dans `supports/`).
2. **Aucune suppression** : tous les steps « Supprimer les sources
   consommées » (`git rm`) sont annulés. `supports/` et
   `travaux_pratiques/` restent intacts.
3. La **Task 24** (suppression des TP) est annulée.
4. Les fichiers « réécrits en place » (Tasks 13, 21, 22) deviennent des
   créations dans `cours_2026/` comme les autres.
5. Les tâches de contenu étant désormais sans conflit possible, elles
   peuvent être exécutées **en parallèle** (un sous-agent par fichier).
   Les sous-agents n'exécutent PAS de commit (évite les conflits d'index
   git) : les commits sont faits par le contrôleur, par lots.
6. Tasks 25-27 : « supports/module_0X » se lit « cours_2026/module_0X » ;
   dans la Task 25 (README) et la Task 26 (CLAUDE.md), documenter que le
   cours refondu vit dans `cours_2026/` et que `supports/` +
   `travaux_pratiques/` sont l'ancien matériau conservé.

---

## Conventions de rédaction (applicables à TOUTES les tâches)

**Template de chapitre** (obligatoire, dans cet ordre) :

```markdown
# Chapitre X.Y — Titre

> **Objectifs** : à la fin de ce chapitre, vous saurez [2-4 puces].
> **Durée en séance** : ~30 min.

## [Sections de théorie — titres libres, voir le contenu de chaque tâche]

## L'essentiel

| Commande | Usage type |
|----------|-----------|
| ... | ... |

## Pour aller plus loin

## Exercices

### Solutions
```

**Règles de contenu :**
- Théorie : la commande, ses 2-3 options vitales, un exemple concret. Pas de
  catalogue d'options. Cible **150-200 lignes** avant `## L'essentiel`
  (maximum strict : 250).
- Chaque concept n'est traité qu'une fois dans toute la formation : si un
  chapitre a besoin d'une notion d'un autre chapitre, faire un renvoi
  (« voir chapitre X.Y »), ne pas réexpliquer.
- « Pour aller plus loin » : lecture hors séance, pas de limite stricte mais
  rester sobre (≤ 100 lignes).
- Exercices : 3 à 6 exercices progressifs, faisables seul sur la VM, recyclés
  depuis le TP indiqué dans la tâche. Solutions complètes en sous-section
  `### Solutions`.
- Français correct, vouvoiement, accents préservés.
- INTERDIT (casse le PDF) : caractères de boîtes `┌┐└┘├┤┬┴┼│─`, flèches
  `→←↑↓▶◀`, symboles `≠≤≥×÷√●`, emojis. Diagrammes en ASCII simple
  (`+`, `-`, `|`, `<`, `>`).

**Vérifications standard** (à exécuter pour chaque chapitre créé, `$F` étant le fichier) :

```bash
# V1 - Structure : les 4 sections obligatoires, dans l'ordre
grep -n "^## L'essentiel$\|^## Pour aller plus loin$\|^## Exercices$\|^### Solutions$" "$F"
# Attendu : exactement 4 lignes, numéros croissants, dans cet ordre.

# V2 - Calibration : nombre de lignes de théorie (avant « L'essentiel »)
awk "/^## L'essentiel/{print NR-1; exit}" "$F"
# Attendu : valeur entre 100 et 250.

# V3 - Caractères interdits
grep -nP '[┌┐└┘├┤┬┴┼│─→←↑↓▶◀≠≤≥×÷√●✅❌⚠️📁🔧🔍✓✗🎯🚀]' "$F"
# Attendu : aucune sortie (code retour 1).
```

**Commits :** messages en français, préfixe conventionnel (`feat:`, `docs:`,
`chore:`), un commit par tâche, sur la branche `refonte-contenu`.

---

### Task 1: Annexe — Guide d'installation

**Files:**
- Create: `supports/annexes/installation.md`
- Delete: `supports/module_01_decouverte/03_installation.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_01_decouverte/03_installation.md`,
`travaux_pratiques/tp01_installation/tp01_premiere_connexion.md` et
`travaux_pratiques/tp01_installation/tp02_configuration_environnement.md`.

- [ ] **Step 2: Écrire `supports/annexes/installation.md`**

Ce fichier est un guide pratique, PAS un chapitre de cours : il ne suit pas le
template en trois parties. Structure :

```markdown
# Annexe — Installer son environnement de travail

> Ce guide est un prérequis : la formation commence une fois
> l'environnement installé et fonctionnel.

## Option A — VM Linux distante (accès SSH)
(public disposant d'une VM fournie : client SSH, paire de clés fournie,
test de connexion, premiers réglages)

## Option B — VM VirtualBox sur poste Windows
(création d'un répertoire personnel sur D:\, installation de VirtualBox,
création d'une VM Debian 13 depuis l'ISO, stockage du disque sur D:\
pour survivre au « freeze », réutilisation d'une semaine sur l'autre)

## Vérifier que tout fonctionne
(checklist commune : ouvrir un terminal, taper une commande, redimensionner)

## En cas de problème
(les 3-4 problèmes les plus courants par option et leur solution)
```

Contenu : condenser l'actuel `03_installation.md` et la partie « mise en
place » des deux TP d'installation. Cible : ≤ 300 lignes au total.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_01_decouverte/03_installation.md
```

- [ ] **Step 4: Vérifier**

V3 uniquement (pas de template trois parties pour l'annexe) :
```bash
grep -nP '[┌┐└┘├┤┬┴┼│─→←↑↓▶◀≠≤≥×÷√●✅❌⚠️📁🔧🔍✓✗🎯🚀]' supports/annexes/installation.md
```
Attendu : aucune sortie. Et `wc -l supports/annexes/installation.md` ≤ 300.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/annexes/installation.md
git -C /opt/github/formation_linux commit -m "feat: guide d'installation en annexe (hors séances)"
```

---

### Task 2: Chapitre 1.1 — Linux : histoire, philosophie et distributions

**Files:**
- Create: `supports/module_01_decouverte/01_histoire_philosophie_distributions.md`
- Delete: `supports/module_01_decouverte/01_histoire_linux.md`, `supports/module_01_decouverte/02_distributions.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_01_decouverte/01_histoire_linux.md`,
`supports/module_01_decouverte/02_distributions.md` et
`travaux_pratiques/tp01_decouverte/exercice_principal.md`.

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 1.1 — Linux : histoire, philosophie et distributions`.

Théorie (sections suggérées) :
- « D'Unix à Linux » : Unix (1970s), GNU (1983), noyau Linux (1991), en
  quelques paragraphes datés, sans biographie détaillée.
- « Le logiciel libre » : les 4 libertés, la GPL en une phrase, le modèle
  communautaire.
- « Les distributions » : définition (noyau + outils + gestion de paquets),
  panorama en un tableau (Debian, Ubuntu, Fedora, Arch : public visé et
  particularité en une ligne chacune), pourquoi Debian pour cette formation.
- « Où vit Linux aujourd'hui » : serveurs, cloud, Android, embarqué (un
  paragraphe).

Pour aller plus loin : généalogie des distributions, différences de licences
(GPL/BSD/MIT en survol), liens vers kernel.org et debian.org.

Exercices : recycler `tp01_decouverte/exercice_principal.md` ; ajouter 2-3
questions de réflexion (ex. « citez deux différences entre Debian et
Ubuntu ») avec solutions.

- [ ] **Step 3: Supprimer les sources consommées**

```bash
git -C /opt/github/formation_linux rm supports/module_01_decouverte/01_histoire_linux.md supports/module_01_decouverte/02_distributions.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 (voir Conventions) avec
`F=supports/module_01_decouverte/01_histoire_philosophie_distributions.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_01_decouverte/
git -C /opt/github/formation_linux commit -m "feat: chapitre 1.1 histoire, philosophie et distributions (fusion 1.1+1.2)"
```

---

### Task 3: Chapitre 1.2 — Premier contact avec le terminal

**Files:**
- Create: `supports/module_01_decouverte/02_premier_terminal.md`
- Delete: `supports/module_01_decouverte/04_premier_terminal.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_01_decouverte/04_premier_terminal.md` et
`travaux_pratiques/tp01_installation/tp02_configuration_environnement.md`
(partie exercices terminal).

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 1.2 — Premier contact avec le terminal`.

Théorie :
- « Terminal, shell, prompt » : ce que c'est, anatomie du prompt
  (`utilisateur@machine:~$`).
- « Anatomie d'une commande » : `commande [options] [arguments]`, exemples
  avec `ls -l /home`.
- « Obtenir de l'aide » : `man commande` (navigation de base : espace, q,
  /recherche), `commande --help`.
- « Travailler plus vite » : complétion Tab, historique avec les flèches,
  `clear`, `exit`, Ctrl+C pour interrompre.

Pour aller plus loin : raccourcis clavier du shell (Ctrl+A/E/U/L, Ctrl+R en
renvoi vers le chapitre 6.3), les différents shells (bash, zsh), `info` et
`apropos`.

Exercices : 4-5 manipulations guidées (ouvrir le man de ls, utiliser la
complétion, retrouver une commande dans l'historique), avec solutions.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_01_decouverte/04_premier_terminal.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_01_decouverte/02_premier_terminal.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_01_decouverte/
git -C /opt/github/formation_linux commit -m "feat: chapitre 1.2 premier contact avec le terminal"
```

---

### Task 4: Chapitre 2.1 — L'arborescence et les chemins

**Files:**
- Create: `supports/module_02_navigation/01_arborescence_chemins.md`
- Delete: `supports/module_02_navigation/01_arborescence.md`, `supports/module_02_navigation/03_chemins.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_02_navigation/01_arborescence.md`,
`supports/module_02_navigation/03_chemins.md` et
`travaux_pratiques/tp02_navigation/tp01_exploration_arborescence.md`.

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 2.1 — L'arborescence et les chemins`.

Théorie :
- « Tout part de la racine » : `/`, arborescence unique (pas de lecteurs
  C:/D:), schéma ASCII simple.
- « Les répertoires à connaître » : tableau `/home`, `/etc`, `/var`, `/usr`,
  `/tmp`, `/root` (une ligne chacun).
- « Chemins absolus et relatifs » : définition, `.` et `..`, `~`, exemples
  comparés depuis un même point de départ.

Pour aller plus loin : le standard FHS, `/proc`, `/sys`, `/dev`, `/opt`,
`/srv`.

Exercices : recycler la partie exploration de
`tp02_navigation/tp01_exploration_arborescence.md` (questions « quel chemin
absolu correspond à... », conversions absolu/relatif), avec solutions.

- [ ] **Step 3: Supprimer les sources consommées**

```bash
git -C /opt/github/formation_linux rm supports/module_02_navigation/01_arborescence.md supports/module_02_navigation/03_chemins.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_02_navigation/01_arborescence_chemins.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_02_navigation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 2.1 arborescence et chemins (fusion 2.1+2.3)"
```

---

### Task 5: Chapitre 2.2 — Se déplacer et explorer

**Files:**
- Create: `supports/module_02_navigation/02_se_deplacer_explorer.md`
- Delete: `supports/module_02_navigation/02_commandes_base.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_02_navigation/02_commandes_base.md` et
`travaux_pratiques/tp02_navigation/tp01_exploration_arborescence.md`
(partie navigation).

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 2.2 — Se déplacer et explorer (pwd, cd, ls)`.

Théorie :
- « Où suis-je ? » : `pwd`.
- « Se déplacer » : `cd chemin`, `cd` seul, `cd ..`, `cd -`.
- « Lister » : `ls`, `ls -l` (lecture des colonnes, en renvoyant au
  chapitre 5.2 pour le détail des permissions), `ls -a`, `ls -lh`.

Pour aller plus loin : tris de `ls` (`-t`, `-S`, `-r`), `tree`, combinaisons
courantes (`ls -latr`).

Exercices : parcours guidé dans l'arborescence (recyclé du TP02), avec
solutions.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_02_navigation/02_commandes_base.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_02_navigation/02_se_deplacer_explorer.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_02_navigation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 2.2 se déplacer et explorer"
```

---

### Task 6: Chapitre 2.3 — Types de fichiers et liens

**Files:**
- Create: `supports/module_02_navigation/03_types_fichiers_liens.md`
- Delete: `supports/module_02_navigation/04_types_fichiers.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_02_navigation/04_types_fichiers.md` et
`travaux_pratiques/tp02_navigation/tp02_types_liens.md`.

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 2.3 — Types de fichiers et liens`.

Théorie :
- « Tout est fichier » : fichiers ordinaires, répertoires, liens ; premier
  caractère de `ls -l` (`-`, `d`, `l`).
- « Identifier un fichier » : `file`.
- « Les liens symboliques » : `ln -s cible lien`, à quoi ça sert, lien cassé.

Pour aller plus loin : liens physiques et inodes, fichiers spéciaux
(`/dev`), extensions de fichiers (Linux ne s'y fie pas).

Exercices : recycler `tp02_navigation/tp02_types_liens.md`, avec solutions.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_02_navigation/04_types_fichiers.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_02_navigation/03_types_fichiers_liens.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_02_navigation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 2.3 types de fichiers et liens"
```

---

### Task 7: Chapitre 3.1 — Créer, copier, déplacer, supprimer

**Files:**
- Create: `supports/module_03_manipulation/01_creer_copier_deplacer_supprimer.md`
- Delete: `supports/module_03_manipulation/01_creation_copie.md`, `supports/module_03_manipulation/02_suppression.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_03_manipulation/01_creation_copie.md`,
`supports/module_03_manipulation/02_suppression.md` et
`travaux_pratiques/tp03_manipulation/tp01_gestion_fichiers.md`.

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 3.1 — Créer, copier, déplacer, supprimer`.

Théorie :
- « Créer » : `touch`, `mkdir`, `mkdir -p`.
- « Copier » : `cp`, `cp -r` pour les répertoires.
- « Déplacer et renommer » : `mv` (les deux usages).
- « Supprimer » : `rm`, `rm -r`, `rmdir` ; encadré « il n'y a PAS de
  corbeille : ce qui est supprimé est perdu », `rm -i` comme filet.

Pour aller plus loin : `cp -a` (préserver les attributs), les dangers de
`rm -rf` et les garde-fous (`--preserve-root`, vérifier avec `echo` avant un
joker), `trash-cli`.

Exercices : recycler `tp03_manipulation/tp01_gestion_fichiers.md` (création
d'une arborescence projet, copies, renommages, suppression contrôlée), avec
solutions.

- [ ] **Step 3: Supprimer les sources consommées**

```bash
git -C /opt/github/formation_linux rm supports/module_03_manipulation/01_creation_copie.md supports/module_03_manipulation/02_suppression.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_03_manipulation/01_creer_copier_deplacer_supprimer.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_03_manipulation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 3.1 créer, copier, déplacer, supprimer (fusion 3.1+3.2)"
```

---

### Task 8: Chapitre 3.2 — Rechercher des fichiers

**Files:**
- Create: `supports/module_03_manipulation/02_rechercher_fichiers.md`
- Delete: `supports/module_03_manipulation/03_recherche.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_03_manipulation/03_recherche.md` et
`travaux_pratiques/tp03_manipulation/tp01_gestion_fichiers.md` (partie
recherche si présente).

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 3.2 — Rechercher des fichiers`.

Théorie :
- « find, l'outil universel » : `find chemin -name motif`, `-type f/d`,
  `-size`, exemple concret par cas d'usage.
- « Où est cette commande ? » : `which`.

Pour aller plus loin : `locate`/`updatedb`, `whereis`, `find -exec`,
`find -mtime`.

Exercices : 4-5 recherches concrètes sur l'arborescence créée au chapitre
3.1 (retrouver un fichier par nom, par taille, par type), avec solutions.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_03_manipulation/03_recherche.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_03_manipulation/02_rechercher_fichiers.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_03_manipulation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 3.2 rechercher des fichiers"
```

---

### Task 9: Chapitre 3.3 — Archiver et compresser

**Files:**
- Create: `supports/module_03_manipulation/03_archiver_compresser.md`
- Delete: `supports/module_03_manipulation/04_archivage.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_03_manipulation/04_archivage.md` et
`travaux_pratiques/tp03_manipulation/tp02_archivage_compression.md`.

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 3.3 — Archiver et compresser`.

Théorie :
- « Archiver ou compresser ? » : la différence en deux phrases.
- « tar » : créer (`tar czf`), lister (`tar tzf`), extraire (`tar xzf`) ;
  moyen mnémotechnique pour c/t/x.
- « zip » : `zip -r`, `unzip` (échanges avec Windows).

Pour aller plus loin : `gzip`/`gunzip` seuls, `bzip2` et `xz` (compromis
taille/vitesse), extraire un seul fichier d'une archive.

Exercices : recycler `tp03_manipulation/tp02_archivage_compression.md`
(sauvegarder l'arborescence du 3.1, la restaurer ailleurs), avec solutions.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_03_manipulation/04_archivage.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_03_manipulation/03_archiver_compresser.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_03_manipulation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 3.3 archiver et compresser"
```

---

### Task 10: Chapitre 4.1 — Lire des fichiers

**Files:**
- Create: `supports/module_04_consultation/01_lire_fichiers.md`
- Delete: `supports/module_04_consultation/01_lecture_fichiers.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_04_consultation/01_lecture_fichiers.md` et
`travaux_pratiques/tp04_consultation/tp01_lecture_edition.md`.

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 4.1 — Lire des fichiers`.

Théorie :
- « Afficher d'un bloc » : `cat` (et quand NE PAS l'utiliser : gros
  fichiers).
- « Lire page par page » : `less` (espace, b, /motif, n, q).
- « Début et fin » : `head`, `tail`, `tail -n 20`, `tail -f` (suivre un log,
  renvoi au chapitre 7.2).

Pour aller plus loin : `more` (historique), `wc`, `nl`, lire un fichier
compressé avec `zless`.

Exercices : recycler la partie lecture de
`tp04_consultation/tp01_lecture_edition.md` (explorer `/etc/passwd`,
suivre un fichier qui grossit), avec solutions.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_04_consultation/01_lecture_fichiers.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_04_consultation/01_lire_fichiers.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_04_consultation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 4.1 lire des fichiers"
```

---

### Task 11: Chapitre 4.2 — Éditer avec nano

**Files:**
- Create: `supports/module_04_consultation/02_editer_nano.md`
- Delete: `supports/module_04_consultation/02_editeurs_texte.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_04_consultation/02_editeurs_texte.md` et
`travaux_pratiques/tp04_consultation/tp01_lecture_edition.md` (partie
édition).

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 4.2 — Éditer avec nano`.

Théorie :
- « Pourquoi un éditeur dans le terminal » : un paragraphe.
- « nano » : ouvrir/créer, taper, sauvegarder (Ctrl+O), quitter (Ctrl+X),
  chercher (Ctrl+W), couper/coller une ligne (Ctrl+K / Ctrl+U) ; lecture de
  la barre de raccourcis (le `^` = Ctrl).

Pour aller plus loin : survol de vim (modes, `i`, `Echap`, `:wq`, `:q!` —
juste de quoi s'en sortir si on y est coincé), `EDITOR` par défaut.

Exercices : recycler la partie édition de
`tp04_consultation/tp01_lecture_edition.md` (créer et modifier un fichier,
chercher/remplacer), avec solutions.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_04_consultation/02_editeurs_texte.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_04_consultation/02_editer_nano.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_04_consultation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 4.2 éditer avec nano"
```

---

### Task 12: Chapitre 4.3 — Chercher dans les fichiers et comparer

**Files:**
- Create: `supports/module_04_consultation/03_chercher_comparer.md`
- Delete: `supports/module_04_consultation/03_recherche_contenu.md`, `supports/module_04_consultation/04_comparaison.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_04_consultation/03_recherche_contenu.md`,
`supports/module_04_consultation/04_comparaison.md` et
`travaux_pratiques/tp04_consultation/tp01_lecture_edition.md` (partie
recherche).

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 4.3 — Chercher dans les fichiers et comparer`.

Théorie :
- « grep » : `grep motif fichier`, `-i`, `-n`, `-r`, `-v` ; distinction avec
  `find` (contenu vs nom) en renvoi au chapitre 3.2.
- « Comparer deux fichiers » : `diff fichier1 fichier2`, lire la sortie
  (`<` / `>`).

Pour aller plus loin : expressions régulières de base (`^`, `$`, `.`,
`[abc]`), `grep -E`, `diff -u`, `cmp` pour les binaires.

Exercices : recherches dans `/etc` et comparaison de deux versions d'un
fichier de config (recyclé du TP04), avec solutions.

- [ ] **Step 3: Supprimer les sources consommées**

```bash
git -C /opt/github/formation_linux rm supports/module_04_consultation/03_recherche_contenu.md supports/module_04_consultation/04_comparaison.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_04_consultation/03_chercher_comparer.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_04_consultation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 4.3 chercher et comparer (fusion 4.3+4.4)"
```

---

### Task 13: Chapitre 5.1 — Utilisateurs et groupes

**Files:**
- Create: `supports/module_05_droits/01_utilisateurs_groupes.md` (réécriture complète du fichier existant)

- [ ] **Step 1: Lire les sources**

Lire `supports/module_05_droits/01_utilisateurs_groupes.md` et
`travaux_pratiques/tp05_droits/tp01_utilisateurs_permissions.md`.

- [ ] **Step 2: Écrire le chapitre**

Remplacer entièrement le contenu du fichier (le nom ne change pas).
En-tête : `# Chapitre 5.1 — Utilisateurs et groupes`.

Théorie :
- « Un système multi-utilisateurs » : pourquoi des comptes, le
  super-utilisateur root.
- « Qui suis-je ? » : `whoami`, `id`, `groups`.
- « Où sont définis les comptes » : lecture guidée d'une ligne de
  `/etc/passwd` et de `/etc/group` (sans exhaustivité).
- « Changer d'utilisateur » : `su - utilisateur`.

Pour aller plus loin : `adduser`/`addgroup`/`usermod` (administration),
`/etc/shadow`, UID/GID, comptes système vs comptes humains.

Exercices : recycler la partie utilisateurs de
`tp05_droits/tp01_utilisateurs_permissions.md`, avec solutions.

- [ ] **Step 3: (néant — le fichier garde son nom)**

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_05_droits/01_utilisateurs_groupes.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_05_droits/
git -C /opt/github/formation_linux commit -m "feat: chapitre 5.1 utilisateurs et groupes (condensé)"
```

---

### Task 14: Chapitre 5.2 — Permissions

**Files:**
- Create: `supports/module_05_droits/02_permissions.md`
- Delete: `supports/module_05_droits/02_permissions_fichiers.md`, `supports/module_05_droits/03_permissions_avancees.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_05_droits/02_permissions_fichiers.md`,
`supports/module_05_droits/03_permissions_avancees.md` et
`travaux_pratiques/tp05_droits/tp01_utilisateurs_permissions.md`.

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 5.2 — Permissions (chmod, chown)`.

Théorie :
- « Lire les permissions » : décomposer `rwxr-xr--` en
  utilisateur/groupe/autres ; sens de r, w, x pour un fichier ET pour un
  répertoire (tableau).
- « Modifier : chmod » : notation symbolique (`u+x`, `g-w`, `o=r`) puis
  octale (table 4/2/1, exemples 755, 644).
- « Changer le propriétaire » : `chown utilisateur:groupe`, `chgrp`.

Pour aller plus loin : `umask`, setuid/setgid/sticky bit (reconnaître `s` et
`t` dans `ls -l`), ACL (`getfacl`/`setfacl`) en survol.

Exercices : recycler la partie permissions de
`tp05_droits/tp01_utilisateurs_permissions.md` (scénario partage de
répertoire entre deux utilisateurs), avec solutions.

- [ ] **Step 3: Supprimer les sources consommées**

```bash
git -C /opt/github/formation_linux rm supports/module_05_droits/02_permissions_fichiers.md supports/module_05_droits/03_permissions_avancees.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec `F=supports/module_05_droits/02_permissions.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_05_droits/
git -C /opt/github/formation_linux commit -m "feat: chapitre 5.2 permissions (fusion 5.2+5.3)"
```

---

### Task 15: Chapitre 5.3 — sudo et bonnes pratiques de sécurité

**Files:**
- Create: `supports/module_05_droits/03_sudo_securite.md`
- Delete: `supports/module_05_droits/04_sudo_securite.md`

**Note :** l'actuel `supports/module_05_droits/05_processus_proprietaires.md`
n'est PAS supprimé ici : sa matière part dans le chapitre 6.1 et sa
suppression est faite par la Task 16 (qui le consomme).

- [ ] **Step 1: Lire les sources**

Lire `supports/module_05_droits/04_sudo_securite.md` et
`travaux_pratiques/tp05_droits/tp01_utilisateurs_permissions.md` (partie
sudo).

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 5.3 — sudo et bonnes pratiques de sécurité`.

Théorie :
- « root, le compte à tout faire (et tout casser) » : pourquoi on ne
  travaille pas en root.
- « sudo » : exécuter une commande en admin, `sudo -l`, le cache de mot de
  passe ; qui a le droit (groupe `sudo` sur Debian).
- « Bonnes pratiques » : principe du moindre privilège, ne jamais copier une
  commande sudo trouvée sur internet sans la comprendre, verrouiller sa
  session.

Pour aller plus loin : `visudo` et la syntaxe de `/etc/sudoers`,
`sudo -i` vs `su -`, journalisation des commandes sudo
(renvoi chapitre 7.2).

Exercices : recycler la partie sudo de
`tp05_droits/tp01_utilisateurs_permissions.md`, avec solutions.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_05_droits/04_sudo_securite.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec `F=supports/module_05_droits/03_sudo_securite.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_05_droits/
git -C /opt/github/formation_linux commit -m "feat: chapitre 5.3 sudo et sécurité"
```

---

### Task 16: Chapitre 6.1 — Les processus : observer et contrôler

**Files:**
- Create: `supports/module_06_processus/01_processus.md`
- Delete: `supports/module_06_processus/01_gestion_processus.md`, `supports/module_06_processus/02_arriere_plan.md`, `supports/module_05_droits/05_processus_proprietaires.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_06_processus/01_gestion_processus.md`,
`supports/module_06_processus/02_arriere_plan.md`,
`supports/module_05_droits/05_processus_proprietaires.md` et
`travaux_pratiques/tp06_processus/tp01_gestion_surveillance.md`.

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 6.1 — Les processus : observer et contrôler`.

Théorie :
- « Qu'est-ce qu'un processus » : programme en cours, PID, chaque processus
  a un propriétaire (reprend l'essentiel de l'ancien 5.5 en quelques
  lignes).
- « Observer » : `ps aux` (lecture des colonnes PID, USER, %CPU, %MEM,
  COMMAND), `top` (lecture rapide, q pour sortir ; mention de `htop`).
- « Arrêter » : `kill PID` (TERM), `kill -9` en dernier recours.
- « Premier plan, arrière-plan » : Ctrl+C vs Ctrl+Z, `&`, `jobs`, `fg`,
  `bg`.

Pour aller plus loin : `nohup`, liste des signaux (`kill -l`),
`pgrep`/`pkill`, `nice`/`renice`, arborescence des processus (`pstree`).

Exercices : recycler la partie processus de
`tp06_processus/tp01_gestion_surveillance.md` (lancer un processus long, le
suspendre, le reprendre en arrière-plan, le tuer), avec solutions.

- [ ] **Step 3: Supprimer les sources consommées**

```bash
git -C /opt/github/formation_linux rm supports/module_06_processus/01_gestion_processus.md supports/module_06_processus/02_arriere_plan.md supports/module_05_droits/05_processus_proprietaires.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec `F=supports/module_06_processus/01_processus.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_06_processus/ supports/module_05_droits/
git -C /opt/github/formation_linux commit -m "feat: chapitre 6.1 processus (fusion 6.1+6.2+5.5)"
```

---

### Task 17: Chapitre 6.2 — Surveillance système

**Files:**
- Create: `supports/module_06_processus/02_surveillance_systeme.md`
- Delete: `supports/module_06_processus/03_surveillance_systeme.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_06_processus/03_surveillance_systeme.md` et
`travaux_pratiques/tp06_processus/tp01_gestion_surveillance.md` (partie
surveillance).

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 6.2 — Surveillance système`.

Théorie :
- « Espace disque » : `df -h` (lecture), `du -sh dossier` (différence entre
  les deux).
- « Mémoire » : `free -h` (lecture de available, le piège du cache).
- « Charge et durée de fonctionnement » : `uptime` (lecture du load
  average en une phrase simple).

Pour aller plus loin : `du` pour trouver ce qui prend de la place
(`du -h --max-depth=1 | sort -h`), `vmstat`, `/proc/meminfo`,
interprétation fine du load average.

Exercices : recycler la partie surveillance de
`tp06_processus/tp01_gestion_surveillance.md` (trouver le plus gros
répertoire de son home, vérifier la mémoire libre), avec solutions.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_06_processus/03_surveillance_systeme.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_06_processus/02_surveillance_systeme.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_06_processus/
git -C /opt/github/formation_linux commit -m "feat: chapitre 6.2 surveillance système"
```

---

### Task 18: Chapitre 6.3 — Variables d'environnement et historique

**Files:**
- Create: `supports/module_06_processus/03_variables_historique.md`
- Delete: `supports/module_06_processus/04_historique_variables.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_06_processus/04_historique_variables.md` et
`travaux_pratiques/tp06_processus/tp01_gestion_surveillance.md` (partie
environnement si présente).

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 6.3 — Variables d'environnement et historique`.

Théorie :
- « Les variables d'environnement » : `echo $HOME`, `echo $PATH` (à quoi
  sert PATH), `export VAR=valeur`, portée (session courante).
- « L'historique » : `history`, `!n`, Ctrl+R (recherche interactive).
- « Où ça se configure » : mention de `~/.bashrc` avec renvoi au chapitre
  8.3 pour la personnalisation.

Pour aller plus loin : `env` et `printenv`, variables utiles (PS1, EDITOR,
LANG), `HISTSIZE`/`HISTFILESIZE`, `!!` et `!$`.

Exercices : 4-5 manipulations (afficher PATH, créer une variable, la rendre
disponible, retrouver une vieille commande avec Ctrl+R), avec solutions.

- [ ] **Step 3: Supprimer la source consommée**

```bash
git -C /opt/github/formation_linux rm supports/module_06_processus/04_historique_variables.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_06_processus/03_variables_historique.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_06_processus/
git -C /opt/github/formation_linux commit -m "feat: chapitre 6.3 variables d'environnement et historique"
```

---

### Task 19: Chapitre 7.1 — Réseau et transferts

**Files:**
- Create: `supports/module_07_reseaux/01_reseau_transferts.md`
- Delete: `supports/module_07_reseaux/01_configuration_reseau.md`, `supports/module_07_reseaux/02_transferts_fichiers.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_07_reseaux/01_configuration_reseau.md`,
`supports/module_07_reseaux/02_transferts_fichiers.md` et
`travaux_pratiques/tp07_reseaux/tp01_reseau_services_logs.md`.

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 7.1 — Réseau et transferts de fichiers`.

Théorie :
- « Qui suis-je sur le réseau » : `ip a` (trouver son adresse IP),
  `hostname`.
- « Ça répond ? » : `ping` (Ctrl+C pour arrêter).
- « Télécharger » : `wget URL`, `curl URL` (différence en une phrase).
- « Copier entre machines » : `scp fichier user@machine:chemin`, `rsync -av`
  (et pourquoi le préférer pour les gros volumes : reprise, incrémental).

Pour aller plus loin : `ss -tln` (ports en écoute), résolution DNS
(`/etc/hosts`, `dig`), options utiles de rsync (`--delete`, `-n` pour
simuler), `curl` pour tester une API.

Exercices : recycler la partie réseau de
`tp07_reseaux/tp01_reseau_services_logs.md` (trouver son IP, ping, wget,
scp vers/depuis la VM), avec solutions.

- [ ] **Step 3: Supprimer les sources consommées**

```bash
git -C /opt/github/formation_linux rm supports/module_07_reseaux/01_configuration_reseau.md supports/module_07_reseaux/02_transferts_fichiers.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_07_reseaux/01_reseau_transferts.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_07_reseaux/
git -C /opt/github/formation_linux commit -m "feat: chapitre 7.1 réseau et transferts (fusion 7.1+7.2)"
```

---

### Task 20: Chapitre 7.2 — Services et logs

**Files:**
- Create: `supports/module_07_reseaux/02_services_logs.md`
- Delete: `supports/module_07_reseaux/03_services_systeme.md`, `supports/module_07_reseaux/04_logs_systeme.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_07_reseaux/03_services_systeme.md`,
`supports/module_07_reseaux/04_logs_systeme.md` et
`travaux_pratiques/tp07_reseaux/tp01_reseau_services_logs.md` (parties
services et logs).

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 7.2 — Services et logs`.

Théorie :
- « Qu'est-ce qu'un service » : programme qui tourne en permanence,
  exemples (ssh, cron).
- « systemctl » : `status`, `start`, `stop`, `restart`,
  `enable`/`disable` (différence démarrage vs démarrage automatique).
- « Lire les logs » : `journalctl -u service`, `journalctl -f`, les
  fichiers de `/var/log` (`syslog`, `auth.log`) lus avec les outils du
  module 4 (renvoi).

Pour aller plus loin : anatomie d'une unité systemd, `systemctl list-units`,
`dmesg`, rotation des logs (logrotate).

Exercices : recycler les parties services/logs de
`tp07_reseaux/tp01_reseau_services_logs.md` (inspecter le service ssh,
retrouver ses propres connexions dans auth.log), avec solutions.

- [ ] **Step 3: Supprimer les sources consommées**

```bash
git -C /opt/github/formation_linux rm supports/module_07_reseaux/03_services_systeme.md supports/module_07_reseaux/04_logs_systeme.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_07_reseaux/02_services_logs.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_07_reseaux/
git -C /opt/github/formation_linux commit -m "feat: chapitre 7.2 services et logs (fusion 7.3+7.4)"
```

---

### Task 21: Chapitre 8.1 — Redirections et pipes

**Files:**
- Create: `supports/module_08_automatisation/01_redirections_pipes.md` (réécriture complète du fichier existant)

- [ ] **Step 1: Lire les sources**

Lire `supports/module_08_automatisation/01_redirections_pipes.md` et
`travaux_pratiques/tp08_automatisation/tp01_automatisation_complete.md`.

- [ ] **Step 2: Écrire le chapitre**

Remplacer entièrement le contenu du fichier (le nom ne change pas).
En-tête : `# Chapitre 8.1 — Redirections et pipes`.

Théorie :
- « Entrée, sortie, erreur » : les trois flux en un schéma ASCII simple.
- « Rediriger » : `>`, `>>`, `2>`, `<`.
- « Enchaîner : le pipe » : `|`, exemples concrets combinant les commandes
  déjà vues (`ls | wc -l`, `grep ... | sort`, `history | grep`) ;
  présentation de `sort`, `uniq`, `wc` au passage (3 lignes chacune).

Pour aller plus loin : `2>&1`, `tee`, `xargs`, `/dev/null`.

Exercices : recycler la partie pipes de
`tp08_automatisation/tp01_automatisation_complete.md` (compter, filtrer,
trier des données réelles du système), avec solutions.

- [ ] **Step 3: (néant — le fichier garde son nom)**

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_08_automatisation/01_redirections_pipes.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_08_automatisation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 8.1 redirections et pipes (condensé)"
```

---

### Task 22: Chapitre 8.2 — Scripts bash : les bases

**Files:**
- Create: `supports/module_08_automatisation/02_scripts_bash.md` (réécriture complète du fichier existant — 1 462 lignes actuellement, plus gros chantier de réduction)

- [ ] **Step 1: Lire les sources**

Lire `supports/module_08_automatisation/02_scripts_bash.md` et
`travaux_pratiques/tp08_automatisation/tp01_automatisation_complete.md`
(partie scripts).

- [ ] **Step 2: Écrire le chapitre**

Remplacer entièrement le contenu du fichier (le nom ne change pas).
En-tête : `# Chapitre 8.2 — Scripts bash : les bases`.

Théorie :
- « Mon premier script » : shebang `#!/bin/bash`, `chmod +x`, exécution
  `./script.sh`.
- « Variables et arguments » : `NOM=valeur`, `$NOM`, `$1` `$2`, `"$@"` en
  une phrase.
- « Conditions » : `if [ ... ]; then ... fi`, tests courants (`-f`, `-d`,
  `=`, `-eq`), UN exemple complet.
- « Boucles » : `for f in *.txt; do ... done`, UN exemple complet.
- Conclure sur un script-exemple de 10-15 lignes combinant le tout
  (ex. sauvegarde datée d'un répertoire avec tar, renvoi chapitre 3.3).

Pour aller plus loin : `while`, `read` (interactivité), fonctions, codes de
retour `$?`, `set -e`, shellcheck.

Exercices : recycler la partie scripts de
`tp08_automatisation/tp01_automatisation_complete.md` (écrire un script de
sauvegarde paramétrable), avec solutions.

- [ ] **Step 3: (néant — le fichier garde son nom)**

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_08_automatisation/02_scripts_bash.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_08_automatisation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 8.2 scripts bash condensé (1462 lignes -> cible 250)"
```

---

### Task 23: Chapitre 8.3 — cron, alias et personnalisation

**Files:**
- Create: `supports/module_08_automatisation/03_cron_alias_personnalisation.md`
- Delete: `supports/module_08_automatisation/03_taches_programmees.md`, `supports/module_08_automatisation/04_alias_personnalisation.md`

- [ ] **Step 1: Lire les sources**

Lire `supports/module_08_automatisation/03_taches_programmees.md`,
`supports/module_08_automatisation/04_alias_personnalisation.md` et
`travaux_pratiques/tp08_automatisation/tp01_automatisation_complete.md`
(parties cron et alias).

- [ ] **Step 2: Écrire le chapitre**

En-tête : `# Chapitre 8.3 — cron, alias et personnalisation`.

Théorie :
- « Programmer une tâche » : `crontab -e`, syntaxe des 5 champs (schéma
  ASCII), `crontab -l`, deux exemples lus à voix haute (« tous les jours à
  8h », « toutes les 15 minutes »).
- « Les alias » : `alias ll='ls -la'`, voir ses alias, limite (session
  courante).
- « Rendre ça permanent : ~/.bashrc » : où ajouter ses alias et variables
  (lien avec chapitre 6.3), recharger avec `source ~/.bashrc`.

Pour aller plus loin : crontab système (`/etc/cron.d`), `anacron`, timers
systemd (mention), personnaliser son prompt PS1.

Exercices : recycler les parties cron/alias de
`tp08_automatisation/tp01_automatisation_complete.md` (programmer le script
de sauvegarde du 8.2, créer trois alias utiles et les rendre permanents),
avec solutions.

- [ ] **Step 3: Supprimer les sources consommées**

```bash
git -C /opt/github/formation_linux rm supports/module_08_automatisation/03_taches_programmees.md supports/module_08_automatisation/04_alias_personnalisation.md
```

- [ ] **Step 4: Vérifier**

Exécuter V1, V2, V3 avec
`F=supports/module_08_automatisation/03_cron_alias_personnalisation.md`.

- [ ] **Step 5: Commit**

```bash
git -C /opt/github/formation_linux add supports/module_08_automatisation/
git -C /opt/github/formation_linux commit -m "feat: chapitre 8.3 cron, alias et personnalisation (fusion 8.3+8.4)"
```

---

### Task 24: Suppression des TP du cours de base

**PRÉREQUIS :** les Tasks 1 à 23 sont terminées (les TP ont été recyclés
dans les sections Exercices).

**Files:**
- Delete: `travaux_pratiques/tp01_decouverte/`, `travaux_pratiques/tp01_installation/`, `travaux_pratiques/tp02_navigation/`, `travaux_pratiques/tp03_manipulation/`, `travaux_pratiques/tp04_consultation/`, `travaux_pratiques/tp05_droits/`, `travaux_pratiques/tp06_processus/`, `travaux_pratiques/tp07_reseaux/`, `travaux_pratiques/tp08_automatisation/`

- [ ] **Step 1: Vérifier que tous les chapitres ont une section Exercices**

```bash
for f in /opt/github/formation_linux/supports/module_0*/[0-9]*.md; do grep -L "^## Exercices$" "$f"; done
```
Attendu : aucune sortie (tous les chapitres ont la section).

- [ ] **Step 2: Supprimer les répertoires TP du cours de base**

```bash
git -C /opt/github/formation_linux rm -r travaux_pratiques/tp01_decouverte travaux_pratiques/tp01_installation travaux_pratiques/tp02_navigation travaux_pratiques/tp03_manipulation travaux_pratiques/tp04_consultation travaux_pratiques/tp05_droits travaux_pratiques/tp06_processus travaux_pratiques/tp07_reseaux travaux_pratiques/tp08_automatisation
```

- [ ] **Step 3: Vérifier que tp_additionnels est intact**

```bash
ls /opt/github/formation_linux/travaux_pratiques/
```
Attendu : seul `tp_additionnels` reste.

- [ ] **Step 4: Commit**

```bash
git -C /opt/github/formation_linux commit -m "chore: suppression des TP de base (recyclés dans les chapitres)"
```

---

### Task 25: Mise à jour du README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Lire le README actuel**

Lire `/opt/github/formation_linux/README.md` en entier.

- [ ] **Step 2: Mettre à jour**

- Remplacer le plan par la nouvelle liste des 22 chapitres (8 modules) et
  l'annexe installation.
- Remplacer la présentation des deux publics par le format unique : 6
  séances de 2h, prérequis « environnement installé » (lien vers l'annexe).
- Ajouter le tableau de correspondance séances/chapitres de la spec :

| Séance | Contenu |
|--------|---------|
| 1 | Module 1 + chap. 2.1 (découverte, terminal, arborescence) |
| 2 | Chap. 2.2-2.3 + 3.1-3.2 (navigation, manipulation, recherche) |
| 3 | Chap. 3.3 + Module 4 (archivage, lecture, édition, grep) |
| 4 | Module 5 + chap. 6.1 (droits, processus) |
| 5 | Chap. 6.2-6.3 + Module 7 (surveillance, environnement, réseau, services) |
| 6 | Module 8 + bilan (redirections, scripts, cron) |

- Expliquer la structure d'un chapitre (théorie en séance, « pour aller
  plus loin » et exercices en autonomie).
- Conserver les sections sur les modules additionnels Git/Docker et la
  génération PDF (avec une note : « génération en cours de refonte »).

- [ ] **Step 3: Vérifier**

```bash
grep -nP '[┌┐└┘├┤┬┴┼│─→←↑↓▶◀≠≤≥×÷√●✅❌⚠️📁🔧🔍✓✗🎯🚀]' /opt/github/formation_linux/README.md
```
Attendu : aucune sortie.

- [ ] **Step 4: Commit**

```bash
git -C /opt/github/formation_linux add README.md
git -C /opt/github/formation_linux commit -m "docs: README mis à jour (format 6x2h, 22 chapitres)"
```

---

### Task 26: Mise à jour du CLAUDE.md du projet

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Lire le CLAUDE.md actuel**

Lire `/opt/github/formation_linux/CLAUDE.md` en entier.

- [ ] **Step 2: Mettre à jour**

- Section « Environnement de travail » : conserver la description des deux
  environnements (VM SSH, VirtualBox/D:\) mais les rattacher au guide
  `supports/annexes/installation.md` ; supprimer les découpages « 2 séances
  de 4 heures » et « 25 séances de 1h30 ».
- Section « Plan de formation » : remplacer par la liste des 22 chapitres
  (mêmes intitulés que la spec) + annexe installation ; ajouter le format
  unique « 6 séances de 2h de théorie » et le tableau séances/chapitres.
- Supprimer la section « Adaptation par public » (les deux occurrences).
- Section « Structure des supports » : mettre à jour l'arbre des fichiers
  (nouveaux noms de chapitres, `supports/annexes/`, suppression des
  `travaux_pratiques/tp01-08`, conservation de `tp_additionnels/`).
- Décrire le template de chapitre en trois parties (théorie / L'essentiel /
  Pour aller plus loin / Exercices+Solutions) et la calibration (150-200
  lignes de théorie, max 250).
- Conserver telles quelles : les règles sur les caractères français/Unicode,
  les sections génération PDF et GitHub Actions (ajouter une note « à
  refondre : ne reflète plus la structure du contenu »).

- [ ] **Step 3: Vérifier**

Relire le CLAUDE.md modifié : plus aucune mention de « 2x4h », « 25x1h30 »,
« formation accélérée » ou « formation étalée » en dehors d'éventuelles
notes historiques.

```bash
grep -in "25 séances\|2 séances de 4\|accélérée\|étalée" /opt/github/formation_linux/CLAUDE.md
```
Attendu : aucune sortie.

- [ ] **Step 4: Commit**

```bash
git -C /opt/github/formation_linux add CLAUDE.md
git -C /opt/github/formation_linux commit -m "docs: CLAUDE.md aligné sur la refonte (format 6x2h, 22 chapitres)"
```

---

### Task 27: Vérification globale finale

- [ ] **Step 1: Compter les chapitres**

```bash
ls /opt/github/formation_linux/supports/module_0*/[0-9]*.md | wc -l
```
Attendu : `22`.

- [ ] **Step 2: Vérifier le volume total de théorie**

```bash
for f in /opt/github/formation_linux/supports/module_0*/[0-9]*.md; do awk "/^## L'essentiel/{print NR-1; exit}" "$f"; done | paste -sd+ - | bc
```
Attendu : entre 2 800 et 4 200 (cible 3 500).

- [ ] **Step 3: Vérifier structure et caractères sur tous les chapitres**

```bash
for f in /opt/github/formation_linux/supports/module_0*/[0-9]*.md; do
  n=$(grep -c "^## L'essentiel$\|^## Pour aller plus loin$\|^## Exercices$\|^### Solutions$" "$f")
  [ "$n" -ne 4 ] && echo "STRUCTURE KO: $f ($n/4)"
done
grep -rnP '[┌┐└┘├┤┬┴┼│─→←↑↓▶◀≠≤≥×÷√●✅❌⚠️📁🔧🔍✓✗🎯🚀]' /opt/github/formation_linux/supports/module_0* /opt/github/formation_linux/supports/annexes/ || echo "Caractères OK"
```
Attendu : aucune ligne `STRUCTURE KO`, et `Caractères OK`.

- [ ] **Step 4: Chasse aux redondances (revue manuelle rapide)**

Vérifier par sondage que les concepts fusionnés ne sont expliqués qu'une
fois (les autres occurrences sont des renvois) :

```bash
grep -rln "chmod" /opt/github/formation_linux/supports/module_0*/[0-9]*.md
grep -rln "grep -" /opt/github/formation_linux/supports/module_0*/[0-9]*.md
```
Les fichiers listés hors chapitre « propriétaire » du concept (5.2 pour
chmod, 4.3 pour grep) ne doivent contenir que des usages en exemple ou des
renvois, pas de réexplication. Corriger le cas échéant.

- [ ] **Step 5: Commit final éventuel et bilan**

S'il y a eu des corrections au Step 4 :
```bash
git -C /opt/github/formation_linux add -A
git -C /opt/github/formation_linux commit -m "fix: corrections de la passe de vérification globale"
```

Produire un bilan : nombre de lignes avant/après
(`git diff --stat master...refonte-contenu | tail -1`), liste des 22
chapitres avec leur volume de théorie.
