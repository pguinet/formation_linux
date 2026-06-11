# Chapitre 7.1 — Réseau et transferts de fichiers

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - identifier votre adresse IP et tester la connectivité réseau ;
> - télécharger des fichiers depuis Internet avec `wget` et `curl` ;
> - copier des fichiers entre machines avec `scp` et `rsync`.
>
> **Durée en séance** : ~30 min.

---

## Qui suis-je sur le réseau ?

Avant de communiquer avec d'autres machines, il faut connaître sa propre identité réseau.

### Trouver son adresse IP avec `ip a`

La commande moderne pour consulter la configuration réseau est `ip addr` (ou sa forme abrégée `ip a`).

```bash
ip a
```

La sortie liste toutes les interfaces réseau. Repérez la section correspondant à votre carte réseau principale — souvent nommée `eth0`, `ens33` ou `enp0s3` sur une VM. La ligne qui commence par `inet` indique l'adresse IPv4 :

```
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP>
    inet 192.168.1.42/24 brd 192.168.1.255 scope global eth0
```

Ici, l'adresse IP est `192.168.1.42`. Le `/24` indique le masque de réseau (les 24 premiers bits identifient le réseau).

L'interface `lo` (loopback, adresse `127.0.0.1`) est interne à la machine — elle n'est pas une carte réseau réelle.

### Afficher le nom de la machine avec `hostname`

```bash
hostname
```

Retourne le nom de la machine tel qu'il est configuré dans le système. Utile pour se repérer quand on travaille sur plusieurs machines via SSH.

---

## Ça répond ? — Tester la connectivité avec `ping`

`ping` envoie des paquets à une adresse IP ou à un nom de domaine et mesure le temps de réponse. C'est le premier réflexe pour vérifier qu'une machine est joignable.

```bash
ping google.com
```

La commande s'exécute indéfiniment : appuyez sur **Ctrl+C** pour l'arrêter. Elle affiche alors un résumé des paquets envoyés, reçus et du temps de réponse moyen.

```
PING google.com (142.250.191.14) 56(84) bytes of data.
64 bytes from ...: icmp_seq=1 ttl=118 time=23.4 ms
64 bytes from ...: icmp_seq=2 ttl=118 time=22.8 ms
^C
--- google.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss
rtt min/avg/max = 22.8/23.1/23.4 ms
```

Pour limiter le nombre d'envois :

```bash
ping -c 4 google.com      # Envoie exactement 4 paquets puis s'arrête
ping -c 1 192.168.1.1     # Test rapide : la passerelle répond-elle ?
```

Si `ping` échoue, cela peut indiquer un problème réseau, un pare-feu, ou simplement que l'hôte distant ne répond pas aux pings (ce qui est courant pour certains serveurs).

---

## Télécharger des fichiers — `wget` et `curl`

### `wget` — téléchargeur orienté fichiers

`wget` est conçu pour télécharger des fichiers depuis le Web. Son usage le plus courant :

```bash
wget https://example.com/fichier.zip
```

Le fichier est sauvegardé dans le répertoire courant avec son nom d'origine. Deux options utiles :

```bash
wget -O mon_nom.zip https://example.com/fichier.zip   # Choisir le nom du fichier
wget -c https://example.com/gros_fichier.iso          # Reprendre un téléchargement interrompu
```

### `curl` — client HTTP polyvalent

`curl` est plus général : il peut télécharger, envoyer des données, tester des API. Par défaut, il affiche le contenu dans le terminal :

```bash
curl https://example.com/page.html          # Affiche dans le terminal
curl -O https://example.com/fichier.zip     # Sauvegarde avec le nom d'origine
curl -o mon_nom.zip https://example.com/fichier.zip   # Choisir le nom
```

**En une phrase** : `wget` est le bon choix pour simplement télécharger un fichier ; `curl` est plus adapté quand on veut inspecter les réponses HTTP ou interagir avec une API.

---

## Copier des fichiers entre machines

