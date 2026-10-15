# Arduino 6 — Qualité et intégration continue

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - expliquer ce qu'un analyseur statique comme cppcheck trouve sans exécuter le code ;
> - lancer `pio check`, lire ses défauts et justifier une suppression en ligne ;
> - définir l'intégration continue et le vocabulaire de GitHub Actions (workflow, job, step, runner, action) ;
> - lire le fichier `ci.yml` du projet, ligne par ligne ;
> - retrouver dans l'onglet Actions le step qui a échoué et la ligne de log qui l'explique.
>
> **Durée de lecture** : environ 1 h 30, exercices compris.

---

Les tests unitaires vérifient que le code fait ce qu'on attend (voir
chapitre Arduino 5). Restent deux questions : le code contient-il des
maladresses que les tests n'exercent pas ? Et qui garantit que tests,
compilation et vérifications tournent à chaque modification ? La
première relève de l'**analyse statique**, la seconde de
l'**intégration continue**. Rien dans ce chapitre ne demande de carte.

## L'analyse statique avec cppcheck

Un **analyseur statique** lit le code sans l'exécuter. Il raisonne sur
les valeurs possibles des variables et l'usage des paramètres, et
signale ce qui ressemble à une erreur ou à une maladresse, même dans
une branche que les tests ne parcourent jamais. **cppcheck** est un
analyseur libre pour le C et le C++. PlatformIO l'intègre : `pio check`
le télécharge au besoin et lui passe les options de compilation de
l'environnement choisi (définitions `-D`, chemins d'inclusion).

### La configuration dans platformio.ini

