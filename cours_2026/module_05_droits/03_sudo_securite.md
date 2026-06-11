# Chapitre 5.3 — sudo et bonnes pratiques de sécurité

> **Objectifs** : à la fin de ce chapitre, vous saurez :
>
> - Expliquer pourquoi on évite de travailler directement en tant que root.
> - Utiliser `sudo` pour exécuter des commandes avec des droits élevés.
> - Vérifier quelles commandes vous sont autorisées avec `sudo -l`.
> - Appliquer les bonnes pratiques essentielles de sécurité liées aux privilèges.
>
> **Durée en séance** : ~30 min.

---

## root, le compte à tout faire (et tout casser)

Sur un système Linux, le compte `root` est le superutilisateur : il peut lire,
modifier ou supprimer n'importe quel fichier, tuer n'importe quel processus,
changer les droits de quiconque. Bref, aucune limite.

Cette toute-puissance est aussi son principal danger. Lorsque vous travaillez
en root, une simple coquille dans une commande peut avoir des conséquences
catastrophiques et irréversibles. Par exemple :

```bash
# En root, ce genre d'erreur de frappe peut supprimer tout le système
rm -rf /tmp/mon dossier    # l'espace est interprété : rm -rf /tmp/mon  ET  dossier
```

Il y a trois problèmes concrets à travailler en root de façon permanente :

1. **Le risque d'erreur** est maximal : chaque commande s'exécute sans filet.
2. **Aucune traçabilité** : si plusieurs personnes partagent le compte root,
   impossible de savoir qui a fait quoi.
3. **Le mot de passe root circule** : dès qu'on le communique à quelqu'un, on
   perd le contrôle de qui peut l'utiliser.

La bonne pratique, universelle sur les systèmes modernes, est de travailler
avec un compte ordinaire et de n'élever ses droits que pour les tâches qui
l'exigent — et uniquement le temps nécessaire.

---

## sudo : élever ses droits de façon contrôlée

`sudo` (de l'anglais *superuser do*) permet d'exécuter une commande précise
avec les droits d'un autre utilisateur, généralement root, sans avoir besoin
de connaître le mot de passe de cet utilisateur. Vous saisissez **votre propre
mot de passe**.

### Syntaxe de base

```bash
sudo <commande>
```

Exemples courants :

```bash
sudo apt update               # mettre à jour la liste des paquets
sudo systemctl restart ssh    # redémarrer le service SSH
sudo nano /etc/hosts          # éditer un fichier système
```

### Le cache de mot de passe

Pour ne pas avoir à saisir votre mot de passe à chaque commande, `sudo` le
met en cache pendant **15 minutes** par défaut (peut varier selon la
configuration du système). Passé ce délai, il vous est de nouveau demandé.

Vous pouvez gérer ce cache explicitement :

```bash
sudo -v    # renouveler le cache (repousse l'expiration de 15 minutes)
sudo -k    # invalider le cache immédiatement (force la re-saisie)
```

### Connaître ses droits : sudo -l

Avant de faire quoi que ce soit, il est utile de savoir ce que vous êtes
autorisé à faire :

```bash
sudo -l
```

La sortie vous indique, pour votre compte, la liste des commandes autorisées.
Exemple de résultat typique sur Debian pour un administrateur :

```
User votre_login may run the following commands on cette-machine:
    (ALL : ALL) ALL
```

Cela signifie que vous pouvez exécuter n'importe quelle commande en tant que
n'importe quel utilisateur. Un compte plus restreint pourrait afficher :

```
    (ALL) /usr/bin/systemctl status *
    (ALL) NOPASSWD: /usr/bin/tail /var/log/*
```

Ce qui signifie qu'il ne peut exécuter que `systemctl status` et `tail` sur
les journaux, cette dernière sans saisir de mot de passe.

### Qui a le droit d'utiliser sudo ?

Sur Debian (et Ubuntu), l'appartenance au groupe `sudo` suffit pour avoir des
droits d'administration complets. Pour vérifier :

```bash
groups          # affiche vos groupes
id              # affiche UID, GID et groupes
```

Si votre compte n'est pas dans le groupe `sudo`, vous obtenez le message :

```
votre_login is not in the sudoers file. This incident will be reported.
```

L'ajout au groupe `sudo` se fait ainsi (commande à exécuter par un
administrateur existant) :

```bash
sudo usermod -aG sudo votre_login
```

La modification prend effet à la prochaine connexion (voir chapitre 5.1 pour
la gestion des groupes).

---

## Bonnes pratiques de sécurité

### Le principe du moindre privilège

Ce principe, fondamental en sécurité informatique, se résume ainsi : **ne
donner à un compte que les droits strictement nécessaires à ses tâches, ni
plus**.

En pratique :

- N'accordez pas les droits `sudo` complets à quelqu'un qui n'a besoin que
  de redémarrer un service.
