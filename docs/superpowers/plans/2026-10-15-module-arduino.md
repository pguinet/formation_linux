# Module additionnel Arduino Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers-extended-cc:executing-plans to implement this plan task-by-task.

**Goal:** Rédiger le module additionnel Arduino (6 chapitres) basé sur le projet
`DS18B20_MQTT`, et l'intégrer à la chaîne PDF.

**Architecture:** Six fichiers Markdown dans
`supports/modules_additionnels/module_arduino/`, un PDF
`module_additionnel_arduino.pdf` déclaré dans `pdf/documents.yaml`. Le code
n'est pas copié : il est cité depuis https://github.com/pguinet/arduino, au
commit figé `1af068f` (dossier `sketches/XIAO-ESP32-S3/DS18B20_MQTT`).

**Tech Stack:** Markdown (pandoc, LuaLaTeX via `./pdf/build`), PlatformIO 6.1.19
(`~/.platformio/penv/bin/pio`) pour vérifier les commandes citées.

**Spécification:** `docs/superpowers/specs/2026-10-15-module-arduino-design.md`
(à lire en entier avant toute tâche).

---

## Règles communes à toutes les tâches de rédaction

- **Source du code** : `~/github/arduino/sketches/XIAO-ESP32-S3/DS18B20_MQTT`
  (lire les fichiers réels, ne jamais inventer un extrait). CI :
  `~/github/arduino/.github/workflows/ci.yml`. Liens publics de la forme
  `https://github.com/pguinet/arduino/blob/1af068f/sketches/XIAO-ESP32-S3/DS18B20_MQTT/<chemin>`.
- **Template** : celui de `CLAUDE.md` (titre `# Arduino N — Titre`, bloc
  `> **Objectifs**` / `> **Durée de lecture**`, sections, `## L'essentiel`,
  `## Pour aller plus loin`, `## Exercices`, `### Solutions`). Exactement un
  titre `#` par fichier. Modèle de style : `supports/modules_additionnels/module_git_windows/01_concepts_git.md`.
- **Public** : connaît Arduino par l'IDE officiel et les `.ino`, pas
  PlatformIO, pas les tests, pas la CI. Lecture personnelle, hors séance :
  vouvoiement, ton de cours, pas de référence au CID ni à VirtualBox.
- **Sans carte** : chaque exercice indique s'il demande la carte ; la majorité
  doit s'en passer.
- **Caractères** : accents préservés ; pas de dessin de boîtes, pas de flèches
  Unicode (`->`), pas d'emojis, pas de `°` hors texte courant si la police
  le refuse (vérifié par `./pdf/build`). Les commentaires du code cité sont en
  ASCII dans le dépôt source : les citer tels quels.
- **Non-répétition** : chaque notion n'est expliquée qu'une fois ; ailleurs,
  `(voir chapitre Arduino N)`. Git/GitHub : `(voir module additionnel Git)`.
- **Vérification d'une commande** : toute commande `pio` citée avec sa sortie
  est rejouée dans le projet source et la sortie recopiée réellement.
- **Longueur** : théorie 150 à 250 lignes (chap. 4 et 6 jusqu'à ~300 car ils
  citent du code), `Pour aller plus loin` ~100 lignes max, 3 à 6 exercices.

---

### Task 0: Catalogue PDF et squelettes

