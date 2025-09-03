# Recherche dans les fichiers

## La commande `grep` - L'outil de recherche de texte

### Principe de grep
`grep` (Global Regular Expression Print) recherche des motifs (patterns) dans les fichiers et affiche les lignes correspondantes.

### Syntaxe de base
```bash
grep [options] motif [fichier...]
```

### Utilisation simple
```bash
# Rechercher un mot dans un fichier
grep "error" /var/log/syslog

# Rechercher dans plusieurs fichiers
grep "root" /etc/passwd /etc/group

# Rechercher dans tous les fichiers du répertoire courant
grep "TODO" *.txt
```

### Options essentielles de grep

#### Options de base
```bash
# Ignorer la casse (insensible)
grep -i "error" /var/log/syslog

# Afficher les numéros de ligne
grep -n "root" /etc/passwd

# Inverser la recherche (lignes qui ne contiennent PAS le motif)
grep -v "comment" config.txt

# Recherche récursive dans les sous-répertoires
grep -r "function" /usr/local/src/
```

#### Options de comptage et contexte
```bash
# Compter les occurrences
grep -c "error" /var/log/syslog

# Afficher seulement les noms de fichiers contenant le motif
grep -l "#!/bin/bash" *.sh

# Afficher le contexte (lignes avant et après)
grep -C 3 "error" /var/log/syslog  # 3 lignes avant et après
grep -B 2 "error" /var/log/syslog  # 2 lignes avant
grep -A 2 "error" /var/log/syslog  # 2 lignes après
```

### Expressions régulières avec grep

#### Motifs de base
```bash
# Début de ligne
grep "^root" /etc/passwd

# Fin de ligne
grep "bash$" /etc/passwd

# Mot entier
grep -w "root" /etc/passwd

# N'importe quel caractère
grep "r..t" /etc/passwd  # r + 2 caractères + t
```

#### Classes de caractères
```bash
# Chiffres
grep "[0-9]" fichier.txt

# Lettres minuscules
grep "[a-z]" fichier.txt

# Plusieurs caractères possibles
grep "[aeiou]" fichier.txt

# Négation
grep "[^0-9]" fichier.txt  # Tout sauf chiffres
```

#### Quantificateurs
```bash
# Un ou plusieurs (avec grep -E ou egrep)
grep -E "colou?r" fichier.txt    # "color" ou "colour"
grep -E "ba+" fichier.txt        # "ba", "baa", "baaa"...
grep -E "ba*" fichier.txt        # "b", "ba", "baa"...

# Alternatives
grep -E "(cat|dog)" fichier.txt  # "cat" ou "dog"
```

## Variantes de grep

### `egrep` - Extended grep
```bash
# Équivalent à grep -E (expressions étendues)
egrep "colou?r" fichier.txt
egrep "(error|warning|fatal)" /var/log/syslog

# Motifs complexes plus faciles
egrep "\b[A-Z]{2,3}\b" fichier.txt  # Mots en majuscules de 2-3 lettres
```

### `fgrep` - Fixed strings grep
```bash
# Équivalent à grep -F (chaînes littérales, pas de regex)
fgrep "." fichier.txt  # Cherche littéralement le point, pas "n'importe quel caractère"
fgrep "$HOME" fichier.txt  # Cherche littéralement "$HOME"
```

### `rgrep` - Recursive grep
```bash
# Équivalent à grep -r
rgrep "function" /usr/src/
```

## Recherches pratiques avec grep

### Recherche dans les logs système
```bash
# Erreurs dans les logs
grep -i "error" /var/log/syslog

# Dernières connexions SSH
grep "sshd" /var/log/auth.log | tail -10

# Activité d'un utilisateur spécifique
grep "john" /var/log/auth.log

# Combiner avec date
grep "$(date +%b' '%d)" /var/log/syslog | grep "error"
```

### Recherche dans le code source
```bash
# Trouver toutes les fonctions dans du code Python
grep -n "def " *.py

# Chercher les imports
grep -E "^(import|from)" *.py

# Trouver les TODOs et FIXME
grep -rn "TODO\|FIXME" ./src/

# Chercher une variable spécifique
grep -r "\$config" ./scripts/
```

