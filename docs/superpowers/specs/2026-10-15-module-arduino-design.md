# Module additionnel Arduino (PlatformIO, tests, CI) -- Design

Date : 2026-10-15
Statut : validé

## Contexte

Les lecteurs visés connaissent déjà Arduino, mais seulement à travers
l'IDE officiel et des fichiers `.ino`. Le module leur montre comment
travailler sur un microcontrôleur avec les pratiques de l'industrie :
PlatformIO, découpage du code pour le rendre testable, tests unitaires,
analyse statique et intégration continue.

Le module s'appuie sur un projet réel et public :
`sketches/XIAO-ESP32-S3/DS18B20_MQTT` du dépôt
https://github.com/pguinet/arduino. Une sonde de température DS18B20,
branchée sur une Seeed Studio XIAO ESP32-S3, publie ses mesures dans Home
Assistant par MQTT Discovery.

## Décisions

1. **Un module de lecture personnelle, pas un cours en séance.** On n'a
   donc aucune contrainte liée au CID (freeze, VirtualBox, USB dans la
   VM). Le lecteur installe PlatformIO sur son propre PC : VS Code avec
   l'extension, ou la CLI `pio`. Linux est l'exemple principal ; les
   différences avec Windows (port COM) et macOS sont signalées.
2. **Pas de matériel obligatoire.** Les tests natifs, la compilation et
   cppcheck tournent sans carte. Seuls le flashage et la publication MQTT
   demandent une carte, ainsi qu'un broker. On le dit dès le chapitre 1.
3. **Le code reste dans le dépôt `pguinet/arduino`.** Le module en cite
   des extraits commentés. Les liens pointent vers un commit figé
   (`1af068f`) pour que le texte et le code ne divergent pas. On ne copie
   pas le projet dans `formation_linux`.
4. **MQTT et Home Assistant sont présentés juste assez pour comprendre le
   code.** Un encadré renvoie au futur homelab du club, où un broker et un
   Home Assistant pourront être installés.
5. **Pas de dossier de TP séparé.** Les exercices sont dans les chapitres
   et se font sans carte, sauf mention contraire.
6. **Prérequis** : avoir déjà utilisé l'IDE Arduino, et avoir lu le module
   additionnel Git (renvoi pour les commits, le fork et GitHub). Durée
   de lecture : 6 à 8 heures.

## Fichiers

```
supports/modules_additionnels/module_arduino/
  01_arduino_xiao_esp32s3.md
  02_ide_vers_platformio.md
  03_mqtt_home_assistant.md
  04_lecture_code.md
  05_tests_unitaires.md
  06_qualite_integration_continue.md
```

- `pdf/documents.yaml` : nouvelle entrée `module_additionnel_arduino.pdf`
  (titre « Arduino : du sketch à l'intégration continue », sous-titre
  « Module additionnel »), placée après Docker.
- `pdf/tests/test_documents.py` : nom ajouté dans `ATTENDUS`, à la même
  position.
- `CLAUDE.md` et `README.md` : le module apparaît dans le plan et dans
  l'arborescence.

## Contenu des chapitres

| Chapitre | Contenu |
|---|---|
| Arduino 1 : de l'Arduino à la XIAO ESP32-S3 | L'écosystème Arduino (framework et cartes), l'ESP32-S3, Seeed Studio et la XIAO (antenne U.FL obligatoire, USB natif, `303a:1001`). Le projet en bref : DS18B20, bus 1-Wire, pull-up interne, schéma de câblage en ASCII. Ce qu'on peut faire sans carte |
| Arduino 2 : de l'IDE à PlatformIO | Ce que cache un `.ino` (prototypes générés, `#include <Arduino.h>` implicite, bibliothèques globales non versionnées). Installation (VS Code et extension, ou CLI). Arborescence `src/lib/test`, `platformio.ini` (plateforme, carte, environnements `xiao` et `native`, `lib_deps` versionnées). `pio run`, `-t upload`, `pio device monitor` |
| Arduino 3 : MQTT et Home Assistant | Broker, client, sujets, QoS en bref, messages retenus, testament (LWT). MQTT Discovery : le JSON de configuration, `availability_mode: all`. Le tableau des sujets du projet. Encadré homelab |
| Arduino 4 : lecture du code | L'architecture : code matériel dans `src/main.cpp`, logique pure dans `lib/temp_logic`. Boucle non bloquante (`millis()` contre `delay()`, débordement géré par la soustraction non signée, conversion DS18B20 asynchrone). Validation des lectures (-127, 85), `PublishPolicy`, `ProbeHealth`. Reconnexion WiFi et MQTT. Secrets (`credentials.h`, `.example`, `#error`) |
| Arduino 5 : tests unitaires | Pourquoi tester du code embarqué, et pourquoi sur le PC. Unity (`setUp`, `TEST_ASSERT_*`, `RUN_TEST`), une suite par dossier de `test/`, l'environnement `native`. Lecture détaillée d'un test, `pio test -e native`, lire un échec. Écrire un test (cas limite) |
| Arduino 6 : qualité et intégration continue | cppcheck (`pio check`, `check_flags`, suppressions en ligne justifiées). GitHub Actions : `ci.yml` décortiqué (déclencheurs, `permissions`, job `discover`, matrice, cache, version de PlatformIO figée, `credentials.h` factice, `--fail-on-defect=low`). Lire un échec dans l'onglet Actions. Badge, protection de branche en « Pour aller plus loin » |

Chaque chapitre suit le template du projet : objectifs, durée, sections,
`L'essentiel`, `Pour aller plus loin`, 3 à 6 exercices avec leurs
solutions. Le calibrage du template (150 à 250 lignes de théorie) est
appliqué avec souplesse : les chapitres 4 et 6 citent du code et seront
plus longs. Chaque concept n'est enseigné qu'une fois, avec des renvois
« (voir chapitre Arduino N) ».

## Exercices sans carte (exemples)

- Créer un projet PlatformIO vide, ajouter une bibliothèque dans
  `lib_deps`, compiler pour `seeed_xiao_esp32s3`.
- Ajouter un test à `test_reading` (85 °C après une lecture à 80 °C),
  puis casser volontairement `isValidReading` et observer l'échec.
- Introduire un défaut repéré par cppcheck, puis le corriger.
- Sur un fork, pousser une branche qui casse un test et lire le résultat
  dans l'onglet Actions.

## Vérification

- `./pdf/build` passe : PDF générés, tests pytest verts, aucun
  `Missing character`.
- Les commandes et extraits cités sont vérifiés sur le dépôt `arduino` au
  commit `1af068f` : `pio test -e native` (24 tests), `pio run -e xiao`,
  `pio check`.
- Aucun caractère interdit : pas de dessin de boîtes, pas de flèches
  Unicode, pas d'emojis.
