# Chapitre 4.3 — Chercher dans les fichiers et comparer

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - Rechercher du texte à l'intérieur d'un fichier avec `grep` et ses options essentielles ;
> - Distinguer `grep` (recherche de contenu) de `find` (recherche de noms de fichiers) ;
> - Comparer deux fichiers avec `diff` et interpréter sa sortie ;
> - Utiliser les expressions régulières de base pour des recherches plus précises.
>
> **Durée en séance** : ~30 min.

---

## Chercher du texte : la commande `grep`

### Principe

`grep` parcourt un fichier ligne par ligne et affiche chaque ligne qui contient le motif
recherché. Son nom vient de « Global Regular Expression Print ».

```
grep motif fichier
```

Exemple concret — afficher les lignes contenant le mot « error » dans un journal :

```bash
grep "error" /var/log/syslog
```

La sortie liste uniquement les lignes correspondantes ; toutes les autres sont masquées.

> **`grep` ou `find` ?**
> Ces deux commandes sont complémentaires, pas interchangeables :
> - `find` cherche des **noms de fichiers** dans l'arborescence (voir chapitre 3.3) ;
> - `grep` cherche du **contenu à l'intérieur** des fichiers.
> Retenez : *find trouve des fichiers, grep trouve du texte.*

---

### Options indispensables

#### `-i` — ignorer la casse

Par défaut, `grep` respecte la casse : « Error » et « error » sont deux motifs différents.
L'option `-i` rend la recherche insensible aux majuscules/minuscules.

```bash
# Trouve "error", "Error", "ERROR"...
grep -i "error" /var/log/syslog
```

Utile pour chercher dans des journaux où les niveaux de sévérité peuvent être écrits
en majuscules ou en minuscules selon l'application.

#### `-n` — afficher les numéros de lignes

Ajoute le numéro de chaque ligne correspondante en préfixe, ce qui facilite grandement
la localisation dans un éditeur.

```bash
grep -n "root" /etc/passwd
```

Exemple de sortie :

```
1:root:x:0:0:root:/root:/bin/bash
```

La ligne 1 contient « root » — le numéro apparaît avant le deux-points.

#### `-v` — inverser la recherche

Affiche les lignes qui **ne contiennent pas** le motif. Pratique pour filtrer les
lignes de commentaires ou les lignes vides dans un fichier de configuration.

```bash
# Afficher la configuration sshd en ignorant les commentaires
grep -v "^#" /etc/ssh/sshd_config
```

#### `-r` — recherche récursive

Parcourt un répertoire et tous ses sous-répertoires.

```bash
# Chercher "TODO" dans tous les fichiers du répertoire courant et ses sous-répertoires
grep -r "TODO" .
```

Pour limiter aux fichiers d'un certain type, combinez avec `--include` :

```bash
grep -r --include="*.conf" "timeout" /etc/
```

---

### Combiner les options

Les options se combinent naturellement. Quelques associations courantes :

```bash
# Numéros de lignes, insensible à la casse, récursif dans /etc
grep -rni "password" /etc/

# Afficher les lignes qui ne sont ni vides ni des commentaires
grep -v "^$" fichier.conf | grep -v "^#"
```

---

### Exemple fil rouge : analyser un journal d'application

Supposons le fichier `app.log` suivant :

```
2024-01-15 08:30:00 INFO  Application démarrée
2024-01-15 08:31:00 ERROR Échec de connexion utilisateur
2024-01-15 08:32:00 INFO  Utilisateur connecté avec succès
2024-01-15 08:33:30 ERROR Timeout sur le service externe
2024-01-15 08:35:00 WARN  Espace disque faible : 85 % utilisé
```

Quelques requêtes utiles :

```bash
# Toutes les erreurs
grep "ERROR" app.log

# Nombre d'erreurs (avec -c, grep compte les lignes correspondantes)
grep -c "ERROR" app.log

# Erreurs avec leur numéro de ligne
grep -n "ERROR" app.log

# Tout sauf les lignes INFO
grep -v "INFO" app.log
```