### Recherche dans la configuration système
```bash
# Utilisateurs avec shell bash
grep "/bin/bash$" /etc/passwd

# Services activés
grep -v "^#" /etc/services | head -20

# Configuration non commentée
grep -v "^$" /etc/ssh/sshd_config | grep -v "^#"
```

## Combinaisons avec d'autres commandes

### Grep avec pipes
```bash
# Filtrer la sortie de ps
ps aux | grep "apache"

# Chercher dans l'historique
history | grep "ssh"

# Filtrer les processus par utilisateur
ps aux | grep "^root"

# Compter les connexions par IP
grep "Failed password" /var/log/auth.log | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort | uniq -c | sort -nr
```

### Grep avec find
```bash
# Trouver les fichiers contenant un motif
find /etc -name "*.conf" -exec grep -l "database" {} \;

# Chercher dans les fichiers récents
find . -name "*.log" -mtime -1 -exec grep "error" {} \;

# Combiner find et grep efficacement
find /var/log -name "*.log" | xargs grep "failed"
```

## La commande `awk` - Traitement de texte structuré

### Principe d'awk
`awk` traite les fichiers ligne par ligne, divisant chaque ligne en champs.

### Syntaxe de base
```bash
awk 'motif { action }' fichier
```

### Exemples simples d'awk
```bash
# Afficher une colonne spécifique
awk '{print $1}' /var/log/syslog    # Premier champ (généralement la date)

# Afficher plusieurs colonnes
awk '{print $1, $3}' fichier.txt

# Avec des séparateurs personnalisés
awk -F':' '{print $1}' /etc/passwd  # Utiliser ':' comme séparateur

# Compter les lignes
awk 'END {print NR}' fichier.txt
```

### Recherche conditionnelle avec awk
```bash
# Lignes contenant un motif
awk '/error/ {print}' /var/log/syslog

# Conditions sur les champs
awk -F':' '$3 > 1000 {print $1}' /etc/passwd  # Utilisateurs avec UID > 1000

# Combinaisons de conditions
awk '/error/ && $1 ~ /Jan/ {print}' /var/log/syslog
```

## La commande `sed` - Éditeur de flux

### Principe de sed
`sed` (Stream EDitor) permet de modifier des fichiers en flux, sans les ouvrir dans un éditeur.

### Recherche et affichage avec sed
```bash
# Afficher les lignes contenant un motif
sed -n '/error/p' /var/log/syslog

# Afficher une plage de lignes
sed -n '10,20p' fichier.txt

# Afficher jusqu'à un motif
sed -n '1,/error/p' fichier.txt
```

### Recherche et remplacement avec sed
```bash
# Remplacer (sans modifier le fichier)
sed 's/old/new/' fichier.txt

# Remplacer globalement sur chaque ligne
sed 's/old/new/g' fichier.txt

# Modifier le fichier directement
sed -i 's/old/new/g' fichier.txt

# Remplacer seulement sur les lignes contenant un motif
sed '/pattern/s/old/new/g' fichier.txt
```

## Outils spécialisés de recherche

### `zgrep` - Recherche dans fichiers compressés
```bash
# Chercher dans des logs compressés
zgrep "error" /var/log/syslog.1.gz

# Recherche récursive dans archives
zgrep -r "pattern" /var/log/
```

### `strings` - Extraire du texte de fichiers binaires
```bash
# Chercher du texte dans un binaire
strings /bin/ls | grep "usage"

# Combiner avec grep pour filtrer
strings /usr/bin/vim | grep -i "version"
```

### `ripgrep` (rg) - Alternative moderne à grep
```bash
# Si installé, plus rapide que grep
rg "error" /var/log/

# Recherche avec types de fichiers
rg "function" --type py

# Exclusion de répertoires automatique (.git, node_modules)
rg "TODO" ./project/
```

## Recherche avancée et optimisation

### Recherche multi-critères
```bash
# ET logique (plusieurs greps)
grep "error" /var/log/syslog | grep "Jan 15"

# OU logique avec egrep
egrep "(error|warning|fatal)" /var/log/syslog

# NOT (exclusion)
grep "error" /var/log/syslog | grep -v "known issue"
```

