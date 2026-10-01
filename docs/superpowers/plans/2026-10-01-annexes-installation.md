# Annexes d'installation -- Plan d'implémentation

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers-extended-cc:subagent-driven-development to implement this plan task-by-task.

**Goal :** remplacer l'annexe unique par deux annexes autonomes (SSH,
VirtualBox), la seconde illustrée par des captures reproductibles, et
publier deux PDF.

**Spec :** `docs/superpowers/specs/2026-10-01-annexes-installation-design.md`
(versions, liens, SHA256, comptes, réglages de VM : s'y référer, ne pas
re-décider).

**Branche :** `annexes-installation`.

---

## Contexte technique (vérifié le 2026-10-01)

- Chaîne PDF : `./pdf/build` (tout), `./pdf/build pdf [X.pdf]`,
  `./pdf/build test [args]`, `./pdf/build check`, `./pdf/build shell CMD`.
  Tout Python/pandoc/LaTeX tourne dans l'image `formation-linux-pdf`
  (`pdf/Dockerfile`). Code : `pdf/generer.py` (importé `generer` dans les
  tests), catalogue `pdf/documents.yaml` (+ liste `ATTENDUS` dans
  `pdf/tests/test_documents.py`), préambule `pdf/preambule.tex`.
- Règles de contenu (CLAUDE.md) : accents préservés ; aucun caractère de
  boîte, flèche Unicode ni emoji ; un seul titre `#` par source ; aucun `--`
  hors code (test `pdf/tests/test_sources.py`).
- L'hôte a Docker et `/dev/kvm` (accès via `--device /dev/kvm`), 8 CPU,
  15 Go de RAM, ~56 Go libres. Les gros téléchargements vont dans
  `build/captures/cache/` (ignoré par git), jamais dans le dépôt.
- Commits : messages en français, terminés par
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` puis
  `Claude-Session: https://claude.ai/code/session_01JeyfNQCc5qMpWwPZKnFa93`.

---

### Task 1 : images dans la chaîne PDF

**Files :** `pdf/generer.py`, `pdf/preambule.tex`, `pdf/tests/`.

Exigences (TDD : test d'abord, échec constaté, puis code) :

1. Une image Markdown `![Légende](chemin.png)` dont le chemin est relatif au
   **fichier source** est trouvée (pandoc `--resource-path` construit à
   partir des dossiers des sources du document) et apparaît dans le PDF.
   Le `.tex` est compilé dans `build/pdf/debug/` : les chemins d'images
   doivent y être valides (piste : `--extract-media` vers
   `build/pdf/debug/<nom>-media`, à vérifier).
2. Une image introuvable fait échouer le build avec un message qui nomme
   l'image (piste : `--fail-if-warnings` si aucun autre avertissement
   pandoc n'est émis sur les 11 PDF actuels ; sinon, détection ciblée du
   message « Could not fetch resource »).
3. Mise en page : les images restent à leur place dans le texte (pas de
   flottant qui part à la page suivante : figure `H` ou équivalent), largeur
   maximale 75 % de la ligne, hauteur maximale ~45 % de la page, proportions
   conservées, légende sous l'image.
4. Tests : unitaire (commande pandoc) ; compilation réelle d'un petit
   document avec une image PNG générée dans `tmp_path` (le PDF contient une
   image : pypdf, `page.images` non vide) ; échec sur image manquante.
5. Les 11 PDF actuels se génèrent toujours, tests et `check` propres.

Commit : `feat: prise en charge des images dans la chaîne PDF`.

---

### Task 2 : captures de l'installeur Debian (QEMU/KVM)

**Files :** `outils/captures/debian/` (scripts, Dockerfile éventuel,
README court), `ressources/images/installation/debian-*.png`.

Exigences :

1. Télécharger `debian-13.7.0-amd64-DVD-1.iso` dans `build/captures/cache/`
   et **vérifier son SHA256** (spec) avant usage ; ne pas retélécharger s'il
   est présent et valide.
