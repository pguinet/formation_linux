# Évaluation finale - Certification Formation Linux

## Informations générales
- **Durée :** 3 heures
- **Type :** Examen pratique de certification  
- **Points :** 150 points au total
- **Seuil de réussite :** 105/150 points (70%)
- **Prérequis :** Validation de tous les modules précédents

## Contexte professionnel

Vous êtes administrateur système junior dans l'entreprise TechCorp. Votre responsable vous confie la gestion d'un serveur Linux de développement. Vous devez accomplir plusieurs tâches de mise en place et de maintenance.

---

## Partie I : Mise en place de l'environnement (40 points)

### Tâche 1 : Structure projet (15 points)

Créer l'arborescence complète suivante pour un nouveau projet :

```
/home/$USER/techcorp/
├── projets/
│   ├── webapp/
│   │   ├── src/
│   │   │   ├── frontend/
│   │   │   └── backend/
│   │   ├── tests/
│   │   └── docs/
│   └── mobile/
│       ├── android/
│       └── ios/
├── backups/
│   ├── daily/
│   └── weekly/
├── logs/
│   ├── apache/
│   └── application/
└── scripts/
    ├── backup/
    └── monitoring/
```

**Critères d'évaluation :**
- Structure exacte respectée (8 points)
- Commandes optimisées utilisées (4 points)
- Vérification avec `tree` ou `find` (3 points)

### Tâche 2 : Configuration des permissions (15 points)

1. **Créer les utilisateurs fictifs** (simulation via groupes existants) :
   - Groupe `developers` : accès lecture/écriture sur `projets/`
   - Groupe `backups` : accès lecture seule sur `projets/`, écriture sur `backups/`
   - Utilisateur `www-data` : accès lecture sur `projets/webapp/`

2. **Configurer les permissions :**
   - `projets/` : 755 pour propriétaire, 750 pour groupe developers
   - `backups/` : 755 pour propriétaire, 770 pour groupe backups  
   - `logs/` : 755 pour propriétaire, 640 pour fichiers de logs
   - `scripts/` : 750 pour propriétaire, exécution pour groupe developers

**Commandes attendues :**
```bash
chmod 755 projets/
chmod 750 backups/
chmod 755 logs/
chmod 750 scripts/
```

### Tâche 3 : Fichiers de configuration (10 points)

Créer les fichiers suivants avec le contenu approprié :

1. **`scripts/config.conf`** - Configuration générale :
```
# Configuration TechCorp
PROJECT_ROOT=/home/$USER/techcorp
BACKUP_RETENTION=30
LOG_LEVEL=INFO
EMAIL_ADMIN=admin@techcorp.com
```

2. **`.env`** dans webapp - Variables d'environnement :
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=webapp_db
DEBUG=false
```

3. **`README.md`** dans le répertoire principal avec description du projet.

---

## Partie II : Scripts d'automatisation (50 points)

### Tâche 4 : Script de sauvegarde avancé (25 points)

Créer `scripts/backup/backup_system.sh` qui :

1. **Sauvegarde les projets** dans `backups/daily/` avec timestamp
2. **Vérifie l'espace disque** avant sauvegarde (échec si < 1GB libre)
3. **Compresse** avec gzip et vérifie l'intégrité  
4. **Supprime** les sauvegardes de plus de 7 jours
5. **Log** toutes les opérations dans `logs/backup.log`
6. **Envoie une notification** (simulation via echo) en cas d'erreur

**Code de base attendu :**
```bash
#!/bin/bash

# Configuration
SCRIPT_DIR="/home/$USER/techcorp/scripts/backup"
PROJECT_DIR="/home/$USER/techcorp/projets"
BACKUP_DIR="/home/$USER/techcorp/backups/daily"
LOG_FILE="/home/$USER/techcorp/logs/backup.log"
MIN_SPACE_KB=1048576  # 1GB en KB

# Fonction de logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Vérification espace disque
check_disk_space() {
    available=$(df "$BACKUP_DIR" | tail -1 | awk '{print $4}')
    if [ "$available" -lt "$MIN_SPACE_KB" ]; then
        log_message "ERREUR: Espace insuffisant (${available}KB disponible)"
        return 1
    fi
    log_message "INFO: Espace disque OK (${available}KB disponible)"
    return 0
}

