# Chapitre 5.1 — Utilisateurs et groupes

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - expliquer pourquoi Linux est un système multi-utilisateurs et quel rôle joue root ;
> - identifier votre identité et vos appartenances avec `whoami`, `id` et `groups` ;
> - lire et interpréter une ligne de `/etc/passwd` et de `/etc/group` ;
> - changer d'utilisateur avec `su`.
>
> **Durée en séance** : ~30 min.

---

## Un système multi-utilisateurs

### Pourquoi des comptes ?

Sur un ordinateur personnel sous Windows, vous avez souvent un seul compte et vous pouvez tout faire. Linux a été conçu dès le départ pour être utilisé par plusieurs personnes en même temps — sur un serveur, des dizaines d'utilisateurs peuvent être connectés simultanément.

Chaque compte représente une identité distincte. Le système attribue à chaque utilisateur un **numéro unique**, l'UID (User IDentifier). Ce numéro est celui que le noyau utilise en interne ; le nom d'utilisateur n'est qu'une étiquette lisible par les humains.

Cette séparation des identités sert trois objectifs :

- **Isolation** : les fichiers d'un utilisateur ne sont pas accessibles par les autres, sauf autorisation explicite (voir chapitre 5.2).
- **Traçabilité** : chaque action est attribuée à un compte précis (journaux système).
- **Sécurité** : limiter les droits d'un compte limite l'impact d'une erreur ou d'une intrusion.

### Le super-utilisateur root

Un compte occupe une place à part : **root**, dont l'UID est toujours 0. Root est l'administrateur absolu du système : il peut lire n'importe quel fichier, modifier n'importe quelle configuration, arrêter n'importe quel processus.

Travailler en permanence en root est dangereux — une simple erreur de frappe peut détruire le système. La bonne pratique est de travailler avec un compte ordinaire et de n'élever les privilèges que ponctuellement, via `sudo` (voir chapitre 5.3).

### Groupes : partager des droits

Un groupe est un ensemble d'utilisateurs qui partagent certains droits. Chaque utilisateur appartient à un **groupe principal** (défini à la création du compte) et peut appartenir à des **groupes secondaires**.

Par exemple, sur Debian, les membres du groupe `sudo` peuvent exécuter des commandes en tant que root. Les membres du groupe `adm` peuvent lire les journaux système sans être root.

---

## Qui suis-je ?

Avant de manipuler quoi que ce soit, il est utile de savoir sous quelle identité on travaille. Trois commandes répondent à cette question.

### `whoami` — mon nom d'utilisateur

```bash
whoami
```

Affiche simplement le nom de l'utilisateur courant. C'est la commande la plus rapide pour vérifier son identité, notamment après un changement de session.

```
alice
```

### `id` — mon identité complète

```bash
id
```

Affiche l'UID, le GID principal et la liste des groupes secondaires :

```
uid=1001(alice) gid=1001(alice) groups=1001(alice),27(sudo),1010(developers)
```

On voit ici qu'alice a l'UID 1001, appartient au groupe principal `alice` (GID 1001) et est également membre de `sudo` et `developers`.

Pour interroger un autre utilisateur :

```bash
id bob
```

### `groups` — mes appartenances aux groupes

```bash
groups
```

Affiche uniquement la liste des groupes de l'utilisateur courant, sous forme de noms :

```
alice sudo developers
```

C'est plus lisible que `id` quand on cherche uniquement les groupes. On peut aussi interroger un autre utilisateur :

```bash
groups bob
```

---

## Où sont définis les comptes ?

Linux stocke les informations sur les utilisateurs et les groupes dans des fichiers texte simples, situés dans `/etc/`. Ce sont des fichiers texte que l'on peut lire avec `cat` ou `less`.

### Le fichier `/etc/passwd`

Chaque ligne de ce fichier décrit un utilisateur. Le nom est trompeur : les mots de passe n'y sont plus stockés depuis longtemps (voir « Pour aller plus loin »).

```bash
cat /etc/passwd | grep alice
```

Résultat :

```
alice:x:1001:1001:Alice Dupont,,,:/home/alice:/bin/bash
```

Les sept champs sont séparés par des deux-points :

```
nom:mdp:UID:GID:commentaire:repertoire_personnel:shell
```

| Champ | Valeur | Signification |
|-------|--------|---------------|
| nom | `alice` | Nom d'utilisateur |
| mdp | `x` | Mot de passe dans `/etc/shadow` |
| UID | `1001` | Identifiant numérique unique |
| GID | `1001` | Groupe principal (numérique) |
| commentaire | `Alice Dupont,,,` | Nom complet et informations |
| repertoire | `/home/alice` | Répertoire de connexion |
| shell | `/bin/bash` | Interpréteur de commandes |