2. Lancer l'installeur sous QEMU/KVM dans un conteneur (`--device
   /dev/kvm`), sans affichage, avec un moniteur QMP. Disque qcow2 de 30 Go
   dans `build/captures/`, 4 Go de RAM, 2 CPU, résolution proche de celle
   d'une VM VirtualBox (1024x768 ou 1280x800 pour l'installeur).
3. Piloter l'**installation graphique** au clavier (QMP `send-key` /
   `human-monitor-command sendkey`), avec les réponses de la spec :
   français / France / clavier français ; nom de machine
   `debian-formation`, domaine vide ; mot de passe root `cid` ; utilisateur
   `cid` (nom complet `cid`), mot de passe `cid` ; fuseau horaire proposé ;
   partitionnement assisté, disque entier, tout dans une seule partition ;
   pas d'analyse d'autre support ; miroir réseau : **oui** si le réseau
   fonctionne (le DVD suffit, mais les mises à jour de sécurité sont
   utiles) ; enquête de popularité : non ; sélection des logiciels :
   environnement de bureau Debian + **GNOME** + **serveur SSH** +
   utilitaires usuels ; GRUB sur le disque principal ; fin.
4. Une capture PNG par écran significatif (`screendump`), prise une fois
   l'écran stabilisé (attendre que deux captures successives soient
   identiques, avec délai maximal), et quelques captures de progression
   (copie des fichiers, installation des logiciels). Puis le premier
   démarrage : écran GRUB, écran de connexion GNOME, bureau GNOME
   (et un terminal ouvert si c'est simple).
5. Noms stables et ordonnés, ex. `debian-01-menu-demarrage.png`,
   `debian-02-langue.png`... ; recadrage inutile (écran entier) ; PNG
   optimisés (taille totale raisonnable, < 10 Mo si possible).
6. Le script est **rejouable** de bout en bout (`outils/captures/debian/capturer.sh`)
   et robuste aux variations de durée (attentes par stabilisation d'écran,
   pas de `sleep` fixes seuls). Il produit aussi une liste
   `ressources/images/installation/debian-captures.txt` (fichier -> écran
   décrit), utile à la rédaction.
7. Regarder chaque PNG produit (outil Read) et vérifier qu'il montre l'écran
   attendu, en français, avec les bonnes valeurs saisies.

**Ne pas committer** (le coordinateur committe, d'autres tâches tournent en
parallèle) : laisser les fichiers dans l'arbre de travail.

---

### Task 3 : captures VirtualBox (Linux, Xvfb)

**Files :** `outils/captures/virtualbox/`, `ressources/images/installation/vbox-*.png`.

Exigences :

1. Conteneur Debian 13 avec VirtualBox **7.2.20** pour Linux (paquet officiel
   de virtualbox.org, version identique à la spec), Xvfb, un gestionnaire de
   fenêtres léger, `xdotool`, `imagemagick` ; interface en **français**
   (`LANG=fr_FR.UTF-8`). Le pilote noyau n'est pas nécessaire : on ne démarre
   aucune VM, on capture seulement les fenêtres.
2. Captures (fenêtre ou écran recadré sur la fenêtre utile) :
   - gestionnaire VirtualBox au premier lancement ;
   - Fichier > Paramètres > Extensions (ou Outils > Gestionnaire
     d'extensions) : installation de l'Extension Pack 7.2.20 (fichier
     téléchargé dans `build/captures/cache/`, SHA256 vérifié), écran de
     licence, résultat ;
   - assistant « Nouvelle machine virtuelle » : nom `FormationLinux`,
     dossier `D:\PrenomNOM\VirtualBox` saisi, image ISO
     `D:\PrenomNOM\sources\debian-13.7.0-amd64-DVD-1.iso` si l'assistant
     l'accepte (sinon un chemin Linux équivalent et une note pour la
     rédaction), case « ignorer l'installation sans surveillance » cochée ;
     matériel 4096 Mo / 2 CPU ; disque 30 Go VDI dynamique ; récapitulatif ;
   - Configuration > Réseau : mode **Accès par pont** ;
   - Configuration > Système > Processeur (2 CPU) si utile.
3. Pilotage reproductible (`outils/captures/virtualbox/capturer.sh`) ; noms
   ordonnés `vbox-01-...png` ; liste `vbox-captures.txt`.
4. Si l'interface refuse de démarrer sans pilote ou si une étape est
   impossible, le dire précisément dans le rapport (ce qui manque, pourquoi)
   plutôt que de contourner par des images retouchées.
5. Regarder chaque PNG (outil Read).

**Ne pas committer** : laisser les fichiers dans l'arbre de travail.

---

### Task 4 : script `installer_virtualbox.bat`

**Files :** `ressources/scripts/installer_virtualbox.bat`.

Exigences :

1. Fichier batch Windows (fins de ligne CRLF, encodage compatible
   `cmd.exe` : messages sans accents ou `chcp 65001` en tête), commenté
   en français.
2. Travaille depuis son propre dossier (`%~dp0`), qui est
   `D:\PrenomNOM\sources\` ; en déduit `D:\PrenomNOM\VirtualBox\`.
3. Se lance par double-clic, sans droits administrateur : chaque
   installeur est lancé par `start /wait` et demande lui-même
   l'autorisation ; VBoxManage tourne avec le compte du stagiaire. Plus de
   blocage `net session` : s'il est lancé en administrateur, simple
   avertissement non bloquant (un autre compte réglerait le mauvais
   profil).
4. Trouve par motif `VC_redist.x64.exe`, `VirtualBox-*-Win.exe`,
   `Oracle_VirtualBox_Extension_Pack-*.vbox-extpack` ; s'arrête avec un
   message clair si l'un manque.
5. Installe en silencieux : VC++ (`/install /quiet /norestart`),
   VirtualBox (`--silent --ignore-reboot`), Extension Pack
   (`VBoxManage extpack install --replace --accept-license=<hash>` : le
   hash de licence de la 7.2.20 est **relevé réellement** lors de la Task 3
   via `VBoxManage extpack install` sur Linux et reporté ici).
6. Règle le dossier des machines (`VBoxManage setproperty machinefolder`)
   et réenregistre `FormationLinux.vbox` s'il existe (sans erreur s'il est
   déjà enregistré ou absent, avec message).
7. Vérifie chaque code retour, affiche un résumé, `pause` final.
8. Contrôle statique : pas d'outil d'exécution Windows ici ; relecture
   attentive + au moins une vérification syntaxique raisonnable (ex.
   `wine cmd /c` si disponible dans un conteneur, sinon noter « non
   exécuté » dans le rapport).

Commit : `feat: script de réinstallation de VirtualBox pour les postes figés`.

---

### Task 5 : `installation_ssh.md`

**Files :** `cours_2026/annexes/installation_ssh.md`.

Reprendre l'option A de l'annexe actuelle (`installation.md`) en document
autonome : titre `# Annexe — Se connecter à sa VM distante (SSH)`,
introduction, prérequis, PuTTY, OpenSSH, vérification, premiers réglages,
problèmes courants. Pas de nouveaux faits inventés. Commit avec la Task 7.

