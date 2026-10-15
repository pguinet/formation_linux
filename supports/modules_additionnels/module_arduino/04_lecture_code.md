# Arduino 4 — Lecture du code

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - expliquer pourquoi le projet sépare le code matériel (`src/`) de la logique pure (`lib/`) ;
> - garder des secrets (WiFi, MQTT) hors d'un dépôt Git ;
> - écrire une boucle non bloquante avec `millis()` et justifier qu'elle survit au débordement du compteur ;
> - lire une machine à états simple (conversion asynchrone de la DS18B20) ;
> - expliquer la validation des lectures, `PublishPolicy` et `ProbeHealth` ;
> - suivre la reconnexion WiFi et MQTT sans bloquer le programme.
>
> **Durée de lecture** : environ 1 h 30, exercices compris.

---

Ce chapitre lit le programme lui-même : il en cite les passages qui
portent une décision, et explique **pourquoi** chaque choix a été fait.
Gardez ouverts `src/main.cpp` et `lib/temp_logic/temp_logic.cpp`, au
commit figé `1af068f` ; les numéros de ligne cités y renvoient :

```
https://github.com/pguinet/arduino/tree/1af068f/sketches/XIAO-ESP32-S3/DS18B20_MQTT
```

## Deux couches : le matériel et la logique

Un sketch de l'IDE tient souvent dans un seul fichier, où lecture de la
sonde, calculs et envoi réseau se mélangent. Ce projet sépare le code
**matériel**, dans `src/main.cpp`, de la **logique pure**, dans
`lib/temp_logic/` :

```
  src/main.cpp  ------------------------>  lib/temp_logic/  (temp::...)
    | Arduino, WiFi, OneWire,                | stdint.h, stddef.h, math.h,
    | DallasTemperature, PubSubClient        | stdio.h, stdlib.h, ArduinoJson
    | (ESP32 uniquement)                     | (compilent aussi sur PC)
```

La logique n'appelle jamais le matériel ; même l'heure lui est **passée
en paramètre** (`nowMs`). Elle compile donc avec le `g++` de votre PC et
se teste sans carte, avec des valeurs choisies (voir chapitre Arduino
5). `main.cpp`, qui ne se teste qu'en flashant la carte, reste
**mince** : de la plomberie entre le matériel et la logique.

L'espace de noms `temp` (`temp::isValidReading`...) signale ce qui vient
du code testé et évite les collisions avec une bibliothèque Arduino.

## Les secrets hors du dépôt

Le nom du WiFi, son mot de passe et les identifiants MQTT ne doivent pas
finir sur GitHub (`main.cpp`, lignes 19 à 28) :

```cpp
#include "credentials.h"
...
#ifndef WIFI_SSID
#error "credentials.h : WIFI_SSID manquant (voir sketches/common/credentials.h.example)"
#endif
...
```

- **le fichier est ignoré** : le `.gitignore` du dépôt contient
  `**/credentials.h` (voir module additionnel Git) ;
- **un modèle est versionné** : `sketches/common/credentials.h.example`,
  avec des valeurs factices ;
- **le compilateur vérifie** : `#error` arrête la compilation avec un
  message qui dit quoi faire.

Pour compiler, copiez le modèle dans `src/` depuis le dossier du projet
(`sketches/XIAO-ESP32-S3/DS18B20_MQTT`), deux niveaux sous `sketches/` :

```bash
cp ../../common/credentials.h.example src/credentials.h
```

Puis éditez `src/credentials.h` (avec nano, par exemple) pour y mettre le
nom et le mot de passe de votre WiFi, l'adresse du broker et ses
identifiants. Les valeurs factices suffisent pour compiler et tester.

Voici `pio run -e xiao` quand `WIFI_SSID` manque :

```
src/main.cpp:24:2: error: #error "credentials.h : WIFI_SSID manquant (voir sketches/common/credentials.h.example)"
...
xiao           FAILED    00:00:08.913
```

Sans le fichier, l'erreur est
`fatal error: credentials.h: No such file or directory`.

## setup() : préparer sans attendre

