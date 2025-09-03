# Module 7.2 : Transferts de fichiers

## Objectifs d'apprentissage
- Maitriser scp pour les transferts securises
- Utiliser rsync pour la synchronisation efficace
- Comprendre les options avancees de transfert
- Automatiser les transferts avec scripts
- Resoudre les problemes de transfert courants

## Introduction

Le **transfert de fichiers** entre systemes Linux est une tache fondamentale en administration. Les outils `scp` et `rsync` permettent de copier des fichiers de maniere securisee et efficace via SSH.

---

## 1. SSH - Fondation des transferts securises

### Concepts de base SSH

#### Authentification SSH
```bash
# Connexion avec mot de passe
ssh username@server.com

# Connexion avec cle SSH (recommande)
ssh -i ~/.ssh/id_rsa username@server.com

# Port personnalise
ssh -p 2222 username@server.com
```

#### Configuration SSH cliente
```bash
# Fichier de configuration personnel
nano ~/.ssh/config

# Exemple de configuration
Host myserver
    HostName 192.168.1.100
    User admin
    Port 22
    IdentityFile ~/.ssh/id_rsa_server
    ServerAliveInterval 60

Host backup-server
    HostName backup.domain.com
    User backup
    IdentityFile ~/.ssh/id_backup

# Utilisation simplifiee apres configuration
ssh myserver        # Equivalent a ssh admin@192.168.1.100
```

### Generation et gestion des cles SSH

#### Creer une paire de cles
```bash
# Generation cle RSA
ssh-keygen -t rsa -b 4096 -C "votre.email@domain.com"

# Generation cle ED25519 (plus moderne)
ssh-keygen -t ed25519 -C "votre.email@domain.com"

# Avec nom de fichier specifique
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_server

# Sans phrase de passe (pour automatisation)
ssh-keygen -t rsa -b 4096 -N ""
```

#### Deployer la cle publique
```bash
# Methode automatique (recommandee)
ssh-copy-id username@server.com
ssh-copy-id -i ~/.ssh/id_rsa_server.pub username@server.com

# Methode manuelle
cat ~/.ssh/id_rsa.pub | ssh username@server.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Verifier le deploiement
ssh username@server.com "cat ~/.ssh/authorized_keys"
```

---

## 2. Commande scp - Secure Copy

### Syntaxe de base

#### Format general
```bash
scp [options] source destination

# Local vers distant
scp file.txt username@server:/path/destination/

# Distant vers local  
scp username@server:/path/file.txt ./

# Distant vers distant
scp user1@server1:/path/file.txt user2@server2:/path/
```

### Transferts simples

#### Fichiers individuels
```bash
# Copier un fichier vers serveur distant
scp document.pdf admin@192.168.1.100:/home/admin/

# Copier avec nom different
scp local_file.txt admin@server:/home/admin/remote_file.txt

# Copier depuis serveur distant
scp admin@server:/var/log/syslog ./server_syslog.log

# Port SSH personnalise
scp -P 2222 file.txt admin@server:/home/admin/
```

#### Repertoires complets
```bash
# Copier un repertoire (recursif)
scp -r /local/directory admin@server:/remote/path/

# Preserver les permissions et timestamps
scp -rp /local/directory admin@server:/remote/path/

# Copier depuis serveur distant
scp -r admin@server:/remote/directory ./local_copy/
```

### Options avancees de scp

#### Controle du transfert
```bash
# Mode verbose (afficher progression)
scp -v file.txt admin@server:/home/admin/

# Compression activee (utile sur liaisons lentes)
scp -C large_file.zip admin@server:/home/admin/

# Limiter la bande passante (Ko/s)
scp -l 1000 big_file.iso admin@server:/home/admin/

# Preservation des attributs
scp -p file.txt admin@server:/home/admin/    # Permissions et dates

# Combinaison d'options
scp -Cvp -l 2000 file.txt admin@server:/path/
```

#### Cles SSH specifiques
```bash
# Utiliser une cle SSH specifique
scp -i ~/.ssh/id_rsa_server file.txt admin@server:/home/admin/

# Configuration SSH utilisee automatiquement
scp file.txt myserver:/home/admin/    # Si defini dans ~/.ssh/config
```

### Exemples pratiques scp