Le champ `x` à la place du mot de passe signifie que celui-ci est stocké de façon sécurisée dans `/etc/shadow` (accessible uniquement par root).

Pour les comptes système (services), on trouve souvent `/bin/false` ou `/sbin/nologin` comme shell — ce qui empêche toute connexion interactive.

### Le fichier `/etc/group`

Ce fichier liste tous les groupes du système. Format :

```bash
cat /etc/group | grep developers
```

Résultat :

```
developers:x:1010:alice,bob
```

Les quatre champs :

```
nom_groupe:mdp:GID:liste_membres
```

| Champ | Valeur | Signification |
|-------|--------|---------------|
| nom_groupe | `developers` | Nom du groupe |
| mdp | `x` | Rarement utilisé |
| GID | `1010` | Identifiant numérique du groupe |
| liste_membres | `alice,bob` | Membres secondaires, séparés par des virgules |

Remarque : un utilisateur dont le groupe principal est `developers` n'apparaît pas dans la liste des membres de ce fichier — il est rattaché via son GID dans `/etc/passwd`.

---

## Changer d'utilisateur

La commande `su` (Switch User) permet de prendre l'identité d'un autre utilisateur dans le terminal courant.

### Syntaxe de base

```bash
su - alice
```

Le tiret `-` est important : il charge l'environnement complet de l'utilisateur cible (variables d'environnement, répertoire de travail, profil shell). Sans le tiret, on change d'identité mais on conserve l'environnement courant — source fréquente de confusion.

Après la commande, le système demande le mot de passe d'alice. Une fois authentifié, le prompt change et toutes les commandes s'exécutent en tant qu'alice.

Pour revenir à l'utilisateur précédent :

```bash
exit
```

### Devenir root

```bash
su -
```

Demande le mot de passe de root. Sur certaines distributions (Ubuntu notamment), le compte root n'a pas de mot de passe défini — on passe par `sudo` à la place (voir chapitre 5.3).

### Vérifier son identité après un changement

Après un `su`, la bonne réflexe est de vérifier qui on est :

```bash
su - bob
whoami
# bob
id
# uid=1002(bob) gid=1002(bob) groups=1002(bob),1010(developers),1011(testers)
```

---

## L'essentiel

| Commande | Usage type |
|----------|-----------|
| `whoami` | Afficher son nom d'utilisateur courant |
| `id` | Afficher UID, GID et tous les groupes |
| `id alice` | Afficher l'identité d'un autre utilisateur |
| `groups` | Lister ses groupes (noms uniquement) |
| `cat /etc/passwd` | Consulter la base des utilisateurs |
| `cat /etc/group` | Consulter la base des groupes |
| `su - alice` | Changer d'utilisateur (avec son environnement) |
| `su -` | Devenir root |
| `exit` | Quitter la session `su` et revenir au compte précédent |

---

## Pour aller plus loin

### Créer et modifier des comptes (administration)

Sur Debian et Ubuntu, la commande `adduser` est plus conviviale que `useradd` car elle pose des questions interactives et crée automatiquement le répertoire personnel :

```bash
sudo adduser martin
```

Pour créer un groupe :

```bash
sudo addgroup projet_alpha
```

Pour ajouter un utilisateur à un groupe existant :

```bash
sudo usermod -aG projet_alpha martin
```

L'option `-aG` signifie « ajouter au(x) groupe(s) » sans retirer les appartenances existantes. Oublier le `-a` remplacerait tous les groupes secondaires — erreur fréquente à éviter.

La prise d'effet de ce changement de groupe nécessite que l'utilisateur ouvre une nouvelle session.

### UID, GID et plages numériques

Les identifiants numériques suivent une convention :

- **UID 0** : root (toujours)
- **UID 1 à 999** : comptes système (services comme `www-data`, `sshd`, `mysql`)
- **UID 1000 et au-delà** : comptes humains

Cette convention est définie dans `/etc/login.defs`. Les comptes système ont généralement `/bin/false` ou `/sbin/nologin` comme shell pour interdire la connexion interactive.

Pour lister uniquement les comptes humains :

```bash
getent passwd | awk -F: '$3 >= 1000 {print $1, $3}'
```

### Le fichier `/etc/shadow`

Les mots de passe ne sont pas stockés en clair dans `/etc/passwd` mais sous forme hachée dans `/etc/shadow`. Ce fichier n'est lisible que par root :

```bash
sudo cat /etc/shadow | grep alice
```

On y trouve aussi des informations sur l'expiration des mots de passe, le nombre de jours depuis le dernier changement, etc.

La commande `passwd` permet à un utilisateur de changer son propre mot de passe, et à root de changer n'importe quel mot de passe :

```bash
passwd          # Changer son propre mot de passe
sudo passwd bob # Changer le mot de passe de bob (root uniquement)
```

---

## Exercices

### Exercice 1 — Exploration de son identité

Exécutez les trois commandes suivantes et notez les résultats :

```bash
whoami
id
groups
```

Répondez aux questions :
1. Quel est votre UID ?
2. Quel est votre groupe principal (GID et nom) ?
3. Combien de groupes secondaires avez-vous ?

---

### Exercice 2 — Lecture de `/etc/passwd`

Affichez la ligne de `/etc/passwd` correspondant à votre compte :

```bash
grep "$(whoami)" /etc/passwd
```

Identifiez chacun des sept champs et donnez leur signification.

Ensuite, affichez les cinq dernières lignes de `/etc/passwd` :

```bash
tail -5 /etc/passwd
```

Parmi ces lignes, repérez un compte système (shell `/bin/false` ou `/sbin/nologin`) et expliquez pourquoi ce compte a ce type de shell.

---

### Exercice 3 — Lecture de `/etc/group`

Affichez le contenu de `/etc/group` et repérez le groupe `sudo` (ou `wheel` selon la distribution) :

```bash
grep "^sudo" /etc/group
```

1. Quel est le GID du groupe `sudo` ?
2. Quels utilisateurs sont listés comme membres ?
3. Votre compte est-il dans ce groupe ? Vérifiez avec `groups`.

---

### Exercice 4 — Changer d'utilisateur

Si votre système dispose d'un second compte (ou si votre formateur vous en fournit un), pratiquez le changement de session :

```bash
su - autrecompte
whoami
id
exit
whoami
```

Vérifiez que `whoami` affiche le bon nom avant et après le `su`, et que `exit` vous ramène bien à votre compte d'origine.

---

### Exercice 5 — Comptes système

Listez les comptes dont le shell est `/bin/false` ou `/sbin/nologin` :

```bash
grep -E "(/bin/false|/sbin/nologin)$" /etc/passwd | cut -d: -f1
```

1. Combien de tels comptes trouvez-vous ?
2. Reconnaissez-vous des noms de services (web, base de données, SSH...) ?
3. Pourquoi est-il important que ces comptes ne puissent pas se connecter de façon interactive ?

---

### Solutions

#### Solution exercice 1

Les valeurs sont propres à chaque machine, mais voici un exemple de résultat attendu :

```
alice                          <- whoami
uid=1001(alice) gid=1001(alice) groups=1001(alice),27(sudo),1010(developers)
                               <- id
alice sudo developers          <- groups
```

- UID : `1001` (le nombre entre parenthèses après `uid=`)
- Groupe principal : GID `1001`, nom `alice`
- Groupes secondaires : `sudo` et `developers` (soit 2 groupes secondaires en plus du principal)

#### Solution exercice 2

Exemple de ligne pour l'utilisateur `alice` :

```
alice:x:1001:1001:Alice Dupont,,,:/home/alice:/bin/bash
```

| Champ | Valeur | Signification |
|-------|--------|---------------|
| 1 | `alice` | Nom d'utilisateur |
| 2 | `x` | Mot de passe dans `/etc/shadow` |
| 3 | `1001` | UID |
| 4 | `1001` | GID du groupe principal |
| 5 | `Alice Dupont,,,` | Commentaire (nom complet) |
| 6 | `/home/alice` | Répertoire personnel |
| 7 | `/bin/bash` | Shell de connexion |

Un compte système avec `/sbin/nologin` comme `sshd` :

```
sshd:x:104:65534::/run/sshd:/usr/sbin/nologin
```

Le shell `/usr/sbin/nologin` affiche un message d'erreur et refuse toute connexion interactive — c'est une mesure de sécurité, car le service SSH n'a pas besoin d'un shell pour fonctionner.

#### Solution exercice 3

Exemple de résultat :

```
sudo:x:27:alice,martin
```

- GID du groupe `sudo` : `27`
- Membres listés : `alice` et `martin`
- Pour vérifier si votre compte est dans le groupe : `groups` doit afficher `sudo` dans la liste.

#### Solution exercice 4

Résultat attendu :

```bash
whoami     # alice   <- avant le su
su - bob
Password:
whoami     # bob     <- après le su
id         # uid=1002(bob) gid=1002(bob) groups=1002(bob),...
exit
whoami     # alice   <- après exit
```

#### Solution exercice 5

Exemple de résultat partiel :

```
daemon
bin
sys
www-data
mysql
sshd
```

On reconnaît : `www-data` (serveur web Apache/Nginx), `mysql` (base de données), `sshd` (service SSH).

Ces comptes ne doivent pas pouvoir se connecter de façon interactive car ils sont créés uniquement pour faire tourner des services en arrière-plan. S'ils pouvaient ouvrir un shell, un attaquant qui compromet un service pourrait utiliser ce compte pour explorer le système.