Extraits de `setup()` (lignes 168 à 196) :

```cpp
    pinMode(ONE_WIRE_PIN, INPUT_PULLUP);
    sensors.begin();
...
    sensors.setWaitForConversion(false);
...
    esp_read_mac(mac, ESP_MAC_WIFI_STA);
...
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);  // non bloquant
...
    mqtt.setBufferSize(1024);  // decouverte > 256 octets par defaut
```

- **`INPUT_PULLUP` avant `sensors.begin()`** : le tirage interne doit
  être actif avant le premier échange 1-Wire (voir chapitre Arduino 1).
- **`setWaitForConversion(false)`** : sinon `requestTemperatures()`
  attend la fin de la mesure (750 ms à 12 bits). On gère cette attente
  soi-même, sans bloquer.
- **`esp_read_mac()`** : l'identifiant (`xiao_ds18b20_3bb004`) dérive
  de la MAC. `WiFi.macAddress()` renverrait ici des zéros, la station
  n'étant pas démarrée : toutes les cartes auraient le même identifiant.
  `esp_read_mac()`, fonction d'ESP-IDF, lit l'adresse gravée en usine
  dans les **eFuses** de la puce, une mémoire programmable une seule
  fois.
- **`WiFi.begin()`** rend la main aussitôt, sans boucle
  `while (WiFi.status() != WL_CONNECTED)` : `loop()` suivra le réseau.
- **`setBufferSize(1024)`** : PubSubClient limite un paquet à 256
  octets, or le JSON de découverte (voir chapitre Arduino 3) en fait 533.

## loop() : une boucle qui ne bloque jamais

Un sketch typique de l'IDE ressemble à ceci (exemple schématique, qui ne
vient pas du projet) :

```cpp
void loop() {
    sensors.requestTemperatures();   // attend 750 ms
    float c = sensors.getTempCByIndex(0);
    client.publish("maison/temperature", String(c).c_str());
    delay(10000);                    // attend 10 s
}
```

Pendant `delay(10000)`, le programme ne fait **rien d'autre** : il ne
voit pas la perte du WiFi et ne répond pas au broker, qui finit par le
déconnecter. La boucle du projet (lignes 198 à 203) est à l'opposé :

```cpp
void loop() {
    handleWifi();
    handleMqtt();
    handleSensor();
    delay(10);
}
```

Chaque `handle*()` regarde l'heure, décide s'il y a quelque chose à
faire, le fait vite et **rend la main** : chaque tâche est examinée
environ cent fois par seconde. Le motif qui remplace `delay()`, avec
`millis()` (millisecondes depuis le démarrage, en `uint32_t`) :

```cpp
if (millis() - last < INTERVAL) return;   // pas encore l'heure
last = millis();
// ... faire le travail ...
```

## Le débordement de millis()

Un `uint32_t` va de 0 à 4 294 967 295 : le compteur repasse à 0 au bout
de 2^32 ms, soit **49,71 jours**, ce qui arrivera sur une sonde branchée
des mois.

La soustraction de deux `uint32_t` se calcule **modulo 2^32** : un
résultat « négatif » reçoit 2^32 en plus. `now - last` donne donc
toujours la durée écoulée, même si `now` est repassé par zéro. Avec
`last = 4 294 962 296` (5 s avant le débordement) et un intervalle de
10 000 ms :

| `now` | `now - last` | Action |
|-------|--------------|--------|
| 4 294 967 295 | 4 999 | attendre |
| 0 (débordement) | 5 000 | attendre |
| 5 000 | 10 000 | agir |

La tâche se déclenche exactement 10 s après la précédente. L'écriture
naïve `if (now >= last + INTERVAL)` échoue : `last + INTERVAL` déborde
aussi et vaut 5 000, si bien que la condition est vraie à chaque tour
de boucle jusqu'au débordement de `now`. Règle : **toujours soustraire,
jamais additionner**, avec des opérandes en `uint32_t`.

## handleSensor() : une conversion en deux temps