---

## Comparer deux fichiers : la commande `diff`

### Principe

`diff` compare deux fichiers ligne par ligne et affiche uniquement ce qui diffère.
Si les fichiers sont identiques, il ne produit aucune sortie.

```
diff fichier1 fichier2
```

C'est l'outil de référence pour repérer ce qui a changé entre deux versions d'un
fichier de configuration, d'un script ou de tout fichier texte.

---

### Lire la sortie de `diff`

Créons deux fichiers proches pour illustrer :

```bash
# Créer les fichiers
printf "ligne1\nligne2\nligne3\n" > ancien.txt
printf "ligne1\nligne2 modifiée\nligne4\n" > nouveau.txt

diff ancien.txt nouveau.txt
```

Sortie obtenue :

```
2c2
< ligne2
---
> ligne2 modifiée
3c3
< ligne3
---
> ligne4
```

Décryptage :

| Symbole | Signification |
|---------|---------------|
| `<`     | Ligne du **premier** fichier (ancien.txt) |
| `>`     | Ligne du **second** fichier (nouveau.txt) |
| `---`   | Séparateur entre les deux versions |
| `2c2`   | La ligne 2 a été **c**hangée (changed) |
| `3d3`   | La ligne 3 a été **d**éléte (deleted) |
| `3a4`   | Une ligne a été **a**joutée après la ligne 3 |

Règle de lecture : `<` appartient au fichier de gauche, `>` au fichier de droite.

---

### Cas pratique : comparer deux versions d'une configuration

Avant de modifier un fichier de configuration important, prenez-en une copie :

```bash
cp /etc/hosts /etc/hosts.bak
# Modifier /etc/hosts ...
diff /etc/hosts.bak /etc/hosts
```

`diff` vous indique précisément ce qui a changé, ce qui est utile pour documenter
une modification ou revenir en arrière si quelque chose ne fonctionne pas.

---

## L'essentiel

| Commande | Usage type |
|----------|------------|
| `grep motif fichier` | Afficher les lignes contenant un motif |
| `grep -i motif fichier` | Recherche insensible à la casse |
| `grep -n motif fichier` | Afficher les numéros de lignes |
| `grep -v motif fichier` | Afficher les lignes qui ne correspondent PAS |
| `grep -r motif repertoire/` | Recherche récursive dans tous les fichiers |
| `grep -c motif fichier` | Compter les lignes correspondantes |
| `diff fichier1 fichier2` | Afficher les différences entre deux fichiers |
| `diff -u fichier1 fichier2` | Format unifié, plus lisible (voir ci-dessous) |
| `cmp fichier1 fichier2` | Comparaison octet par octet (fichiers binaires) |

---

## Pour aller plus loin

### Expressions régulières de base avec `grep`

Un motif `grep` peut être plus qu'un mot littéral. Les expressions régulières permettent
de décrire des familles de textes.

| Symbole | Signification | Exemple |
|---------|---------------|---------|
| `^`     | Début de ligne | `grep "^root" /etc/passwd` — lignes commençant par « root » |
| `$`     | Fin de ligne   | `grep "bash$" /etc/passwd` — lignes finissant par « bash » |
| `.`     | N'importe quel caractère unique | `grep "r..t" /etc/passwd` — « root », « ropt »... |
| `[abc]` | Un caractère parmi la liste | `grep "[aeiou]" fichier` — lignes contenant une voyelle |
| `[^abc]`| Tout caractère sauf ceux de la liste | `grep "[^0-9]" fichier` — lignes avec un caractère non numérique |

Ces expressions fonctionnent directement avec `grep` sans option supplémentaire.

Exemples concrets dans `/etc/passwd` :

