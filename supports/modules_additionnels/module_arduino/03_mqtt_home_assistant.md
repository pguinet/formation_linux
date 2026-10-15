# Arduino 3 — MQTT et Home Assistant

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - expliquer le modèle publication/abonnement et le rôle d'un broker MQTT ;
> - écrire un sujet et un filtre d'abonnement avec les jokers `+` et `#` ;
> - dire ce que changent la QoS, un message retenu et un testament ;
> - lire le message de découverte qui crée le capteur dans Home Assistant ;
> - associer chaque sujet du projet à son contenu.
>
> **Durée de lecture** : environ 1 h.

---

La carte mesure une température ; Home Assistant l'affiche. Entre les
deux, pas d'appel direct : la carte envoie ses mesures à un serveur
intermédiaire, où Home Assistant les lit. Ce serveur parle **MQTT**, un
protocole léger, très répandu dans l'Internet des objets.

Ce chapitre présente MQTT juste assez pour comprendre le code, puis la
**découverte** (*MQTT Discovery*), qui fait apparaître le capteur dans
Home Assistant sans aucune configuration de ce côté. Les exercices se
font sans carte ; le dernier demande Docker.

## Le besoin : publier sans connaître ses lecteurs

Une sonde peut intéresser plusieurs programmes : Home Assistant, un
script d'archivage, une alerte. Si la carte devait les connaître tous,
il faudrait la reprogrammer à chaque nouveau lecteur.

MQTT suit le modèle **publication/abonnement** (*publish/subscribe*) :
la carte **publie** ses mesures sous un nom, sans savoir qui les lira ;
chaque programme intéressé **s'abonne** à ce nom. Au centre, un serveur
reçoit les publications et les distribue aux abonnés :

```
                                 abonnés
  +-----------+             +-> Home Assistant
  | XIAO      |  +--------+ |
  | ESP32-S3  |->| broker |-+-> script d'archive
  | + DS18B20 |  |  MQTT  | |
  +-----------+  +--------+ +-> mosquitto_sub
   publie
```

La carte et les lecteurs ne connaissent que l'adresse du broker : on
ajoute ou retire un lecteur sans toucher à la carte.

## Le vocabulaire de MQTT

**Broker.** Le serveur central, qui écoute par défaut sur le port TCP
1883. Le plus courant est **Mosquitto**, logiciel libre de la fondation
Eclipse. Dans le projet, son adresse vient de `MQTT_SERVER` et
`MQTT_PORT` (voir chapitre Arduino 4 pour les secrets).

**Client.** Tout programme connecté au broker, pour publier, s'abonner,
ou les deux : la carte (bibliothèque `PubSubClient`) comme Home
Assistant. Chaque client a un **identifiant** unique ; celui de la carte
est `xiao_ds18b20_` suivi de trois octets de sa MAC, par exemple
`xiao_ds18b20_3bb004`.

**Sujet** (*topic*). Le nom sous lequel un message est publié, découpé
en niveaux par des `/` comme un chemin de fichier. Il n'a pas besoin
d'être déclaré, et l'organisation des niveaux est une convention du
développeur ; ici, le type d'appareil, l'appareil, puis la donnée :

```
xiao_ds18b20/xiao_ds18b20_3bb004/temperature
```

**Filtre et jokers.** Un abonné donne un **filtre**, qui peut contenir
deux jokers :

| Joker | Remplace | Exemple | Correspond à |
|-------|----------|---------|--------------|
| `+` | exactement un niveau | `xiao_ds18b20/+/status` | le `status` de chaque carte |
| `#` | tous les niveaux restants (en dernier) | `xiao_ds18b20/#` | tout ce que publient les cartes |

`+` peut apparaître plusieurs fois ; `#` seulement à la fin. S'abonner à
`#` seul reçoit tout le trafic du broker : pratique pour observer, à
éviter en production.

**Message.** Un sujet et un contenu (*payload*), simple suite d'octets
dont MQTT n'impose pas le format. Le projet publie du texte (`21.4`,
`online`) et du JSON pour la découverte.

**QoS** (*Quality of Service*). Le niveau de garantie de livraison,
choisi à chaque publication :

| QoS | Garantie | Coût |
|-----|----------|------|
| 0 | au plus une fois : envoyé sans accusé de réception | le plus léger |
| 1 | au moins une fois : renvoyé jusqu'à l'accusé, doublons possibles | un aller-retour |
| 2 | exactement une fois | deux allers-retours |