#### Sauvegarde de fichiers
```bash
# Sauvegarder configuration systeme
scp -r /etc/nginx admin@backup-server:/backups/nginx_$(date +%Y%m%d)/

# Sauvegarder logs
scp /var/log/syslog admin@backup:/backups/logs/syslog_$(hostname)_$(date +%Y%m%d)

# Sauvegarder base de donnees
mysqldump -u root -p database_name > db_backup.sql
scp db_backup.sql admin@backup:/backups/databases/
```

#### Deploiement d'applications
```bash
# Copier application web
scp -r ./website/* admin@webserver:/var/www/html/

# Deployer script de maintenance
scp maintenance.sh admin@server:/usr/local/bin/
ssh admin@server "chmod +x /usr/local/bin/maintenance.sh"

# Copier configuration
scp config.conf admin@server:/etc/myapp/
ssh admin@server "sudo systemctl restart myapp"
```

---

## 3. Commande rsync - Synchronisation avancee

### Avantages de rsync sur scp

#### Pourquoi rsync ?
- **Transfert differentiel** : ne copie que les changements
- **Reprise de transfert** : continue apres interruption
- **Synchronisation bidirectionnelle** : maintient identiques deux arborescences
- **Exclusions avancees** : filtres sophistiques
- **Preservation complete** : permissions, liens, attributs etendus

### Syntaxe de base rsync

#### Format general
```bash
rsync [options] source destination

# Modes principaux
rsync -av /local/path/ username@server:/remote/path/    # Local -> distant
rsync -av username@server:/remote/path/ /local/path/    # Distant -> local
rsync -av server1:/path/ server2:/path/                 # Distant -> distant
```

### Options essentielles rsync

#### Options de base
```bash
# -a : mode archive (preserve tout)
# -v : verbose (affichage detaille)
# -z : compression
# -P : progression + reprise de transfert

# Combinaison courante
rsync -avzP source/ destination/

# Options detaillees de -a (archive)
# -a equivaut a : -rlptgoD
# -r : recursif
# -l : preserver liens symboliques
# -p : preserver permissions
# -t : preserver timestamps
# -g : preserver groupe
# -o : preserver proprietaire
# -D : preserver fichiers speciaux
```

#### Mode dry-run (simulation)
```bash
# Tester sans effectuer de changements
rsync -avzP --dry-run source/ destination/

# Voir ce qui serait supprime
rsync -avzP --delete --dry-run source/ destination/

# Format de sortie plus lisible
rsync -avzP --dry-run --itemize-changes source/ destination/
```

### Synchronisation avec rsync

#### Synchronisation simple
```bash
# Synchroniser repertoire local vers distant
rsync -avzP /home/user/documents/ admin@server:/backup/documents/

# Synchroniser depuis serveur distant
rsync -avzP admin@server:/data/shared/ /local/backup/

# Synchronisation avec suppression des fichiers obsoletes
rsync -avzP --delete /local/data/ admin@server:/backup/data/
```

#### Exclusions et inclusions
```bash
# Exclure des fichiers/dossiers
rsync -avzP --exclude='*.tmp' --exclude='cache/' source/ destination/

# Fichier d'exclusion
echo "*.log" > exclude.txt
echo "temp/" >> exclude.txt
rsync -avzP --exclude-from=exclude.txt source/ destination/

# Inclure seulement certains fichiers
rsync -avzP --include='*.txt' --exclude='*' source/ destination/

# Exemples d'exclusion courantes
rsync -avzP \
  --exclude='.git/' \
  --exclude='node_modules/' \
  --exclude='*.pyc' \
  --exclude='.DS_Store' \
  source/ destination/
```

### Cas d'usage avances rsync

#### Sauvegarde incrementale
```bash
#!/bin/bash
# backup_incremental.sh - Sauvegarde incrementale avec rsync

BACKUP_ROOT="/backup"
TODAY=$(date +%Y%m%d)
YESTERDAY=$(date -d yesterday +%Y%m%d)

SOURCE="/home/users/"
CURRENT_BACKUP="$BACKUP_ROOT/current"
DAILY_BACKUP="$BACKUP_ROOT/daily_$TODAY"

# Creer sauvegarde du jour avec liens durs vers la precedente
rsync -avzP \
  --delete \
  --link-dest="$CURRENT_BACKUP" \
  "$SOURCE" \
  "$DAILY_BACKUP"

# Mettre a jour le lien 'current'
rm -f "$CURRENT_BACKUP"
ln -s "$DAILY_BACKUP" "$CURRENT_BACKUP"

echo "Sauvegarde terminee : $DAILY_BACKUP"
```