```bash
# Utilisateurs dont le nom commence par la lettre 's'
grep "^s" /etc/passwd

# Utilisateurs qui utilisent bash comme shell
grep "bash$" /etc/passwd

# Lignes contenant au moins un chiffre
grep "[0-9]" /etc/passwd
```

### `grep -E` — expressions régulières étendues

L'option `-E` (ou son équivalent `egrep`) active des métacaractères supplémentaires,
notamment l'alternance et les quantificateurs.

```bash
# Chercher "error" OU "warning" (alternance avec |)
grep -E "error|warning" app.log

# Mot de 3 à 5 lettres minuscules (quantificateur {n,m})
grep -E "^[a-z]{3,5}$" fichier.txt
```

Pour les recherches du quotidien, `grep` sans `-E` suffit. Réservez `-E` quand vous
avez besoin de l'alternance ou des quantificateurs.

### `diff -u` — format unifié

Le format par défaut de `diff` est concis mais pas toujours intuitif. Le format unifié
(`-u`) est plus lisible et correspond au format des « patches » utilisés dans Git et
dans l'échange de correctifs entre développeurs.

```bash
diff -u ancien.txt nouveau.txt
```

Sortie :

```
--- ancien.txt  2024-01-15 10:00:00
+++ nouveau.txt 2024-01-15 10:05:00
@@ -1,3 +1,3 @@
 ligne1
-ligne2
+ligne2 modifiée
-ligne3
+ligne4
```

- Les lignes préfixées par `-` sont dans l'ancien fichier seulement ;
- les lignes préfixées par `+` sont dans le nouveau fichier seulement ;
- les lignes sans préfixe sont communes aux deux (contexte).

### `cmp` — comparaison de fichiers binaires

`diff` travaille avec du texte. Pour comparer des fichiers binaires (images, archives,
exécutables), utilisez `cmp` qui opère octet par octet et s'arrête à la première
différence.

```bash
cmp image_originale.png image_modifiee.png
# Sortie : image_originale.png image_modifiee.png differ: byte 1024, line 5
```

En mode silencieux (`-s`), `cmp` ne produit aucune sortie mais le code de retour
indique si les fichiers sont identiques (0) ou différents (1) — pratique dans un script.

```bash
if cmp -s fichier1 fichier2; then
    echo "Fichiers identiques"
else
    echo "Fichiers différents"
fi
```

---

## Exercices

### Exercice 1 — Premières recherches dans `/etc/passwd`

`/etc/passwd` est lisible par tous les utilisateurs et contient des informations
sur les comptes du système (un compte par ligne, champs séparés par `:`).

1. Affichez toutes les lignes contenant le mot « root ».
2. Affichez ces mêmes lignes avec leur numéro.
3. Affichez les lignes qui **ne contiennent pas** « nologin » ni « false ».
   (Indication : enchaînez deux `grep -v` avec un pipe `|`.)
4. Comptez le nombre de lignes se terminant par « /bin/bash ».

---

### Exercice 2 — Recherche récursive dans `/etc`

