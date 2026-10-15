# Arduino 5 — Les tests unitaires

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - expliquer pourquoi on teste du code embarqué, et pourquoi on le fait sur le PC ;
> - lire une suite de tests Unity (`setUp`, `TEST_ASSERT_*`, `RUN_TEST`) ;
> - lancer les tests avec `pio test -e native` et lire un échec ;
> - écrire un nouveau test pour un cas limite, et vérifier qu'il sait échouer.
>
> **Durée de lecture** : environ 1 h 15, exercices compris.

---

Avec l'IDE Arduino, on vérifie un programme en le téléversant sur la
carte et en regardant le moniteur série. Cette méthode a ses limites :
elle est lente, elle demande le matériel, et elle ne montre que les
situations qui se présentent pendant l'essai.

Ce chapitre présente une autre méthode : les **tests unitaires**. De
petits programmes appellent les fonctions du projet avec des valeurs
choisies et vérifient les résultats. Ils tournent sur votre PC, en
quelques secondes, sans carte. Le projet `DS18B20_MQTT` en contient 24.

## Pourquoi tester du code embarqué

Un bogue dans la logique d'un capteur se voit rarement tout de suite.
Trois exemples tirés du projet :

- **L'arrondi.** La sonde renvoie 21,45 °C ; le programme publie des
  dixièmes de degré. Faut-il publier 21,4 ou 21,5 ? Une conversion
  maladroite tronque au lieu d'arrondir, et l'erreur passe inaperçue
  sur un affichage.
- **Les cas limites.** La DS18B20 renvoie 85 °C à la mise sous tension
  (voir chapitre Arduino 4). Le programme doit rejeter cette valeur,
  sauf si la température était déjà proche de 85 °C. Pour vérifier cela
  sur la carte, il faudrait chauffer la sonde à 80 °C.
- **Le débordement.** `millis()` revient à zéro au bout d'environ
  49,7 jours (voir chapitre Arduino 4). Personne n'attend sept semaines
  devant son moniteur série pour vérifier que le battement de cœur survit.

S'ajoutent les **régressions** : une modification qui casse ce qui
marchait. En relançant les tests après chaque modification, on les voit
immédiatement. Un test unitaire ne remplace pas l'essai sur la carte :
il le complète, en couvrant les cas rares, rapidement et à chaque fois.

## Tester sur le PC : l'environnement `native`

Le fichier `platformio.ini` du projet déclare deux environnements (voir
chapitre Arduino 2). Le second sert aux tests :

```ini
[env:native]
platform = native
build_flags = -std=c++17 -Wall -Wextra
lib_deps =
    bblanchon/ArduinoJson@^7.0.0
```

- `platform = native` : le code est compilé pour votre PC, avec le
  compilateur du système (`g++` sous Linux), et non pour l'ESP32-S3.
- `build_flags` : la norme C++17 et les avertissements (`-Wall
  -Wextra`) ; un avertissement signale souvent un vrai problème.
- `lib_deps` : seulement ArduinoJson, qui fonctionne aussi hors
  Arduino. Ni OneWire, ni DallasTemperature, ni PubSubClient : ces
  bibliothèques parlent au matériel et ne compilent pas sur un PC.

Cela n'est possible que grâce au découpage du projet (voir chapitre
Arduino 4) : `src/main.cpp` contient tout ce qui touche au matériel,
`lib/temp_logic/` la logique pure, sans `#include <Arduino.h>`. Lors
d'un test, PlatformIO ne compile pas `src/` : il compile la suite de
tests et les bibliothèques de `lib/` qu'elle inclut.

On ne teste pas ainsi la lecture réelle sur le bus 1-Wire, le WiFi, le
broker ni le câblage. En revanche, toute la logique de décision
(validation, arrondi, publication, santé de la sonde, JSON de
découverte) est vérifiée en quelques secondes, sur n'importe quel PC et
sur le serveur d'intégration continue (voir chapitre Arduino 6).

## Unity, le cadre de test

