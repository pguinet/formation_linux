# Module 8.1 : Redirections et pipes

## Objectifs d'apprentissage
- Maitriser les redirections d'entree/sortie (>, >>, <, <<)
- Utiliser les pipes pour chainer les commandes
- Combiner redirections et pipes efficacement
- Gerer les flux d'erreur et de sortie separement
- Creer des pipelines de traitement de donnees

## Introduction

Les **redirections** et les **pipes** sont des mecanismes fondamentaux de Linux qui permettent de controler les flux de donnees entre commandes, fichiers et processus. Ils forment la base de l'automatisation et du traitement de donnees en ligne de commande.

---

## 1. Concepts des flux de donnees

### Les trois flux standards

#### Descripteurs de fichiers
```bash
0 - stdin  (entree standard)     # Clavier par defaut
1 - stdout (sortie standard)     # Ecran par defaut
2 - stderr (sortie d'erreur)     # Ecran par defaut

# Visualisation
commande < stdin > stdout 2> stderr
```

#### Comportement par defaut
```bash
# Sans redirection, tout s'affiche a l'ecran
ls /home /nonexistent
# Affiche :
# /home:           <- stdout
# total 4
# drwxr-xr-x alice
# ls: cannot access '/nonexistent': No such file or directory  <- stderr
```

### Flux de donnees entre processus
```
Processus A -> [stdout] -> [stdin] -> Processus B -> [stdout] -> Terminal
                v
            [Fichier ou pipe]
```

---

## 2. Redirections de sortie

### Redirection simple (>)

#### Redirection stdout
```bash
# Rediriger vers un fichier (ecrase le contenu)
ls /home > liste_home.txt
cat liste_home.txt

# Rediriger une commande longue
ps aux > processus.txt
wc -l processus.txt

# Creer un fichier vide
> fichier_vide.txt
# ou
touch fichier_vide.txt
```

#### Redirection avec ecrasement
```bash
# Premier contenu
echo "Premiere ligne" > test.txt
cat test.txt

# Ecrasement (contenu precedent perdu)
echo "Nouvelle ligne" > test.txt
cat test.txt    # Seule la nouvelle ligne reste
```

### Redirection en ajout (>>)

#### Ajouter au lieu d'ecraser
```bash
# Creer un fichier initial
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
# Plusieurs commandes vers le meme fichier
{
    echo "=== Rapport systeme ==="
    date
    echo "Utilisateurs connectes:"
    who
    echo "Processus actifs:"
    ps aux | wc -l
} > rapport.txt

cat rapport.txt
```

### Redirection des erreurs (2>)

#### Rediriger stderr separement
```bash
# Commande qui produit erreur et succes
ls /home /nonexistent > sorties.txt 2> erreurs.txt

# Verifier les fichiers
echo "=== Sorties normales ==="
cat sorties.txt
echo "=== Erreurs ==="
cat erreurs.txt
```

#### Combiner stdout et stderr
```bash
# Rediriger tout vers le meme fichier
ls /home /nonexistent > tout.txt 2>&1
cat tout.txt

# Syntaxe alternative (bash recent)
ls /home /nonexistent &> tout.txt
cat tout.txt

# Ajouter tout a un fichier existant
ls /other /paths >> tout.txt 2>&1
```

#### Supprimer les sorties
```bash
# Envoyer vers /dev/null (poubelle systeme)
ls /home > /dev/null    # Supprime stdout
ls /nonexistent 2> /dev/null    # Supprime stderr
ls /home /nonexistent > /dev/null 2>&1    # Supprime tout

# Commandes silencieuses
ping -c 1 google.com > /dev/null 2>&1 && echo "Internet OK" || echo "Internet KO"
```

---

## 3. Redirections d'entree

### Redirection simple (<)