**Files:**
- Modify: `pdf/documents.yaml` (après l'entrée `module_additionnel_docker.pdf`)
- Modify: `pdf/tests/test_documents.py` (`ATTENDUS`, après `"module_additionnel_docker.pdf"`)
- Create: les 6 fichiers de `supports/modules_additionnels/module_arduino/`

**Step 1: Ajouter le nom attendu (test qui échoue)**

Dans `ATTENDUS`, insérer `"module_additionnel_arduino.pdf",` juste après
`"module_additionnel_docker.pdf",`.

**Step 2: Lancer les tests**

Run: `./pdf/build test`
Expected: FAIL sur `test_catalogue...` (liste différente).

**Step 3: Déclarer le document et créer les squelettes**

Dans `pdf/documents.yaml`, après le bloc Docker (même indentation) :

```yaml
  - fichier: module_additionnel_arduino.pdf
    titre: "Arduino : du sketch à l'intégration continue"
    sous_titre: Module additionnel
    sources:
      - supports/modules_additionnels/module_arduino/01_arduino_xiao_esp32s3.md
      - supports/modules_additionnels/module_arduino/02_ide_vers_platformio.md
      - supports/modules_additionnels/module_arduino/03_mqtt_home_assistant.md
      - supports/modules_additionnels/module_arduino/04_lecture_code.md
      - supports/modules_additionnels/module_arduino/05_tests_unitaires.md
      - supports/modules_additionnels/module_arduino/06_qualite_integration_continue.md
```

Chaque squelette contient seulement son titre `#` et le bloc objectifs :
`# Arduino 1 — De l'Arduino à la XIAO ESP32-S3`,
`# Arduino 2 — De l'IDE Arduino à PlatformIO`,
`# Arduino 3 — MQTT et Home Assistant`,
`# Arduino 4 — Lecture du code`,
`# Arduino 5 — Les tests unitaires`,
`# Arduino 6 — Qualité et intégration continue`.

**Step 4: Lancer tests et PDF**

Run: `./pdf/build test && ./pdf/build pdf module_additionnel_arduino.pdf`
Expected: PASS, `build/pdf/module_additionnel_arduino.pdf` existe.

**Step 5: Commit**

```bash
git add pdf/ supports/modules_additionnels/module_arduino/
git commit -m "feat: squelette du module additionnel Arduino"
```

---

### Task 1: Chapitre Arduino 1 — De l'Arduino à la XIAO ESP32-S3

**Files:** Modify: `supports/modules_additionnels/module_arduino/01_arduino_xiao_esp32s3.md`

**Contenu attendu (sections):**
1. Introduction du module : à qui il s'adresse, ce qu'on va construire
   (sonde -> carte -> WiFi -> broker MQTT -> Home Assistant, en ASCII), ce
   qu'on peut faire **sans carte** (tests, compilation, cppcheck, CI) et ce qui
   demande la carte (flasher, moniteur, MQTT réel). Prérequis : IDE Arduino,
   module Git. Lien vers le dépôt au commit `1af068f`.
2. Arduino, c'est trois choses : des cartes, un framework (`setup`/`loop`,
   `digitalWrite`, `Serial`...), un IDE. Le framework existe sur bien d'autres
   puces que l'AVR (ESP32 via le « core » d'Espressif).
3. L'ESP32-S3 : double cœur, WiFi + Bluetooth LE, USB natif ; comparaison
   rapide avec un Uno (tableau : fréquence, RAM, flash, WiFi, tension 3,3 V).
4. Seeed Studio et la XIAO ESP32-S3 : format timbre-poste, broches `D0`...,
   antenne U.FL **obligatoire** (symptôme `WiFi toujours absent (statut 1)`),
   USB natif : port `/dev/ttyACM0` sous Linux, `COMx` sous Windows,
   identifiant `303a:1001` commun à toutes les ESP32-S3.
5. La sonde DS18B20 et le bus 1-Wire : trois fils, adresse unique, résolution
   12 bits (750 ms), valeurs spéciales -127 et 85 (annoncer, détaillées au
   chapitre 4). Résistance de tirage : pull-up interne ~45 kΩ, 4,7 kΩ externe
   pour un câble long. Tableau de câblage du README et schéma ASCII.
6. Aperçu du projet : arborescence du dossier (sortie de `find` hors `.pio`,
   commentée), rôle de chaque partie, plan des chapitres suivants.

**Exercices (3-4)** : identifier le port d'une carte branchée (`ls /dev/ttyACM*`,
`lsusb`), carte avec carte ; lire le tableau de câblage et dire ce qui se passe
sans pull-up ; associer chaque fichier du projet à son rôle ; cloner le dépôt
et se placer au commit `1af068f` (`git switch --detach 1af068f`).

**Verify:** `./pdf/build pdf module_additionnel_arduino.pdf` passe ; relire
le chapitre contre la checklist des règles communes.

**Commit:** `git commit -m "docs: chapitre Arduino 1 (Arduino, XIAO ESP32-S3, DS18B20)"`

---

### Task 2: Chapitre Arduino 2 — De l'IDE Arduino à PlatformIO

**Files:** Modify: `.../02_ide_vers_platformio.md`

**Contenu attendu:**
1. Ce que l'IDE fait sans le dire : un `.ino` est concaténé en `.cpp`,
   `#include <Arduino.h>` ajouté, prototypes générés (montrer un `.ino` qui
   compile et le même fichier `.cpp` qui échoue faute de prototype), bibliothèques
   installées globalement sans version, carte choisie dans un menu (rien dans
   le projet). Conséquence : projet non reproductible sur une autre machine ni
   en CI.
