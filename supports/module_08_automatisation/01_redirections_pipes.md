# Module 8.1 : Redirections et pipes

## Objectifs d'apprentissage
- Maîtriser les redirections d'entrée/sortie (>, >>, <, <<)
- Utiliser les pipes pour chaîner les commandes
- Combiner redirections et pipes efficacement
- Gérer les flux d'erreur et de sortie séparément
- Créer des pipelines de traitement de données

## Introduction

Les **redirections** et les **pipes** sont des mécanismes fondamentaux de Linux qui permettent de contrôler les flux de données entre commandes, fichiers et processus. Ils forment la base de l'automatisation et du traitement de données en ligne de commande.

---

## 1. Concepts des flux de données

### Les trois flux standards

#### Descripteurs de fichiers
```bash
0 - stdin  (entrée standard)     # Clavier par défaut
1 - stdout (sortie standard)     # Écran par défaut
2 - stderr (sortie d'erreur)     # Écran par défaut

# Visualisation
commande < stdin > stdout 2> stderr
```

#### Comportement par défaut
```bash
# Sans redirection, tout s'affiche à l'écran
ls /home /nonexistent
# Affiche :
# /home:           <- stdout
# total 4
# drwxr-xr-x alice
# ls: cannot access '/nonexistent': No such file or directory  <- stderr
```

### Flux de données entre processus
```
Processus A → [stdout] → [stdin] → Processus B → [stdout] → Terminal
                ↓
            [Fichier ou pipe]
```

---

## 2. Redirections de sortie

### Redirection simple (>)

#### Redirection stdout
```bash
# Rediriger vers un fichier (écrase le contenu)
ls /home > liste_home.txt
cat liste_home.txt

# Rediriger une commande longue
ps aux > processus.txt
wc -l processus.txt

# Créer un fichier vide
> fichier_vide.txt
# ou
touch fichier_vide.txt
```

#### Redirection avec écrasement
```bash
# Premier contenu
echo "Première ligne" > test.txt
cat test.txt

# Écrasement (contenu précédent perdu)
echo "Nouvelle ligne" > test.txt
cat test.txt    # Seule la nouvelle ligne reste
```

### Redirection en ajout (>>)

#### Ajouter au lieu d'écraser
```bash
# Créer un fichier initial
echo "Ligne 1" > fichier.txt

# Ajouter des lignes
echo "Ligne 2" >> fichier.txt
echo "Ligne 3" >> fichier.txt
cat fichier.txt

# Exemple pratique : log de surveillance
date >> surveillance.log
uptime >> surveillance.log
echo "---" >> surveillance.log
cat surveillance.log
```

#### Redirection de commandes multiples
```bash
# Plusieurs commandes vers le même fichier
{
    echo "=== Rapport système ==="
    date
    echo "Utilisateurs connectés:"
    who
    echo "Processus actifs:"
    ps aux | wc -l
} > rapport.txt

cat rapport.txt
```

### Redirection des erreurs (2>)

#### Rediriger stderr séparément
```bash
# Commande qui produit erreur et succès
ls /home /nonexistent > sorties.txt 2> erreurs.txt

# Vérifier les fichiers
echo "=== Sorties normales ==="
cat sorties.txt
echo "=== Erreurs ==="
cat erreurs.txt
```

#### Combiner stdout et stderr
```bash
# Rediriger tout vers le même fichier
ls /home /nonexistent > tout.txt 2>&1
cat tout.txt

# Syntaxe alternative (bash récent)
ls /home /nonexistent &> tout.txt
cat tout.txt

# Ajouter tout à un fichier existant
ls /other /paths >> tout.txt 2>&1
```

#### Supprimer les sorties
```bash
# Envoyer vers /dev/null (poubelle système)
ls /home > /dev/null    # Supprime stdout
ls /nonexistent 2> /dev/null    # Supprime stderr
ls /home /nonexistent > /dev/null 2>&1    # Supprime tout

# Commandes silencieuses
ping -c 1 google.com > /dev/null 2>&1 && echo "Internet OK" || echo "Internet KO"
```