#### Lire depuis un fichier
```bash
# Creer un fichier de donnees
cat > donnees.txt << EOF
ligne1
ligne2  
ligne3
EOF

# Utiliser le fichier comme entree
sort < donnees.txt
wc -l < donnees.txt

# Equivalent a :
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
Variables sont expansees : $USER
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
# Creation de script
cat << 'EOF' > mon_script.sh
#!/bin/bash
echo "Script cree automatiquement"
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
# Utiliser <<- pour supprimer les tabs en debut de ligne
cat <<- EOF
	Cette ligne a une tab au debut
	Cette ligne aussi
	Mais les tabs seront supprimees
EOF

# Utile dans les scripts indentes
if [ "$USER" = "alice" ]; then
    cat <<- EOF
	Bonjour Alice !
	Votre repertoire personnel est $HOME
	EOF
fi
```

### Here String (<<<)

#### Syntaxe simple
```bash
# Here string pour passer une chaine directement
grep "pattern" <<< "texte a chercher dans cette chaine"

# Avec variables
nom="Alice"
grep "Alice" <<< "Bonjour $nom, comment allez-vous ?"

# Exemples pratiques
wc -w <<< "Combien de mots dans cette phrase"
sort <<< $'ligne3\nligne1\nligne2'
```

---

## 4. Pipes (|) - Chainage de commandes

### Concept de pipe

#### Fonctionnement de base
```bash
# Sortie de la premiere commande -> Entree de la seconde
commande1 | commande2

# Exemple simple
ls -la | grep "^d"    # Lister seulement les repertoires
ps aux | grep nginx   # Processus contenant "nginx"
```

#### Pipelines multiples
```bash
# Chainer plusieurs commandes
ps aux | grep -v grep | grep nginx | wc -l

# Pipeline de traitement de donnees
cat /var/log/syslog | grep "error" | sort | uniq -c | sort -nr
```

### Pipes avec utilitaires de texte

#### grep - Filtrage de lignes
```bash
# Filtrer les lignes contenant un pattern
ps aux | grep python
ls -la | grep "^-.*x"    # Fichiers executables

# Grep avec options dans un pipe
dmesg | grep -i error
cat /etc/passwd | grep -E "bash|zsh"

# Grep inverse (exclure)
ps aux | grep -v grep    # Exclure la commande grep elle-meme
```

#### sort - Tri de donnees
```bash
# Trier les resultats
cat /etc/passwd | cut -d: -f1 | sort    # Noms d'utilisateurs tries
du -h /var/log/* | sort -hr              # Fichiers par taille decroissante

# Tri numerique
ps aux | sort -k3 -nr | head -10    # Top 10 CPU
ls -la | sort -k5 -n                # Par taille croissante
```

#### uniq - Dedoublonnage
```bash
# Supprimer doublons (necessite tri prealable)
cat fichier.txt | sort | uniq

# Compter les occurrences
cut -d: -f7 /etc/passwd | sort | uniq -c    # Shells utilises

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

#### sed - Edition de flux
```bash
# Substitutions dans un pipe
ps aux | sed 's/python/PYTHON/g'
cat /etc/passwd | sed 's/:/\t/g'    # Remplacer : par tab

# Supprimer des lignes
ps aux | sed '/grep/d'    # Supprimer lignes contenant "grep"
cat fichier.txt | sed '1d'    # Supprimer premiere ligne
```

### Pipes avances

#### tee - Dupliquer le flux
```bash
# Envoyer vers fichier ET vers la commande suivante
ps aux | tee processus_backup.txt | grep python

# Ajouter a un fichier existant
ls -la | tee -a listing.txt | wc -l

# Multiples destinations
echo "Message important" | tee fichier1.txt fichier2.txt fichier3.txt
```

#### xargs - Passer arguments a une commande
```bash
# Convertir stdin en arguments
find . -name "*.txt" | xargs ls -la
echo "file1.txt file2.txt" | xargs rm

# Avec options
find . -name "*.log" | xargs -I {} cp {} backup/
ps aux | grep python | awk '{print $2}' | xargs kill