2. PlatformIO : outil en ligne de commande (`pio`) + extension VS Code ; il
   télécharge lui-même plateformes, chaînes de compilation et bibliothèques.
   Installation : extension VS Code (recommandée) ou `pipx install platformio`.
   Sous Linux, règles udev (`99-platformio-udev.rules`) et groupe `dialout`
   (renvoi au module 5 du cours pour les groupes).
3. Arborescence d'un projet : `platformio.ini`, `src/`, `lib/`, `include/`,
   `test/`, `.pio/` (à ignorer dans Git).
4. `platformio.ini` du projet cité en entier puis commenté ligne par ligne :
   `[platformio] default_envs`, `[env:xiao]` (`platform` pioarduino figée par
   URL de version, `board`, `framework`, ports, `monitor_speed`, `lib_deps` avec
   `^` et sens du caret), `check_*` (annoncé, détaillé chap. 6),
   `[env:native]` (annoncé, détaillé chap. 5).
5. Les commandes : `pio run -e xiao`, `pio run -e xiao -t upload`,
   `pio device monitor`, `pio run -t clean`, `pio pkg list`. Équivalents
   boutons VS Code. Sortie réelle de `pio run -e xiao` (tableau RAM/Flash)
   recopiée après exécution dans le projet source (avec `src/credentials.h`
   présent).
6. Les bibliothèques : `lib_deps` (registre PlatformIO, `auteur/nom@version`)
   et `lib/` (bibliothèques locales du projet : `temp_logic`).

**Exercices** : créer un projet vide `pio project init --board seeed_xiao_esp32s3`
et y porter un « Blink » (prototype à ajouter) ; ajouter `ArduinoJson` en
`lib_deps` et compiler ; expliquer `^2.3.8` (quelles versions acceptées) ;
lister les environnements du projet et ce que fait `pio run` sans `-e`.

**Verify:** rejouer chaque commande citée (sans upload) ; `./pdf/build pdf module_additionnel_arduino.pdf`.

**Commit:** `git commit -m "docs: chapitre Arduino 2 (de l'IDE à PlatformIO)"`

---

### Task 3: Chapitre Arduino 3 — MQTT et Home Assistant

**Files:** Modify: `.../03_mqtt_home_assistant.md`

**Contenu attendu:**
1. Le besoin : un capteur publie, plusieurs consommateurs lisent, sans se
   connaître. Modèle publication/abonnement, schéma ASCII broker au centre.
2. Vocabulaire : broker (Mosquitto), client, sujet (`a/b/c`, jokers `+` et `#`),
   message, QoS 0/1/2 en bref (le projet publie en QoS 0), session.
3. Messages retenus : le dernier message d'un sujet est remis à tout nouvel
   abonné ; usage pour la découverte et la disponibilité, pas pour la mesure.
4. Testament (Last Will) : `status` passe à `offline` si la carte disparaît.
   Citer l'appel `mqtt.connect(deviceId, MQTT_USER, MQTT_PASS, topics.status, 0, true, "offline")`
   et le décoder argument par argument.
5. Home Assistant et MQTT Discovery : HA écoute `homeassistant/#` ; un message
   retenu sur `homeassistant/sensor/<id>/temperature/config` crée le capteur.
   Montrer le JSON produit par `buildDiscovery` (le reconstituer à partir de
   `lib/temp_logic/ha_discovery.cpp` et `test/test_discovery/test_main.cpp`,
   indenté), expliquer `availability`, `availability_mode: all`,
   `device_class`, `unit_of_measurement`, `unique_id`. Redémarrage de HA :
   `homeassistant/status` = `online` -> republication.
6. Tableau des sujets du projet (repris du README).
7. Encadré « Et en vrai ? » : broker et HA pourront tourner sur le futur
   homelab du club (renvoi au module Docker). En attendant, `mosquitto_sub -v -t 'xiao_ds18b20/#'`
   sur n'importe quel broker.

**Exercices** : prédire ce que voit un abonné arrivant après coup sur chaque
sujet (retenu ou non) ; écrire le filtre pour toutes les températures de
toutes les sondes ; expliquer pourquoi la mesure n'est pas retenue ; (option
avec Docker) lancer `eclipse-mosquitto` et publier/lire à la main avec
`mosquitto_pub`/`mosquitto_sub` en simulant la carte.

**Verify:** l'extrait JSON correspond exactement à ce que vérifie `test_discovery` ;
`./pdf/build pdf module_additionnel_arduino.pdf`.

**Commit:** `git commit -m "docs: chapitre Arduino 3 (MQTT et Home Assistant)"`