---

## 3. Redirections d'entrée

### Redirection simple (<)

#### Lire depuis un fichier
```bash
# Créer un fichier de données
cat > donnees.txt << EOF
ligne1
ligne2  
ligne3
EOF

# Utiliser le fichier comme entrée
sort < donnees.txt
wc -l < donnees.txt

# Équivalent à :
sort donnees.txt
wc -l donnees.txt
```

### Here Document (<<)

#### Syntaxe et utilisation
```bash
# Here document basique
cat << EOF
Ceci est un here document
Il peut contenir plusieurs lignes
Variables sont expansées : $USER
EOF

# Here document vers fichier
cat << EOF > config.txt
# Fichier de configuration
user=$USER
home=$HOME
date=$(date)
EOF

cat config.txt
```

#### Applications pratiques
```bash
# Création de script
cat << 'EOF' > mon_script.sh
#!/bin/bash
echo "Script créé automatiquement"
echo "Date: $(date)"
echo "Utilisateur: $USER"
EOF

chmod +x mon_script.sh
./mon_script.sh

# Configuration de service
sudo tee /etc/systemd/system/test.service << EOF > /dev/null
[Unit]
Description=Service de test
After=network.target

[Service]
Type=simple
ExecStart=/bin/sleep 3600

[Install]
WantedBy=multi-user.target
EOF
```

#### Here Document avec suppression d'indentation
```bash
# Utiliser <<- pour supprimer les tabs en début de ligne
cat <<- EOF
	Cette ligne a une tab au début
	Cette ligne aussi
	Mais les tabs seront supprimées
EOF

# Utile dans les scripts indentés
if [ "$USER" = "alice" ]; then
    cat <<- EOF
	Bonjour Alice !
	Votre répertoire personnel est $HOME
	EOF
fi
```

### Here String (<<<)

#### Syntaxe simple
```bash
# Here string pour passer une chaîne directement
grep "pattern" <<< "texte à chercher dans cette chaîne"

# Avec variables
nom="Alice"
grep "Alice" <<< "Bonjour $nom, comment allez-vous ?"

# Exemples pratiques
wc -w <<< "Combien de mots dans cette phrase"
sort <<< $'ligne3\nligne1\nligne2'
```

---

## 4. Pipes (|) - Chaînage de commandes

### Concept de pipe

#### Fonctionnement de base
```bash
# Sortie de la première commande → Entrée de la seconde
commande1 | commande2

# Exemple simple
ls -la | grep "^d"    # Lister seulement les répertoires
ps aux | grep nginx   # Processus contenant "nginx"
```

#### Pipelines multiples
```bash
# Chaîner plusieurs commandes
ps aux | grep -v grep | grep nginx | wc -l

# Pipeline de traitement de données
cat /var/log/syslog | grep "error" | sort | uniq -c | sort -nr
```

### Pipes avec utilitaires de texte

#### grep - Filtrage de lignes
```bash
# Filtrer les lignes contenant un pattern
ps aux | grep python
ls -la | grep "^-.*x"    # Fichiers exécutables

# Grep avec options dans un pipe
dmesg | grep -i error
cat /etc/passwd | grep -E "bash|zsh"

# Grep inverse (exclure)
ps aux | grep -v grep    # Exclure la commande grep elle-même
```

#### sort - Tri de données
```bash
# Trier les résultats
cat /etc/passwd | cut -d: -f1 | sort    # Noms d'utilisateurs triés
du -h /var/log/* | sort -hr              # Fichiers par taille décroissante

# Tri numérique
ps aux | sort -k3 -nr | head -10    # Top 10 CPU
ls -la | sort -k5 -n                # Par taille croissante
```

#### uniq - Dédoublonnage
```bash
# Supprimer doublons (nécessite tri préalable)
cat fichier.txt | sort | uniq

# Compter les occurrences
cut -d: -f7 /etc/passwd | sort | uniq -c    # Shells utilisés

# Seulement les doublons
cat fichier.txt | sort | uniq -d
```