# Execution parallele
find . -name "*.jpg" | xargs -P 4 -I {} convert {} {}.webp
```

---

## 5. Combinaisons avancees

### Pipelines complexes de traitement

#### Analyse de logs
```bash
# Analyser les acces web les plus frequents
cat /var/log/nginx/access.log | \
    awk '{print $1}' | \
    sort | \
    uniq -c | \
    sort -nr | \
    head -10

# Top des erreurs systeme
journalctl --since "24 hours ago" -p err --no-pager | \
    grep -o '[A-Za-z][A-Za-z]*:.*' | \
    sort | \
    uniq -c | \
    sort -nr
```

#### Traitement de donnees CSV
```bash
# Creer des donnees de test CSV
cat > data.csv << EOF
nom,age,ville
Alice,25,Paris
Bob,30,Lyon  
Charlie,35,Paris
Diana,28,Lyon
EOF

# Analyser les donnees
echo "=== Repartition par ville ==="
cat data.csv | tail -n +2 | cut -d, -f3 | sort | uniq -c

echo "=== Age moyen ==="
cat data.csv | tail -n +2 | cut -d, -f2 | \
    awk '{sum += $1; count++} END {print "Moyenne:", sum/count}'
```

#### Surveillance systeme en temps reel
```bash
# Processus consommant le plus de CPU en temps reel
while true; do
    ps aux | sort -k3 -nr | head -5 | \
    awk '{printf "%-10s %5s%% %s\n", $1, $3, $11}'
    echo "---"
    sleep 5
done
```

### Redirections et pipes combines

#### Patterns courants
```bash
# Logs avec horodatage
commande 2>&1 | while read line; do
    echo "$(date): $line"
done | tee -a fichier.log

# Sauvegarde ET traitement
tar czf backup.tar.gz /home/user | tee backup.log | \
    awk '{print "Progress:", $0}'

# Traitement parallele
cat gros_fichier.txt | \
    tee >(grep "ERROR" > erreurs.txt) | \
    tee >(grep "WARNING" > warnings.txt) | \
    grep "INFO" > info.txt
```

#### Named pipes (FIFO)
```bash
# Creer un named pipe
mkfifo mon_pipe

# Terminal 1 : ecrire dans le pipe
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