PlatformIO utilise par défaut **Unity**, un cadre de test en C très
léger, conçu pour l'embarqué. Le projet ne le déclare pas : au premier
`pio test`, PlatformIO l'installe tout seul
(`throwtheswitch/Unity @ ^2.6.1`).

Une suite Unity est un programme C++ ordinaire, avec une fonction
`main()` :

| Élément | Rôle |
|---------|------|
| `#include <unity.h>` | Déclare les macros de Unity |
| `void setUp()` | Appelée avant chaque test (préparation commune) |
| `void tearDown()` | Appelée après chaque test (nettoyage) |
| `void test_xxx()` | Un test : une fonction sans paramètre |
| `TEST_ASSERT_TRUE(x)` / `TEST_ASSERT_FALSE(x)` | Vérifie qu'une condition est vraie / fausse |
| `TEST_ASSERT_EQUAL_INT(attendu, obtenu)` | Compare deux entiers |
| `TEST_ASSERT_EQUAL_STRING(attendu, obtenu)` | Compare deux chaînes C |
| `UNITY_BEGIN()` | Démarre la suite |
| `RUN_TEST(test_xxx)` | Exécute un test et note son résultat |
| `UNITY_END()` | Affiche le bilan et renvoie le nombre d'échecs |

Dès qu'une assertion échoue, Unity abandonne le test en cours, note
l'échec et passe au test suivant. L'ordre des arguments compte : la
valeur **attendue** d'abord, la valeur **obtenue** ensuite. Le message
d'échec en dépend. Dans le projet, `setUp` et `tearDown` sont vides
(chaque test crée ses propres objets), mais Unity exige leur présence.

PlatformIO range les tests dans `test/`, **une suite par dossier**
dont le nom commence par `test_` :

```
test/
+-- test_reading/test_main.cpp     validation, arrondi, formatage (8 tests)
+-- test_publish/test_main.cpp     PublishPolicy (6 tests)
+-- test_probe/test_main.cpp       ProbeHealth (6 tests)
+-- test_discovery/test_main.cpp   sujets et JSON de découverte (4 tests)
```

Chaque dossier est compilé en un programme séparé, puis exécuté.

## Lecture d'une suite : `test_reading`

