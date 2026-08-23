# Chapitre 6.3 — Variables d'environnement et historique

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - lire et modifier les variables d'environnement de votre session ;
> - comprendre le rôle de `PATH` et savoir pourquoi il est important ;
> - retrouver et réutiliser d'anciennes commandes grâce à l'historique ;
> - savoir où les configurations persistantes se définissent (`~/.bashrc`).
>
> **Durée en séance** : ~30 min.

---

## Les variables d'environnement

### Qu'est-ce qu'une variable d'environnement ?

Lorsque vous ouvrez un terminal, le shell dispose d'un ensemble de
**variables** qui décrivent votre environnement de travail : qui vous êtes,
où se trouvent les programmes, quelle langue utiliser, etc.

Ces variables sont héritées par tous les programmes que vous lancez depuis
ce terminal. C'est pourquoi on les appelle variables *d'environnement* :
elles forment le contexte dans lequel chaque commande s'exécute.

Deux variables incontournables :

```bash
echo $HOME    # Affiche votre répertoire personnel, ex. : /home/alice
echo $USER    # Affiche votre nom d'utilisateur
```

Le signe `$` devant le nom indique au shell qu'il doit remplacer le nom
par la valeur de la variable avant d'exécuter la commande.

### La variable PATH

`PATH` est probablement la variable la plus importante. Elle contient la
liste des répertoires dans lesquels le shell cherche les programmes quand
vous tapez une commande.

```bash
echo $PATH
# Exemple de résultat :
# /usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
```

Chaque répertoire est séparé par un deux-points (`:`). Quand vous tapez
`ls`, le shell parcourt ces répertoires dans l'ordre de gauche à droite et
exécute le premier `ls` qu'il trouve. Si un répertoire n'est pas dans
`PATH`, les programmes qu'il contient ne sont pas accessibles par leur
seul nom : il faut taper le chemin complet.

Pour savoir où se trouve une commande, utilisez `which` :

```bash
which ls      # Répond : /usr/bin/ls
which python3 # Répond le chemin, ou rien si absent du PATH
```

### Créer et exporter une variable

```bash
# Créer une variable locale (visible uniquement dans le shell courant)
PRENOM="Alice"
echo $PRENOM    # Affiche : Alice

# Exporter la variable (visible aussi dans les programmes enfants)
export PRENOM="Alice"
```

La différence est importante : une variable créée sans `export` disparaît
dès qu'un programme enfant est lancé. Avec `export`, elle est transmise.

Exemple pour s'en convaincre :

```bash
LOCALE="sans_export"
export EXPORTEE="avec_export"

bash -c 'echo $LOCALE'    # Affiche rien (variable locale)
bash -c 'echo $EXPORTEE'  # Affiche : avec_export
```

La commande `bash -c '...'` ouvre un shell enfant pour la durée de la
commande. C'est le même phénomène qui se produit quand vous lancez un
script ou une application.

### Portée d'une variable : la session courante

Une variable définie dans un terminal n'existe que pendant la durée de
cette session. Si vous fermez le terminal et en ouvrez un nouveau, la
variable a disparu.

Pour qu'une variable survive à la fermeture du terminal, il faut la
déclarer dans le fichier `~/.bashrc`, qui est relu à chaque ouverture de
session (voir la section « Où ça se configure » plus bas).

### Modifier PATH

Pour ajouter un répertoire à `PATH`, on reconstruit la variable en
incluant l'ancienne valeur `$PATH` :

```bash
# Ajouter ~/bin en tête (priorité la plus haute)
export PATH="$HOME/bin:$PATH"

# Vérifier le résultat
echo $PATH
```

L'ordre compte : le shell s'arrête au premier répertoire où il trouve
le programme demandé.

---

## L'historique des commandes

### Consulter l'historique avec `history`

Le shell mémorise les commandes que vous tapez dans un fichier
(`~/.bash_history`). La commande `history` affiche cet historique avec
un numéro de séquence devant chaque ligne :

```bash
history         # Affiche tout l'historique
history 15      # Affiche uniquement les 15 dernières commandes
```

Exemple de sortie :

```
  498  ls -la
  499  cd /var/log
  500  sudo tail syslog
  501  cd ~
  502  history
```

### Réexécuter une commande par son numéro : `!n`

Le point d'exclamation suivi d'un numéro rejoue la commande
correspondante :

```bash
!499    # Rejoue : cd /var/log
!!      # Rejoue la toute dernière commande (très pratique)
```

`!!` est particulièrement utile quand vous avez oublié `sudo` :

```bash
apt update
# Permission denied
sudo !!    # Rejoue : sudo apt update
```

`!$` désigne le dernier *argument* de la commande précédente :

```bash
mkdir /tmp/mon_dossier
cd !$    # Revient à : cd /tmp/mon_dossier
```

