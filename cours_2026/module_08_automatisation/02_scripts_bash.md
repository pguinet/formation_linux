# Chapitre 8.2 — Scripts bash : les bases

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - Créer un script bash exécutable avec le shebang approprié.
> - Utiliser des variables, traiter des arguments et contrôler le flux avec conditions et boucles.
> - Écrire un script de sauvegarde autonome combinant ces notions.
>
> **Durée en séance** : ~30 min.

---

## Mon premier script

Un script bash est un simple fichier texte contenant des commandes shell. La première ligne — le **shebang** — indique au système quel interpréteur utiliser.

```bash
#!/bin/bash
# Mon premier script

echo "Bonjour, je suis un script bash !"
echo "Date : $(date)"
```

Enregistrez ce fichier sous le nom `bonjour.sh`, puis rendez-le exécutable :

```bash
chmod +x bonjour.sh
./bonjour.sh
```

L'instruction `chmod +x` (voir chapitre 5.2) est indispensable : sans elle, le système refusera de lancer le fichier comme programme. Vous pouvez toujours l'exécuter explicitement avec `bash bonjour.sh`, mais la convention est d'utiliser `./`.

---

## Variables et arguments

### Variables locales

Une variable se définit sans espace autour du signe `=`. On la lit en préfixant son nom avec `$` :

```bash
NOM="Alice"
AGE=30
echo "Bonjour, $NOM ! Vous avez $AGE ans."
```

Utilisez des accolades pour lever toute ambiguïté : `${NOM}s` affichera `Alices`, `$NOMs` chercherait une variable `NOMs` inexistante.

### Arguments positionnels

Lorsqu'on appelle `./script.sh val1 val2`, bash peuple automatiquement :

| Variable | Contenu |
|----------|---------|
| `$0`     | Nom du script |
| `$1`, `$2`... | Premier, deuxième argument... |
| `$#`     | Nombre d'arguments reçus |
| `"$@"`   | Tous les arguments, chacun bien isolé entre guillemets |

```bash
#!/bin/bash
echo "Script : $0"
echo "Premier argument : $1"
echo "Tous les arguments : $@"
echo "Nombre d'arguments : $#"
```

---

## Conditions

La structure de base est `if [ ... ]; then ... fi`. Les crochets sont en réalité une commande : les espaces autour des opérandes sont **obligatoires**.

### Tests courants

| Test | Signification |
|------|---------------|
| `-f fichier` | Le chemin existe et est un fichier ordinaire |
| `-d chemin`  | Le chemin existe et est un répertoire |
| `"$a" = "b"` | Deux chaînes sont égales |
| `$n -eq 0`   | Deux entiers sont égaux |
| `$n -gt 0`   | Entier strictement positif |
| `-z "$var"`  | Variable vide ou non définie |

### Exemple complet

```bash
#!/bin/bash
# Vérifie qu'un répertoire source est passé en argument

SOURCE="$1"

if [ -z "$SOURCE" ]; then
    echo "Usage : $0 <répertoire>"
    exit 1
fi

if [ -d "$SOURCE" ]; then
    echo "Le répertoire '$SOURCE' existe."
else
    echo "ERREUR : '$SOURCE' est introuvable."
    exit 1
fi
```

La commande `exit 1` termine le script avec un code d'erreur non nul — convention Unix pour signaler un problème (voir « Pour aller plus loin »).

---

## Boucles

### La boucle `for`

Elle parcourt une liste de valeurs. La syntaxe `*.txt` utilise le globbing du shell (expansion automatique des noms de fichiers).

```bash
#!/bin/bash
# Affiche la taille de chaque fichier .log du répertoire courant

for fichier in *.log; do
    if [ -f "$fichier" ]; then
        echo "$fichier : $(wc -l < "$fichier") lignes"
    fi
done
```

La variable de boucle (`fichier` ici) prend tour à tour la valeur de chaque élément de la liste. Le corps du `do ... done` est exécuté pour chacun.

---

## Script-exemple : sauvegarde datée

Voici un script d'une quinzaine de lignes qui combine tout ce qui précède — variables, arguments, condition sur un répertoire, et archivage `tar` (voir chapitre 3.3) :