#### Synchronisation bidirectionnelle
```bash
# Synchronisation serveur A vers B
rsync -avzP --delete serverA:/data/ /local/sync/
rsync -avzP --delete /local/sync/ serverB:/data/

# Attention : peut causer des pertes de donnees si modifications simultanees
# Utiliser des outils specialises comme unison pour vraie bidirectionnelle
```

#### Transfert avec limitation de bande passante
```bash
# Limiter a 1000 Ko/s
rsync -avzP --bwlimit=1000 large_files/ admin@server:/backup/

# Planifier pendant heures creuses
rsync -avzP --bwlimit=5000 /data/ admin@server:/backup/ &
```

---

## 4. Comparaison scp vs rsync

### Quand utiliser scp

#### Avantages de scp
- **Simplicite** : syntaxe proche de cp
- **Rapidite** : pour petits fichiers ou transfert unique
- **Universalite** : disponible partout ou SSH existe
- **Securite** : chiffrement SSH integre

#### Cas d'usage scp
```bash
# Transfert ponctuel de fichiers
scp config.txt admin@server:/etc/app/

# Copie rapide de petits fichiers
scp *.log admin@server:/var/log/app/

# Transfert simple sans besoins avances
scp -r project/ admin@server:/home/admin/
```

### Quand utiliser rsync

#### Avantages de rsync
- **Efficacite** : transfert differentiel
- **Reprise** : continue apres interruption
- **Flexibilite** : nombreuses options de filtrage
- **Synchronisation** : maintient coherence entre repertoires

#### Cas d'usage rsync
```bash
# Synchronisation reguliere de gros volumes
rsync -avzP /data/ admin@server:/backup/data/

# Sauvegarde avec exclusions
rsync -avzP --exclude='cache/' --exclude='*.tmp' website/ admin@server:/var/www/

# Transfert de gros fichiers avec reprise possible
rsync -avzP --partial big_file.iso admin@server:/downloads/
```

### Tableau comparatif

| Critere | scp | rsync |
|---------|-----|-------|
| **Simplicite** | [OK] Tres simple | [WARN] Plus complexe |
| **Transfert differentiel** | [NOK] Non | [OK] Oui |
| **Reprise de transfert** | [NOK] Non | [OK] Oui |
| **Synchronisation** | [NOK] Non | [OK] Oui |
| **Exclusions avancees** | [NOK] Non | [OK] Oui |
| **Performance gros volumes** | [WARN] Moyen | [OK] Excellent |
| **Consommation reseau** | [WARN] Elevee | [OK] Optimisee |
| **Disponibilite** | [OK] Partout | [WARN] A installer |

---

## 5. Automatisation des transferts

### Scripts de transfert automatise

#### Script de sauvegarde quotidienne
```bash
#!/bin/bash
# daily_backup.sh - Sauvegarde automatisee

# Configuration
SOURCE="/home/users"
DEST_SERVER="backup.domain.com"
DEST_PATH="/backups/daily"
LOG_FILE="/var/log/backup.log"
RETENTION_DAYS=30

# Fonction de logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Fonction de nettoyage ancien backups
cleanup_old_backups() {
    ssh admin@$DEST_SERVER "find $DEST_PATH -type d -name 'backup_*' -mtime +$RETENTION_DAYS -exec rm -rf {} \;"
}

# Sauvegarde principale
main() {
    local backup_date=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$DEST_PATH/backup_$backup_date"
    
    log "Debut sauvegarde vers $backup_dir"
    
    # Creer le repertoire de destination
    ssh admin@$DEST_SERVER "mkdir -p $backup_dir"
    
    # Transfert avec rsync
    if rsync -avzP \
        --delete \
        --exclude='*.tmp' \
        --exclude='.cache/' \
        --exclude='node_modules/' \
        "$SOURCE/" \
        admin@$DEST_SERVER:"$backup_dir/"; then
        
        log "Sauvegarde reussie: $backup_dir"
        
        # Creer lien symbolique vers derniere sauvegarde
        ssh admin@$DEST_SERVER "ln -sfn $backup_dir $DEST_PATH/latest"
        
        # Nettoyer anciennes sauvegardes
        cleanup_old_backups
        
        log "Nettoyage termine"
    else
        log "ERREUR: Echec de la sauvegarde"
        exit 1
    fi
}

# Execution
main
```

