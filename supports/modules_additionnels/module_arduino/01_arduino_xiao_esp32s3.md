# Arduino 1 — De l'Arduino à la XIAO ESP32-S3

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - distinguer les trois sens du mot « Arduino » : les cartes, le framework et l'IDE ;
> - situer l'ESP32-S3 et la Seeed Studio XIAO ESP32-S3 par rapport à un Arduino Uno ;
> - expliquer le rôle de l'antenne U.FL et de l'USB natif de la XIAO ;
> - décrire la sonde DS18B20, le bus 1-Wire et le rôle de la résistance de tirage ;
> - vous repérer dans l'arborescence du projet étudié dans ce module.
>
> **Durée de lecture** : environ 45 min, exercices compris.

---

Ce module s'adresse aux lecteurs qui connaissent Arduino par l'IDE
officiel et les fichiers `.ino`. Il montre comment travailler sur un
microcontrôleur avec les pratiques de l'industrie : construction
reproductible avec PlatformIO, code découpé pour être testable, tests
unitaires, analyse statique et intégration continue. Ce premier
chapitre présente le module, puis le matériel du projet étudié.

## Le module en bref

### Ce que l'on étudie

Tout le module s'appuie sur un projet réel et public, `DS18B20_MQTT` :
une sonde de température dont les mesures s'affichent dans Home
Assistant, un logiciel de domotique.

```
DS18B20  --1-Wire-->  XIAO ESP32-S3  --WiFi-->  broker MQTT  -->  Home Assistant
(sonde)               (la carte)                (serveur)         (affichage)
```

La carte lit la sonde toutes les 10 secondes. Elle publie la mesure par
WiFi quand elle a changé d'au moins 0,2 °C, et au plus tard toutes les
5 minutes (voir chapitre Arduino 4). Les messages partent vers un
**broker MQTT**, un serveur qui les reçoit et les redistribue ; Home
Assistant les reçoit, affiche la mesure et en garde l'historique.

Le code se trouve dans le dépôt https://github.com/pguinet/arduino,
dossier `sketches/XIAO-ESP32-S3/DS18B20_MQTT`. Le module cite toujours
le même commit, `1af068f`, pour que le texte et le code restent
d'accord :
https://github.com/pguinet/arduino/tree/1af068f/sketches/XIAO-ESP32-S3/DS18B20_MQTT

### Prérequis et organisation

- avoir déjà écrit et téléversé un sketch avec l'IDE Arduino ;
- avoir lu le module additionnel Git (contrôle de version) : cloner,
  commit, branche, GitHub ne sont pas réexpliqués.

Le module se lit seul, sur votre propre PC, en 6 à 8 heures. Linux sert
d'exemple ; les différences avec Windows et macOS sont signalées.

Vous n'avez **pas besoin de la carte** pour l'essentiel du module, et
chaque exercice indique s'il la demande :

| Sans carte, sur le PC seul | Avec la carte (et un broker) |
|----------------------------|------------------------------|
| compiler le projet | téléverser le programme (flasher) |
| lancer les tests unitaires | lire le moniteur série |
| lancer l'analyse statique (cppcheck) | voir les messages MQTT réels |
| faire tourner l'intégration continue | voir le capteur dans Home Assistant |

| Chapitre | Titre | Contenu |
|----------|-------|---------|
| Arduino 1 | De l'Arduino à la XIAO ESP32-S3 | ESP32-S3, XIAO, DS18B20, bus 1-Wire, le projet |
| Arduino 2 | De l'IDE Arduino à PlatformIO | `platformio.ini`, `pio run` |
| Arduino 3 | MQTT et Home Assistant | sujets, messages retenus, découverte |
| Arduino 4 | Lecture du code | architecture, boucle non bloquante, reconnexions |
| Arduino 5 | Les tests unitaires | Unity, `pio test`, écrire un test |
| Arduino 6 | Qualité et intégration continue | cppcheck, GitHub Actions |

## Arduino, c'est trois choses

Le mot « Arduino » désigne trois choses, que l'IDE présente comme un
tout :

- **des cartes** : l'Uno et ses cousines, dont les schémas sont publiés
  sous licence libre, d'où les nombreux clones ;
- **un framework** : `setup()` et `loop()`, `pinMode()`,
  `digitalWrite()`, `millis()`, l'objet `Serial`... Il rend un programme
  lisible sans connaître les registres du microcontrôleur ;
- **un IDE** : l'éditeur qui compile et téléverse le sketch.