L'environnement `xiao` du projet contient trois lignes consacrées à
l'analyse
([platformio.ini](https://github.com/pguinet/arduino/blob/1af068f/sketches/XIAO-ESP32-S3/DS18B20_MQTT/platformio.ini)) :

```ini
check_tool = cppcheck
check_flags = cppcheck: --enable=warning,style,performance --inline-suppr --suppress=*:*/.pio/*
check_src_filters = +<src/main.cpp> +<lib/temp_logic/>
```

- `check_tool` choisit l'outil (PlatformIO propose aussi `clangtidy`).
- `check_flags` passe des options à cppcheck. `--enable=...` ajoute aux
  erreurs, toujours actives, trois familles de contrôles : les
  avertissements (code probablement faux), le style (code inutile ou
  maladroit) et la performance (copie évitable). `--inline-suppr`
  autorise les suppressions en ligne (voir plus bas).
  `--suppress=*:*/.pio/*` ignore les défauts du dossier `.pio`, où sont
  rangées les bibliothèques de `lib_deps` (voir chapitre Arduino 2).
- `check_src_filters` limite l'analyse à `src/main.cpp` et à
  `lib/temp_logic/`.

### Lancer l'analyse

Depuis le dossier du projet :

```
$ pio check -e xiao --skip-packages --fail-on-defect=low
Checking xiao > cppcheck (platform: https://github.com/pioarduino/platform-espressif32/releases/download/51.03.07/platform-espressif32.zip; board: seeed_xiao_esp32s3; framework: arduino)
--------------------------------------------------------------------------------
No defects found
========================== [PASSED] Took 0.52 seconds ==========================

Environment    Tool      Status    Duration
-------------  --------  --------  ------------
xiao           cppcheck  PASSED    00:00:00.524
========================= 1 succeeded in 00:00:00.524 =========================
```

- `-e xiao` : cppcheck voit les mêmes définitions que le compilateur
  de la carte (`ARDUINO_XIAO_ESP32S3`, `ESP32`...).
- `--skip-packages` exclut les paquets de PlatformIO (framework
  Arduino, chaîne de compilation) : leurs défauts ne vous concernent
  pas, et l'analyse est bien plus rapide.
- `--fail-on-defect=low` fait échouer la commande (code de retour non
  nul) dès le premier défaut, quelle que soit sa gravité.

### Lire un défaut

PlatformIO classe chaque défaut selon trois gravités : `high` pour une
erreur de cppcheck, `medium` pour un avertissement, `low` pour le
style et la performance. Pour voir un défaut, ajoutons une variable
inutile dans `toTenths`, dans `lib/temp_logic/temp_logic.cpp` :

```cpp
int toTenths(float celsius) {
    int arrondi = 0;
    return (int)lroundf(celsius * 10.0f);
}
```

L'analyse échoue :

```
$ pio check -e xiao --skip-packages --fail-on-defect=low
Checking xiao > cppcheck (platform: ...; board: seeed_xiao_esp32s3; framework: arduino)
--------------------------------------------------------------------------------
lib/temp_logic/temp_logic.cpp:27: [low:style] Variable 'arrondi' is assigned a value that is never used. [unreadVariable]
========================== [FAILED] Took 0.28 seconds ==========================

Component        HIGH    MEDIUM    LOW
--------------  ------  --------  -----
lib/temp_logic    0        0        1
...
==================== 1 failed, 0 succeeded in 00:00:00.276 ====================
```

Chaque défaut donne le fichier et la ligne, la gravité et la famille
(`[low:style]`), le message, puis l'**identifiant** du contrôle
(`unreadVariable`). Sans `--fail-on-defect`, le défaut serait affiché
mais la commande finirait par `PASSED`, avec un code de retour nul.

### Supprimer un défaut, en le justifiant

Parfois, cppcheck a raison en général mais tort dans un cas précis. Le
rappel MQTT de `src/main.cpp` en est un exemple
([main.cpp](https://github.com/pguinet/arduino/blob/1af068f/sketches/XIAO-ESP32-S3/DS18B20_MQTT/src/main.cpp)) :

```cpp
// Signature imposee par PubSubClient (pas de const possible).
// cppcheck-suppress constParameterCallback
static void onMqttMessage(char *topic, byte *payload, unsigned int length) {
```

La fonction ne modifie ni `topic` ni `payload` : cppcheck propose de
les déclarer `const`. Mais c'est un **rappel** (*callback*) : la
bibliothèque PubSubClient l'appelle et impose cette signature exacte.
Le commentaire `// cppcheck-suppress <identifiant>`, juste avant la
ligne, fait taire ce seul contrôle sur cette seule ligne (il exige
`--inline-suppr`). Supprimez toujours un identifiant précis, et
écrivez au-dessus **pourquoi** le défaut est accepté : un relecteur
doit pouvoir en juger sans enquêter.

## L'intégration continue

Sur votre PC, vous pouvez oublier les tests avant un commit, ou
dépendre d'une bibliothèque que vous seul avez installée. L'**intégration
continue** (*CI*) fait vérifier chaque modification, automatiquement,
sur une machine neuve : à chaque push, un serveur récupère le dépôt,
installe les outils, teste, compile et analyse. Le résultat s'affiche à
côté du commit et de la pull request (voir module additionnel Git).

**GitHub Actions** est le service de CI intégré à GitHub. Son
vocabulaire :

| Terme | Sens |
|-------|------|
| Workflow | Un fichier YAML dans `.github/workflows/` : quand se déclencher, et quoi faire |
| Run | Une exécution d'un workflow, déclenchée par un événement (push, pull request) |
| Job | Un groupe d'étapes exécutées sur une même machine ; les jobs tournent en parallèle sauf dépendance |
| Step | Une étape d'un job : une commande shell (`run:`) ou une action (`uses:`) |
| Runner | La machine qui exécute un job ; `ubuntu-latest` est une VM Ubuntu neuve, fournie par GitHub |
| Action | Une étape réutilisable publiée sur GitHub, par exemple `actions/checkout` qui récupère le dépôt |

## Le fichier ci.yml décortiqué

Le dépôt `arduino` contient plusieurs projets ; un seul workflow les
vérifie tous
([ci.yml](https://github.com/pguinet/arduino/blob/1af068f/.github/workflows/ci.yml)).
Voici ses 66 premières lignes, telles qu'au commit `1af068f` :

```yaml
# Tests et qualite : projets PlatformIO avec tests natifs + agent Python
# de Claude_Dashboard. Le firmware est compile avec un credentials.h tire de
# credentials.h.example (le vrai n'est jamais dans le depot).

name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  discover:
    name: Projets PlatformIO testes
    runs-on: ubuntu-latest
    outputs:
      projects: ${{ steps.find.outputs.projects }}
    steps:
      - uses: actions/checkout@v7
      # Tout projet qui declare un [env:native] a des tests natifs.
      - id: find
        run: |
          projects=$(grep -rl --include=platformio.ini '^\[env:native\]' sketches \
            | xargs -n1 dirname | sort | jq -R . | jq -cs .)
          echo "projects=$projects" >> "$GITHUB_OUTPUT"
          echo "Projets : $projects"

  platformio:
    name: ${{ matrix.project }}
    needs: discover
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        project: ${{ fromJSON(needs.discover.outputs.projects) }}
    defaults:
      run:
        working-directory: ${{ matrix.project }}
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-python@v7
        with:
          python-version: "3.12"
      - uses: actions/cache@v6
        with:
          path: ~/.platformio
          key: pio-${{ runner.os }}-${{ hashFiles(format('{0}/platformio.ini', matrix.project)) }}
      - name: Installer PlatformIO
        run: pip install platformio==6.1.19
      - name: credentials.h factice
        run: cp "$GITHUB_WORKSPACE/sketches/common/credentials.h.example" src/credentials.h
      - name: Tests natifs
        run: pio test -e native
      - name: Environnement de la carte
        id: env
        run: |
          env=$(python -c "import configparser; c = configparser.ConfigParser(); \
            c.read('platformio.ini'); print(c['platformio']['default_envs'].split(',')[0].strip())")
          echo "name=$env" >> "$GITHUB_OUTPUT"
      - name: Compilation du firmware
        run: pio run -e ${{ steps.env.outputs.name }}
      - name: cppcheck
        run: pio check -e ${{ steps.env.outputs.name }} --skip-packages --fail-on-defect=low
```

Le fichier se termine par un troisième job, `claude-dash-agent`, qui
vérifie le serveur Python d'un autre projet du dépôt ; il ne concerne
pas ce module.

### Déclencheurs et permissions

- `on:` liste les événements qui lancent le workflow : un push sur la
  branche `main`, et toute pull request, quelle que soit la branche
  visée. Un push sur une autre branche ne déclenche rien tant qu'aucune
  pull request n'est ouverte pour elle.
- `permissions: contents: read` limite le jeton confié au workflow à
  la lecture du dépôt (moindre privilège : une étape compromise ne
  pourrait rien pousser).

### Le job discover : trouver les projets à vérifier

Le job `discover` calcule la liste des projets : tout projet qui
déclare un `[env:native]` a des tests natifs.

1. `grep -rl --include=platformio.ini '^\[env:native\]' sketches` liste
   les `platformio.ini` qui contiennent cette ligne ;
2. `xargs -n1 dirname` garde le dossier de chacun, `sort` les trie ;
3. `jq -R .` transforme chaque ligne en chaîne JSON, `jq -cs .` les
   rassemble en un tableau JSON compact ;
4. `echo "projects=..." >> "$GITHUB_OUTPUT"` publie le résultat comme
   **sortie** du step `find` ; la clé `outputs:` du job la remonte au
   niveau du job.

Le log affiche
`Projets : ["sketches/JC3248W535C/Claude_Dashboard","sketches/XIAO-ESP32-S3/DS18B20_MQTT"]`.
Un nouveau projet testé est donc vérifié sans toucher au workflow.

### Le job platformio : une matrice de projets

- `needs: discover` attend la fin de `discover` et donne accès à ses
  sorties (`needs.discover.outputs.projects`).
- `strategy.matrix` crée **une copie du job par valeur** de la liste.
  `fromJSON(...)` convertit la chaîne JSON en vraie liste : la matrice
  est dynamique. Avec deux projets, on obtient deux jobs en parallèle,
  nommés d'après le projet grâce à `name: ${{ matrix.project }}`.
- `fail-fast: false` laisse tourner les autres jobs de la matrice quand
  l'un échoue (par défaut, GitHub les annulerait).
- `defaults.run.working-directory` fait exécuter chaque `run:` dans le
  dossier du projet : `pio` y trouve son `platformio.ini`.

### Les steps

1. `actions/checkout@v7` récupère le dépôt (`@v7` : version de
   l'action) ; `actions/setup-python@v7` installe Python 3.12.
2. `actions/cache@v6` restaure `~/.platformio` (plateformes, chaînes
   de compilation, bibliothèques : environ 1,4 Go pour ce projet) au
   début du job ; sans cache pour la clé, il le sauvegarde à la fin. La
   **clé** inclut une empreinte du `platformio.ini` (`hashFiles`) :
   changer une version dans `lib_deps` repart d'un cache vide.
3. `pip install platformio==6.1.19` fige la version : sans `==`, une
   nouvelle version publiée un matin pourrait casser la CI sans
   qu'aucun commit ne l'explique. Cette installation par `pip`, à
   version figée, convient à une machine jetable ; elle diffère de
   celle du chapitre Arduino 2, prévue pour votre poste.
4. `credentials.h factice` copie le modèle aux valeurs fictives, pour
   que `main.cpp` compile : le vrai fichier n'est jamais versionné (voir
   chapitre Arduino 4).
5. `Tests natifs` lance `pio test -e native` (voir chapitre Arduino 5).
6. `Environnement de la carte` lit `default_envs` avec le module Python
   `configparser` et garde le premier nom (`xiao` ici) : chaque projet
   vise une carte différente, aucune n'est codée en dur. Le nom, publié
   par le step `env`, est relu par `${{ steps.env.outputs.name }}`.
7. `Compilation du firmware` lance `pio run -e xiao`, car les tests
   natifs ne compilent pas le code de la carte.
8. `cppcheck` lance l'analyse avec `--fail-on-defect=low` : aucun
   défaut, même de style, n'est toléré.

Le premier step qui échoue arrête le job ; les suivants sont sautés.

## Lire un résultat dans l'onglet Actions

L'onglet **Actions** du dépôt liste les runs (titre du commit ou de la
pull request, workflow `CI`, branche, événement, durée), avec une
pastille verte ou une croix rouge. Un run affiche ses jobs :
`Projets PlatformIO testes`, un job par projet de la matrice
(`sketches/XIAO-ESP32-S3/DS18B20_MQTT`...) et les deux `Agent Python`.
Un job affiche ses steps repliables, chacun avec son log : `Set up job`,
`Run actions/checkout@v7`, ..., `Tests natifs`, `Compilation du
firmware`, `cppcheck`, puis `Post Run ...` et `Complete job`. Sur une
pull request, les mêmes jobs figurent dans la liste des vérifications
(*checks*), avec un lien **Details** vers le log.

Voici un échec réel, sur une pull request antérieure au commit
`1af068f` : le job `sketches/JC3248W535C/Claude_Dashboard` est rouge,
ses steps sont verts jusqu'à `Compilation du firmware`, et `cppcheck`
porte la croix. Fin du log (horodatages retirés) :

```
Run pio check -e esp32s3 --skip-packages --fail-on-defect=low
Checking esp32s3 > cppcheck (platform: ...; board: esp32-s3-devkitc-1; framework: arduino)
--------------------------------------------------------------------------------
Tool Manager: Installing platformio/tool-cppcheck @ ~1.21100.0
...
src/ui.cpp:243: [low:style] Condition 'n>shown' is always false [knownConditionTrueFalse]
========================== [FAILED] Took 3.12 seconds ==========================
...
##[error]Process completed with exit code 1.
```

La méthode est toujours la même : le job rouge, puis le step rouge,
puis la première ligne du log qui explique l'échec (ici, une condition
jamais vraie, `ui.cpp` ligne 243). On reproduit avec `pio check` sur
son PC, on corrige, on pousse à nouveau.

## La chaîne complète

Mis bout à bout, les chapitres du module donnent cette chaîne :

```
éditer le code
   -> pio test -e native      (les tests passent, voir chapitre Arduino 5)
   -> pio check -e xiao ...   (aucun défaut)
   -> git commit, git push    (sur une branche, voir module additionnel Git)
   -> pull request            (la CI rejoue tout sur une VM neuve)
   -> CI verte, relecture
   -> fusion dans main        (la CI tourne une dernière fois sur main)
   -> pio run -t upload       (flashage, avec la carte, voir chapitre Arduino 2)
```

Les vérifications locales répondent en quelques secondes ; la CI ne
les remplace pas, elle garantit qu'elles ont été faites, sur une
machine que personne n'a bricolée.

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| Analyse statique | Chercher des défauts en lisant le code, sans l'exécuter |
| `check_tool`, `check_flags`, `check_src_filters` | Choisir l'analyseur, ses options et les fichiers analysés (`platformio.ini`) |
| `pio check -e xiao --skip-packages` | Analyser le projet avec la configuration de la carte, sans les paquets |
| `--fail-on-defect=low` | Faire échouer la commande dès le premier défaut |
| `[low:style] ... [unreadVariable]` | Gravité, famille, message et identifiant d'un défaut |
| `// cppcheck-suppress <id>` | Taire un contrôle sur la ligne suivante (avec `--inline-suppr`), en justifiant |
| Intégration continue | Vérifier automatiquement chaque modification sur une machine neuve |
| Workflow, job, step | Fichier `.github/workflows/*.yml`, groupe d'étapes sur un runner, étape |
| Runner, action (`uses:`) | Machine qui exécute un job ; étape réutilisable publiée |
| `on:`, `permissions:` | Événements déclencheurs ; droits du jeton du workflow |
| `needs`, `outputs`, `$GITHUB_OUTPUT` | Enchaîner des jobs et leur passer des valeurs |
| `matrix`, `fromJSON`, `fail-fast: false` | Un job par projet, liste calculée, pas d'annulation en cascade |
| `actions/cache` et `hashFiles` | Réutiliser `~/.platformio` tant que `platformio.ini` ne change pas |
| `platformio==6.1.19` | Figer la version de l'outil pour des runs reproductibles |
| Onglet Actions | Runs, jobs, steps et logs ; lire le premier step rouge |

## Pour aller plus loin

**Un badge de statut.** Le README d'un dépôt peut afficher l'état de
la CI sous forme d'image, mise à jour à chaque run. L'adresse suit la
forme
`https://github.com/PROPRIETAIRE/DEPOT/actions/workflows/FICHIER/badge.svg`.
Pour le dépôt `arduino`, en Markdown :

```markdown
![CI](https://github.com/pguinet/arduino/actions/workflows/ci.yml/badge.svg)
```

Par défaut, le badge reflète la branche par défaut du dépôt. Les
paramètres `?branch=main` ou `?event=push`, ajoutés à la fin de
l'adresse, le restreignent à une branche ou à un événement.

**Exiger la CI avant une fusion.** Une CI rouge n'empêche pas, à elle
seule, de fusionner une pull request. Une **règle de protection de
branche** le peut : dans **Settings**, section **Branches**, cliquer
**Add classic branch protection rule**, saisir `main` comme *Branch
name pattern*, cocher **Require status checks to pass before
merging**, puis rechercher et sélectionner les vérifications exigées.
Leurs noms sont ceux des jobs, par exemple
`sketches/XIAO-ESP32-S3/DS18B20_MQTT`. L'option **Require branches to
be up to date before merging** impose en plus que la branche intègre
le dernier état de `main`. GitHub propose aussi les **rulesets**, plus
souples, qui remplacent progressivement ces règles classiques. Le dépôt
`arduino` n'en a pas : c'est un projet personnel.

**Lancer un workflow en local avec act.** L'outil libre `act`
(https://github.com/nektos/act) exécute les jobs d'un workflow dans
des conteneurs Docker sur votre PC (voir module additionnel Docker) :
`act -l` liste les jobs, `act pull_request` simule une pull request.
Les images par défaut ne reproduisent pas exactement les runners de
GitHub : utile pour mettre au point un workflow, pas pour remplacer la
vraie CI.

**Tests sur la cible.** `pio test -e native` teste la logique pure sur
le PC. PlatformIO sait aussi compiler les tests pour la carte, les
flasher et lire leurs résultats sur le port série :
`pio test -e xiao`. Cela vérifie le code dans son vrai environnement
(processeur 32 bits, flottants de l'ESP32), mais demande la carte
branchée : impossible sur un runner GitHub, sauf à brancher la carte
sur un runner auto-hébergé. Le projet ne le fait pas.

**Garder les actions à jour avec Dependabot.** Les versions des
actions (`@v7`, `@v6`) vieillissent : le commit `1af068f` les a
justement fait passer de v4 et v5 à v7 et v6, parce que GitHub
signalait leur version de Node.js comme obsolète. Dependabot peut
proposer ces mises à jour sous forme de pull requests, vérifiées par la
CI. Il suffit d'un fichier `.github/dependabot.yml` :

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

**Comparer cppcheck d'une machine à l'autre.** La version de cppcheck
dépend du paquet installé par PlatformIO : le log ci-dessus montre
`tool-cppcheck @ ~1.21100.0` (cppcheck 2.11) sur le runner. Une version
plus récente sur votre PC peut trouver des défauts que la CI ne voit
pas, ou l'inverse. En cas de désaccord, la CI fait foi.

## Exercices

Les exercices 1 à 4 se font sans carte, dans une copie du dépôt
`arduino` avec un `credentials.h` copié depuis le modèle (voir chapitre
Arduino 4). Annulez vos modifications après chaque exercice
(`git restore .`).

**Exercice 1 -- Provoquer des défauts** (sans carte). Introduisez deux défauts dans
`lib/temp_logic/temp_logic.cpp`, puis faites-les signaler par
`pio check -e xiao --skip-packages --fail-on-defect=low` :

1. une variable inutile, `int arrondi = 0;`, au début de `toTenths` ;
2. à la fin du fichier, une fonction qui reçoit une chaîne par valeur :

```cpp
#include <string>
namespace temp {
size_t labelLength(std::string label) { return label.size(); }
}
```

Pour chaque défaut, relevez la gravité, la famille et l'identifiant,
puis corrigez-le et vérifiez que l'analyse repasse.

**Exercice 2 -- Sans --fail-on-defect** (sans carte). Relancez l'analyse du premier défaut de l'exercice 1
sans l'option `--fail-on-defect`. Que change le résultat ? Pourquoi
la CI utilise-t-elle cette option ?

**Exercice 3 -- Retirer une suppression** (sans carte). Supprimez la ligne `// cppcheck-suppress
constParameterCallback` de `src/main.cpp`. Prévoyez le résultat de
`pio check`, puis vérifiez. Pourquoi ne corrige-t-on pas plutôt le
code en ajoutant `const` ?

**Exercice 4 -- Un modèle incomplet** (sans carte). Dans `sketches/common/credentials.h.example`, la
ligne `#define MQTT_SERVER ...` disparaît par erreur. Pour le job
`sketches/XIAO-ESP32-S3/DS18B20_MQTT`, quel est le premier step qui
échoue, et quel message lira-t-on dans son log ? Les tests natifs
passent-ils ?

**Exercice 5 -- La CI d'un fork** (sans carte, compte GitHub requis). Faites un fork
du dépôt `pguinet/arduino` (voir module additionnel Git) et activez
GitHub Actions dans son onglet **Actions**. Créez une branche qui
casse un test, par exemple en remplaçant `85.0f` par `86.0f` dans la
constante `kPowerOn` de `temp_logic.cpp`, et poussez-la. La CI se
lance-t-elle ? Faites ce qu'il faut pour qu'elle se lance, puis
retrouvez dans le log le test en échec.

**Exercice 6 -- Une branche develop** (sans carte). Votre équipe ajoute une branche `develop` : les
fonctionnalités y sont fusionnées par pull request, puis `develop` est
fusionnée dans `main` à chaque version. On veut que la CI tourne pour
les pull requests qui visent `develop` et pour chaque push sur
`develop`. Que faut-il modifier dans `ci.yml` ?

### Solutions

**Solution 1**

1. `lib/temp_logic/temp_logic.cpp:27: [low:style] Variable 'arrondi'
   is assigned a value that is never used. [unreadVariable]` : gravité
   `low`, famille `style`, identifiant `unreadVariable`. Correction :
   supprimer la ligne.
2. `[low:performance] Function parameter 'label' should be passed by
   const reference. [passedByValue]` : gravité `low`, famille
   `performance`, identifiant `passedByValue`. Passer une
   `std::string` par valeur la copie à chaque appel. Correction :
   `size_t labelLength(const std::string &label)`.

Après chaque correction, l'analyse affiche `No defects found` et
`PASSED`.

**Solution 2**

Le défaut est toujours affiché, mais l'analyse se
termine par `PASSED` et le code de retour vaut 0. Un step GitHub
Actions n'échoue que si sa commande renvoie un code non nul : sans
l'option, la CI resterait verte malgré le défaut, et personne ne le
lirait.

**Solution 3**

Deux défauts, un par paramètre :

```
src/main.cpp:71: [low:style] Parameter 'topic' can be declared as pointer to const. However it seems that 'onMqttMessage' is a callback function, if 'topic' is declared with const you might also need to cast function pointer(s). [constParameterCallback]
src/main.cpp:71: [low:style] Parameter 'payload' can be declared as pointer to const. However it seems that 'onMqttMessage' is a callback function, if 'payload' is declared with const you might also need to cast function pointer(s). [constParameterCallback]
```

cppcheck devine lui-même qu'il s'agit d'un rappel. La signature est
imposée par PubSubClient, qui appelle la fonction : avec `const`, son
type ne correspondrait plus à celui qu'attend `mqtt.setCallback`, et
la compilation échouerait. La suppression en ligne, justifiée par le
commentaire qui la précède, est la bonne réponse.

**Solution 4**

Le step `credentials.h factice` réussit : il copie le
fichier, quel que soit son contenu. Les `Tests natifs` passent aussi :
ils compilent `lib/temp_logic` et les tests, pas `src/main.cpp` (voir
chapitre Arduino 5). Le premier step en échec est `Compilation du
firmware` : `main.cpp` contient une garde

```cpp
#ifndef MQTT_SERVER
#error "credentials.h : MQTT_SERVER manquant (voir sketches/common/credentials.h.example)"
#endif
```

et le log du step affiche ce message d'erreur. Le step `cppcheck` est
sauté.

**Solution 5**

La CI ne se lance pas : `on.push` ne vise que `main`,
et aucune pull request n'existe encore. Il faut ouvrir une pull
request de la branche vers `main` dans le fork (attention à choisir le
fork, et non `pguinet/arduino`, comme dépôt de base). Le run démarre ;
le job `sketches/XIAO-ESP32-S3/DS18B20_MQTT` échoue au step `Tests
natifs`, dont le log montre deux tests en échec dans
`test_reading` (voir chapitre Arduino 5) :

```
test/test_reading/test_main.cpp:16: test_power_on_85_rejected_without_close_previous: Expected FALSE Was TRUE	[FAILED]
test/test_reading/test_main.cpp:23: test_real_85_accepted_when_previous_is_close: Expected FALSE Was TRUE	[FAILED]
```

Avec `kPowerOn` à 86, la valeur 85 n'est plus reconnue comme la valeur
de mise sous tension : elle est acceptée alors que les tests attendent
un rejet. Les steps suivants sont sautés ; l'autre projet de
la matrice continue grâce à `fail-fast: false`.

**Solution 6**

Pour les pull requests, rien : `pull_request:` sans
filtre couvre déjà toutes les branches visées, `develop` comprise.
Pour les push, il faut ajouter `develop` à la liste :

```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
```

Si l'on voulait au contraire limiter les pull requests à ces deux
branches, on écrirait `pull_request:` suivi de
`branches: [main, develop]`, avec la même syntaxe que pour `push`.