#### Script de synchronisation de sites web
```bash
#!/bin/bash
# deploy_website.sh - Deploiement automatise site web

# Configuration
LOCAL_PATH="./dist/"
REMOTE_SERVER="webserver.com"
REMOTE_PATH="/var/www/html/"
REMOTE_USER="www-deploy"

# Verifications pre-deploiement
check_local_build() {
    if [[ ! -d "$LOCAL_PATH" ]]; then
        echo "Erreur: Repertoire de build '$LOCAL_PATH' non trouve"
        exit 1
    fi
    
    if [[ ! -f "$LOCAL_PATH/index.html" ]]; then
        echo "Erreur: index.html non trouve dans le build"
        exit 1
    fi
}

# Test de connectivite
check_remote_access() {
    if ! ssh -q $REMOTE_USER@$REMOTE_SERVER exit; then
        echo "Erreur: Impossible de se connecter a $REMOTE_SERVER"
        exit 1
    fi
}

# Sauvegarde du site actuel
backup_current() {
    echo "Sauvegarde du site actuel..."
    ssh $REMOTE_USER@$REMOTE_SERVER "tar czf /tmp/website_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C $REMOTE_PATH ."
}

# Deploiement
deploy() {
    echo "Deploiement en cours..."
    
    # Synchronisation avec test prealable
    if rsync -avzP \
        --dry-run \
        --delete \
        --exclude='.htaccess' \
        --exclude='wp-config.php' \
        "$LOCAL_PATH" \
        $REMOTE_USER@$REMOTE_SERVER:"$REMOTE_PATH"; then
        
        echo "Test reussi, deploiement reel..."
        
        rsync -avzP \
            --delete \
            --exclude='.htaccess' \
            --exclude='wp-config.php' \
            "$LOCAL_PATH" \
            $REMOTE_USER@$REMOTE_SERVER:"$REMOTE_PATH"
    else
        echo "Erreur lors du test de deploiement"
        exit 1
    fi
}

# Test post-deploiement
test_deployment() {
    echo "Test du site deploye..."
    if curl -s -o /dev/null -w "%{http_code}" http://$REMOTE_SERVER | grep -q "200"; then
        echo "[OK] Site accessible et fonctionnel"
    else
        echo "[NOK] Probleme detecte sur le site"
        exit 1
    fi
}

# Fonction principale
main() {
    echo "=== DEPLOIEMENT SITE WEB ==="
    check_local_build
    check_remote_access
    backup_current
    deploy
    test_deployment
    echo "=== DEPLOIEMENT TERMINE ==="
}

# Execution
main
```

### Synchronisation avec cron

#### Configuration de taches automatiques
```bash
# Editer crontab utilisateur
crontab -e

# Exemples de taches de synchronisation
# Sauvegarde quotidienne a 2h du matin
0 2 * * * /home/user/scripts/daily_backup.sh

# Synchronisation toutes les 4 heures
0 */4 * * * /usr/local/bin/rsync -azq /data/ backup@server:/backup/data/

# Sauvegarde hebdomadaire le dimanche a 3h
0 3 * * 0 /home/user/scripts/weekly_backup.sh

# Voir les taches cron actuelles
crontab -l
```

---

## 6. Resolution de problemes

### Problemes d'authentification SSH

#### Diagnostic des connexions SSH
```bash
# Test de connexion avec debug
ssh -v username@server.com
ssh -vv username@server.com    # Plus de details
ssh -vvv username@server.com   # Tres verbeux

# Tester une cle specifique
ssh -i ~/.ssh/id_rsa_test -v username@server.com

# Verifier les permissions des cles
ls -la ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

#### Problemes courants SSH
```bash
# Probleme : "Permission denied (publickey)"
# Solutions :
# 1. Verifier que la cle publique est sur le serveur
ssh username@server "cat ~/.ssh/authorized_keys | grep '$(cat ~/.ssh/id_rsa.pub)'"

