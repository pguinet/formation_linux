# Arduino 2 — De l'IDE Arduino à PlatformIO

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - expliquer ce que l'IDE Arduino fait à votre place, et pourquoi un projet `.ino` est difficile à reproduire ;
> - installer PlatformIO, avec VS Code ou en ligne de commande ;
> - lire un fichier `platformio.ini` : environnements, plateforme, carte, bibliothèques versionnées ;
> - compiler, téléverser et ouvrir le moniteur série avec `pio run` et `pio device monitor` ;
> - distinguer les bibliothèques du registre (`lib_deps`) et les bibliothèques locales (`lib/`).
>
> **Durée de lecture** : environ 1 h, exercices compris.

---

Avec l'IDE Arduino, un projet tient dans un fichier `.ino`. On choisit
la carte dans un menu, on installe les bibliothèques depuis le
gestionnaire, puis on clique sur « Téléverser ». C'est simple, mais une
bonne partie du projet n'est écrite nulle part.

Ce chapitre montre ce que l'IDE cache, puis présente **PlatformIO**,
l'outil du projet `DS18B20_MQTT`, où un fichier décrit tout ce qu'il
faut pour compiler, sur n'importe quelle machine.

## Ce que l'IDE fait sans le dire

Prenons un « Blink » ordinaire, qui range le clignotement dans une
fonction placée après `loop()` :

```cpp
void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  clignoter(500);
}

void clignoter(unsigned long duree) {
  digitalWrite(LED_BUILTIN, HIGH);
  delay(duree);
  digitalWrite(LED_BUILTIN, LOW);
  delay(duree);
}
```

Sous le nom `main.ino`, ce fichier compile. Renommé en `main.cpp`, le
même texte échoue (sortie abrégée) :

```
src/main.cpp:2:11: error: 'LED_BUILTIN' was not declared in this scope
...
src/main.cpp:2:3: error: 'pinMode' was not declared in this scope
src/main.cpp:6:3: error: 'clignoter' was not declared in this scope
...
*** [.pio/build/seeed_xiao_esp32s3/src/main.cpp.o] Error 1
```

Un `.ino` n'est pas du C++ : avant de compiler, l'IDE le transforme
en `.cpp`, en silence :

1. **Il ajoute `#include <Arduino.h>`**, l'en-tête qui déclare
   `pinMode`, `digitalWrite`, `delay`, `HIGH`...
2. **Il génère les prototypes.** En C++, une fonction doit être
   déclarée avant d'être appelée ; l'IDE insère donc
   `void clignoter(unsigned long duree);` en haut du fichier.
3. **Il concatène les onglets** : plusieurs `.ino` deviennent un seul
   `.cpp`.

En C++ ordinaire, ces deux lignes sont à écrire vous-même :

```cpp
#include <Arduino.h>

void clignoter(unsigned long duree);
```

Avec elles, `main.cpp` compile. Un fichier qui déclare ce qu'il
utilise se découpe et se teste mieux (voir chapitre Arduino 4).

L'IDE cache aussi deux informations qui ne sont pas dans le sketch :

- **La carte.** Elle est choisie dans le menu « Outils », avec ses
  options. Le sketch ne dit pas pour quelle carte il a été écrit.
- **Les bibliothèques.** Le gestionnaire les installe dans un dossier
  global (`~/Arduino/libraries` sous Linux), partagé par tous vos
  sketches, dans la version du jour. Le sketch dit `#include
  <PubSubClient.h>`, mais pas quelle version il attend.

Conséquence : copié sur un autre PC, le sketch peut ne pas compiler,
ou compiler avec d'autres versions et se comporter autrement. Un
serveur d'intégration continue, parti d'une machine vierge, ne sait
pas quoi installer.

## PlatformIO

**PlatformIO** est un outil de développement pour l'embarqué, en deux
parties : **PlatformIO Core**, programme en ligne de commande nommé
`pio`, et **PlatformIO IDE**, extension de l'éditeur VS Code qui ajoute
des boutons au-dessus de `pio`. À partir d'un fichier de configuration,
`pio` télécharge lui-même la **plateforme** (support d'une famille de
puces, ici l'ESP32), la **chaîne de compilation**, le **framework** (le
core Arduino) et les **bibliothèques**. Rien ne s'installe à la main.