---

### Task 4: Chapitre Arduino 4 — Lecture du code

**Files:** Modify: `.../04_lecture_code.md`

**Contenu attendu:**
1. L'architecture : pourquoi deux couches. `src/main.cpp` dépend du matériel
   (WiFi, OneWire, PubSubClient) ; `lib/temp_logic` n'inclut que
   `<stdint.h>`/`<stddef.h>` (+ ArduinoJson, qui compile aussi sur PC) et se
   teste sur PC. Schéma ASCII des dépendances. Le namespace `temp`.
2. Les secrets : `#include "credentials.h"`, fichier hors dépôt (`.gitignore`),
   modèle `credentials.h.example`, garde-fous `#ifndef WIFI_SSID / #error`.
3. `setup()` : pull-up, `setWaitForConversion(false)`, MAC lue dans l'eFuse et
   pourquoi (`WiFi.macAddress()` renvoie des zéros avant démarrage),
   `makeDeviceId`, `WiFi.begin` non bloquant, réglages PubSubClient
   (`setBufferSize(1024)` car la découverte dépasse 256 octets).
4. La boucle non bloquante : `loop()` = trois `handle*()` + `delay(10)`. Le
   motif `if (millis() - last < INTERVAL) return;`, et pourquoi la soustraction
   non signée survit au débordement de `millis()` (~49,7 jours ; exemple
   chiffré). Comparer avec un sketch « IDE » à base de `delay(10000)`.