# 2. Verifier les permissions cote serveur
ssh username@server "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"

# 3. Verifier la configuration SSH du serveur
ssh username@server "sudo grep -E 'PubkeyAuthentication|PasswordAuthentication' /etc/ssh/sshd_config"
```

### Problemes de transfert

#### Transferts interrompus
```bash
# scp : recommencer completement
scp -C file.txt username@server:/path/

# rsync : reprendre ou on s'est arrete
rsync -avzP --partial file.txt username@server:/path/

# Verifier l'integrite apres transfert
# Local
sha256sum file.txt

# Distant
ssh username@server "sha256sum /path/file.txt"
```

#### Problemes de permissions
```bash
# Erreur : permission denied en ecriture
# Verifier permissions repertoire de destination
ssh username@server "ls -ld /destination/path/"

# Creer repertoire si necessaire
ssh username@server "mkdir -p /destination/path/"

# Probleme : fichier exists et non ecrasable
rsync -avzP --force source/ destination/    # Force l'ecrasement
```

### Optimisation des performances

#### Ameliorer les vitesses de transfert
```bash
# Utiliser compression pour liaisons lentes
rsync -avzP -e "ssh -C" source/ username@server:/dest/

# Desactiver compression pour liaisons rapides locales
rsync -av --no-compress source/ username@server:/dest/

# Utiliser algorithmes SSH plus rapides
rsync -avzP -e "ssh -c aes128-ctr" source/ username@server:/dest/

# Augmenter le parallelisme (rsync recents)
rsync -avzP --parallel=4 source/ username@server:/dest/
```

#### Surveillance de transferts longs
```bash
# Utiliser screen/tmux pour transferts longs
screen -S transfer
rsync -avzP large_data/ username@server:/backup/
# Ctrl+A, D pour detacher

# Reprendre la session
screen -r transfer

# Logging detaille
rsync -avzP --log-file=transfer.log source/ destination/
tail -f transfer.log
```

---

## Resume

### Commandes essentielles de transfert
```bash
# SSH - Base des transferts securises
ssh-keygen -t rsa -b 4096      # Generer cles SSH
ssh-copy-id user@server        # Deployer cle publique

# scp - Transferts simples
scp file.txt user@server:/path/           # Fichier local -> distant
scp user@server:/path/file.txt ./         # Fichier distant -> local
scp -r directory/ user@server:/path/      # Repertoire recursif

# rsync - Synchronisation avancee  
rsync -avzP source/ user@server:/dest/    # Synchronisation de base
rsync -avzP --delete src/ dest/           # Avec suppression
rsync -avzP --dry-run src/ dest/          # Test sans action
```

### Options importantes
```bash
# scp
-r          # Recursif (repertoires)
-p          # Preserver permissions/dates
-C          # Compression
-v          # Verbose
-P port     # Port SSH personnalise
-i keyfile  # Cle SSH specifique

# rsync
-a          # Archive (preserve tout)
-v          # Verbose
-z          # Compression
-P          # Progression + reprise
--delete    # Supprimer fichiers obsoletes
--exclude   # Exclure fichiers/dossiers
--dry-run   # Simulation
```

### Cas d'usage recommandes

#### Utiliser scp pour :
- Transferts ponctuels de fichiers
- Copies simples sans synchronisation
- Environnements avec rsync non disponible
- Scripts simples de deploiement

#### Utiliser rsync pour :
- Synchronisation reguliere
- Gros volumes de donnees
- Sauvegardes incrementales
- Transferts avec filtrage avance
- Reprises de transfert necessaires

### Scripts d'automatisation
- **Sauvegardes** : rsync avec rotation et logs
- **Deploiements** : tests + synchronisation + verification
- **Planification** : crontab pour automatisation
- **Surveillance** : logs et alertes en cas d'echec

### Bonnes pratiques
- **Authentification** : cles SSH plutot que mots de passe
- **Tests** : --dry-run avant transferts importants
- **Sauvegardes** : toujours sauvegarder avant synchronisation destructive
- **Logs** : enregistrer les transferts importants
- **Permissions** : verifier les droits d'acces
- **Compression** : activer selon la bande passante disponible

---

**Temps de lecture estime** : 25-30 minutes
**Niveau** : Intermediaire
**Pre-requis** : SSH de base, navigation fichiers, concepts reseau