### Installation

PlatformIO tourne sous Linux, Windows et macOS. Au choix :

- **Avec VS Code (recommandé pour débuter).** Installez VS Code, puis,
  dans l'onglet « Extensions », l'extension **PlatformIO IDE**. Au
  premier lancement, elle installe PlatformIO Core dans
  `~/.platformio`. Sous Linux, elle demande Python 3 (paquet
  `python3-venv` sous Debian et Ubuntu).
- **En ligne de commande seule.** La documentation officielle
  recommande son script d'installation :

  ```bash
  curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
  python3 get-platformio.py
  ```

Dans les deux cas, `pio` est installé dans `~/.platformio/penv/bin/`
(`%USERPROFILE%\.platformio\penv\Scripts\` sous Windows, dossier à
ajouter à la variable `Path`). Sous Linux et macOS, un lien le rend
accessible depuis tout terminal ; VS Code propose aussi son propre
terminal PlatformIO :

```bash
mkdir -p ~/.local/bin && ln -s ~/.platformio/penv/bin/pio ~/.local/bin/pio
```

Sous Linux, l'accès au port série demande en plus un réglage (règles
udev ou groupe `dialout`), décrit dans « Pour aller plus loin ».

## L'arborescence d'un projet

Un projet PlatformIO est un dossier qui contient un `platformio.ini` :

```
mon_projet/
+-- platformio.ini   <- la configuration (carte, bibliothèques...)
+-- src/             <- le programme : main.cpp
+-- include/         <- en-têtes partagés par les fichiers de src/
+-- lib/             <- bibliothèques propres au projet
+-- test/            <- tests unitaires (voir chapitre Arduino 5)
+-- .pio/            <- fabriqué par pio : compilations, bibliothèques
```

`.pio/` se reconstruit à chaque compilation : il ne se versionne pas,
et le `.gitignore` du dépôt `arduino` contient la ligne `.pio/` (voir
module additionnel Git). `DS18B20_MQTT` n'a pas de dossier `include/`.

## Le fichier `platformio.ini`

Voici celui du projet, en entier
([source](https://github.com/pguinet/arduino/blob/1af068f/sketches/XIAO-ESP32-S3/DS18B20_MQTT/platformio.ini)) :

```ini
; DS18B20_MQTT - XIAO ESP32-S3
; Sonde DS18B20 publiee dans Home Assistant (MQTT Discovery)

[platformio]
default_envs = xiao

[env:xiao]
platform = https://github.com/pioarduino/platform-espressif32/releases/download/51.03.07/platform-espressif32.zip
board = seeed_xiao_esp32s3
framework = arduino
upload_port = /dev/ttyACM0
monitor_port = /dev/ttyACM0
monitor_speed = 115200

lib_deps =
    paulstoffregen/OneWire@^2.3.8
    milesburton/DallasTemperature@^4.0.6
    knolleary/PubSubClient@^2.8
    bblanchon/ArduinoJson@^7.0.0

check_tool = cppcheck
check_flags = cppcheck: --enable=warning,style,performance --inline-suppr --suppress=*:*/.pio/*
check_src_filters = +<src/main.cpp> +<lib/temp_logic/>

[env:native]
platform = native
build_flags = -std=c++17 -Wall -Wextra
lib_deps =
    bblanchon/ArduinoJson@^7.0.0
```

C'est un fichier INI : sections entre crochets, lignes `clé = valeur`,
commentaires après `;`, valeurs multiples sur des lignes indentées.

**Les environnements.** Chaque section `[env:NOM]` décrit une façon de
compiler : `xiao` pour la carte, `native` pour les tests sur le PC
(voir chapitre Arduino 5). Dans `[platformio]`, `default_envs = xiao`
désigne l'environnement utilisé quand on n'en précise pas.

**La plateforme.** Plutôt que `platform = espressif32` (la dernière
version publiée), le projet désigne par URL une version précise
(51.03.07) de **pioarduino**, plateforme communautaire qui fournit la
version 3 du core Arduino pour ESP32. La compilation de demain sera
identique à celle d'aujourd'hui.

**La carte et le framework.** `board` remplace le menu « Outils > Type
de carte » de l'IDE (processeur, flash, brochage `D0`, `LED_BUILTIN`...).
`framework = arduino` choisit le framework Arduino plutôt qu'ESP-IDF,
le framework natif d'Espressif.

**Le port et le moniteur.** `upload_port` et `monitor_port` fixent le
port (sans eux, PlatformIO le cherche seul) : on ne flashe pas la
mauvaise carte. Sous Windows, ce serait `COM3` par exemple ; sous macOS,
`/dev/cu.usbmodem...`. Par convention, `monitor_speed` égale le
`Serial.begin(115200)` du programme (le moniteur écoute sinon à 9600
bauds). C'est indispensable sur les cartes dont l'USB passe par une
puce USB-série (Uno, clones à CH340) : une vitesse différente n'y
affiche que des caractères illisibles. Sur la XIAO, la carte définit
`ARDUINO_USB_CDC_ON_BOOT=1` : `Serial` passe par l'USB natif, qui
ignore la vitesse, et le réglage est sans effet.

**La suite.** `lib_deps` liste les bibliothèques (voir plus bas). Les
lignes `check_*` configurent cppcheck, lancé par `pio check` (voir
chapitre Arduino 6). `platform = native` compile pour le PC lui-même,
sans framework Arduino (voir chapitre Arduino 5).

## Compiler, téléverser, observer

Les commandes se lancent dans le dossier qui contient `platformio.ini`.

| Commande | Rôle | Bouton VS Code |
|----------|------|----------------|
| `pio run -e xiao` | Compiler | Build (coche) |
| `pio run -e xiao -t upload` | Compiler et téléverser | Upload (flèche) |
| `pio device monitor` | Moniteur série | Serial Monitor (prise) |
| `pio run -t clean` | Effacer les fichiers compilés | Clean (corbeille) |
| `pio pkg list` | Lister plateforme, outils et bibliothèques | - |

`-e` choisit l'environnement, `-t` (*target*) l'action après la
compilation. Sans `-e`, `pio run` traite `default_envs`, ici `xiao`.

La première compilation télécharge tout et compile le core Arduino :
comptez une à plusieurs minutes. Les suivantes ne recompilent que les
fichiers modifiés. Sortie abrégée de `pio run -e xiao` dans le projet :

```
Processing xiao (platform: https://github.com/pioarduino/platform-espressif32/releases/download/51.03.07/platform-espressif32.zip; board: seeed_xiao_esp32s3; framework: arduino)
--------------------------------------------------------------------------------
Library Manager: ArduinoJson@7.4.3 has been installed!
...
PLATFORM: Espressif 32 (51.3.6) > Seeed Studio XIAO ESP32S3
HARDWARE: ESP32S3 240MHz, 320KB RAM, 8MB Flash
...
Dependency Graph
|-- OneWire @ 2.3.8
...
|-- temp_logic
|-- WiFi @ 3.0.7
...
RAM:   [=         ]  12.7% (used 41728 bytes from 327680 bytes)
Flash: [===       ]  26.7% (used 893329 bytes from 3342336 bytes)
========================= [SUCCESS] Took 35.94 seconds =========================
```

Les bibliothèques sont téléchargées dans `.pio/libdeps/xiao/`, dans le
projet (`^7.0.0` résolu en `7.4.3`). Suivent la plateforme et la carte.
La sortie affiche 51.3.6 alors que l'URL désigne la release 51.03.07 :
le `platform.json` de cette release annonce cette version, ne vous en
inquiétez pas. Les 320KB de RAM sont la mémoire disponible pour le
programme ; le reste des 512 Ko de SRAM est réservé. Viennent ensuite
les bibliothèques réellement utilisées, dont `temp_logic` (locale) et
`WiFi` (fournie par le core), puis l'occupation mémoire, comme en bas
de l'IDE. La compilation demande aussi `src/credentials.h`, absent du
dépôt (voir chapitre Arduino 4).

Carte branchée, `-t upload` téléverse par `upload_port`, et
`pio device monitor` affiche ce que la carte écrit avec `Serial.print`
(`Ctrl+C` pour quitter). Les deux s'enchaînent :

```bash
pio run -e xiao -t upload && pio device monitor
```

## Les bibliothèques

**Les bibliothèques du registre, dans `lib_deps`.** Le registre
PlatformIO (https://registry.platformio.org) recense les bibliothèques
publiques, désignées par `auteur/nom@version`. Dans
`paulstoffregen/OneWire@^2.3.8` :

`paulstoffregen` est le propriétaire (deux bibliothèques peuvent
porter le même nom), `OneWire` le nom, et `^2.3.8` la contrainte de
version : le caret accepte 2.3.8 ou plus, mais strictement moins de
3.0.0. Une version majeure peut casser l'interface : on l'accepte
explicitement, en modifiant `platformio.ini`. Les dépendances des
dépendances s'installent aussi (voir « Pour aller plus loin »).

**Les bibliothèques locales, dans `lib/`.** Chaque sous-dossier de
`lib/` est une bibliothèque du projet, ici `lib/temp_logic/`. Rien à
déclarer : quand `src/main.cpp` écrit `#include "temp_logic.h"`,
PlatformIO trouve l'en-tête, compile la bibliothèque et la lie au
programme (ligne `|-- temp_logic` du graphe). Pourquoi ce découpage :
voir chapitre Arduino 4.

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| `.ino` | Fichier de l'IDE, transformé en `.cpp` avant compilation |
| `#include <Arduino.h>` | Déclare l'API Arduino ; obligatoire dans un `.cpp` |
| Prototype | Déclaration d'une fonction avant son appel (`void f(int);`) |
| PlatformIO Core (`pio`) | Outil en ligne de commande qui compile, téléverse, teste |
| PlatformIO IDE | Extension VS Code au-dessus de `pio` |
| `99-platformio-udev.rules`, `dialout` | Accès au port série sous Linux |
| `platformio.ini` | Configuration du projet : environnements, carte, bibliothèques |
| `[env:NOM]` | Environnement : une façon de compiler (`xiao`, `native`) |
| `default_envs` | Environnement(s) utilisé(s) sans `-e` |
| `platform`, `board`, `framework` | Famille de puces, carte, framework |
| `monitor_speed` | Vitesse du moniteur, égale à celle de `Serial.begin` |
| `lib_deps` | Bibliothèques du registre, `auteur/nom@^x.y.z` |
| `^2.3.8` | Version 2.3.8 ou plus, inférieure à 3.0.0 |
| `lib/` | Bibliothèques locales du projet |
| `.pio/` | Dossier de travail de `pio`, à ne pas versionner |
| `pio run -e xiao` | Compiler l'environnement `xiao` |
| `pio run -e xiao -t upload` | Compiler et téléverser |
| `pio device monitor` | Moniteur série (`Ctrl+C` pour quitter) |
| `pio run -t clean` | Effacer les fichiers compilés |
| `pio pkg list` | Lister les paquets et bibliothèques installés |

## Pour aller plus loin

**Accès au port série sous Linux.** Un utilisateur ordinaire ne peut
pas écrire sur `/dev/ttyACM0` (voir chapitre Arduino 1). PlatformIO
fournit des **règles udev** qui ouvrent l'accès aux cartes connues,
dont `303a:1001` :

```bash
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Autre solution : ajouter votre compte au groupe `dialout`, propriétaire
du port sous Debian et Ubuntu (voir chapitre 5.1 du cours de base),
avec `sudo usermod -a -G dialout $USER`, puis rouvrir la session. Sous
Windows et macOS, il n'y a rien à faire.

**Les dépendances indirectes.** `pio pkg list -e xiao` montre que
`DallasTemperature` a besoin de `OneWire`, installée même si elle
n'était pas dans `lib_deps` (arborescence redessinée en ASCII) :

```
Libraries
+-- ArduinoJson @ 7.4.3 (required: bblanchon/ArduinoJson @ ^7.0.0)
+-- DallasTemperature @ 4.0.6 (required: milesburton/DallasTemperature @ ^4.0.6)
|   +-- OneWire @ 2.3.8 (required: paulstoffregen/OneWire @ ^2.3.5)
+-- PubSubClient @ 2.8.0 (required: knolleary/PubSubClient @ ^2.8)
```

**Une URL `stable` n'est pas une version figée.** Selon votre
installation, `pio project init` peut écrire dans le `platformio.ini`
une URL de pioarduino qui se termine par `/stable/`, c'est-à-dire « la
dernière version stable ». Le contenu de cette URL change sans que le
fichier change. Lors de la rédaction de ce chapitre, avec PlatformIO
Core 6.1.19, elle désignait une version qui exigeait un Core plus
récent :

```
IncompatiblePlatform: Development platform 'espressif32' is not compatible with PlatformIO Core v6.1.19 and depends on PlatformIO Core >=6.2.0.
```

Un projet qui doit compiler dans un an, ou en CI, fige la version,
comme `DS18B20_MQTT` le fait avec `51.03.07`.

**D'autres contraintes de version.** `@2.3.8` exige exactement cette
version ; `@~2.3.8` accepte 2.3.x, à partir de 2.3.8 (correctifs
seulement) ; `@^2.3.8` accepte 2.x.y. Pour une version `0.x`, le caret
est plus strict : `^0.5.1` n'accepte que des 0.5.x. On peut aussi
désigner un dépôt Git (`https://github.com/auteur/projet.git#v1.2.0`).

**Partager la configuration entre environnements.** Une section `[env]`
sans nom est héritée par tous les `[env:...]`. Une option peut aussi
reprendre celle d'une autre section : `lib_deps = ${env:xiao.lib_deps}`.

**Voir la configuration calculée.** `pio project config` affiche la
configuration après héritage et substitution, environnement par
environnement. `pio run -e xiao --list-targets` liste les actions
possibles pour `-t` (`upload`, `erase`, `size`, `uploadfs`...).

**Les ports.** `pio device list` liste les ports série et leur
identifiant matériel. Les deux options `--upload-port` de `pio run` et
`-p` de `pio device monitor` remplacent ponctuellement le port du
fichier.

**Le téléversement de la XIAO ESP32-S3.** Si le port USB natif a
disparu, démarrez la carte bouton BOOT enfoncé, puis relancez
`pio run -e xiao -t upload` (voir chapitre Arduino 1).

**Garder des `.ino` ?** PlatformIO sait compiler un `.ino` placé dans
`src/` : il fait la même conversion que l'IDE (« Converting main.ino »
dans la sortie). C'est pratique pour porter un vieux sketch, mais un
projet qui grandit gagne à passer en `.cpp`.

**La CLI de l'IDE.** `arduino-cli` est la version en ligne de commande
de l'IDE Arduino. Elle compile et téléverse sans fenêtre, mais garde le
modèle de l'IDE : bibliothèques globales, carte passée en option à
chaque commande.

## Exercices

**Exercice 1 -- Porter un Blink** (sans carte). Créez un projet vide
dans un nouveau dossier :

```bash
mkdir -p ~/essais/blink && cd ~/essais/blink
pio project init --board seeed_xiao_esp32s3
```

Remplacez la ligne `platform` du `platformio.ini` créé par celle du
projet `DS18B20_MQTT`. Copiez le Blink du début du chapitre dans
`src/main.cpp`, compilez avec `pio run`, puis corrigez le fichier
jusqu'à ce que la compilation réussisse.

**Exercice 2 -- Ajouter une bibliothèque** (sans carte). Dans le projet
de l'exercice 1, déclarez `bblanchon/ArduinoJson@^7.0.0` dans
`lib_deps`. Écrivez un `main.cpp` qui construit un `JsonDocument`
contenant une température et l'écrit sur `Serial` toutes les 2
secondes, puis compilez. Où la bibliothèque a-t-elle été installée ?
Quelle ligne faut-il aussi ajouter pour lire ce message avec
`pio device monitor` ?

**Exercice 3 -- Contraintes de version** (sans carte). Pour chaque ligne de
`lib_deps` du projet, donnez la plus petite et la plus grande version
acceptées. La version 3.0.0 de `OneWire` serait-elle installée ? Et
`PubSubClient` 2.8.1 ?

**Exercice 4 -- Les environnements** (sans carte). Dans le projet
`DS18B20_MQTT`, quels sont les environnements ? Que compile `pio run`
sans option ? Que se passe-t-il avec `pio run -e native`, et pourquoi
cet environnement sert-il malgré tout ?

**Exercice 5 -- Reproductibilité** (sans carte). Un collègue vous envoie un sketch
`.ino` qui « marche chez lui ». Listez les informations qui vous
manquent pour le compiler à l'identique, et indiquez où chacune se
trouverait dans un projet PlatformIO.

### Solutions

**Solution 1**

`pio project init` crée `platformio.ini`, `src/`,
`lib/`, `include/` et `test/`, avec un environnement
`[env:seeed_xiao_esp32s3]`. La ligne `platform` générée dépend de votre
installation. Si la commande se termine par `IncompatiblePlatform` (voir
« Pour aller plus loin »), les fichiers sont tout de même créés. Dans
tous les cas, on remplace cette ligne par :

```ini
platform = https://github.com/pioarduino/platform-espressif32/releases/download/51.03.07/platform-espressif32.zip
```

La première compilation échoue sur `pinMode`, `LED_BUILTIN`,
`clignoter`... Il faut ajouter l'include et le prototype :

```cpp
#include <Arduino.h>

void clignoter(unsigned long duree);

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
}
...
```

Avec `#include <Arduino.h>` seul, il reste une erreur :
`'clignoter' was not declared in this scope`. Avec les deux lignes, la
compilation se termine par `[SUCCESS]`. Autre solution : déplacer la
fonction `clignoter()` avant `loop()`.

**Solution 2**

Le `platformio.ini` se termine par :

```ini
lib_deps =
    bblanchon/ArduinoJson@^7.0.0
monitor_speed = 115200
```

Un `main.cpp` possible :

```cpp
#include <Arduino.h>
#include <ArduinoJson.h>

void setup() {
  Serial.begin(115200);
}

void loop() {
  JsonDocument doc;
  doc["temperature"] = 21.5;
  doc["unite"] = "C";
  serializeJson(doc, Serial);
  Serial.println();
  delay(2000);
}
```

`pio run` affiche `Library Manager: ArduinoJson@7.4.3 has been
installed!` (ou une version 7.x plus récente) et la bibliothèque est
rangée dans `.pio/libdeps/seeed_xiao_esp32s3/`, à l'intérieur du
projet. Par convention, on ajoute `monitor_speed = 115200`, égal au
`Serial.begin(115200)` du programme. Sur la XIAO, dont `Serial` passe
par l'USB natif, il est sans effet ; il serait indispensable sur une
carte à puce USB-série (Uno, CH340). La lecture elle-même demande la
carte.

**Solution 3**

| Bibliothèque | Minimum | Maximum (exclu) |
|--------------|---------|-----------------|
| `OneWire@^2.3.8` | 2.3.8 | 3.0.0 |
| `DallasTemperature@^4.0.6` | 4.0.6 | 5.0.0 |
| `PubSubClient@^2.8` | 2.8.0 | 3.0.0 |
| `ArduinoJson@^7.0.0` | 7.0.0 | 8.0.0 |

`OneWire` 3.0.0 est refusée : c'est une nouvelle version majeure.
`PubSubClient` 2.8.1 est acceptée.

**Solution 4**

Deux environnements : `xiao` et `native`. `pio run` sans
`-e` compile `default_envs`, donc `xiao` seulement. `pio run -e native`
essaie de compiler `src/main.cpp` pour le PC et échoue :

```
src/main.cpp:12:10: fatal error: Arduino.h: No such file or directory
```

Le PC n'a pas de framework Arduino. L'environnement `native` ne sert
pas à compiler le programme, mais à exécuter les tests de `test/` avec
`pio test -e native` : ils n'utilisent que `lib/temp_logic`, qui ne
dépend pas d'Arduino (voir chapitre Arduino 5).

**Solution 5**

Il manque :

- la carte et ses options (`board` dans `[env:...]`) ;
- la version du core, c'est-à-dire de la plateforme (`platform`, figée
  par une version ou une URL) ;
- la liste des bibliothèques et leurs versions (`lib_deps`) ;
- la vitesse du port série (`monitor_speed`) ;
- les éventuels autres fichiers `.ino` du sketch, que l'IDE concatène
  (dans un projet PlatformIO, ce sont des fichiers de `src/` ou des
  bibliothèques de `lib/`).

Tout cela tient dans `platformio.ini` et dans le dossier du projet,
versionnés ensemble avec Git.