Le framework n'est pas lié aux cartes Arduino. Pour chaque famille de
puces, une implémentation appelée **core** traduit `digitalWrite()` ou
`Serial.println()` pour cette puce. Le core d'origine vise les AVR,
comme l'ATmega328P de l'Uno ; Espressif publie le sien,
`arduino-esp32`, pour ses ESP32. Dans ce module, c'est PlatformIO qui
l'installe (voir chapitre Arduino 2). Un sketch se compile donc pour un
Uno comme pour une ESP32, aux différences de matériel près : broches,
tension, mémoire.

## L'ESP32-S3

L'**ESP32-S3** est un microcontrôleur de la société chinoise Espressif
Systems, annoncé fin 2020. Il réunit sur une seule puce deux cœurs
Xtensa LX7 de 32 bits à 240 MHz, 512 Ko de SRAM, le **WiFi** 2,4 GHz
(802.11 b/g/n), le **Bluetooth 5 LE** et un contrôleur **USB** intégré.
Comparé à l'Arduino Uno R3 :

| | Arduino Uno R3 | XIAO ESP32-S3 |
|---|---|---|
| Microcontrôleur | ATmega328P (AVR, 8 bits) | ESP32-S3 (Xtensa LX7, 32 bits) |
| Cœurs, fréquence | 1 à 16 MHz | 2 à 240 MHz |
| RAM | 2 Ko | 512 Ko de SRAM + 8 Mo de PSRAM |
| Flash (programme) | 32 Ko | 8 Mo |
| WiFi, Bluetooth | non | WiFi 2,4 GHz, Bluetooth 5 LE |
| Tension des broches | 5 V | 3,3 V |
| USB | via une seconde puce (ATmega16U2) | natif |
| Dimensions | 68,6 x 53,4 mm | 21 x 17,8 mm |

Deux conséquences pratiques. La RAM n'est plus le souci quotidien
qu'elle est sur un Uno : on construit sans peine un message JSON de
plusieurs centaines d'octets. Et les broches travaillent en **3,3 V** :
un module prévu pour du 5 V peut endommager la carte. La sonde DS18B20,
elle, accepte de 3,0 à 5,5 V.

## Seeed Studio et la XIAO ESP32-S3

**Seeed Studio** est un fabricant chinois de cartes de développement. Sa
gamme **XIAO** décline un même format de la taille d'un timbre pour
plusieurs microcontrôleurs (RP2040, ESP32-C3, ESP32-C6, ESP32-S3...),
avec un connecteur USB-C et des broches nommées `D0` à `D10`. La XIAO
ESP32-S3 existe en version de base et en version *Sense* (caméra et
lecteur microSD) ; le projet utilise la version de base. Sur cette
carte, la constante `D0` du framework désigne la broche GPIO1 de la
puce.

### L'antenne est obligatoire

La XIAO ESP32-S3 **n'a pas d'antenne intégrée**. Elle est livrée avec une
antenne souple qui se clipse sur un minuscule connecteur **U.FL**. Sans
elle, la carte ne voit pas le réseau, même à un mètre de la box. Le
programme du projet l'affiche alors sur le moniteur série :

```
WiFi toujours absent (statut 1) : relance
```

Le statut 1 est `WL_NO_SSID_AVAIL` : aucun réseau de ce nom n'est
visible. Vérifiez l'antenne avant de soupçonner le mot de passe.

### L'USB natif

Sur un Uno, le microcontrôleur ne parle pas USB : une seconde puce
traduit entre l'USB du PC et sa liaison série. L'ESP32-S3 contient son
propre contrôleur USB : c'est lui que le PC voit. La carte apparaît
comme un port série : `/dev/ttyACM0` sous Linux (le numéro augmente avec
plusieurs cartes), `COM3`, `COM4`... sous Windows (gestionnaire de
périphériques), `/dev/cu.usbmodem...` sous macOS.

La commande `lsusb` affiche l'identifiant USB `fabricant:produit` de la
carte, `303a:1001` : `303a` désigne Espressif, `1001` le contrôleur USB
de la puce. Cet identifiant est donc **le même pour toutes les cartes
ESP32-S3**, quel que soit leur fabricant. Pour vérifier que c'est bien
la XIAO qui est branchée, le README du projet lit la taille de sa flash
(8 Mo) avec l'outil `esptool`.

## La sonde DS18B20 et le bus 1-Wire