### Recherche interactive : Ctrl+R

La combinaison **Ctrl+R** ouvre une recherche dans l'historique. Vous
tapez quelques lettres et le shell affiche la commande la plus récente
qui contient ce texte :

```
(reverse-i-search)`tail': sudo tail -f /var/log/syslog
```

Appuyez à nouveau sur **Ctrl+R** pour remonter aux occurrences plus
anciennes. Appuyez sur **Entrée** pour exécuter la commande trouvée, ou
sur **Tab** pour l'éditer avant de l'exécuter. Pour annuler la recherche
sans rien exécuter, appuyez sur **Ctrl+G**.

C'est de loin la façon la plus rapide de retrouver une longue commande
que l'on a tapée il y a quelques heures.

---

## Où ça se configure : `~/.bashrc`

Le fichier `~/.bashrc` est un script shell exécuté automatiquement à
chaque ouverture d'un terminal interactif. C'est l'endroit standard pour
déclarer des variables persistantes, des alias ou des réglages de
l'historique.

```bash
# Ouvrir le fichier dans nano pour jeter un coup d'oeil
nano ~/.bashrc
```

Après avoir modifié `~/.bashrc`, il faut recharger la configuration
sans fermer le terminal :

```bash
source ~/.bashrc
```

La personnalisation de ce fichier (alias, prompt, fonctions...) est
abordée en détail au chapitre 8.3. Pour l'instant, retenez simplement
que c'est ici que vous placerez vos `export` pour qu'ils soient actifs
à chaque nouvelle session.

---

## L'essentiel

| Commande / Expression | Usage type |
|-----------------------|------------|
| `echo $NOM`           | Afficher la valeur d'une variable |
| `echo $HOME`          | Afficher le répertoire personnel |
| `echo $PATH`          | Voir les répertoires de recherche des commandes |
| `export VAR=valeur`   | Créer ou modifier une variable exportée |
| `which commande`      | Savoir où se trouve un programme dans PATH |
| `history`             | Afficher l'historique des commandes |
| `history 20`          | Afficher les 20 dernières commandes |
| `!n`                  | Rejouer la commande numéro n |
| `!!`                  | Rejouer la dernière commande |
| `!$`                  | Dernier argument de la commande précédente |
| Ctrl+R                | Recherche interactive dans l'historique |
| `source ~/.bashrc`    | Recharger la configuration sans fermer le terminal |

---

## Pour aller plus loin

### Lister toutes les variables : `env` et `printenv`

`env` et `printenv` affichent l'ensemble des variables d'environnement
actuellement exportées :

```bash
env           # Toutes les variables exportées
printenv HOME # Une variable précise (sans le signe $)
```

La différence entre les deux est minime en pratique. `printenv` est
souvent préféré quand on veut interroger une seule variable, car il
retourne un code d'erreur si la variable n'existe pas.

### Variables utiles à connaître

| Variable  | Rôle |
|-----------|------|
| `PS1`     | Définit l'apparence du prompt (voir chapitre 8.3) |
| `EDITOR`  | Éditeur de texte par défaut (`nano`, `vim`...) |
| `LANG`    | Langue et encodage du système (`fr_FR.UTF-8` par ex.) |
| `SHELL`   | Chemin vers le shell actif (`/bin/bash`) |

Pour définir votre éditeur préféré de façon permanente :

```bash
# Dans ~/.bashrc
export EDITOR=nano
```

Certains programmes comme `git` utilisent `EDITOR` pour savoir quel
éditeur ouvrir lors d'une saisie de message de commit.

### Contrôler la taille de l'historique

Deux variables gèrent la taille de l'historique :

- `HISTSIZE` : nombre de commandes conservées *en mémoire* pendant la
  session courante.
- `HISTFILESIZE` : nombre de lignes conservées dans le fichier
  `~/.bash_history` lors de la fermeture du terminal.

```bash
echo $HISTSIZE        # Affiche la valeur actuelle (souvent 1000)
echo $HISTFILESIZE    # Valeur du fichier disque

# Augmenter la taille dans ~/.bashrc
export HISTSIZE=5000
export HISTFILESIZE=10000
```

Une valeur plus grande permet de retrouver des commandes tapées plusieurs
jours auparavant, ce qui s'avère très pratique.

### Expansion d'historique avancée

En plus de `!!` et `!n`, quelques raccourcis méritent d'être connus :

```bash
!ssh       # Dernière commande qui commence par "ssh"
!?grep     # Dernière commande qui contient "grep"
^ancien^nouveau   # Remplace "ancien" par "nouveau" dans la dernière commande
```

Exemple concret de la substitution rapide :

```bash
cat /var/log/syslog | grep "erorr"
# Pas de résultat à cause de la faute de frappe

