# Refonte du contenu de la formation Linux — Design

Date : 2026-06-11
Statut : validé

## Contexte et objectif

Les supports actuels des modules de base (1 à 8) totalisent environ 18 800 lignes
réparties sur 33 chapitres, dans un style « manuel de référence » : chaque commande
déroule l'ensemble de ses options, avec de nombreuses redondances entre chapitres
(grep traité en 3.3, 4.3 et 8.1 ; permissions traitées en 5.2, 5.3 et 5.5 ; etc.).

Objectif : le cours théorique de base doit tenir sur **6 séances de 2 heures**
(une fois l'environnement installé). Chaque chapitre est restructuré en trois
parties : théorie courte, approfondissement optionnel, exercices à faire chez soi.

## Décisions de cadrage

1. **Format unique** : les deux formats actuels (accéléré 2×4h et étalé 25×1h30)
   sont remplacés par un format unique de 6 séances de 2h. Les sections
   « Pour aller plus loin » et les exercices maison absorbent les différences
   de rythme entre publics.
2. **Un fichier par chapitre** contenant les trois parties (théorie /
   pour aller plus loin / exercices). Le répertoire `travaux_pratiques/`
   disparaît pour le cours de base.
3. **Modules additionnels Git et Docker non touchés** dans cette passe.
4. **Solutions des exercices incluses** dans le même fichier, dans une
   sous-section « Solutions » après les énoncés.
5. **Approche structurelle** : squelette des 8 modules conservé, chapitres
   redondants fusionnés (33 → 22 chapitres). Le découpage suit les concepts,
   pas le nombre de séances ; un tableau de correspondance séance ↔ chapitres
   est fourni à titre indicatif.
6. **Génération PDF hors périmètre** : les scripts et workflows de génération
   seront revus dans un second temps. Ils casseront probablement entre-temps,
   c'est assumé.

## Nouvelle structure des chapitres (22 chapitres)

### Module 1 — Découverte (2 chapitres)
- 1.1 Linux : histoire, philosophie et distributions *(fusion des actuels 1.1 + 1.2)*
- 1.2 Premier contact avec le terminal *(actuel 1.4)*
- L'actuel `03_installation.md` sort des séances : il devient un **guide
  d'installation en annexe** dans `supports/annexes/installation.md`
  (prérequis « environnement installé »), couvrant les deux environnements
  possibles (VM distante via SSH, VM VirtualBox Debian).

### Module 2 — Navigation (3 chapitres)
- 2.1 L'arborescence et les chemins *(fusion actuels 2.1 + 2.3 : arborescence
  et chemins absolus/relatifs sont indissociables)*
- 2.2 Se déplacer et explorer (ls, cd, pwd) *(actuel 2.2)*
- 2.3 Types de fichiers et liens *(actuel 2.4)*

### Module 3 — Manipulation (3 chapitres)
- 3.1 Créer, copier, déplacer, supprimer *(fusion actuels 3.1 + 3.2)*
- 3.2 Rechercher des fichiers (find, locate, which) *(actuel 3.3)*
- 3.3 Archiver et compresser (tar, gzip, zip) *(actuel 3.4)*

### Module 4 — Consultation et édition (3 chapitres)
- 4.1 Lire des fichiers (cat, less, head, tail) *(actuel 4.1)*
- 4.2 Éditer avec nano *(actuel 4.2 ; vim relégué en « pour aller plus loin »)*
- 4.3 Chercher dans les fichiers et comparer *(fusion actuels 4.3 + 4.4 :
  grep + diff)*

### Module 5 — Droits (3 chapitres)
- 5.1 Utilisateurs et groupes *(actuel 5.1)*
- 5.2 Permissions (chmod, chown) *(fusion actuels 5.2 + 5.3 ; setuid/setgid/
  sticky bit/ACL en « pour aller plus loin »)*
- 5.3 sudo et bonnes pratiques de sécurité *(actuel 5.4)*
- L'actuel 5.5 « processus et propriétaires » fusionne dans le chapitre 6.1.

### Module 6 — Processus et système (3 chapitres)
- 6.1 Les processus : observer et contrôler *(fusion actuels 6.1 + 6.2 + 5.5 :
  ps, top, kill, propriétaires des processus, jobs et arrière-plan ;
  nohup et cas avancés en « pour aller plus loin »)*