Le projet publie tout en QoS 0, la seule que `PubSubClient` sait
publier : perdre une mesure envoyée toutes les 10 secondes est sans
importance.

**Session.** Ce que le broker garde pour un client : ses abonnements et,
en QoS 1 ou 2, les messages en attente. La carte demande une session
« propre » (*clean session*), oubliée à la déconnexion : elle se
réabonne donc après chaque connexion (voir chapitre Arduino 4).

## Les messages retenus

Par défaut, un message n'est remis qu'aux clients abonnés **au moment**
de la publication. Un message publié avec le drapeau **retenu**
(*retained*) est en plus conservé par le broker, qui le remet aussitôt à
tout nouvel abonné. Le broker garde un seul message retenu par sujet, le
dernier.

Dans `PubSubClient`, le drapeau est le dernier argument de `publish`.
Comparez ces deux lignes de `src/main.cpp` :

```cpp
mqtt.publish(topics.status, "online", true);
```

```cpp
if (mqtt.publish(topics.state, value)) {
```

La première est retenue (`true`), la seconde non. La règle :

- un **état**, vrai tant qu'il n'a pas changé (« la carte est en
  ligne », « voici comment me décrire »), est retenu : un client qui
  arrive doit le connaître tout de suite ;
- une **mesure** n'est pas retenue : retenir `21.4` le ferait passer pour
  la température actuelle, même une semaine après la panne de la carte.

Un message **vide** retenu efface le message retenu d'un sujet : c'est
le remède aux « appareils fantômes » du README, laissés par une carte
dont l'identifiant a changé.

## Le testament

Une carte qui perd son alimentation ne prévient personne : son sujet
`status`, retenu, resterait à `online`. MQTT prévoit le **testament**
(*Last Will and Testament*, LWT) : à la connexion, le client confie au
broker un message à publier **à sa place** s'il disparaît sans se
déconnecter proprement. Le broker s'en aperçoit quand la connexion TCP
tombe, ou après une fois et demie l'intervalle *keepalive* sans nouvelle
(15 secondes par défaut dans `PubSubClient`).

Le testament se donne dans l'appel de connexion de `handleMqtt()`, dans
`src/main.cpp` :

```cpp
const bool ok = mqtt.connect(deviceId, MQTT_USER, MQTT_PASS, topics.status, 0, true, "offline");
```

| Argument | Valeur | Rôle |
|----------|--------|------|
| 1 | `deviceId` | identifiant du client, unique sur le broker |
| 2 | `MQTT_USER` | nom d'utilisateur (secret, voir chapitre Arduino 4) |
| 3 | `MQTT_PASS` | mot de passe |
| 4 | `topics.status` | sujet du testament : `xiao_ds18b20/<id>/status` |
| 5 | `0` | QoS du testament |
| 6 | `true` | testament retenu |
| 7 | `"offline"` | contenu du testament |

Une fois connectée, la carte publie elle-même `online`, retenu, sur ce
sujet. `status` vaut donc toujours l'état réel : `online` publié par la
carte, puis `offline` publié par le broker dès qu'elle disparaît. Le
testament doit être retenu, sinon un client arrivé après la panne ne
verrait jamais `offline`.

## Home Assistant et MQTT Discovery

**Home Assistant** est un logiciel libre de domotique ; son intégration
MQTT est un client comme un autre. Avec **MQTT Discovery**, c'est la
carte qui se décrit auprès de lui : Home Assistant
s'abonne à `homeassistant/#`, et un message publié sur un sujet de la
forme `homeassistant/<type>/<identifiant>/<objet>/config` crée l'entité
correspondante. La carte publie sa description, retenue, sur :

```
homeassistant/sensor/xiao_ds18b20_3bb004/temperature/config
```