^erorr^error    # Rejoue la commande avec la correction
```

---

## Exercices

### Exercice 1 — Explorer les variables de l'environnement

Affichez successivement la valeur des variables `HOME`, `USER`, `SHELL`
et `PATH`. Pour `PATH`, comptez combien de répertoires sont listés
(indice : les séparateurs sont les deux-points).

Ensuite, affichez uniquement les variables dont le nom contient `HIST`
en combinant `env` et `grep`.

### Exercice 2 — Créer une variable et observer sa portée

1. Créez une variable `FORMATION` avec la valeur `linux` sans utiliser
   `export`.
2. Vérifiez qu'elle est accessible dans votre shell avec `echo`.
3. Ouvrez un sous-shell avec la commande `bash`, puis essayez d'afficher
   `$FORMATION`. Que se passe-t-il ?
4. Quittez le sous-shell avec `exit`.
5. Recommencez l'opération en utilisant cette fois `export FORMATION=linux`,
   puis relancez le sous-shell.

### Exercice 3 — Ajouter un répertoire au PATH

1. Créez le répertoire `~/mes_scripts` s'il n'existe pas.
2. Créez dans ce répertoire un fichier `bonjour` contenant la ligne
   `echo "Bonjour depuis mes_scripts !"` et rendez-le exécutable
   (`chmod +x ~/mes_scripts/bonjour`).
3. Essayez de taper `bonjour` : que se passe-t-il ?
4. Ajoutez `~/mes_scripts` au début de `PATH` avec `export`.
5. Tapez de nouveau `bonjour`. Vérifiez avec `which bonjour` que le
   shell trouve bien le fichier.

### Exercice 4 — Maîtriser l'historique

1. Tapez quelques commandes variées (`ls`, `pwd`, `echo bonjour`, etc.).
2. Affichez les 10 dernières entrées de l'historique.
3. Repérez le numéro de l'une des commandes et rejouez-la avec `!n`.
4. Utilisez `!!` pour rejouer la toute dernière commande.
5. Utilisez **Ctrl+R** pour rechercher une commande contenant `echo`.
   Appuyez sur **Entrée** pour l'exécuter.

### Exercice 5 — Retrouver une commande oubliée

Vous avez tapé une longue commande `find` il y a quelques minutes et
vous ne vous en souvenez plus exactement. Reproduisez la situation :

1. Tapez la commande suivante : `find /etc -name "*.conf" -type f 2>/dev/null | head -5`
2. Tapez ensuite une dizaine d'autres commandes quelconques.
3. Sans remonter manuellement dans l'historique, utilisez **Ctrl+R** et
   tapez `find` pour retrouver la commande. Appuyez sur **Tab** pour
   l'éditer (par exemple, changez `/etc` en `/var`) puis exécutez-la.

---

### Solutions

#### Solution exercice 1

```bash
echo $HOME
echo $USER
echo $SHELL
echo $PATH

# Compter les répertoires dans PATH (chaque : sépare deux entrées)
echo $PATH | tr ':' '\n' | wc -l

# Afficher les variables contenant HIST
env | grep HIST
```

#### Solution exercice 2

```bash
# Sans export
FORMATION=linux
echo $FORMATION     # Affiche : linux

bash
echo $FORMATION     # N'affiche rien : variable non exportée
exit

# Avec export
export FORMATION=linux
bash
echo $FORMATION     # Affiche : linux
exit
```

La variable non exportée reste dans le shell courant ; elle n'est pas
transmise aux processus enfants (sous-shells, scripts, applications).

#### Solution exercice 3

```bash
mkdir -p ~/mes_scripts

cat > ~/mes_scripts/bonjour << 'EOF'
echo "Bonjour depuis mes_scripts !"
EOF
chmod +x ~/mes_scripts/bonjour

bonjour   # Erreur : command not found

export PATH="$HOME/mes_scripts:$PATH"

bonjour        # Affiche : Bonjour depuis mes_scripts !
which bonjour  # Affiche : /home/<user>/mes_scripts/bonjour
```

#### Solution exercice 4

```bash
ls
pwd
echo bonjour
date
uptime

history 10

# Repérez par exemple le numéro 3 de votre session, ex. 52 :
!52

# Dernière commande :
!!

# Recherche interactive :
# Ctrl+R, puis taper : echo
# Appuyer sur Entrée pour exécuter
```

#### Solution exercice 5

```bash
# Commande à mémoriser
find /etc -name "*.conf" -type f 2>/dev/null | head -5

# Quelques commandes quelconques
ls
pwd
date
echo test
uname -r
whoami
cat /etc/hostname
id
uptime
df -h

# Recherche interactive :
# Ctrl+R, puis taper : find
# Le shell affiche la commande find /etc ...
# Appuyer sur Tab pour l'éditer, changer /etc par /var
# Appuyer sur Entrée pour exécuter
```