#### awk - Traitement de colonnes
```bash
# Extraire des colonnes
ps aux | awk '{print $1, $2, $11}'    # User, PID, Command
ls -la | awk '{print $9, $5}'         # Nom, Taille

# Avec conditions
ps aux | awk '$3 > 5 {print $1, $2, $3}'    # CPU > 5%

# Calculs
ls -la | awk '{sum += $5} END {print "Total:", sum, "bytes"}'
```

#### sed - Édition de flux
```bash
# Substitutions dans un pipe
ps aux | sed 's/python/PYTHON/g'
cat /etc/passwd | sed 's/:/\t/g'    # Remplacer : par tab

# Supprimer des lignes
ps aux | sed '/grep/d'    # Supprimer lignes contenant "grep"
cat fichier.txt | sed '1d'    # Supprimer première ligne
```

### Pipes avancés

#### tee - Dupliquer le flux
```bash
# Envoyer vers fichier ET vers la commande suivante
ps aux | tee processus_backup.txt | grep python

# Ajouter à un fichier existant
ls -la | tee -a listing.txt | wc -l

# Multiples destinations
echo "Message important" | tee fichier1.txt fichier2.txt fichier3.txt
```

#### xargs - Passer arguments à une commande
```bash
# Convertir stdin en arguments
find . -name "*.txt" | xargs ls -la
echo "file1.txt file2.txt" | xargs rm

# Avec options
find . -name "*.log" | xargs -I {} cp {} backup/
ps aux | grep python | awk '{print $2}' | xargs kill

# Exécution parallèle
find . -name "*.jpg" | xargs -P 4 -I {} convert {} {}.webp
```

---

## 5. Combinaisons avancées

### Pipelines complexes de traitement

#### Analyse de logs
```bash
# Analyser les accès web les plus fréquents
cat /var/log/nginx/access.log | \
    awk '{print $1}' | \
    sort | \
    uniq -c | \
    sort -nr | \
    head -10

# Top des erreurs système
journalctl --since "24 hours ago" -p err --no-pager | \
    grep -o '[A-Za-z][A-Za-z]*:.*' | \
    sort | \
    uniq -c | \
    sort -nr
```

#### Traitement de données CSV
```bash
# Créer des données de test CSV
cat > data.csv << EOF
nom,age,ville
Alice,25,Paris
Bob,30,Lyon  
Charlie,35,Paris
Diana,28,Lyon
EOF

# Analyser les données
echo "=== Répartition par ville ==="
cat data.csv | tail -n +2 | cut -d, -f3 | sort | uniq -c

echo "=== Age moyen ==="
cat data.csv | tail -n +2 | cut -d, -f2 | \
    awk '{sum += $1; count++} END {print "Moyenne:", sum/count}'
```

#### Surveillance système en temps réel
```bash
# Processus consommant le plus de CPU en temps réel
while true; do
    ps aux | sort -k3 -nr | head -5 | \
    awk '{printf "%-10s %5s%% %s\n", $1, $3, $11}'
    echo "---"
    sleep 5
done
```

### Redirections et pipes combinés

#### Patterns courants
```bash
# Logs avec horodatage
commande 2>&1 | while read line; do
    echo "$(date): $line"
done | tee -a fichier.log

# Sauvegarde ET traitement
tar czf backup.tar.gz /home/user | tee backup.log | \
    awk '{print "Progress:", $0}'

# Traitement parallèle
cat gros_fichier.txt | \
    tee >(grep "ERROR" > erreurs.txt) | \
    tee >(grep "WARNING" > warnings.txt) | \
    grep "INFO" > info.txt
```

#### Named pipes (FIFO)
```bash
# Créer un named pipe
mkfifo mon_pipe

# Terminal 1 : écrire dans le pipe
echo "Message via FIFO" > mon_pipe &

# Terminal 2 : lire depuis le pipe
cat < mon_pipe

# Nettoyage
rm mon_pipe
```