Une mesure DS18B20 demande une conversion, lue 750 ms plus tard.
`handleSensor()` (lignes 141 à 166) découpe l'attente avec `converting` :

```cpp
    if (!converting) {
        if (now - lastRead < READ_INTERVAL_MS && lastRead != 0) return;
        sensors.requestTemperatures();
        converting = true;
        conversionStart = now;
        return;
    }
    if (now - conversionStart < sensors.millisToWaitForConversion()) return;
    converting = false;
```

C'est une **machine à deux états** :

```
          10 s écoulées : requestTemperatures()
  +----------+  ------------------------------>  +------------+
  | au repos |                                   | conversion |
  +----------+  <------------------------------  +------------+
          750 ms écoulées : lire, valider, publier
```

Pendant la conversion, la boucle continue de servir le WiFi et MQTT.
`lastRead != 0` déclenche la première mesure dès le démarrage.

## Valider une lecture

`isValidReading` (`temp_logic.cpp`, lignes 78 à 85) écarte les valeurs
fausses. Les constantes valent -127, -55, 125, 85 et 10 (tolérance) :

```cpp
bool isValidReading(float celsius, bool hasPrevious, float previous) {
    if (celsius == kDisconnected) return false;
    if (!(celsius >= kMin && celsius <= kMax)) return false;  // rejette aussi NaN
    if (celsius == kPowerOn) {
        return hasPrevious && fabsf(previous - kPowerOn) <= kPowerOnTolerance;
    }
    return true;
}
```

- **-127 °C** : sonde muette ou somme de contrôle (CRC) fausse.
- **Hors de -55 à 125 °C** (plage de la DS18B20) : la forme `!(...)`
  rejette aussi NaN, car toute comparaison avec NaN est fausse.
- **85 °C** : valeur de mise sous tension, suspecte sauf si la lecture
  valide précédente était proche (75 à 95 °C).

`==` sur des `float` est correct ici : -127 et 85 sont renvoyés
exactement. Quand la sonde passe hors ligne, `handleSensor()` oublie
`previous` (ligne 159) : rebranchée, elle renverra 85, alors rejeté.

## PublishPolicy et ProbeHealth

Publier toutes les 10 s remplirait l'historique de Home Assistant de
valeurs identiques. `PublishPolicy` (`temp_logic.cpp`, lignes 96 à 100)
décide :

```cpp
bool PublishPolicy::shouldPublish(int tenths, uint32_t nowMs) const {
    if (!hasPublished_) return true;
    if (abs(tenths - lastTenths_) >= minDelta_) return true;
    return (uint32_t)(nowMs - lastMs_) >= maxInterval_;
}
```

Par défaut (2 dixièmes, 300 000 ms), on publie la première valeur, puis
à chaque écart d'au moins 0,2 °C, et au moins toutes les 5 minutes (un
« battement de cœur », *heartbeat* en anglais). `reset()`, appelé à
chaque connexion MQTT, fait partir la valeur suivante. Les **dixièmes entiers** (`toTenths(21.4375)`
vaut 214) se comparent exactement, contrairement aux `float` (voir
« Pour aller plus loin »).

`ProbeHealth` (lignes 108 à 117) suit l'état de la sonde :

```cpp
    } else if (failures_ < maxFailures_ && ++failures_ >= maxFailures_) {
        online_ = false;
    }
    return online_ != before;
```

La sonde passe hors ligne après **3 échecs d'affilée** (une lecture
ratée isolée ne compte pas) et revient dès la première lecture valide.
`failures_ < maxFailures_` empêche le compteur (`uint8_t`) de déborder.
`record()` ne renvoie `true` qu'au **changement** d'état, signal pour
publier sur le sujet `probe` (voir chapitre Arduino 3).

## WiFi et MQTT : se reconnecter sans bloquer