5. `handleSensor()` : machine à deux états (`converting`), conversion
   asynchrone 750 ms. `isValidReading` : -127, plage -55..125, 85 sauf si la
   précédente > 75 (citer l'implémentation de `temp_logic.cpp`).
6. `PublishPolicy` (écart >= 0,2 °C ou 5 min, `reset()` à la reconnexion) et
   `ProbeHealth` (3 échecs -> hors ligne) : interface du `.h` citée, choix
   « dixièmes entiers » (`toTenths`) pour éviter de comparer des `float`.
7. WiFi et MQTT : reconnexion du core + relance toutes les 30 s ; MQTT réessayé
   5 s après la fin de la tentative précédente (`lastAttempt = 0 - RETRY_INTERVAL_MS`
   pour une première tentative immédiate) ; callback `onMqttMessage`.

**Exercices** : transformer un sketch bloquant (`delay`) donné en version
`millis()` ; calculer `millis() - last` juste après le débordement (valeurs
données) ; dire ce que fait `isValidReading` pour une liste d'entrées ;
justifier pourquoi `PublishPolicy` est dans `lib/` et `handleWifi` dans `src/`.

**Verify:** chaque extrait cité est identique au fichier au commit `1af068f`
(`git -C ~/github/arduino show 1af068f:sketches/XIAO-ESP32-S3/DS18B20_MQTT/<f>`) ;
`./pdf/build pdf module_additionnel_arduino.pdf`.

**Commit:** `git commit -m "docs: chapitre Arduino 4 (lecture du code)"`

---

### Task 5: Chapitre Arduino 5 — Les tests unitaires

**Files:** Modify: `.../05_tests_unitaires.md`

**Contenu attendu:**
1. Pourquoi tester : bugs d'arrondi, cas limites (85 °C, débordement), régressions ;
   tester sur la carte est lent et ne couvre pas les cas rares.
2. Tester sur le PC : `[env:native]` (`platform = native`, `-std=c++17 -Wall -Wextra`,
   ArduinoJson seul). Possible grâce à la séparation du chapitre 4. Ce qu'on ne
   teste pas ainsi (le matériel) et ce qu'on y gagne.
3. Unity : `#include <unity.h>`, `setUp`/`tearDown`, `TEST_ASSERT_TRUE`,
   `TEST_ASSERT_EQUAL_INT`, `TEST_ASSERT_EQUAL_STRING`, `UNITY_BEGIN`,
   `RUN_TEST`, `UNITY_END`. Une suite = un dossier `test/test_xxx/`.
4. Lecture détaillée de `test/test_reading/test_main.cpp` (citer en entier ou
   l'essentiel), noms de tests comme documentation.
5. Lancer : `pio test -e native` (sortie réelle, 24 tests), `-f test_reading`,
   `-v`. Lire un échec : casser `toTenths` (ex. troncature au lieu d'arrondi),
   recopier la sortie réelle de l'échec, puis annuler (`git restore`).
6. Écrire un test : démarche (cas nominal, limites, erreurs), exemple guidé
   d'ajout dans `test_publish` (heartbeat exactement à 300000 ms).

**Exercices** : ajouter un test 85 °C après 80 °C (accepté) et après 20 °C
(rejeté) ; ajouter un test `formatTenths(-5)` -> `"-0.5"` ; casser
volontairement `ProbeHealth::record` et identifier le test qui échoue ;
proposer un cas non couvert par les 24 tests actuels.

**Verify:** chaque test d'exercice compilé et exécuté dans une copie de travail
du dépôt `arduino` (puis annulé) ; sorties recopiées réelles ;
`./pdf/build pdf module_additionnel_arduino.pdf`.

**Commit:** `git commit -m "docs: chapitre Arduino 5 (tests unitaires)"`

---

### Task 6: Chapitre Arduino 6 — Qualité et intégration continue

**Files:** Modify: `.../06_qualite_integration_continue.md`

**Contenu attendu:**
1. L'analyse statique : ce que voit cppcheck sans exécuter le code. `check_tool`,
   `check_flags` (`--enable=warning,style,performance`, `--inline-suppr`,
   exclusion de `.pio`), `check_src_filters`. `pio check -e xiao --skip-packages`
   (sortie réelle). Suppression en ligne justifiée : `constParameterCallback`
   dans `main.cpp`.
2. L'intégration continue : principe (chaque push vérifié sur une machine
   neuve), GitHub Actions : workflow, job, step, runner, action (`uses:`).
3. `ci.yml` cité en entier puis décortiqué : `on` (push sur `main`, PR),
   `permissions: contents: read`, job `discover` (grep des `[env:native]`,
   `jq`, `outputs`), job `platformio` (`needs`, `matrix` dynamique via
   `fromJSON`, `fail-fast: false`, `working-directory`), cache `~/.platformio`
   indexé sur `platformio.ini`, PlatformIO figé `==6.1.19`, `credentials.h`
   factice, tests, détection de l'environnement par `configparser`,
   compilation, cppcheck `--fail-on-defect=low`. Ne pas détailler le job
   `claude-dash-agent` (une phrase : autre projet du dépôt).
4. Lire un résultat : onglet Actions, statut sur la PR, logs d'un step.
5. Synthèse : la chaîne complète du développeur (éditer -> `pio test` ->
   `pio check` -> commit -> push -> CI -> fusion).

**Pour aller plus loin** : badge de statut dans le README, protection de
branche exigeant la CI, `act` pour lancer un workflow en local, tests sur
cible (`pio test -e xiao`), Dependabot pour les versions d'actions.

**Exercices** : introduire un défaut cppcheck (variable inutilisée,
paramètre passé par valeur) et le faire signaler ; dire quel step échoue si
`credentials.h.example` perd `MQTT_SERVER` ; sur un fork, pousser une branche
qui casse un test et lire le log ; adapter `ci.yml` pour lancer aussi les tests
sur `pull_request` vers une autre branche.

**Verify:** sortie cppcheck réelle ; extrait `ci.yml` identique au commit
`1af068f` ; `./pdf/build pdf module_additionnel_arduino.pdf`.

**Commit:** `git commit -m "docs: chapitre Arduino 6 (qualité et intégration continue)"`

---

### Task 7: Documentation du dépôt et vérification finale

**Files:**
- Modify: `CLAUDE.md` (section « Modules additionnels » : bloc Arduino avec ses
  6 chapitres, prérequis « IDE Arduino ; module additionnel Git », durée
  « 6-8 heures de lecture personnelle, hors séances » ; arborescence :
  `module_arduino/` et ses 6 fichiers ; remarque finale : liste des modules)
- Modify: `README.md` (liste des modules / PDF, au même format que Docker)

**Step 1:** Mettre à jour les deux fichiers.

**Step 2:** Vérification complète

Run: `./pdf/build && ./pdf/build check`
Expected: tous les PDF générés, pytest vert, ruff et shellcheck sans erreur.

**Step 3:** Relecture : grep des caractères interdits

Run: `grep -nP '[\x{2190}-\x{21FF}\x{2500}-\x{257F}\x{1F300}-\x{1FAFF}]' supports/modules_additionnels/module_arduino/*.md`
Expected: aucune sortie.

**Step 4:** Commit

```bash
git add CLAUDE.md README.md
git commit -m "docs: module additionnel Arduino dans le plan et le README"
```

**Step 5:** Revue de code (superpowers-extended-cc:requesting-code-review),
puis PR vers `master`.