---

## 6. Cas pratiques et scripts

### Scripts utilisant redirections et pipes

#### Script de backup avec logs
```bash
#!/bin/bash
# backup_with_logs.sh

BACKUP_DIR="/backup"
SOURCE_DIR="/home/user/documents"
LOG_FILE="/var/log/backup.log"
ERROR_FILE="/var/log/backup_errors.log"

# Fonction de log avec timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Backup avec gestion complète des flux
{
    log "Début backup de $SOURCE_DIR"
    
    if tar czf "$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz" "$SOURCE_DIR" 2>"$ERROR_FILE"; then
        log "Backup réussi"
        
        # Statistiques
        backup_size=$(ls -lh "$BACKUP_DIR"/backup_*.tar.gz | tail -1 | awk '{print $5}')
        log "Taille du backup: $backup_size"
        
    else
        log "Erreur pendant le backup"
        cat "$ERROR_FILE" | while read line; do
            log "ERREUR: $line"
        done
    fi
    
    log "Fin backup"
} 2>&1    # Tout vers stdout pour le log
```

#### Script d'analyse système
```bash
#!/bin/bash
# system_analysis.sh

REPORT_FILE="system_report_$(date +%Y%m%d).txt"

# Génération du rapport avec redirections
{
    echo "=== RAPPORT SYSTÈME $(date) ==="
    echo
    
    echo "CHARGE SYSTÈME:"
    uptime
    echo
    
    echo "UTILISATION MÉMOIRE:"
    free -h
    echo
    
    echo "TOP 10 PROCESSUS CPU:"
    ps aux | sort -k3 -nr | head -10
    echo
    
    echo "TOP 10 PROCESSUS MÉMOIRE:"
    ps aux | sort -k4 -nr | head -10
    echo
    
    echo "ESPACE DISQUE:"
    df -h
    echo
    
    echo "DERNIÈRES CONNEXIONS:"
    last | head -10
    
} > "$REPORT_FILE" 2>&1

echo "Rapport généré: $REPORT_FILE"

# Envoyer par mail si configuré
if command -v mail >/dev/null; then
    cat "$REPORT_FILE" | mail -s "Rapport système $(hostname)" admin@domain.com
    echo "Rapport envoyé par mail"
fi
```

#### Pipeline de traitement de données
```bash
#!/bin/bash
# process_data.sh

INPUT_FILE="$1"
OUTPUT_DIR="processed_data"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Usage: $0 <input_file>" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Traitement de $INPUT_FILE..."

# Pipeline complexe de traitement
cat "$INPUT_FILE" | \
    # Nettoyer les lignes (supprimer espaces début/fin)
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
    # Supprimer lignes vides et commentaires
    grep -v '^$\|^#' | \
    # Convertir en minuscules
    tr '[:upper:]' '[:lower:]' | \
    # Remplacer espaces multiples par un seul
    sed 's/[[:space:]]\+/ /g' | \
    # Dupliquer vers plusieurs sorties
    tee \
        >(sort > "$OUTPUT_DIR/sorted.txt") \
        >(sort | uniq > "$OUTPUT_DIR/unique.txt") \
        >(wc -l > "$OUTPUT_DIR/line_count.txt") | \
    # Dernière transformation
    sort | uniq -c | sort -nr > "$OUTPUT_DIR/frequency.txt"

echo "Traitement terminé. Résultats dans $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
```

---

## 7. Débogage et bonnes pratiques

### Techniques de débogage

#### Tracer les pipelines
```bash
# Utiliser set -x pour tracer l'exécution
set -x
ps aux | grep python | awk '{print $2}' | xargs echo
set +x

# Tester chaque étape du pipeline
ps aux > /tmp/step1.txt
grep python /tmp/step1.txt > /tmp/step2.txt
awk '{print $2}' /tmp/step2.txt > /tmp/step3.txt
cat /tmp/step3.txt
```