---

### Task 6 : `installation_virtualbox.md`

**Files :** `cours_2026/annexes/installation_virtualbox.md`.

Document autonome, titre `# Annexe — Installer Debian 13 dans VirtualBox`,
suivant la spec point par point :

1. Introduction : poste du CID figé sur `C:`, `D:\` persistant ; ce qui est
   fait une seule fois, ce qui est refait à chaque séance.
2. Prérequis matériels.
3. Arborescence `D:\PrenomNOM\sources\` et `D:\PrenomNOM\VirtualBox\`.
4. Tableau des téléchargements (lien, version, taille), puis SHA256 et
   vérification (`certutil -hashfile fichier SHA256`). Lien d'index Debian
   pour la dernière 13.x. Où récupérer `installer_virtualbox.bat` (lien
   brut GitHub vers `ressources/scripts/installer_virtualbox.bat`) et son
   contenu intégral en bloc de code.
5. Première séance : installation de VC++, VirtualBox, Extension Pack
   (texte ; captures `vbox-*` de l'Extension Pack) ; création de la VM
   (captures de l'assistant ; réglages de la spec ; réseau **par pont**) ;
   installation de Debian (une capture par étape, réponses de la spec,
   explications courtes de chaque choix) ; premier démarrage ; ajout de
   `cid` au groupe `sudo` (`su -` puis `usermod -aG sudo cid`, déconnexion)
   ; mise à jour ; Additions invité (prérequis `build-essential` et en-têtes
   du noyau, insertion du CD, `sh VBoxLinuxAdditions.run`, redémarrage).
6. Séances suivantes : script `.bat` (double-clic ; répondre Oui si
   Windows demande une autorisation), puis démarrer la
   VM ; procédure manuelle de secours ; « Ajouter » (pas « Nouvelle ») si
   la VM n'apparaît pas.
7. Vérifier que tout fonctionne (commandes) ; accès SSH depuis Windows à
   la VM (grâce au mode pont : `ip a` pour l'adresse, `ssh cid@ADRESSE`).
8. Problèmes courants : VC++ manquant, VT-x, pont sans réseau (choisir la
   bonne carte), VM lente, VM introuvable après le freeze, clavier QWERTY.
9. Légendes de figures courtes ; chemins d'images relatifs
   (`../../ressources/images/installation/...`).
10. Respect des règles de contenu (test `test_sources.py`, un seul `#`).

### Task 7 : catalogue, références, suppression de l'ancienne annexe

**Files :** `pdf/documents.yaml`, `pdf/tests/test_documents.py`,
`cours_2026/annexes/installation.md` (suppression), `CLAUDE.md`,
`README.md`, `CONTRIBUTING.md` si concerné.

- `annexe_installation.pdf` -> `annexe_installation_ssh.pdf` (sous-titre
  « Annexe ») et `annexe_installation_virtualbox.pdf` ; `ATTENDUS` à 12.
- Supprimer `installation.md` (git mv vers l'un des deux si pertinent pour
  l'historique).
- Mettre à jour toutes les références (`grep -rn "installation.md\|annexe_installation"`
  hors `archives/` et `docs/superpowers/`), y compris CLAUDE.md (section
  Environnement de travail, arborescence) et README.
- Commit : `feat: deux annexes d'installation (SSH, VirtualBox illustrée)`.

### Task 8 : vérification et livraison

- `./pdf/build check && ./pdf/build` : 12 PDF, tests verts.
- Revue visuelle du PDF VirtualBox (toutes les pages) et du PDF SSH.
- Commit des captures et scripts de capture (Tasks 2 et 3) en commits
  séparés : `feat: captures de l'installeur Debian 13.7`,
  `feat: captures de l'assistant VirtualBox 7.2.20`.
- PR vers `master`, CI verte, fusion et tag sur accord de l'utilisateur.