### Optimisation des performances
```bash
# Arrêter après la première occurrence
grep -m 1 "pattern" gros_fichier.log

# Recherche binaire plus rapide pour fichiers triés
look "pattern" fichier_trie.txt

# Utiliser des outils spécialisés pour gros volumes
# ripgrep, ag (silver searcher) sont plus rapides que grep
```

### Recherche dans des structures complexes
```bash
# JSON avec jq (si installé)
jq '.[] | select(.status == "error")' data.json

# XML avec xmlstarlet (si installé)
xmlstarlet sel -t -v "//error" data.xml

# CSV avec awk
awk -F',' '$3 == "error" {print}' data.csv
```

## Scripts de recherche personnalisés

### Script de recherche dans logs
```bash
#!/bin/bash
# search_logs.sh - Recherche intelligente dans les logs

PATTERN="$1"
if [ -z "$PATTERN" ]; then
    echo "Usage: $0 <pattern>"
    exit 1
fi

echo "=== Recherche de '$PATTERN' dans les logs ==="

# Logs système
echo "--- Logs système ---"
grep -i "$PATTERN" /var/log/syslog | tail -5

# Logs d'authentification
echo "--- Logs auth ---"
grep -i "$PATTERN" /var/log/auth.log | tail -5

# Logs Apache (si présents)
if [ -f /var/log/apache2/error.log ]; then
    echo "--- Logs Apache ---"
    grep -i "$PATTERN" /var/log/apache2/error.log | tail -5
fi

echo "=== Fin de recherche ==="
```

### Fonction de recherche contextualisée
```bash
search_context() {
    local pattern="$1"
    local file="$2"
    local context="${3:-3}"
    
    echo "Recherche de '$pattern' dans $file:"
    grep -n -C "$context" "$pattern" "$file" | head -20
}

# Usage
search_context "error" /var/log/syslog 5
```

## Recherche et sécurité

### Recherche de mots de passe et secrets
```bash
# ATTENTION : Ces recherches sont pour la sécurité/audit
# Chercher des mots de passe potentiels (audit sécurité)
grep -ri "password\|passwd\|pwd" /home/ --exclude-dir=.git

# Rechercher des clés privées
find /home -name "*.pem" -o -name "id_rsa" -o -name "*.key"

# Chercher des tokens dans le code
grep -r "token\|api_key\|secret" ./src/ --include="*.py" --include="*.js"
```

### Anonymisation lors de la recherche
```bash
# Masquer les informations sensibles dans les résultats
grep "login" /var/log/auth.log | sed 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/XXX.XXX.XXX.XXX/g'
```

## Points clés à retenir

- **`grep`** : outil principal de recherche de texte
- **Options importantes** : `-i` (insensible casse), `-r` (récursif), `-n` (numéros)
- **Expressions régulières** : `^` début, `$` fin, `.` n'importe quoi, `[abc]` classes
- **Variantes** : `egrep` (étendu), `fgrep` (littéral), `zgrep` (compressé)
- **Combinaisons** : pipes avec autres commandes, find + grep
- **Performance** : `-m` limiter résultats, outils modernes (ripgrep)
- **Scripts** : automatiser recherches complexes
- **Sécurité** : attention aux informations sensibles

## Exercices pratiques

### Exercice 1 : Recherches de base
```bash
# Chercher les utilisateurs avec shell bash
grep "/bin/bash$" /etc/passwd

# Compter les lignes d'erreur dans syslog
grep -c "error" /var/log/syslog

# Recherche insensible à la casse
grep -i "WARNING" /var/log/syslog
```

### Exercice 2 : Recherche avancée
```bash
# Créer un fichier test
echo -e "line1 error\nline2 ERROR\nline3 warning\nline4 info" > test.txt

# Rechercher avec contexte
grep -A 1 -B 1 "error" test.txt

# Recherche avec expressions régulières
grep -E "(error|warning)" test.txt
```

### Exercice 3 : Combinaisons pratiques
```bash
# Processus avec "ssh" dans le nom
ps aux | grep ssh

# Lignes uniques contenant "error"
grep "error" /var/log/syslog | sort | uniq
```