#### Gestion d'erreurs dans pipelines
```bash
# Par défaut, le pipeline réussit si la dernière commande réussit
false | echo "Cette commande réussit"
echo $?    # 0 (succès)

# Activer pipefail pour plus de rigueur
set -o pipefail
false | echo "Cette commande réussit maintenant"
echo $?    # 1 (échec)

# Dans un script
#!/bin/bash
set -euo pipefail    # Strict mode

# Pipeline qui échouera si une étape échoue
cat fichier_inexistant.txt | sort | uniq
```

### Bonnes pratiques

#### Performance des pipelines
```bash
# ✓ Bon : filtrer tôt pour réduire les données
grep "pattern" gros_fichier.txt | sort | uniq

# ✗ Mauvais : trier d'abord
sort gros_fichier.txt | grep "pattern" | uniq

# ✓ Bon : utiliser des buffers appropriés
cat gros_fichier.txt | buffer -s 1m | traitement_lent.sh

# ✓ Bon : paralléliser quand possible
find . -name "*.txt" | xargs -P 4 -I {} traitement.sh {}
```

#### Lisibilité des pipelines
```bash
# ✓ Bon : découper sur plusieurs lignes
cat /var/log/access.log | \
    grep "404" | \
    awk '{print $1}' | \
    sort | \
    uniq -c | \
    sort -nr | \
    head -10

# ✓ Bon : commenter les étapes complexes
cat data.txt | \
    sed 's/old/new/g' |         # Remplacer old par new
    awk '{print $1, $3}' |      # Garder colonnes 1 et 3
    sort -k2 -n                 # Trier par colonne 2 numériquement
```

#### Sécurité
```bash
# ✓ Bon : valider les entrées
if [ -r "$input_file" ]; then
    cat "$input_file" | traitement.sh
else
    echo "Fichier non lisible: $input_file" >&2
    exit 1
fi

# ✓ Bon : échapper les variables dans les pipes
grep "$pattern" file.txt    # $pattern peut contenir des métacaractères
grep -F "$pattern" file.txt  # Recherche littérale plus sûre
```

---

## Résumé

### Redirections essentielles
```bash
# Sortie
command > file              # Rediriger stdout (écrase)
command >> file             # Rediriger stdout (ajoute)
command 2> file             # Rediriger stderr
command > file 2>&1         # Rediriger tout
command &> file             # Rediriger tout (bash)

# Entrée
command < file              # Lire depuis fichier
command << EOF              # Here document
...
EOF
command <<< "string"        # Here string
```

### Pipes fondamentaux
```bash
cmd1 | cmd2                 # Pipe simple
cmd1 | cmd2 | cmd3          # Pipeline
cmd | tee file              # Dupliquer flux
cmd | xargs other_cmd       # Arguments via pipe
```

### Utilitaires de pipe courants
```bash
grep pattern               # Filtrer lignes
sort                      # Trier
uniq                      # Dédoublonner
awk '{print $1}'          # Traiter colonnes
sed 's/old/new/'          # Éditer flux
wc -l                     # Compter
head -n 10                # Premiers éléments
tail -n 10                # Derniers éléments
```

### Patterns utiles
```bash
# Top N des plus gros consommateurs
command | sort -nr | head -n

# Fréquence des occurrences  
command | sort | uniq -c | sort -nr

# Traitement avec sauvegarde
command | tee backup.txt | next_command

# Filtrage multi-critères
command | grep pattern1 | grep pattern2

# Statistiques rapides
command | awk '{sum+=$1} END {print sum/NR}'
```

### Bonnes pratiques
- **Pipelines courts** : privilégier la lisibilité
- **Filtrage précoce** : réduire les données tôt dans le pipeline
- **Gestion d'erreurs** : utiliser `set -o pipefail`
- **Validation** : vérifier les entrées et sorties
- **Documentation** : commenter les pipelines complexes
- **Test par étapes** : valider chaque composant séparément

---

**Temps de lecture estimé** : 25-30 minutes
**Niveau** : Intermédiaire
**Pré-requis** : Commandes de base Linux, navigation fichiers, utilitaires texte