Le contenu est un JSON construit par `buildDiscovery()`, dans
[`lib/temp_logic/ha_discovery.cpp`](https://github.com/pguinet/arduino/blob/1af068f/sketches/XIAO-ESP32-S3/DS18B20_MQTT/lib/temp_logic/ha_discovery.cpp).
Voici, indenté pour la lecture, celui qu'il produit pour
`xiao_ds18b20_3bb004` (la carte l'envoie sur une ligne de 533 octets) :

```json
{
  "name": "Temperature",
  "unique_id": "xiao_ds18b20_3bb004_temperature",
  "state_topic": "xiao_ds18b20/xiao_ds18b20_3bb004/temperature",
  "device_class": "temperature",
  "state_class": "measurement",
  "unit_of_measurement": "°C",
  "suggested_display_precision": 1,
  "availability_mode": "all",
  "availability": [
    {"topic": "xiao_ds18b20/xiao_ds18b20_3bb004/status"},
    {"topic": "xiao_ds18b20/xiao_ds18b20_3bb004/probe"}
  ],
  "device": {
    "identifiers": ["xiao_ds18b20_3bb004"],
    "name": "xiao_ds18b20_3bb004",
    "model": "XIAO ESP32S3 + DS18B20",
    "manufacturer": "Seeed Studio"
  }
}
```

Les champs à connaître :

- `unique_id` : identifiant stable de l'entité ; Home Assistant
  reconnaît ainsi le capteur d'une publication à l'autre ;
- `state_topic` : le sujet où lire la valeur ;
- `device_class` : la nature de la mesure (icône, regroupement) ;
  `state_class: measurement` fait tenir des statistiques ;
- `unit_of_measurement`, `suggested_display_precision` : affichage en
  °C avec un chiffre après la virgule ;
- `availability` : les sujets qui disent si le capteur est disponible,
  avec les valeurs par défaut `online` et `offline` ;
- `availability_mode: all` : disponible seulement si **tous** ces sujets
  valent `online`. La carte doit être connectée (`status`, tenu par le
  testament) **et** la sonde doit répondre (`probe`, voir chapitre
  Arduino 4). Sinon, Home Assistant affiche « indisponible » plutôt
  qu'une ancienne valeur ;
- `device` : regroupe les entités sous un même appareil.

Ce message dépasse les 256 octets acceptés par défaut par `PubSubClient`,
d'où le réglage de son tampon (voir chapitre Arduino 4).

**Redémarrage de Home Assistant.** À sa connexion au broker, Home
Assistant publie `online` sur `homeassistant/status`. La carte, abonnée
à ce sujet, republie alors sa découverte et sa prochaine température
(fonction `onMqttMessage()`, voir chapitre Arduino 4). Les messages
étant retenus, c'est un filet de sécurité : il couvre par exemple un
broker redémarré sans conserver ses messages retenus.

## Les sujets du projet

Le tableau suivant, repris du README, résume ce que publie la carte ;
`<id>` est son identifiant. Les noms sont construits par `makeTopics()`,
dans le même fichier que `buildDiscovery()`.

| Sujet | Contenu | Retenu |
|---|---|---|
| `homeassistant/sensor/<id>/temperature/config` | découverte | oui |
| `xiao_ds18b20/<id>/temperature` | valeur, ex. `21.4` | non |
| `xiao_ds18b20/<id>/status` | `online` / `offline` (testament MQTT) | oui |
| `xiao_ds18b20/<id>/probe` | `online` / `offline` selon la sonde | oui |

La carte s'abonne à un seul sujet, `homeassistant/status`.

> **Et en vrai ?** Pour voir la carte publier, il faut un broker et un
> Home Assistant. Tous deux pourront tourner dans des conteneurs sur le
> futur homelab du club (voir module additionnel Docker). En attendant,
> n'importe quel broker convient ; cette commande affiche tout ce que
> publient les cartes, sujet compris (`-v`) :
>
> ```
> mosquitto_sub -h <adresse du broker> -v -t 'xiao_ds18b20/#'
> ```
>
> L'exercice 5 monte un broker local avec Docker, sans carte.

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| Publication/abonnement | Les émetteurs publient, les lecteurs s'abonnent, sans se connaître |
| Broker (Mosquitto) | Serveur central qui reçoit et distribue les messages (port 1883) |
| Client | Programme connecté au broker, avec un identifiant unique |
| Sujet | Nom hiérarchique d'un message : `a/b/c` |
| `+` / `#` | Joker d'un niveau / de tous les niveaux restants |
| QoS 0, 1, 2 | Au plus une fois, au moins une fois, exactement une fois |
| Message retenu | Dernier message d'un sujet, remis à tout nouvel abonné |
| Message vide retenu | Efface le message retenu d'un sujet |
| Testament (LWT) | Message publié par le broker si le client disparaît |
| MQTT Discovery | Un JSON retenu sur `homeassistant/.../config` crée l'entité |
| `availability_mode: all` | Disponible seulement si tous les sujets d'`availability` valent `online` |
| `homeassistant/status` | `online` au démarrage de Home Assistant : la carte republie |
| `mosquitto_sub -v -t FILTRE` | Afficher les messages reçus, avec leur sujet |
| `mosquitto_pub -t SUJET -m TEXTE [-r]` | Publier un message (retenu avec `-r`) |

## Pour aller plus loin

**Sécuriser le broker.** Un broker ouvert à tous accepte n'importe quelle
publication, y compris une fausse découverte. En production, Mosquitto
exige un compte (`password_file`, fichier créé avec `mosquitto_passwd`)
et peut chiffrer les échanges en TLS, en général sur le port 8883. Le
projet transmet un nom d'utilisateur et un mot de passe, mais pas de
TLS : à réserver à un réseau local de confiance.

**MQTT 3.1.1 et MQTT 5.** `PubSubClient` parle MQTT 3.1.1. La version 5
ajoute notamment une durée de vie aux messages, des propriétés
utilisateur et des codes de retour plus précis. Les brokers récents
acceptent les deux versions en même temps.

**QoS de bout en bout.** La QoS s'applique à chaque saut séparément :
de l'émetteur au broker, puis du broker à chaque abonné, avec la QoS
demandée par l'abonné. Un message publié en QoS 2 et lu par un abonné en
QoS 0 n'est livré qu'au plus une fois à cet abonné.

**Persistance du broker.** Mosquitto garde ses messages retenus en
mémoire. Avec `persistence true` dans sa configuration, il les écrit
aussi sur disque et les retrouve après un redémarrage. C'est le cas que
couvre, sinon, la republication déclenchée par `homeassistant/status`.

**Supprimer un appareil.** Publier un message vide retenu sur le sujet
`config` d'une entité la supprime de Home Assistant. Pour un appareil
fantôme du projet, on vide ainsi ses trois sujets retenus :

```
mosquitto_pub -h <broker> -t 'homeassistant/sensor/<id>/temperature/config' -r -n
mosquitto_pub -h <broker> -t 'xiao_ds18b20/<id>/status' -r -n
mosquitto_pub -h <broker> -t 'xiao_ds18b20/<id>/probe' -r -n
```

L'option `-n` publie un message vide.

**Autres types d'entités.** Le niveau `<type>` du sujet de découverte
peut valoir `binary_sensor` (ouvert/fermé), `switch` (un relais que Home
Assistant commande en publiant sur un `command_topic`), `light`, etc. La
documentation de l'intégration MQTT de Home Assistant décrit les champs
de chacun.

## Exercices

Tous les exercices se font sans carte. L'exercice 5 demande Docker.

**Exercice 1.** La carte fonctionne depuis une heure. Un nouveau client
s'abonne à `xiao_ds18b20/#` et à `homeassistant/#`. Que reçoit-il
immédiatement, avant toute nouvelle publication ? Et si la carte a été
débranchée il y a dix minutes ?

**Exercice 2.** Plusieurs cartes publient sur le même broker. Écrivez :

1. le filtre qui reçoit la température de toutes les cartes, et rien
   d'autre ;
2. le filtre qui reçoit tout ce que publie la seule carte
   `xiao_ds18b20_3bb004` ;
3. le filtre qui reçoit les messages de découverte de tous les capteurs
   annoncés à Home Assistant.

**Exercice 3.** Pourquoi la température n'est-elle pas publiée en message
retenu, alors que `status` et `probe` le sont ? Décrivez ce que verrait
Home Assistant, au redémarrage, si elle l'était et que la carte était
hors service.

**Exercice 4.** Dans chaque situation, dites ce que valent `status` et
`probe`, et ce qu'affiche Home Assistant :

1. tout fonctionne ;
2. le fil DATA de la sonde est coupé, la carte reste connectée ;
3. la carte n'est plus alimentée.

**Exercice 5 (Docker).** Simulez la carte avec un broker Mosquitto local
et les outils `mosquitto_pub` et `mosquitto_sub` fournis dans l'image :

1. lancez le broker `eclipse-mosquitto:2` en autorisant les connexions
   anonymes ;
2. publiez `status` et `probe` en messages retenus, puis une température
   non retenue ; abonnez-vous ensuite à `xiao_ds18b20/#` et notez ce que
   vous recevez ;
3. simulez la disparition brutale d'une carte qui a laissé un testament,
   et vérifiez que `status` passe à `offline` ;
4. supprimez le broker.

### Solutions

**Solution 1.** Il reçoit immédiatement les messages retenus : le JSON
de découverte sur `homeassistant/sensor/<id>/temperature/config`,
`online` sur `status` et `online` sur `probe` (si la sonde répond). Il
ne reçoit pas la température, non retenue : il l'aura à la prochaine
publication. Si la carte est débranchée depuis dix minutes, le broker a
publié le testament : `status` vaut `offline`. La découverte et `probe`
(`online`, dernière valeur publiée) restent inchangés ; c'est
`availability_mode: all` qui rend malgré tout le capteur indisponible.

**Solution 2.**

1. `xiao_ds18b20/+/temperature`
2. `xiao_ds18b20/xiao_ds18b20_3bb004/#`
3. `homeassistant/+/+/+/config`, ou plus largement `homeassistant/#`,
   qui reçoit aussi `homeassistant/status`.

**Solution 3.** Une mesure n'a de sens qu'au moment où elle est prise.
Retenue, la dernière valeur serait remise à chaque nouvel abonné, même
longtemps après. Au redémarrage, Home Assistant lirait par exemple
`21.4` et le présenterait comme la valeur courante. Ici, le testament
fait passer `status` à `offline` et le capteur s'affiche
« indisponible », ce qui est exact.

**Solution 4.**

1. `status` = `online`, `probe` = `online` : la température s'affiche.
2. `status` = `online`, `probe` = `offline` après trois lectures
   invalides (voir chapitre Arduino 4) : capteur indisponible.
3. `status` = `offline`, publié par le broker grâce au testament ;
   `probe` garde sa dernière valeur, `online` : capteur indisponible,
   puisque `availability_mode: all` exige que les deux sujets valent
   `online`.

**Solution 5.**

1. Créez la configuration et lancez le broker :

   ```bash
   mkdir mosquitto && cd mosquitto
   printf 'listener 1883\nallow_anonymous true\n' > mosquitto.conf
   docker run -d --name broker -p 1883:1883 \
     -v "$PWD/mosquitto.conf:/mosquitto/config/mosquitto.conf:ro" \
     eclipse-mosquitto:2
   docker logs broker
   ```

   Sans fichier de configuration, Mosquitto 2 n'accepte que les
   connexions locales. Le journal se termine par :

   ```
   ...: Opening ipv4 listen socket on port 1883.
   ...: Opening ipv6 listen socket on port 1883.
   ...: mosquitto version 2.1.2 running
   ```

2. Les outils sont lancés dans le conteneur avec `docker exec`.
   L'option `-W 2` arrête l'abonné au bout de 2 secondes :

   ```bash
   ID=xiao_ds18b20_3bb004
   docker exec broker mosquitto_pub -t xiao_ds18b20/$ID/status -m online -r
   docker exec broker mosquitto_pub -t xiao_ds18b20/$ID/probe -m online -r
   docker exec broker mosquitto_pub -t xiao_ds18b20/$ID/temperature -m 21.4
   docker exec broker mosquitto_sub -v -t 'xiao_ds18b20/#' -W 2
   ```

   ```
   xiao_ds18b20/xiao_ds18b20_3bb004/status online
   xiao_ds18b20/xiao_ds18b20_3bb004/probe online
   Timed out
   ```

   Seuls les messages retenus arrivent : la température a été publiée
   avant l'abonnement et n'a pas été conservée.

3. Un client qui se termine normalement (Ctrl+C) se déconnecte
   proprement, et le broker ne publie pas son testament. Il faut donc
   le tuer brutalement (`kill -9`) pour simuler une coupure
   d'alimentation :

   ```bash
   docker exec broker sh -c "mosquitto_sub -i $ID -t rien \
     --will-topic xiao_ds18b20/$ID/status --will-payload offline \
     --will-retain & sleep 1; kill -9 \$!"
   docker exec broker mosquitto_sub -v -t 'xiao_ds18b20/+/status' -W 1
   ```

   ```
   xiao_ds18b20/xiao_ds18b20_3bb004/status offline
   Timed out
   ```

   Pour suivre la scène en direct, lancez avant, dans un second
   terminal, `docker exec broker mosquitto_sub -v -t 'xiao_ds18b20/#'` :
   il affiche les deux messages retenus, puis `status offline` au
   moment du `kill`.

4. Supprimez le conteneur :

   ```bash
   docker rm -f broker
   ```