La **DS18B20** (Maxim Integrated, aujourd'hui Analog Devices) est un
thermomètre numérique. Le projet utilise sa version étanche : la puce
est enfermée dans un tube en inox, au bout d'un câble à trois fils.

| Caractéristique | Valeur |
|-----------------|--------|
| Plage de mesure | -55 °C à +125 °C |
| Précision | 0,5 °C entre -10 °C et +85 °C |
| Résolution | 9 à 12 bits (12 bits : 0,0625 °C) |
| Durée de conversion | 750 ms au plus en 12 bits |
| Alimentation | 3,0 V à 5,5 V |

Elle communique par le bus **1-Wire** : un seul fil de données
(`DATA`), plus la masse et l'alimentation. Chaque sonde porte une
**adresse unique** de 64 bits gravée en usine : plusieurs sondes peuvent
partager le même fil, et le programme les compte au démarrage
(`Sondes detectees : 1`). Une mesure se fait en deux temps : demander
une **conversion**, puis lire le résultat 750 ms plus tard (voir
chapitre Arduino 4 pour l'attente non bloquante).

Deux valeurs sont suspectes, et seront traitées au chapitre Arduino 4 :
**-127**, renvoyée par la bibliothèque `DallasTemperature` quand la
sonde ne répond pas (fil coupé, soudure ratée), et **85**, contenue par
la sonde à la mise sous tension, avant toute conversion.

### La résistance de tirage

Sur le fil `DATA`, la sonde et la carte ne font que **tirer la ligne vers
0 V** pour envoyer leurs bits. Au repos, une **résistance de tirage**
(*pull-up*), placée entre `DATA` et l'alimentation, ramène la ligne à
3,3 V. Sans elle, la ligne flotte et les lectures échouent (-127).

Les montages classiques utilisent une résistance externe de 4,7
kilohms. Le projet s'en passe : il active la résistance de tirage
**interne** de l'ESP32-S3, d'environ 45 kilohms, avant de démarrer le
bus. C'est cette ligne de `setup()`, dans `src/main.cpp` :

```cpp
    pinMode(ONE_WIRE_PIN, INPUT_PULLUP);
```

Cette résistance, dix fois plus élevée, donc un tirage plus faible, suffit pour le mètre de câble
d'une sonde étanche, pas pour plusieurs mètres. En cas de lectures à
-127, on soude une 4,7 kilohms entre `DATA` et `3V3`, sans toucher au
code. Le câblage, repris du README :

| Fil de la sonde | XIAO ESP32S3 |
|---|---|
| Rouge (VDD) | 3V3 |
| Noir (GND) | GND |
| Jaune (DATA) | D0 (GPIO1) |

```
  XIAO ESP32-S3                            sonde DS18B20
  3V3 o------------+---------------------- rouge (VDD)
                   |
                [45 k]  pull-up interne (INPUT_PULLUP)
                   |
  D0  o------------+---------------------- jaune (DATA)
  GND o----------------------------------- noir (GND)
```

Schéma électrique : sur la carte, les broches sont disposées autrement.

## Le projet DS18B20_MQTT

Dans un clone du dépôt, le dossier du projet contient ces fichiers
(sortie de `find . -type f | sort`, avant toute compilation) :

```
./case/ATTRIBUTION.md
./case/seeed-studio-xiao-esp32-c6-base-plain.stl
./case/seeed-studio-xiao-esp32-c6-lid-x.stl
./lib/temp_logic/ha_discovery.cpp
./lib/temp_logic/ha_discovery.h
./lib/temp_logic/temp_logic.cpp
./lib/temp_logic/temp_logic.h
./platformio.ini
./README.md
./src/main.cpp
./test/test_discovery/test_main.cpp
./test/test_probe/test_main.cpp
./test/test_publish/test_main.cpp
./test/test_reading/test_main.cpp
```

| Chemin | Rôle | Chapitre |
|--------|------|----------|
| `platformio.ini` | description du projet : carte, framework, bibliothèques | Arduino 2 |
| `src/main.cpp` | le programme : sonde, WiFi, MQTT (code lié au matériel) | Arduino 4 |
| `lib/temp_logic/temp_logic.*` | validation, arrondi, décision de publier, état de la sonde | Arduino 4 |
| `lib/temp_logic/ha_discovery.*` | identifiant, sujets MQTT, message de découverte | Arduino 3 et 4 |
| `test/` | tests unitaires, une suite par dossier | Arduino 5 |
| `case/` | boîtier imprimable en 3D (fichiers STL) | - |
| `README.md` | matériel, câblage, configuration, dépannage | - |

Il n'y a pas de fichier `.ino` : le programme est un fichier C++
ordinaire. Il manque aussi `src/credentials.h`, qui contient les
identifiants du WiFi et du broker : il est volontairement exclu du dépôt
(voir chapitre Arduino 4).

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| Arduino | Trois choses : des cartes, un framework (`setup`, `loop`, `Serial`...), un IDE |
| Core | Implémentation du framework pour une famille de puces (`arduino-esp32` pour les ESP32) |
| ESP32-S3 | Microcontrôleur Espressif : 2 cœurs à 240 MHz, WiFi, Bluetooth 5 LE, USB natif |
| XIAO ESP32-S3 | Carte Seeed Studio de 21 x 17,8 mm, 8 Mo de flash, broches `D0` à `D10` |
| Antenne U.FL | Obligatoire sur la XIAO ; sans elle : `WiFi toujours absent (statut 1) : relance` |
| USB natif | La puce gère l'USB elle-même ; port `/dev/ttyACM0` (Linux), `COMx` (Windows) |
| `303a:1001` | Identifiant USB commun à toutes les ESP32-S3 (`lsusb`) |
| DS18B20 | Sonde numérique, -55 à +125 °C, 750 ms par conversion en 12 bits |
| 1-Wire | Bus à un fil de données ; chaque sonde a une adresse unique de 64 bits |
| -127 et 85 | Sonde muette, et valeur de mise sous tension : lectures suspectes |
| Pull-up | Ramène `DATA` à 3,3 V au repos ; interne (environ 45 kilohms) ou externe (4,7 kilohms) |
| `INPUT_PULLUP` | Active la résistance de tirage interne d'une broche |

## Pour aller plus loin

**Les autres ESP32.** Espressif décline l'ESP32 en plusieurs familles.
L'ESP32 « classique » (2016) a deux cœurs Xtensa LX6 et pas d'USB natif.
Les ESP32-C3 et ESP32-C6 ont un cœur principal RISC-V ; le C6 ajoute le
WiFi 6 et les protocoles domotiques Thread et Zigbee. Le S3 se distingue par
ses deux cœurs, ses instructions vectorielles (utiles pour l'audio ou la
reconnaissance d'images) et son grand nombre de broches. Le boîtier du
dossier `case/` est prévu pour les XIAO C3, C6 et S3, qui ont le même
format.

**ESP-IDF.** Sur l'ESP32, le framework Arduino tourne au-dessus
d'ESP-IDF, le kit de développement officiel d'Espressif, lui-même bâti
sur FreeRTOS (voir chapitre Arduino 4). On peut appeler directement les
fonctions d'ESP-IDF depuis un sketch : le projet le fait avec
`esp_read_mac()` (voir chapitre Arduino 4).

**Quand l'USB natif disparaît.** Avec une seconde puce USB, comme sur
l'Uno, le port série existe tant que la carte est alimentée. Avec l'USB
natif, c'est le programme qui le fait vivre : si le programme plante en
boucle ou met la puce en sommeil profond, le port `/dev/ttyACM0`
disparaît, et le téléversement échoue. La parade : débrancher la carte,
maintenir le bouton **BOOT** enfoncé, la rebrancher, puis relâcher le
bouton. La puce démarre alors sur son chargeur interne, qui expose
toujours le port USB, et accepte un nouveau programme.

**ttyACM ou ttyUSB.** Sous Linux, le nom du port dépend du pilote, pas
de la carte. Un appareil qui se présente comme un modem USB standard
(classe CDC ACM), comme l'ESP32-S3 ou l'ATmega16U2 de l'Uno R3, devient
`/dev/ttyACM0`. Les cartes équipées d'une puce de conversion USB-série
(CH340, CP2102, FT232), fréquentes sur les clones et les anciennes
cartes ESP32, deviennent `/dev/ttyUSB0`. L'accès à ces fichiers sans
`sudo` demande un réglage (voir chapitre Arduino 2).

**Le mode parasite.** La DS18B20 peut aussi fonctionner avec deux fils
seulement (`DATA` et la masse) : elle se nourrit alors sur la ligne de
données. Ce « mode parasite » complique le montage et la lecture ; le
projet utilise l'alimentation normale, à trois fils.

**Les fiches techniques.** Les caractéristiques citées dans ce chapitre
viennent des documents des fabricants : la fiche *ESP32-S3 Series
Datasheet* d'Espressif, la page *Getting Started with Seeed Studio XIAO
ESP32S3* du wiki de Seeed Studio, la fiche de l'Arduino Uno R3 et la
fiche technique de la DS18B20. Prendre l'habitude de les consulter évite
bien des suppositions.

## Exercices

**Exercice 1 — Trouver la carte** (avec la carte). Branchez la XIAO ESP32-S3 sur votre PC
Linux. Quelles commandes permettent de trouver le nom du port série et
de vérifier que le PC voit une puce ESP32-S3 ? Comment distinguer la
XIAO d'une autre carte ESP32-S3 ?

**Exercice 2 — Sans résistance de tirage** (sans carte). Un camarade a câblé une sonde DS18B20 sur
une XIAO comme dans le tableau de câblage, mais il a supprimé la ligne
`pinMode(ONE_WIRE_PIN, INPUT_PULLUP);` de `setup()`. Il n'a pas soudé de
résistance externe. Que va-t-il observer, et pourquoi ? Proposez deux
corrections.

**Exercice 3 — Pas de WiFi** (sans carte). Votre XIAO affiche en boucle
`WiFi toujours absent (statut 1) : relance`, alors que le nom du réseau est
correct. Quelle est la cause la plus probable ?

**Exercice 4 — Le bon fichier** (sans carte). Pour chaque besoin, indiquez le fichier ou
le dossier du projet concerné :

1. changer la broche à laquelle la sonde est reliée ;
2. ajouter une bibliothèque au projet ;
3. vérifier que les lectures à -127 sont bien rejetées ;
4. imprimer un boîtier ;
5. renseigner le mot de passe du WiFi.

**Exercice 5 — Cloner le projet** (sans carte). Clonez le dépôt du projet, placez-vous au
commit `1af068f` utilisé dans tout le module, et vérifiez que le dossier
du projet contient bien les fichiers listés dans ce chapitre.

### Solutions

**Solution 1**

```bash
ls /dev/ttyACM*
lsusb
```

`ls /dev/ttyACM*` affiche le port créé par la carte, en général
`/dev/ttyACM0`. Une façon fiable de le confirmer : lancer la commande
avant et après avoir branché la carte, et comparer. Dans la sortie de
`lsusb`, la carte se reconnaît à l'identifiant `303a:1001`. Cet
identifiant est celui de toutes les puces ESP32-S3 : il ne permet pas de
distinguer la XIAO d'une autre carte. Le README du projet lit pour cela
la taille de la mémoire flash avec `esptool` (`flash_id`) : 8 Mo pour la
XIAO ESP32-S3.

**Solution 2**

Sans résistance de tirage, la ligne `DATA` n'est
ramenée à 3,3 V par rien : elle flotte, et les bits envoyés par la
sonde sont illisibles. La sonde peut ne pas être détectée
(`Sondes detectees : 0`), ou les lectures valent -127 et sont rejetées.
Corrections : remettre la ligne `pinMode(ONE_WIRE_PIN, INPUT_PULLUP);`
avant `sensors.begin()`, ou souder une résistance de 4,7 kilohms entre
`DATA` et `3V3`. La seconde solution est préférable avec un câble de
plusieurs mètres.

**Solution 3**

L'antenne n'est pas branchée sur le connecteur U.FL. La
XIAO ESP32-S3 n'a pas d'antenne intégrée : sans elle, aucun réseau n'est
visible, d'où le statut 1 (`WL_NO_SSID_AVAIL`). Autre cause possible :
un réseau hors de portée.

**Solution 4**

1. `src/main.cpp` (la constante `ONE_WIRE_PIN`).
2. `platformio.ini` (voir chapitre Arduino 2).
3. `lib/temp_logic/temp_logic.cpp` pour le code, `test/test_reading/`
   pour les tests.
4. `case/` (fichiers STL).
5. `src/credentials.h`, absent du dépôt, à créer à partir du modèle
   (voir chapitre Arduino 4).

**Solution 5**

```bash
git clone https://github.com/pguinet/arduino.git
cd arduino
git switch --detach 1af068f
```

La dernière commande répond :

```
HEAD is now at 1af068f CI: move actions to their Node 24 majors
```

`--detach` est nécessaire parce que `1af068f` est un commit, pas une
branche : Git se place dessus sans branche courante (« HEAD détachée »).
On vérifie ensuite le contenu :

```bash
cd sketches/XIAO-ESP32-S3/DS18B20_MQTT
find . -type f | sort
```

La liste est celle de la section « Le projet DS18B20_MQTT ». Pour revenir à la
version la plus récente : `git switch main`.