# Script principal
log_message "=== DÉBUT SAUVEGARDE ==="

if ! check_disk_space; then
    echo "ALERTE: Sauvegarde échouée - espace insuffisant"
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${TIMESTAMP}.tar.gz"

# Création sauvegarde
tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "/home/$USER/techcorp" "projets" 2>/dev/null

if [ $? -eq 0 ]; then
    log_message "INFO: Sauvegarde créée: $BACKUP_FILE"
    
    # Vérification intégrité
    if tar -tzf "$BACKUP_DIR/$BACKUP_FILE" >/dev/null 2>&1; then
        log_message "INFO: Intégrité vérifiée pour $BACKUP_FILE"
    else
        log_message "ERREUR: Corruption détectée dans $BACKUP_FILE"
    fi
    
    # Nettoyage ancien fichiers (7 jours)
    find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
    log_message "INFO: Nettoyage des anciennes sauvegardes terminé"
else
    log_message "ERREUR: Échec création sauvegarde"
    echo "ALERTE: Sauvegarde échouée"
fi

log_message "=== FIN SAUVEGARDE ==="
```

**Critères :**
- Script fonctionnel et sans erreur (15 points)
- Gestion d'erreurs appropriée (5 points)  
- Logging complet (5 points)

### Tâche 5 : Script de monitoring (25 points)

Créer `scripts/monitoring/system_check.sh` qui génère un rapport système complet :

1. **Informations système** : uptime, charge, utilisateurs connectés
2. **Utilisation ressources** : CPU, mémoire, disques
3. **État des services** : simulation de vérification de services web
4. **Analyse des logs** : compte les erreurs dans les logs récents
5. **Alertes** : détection de seuils critiques
6. **Format de sortie** : HTML et texte

**Fonctionnalités requises :**
```bash
#!/bin/bash

# Variables
REPORT_DIR="/home/$USER/techcorp/logs"
REPORT_FILE="system_report_$(date +%Y%m%d_%H%M%S).html"
TEXT_REPORT="system_report_$(date +%Y%m%d_%H%M%S).txt"