Voici l'essentiel de `test/test_reading/test_main.cpp`
([source](https://github.com/pguinet/arduino/blob/1af068f/sketches/XIAO-ESP32-S3/DS18B20_MQTT/test/test_reading/test_main.cpp)) :

```cpp
#include <math.h>
#include <unity.h>
#include "temp_logic.h"

using namespace temp;

void setUp() {}
void tearDown() {}
...
void test_real_85_accepted_when_previous_is_close() {
    TEST_ASSERT_TRUE(isValidReading(85.0f, true, 84.5f));
    TEST_ASSERT_TRUE(isValidReading(85.0f, true, 75.0f));
    TEST_ASSERT_FALSE(isValidReading(85.0f, true, 74.9f));
}
...
void test_to_tenths_rounds_half_away_from_zero() {
    TEST_ASSERT_EQUAL_INT(214, toTenths(21.4375f));
    TEST_ASSERT_EQUAL_INT(215, toTenths(21.45f));
    TEST_ASSERT_EQUAL_INT(0, toTenths(0.04f));
    TEST_ASSERT_EQUAL_INT(-31, toTenths(-3.0625f));
    TEST_ASSERT_EQUAL_INT(-5, toTenths(-0.5f));
}

void test_format_tenths() {
    char b[8];
    formatTenths(214, b, sizeof b);  TEST_ASSERT_EQUAL_STRING("21.4", b);
    formatTenths(0, b, sizeof b);    TEST_ASSERT_EQUAL_STRING("0.0", b);
    formatTenths(-5, b, sizeof b);   TEST_ASSERT_EQUAL_STRING("-0.5", b);
    formatTenths(-31, b, sizeof b);  TEST_ASSERT_EQUAL_STRING("-3.1", b);
    formatTenths(1250, b, sizeof b); TEST_ASSERT_EQUAL_STRING("125.0", b);
}

int main() {
    UNITY_BEGIN();
    RUN_TEST(test_disconnected_is_rejected);
    ...
    RUN_TEST(test_format_tenths);
    return UNITY_END();
}
```

Quelques remarques :

- **Les noms des tests sont une documentation.**
  `test_real_85_accepted_when_previous_is_close` se lit comme une
  règle : « un vrai 85 est accepté quand la lecture précédente est
  proche ». La liste des tests résume le comportement attendu.
- **Les valeurs sont choisies aux frontières.** La tolérance autour de
  85 °C est de 10 degrés : le test essaie 75,0 (accepté, juste dans la
  limite) et 74,9 (rejeté, juste au-delà). Un bogue de frontière, `<`
  au lieu de `<=`, serait détecté.
- **Les valeurs viennent du capteur réel** : 21,4375 et -3,0625 sont
  des multiples de 1/16 de degré, la résolution de la DS18B20.
- **Les cas pièges sont explicites.** `-0.5` est un piège classique :
  la partie entière de -5 / 10 vaut 0, et un formatage naïf perdrait
  le signe moins.

## Lancer les tests

Depuis le dossier du projet :

```
$ pio test -e native
...
Collected 4 tests

Processing test_reading in native environment
...
test/test_reading/test_main.cpp:61: test_disconnected_is_rejected	[PASSED]
...
test/test_reading/test_main.cpp:68: test_format_tenths	[PASSED]
---------------- native:test_reading [PASSED] Took 4.98 seconds ----------------
...
native         test_discovery  PASSED    00:00:03.573
================= 24 test cases: 24 succeeded in 00:00:11.395 =================
```

« Collected 4 tests » compte les **suites** (les dossiers) ; le bilan
final compte les **cas de test** (les fonctions) : 24. Chaque ligne
indique le fichier, le numéro de la ligne `RUN_TEST`, le nom du test
et son résultat.

Deux options servent souvent :

- `-f test_reading` (*filter*) : ne lance que la suite indiquée. Pratique
  quand on travaille sur une seule partie du code.
- `-v` : affiche la sortie brute de Unity (`8 Tests 0 Failures 0
  Ignored`, puis `OK`).

L'option `-e native` est indispensable : sans elle, PlatformIO prend
l'environnement par défaut, `xiao`, et chercherait une carte branchée.

## Lire un échec

Pour voir un échec, cassez volontairement `toTenths`, dans
`lib/temp_logic/temp_logic.cpp`. Remplacez l'arrondi par une simple
conversion en entier, qui tronque :

```cpp
int toTenths(float celsius) {
    return (int)(celsius * 10.0f);   // au lieu de (int)lroundf(celsius * 10.0f)
}
```

Puis relancez la suite concernée :

```
$ pio test -e native -f test_reading
...
test/test_reading/test_main.cpp:66: test_ordinary_readings_accepted	[PASSED]
test/test_reading/test_main.cpp:44: test_to_tenths_rounds_half_away_from_zero: Expected 215 Was 214	[FAILED]
test/test_reading/test_main.cpp:68: test_format_tenths	[PASSED]
Program received signal SIGHUP (Hangup)
--------------- native:test_reading [ERRORED] Took 1.42 seconds ---------------
...
============= 9 test cases: 1 failed, 7 succeeded in 00:00:01.422 =============
```

La ligne utile est celle marquée `[FAILED]` :

- `test_main.cpp:44` : pour un échec, le numéro est celui de
  l'**assertion** qui a échoué, et non plus celui du `RUN_TEST`. La
  ligne 44 est `TEST_ASSERT_EQUAL_INT(215, toTenths(21.45f));`.
- `Expected 215 Was 214` : on attendait 215, on a obtenu 214. Tronquer
  214,5 donne 214 ; l'arrondi donnait 215.

Le reste est trompeur. `UNITY_END()` renvoie le nombre d'échecs (ici 1)
comme code de retour du programme ; PlatformIO prend ce code pour un
numéro de signal, et le signal 1 se nomme SIGHUP. Aucun signal n'a été
envoyé : avec deux échecs, vous liriez `SIGINT` (signal 2). D'où aussi
l'état `ERRORED` et le neuvième « cas » du bilan. Retenez : `[FAILED]`
désigne le test fautif, et `pio test` se termine avec le code 1, ce qui
suffit à faire échouer l'intégration continue (voir chapitre Arduino 6).

Annulez la modification avant de continuer (voir module additionnel
Git) :

```
$ git restore lib/temp_logic/temp_logic.cpp
```

## Écrire un test

Pour une fonction donnée, cherchez trois familles de cas :

1. **le cas nominal** : une valeur ordinaire (21,4 °C) ;
2. **les limites** : les frontières des intervalles (-55, 125, la
   tolérance de 10 degrés, l'intervalle de 300000 ms) ;
3. **les erreurs** : les valeurs que le capteur ne devrait pas renvoyer
   mais renvoie quand même (-127, 85, NaN).

Prenons `PublishPolicy` (voir chapitre Arduino 4). La suite
`test_publish` vérifie déjà le battement de cœur à 299999 ms et à exactement
300000 ms après une publication. Un cas manque : après une deuxième
publication, le délai doit repartir de **cette** publication, et non de
la première. Ajoutez ce test dans `test/test_publish/test_main.cpp`,
avant `main()` :

```cpp
void test_heartbeat_restarts_from_last_publish() {
    PublishPolicy p;
    p.markPublished(214, 1000);
    p.markPublished(214, 301000);  // publication du heartbeat
    TEST_ASSERT_FALSE(p.shouldPublish(214, 301000 + 299999));
    TEST_ASSERT_TRUE(p.shouldPublish(214, 301000 + 300000));
}
```

Puis ajoutez `RUN_TEST(test_heartbeat_restarts_from_last_publish);`
dans `main()`, après le dernier `RUN_TEST` : un test oublié là n'est
jamais exécuté, sans aucun message. Lancez la suite :

```
$ pio test -e native -f test_publish
...
test/test_publish/test_main.cpp:64: test_reset_forces_next_publish	[PASSED]
test/test_publish/test_main.cpp:65: test_heartbeat_restarts_from_last_publish	[PASSED]
---------------- native:test_publish [PASSED] Took 0.70 seconds ----------------
...
================== 7 test cases: 7 succeeded in 00:00:00.705 ==================
```

Un test qui passe du premier coup ne prouve pas grand-chose : il faut
vérifier qu'il **sait échouer**. Introduisez un bogue plausible dans
`markPublished` : ne mémoriser l'heure que lors de la toute première
publication.

```cpp
void PublishPolicy::markPublished(int tenths, uint32_t nowMs) {
    if (!hasPublished_) lastMs_ = nowMs;
    hasPublished_ = true;
    lastTenths_ = tenths;
}
```

Les six tests d'origine passent toujours : aucun n'appelle
`markPublished` deux fois. Le nouveau test, lui, détecte le bogue :

```
test/test_publish/test_main.cpp:64: test_reset_forces_next_publish	[PASSED]
test/test_publish/test_main.cpp:53: test_heartbeat_restarts_from_last_publish: Expected FALSE Was TRUE	[FAILED]
```

C'est exactement ce qu'on attend d'un nouveau test : il couvre un cas
que la suite ne voyait pas. Annulez le bogue avec
`git restore lib/temp_logic/temp_logic.cpp`, et gardez le test le temps
de la lecture. Le `git restore` demandé à la fin de chaque exercice le
retirera aussi : les exercices repartent des 24 tests du dépôt.

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| Test unitaire | Petit programme qui appelle une fonction et vérifie son résultat |
| Régression | Ce qui marchait et ne marche plus après une modification |
| `[env:native]` | Environnement qui compile pour le PC, sans le matériel |
| Unity | Cadre de test par défaut de PlatformIO |
| `setUp()` / `tearDown()` | Appelées avant / après chaque test (obligatoires, même vides) |
| `TEST_ASSERT_TRUE` / `_FALSE` | Vérifier une condition |
| `TEST_ASSERT_EQUAL_INT` / `_STRING` | Comparer : valeur attendue d'abord, obtenue ensuite |
| `UNITY_BEGIN()`, `RUN_TEST()`, `UNITY_END()` | Démarrer, exécuter un test, faire le bilan |
| `test/test_xxx/` | Un dossier = une suite = un programme |
| `pio test -e native` | Lancer toutes les suites sur le PC |
| `pio test -e native -f test_xxx` | Lancer une seule suite |
| `pio test ... -v` | Afficher la sortie brute de Unity |
| `[FAILED]` | Fichier, ligne de l'assertion, valeurs attendue et obtenue |
| Cas nominal, limites, erreurs | Les trois familles de cas à tester |

## Pour aller plus loin

**Les autres assertions.** Unity en propose beaucoup d'autres. Le
projet utilise aussi `TEST_ASSERT_EQUAL` (entier générique) et
`TEST_ASSERT_GREATER_THAN` dans `test_discovery`. Pour les nombres à
virgule, `TEST_ASSERT_FLOAT_WITHIN(delta, attendu, obtenu)` tolère un
écart, car comparer deux `float` avec `==` est piégeux (voir chapitre
Arduino 4). Le projet contourne la question en testant des dixièmes
entiers.

**Tester sur la carte.** PlatformIO sait aussi exécuter les suites sur
la carte elle-même (voir chapitre Arduino 6).

**Les doublures.** Pour tester du code qui appelle le matériel (lire la
sonde, publier sur MQTT), on le fait dépendre d'une interface, puis on
fournit au test une fausse implémentation (*mock* ou *fake*) qui
renvoie des valeurs choisies. C'est plus de travail ; le découpage du
projet évite d'en avoir besoin.

**Le développement piloté par les tests.** La démarche TDD (*Test
Driven Development*) inverse l'ordre : on écrit d'abord un test qui
échoue, puis le code minimal qui le fait passer, puis on nettoie.
L'exemple de la section « Écrire un test » en reprend l'idée clé : un
test ne vaut que s'il a été vu échouer.

**La couverture.** Des outils comme `gcov` mesurent les lignes de code
exécutées par les tests. Une couverture de 100 % ne garantit pas
l'absence de bogue (le bogue de `markPublished` ci-dessus passait les
24 tests, alors que toutes ses lignes étaient exécutées), mais une
ligne jamais exécutée n'est jamais vérifiée.

**Documentation.** La page « Unit Testing » de la documentation de
PlatformIO (https://docs.platformio.org/en/latest/advanced/unit-testing/)
détaille les options de `pio test` et les autres cadres de test
disponibles (GoogleTest, doctest).

## Exercices

Tous les exercices se font sans carte, dans votre clone du dépôt
`arduino`, dossier `sketches/XIAO-ESP32-S3/DS18B20_MQTT`. Annulez vos
modifications avec `git restore .` à la fin de chaque exercice : cela
retire aussi le test ajouté dans la section « Écrire un test ».

**Exercice 1 — Lancer les tests** (sans carte). Lancez `pio test -e native`. Combien de suites et
combien de cas de test sont exécutés ? Relancez seulement la suite
`test_probe` avec l'option `-v` : quelles lignes Unity affiche-t-il à
la fin ?

**Exercice 2 — La tolérance de 85 °C** (sans carte). Dans `test_reading`, ajoutez deux tests : une lecture
de 85 °C après une lecture valide de 80 °C doit être acceptée ; une
lecture de 85 °C après 20 °C doit être rejetée. Vérifiez qu'ils
passent. Puis, dans `temp_logic.cpp`, réduisez la tolérance
`kPowerOnTolerance` de 10 à 2 degrés : quels tests échouent ?

**Exercice 3 — Les valeurs négatives** (sans carte). Le cas `formatTenths(-5)` -> `"-0.5"` est-il déjà
testé ? Ajoutez un test pour deux autres valeurs négatives sensibles :
-1 (-0,1 °C) et -550 (-55,0 °C, la limite basse de la DS18B20).

**Exercice 4 — Un compteur non remis à zéro** (sans carte). Dans `ProbeHealth::record`, mettez en commentaire la
ligne `failures_ = 0;`. Quel test échoue, et pourquoi ? Pourquoi
`test_recovers_after_offline` passe-t-il quand même ?

**Exercice 5 — Un cas non couvert** (sans carte). Proposez un cas que les 24 tests actuels ne couvrent
pas, et écrivez le test correspondant.

### Solutions

**Solution 1**

4 suites (« Collected 4 tests ») et 24 cas de test
(« 24 test cases: 24 succeeded »). Avec `pio test -e native -f
test_probe -v`, Unity termine par :

```
-----------------------
6 Tests 0 Failures 0 Ignored 
OK
```

**Solution 2**

Les deux tests, avant `main()` :

```cpp
void test_85_after_80_accepted() {
    TEST_ASSERT_TRUE(isValidReading(85.0f, true, 80.0f));
}

void test_85_after_20_rejected() {
    TEST_ASSERT_FALSE(isValidReading(85.0f, true, 20.0f));
}
```

et dans `main()` :

```cpp
    RUN_TEST(test_85_after_80_accepted);
    RUN_TEST(test_85_after_20_rejected);
```

Avec une tolérance de 2 degrés, 80 n'est plus « proche » de 85 :

```
test/test_reading/test_main.cpp:22: test_real_85_accepted_when_previous_is_close: Expected TRUE Was FALSE	[FAILED]
...
test/test_reading/test_main.cpp:60: test_85_after_80_accepted: Expected TRUE Was FALSE	[FAILED]
test/test_reading/test_main.cpp:78: test_85_after_20_rejected	[PASSED]
Program received signal SIGINT (Interrupt)
```

Le test existant échoue sur 75,0 (ligne 22), le vôtre sur 80. Le rejet
après 20 °C reste juste. Le signal 2, SIGINT, correspond aux deux
échecs (voir « Lire un échec »).

**Solution 3**

Oui : `test_format_tenths` le vérifie déjà. Les deux
nouveaux cas :

```cpp
void test_format_small_negatives() {
    char b[8];
    formatTenths(-1, b, sizeof b);   TEST_ASSERT_EQUAL_STRING("-0.1", b);
    formatTenths(-550, b, sizeof b); TEST_ASSERT_EQUAL_STRING("-55.0", b);
}
```

sans oublier `RUN_TEST(test_format_small_negatives);`. Le test passe.
Le tampon de 8 caractères suffit : `"-55.0"` en occupe 6 avec le
caractère nul final.

**Solution 4**

Seul `test_valid_reading_resets_failure_count` échoue :

```
test/test_probe/test_main.cpp:40: test_valid_reading_resets_failure_count: Expected TRUE Was FALSE	[FAILED]
```

Sans la remise à zéro, les échecs s'accumulent malgré la lecture
valide intercalée : après deux échecs, une réussite laisse le compteur
à 2, et l'échec suivant le porte à 3. La sonde passe hors ligne alors
qu'elle n'a jamais échoué trois fois d'affilée. `test_recovers_after_offline` passe car il
ne vérifie que le retour en ligne, qui ne dépend pas du compteur : une
lecture valide met toujours `online_` à vrai.

**Solution 5**

Plusieurs réponses sont possibles. Par exemple, aucun
test ne construit un `PublishPolicy` avec d'autres paramètres que ceux
par défaut (2 dixièmes, 300000 ms) :

```cpp
void test_custom_parameters() {
    PublishPolicy p(5, 60000);
    p.markPublished(200, 0);
    TEST_ASSERT_FALSE(p.shouldPublish(204, 1000));
    TEST_ASSERT_TRUE(p.shouldPublish(205, 1000));
    TEST_ASSERT_FALSE(p.shouldPublish(200, 59999));
    TEST_ASSERT_TRUE(p.shouldPublish(200, 60000));
}
```

Autres pistes : un `ProbeHealth(5)`, ou `formatTenths` avec un tampon
trop petit.