Le core ESP32 reconnecte le WiFi tout seul, mais abandonne dans certains
cas (une box qui redémarre et refuse l'authentification). `handleWifi()`
(lignes 82 à 101) relance donc toutes les 30 s :

```cpp
            lastKick = millis();  // laisser d'abord le core se reconnecter
...
    if (connected) return;
    if (millis() - lastKick < WIFI_KICK_INTERVAL_MS) return;
    lastKick = millis();
...
    WiFi.reconnect();  // non bloquant
```

`lastKick` est `static` : il garde sa valeur d'un appel à l'autre. Sa
remise à l'heure à la perte du réseau laisse 30 s au core.

`handleMqtt()` (lignes 103 à 128) fait vivre la connexion au broker :

```cpp
    static uint32_t lastAttempt = 0 - RETRY_INTERVAL_MS;  // 1re tentative immediate
...
    if (mqtt.connected()) {
        mqtt.loop();
...
    if (millis() - lastAttempt < RETRY_INTERVAL_MS) return;
    const bool ok = mqtt.connect(deviceId, MQTT_USER, MQTT_PASS, topics.status, 0, true, "offline");
    lastAttempt = millis();  // delai compte depuis la fin de la tentative
...
    mqtt.subscribe(HA_STATUS_TOPIC);
```

- **`0 - RETRY_INTERVAL_MS`** vaut 4 294 962 296. Au premier appel,
  `millis() - lastAttempt` vaut `millis() + 5000`, toujours au moins
  5 000 : la première tentative est immédiate.
- **`lastAttempt = millis()` après `connect()`** : `connect()`, seule
  opération bloquante, dure au plus environ 8 s (3 s de TCP plus 5 s de
  réponse, réglés aux lignes 191 et 193 de `setup()`). En comptant
  depuis la **fin** de la tentative, on garantit 5 s de boucle normale
  entre deux essais, même si le broker ne répond jamais.
- **`mqtt.loop()`** lit les messages et entretient la connexion : il
  doit être appelé souvent, d'où l'interdiction de bloquer.
- **`mqtt.subscribe()` après chaque connexion** : la carte demande une
  session propre (voir chapitre Arduino 3), et l'abonnement à
  `homeassistant/status` est perdu avec la connexion. Il est donc
  renouvelé à chaque connexion réussie.

Les messages reçus arrivent dans le rappel `onMqttMessage()` (lignes 72
à 77) :

```cpp
    if (strcmp(topic, HA_STATUS_TOPIC) == 0 && length == 6 &&
        memcmp(payload, "online", 6) == 0) {
        discoveryRequested = true;  // Home Assistant a redemarre
    }
```

`payload` n'est pas terminé par un zéro : on compare la longueur, puis
les octets. Le rappel ne publie rien : il lève un **drapeau** que
`handleMqtt()` traite au tour suivant, hors de `mqtt.loop()`.

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| `src/` contre `lib/` | Code matériel mince d'un côté, logique pure testable sur PC de l'autre |
| `namespace temp` | Regroupe la logique, évite les collisions de noms |
| `credentials.h` | Secrets hors dépôt (`.gitignore`), modèle `credentials.h.example` versionné |
| `#ifndef ... #error` | Arrêter la compilation avec un message clair si un secret manque |
| `esp_read_mac()` | MAC lue dans l'eFuse, disponible avant le démarrage du WiFi |
| `setBufferSize(1024)` | Agrandir le tampon de PubSubClient (256 octets par défaut) |
| `loop()` non bloquante | Des `handle*()` qui décident vite et rendent la main |
| `millis() - last < INTERVAL` | Motif d'attente sans `delay()`, sûr au débordement (49,71 jours) |
| `setWaitForConversion(false)` | Conversion DS18B20 asynchrone (750 ms à 12 bits) |
| `isValidReading` | Rejette -127, NaN, hors -55..125, et 85 sans précédent proche |
| `PublishPolicy` | Publier si écart >= 0,2 °C ou toutes les 5 min ; `reset()` à la reconnexion |
| `toTenths` | Comparer des dixièmes entiers plutôt que des `float` |
| `ProbeHealth` | Hors ligne après 3 échecs d'affilée, en ligne au premier succès |
| `0 - RETRY_INTERVAL_MS` | Première tentative immédiate grâce à l'arithmétique non signée |
| Rappel + drapeau | Le rappel MQTT note l'événement, la boucle le traite |

## Pour aller plus loin

**Le piège des `float`.** Sur PC, `21.3f - 21.1f` vaut 0,199998856
(l'ESP32 utilise le même format IEEE 754 pour les `float`) : le test
`>= 0.2f` serait faux, alors que l'affichage montre bien 0,2 °C d'écart.
En dixièmes entiers, `213 - 211 = 2`, sans ambiguïté. C'est la raison
de `toTenths` dans `PublishPolicy`.

**Le piège des petits entiers.** La soustraction modulo ne fonctionne
que si le calcul reste dans le type non signé. Avec des `uint16_t`, le
C++ convertit d'abord les opérandes en `int` (promotion entière) : sur
un ESP32 ou un PC, où `int` fait 32 bits, `100 - 65000` vaut -64 900 et
non 636. Il faudrait écrire `(uint16_t)(a - b)`. C'est pour la même
raison que `shouldPublish` convertit explicitement
`(uint32_t)(nowMs - lastMs_)` : le code reste juste quelle que soit la
taille d'`int` sur la plateforme. Avec `uint32_t` partout, comme ici, le
piège ne se présente pas.

**Le cas `lastRead == 0`.** Dans `handleSensor()`, la condition
`lastRead != 0` sert au démarrage. Si, après un débordement, `millis()`
valait exactement 0 au moment d'une lecture, la lecture suivante
partirait sans attendre 10 s. La conséquence est une mesure en avance,
une fois tous les 49 jours au pire : ce cas est sans gravité.
`handleMqtt()` montre l'autre solution, sans cas particulier :
initialiser à `0 - INTERVALLE`.

**`loop()`, `delay(10)` et FreeRTOS.** Sur l'ESP32, le framework
Arduino s'appuie sur le système temps réel FreeRTOS : `loop()` est
appelée en boucle par une tâche, et la pile WiFi tourne dans d'autres
tâches. Le `delay(10)` en fin de `loop()` met la tâche en sommeil et
laisse le processeur aux autres.

**Pourquoi pas de `String`.** Le programme manipule des tableaux de
`char` de taille fixe (`deviceId[32]`, `payload[768]`) et `snprintf`,
jamais la classe `String` d'Arduino. Sur un microcontrôleur qui tourne
des mois, les allocations dynamiques répétées fragmentent la mémoire.
Avec des tampons fixes, la mémoire utilisée est connue à la compilation.

**Ce qui reste bloquant.** La résolution DNS du nom du broker (et mDNS
pour un nom en `.local`) n'est pas couverte par les délais d'attente de
`setup()`. Pour un appareil plus exigeant, on placerait la connexion
MQTT dans une tâche FreeRTOS séparée, ou on utiliserait une bibliothèque
MQTT asynchrone.

## Exercices

Aucun exercice ne demande la carte. L'exercice 1 se vérifie avec
`pio run` sur un projet PlatformIO vide (voir chapitre Arduino 2).

**Exercice 1 — Sans delay()** (sans carte). Ce sketch fait clignoter la LED et affiche une mesure
analogique, mais la LED ne change d'état que toutes les 10 s :

```cpp
#include <Arduino.h>

void setup() {
    Serial.begin(115200);
    pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
    Serial.println(analogRead(A0));
    delay(10000);
}
```

Réécrivez-le sans `delay()` long : la LED change d'état toutes les
500 ms et la mesure s'affiche toutes les 10 s, la première dès le
démarrage. Suivez le style du projet (une fonction `handle*()` par
tâche).

**Exercice 2 — Le débordement** (sans carte). Une lecture a eu lieu à `lastRead = 4 294 965 000`.
L'intervalle est de 10 000 ms. Calculez `millis() - lastRead` pour
`millis() = 3 000`, puis `millis() = 9 000`. Dans chaque cas, la
lecture suivante a-t-elle lieu ?

**Exercice 3 — Valider une lecture** (sans carte). Pour chaque appel, dites ce que renvoie
`isValidReading(celsius, hasPrevious, previous)` et pourquoi :

1. `(21.5, false, 0)`
2. `(-127, true, 20)`
3. `(85, false, 0)`
4. `(85, true, 21.5)`
5. `(85, true, 80)`
6. `(125.5, true, 20)`
7. `(84.9375, false, 0)`

**Exercice 4 — Quand publier** (sans carte). Une `PublishPolicy` par défaut reçoit, toutes les 10 s
à partir de `t = 0`, les valeurs en dixièmes 214, 215, 216, 216, 213.
Lesquelles sont publiées ? Si la température reste ensuite à 213, à
quel instant la publication suivante a-t-elle lieu ?

**Exercice 5 — Le bon dossier** (sans carte). Justifiez pourquoi `PublishPolicy` est dans `lib/` alors
que `handleWifi()` est dans `src/main.cpp`. Pourquoi `shouldPublish`
reçoit-elle `nowMs` en paramètre au lieu d'appeler `millis()` ?

### Solutions

**Solution 1**

Deux tâches, chacune avec son propre instant de
référence :

```cpp
#include <Arduino.h>

static const uint32_t BLINK_INTERVAL_MS = 500;
static const uint32_t READ_INTERVAL_MS = 10000;

static void handleLed() {
    static uint32_t lastToggle = 0;
    if (millis() - lastToggle < BLINK_INTERVAL_MS) return;
    lastToggle = millis();
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
}

static void handleRead() {
    static uint32_t lastRead = 0 - READ_INTERVAL_MS;  // 1re lecture immediate
    if (millis() - lastRead < READ_INTERVAL_MS) return;
    lastRead = millis();
    Serial.println(analogRead(A0));
}

void setup() {
    Serial.begin(115200);
    pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
    handleLed();
    handleRead();
    delay(10);
}
```

Les deux versions compilent avec `pio run` pour `seeed_xiao_esp32s3`.
L'initialisation `0 - READ_INTERVAL_MS` reprend l'astuce de
`handleMqtt()`. Ajouter une troisième tâche ne ralentit pas les deux
premières.

**Solution 2**

Le compteur a débordé entre les deux instants. Il
restait 4 294 967 296 - 4 294 965 000 = 2 296 ms avant le débordement :

- `3 000 - 4 294 965 000` = 2 296 + 3 000 = **5 296** : inférieur à
  10 000, on attend ;
- `9 000 - 4 294 965 000` = 2 296 + 9 000 = **11 296** : la lecture a
  lieu.

**Solution 3**

1. `true` : valeur normale, dans la plage.
2. `false` : -127, sonde absente ou CRC faux.
3. `false` : 85 sans lecture précédente, probablement la valeur de mise
   sous tension.
4. `false` : 85 alors que la précédente valait 21,5 ; l'écart (63,5)
   dépasse la tolérance de 10.
5. `true` : 85 après 80, écart de 5, le radiateur chauffe vraiment.
6. `false` : hors de la plage -55..125.
7. `true` : seul 85 exactement est suspect ; 84,9375 est une valeur
   normale (pas de 0,0625 °C à 12 bits).

**Solution 4**

À 0 s, 214 est publié (première valeur). À 10 s, 215 :
écart de 1 avec 214, rien. À 20 s, 216 : écart de 2, publié. À 30 s,
216 : écart nul, rien. À 40 s, 213 : écart de 3 avec 216, publié. La
température restant à 213, la publication suivante est le battement de
cœur, 5 minutes après la dernière : à 340 s (40 + 300).

**Solution 5**

`PublishPolicy` est de la logique pure : elle ne prend
que des entiers et ne touche à aucun matériel. Elle compile sur PC et se
teste avec des cas choisis. `handleWifi()` appelle `WiFi.status()` et
`WiFi.reconnect()`, qui n'existent que sur l'ESP32 : elle ne peut vivre
que dans `src/`. `shouldPublish` reçoit l'heure en paramètre pour rester
indépendante de `millis()` : un test peut lui passer n'importe quel
instant (5 minutes plus tard, juste avant le débordement...) sans
attendre réellement.