- Préférez une autorisation sur une commande précise plutôt qu'un accès total.
- Révoquez les droits dès qu'ils ne sont plus nécessaires.

### Ne jamais copier une commande sudo sans la comprendre

Internet regorge de solutions qui commencent par `sudo`. Avant d'exécuter une
telle commande copiée-collée, posez-vous les questions suivantes :

- Que fait exactement chaque partie de cette commande ?
- Quels fichiers ou paramètres système va-t-elle modifier ?
- Est-ce réversible ?

Une commande exécutée en root peut supprimer des données, ouvrir des failles
de sécurité ou déstabiliser le système. Prendre 2 minutes pour comprendre
évite bien des catastrophes.

### Verrouiller sa session

Lorsque vous quittez votre poste, même brièvement, verrouillez votre session
ou déconnectez-vous. Si vous avez utilisé `sudo` récemment, le cache est
encore valide et n'importe qui assis devant votre écran pourrait exécuter des
commandes en root.

Dans un terminal :

```bash
sudo -k    # invalider le cache sudo avant de quitter
exit       # fermer le terminal ou la session SSH
```

Sur un bureau graphique, utilisez le raccourci de verrouillage de votre
environnement (souvent `Super + L`).

---

## L'essentiel

| Commande | Usage type |
|----------|-----------|
| `sudo <commande>` | Exécuter une commande en tant que root |
| `sudo -l` | Lister les droits sudo de votre compte |
| `sudo -v` | Renouveler le cache de mot de passe |
| `sudo -k` | Invalider le cache (force la re-saisie) |
| `sudo -u alice <commande>` | Exécuter en tant qu'un autre utilisateur |
| `groups` | Vérifier l'appartenance au groupe sudo |
| `sudo usermod -aG sudo login` | Ajouter un utilisateur au groupe sudo |

---

## Pour aller plus loin

### visudo et la syntaxe de /etc/sudoers

La configuration de `sudo` est stockée dans `/etc/sudoers`. Ce fichier ne
doit **jamais** être édité directement avec un éditeur de texte classique,
car une erreur de syntaxe rendrait sudo totalement inutilisable. L'outil
`visudo` vérifie la syntaxe avant de sauvegarder :

```bash
sudo visudo
```

La syntaxe d'une règle est la suivante :

```
utilisateur  MACHINE=(CIBLE)  COMMANDES
```

Exemples :

```bash
# Alice peut tout faire sur cette machine
alice ALL=(ALL:ALL) ALL

# Bob peut uniquement redémarrer nginx, sans mot de passe
bob ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx

# Le groupe developers peut exécuter certaines commandes web
%developers ALL=(www-data) /usr/bin/php, /usr/bin/composer
```

Pour une organisation modulaire, des fichiers séparés peuvent être placés
dans `/etc/sudoers.d/`. Chaque fichier est inclus automatiquement et peut
être édité avec :

```bash
sudo visudo -f /etc/sudoers.d/nom-du-fichier
```

### sudo -i vs su -

Ces deux commandes ouvrent un shell root interactif, mais avec une nuance :

- `sudo -i` ouvre un shell de connexion (*login shell*) root en utilisant
  votre propre mot de passe. Il charge l'environnement complet de root.
- `su -` ouvre également un shell de connexion root, mais demande le mot de
  passe **root** lui-même.

Sur Debian, le compte root n'a pas de mot de passe défini par défaut : `su -`
ne fonctionnera pas, seul `sudo -i` est disponible.

En règle générale, préférez `sudo -i` pour des interventions ponctuelles et
limitées. La forme `sudo su -` est déconseillée : elle enchaîne deux
élévations de privilèges, ce qui complique la journalisation et contourne
la protection apportée par `sudo`. Évitez de toute façon de rester dans un
shell root plus longtemps que nécessaire.

### Journalisation des commandes sudo

Chaque utilisation de `sudo` est enregistrée dans les journaux système. Cela
permet de savoir qui a exécuté quoi et quand. Pour consulter ces traces :

```bash
sudo grep sudo /var/log/auth.log | tail -20
```

Une entrée typique ressemble à :

```
Jun 11 10:23:04 machine sudo: alice : TTY=pts/1 ; PWD=/home/alice ;
USER=root ; COMMAND=/usr/bin/apt update
```

La journalisation est présentée en détail au chapitre 7.2 (logs système et
journalctl).

---

## Exercices

### Exercice 1 — Identifier ses droits sudo

Connectez-vous avec votre compte utilisateur normal et affichez la liste de
vos droits `sudo`.

1. Quelle commande utilisez-vous ?
2. Quelles commandes vous sont autorisées ?
3. Votre compte est-il dans le groupe `sudo` ? Vérifiez avec `groups`.

---

### Exercice 2 — Utilisation de base