# Backup avec gestion complete des flux
{
    log "Debut backup de $SOURCE_DIR"
    
    if tar czf "$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz" "$SOURCE_DIR" 2>"$ERROR_FILE"; then
        log "Backup reussi"
        
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

#### Script d'analyse systeme
```bash
#!/bin/bash
# system_analysis.sh

REPORT_FILE="system_report_$(date +%Y%m%d).txt"

# Generation du rapport avec redirections
{
    echo "=== RAPPORT SYSTEME $(date) ==="
    echo
    
    echo "CHARGE SYSTEME:"
    uptime
    echo
    
    echo "UTILISATION MEMOIRE:"
    free -h
    echo
    
    echo "TOP 10 PROCESSUS CPU:"
    ps aux | sort -k3 -nr | head -10
    echo
    
    echo "TOP 10 PROCESSUS MEMOIRE:"
    ps aux | sort -k4 -nr | head -10
    echo
    
    echo "ESPACE DISQUE:"
    df -h
    echo
    
    echo "DERNIERES CONNEXIONS:"
    last | head -10
    
} > "$REPORT_FILE" 2>&1

echo "Rapport genere: $REPORT_FILE"

# Envoyer par mail si configure
if command -v mail >/dev/null; then
    cat "$REPORT_FILE" | mail -s "Rapport systeme $(hostname)" admin@domain.com
    echo "Rapport envoye par mail"
fi
```

#### Pipeline de traitement de donnees
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
    # Nettoyer les lignes (supprimer espaces debut/fin)
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
    # Derniere transformation
    sort | uniq -c | sort -nr > "$OUTPUT_DIR/frequency.txt"

echo "Traitement termine. Resultats dans $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
```

---

## 7. Debogage et bonnes pratiques

### Techniques de debogage

#### Tracer les pipelines
```bash
# Utiliser set -x pour tracer l'execution
set -x
ps aux | grep python | awk '{print $2}' | xargs echo
set +x

# Tester chaque etape du pipeline
ps aux > /tmp/step1.txt
grep python /tmp/step1.txt > /tmp/step2.txt
awk '{print $2}' /tmp/step2.txt > /tmp/step3.txt
cat /tmp/step3.txt
```

#### Gestion d'erreurs dans pipelines
```bash
# Par defaut, le pipeline reussit si la derniere commande reussit
false | echo "Cette commande reussit"
echo $?    # 0 (succes)

# Activer pipefail pour plus de rigueur
set -o pipefail
false | echo "Cette commande reussit maintenant"
echo $?    # 1 (echec)

# Dans un script
#!/bin/bash
set -euo pipefail    # Strict mode

# Pipeline qui echouera si une etape echoue
cat fichier_inexistant.txt | sort | uniq
```

### Bonnes pratiques

#### Performance des pipelines
```bash
# [OK] Bon : filtrer tot pour reduire les donnees
grep "pattern" gros_fichier.txt | sort | uniq

# [NOK] Mauvais : trier d'abord
sort gros_fichier.txt | grep "pattern" | uniq

# [OK] Bon : utiliser des buffers appropries
cat gros_fichier.txt | buffer -s 1m | traitement_lent.sh

# [OK] Bon : paralleliser quand possible
find . -name "*.txt" | xargs -P 4 -I {} traitement.sh {}
```

#### Lisibilite des pipelines
```bash
# [OK] Bon : decouper sur plusieurs lignes
cat /var/log/access.log | \
    grep "404" | \
    awk '{print $1}' | \
    sort | \
    uniq -c | \
    sort -nr | \
    head -10

# [OK] Bon : commenter les etapes complexes
cat data.txt | \
    sed 's/old/new/g' |         # Remplacer old par new
    awk '{print $1, $3}' |      # Garder colonnes 1 et 3
    sort -k2 -n                 # Trier par colonne 2 numeriquement
```

#### Securite
```bash
# [OK] Bon : valider les entrees
if [ -r "$input_file" ]; then
    cat "$input_file" | traitement.sh
else
    echo "Fichier non lisible: $input_file" >&2
    exit 1
fi

# [OK] Bon : echapper les variables dans les pipes
grep "$pattern" file.txt    # $pattern peut contenir des metacaracteres
grep -F "$pattern" file.txt  # Recherche litterale plus sure
```

---

## Resume

### Redirections essentielles
```bash
# Sortie
command > file              # Rediriger stdout (ecrase)
command >> file             # Rediriger stdout (ajoute)
command 2> file             # Rediriger stderr
command > file 2>&1         # Rediriger tout
command &> file             # Rediriger tout (bash)

# Entree
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
uniq                      # Dedoublonner
awk '{print $1}'          # Traiter colonnes
sed 's/old/new/'          # Editer flux
wc -l                     # Compter
head -n 10                # Premiers elements
tail -n 10                # Derniers elements
```

### Patterns utiles
```bash
# Top N des plus gros consommateurs
command | sort -nr | head -n

# Frequence des occurrences  
command | sort | uniq -c | sort -nr

# Traitement avec sauvegarde
command | tee backup.txt | next_command

# Filtrage multi-criteres
command | grep pattern1 | grep pattern2

# Statistiques rapides
command | awk '{sum+=$1} END {print sum/NR}'
```

### Bonnes pratiques
- **Pipelines courts** : privilegier la lisibilite
- **Filtrage precoce** : reduire les donnees tot dans le pipeline
- **Gestion d'erreurs** : utiliser `set -o pipefail`
- **Validation** : verifier les entrees et sorties
- **Documentation** : commenter les pipelines complexes
- **Test par etapes** : valider chaque composant separement

---

**Temps de lecture estime** : 25-30 minutes
**Niveau** : Intermediaire
**Pre-requis** : Commandes de base Linux, navigation fichiers, utilitaires texte