- 6.2 Surveillance système (df, du, free, uptime) *(actuel 6.3)*
- 6.3 Variables d'environnement et historique *(actuel 6.4)*

### Module 7 — Réseau et services (2 chapitres)
- 7.1 Réseau et transferts *(fusion actuels 7.1 + 7.2 : ip, ping, curl/wget +
  scp, rsync)*
- 7.2 Services et logs *(fusion actuels 7.3 + 7.4 : systemctl + journalctl,
  /var/log)*

### Module 8 — Automatisation (3 chapitres)
- 8.1 Redirections et pipes *(actuel 8.1)*
- 8.2 Scripts bash : les bases *(actuel 8.2, à réduire massivement :
  1 462 lignes aujourd'hui)*
- 8.3 cron, alias et personnalisation *(fusion actuels 8.3 + 8.4)*

## Correspondance séances ↔ chapitres (indicatif, dans le README)

| Séance | Contenu |
|--------|---------|
| 1 | Module 1 + chap. 2.1 (découverte, terminal, arborescence) |
| 2 | Chap. 2.2-2.3 + 3.1-3.2 (navigation, manipulation, recherche) |
| 3 | Chap. 3.3 + Module 4 (archivage, lecture, édition, grep) |
| 4 | Module 5 + chap. 6.1 (droits, processus) |
| 5 | Chap. 6.2-6.3 + Module 7 (surveillance, environnement, réseau, services) |
| 6 | Module 8 + bilan (redirections, scripts, cron) |

## Template de chapitre

Chaque chapitre est un fichier `.md` unique avec cette structure :

```markdown
# Chapitre X.Y — Titre

> **Objectifs** : ce que le stagiaire saura faire à la fin.
> **Durée en séance** : ~30 min (indicatif).

## (Sections de théorie)
Le cœur du cours : concepts + commandes essentielles, exemples concrets
et courts. Pas de catalogue d'options.

## L'essentiel
Mémo de fin de chapitre : tableau récapitulatif des commandes vues
avec leur usage type.

## Pour aller plus loin
Options avancées, cas particuliers, outils alternatifs. Lecture
optionnelle, hors séance.

## Exercices
Exercices progressifs à faire chez soi, recyclés depuis les TP actuels.

### Solutions
Solutions détaillées des exercices ci-dessus.
```

## Calibration de la partie théorique

- ~30 minutes de séance par chapitre en moyenne (22 chapitres ≈ 11h,
  marge pour questions et bilan).
- ~150-200 lignes de markdown par partie théorique.
- Total théorie visé : ≈ 3 500 lignes (contre ≈ 18 800 aujourd'hui).
- **Règle de réécriture** : la théorie montre la commande, ses 2-3 options
  vitales et un exemple concret. Tout le reste descend en « Pour aller
  plus loin » ou disparaît.

## Nettoyage associé

- `travaux_pratiques/tp01_*` à `tp08_*` : la matière utile est recyclée dans
  les sections Exercices des chapitres, puis les répertoires sont supprimés.
  `travaux_pratiques/tp_additionnels/` (Git, Docker) est conservé.
- `CLAUDE.md` du projet : mis à jour avec le nouveau plan (22 chapitres),
  le format unique 6×2h, la nouvelle structure de fichiers ; suppression
  des deux découpages par public. Les descriptions d'environnement
  (VM SSH / VirtualBox) sont conservées et rattachées au guide
  d'installation en annexe.
- `README.md` : mis à jour avec le nouveau plan et le tableau des séances.
- `evaluations/`, `ressources/`, `supports/modules_additionnels/` : non
  touchés.
- Scripts `scripts/` et workflows GitHub Actions : non touchés dans cette
  passe (refonte de la génération prévue dans un second temps).

## Critères de réussite

1. 22 fichiers de chapitres conformes au template, plus le guide
   d'installation en annexe.
2. Chaque partie théorique tient dans sa cible (~150-200 lignes) ; total
   théorie ≈ 3 500 lignes.
3. Plus aucune redondance structurelle : chaque concept n'est traité en
   théorie que dans un seul chapitre (les rappels renvoient au chapitre
   concerné).
4. Chaque chapitre contient des exercices avec solutions.
5. Les accents français sont préservés et aucun caractère Unicode
   problématique (dessins de boîtes, flèches, emojis) n'est introduit,
   conformément aux règles du projet.
6. README et CLAUDE.md reflètent la nouvelle organisation.