# Génération rapport HTML
generate_html_report() {
    cat > "$REPORT_DIR/$REPORT_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Rapport Système TechCorp</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .alert { color: red; font-weight: bold; }
        .ok { color: green; }
        .warning { color: orange; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Rapport Système - $(date)</h1>
    
    <h2>Informations Système</h2>
    <table>
        <tr><th>Métrique</th><th>Valeur</th></tr>
        <tr><td>Uptime</td><td>$(uptime)</td></tr>
        <tr><td>Utilisateur</td><td>$USER</td></tr>
        <tr><td>Hostname</td><td>$(hostname)</td></tr>
    </table>
    
    <h2>Utilisation Ressources</h2>
    <table>
        <tr><th>Ressource</th><th>Utilisation</th><th>État</th></tr>
EOF

    # Ajout données ressources
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    
    # État disque
    if [ "$DISK_USAGE" -gt 90 ]; then
        DISK_STATUS="<span class='alert'>CRITIQUE</span>"
    elif [ "$DISK_USAGE" -gt 75 ]; then
        DISK_STATUS="<span class='warning'>WARNING</span>"  
    else
        DISK_STATUS="<span class='ok'>OK</span>"
    fi
    
    echo "<tr><td>Disque /</td><td>${DISK_USAGE}%</td><td>$DISK_STATUS</td></tr>" >> "$REPORT_DIR/$REPORT_FILE"
    echo "<tr><td>Mémoire</td><td>${MEM_USAGE}%</td><td><span class='ok'>OK</span></td></tr>" >> "$REPORT_DIR/$REPORT_FILE"
    
    cat >> "$REPORT_DIR/$REPORT_FILE" << EOF
    </table>
    
    <h2>Processus</h2>
    <pre>$(ps aux --sort=-pcpu | head -10)</pre>
    
    </body>
    </html>
EOF
}

# Génération rapport texte
generate_text_report() {
    cat > "$REPORT_DIR/$TEXT_REPORT" << EOF
=== RAPPORT SYSTÈME TECHCORP ===
Date: $(date)
Uptime: $(uptime)
Utilisateur: $USER

=== RESSOURCES ===
$(df -h)

$(free -h)

=== PROCESSUS TOP CPU ===
$(ps aux --sort=-pcpu | head -10)

=== ALERTES ===
EOF

    # Vérification alertes
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$DISK_USAGE" -gt 75 ]; then
        echo "ALERTE: Disque plein à ${DISK_USAGE}%" >> "$REPORT_DIR/$TEXT_REPORT"
    fi
    
    echo "=== FIN RAPPORT ===" >> "$REPORT_DIR/$TEXT_REPORT"
}

# Script principal
echo "Génération du rapport système..."
generate_html_report
generate_text_report

echo "Rapports générés:"
echo "- HTML: $REPORT_DIR/$REPORT_FILE"
echo "- Texte: $REPORT_DIR/$TEXT_REPORT"
```

---

## Partie III : Administration et maintenance (35 points)

### Tâche 6 : Gestion des logs (15 points)

1. **Créer un système de rotation de logs** :
   - Script `rotate_logs.sh` qui archive les logs > 100 lignes
   - Compression avec gzip des archives
   - Conservation des 10 dernières archives seulement

2. **Analyser les logs système** :
   - Compter les erreurs par type
   - Identifier les pics d'activité
   - Générer un résumé quotidien

**Script de rotation attendu :**
```bash
#!/bin/bash

LOG_DIRS=("/home/$USER/techcorp/logs/apache" "/home/$USER/techcorp/logs/application")
MAX_LINES=100
MAX_ARCHIVES=10

for log_dir in "${LOG_DIRS[@]}"; do
    if [ -d "$log_dir" ]; then
        for log_file in "$log_dir"/*.log; do
            if [ -f "$log_file" ] && [ $(wc -l < "$log_file") -gt $MAX_LINES ]; then
                timestamp=$(date +%Y%m%d_%H%M%S)
                gzip -c "$log_file" > "${log_file}.${timestamp}.gz"
                > "$log_file"  # Vider le fichier original
                
                # Nettoyer anciennes archives
                find "$log_dir" -name "$(basename "$log_file").*.gz" | sort | head -n -$MAX_ARCHIVES | xargs rm -f
            fi
        done
    fi
done
```

### Tâche 7 : Surveillance proactive (20 points)

Créer un système d'alertes qui :

1. **Surveille l'espace disque** (alerte si > 85%)
2. **Surveille la charge système** (alerte si load > 2.0) 
3. **Vérifie la connectivité** (ping vers 8.8.8.8)
4. **Contrôle les processus critiques** (simulation)
5. **Envoie des notifications** (fichier d'alerte)

**Exemple de système d'alerte :**
```bash
#!/bin/bash

ALERT_FILE="/home/$USER/techcorp/logs/alerts.log"
THRESHOLD_DISK=85
THRESHOLD_LOAD="2.0"

check_disk() {
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$usage" -gt $THRESHOLD_DISK ]; then
        echo "$(date): ALERTE DISQUE - Utilisation: ${usage}%" >> "$ALERT_FILE"
        return 1
    fi
    return 0
}

check_load() {
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    if (( $(echo "$load > $THRESHOLD_LOAD" | bc -l) )); then
        echo "$(date): ALERTE CHARGE - Load: $load" >> "$ALERT_FILE"
        return 1
    fi
    return 0
}

check_connectivity() {
    if ! ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo "$(date): ALERTE RÉSEAU - Pas de connectivité" >> "$ALERT_FILE"
        return 1
    fi
    return 0
}

# Exécution des vérifications
check_disk
check_load  
check_connectivity

# Résumé quotidien si nécessaire
if [ -f "$ALERT_FILE" ]; then
    alert_count=$(grep "$(date +%Y-%m-%d)" "$ALERT_FILE" | wc -l)
    if [ "$alert_count" -gt 0 ]; then
        echo "$(date): $alert_count alerte(s) aujourd'hui" >> "$ALERT_FILE"
    fi
fi
```

---

## Partie IV : Configuration avancée (25 points)

### Tâche 8 : Automatisation avec cron (15 points)

Configurer les tâches automatisées suivantes :

1. **Sauvegarde quotidienne** à 2h00
2. **Rapport système** toutes les 6 heures  
3. **Rotation des logs** chaque dimanche à 3h00
4. **Vérifications d'alertes** toutes les 15 minutes
5. **Maintenance hebdomadaire** le samedi à minuit

**Configuration crontab attendue :**
```bash
# Sauvegarde quotidienne
0 2 * * * /home/$USER/techcorp/scripts/backup/backup_system.sh

# Rapport système (6h, 12h, 18h, 00h)  
0 */6 * * * /home/$USER/techcorp/scripts/monitoring/system_check.sh

# Rotation logs (dimanche 3h)
0 3 * * 0 /home/$USER/techcorp/scripts/monitoring/rotate_logs.sh

# Surveillance (toutes les 15min)
*/15 * * * * /home/$USER/techcorp/scripts/monitoring/alert_system.sh

# Maintenance hebdomadaire (samedi minuit)
0 0 * * 6 /home/$USER/techcorp/scripts/maintenance/weekly_maintenance.sh
```

### Tâche 9 : Personnalisation avancée (10 points)

Créer un environnement de travail optimisé :

1. **Fichier `.bash_aliases`** avec 15 alias utiles minimum
2. **Invite de commande personnalisée** affichant :
   - Heure actuelle
   - Utilisateur@machine
   - Répertoire courant  
   - Indicateur de statut Git (si dans un repo)
3. **Fonctions bash avancées** pour :
   - `mkcd` : créer et entrer dans un répertoire
   - `backup-quick` : sauvegarde rapide d'un fichier
   - `log-search` : recherche dans les logs avec couleurs

**Exemple de configuration :**
```bash
# ~/.bash_aliases

# Navigation rapide
alias ..='cd ..'
alias ...='cd ../..'  
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias tcorp='cd /home/$USER/techcorp'
alias projects='cd /home/$USER/techcorp/projets'
alias logs='cd /home/$USER/techcorp/logs'

# Outils système
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias ports='netstat -tulanp'

# Sécurité
alias rm='rm -i'
alias cp='cp -i' 
alias mv='mv -i'

# Git (si applicable)
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Fonctions avancées
mkcd() {
    mkdir -p "$1" && cd "$1"
}

backup-quick() {
    if [ -f "$1" ]; then
        cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Sauvegarde créée: $1.backup.$(date +%Y%m%d_%H%M%S)"
    else
        echo "Fichier non trouvé: $1"
    fi
}

log-search() {
    grep --color=always -n "$1" /home/$USER/techcorp/logs/*.log
}

# Prompt personnalisé avec couleurs
PS1='\[\033[01;32m\][\t] \u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
```

---

## Grille d'évaluation finale

| Partie | Points max | Critères principaux |
|---------|------------|-------------------|
| I - Environnement | 40 | Structure, permissions, configuration |
| II - Scripts | 50 | Fonctionnalité, robustesse, gestion d'erreurs |
| III - Administration | 35 | Logs, surveillance, maintenance |
| IV - Configuration | 25 | Automatisation, personnalisation |
| **Total** | **150** | **Certification si ≥ 105/150** |

### Niveaux de certification

- **150-135** : Expert Linux - Certification Gold
- **134-120** : Administrateur confirmé - Certification Silver  
- **119-105** : Utilisateur avancé - Certification Bronze
- **< 105** : Non certifié - Formation complémentaire requise

### Instructions de rendu

1. **Archive complète** : `tar -czf evaluation_[nom]_[prenom].tar.gz techcorp/`
2. **Documentation** : README expliquant les choix techniques
3. **Tests** : Preuves d'exécution (captures, logs)
4. **Présentation orale** : 15 minutes de démonstration

**Bonne réussite dans votre certification !**