Exécutez les commandes suivantes et observez le comportement :

```bash
# Afficher le contenu d'un fichier réservé à root
sudo cat /etc/shadow | head -3

# Mettre à jour la liste des paquets
sudo apt update

# Voir les dernières lignes du journal d'authentification
sudo tail -10 /var/log/auth.log
```

Après la première commande, avez-vous eu à saisir votre mot de passe pour
les suivantes ? Pourquoi ?

---

### Exercice 3 — Gestion du cache

1. Invalidez le cache sudo.
2. Exécutez `sudo whoami` : votre mot de passe est-il demandé ?
3. Exécutez à nouveau `sudo whoami` immédiatement : est-il demandé une
   seconde fois ?
4. Renouvelez le cache avec `sudo -v`.

---

### Exercice 4 — Exécuter en tant qu'un autre utilisateur

Créez un fichier appartenant à un autre utilisateur, puis utilisez `sudo -u`
pour y accéder en tant que cet utilisateur.

```bash
# Créer un fichier appartenant à www-data
echo "contenu web" | sudo tee /tmp/test_web.txt
sudo chown www-data /tmp/test_web.txt
sudo chmod 600 /tmp/test_web.txt

# Lire ce fichier en tant que www-data
sudo -u www-data cat /tmp/test_web.txt

# Tenter de le lire directement (sans sudo -u) : que se passe-t-il ?
cat /tmp/test_web.txt
```

Expliquez pourquoi la dernière commande échoue ou réussit selon votre compte.

---

### Exercice 5 — Identifier une commande inconnue

Voici une commande trouvée sur un forum :

```bash
sudo rm -rf /var/cache/apt/archives/
```

Avant de l'exécuter :

1. Décomposez chaque mot de la commande et expliquez son rôle.
2. Quel répertoire va-t-elle vider ?
3. L'opération est-elle réversible ?
4. Est-ce dangereux ? Pourquoi (ou pourquoi pas) ?

---

### Exercice 6 — Consulter les traces

Après avoir utilisé `sudo` plusieurs fois dans les exercices précédents,
consultez les journaux pour retrouver vos actions :

```bash
sudo grep "$(whoami)" /var/log/auth.log | grep "COMMAND" | tail -10
```

Retrouvez-vous les commandes que vous avez exécutées ? Quelle information
supplémentaire apparaît dans chaque entrée (heure, terminal, répertoire) ?

---

### Solutions

#### Solution exercice 1

```bash
sudo -l       # afficher les droits sudo
groups        # vérifier l'appartenance aux groupes
```

Sur Debian avec un compte administrateur standard, `sudo -l` affiche
généralement `(ALL : ALL) ALL`, signifiant tous les droits. Le groupe `sudo`
doit apparaître dans la sortie de `groups`.

#### Solution exercice 2

Après la première commande `sudo`, le mot de passe est mis en cache. Les
commandes suivantes dans les 15 minutes ne le redemandent pas. C'est le
mécanisme de cache de `sudo` (voir la section théorie).

#### Solution exercice 3

```bash
sudo -k               # invalider le cache
sudo whoami           # mot de passe demandé -> affiche "root"
sudo whoami           # pas de demande cette fois (cache rechargé)
sudo -v               # renouveler sans exécuter de commande
```

#### Solution exercice 4

La commande `cat /tmp/test_web.txt` échoue car le fichier a les permissions
`600` (lecture/écriture réservées au propriétaire `www-data`). Votre compte
n'est ni `www-data` ni root. Avec `sudo -u www-data cat ...`, vous exécutez
la lecture en tant que `www-data`, qui est bien le propriétaire.

#### Solution exercice 5

Décomposition de `sudo rm -rf /var/cache/apt/archives/` :

- `sudo` : exécuter en root
- `rm` : supprimer
- `-r` : récursivement (tous les sous-répertoires et fichiers)
- `-f` : forcer (pas de confirmation)
- `/var/cache/apt/archives/` : répertoire contenant les paquets `.deb`
  téléchargés par `apt`

Cette commande **vide le cache des paquets téléchargés**. Elle est réversible
(les paquets peuvent être re-téléchargés). Elle n'est pas dangereuse en
elle-même, mais illustre l'importance de comprendre avant d'exécuter : toute
commande commençant par `sudo rm -rf` mérite une attention particulière.

#### Solution exercice 6

Chaque entrée de journal contient :

- La date et l'heure exacte
- Le nom de la machine
- Le nom de votre compte
- Le terminal utilisé (`TTY=pts/0` par exemple)
- Le répertoire courant au moment de l'exécution (`PWD=...`)
- L'utilisateur cible (`USER=root`)
- La commande complète exécutée (`COMMAND=...`)

Ces informations constituent une trace d'audit précieuse pour savoir qui a
fait quoi et dans quel contexte.