```bash
#!/bin/bash
# sauvegarde.sh — sauvegarde un répertoire dans ~/backups/
# Usage : ./sauvegarde.sh <répertoire_source>

SOURCE="$1"
DEST="$HOME/backups"
DATE=$(date +%Y%m%d_%H%M%S)
ARCHIVE="$DEST/backup_${DATE}.tar.gz"

if [ -z "$SOURCE" ] || [ ! -d "$SOURCE" ]; then
    echo "Usage : $0 <répertoire>"
    exit 1
fi

mkdir -p "$DEST"
tar -czf "$ARCHIVE" "$SOURCE"
echo "Sauvegarde créée : $ARCHIVE"
```

Testez-le ainsi :

```bash
chmod +x sauvegarde.sh
./sauvegarde.sh ~/Documents
ls ~/backups/
```

---

## L'essentiel

| Syntaxe | Usage type |
|---------|------------|
| `#!/bin/bash` | Première ligne de tout script bash |
| `chmod +x script.sh` | Rendre un script exécutable |
| `./script.sh arg1 arg2` | Lancer le script avec des arguments |
| `NOM=valeur` | Définir une variable (pas d'espace autour de `=`) |
| `$NOM`, `${NOM}` | Lire une variable |
| `$1`, `$2`, `"$@"` | Arguments positionnels |
| `if [ -f "$f" ]; then ... fi` | Condition sur l'existence d'un fichier |
| `if [ -d "$d" ]; then ... fi` | Condition sur l'existence d'un répertoire |
| `if [ "$a" = "$b" ]; then ... fi` | Comparaison de chaînes |
| `if [ "$n" -eq 0 ]; then ... fi` | Comparaison numérique |
| `for f in *.txt; do ... done` | Boucle sur une liste de fichiers |
| `exit 0` / `exit 1` | Fin normale / fin avec erreur |

---

## Pour aller plus loin

### La boucle `while` et la saisie interactive

`while` répète un bloc tant qu'une condition est vraie. Combinée à `read`, elle permet des scripts interactifs :

```bash
#!/bin/bash
echo "Entrez des noms (ligne vide pour arrêter) :"
while read -r ligne; do
    [ -z "$ligne" ] && break
    echo "  -> Bonjour, $ligne !"
done
```

### Fonctions

Une fonction regroupe des commandes réutilisables dans le même script :

```bash
saluer() {
    local prenom="$1"
    echo "Bonjour, $prenom !"
}

saluer "Alice"
saluer "Bob"
```

Le mot-clé `local` limite la portée de la variable à la fonction.

### Codes de retour avec `$?`

Chaque commande renvoie un code de sortie accessible via `$?` : `0` signifie succès, toute autre valeur signale une erreur. C'est ce que testent implicitement `if` et `while`.

```bash
cp source.txt dest.txt
if [ $? -ne 0 ]; then
    echo "La copie a échoué."
fi
```

### `set -e` et robustesse

Ajoutez `set -e` au début d'un script pour qu'il s'arrête immédiatement à la première erreur, sans continuer sur une base défaillante. Une règle encore plus stricte est `set -euo pipefail` :

- `-e` : arrêt sur erreur
- `-u` : erreur si une variable non définie est utilisée
- `-o pipefail` : échec si une commande dans un pipeline échoue

### ShellCheck — l'outil indispensable

[ShellCheck](https://www.shellcheck.net) analyse vos scripts et signale les erreurs courantes avant même l'exécution. Sur Debian/Ubuntu : `sudo apt install shellcheck`, puis `shellcheck mon_script.sh`.

---

## Exercices

### Exercice 1 — Premier script

Créez un script `infos.sh` qui affiche :
- Votre nom d'utilisateur (`$USER`)
- Le répertoire courant (`$PWD`)
- La date et l'heure actuelles

Rendez-le exécutable et lancez-le.

---

### Exercice 2 — Script avec argument

Créez un script `verif_fichier.sh` qui reçoit un chemin en argument et affiche :
- « Fichier ordinaire » si c'est un fichier
- « Répertoire » si c'est un dossier
- « Introuvable » sinon

Testez-le avec `/etc/passwd`, `/etc`, et un chemin inexistant.

---

### Exercice 3 — Boucle sur des fichiers

Créez un répertoire `test_boucle/` contenant quelques fichiers `.txt` (avec `touch`). Écrivez un script `liste_txt.sh` qui affiche le nom et le nombre de lignes de chaque fichier `.txt` du répertoire courant.

---

### Exercice 4 — Script de sauvegarde paramétrable

Créez un script `sauvegarde_v2.sh` qui :
1. Reçoit deux arguments : `<source>` et `<destination>`
2. Vérifie que le répertoire source existe (sinon affiche un message d'erreur et quitte avec `exit 1`)
3. Crée le répertoire de destination s'il n'existe pas
4. Crée une archive `tar.gz` nommée avec la date et l'heure (`backup_YYYYMMDD_HHMMSS.tar.gz`)
5. Affiche un message de confirmation avec le chemin de l'archive créée

**Exemple d'utilisation :**

```bash
chmod +x sauvegarde_v2.sh
./sauvegarde_v2.sh ~/Documents ~/mes_backups
```

---

### Exercice 5 (approfondissement) — Rotation des sauvegardes

Améliorez `sauvegarde_v2.sh` en ajoutant, après la création de l'archive, une étape de nettoyage : ne garder que les 5 archives les plus récentes dans le répertoire de destination. Indication : `ls -t` trie par date, `tail -n +6` permet de sélectionner les plus anciennes.

---

### Solutions

#### Solution exercice 1

```bash
#!/bin/bash
# infos.sh — affiche des informations sur l'environnement courant

echo "Utilisateur : $USER"
echo "Répertoire courant : $PWD"
echo "Date et heure : $(date)"
```

```bash
chmod +x infos.sh
./infos.sh
```

---

#### Solution exercice 2

```bash
#!/bin/bash
# verif_fichier.sh — identifie le type d'un chemin passé en argument

CHEMIN="$1"

if [ -z "$CHEMIN" ]; then
    echo "Usage : $0 <chemin>"
    exit 1
fi

if [ -f "$CHEMIN" ]; then
    echo "Fichier ordinaire"
elif [ -d "$CHEMIN" ]; then
    echo "Répertoire"
else
    echo "Introuvable"
fi
```

---

#### Solution exercice 3

```bash
#!/bin/bash
# liste_txt.sh — affiche le nom et le nombre de lignes de chaque .txt

for fichier in *.txt; do
    if [ -f "$fichier" ]; then
        lignes=$(wc -l < "$fichier")
        echo "$fichier : $lignes ligne(s)"
    fi
done
```

Préparation :

```bash
mkdir test_boucle
cd test_boucle
echo -e "ligne1\nligne2\nligne3" > alpha.txt
echo -e "a\nb" > beta.txt
touch vide.txt
bash ../liste_txt.sh
```

---

#### Solution exercice 4

```bash
#!/bin/bash
# sauvegarde_v2.sh — sauvegarde paramétrable avec vérifications

SOURCE="$1"
DEST="$2"
DATE=$(date +%Y%m%d_%H%M%S)
ARCHIVE="$DEST/backup_${DATE}.tar.gz"

if [ -z "$SOURCE" ] || [ -z "$DEST" ]; then
    echo "Usage : $0 <source> <destination>"
    exit 1
fi

if [ ! -d "$SOURCE" ]; then
    echo "ERREUR : le répertoire source '$SOURCE' n'existe pas."
    exit 1
fi

mkdir -p "$DEST"
tar -czf "$ARCHIVE" "$SOURCE"
echo "Sauvegarde créée : $ARCHIVE"
```

---

#### Solution exercice 5

Ajoutez ces lignes à la fin du script, après le `echo` de confirmation :

```bash
# Rotation : on ne garde que les 5 archives les plus récentes
cd "$DEST"
ls -t backup_*.tar.gz 2>/dev/null | tail -n +6 | while read -r ancien; do
    rm "$ancien"
    echo "Supprimé : $ancien"
done
```

`ls -t` trie par date décroissante (la plus récente en premier) ; `tail -n +6` saute les 5 premières lignes et retourne tout le reste — c'est-à-dire les archives au-delà des 5 plus récentes.