1. Cherchez récursivement le mot « timeout » dans `/etc/` (vous pouvez obtenir
   des messages « Permission non accordée » pour certains fichiers — c'est normal).
2. Répétez la recherche en ajoutant les numéros de lignes.
3. Cherchez « PermitRootLogin » dans `/etc/ssh/` pour savoir si la connexion
   root est autorisée sur ce système.

---

### Exercice 3 — Comparer deux versions d'une configuration

1. Copiez `/etc/hosts` dans votre répertoire personnel :

   ```bash
   cp /etc/hosts ~/hosts.original
   ```

2. Créez une version modifiée en ajoutant deux lignes à la fin :

   ```bash
   cp ~/hosts.original ~/hosts.modifie
   printf "192.168.1.10   serveur-web\n192.168.1.20   serveur-bdd\n" >> ~/hosts.modifie
   ```

3. Comparez les deux fichiers avec `diff`.
4. Comparez-les à nouveau avec `diff -u` et observez la différence de présentation.

---

### Exercice 4 — Recherche avec expressions régulières

Dans `/etc/passwd` :

1. Affichez les lignes qui **commencent** par la lettre « s ».
2. Affichez les lignes qui **se terminent** par « /bin/bash ».
3. Affichez les lignes dont le premier champ (le nom d'utilisateur) ne contient
   que des lettres minuscules et des chiffres — motif `^[a-z0-9]*:`.

---

### Exercice 5 — Filtrer un journal

Créez d'abord le fichier de test :

```bash
cat > ~/app.log << 'EOF'
2024-01-15 08:30:00 INFO  Démarrage de l'application
2024-01-15 08:31:00 ERROR Échec de connexion à la base de données
2024-01-15 08:32:00 INFO  Nouvelle tentative de connexion
2024-01-15 08:33:00 INFO  Connexion rétablie
2024-01-15 08:34:00 WARN  Espace disque faible : 88 % utilisé
2024-01-15 08:35:00 ERROR Délai d'attente dépassé sur le service distant
2024-01-15 08:36:00 INFO  Arrêt planifié dans 5 minutes
EOF
```

1. Affichez uniquement les lignes de niveau « ERROR ».
2. Comptez le nombre total de lignes « INFO ».
3. Affichez les lignes qui ne sont ni « INFO » ni « DEBUG »
   (enchaînez deux `grep -v`).
4. Cherchez les lignes contenant « connexion » sans tenir compte de la casse.

---

### Solutions

#### Exercice 1

```bash
# 1. Lignes contenant "root"
grep "root" /etc/passwd

# 2. Avec numéros de lignes
grep -n "root" /etc/passwd

# 3. Lignes sans "nologin" ni "false"
grep -v "nologin" /etc/passwd | grep -v "false"

# 4. Compter les lignes se terminant par /bin/bash
grep -c "/bin/bash$" /etc/passwd
```

#### Exercice 2

```bash
# 1. Recherche récursive de "timeout" dans /etc
grep -r "timeout" /etc/ 2>/dev/null

# 2. Avec numéros de lignes
grep -rn "timeout" /etc/ 2>/dev/null

# 3. Connexion root SSH
grep "PermitRootLogin" /etc/ssh/sshd_config
```

> Le `2>/dev/null` redirige les messages d'erreur vers « la poubelle » afin de ne pas
> mélanger les erreurs de permission avec les résultats. La redirection est abordée
> au chapitre 8.1.

#### Exercice 3

```bash
# 1. Copie du fichier hosts
cp /etc/hosts ~/hosts.original

# 2. Version modifiée
cp ~/hosts.original ~/hosts.modifie
printf "192.168.1.10   serveur-web\n192.168.1.20   serveur-bdd\n" >> ~/hosts.modifie

# 3. Comparaison standard
diff ~/hosts.original ~/hosts.modifie

# 4. Format unifié
diff -u ~/hosts.original ~/hosts.modifie
```

La sortie de la question 3 montre les lignes ajoutées préfixées par `>`.
Celle de la question 4 les préfixe par `+`, avec quelques lignes de contexte
autour — format adopté par Git.

#### Exercice 4

```bash
# 1. Lignes commençant par 's'
grep "^s" /etc/passwd

# 2. Lignes se terminant par /bin/bash
grep "/bin/bash$" /etc/passwd

# 3. Noms d'utilisateurs alphanumériques minuscules
grep "^[a-z0-9]*:" /etc/passwd
```

#### Exercice 5

```bash
# 1. Lignes ERROR
grep "ERROR" ~/app.log

# 2. Compter les lignes INFO
grep -c "INFO" ~/app.log

# 3. Lignes autres qu'INFO et DEBUG
grep -v "INFO" ~/app.log | grep -v "DEBUG"

# 4. Recherche insensible à la casse pour "connexion"
grep -i "connexion" ~/app.log
```