Les outils `scp` et `rsync` utilisent SSH comme canal de transport sécurisé. La connexion SSH est supposée déjà configurée (voir l'annexe installation).

### `scp` — copie sécurisée simple

`scp` fonctionne comme la commande `cp`, mais l'une des deux extrémités peut être une machine distante. La syntaxe est :

```
scp [options] source destination
```

L'adresse d'un fichier distant s'écrit `utilisateur@machine:chemin`.

Exemples courants :

```bash
# Envoyer un fichier local vers la machine distante
scp rapport.pdf alice@192.168.1.10:/home/alice/documents/

# Récupérer un fichier depuis la machine distante
scp alice@192.168.1.10:/var/log/syslog ./syslog_distant.log

# Copier un répertoire entier (option -r pour récursif)
scp -r ./projet alice@192.168.1.10:/home/alice/

# Utiliser un port SSH non standard (option -P)
scp -P 2222 fichier.txt alice@192.168.1.10:/home/alice/
```

`scp` est rapide à taper pour un transfert ponctuel, mais il recommence toujours depuis le début en cas d'interruption.

### `rsync` — synchronisation robuste pour les gros volumes

`rsync` est préférable à `scp` dès que :
- le volume de données est important ;
- le transfert peut être interrompu (connexion instable) ;
- on veut synchroniser régulièrement deux répertoires en ne transférant que les différences.

Ses atouts principaux :
- **transfert différentiel** : compare source et destination, ne copie que ce qui a changé ;
- **reprise automatique** : repart là où il s'est arrêté ;
- **mode simulation** : vérifie ce qui serait fait sans rien modifier.

La combinaison d'options la plus courante est `-av` :

```bash
rsync -av source/ utilisateur@machine:/chemin/destination/
```

- `-a` (archive) : mode récursif + préserve les permissions, dates, liens symboliques ;
- `-v` (verbose) : affiche les fichiers transférés.

Exemples pratiques :

```bash
# Synchroniser un répertoire local vers une machine distante
rsync -av ~/documents/ alice@192.168.1.10:/backup/documents/

# Récupérer des fichiers depuis une machine distante
rsync -av alice@192.168.1.10:/var/www/html/ ./sauvegarde_site/
```

---

## L'essentiel

| Commande | Usage type |
|----------|------------|
| `ip a` | Afficher les adresses IP de la machine |
| `hostname` | Afficher le nom de la machine |
| `ping -c 4 cible` | Tester la joignabilité d'une machine (4 paquets) |
| `wget URL` | Télécharger un fichier depuis le Web |
| `curl -O URL` | Télécharger un fichier et le sauvegarder |
| `scp fichier user@machine:chemin` | Copier un fichier vers une machine distante |
| `scp user@machine:chemin fichier` | Récupérer un fichier depuis une machine distante |
| `rsync -av source/ user@machine:dest/` | Synchroniser un répertoire vers une machine distante |
| `rsync -av --dry-run source/ dest/` | Simuler une synchronisation sans rien modifier |

---

## Pour aller plus loin

### Voir les ports en écoute avec `ss`

`ss` (socket statistics) remplace l'ancienne commande `netstat`. Pour afficher les ports TCP sur lesquels la machine attend des connexions :

```bash
ss -tln
```

- `-t` : connexions TCP uniquement ;
- `-l` : ports en écoute (listening) ;
- `-n` : afficher les numéros de port au lieu des noms de service.

Exemple de sortie :

```
State    Recv-Q   Send-Q   Local Address:Port
LISTEN   0        128      0.0.0.0:22
LISTEN   0        128      0.0.0.0:80
```

Le port `22` correspond à SSH, le port `80` à HTTP. Utile pour diagnostiquer si un service est bien démarré.

### Résolution DNS — `/etc/hosts` et `dig`

Quand vous tapez un nom de domaine, le système le traduit en adresse IP. La résolution passe d'abord par le fichier `/etc/hosts`, qui définit des correspondances locales :

```bash
cat /etc/hosts
```

Vous pouvez y ajouter des entrées pour résoudre des noms sans serveur DNS (par exemple dans un réseau de formation) :

```
192.168.1.10   serveur-tp
```

Pour interroger le DNS depuis la ligne de commande, la commande `dig` est très complète :

```bash
dig google.com          # Résolution IPv4
dig +short google.com   # Résultat concis (juste l'IP)
```

### Options rsync utiles : simulation et suppression

**Simuler avant d'agir (`-n` / `--dry-run`)**

Avant de lancer une synchronisation sur de vraies données, il est prudent
de simuler pour voir ce qui serait transféré ou supprimé, sans rien modifier :

```bash
rsync -av --dry-run ~/documents/ alice@192.168.1.10:/backup/documents/
```

L'option `-n` est le raccourci de `--dry-run`. Relancer sans elle une fois
le résultat jugé correct.

**Supprimer les fichiers absents de la source (`--delete`)**

Par défaut, `rsync` ne supprime jamais rien dans la destination.
L'option `--delete` aligne la destination sur la source en supprimant
les fichiers présents dans la destination mais absents de la source :

```bash
rsync -av --delete ~/documents/ alice@192.168.1.10:/backup/documents/
```

> **Attention** : toujours tester avec `--dry-run` avant d'utiliser `--delete`
> pour la première fois sur un répertoire important.

**Exclure des fichiers (bonus)**

```bash
rsync -av --exclude='*.tmp' --exclude='cache/' source/ dest/
```

### Tester une API avec `curl`

`curl` permet aussi d'interroger des services web. Pour vérifier qu'un serveur HTTP répond et voir ses en-têtes :

```bash
curl -I https://example.com       # En-têtes HTTP seulement
curl -L https://example.com       # Suit les redirections automatiquement
```

Pour envoyer des données à une API REST :

```bash
curl -X GET https://api.github.com/users/octocat
curl -H "Content-Type: application/json" -d '{"key":"value"}' https://httpbin.org/post
```

---

## Exercices

### Exercice 1 — Identifier votre configuration réseau

Affichez la configuration réseau de votre VM. Notez votre adresse IP principale.

Vérifiez également le nom de la machine :

```bash
hostname
```

Quelle est votre adresse IP ? Sur quel réseau êtes-vous (les trois premiers octets) ?

---

### Exercice 2 — Tester la connectivité

Réalisez les tests suivants en ordre et notez à quelle étape un éventuel problème apparaîtrait :

1. Testez votre interface locale : `ping -c 2 127.0.0.1`
2. Testez la résolution DNS : `ping -c 2 google.com`
3. Arrêtez `ping` avec **Ctrl+C** si vous ne spécifiez pas `-c`.

---

### Exercice 3 — Télécharger un fichier avec `wget`

Téléchargez la page d'accueil de `example.com` et sauvegardez-la sous le nom `page_test.html` :

```bash
wget -O page_test.html https://example.com
```

Vérifiez que le fichier existe et affichez ses premières lignes avec `head page_test.html`.

---

### Exercice 4 — Comparer `wget` et `curl`

Téléchargez le même fichier avec `curl` :

```bash
curl -o page_test_curl.html https://example.com
```

Comparez les deux fichiers téléchargés (voir chapitre 4.3 pour `diff`) :

```bash
diff page_test.html page_test_curl.html
```

---

### Exercice 5 — Copier un fichier avec `scp`

Créez un fichier de test, puis copiez-le vers votre VM (ou vers un autre compte sur la même machine via `localhost`). Adaptez `alice` et l'adresse IP à votre environnement.

```bash
echo "Fichier de test SCP" > test_scp.txt
scp test_scp.txt alice@192.168.1.10:/home/alice/
```

Vérifiez ensuite que le fichier est bien arrivé :

```bash
ssh alice@192.168.1.10 "ls -la /home/alice/test_scp.txt"
```

---

### Exercice 6 — Synchroniser un répertoire avec `rsync`

Créez un répertoire de travail avec quelques fichiers, puis synchronisez-le vers la machine distante.

```bash
mkdir ~/tp_rsync
echo "fichier 1" > ~/tp_rsync/a.txt
echo "fichier 2" > ~/tp_rsync/b.txt

# Simuler d'abord
rsync -av --dry-run ~/tp_rsync/ alice@192.168.1.10:/home/alice/tp_rsync/

# Puis exécuter réellement
rsync -av ~/tp_rsync/ alice@192.168.1.10:/home/alice/tp_rsync/
```

Modifiez maintenant `a.txt` et relancez `rsync`. Observez que seul le fichier modifié est retransféré.

---

### Solutions

#### Solution exercice 1

```bash
ip a
hostname
```

La ligne `inet` de l'interface principale (par exemple `eth0`) donne l'adresse IP. Sur un réseau de classe C classique, les trois premiers octets forment le réseau, par exemple `192.168.1`.

#### Solution exercice 2

```bash
ping -c 2 127.0.0.1       # Teste la pile réseau locale
ping -c 2 google.com      # Teste la résolution DNS et la connectivité Internet
```

Si l'étape 1 échoue, le problème est interne à la machine. Si l'étape 2 échoue, le problème est soit réseau, soit DNS.

#### Solution exercice 3

```bash
wget -O page_test.html https://example.com
ls -lh page_test.html
head page_test.html
```

#### Solution exercice 4

```bash
curl -o page_test_curl.html https://example.com
diff page_test.html page_test_curl.html
```

Les fichiers peuvent présenter de légères différences (en-têtes HTTP, compression), mais le contenu HTML devrait être identique ou très similaire.

#### Solution exercice 5

```bash
echo "Fichier de test SCP" > test_scp.txt
scp test_scp.txt alice@192.168.1.10:/home/alice/
ssh alice@192.168.1.10 "ls -la /home/alice/test_scp.txt"
```

#### Solution exercice 6

```bash
mkdir ~/tp_rsync
echo "fichier 1" > ~/tp_rsync/a.txt
echo "fichier 2" > ~/tp_rsync/b.txt

# Simulation
rsync -av --dry-run ~/tp_rsync/ alice@192.168.1.10:/home/alice/tp_rsync/

# Transfert réel
rsync -av ~/tp_rsync/ alice@192.168.1.10:/home/alice/tp_rsync/

# Modifier un fichier et relancer
echo "ligne ajoutée" >> ~/tp_rsync/a.txt
rsync -av ~/tp_rsync/ alice@192.168.1.10:/home/alice/tp_rsync/
# Seul a.txt apparaît dans la liste des fichiers transférés
```
