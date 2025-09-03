# Module 7.2 : Transferts de fichiers

## Objectifs d'apprentissage
- Maîtriser scp pour les transferts sécurisés
- Utiliser rsync pour la synchronisation efficace
- Comprendre les options avancées de transfert
- Automatiser les transferts avec scripts
- Résoudre les problèmes de transfert courants

## Introduction

Le **transfert de fichiers** entre systèmes Linux est une tâche fondamentale en administration. Les outils `scp` et `rsync` permettent de copier des fichiers de manière sécurisée et efficace via SSH.

---

## 1. SSH - Fondation des transferts sécurisés

### Concepts de base SSH

#### Authentification SSH
```bash
# Connexion avec mot de passe
ssh username@server.com

# Connexion avec clé SSH (recommandé)
ssh -i ~/.ssh/id_rsa username@server.com

# Port personnalisé
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

# Utilisation simplifiée après configuration
ssh myserver        # Équivalent à ssh admin@192.168.1.100
```

### Génération et gestion des clés SSH

#### Créer une paire de clés
```bash
# Génération clé RSA
ssh-keygen -t rsa -b 4096 -C "votre.email@domain.com"

# Génération clé ED25519 (plus moderne)
ssh-keygen -t ed25519 -C "votre.email@domain.com"

# Avec nom de fichier spécifique
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_server

# Sans phrase de passe (pour automatisation)
ssh-keygen -t rsa -b 4096 -N ""
```

#### Déployer la clé publique
```bash
# Méthode automatique (recommandée)
ssh-copy-id username@server.com
ssh-copy-id -i ~/.ssh/id_rsa_server.pub username@server.com

# Méthode manuelle
cat ~/.ssh/id_rsa.pub | ssh username@server.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Vérifier le déploiement
ssh username@server.com "cat ~/.ssh/authorized_keys"
```

---

## 2. Commande scp - Secure Copy

### Syntaxe de base

#### Format général
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

# Copier avec nom différent
scp local_file.txt admin@server:/home/admin/remote_file.txt

# Copier depuis serveur distant
scp admin@server:/var/log/syslog ./server_syslog.log

# Port SSH personnalisé
scp -P 2222 file.txt admin@server:/home/admin/
```

#### Répertoires complets
```bash
# Copier un répertoire (récursif)
scp -r /local/directory admin@server:/remote/path/

# Préserver les permissions et timestamps
scp -rp /local/directory admin@server:/remote/path/

# Copier depuis serveur distant
scp -r admin@server:/remote/directory ./local_copy/
```

### Options avancées de scp

#### Contrôle du transfert
```bash
# Mode verbose (afficher progression)
scp -v file.txt admin@server:/home/admin/

# Compression activée (utile sur liaisons lentes)
scp -C large_file.zip admin@server:/home/admin/

# Limiter la bande passante (Ko/s)
scp -l 1000 big_file.iso admin@server:/home/admin/

# Préservation des attributs
scp -p file.txt admin@server:/home/admin/    # Permissions et dates

# Combinaison d'options
scp -Cvp -l 2000 file.txt admin@server:/path/
```

#### Clés SSH spécifiques
```bash
# Utiliser une clé SSH spécifique
scp -i ~/.ssh/id_rsa_server file.txt admin@server:/home/admin/

# Configuration SSH utilisée automatiquement
scp file.txt myserver:/home/admin/    # Si défini dans ~/.ssh/config
```

### Exemples pratiques scp

#### Sauvegarde de fichiers
```bash
# Sauvegarder configuration système
scp -r /etc/nginx admin@backup-server:/backups/nginx_$(date +%Y%m%d)/

# Sauvegarder logs
scp /var/log/syslog admin@backup:/backups/logs/syslog_$(hostname)_$(date +%Y%m%d)

# Sauvegarder base de données
mysqldump -u root -p database_name > db_backup.sql
scp db_backup.sql admin@backup:/backups/databases/
```

#### Déploiement d'applications
```bash
# Copier application web
scp -r ./website/* admin@webserver:/var/www/html/

# Déployer script de maintenance
scp maintenance.sh admin@server:/usr/local/bin/
ssh admin@server "chmod +x /usr/local/bin/maintenance.sh"

# Copier configuration
scp config.conf admin@server:/etc/myapp/
ssh admin@server "sudo systemctl restart myapp"
```

---

## 3. Commande rsync - Synchronisation avancée

### Avantages de rsync sur scp

#### Pourquoi rsync ?
- **Transfert différentiel** : ne copie que les changements
- **Reprise de transfert** : continue après interruption
- **Synchronisation bidirectionnelle** : maintient identiques deux arborescences
- **Exclusions avancées** : filtres sophistiqués
- **Préservation complète** : permissions, liens, attributs étendus

### Syntaxe de base rsync

#### Format général
```bash
rsync [options] source destination

# Modes principaux
rsync -av /local/path/ username@server:/remote/path/    # Local → distant
rsync -av username@server:/remote/path/ /local/path/    # Distant → local
rsync -av server1:/path/ server2:/path/                 # Distant → distant
```

### Options essentielles rsync

#### Options de base
```bash
# -a : mode archive (préserve tout)
# -v : verbose (affichage détaillé)
# -z : compression
# -P : progression + reprise de transfert

# Combinaison courante
rsync -avzP source/ destination/

# Options détaillées de -a (archive)
# -a équivaut à : -rlptgoD
# -r : récursif
# -l : préserver liens symboliques
# -p : préserver permissions
# -t : préserver timestamps
# -g : préserver groupe
# -o : préserver propriétaire
# -D : préserver fichiers spéciaux
```

#### Mode dry-run (simulation)
```bash
# Tester sans effectuer de changements
rsync -avzP --dry-run source/ destination/

# Voir ce qui serait supprimé
rsync -avzP --delete --dry-run source/ destination/

# Format de sortie plus lisible
rsync -avzP --dry-run --itemize-changes source/ destination/
```

### Synchronisation avec rsync

#### Synchronisation simple
```bash
# Synchroniser répertoire local vers distant
rsync -avzP /home/user/documents/ admin@server:/backup/documents/

# Synchroniser depuis serveur distant
rsync -avzP admin@server:/data/shared/ /local/backup/

# Synchronisation avec suppression des fichiers obsolètes
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

### Cas d'usage avancés rsync

#### Sauvegarde incrémentale
```bash
#!/bin/bash
# backup_incremental.sh - Sauvegarde incrémentale avec rsync

BACKUP_ROOT="/backup"
TODAY=$(date +%Y%m%d)
YESTERDAY=$(date -d yesterday +%Y%m%d)

SOURCE="/home/users/"
CURRENT_BACKUP="$BACKUP_ROOT/current"
DAILY_BACKUP="$BACKUP_ROOT/daily_$TODAY"

# Créer sauvegarde du jour avec liens durs vers la précédente
rsync -avzP \
  --delete \
  --link-dest="$CURRENT_BACKUP" \
  "$SOURCE" \
  "$DAILY_BACKUP"

# Mettre à jour le lien 'current'
rm -f "$CURRENT_BACKUP"
ln -s "$DAILY_BACKUP" "$CURRENT_BACKUP"

echo "Sauvegarde terminée : $DAILY_BACKUP"
```

#### Synchronisation bidirectionnelle
```bash
# Synchronisation serveur A vers B
rsync -avzP --delete serverA:/data/ /local/sync/
rsync -avzP --delete /local/sync/ serverB:/data/

# Attention : peut causer des pertes de données si modifications simultanées
# Utiliser des outils spécialisés comme unison pour vraie bidirectionnelle
```

#### Transfert avec limitation de bande passante
```bash
# Limiter à 1000 Ko/s
rsync -avzP --bwlimit=1000 large_files/ admin@server:/backup/

# Planifier pendant heures creuses
rsync -avzP --bwlimit=5000 /data/ admin@server:/backup/ &
```

---

## 4. Comparaison scp vs rsync

### Quand utiliser scp

#### Avantages de scp
- **Simplicité** : syntaxe proche de cp
- **Rapidité** : pour petits fichiers ou transfert unique
- **Universalité** : disponible partout où SSH existe
- **Sécurité** : chiffrement SSH intégré

#### Cas d'usage scp
```bash
# Transfert ponctuel de fichiers
scp config.txt admin@server:/etc/app/

# Copie rapide de petits fichiers
scp *.log admin@server:/var/log/app/

# Transfert simple sans besoins avancés
scp -r project/ admin@server:/home/admin/
```

### Quand utiliser rsync

#### Avantages de rsync
- **Efficacité** : transfert différentiel
- **Reprise** : continue après interruption
- **Flexibilité** : nombreuses options de filtrage
- **Synchronisation** : maintient cohérence entre répertoires

#### Cas d'usage rsync
```bash
# Synchronisation régulière de gros volumes
rsync -avzP /data/ admin@server:/backup/data/

# Sauvegarde avec exclusions
rsync -avzP --exclude='cache/' --exclude='*.tmp' website/ admin@server:/var/www/

# Transfert de gros fichiers avec reprise possible
rsync -avzP --partial big_file.iso admin@server:/downloads/
```

### Tableau comparatif

| Critère | scp | rsync |
|---------|-----|-------|
| **Simplicité** | ✅ Très simple | ⚠️ Plus complexe |
| **Transfert différentiel** | ❌ Non | ✅ Oui |
| **Reprise de transfert** | ❌ Non | ✅ Oui |
| **Synchronisation** | ❌ Non | ✅ Oui |
| **Exclusions avancées** | ❌ Non | ✅ Oui |
| **Performance gros volumes** | ⚠️ Moyen | ✅ Excellent |
| **Consommation réseau** | ⚠️ Élevée | ✅ Optimisée |
| **Disponibilité** | ✅ Partout | ⚠️ À installer |

---

## 5. Automatisation des transferts

### Scripts de transfert automatisé

#### Script de sauvegarde quotidienne
```bash
#!/bin/bash
# daily_backup.sh - Sauvegarde automatisée

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
    
    log "Début sauvegarde vers $backup_dir"
    
    # Créer le répertoire de destination
    ssh admin@$DEST_SERVER "mkdir -p $backup_dir"
    
    # Transfert avec rsync
    if rsync -avzP \
        --delete \
        --exclude='*.tmp' \
        --exclude='.cache/' \
        --exclude='node_modules/' \
        "$SOURCE/" \
        admin@$DEST_SERVER:"$backup_dir/"; then
        
        log "Sauvegarde réussie: $backup_dir"
        
        # Créer lien symbolique vers dernière sauvegarde
        ssh admin@$DEST_SERVER "ln -sfn $backup_dir $DEST_PATH/latest"
        
        # Nettoyer anciennes sauvegardes
        cleanup_old_backups
        
        log "Nettoyage terminé"
    else
        log "ERREUR: Échec de la sauvegarde"
        exit 1
    fi
}

# Exécution
main
```

#### Script de synchronisation de sites web
```bash
#!/bin/bash
# deploy_website.sh - Déploiement automatisé site web

# Configuration
LOCAL_PATH="./dist/"
REMOTE_SERVER="webserver.com"
REMOTE_PATH="/var/www/html/"
REMOTE_USER="www-deploy"

# Vérifications pré-déploiement
check_local_build() {
    if [[ ! -d "$LOCAL_PATH" ]]; then
        echo "Erreur: Répertoire de build '$LOCAL_PATH' non trouvé"
        exit 1
    fi
    
    if [[ ! -f "$LOCAL_PATH/index.html" ]]; then
        echo "Erreur: index.html non trouvé dans le build"
        exit 1
    fi
}

# Test de connectivité
check_remote_access() {
    if ! ssh -q $REMOTE_USER@$REMOTE_SERVER exit; then
        echo "Erreur: Impossible de se connecter à $REMOTE_SERVER"
        exit 1
    fi
}

# Sauvegarde du site actuel
backup_current() {
    echo "Sauvegarde du site actuel..."
    ssh $REMOTE_USER@$REMOTE_SERVER "tar czf /tmp/website_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C $REMOTE_PATH ."
}

# Déploiement
deploy() {
    echo "Déploiement en cours..."
    
    # Synchronisation avec test préalable
    if rsync -avzP \
        --dry-run \
        --delete \
        --exclude='.htaccess' \
        --exclude='wp-config.php' \
        "$LOCAL_PATH" \
        $REMOTE_USER@$REMOTE_SERVER:"$REMOTE_PATH"; then
        
        echo "Test réussi, déploiement réel..."
        
        rsync -avzP \
            --delete \
            --exclude='.htaccess' \
            --exclude='wp-config.php' \
            "$LOCAL_PATH" \
            $REMOTE_USER@$REMOTE_SERVER:"$REMOTE_PATH"
    else
        echo "Erreur lors du test de déploiement"
        exit 1
    fi
}

# Test post-déploiement
test_deployment() {
    echo "Test du site déployé..."
    if curl -s -o /dev/null -w "%{http_code}" http://$REMOTE_SERVER | grep -q "200"; then
        echo "✅ Site accessible et fonctionnel"
    else
        echo "❌ Problème détecté sur le site"
        exit 1
    fi
}

# Fonction principale
main() {
    echo "=== DÉPLOIEMENT SITE WEB ==="
    check_local_build
    check_remote_access
    backup_current
    deploy
    test_deployment
    echo "=== DÉPLOIEMENT TERMINÉ ==="
}

# Exécution
main
```

### Synchronisation avec cron

#### Configuration de tâches automatiques
```bash
# Éditer crontab utilisateur
crontab -e

# Exemples de tâches de synchronisation
# Sauvegarde quotidienne à 2h du matin
0 2 * * * /home/user/scripts/daily_backup.sh

# Synchronisation toutes les 4 heures
0 */4 * * * /usr/local/bin/rsync -azq /data/ backup@server:/backup/data/

# Sauvegarde hebdomadaire le dimanche à 3h
0 3 * * 0 /home/user/scripts/weekly_backup.sh

# Voir les tâches cron actuelles
crontab -l
```

---

## 6. Résolution de problèmes

### Problèmes d'authentification SSH

#### Diagnostic des connexions SSH
```bash
# Test de connexion avec debug
ssh -v username@server.com
ssh -vv username@server.com    # Plus de détails
ssh -vvv username@server.com   # Très verbeux

# Tester une clé spécifique
ssh -i ~/.ssh/id_rsa_test -v username@server.com

# Vérifier les permissions des clés
ls -la ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

#### Problèmes courants SSH
```bash
# Problème : "Permission denied (publickey)"
# Solutions :
# 1. Vérifier que la clé publique est sur le serveur
ssh username@server "cat ~/.ssh/authorized_keys | grep '$(cat ~/.ssh/id_rsa.pub)'"

# 2. Vérifier les permissions côté serveur
ssh username@server "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"

# 3. Vérifier la configuration SSH du serveur
ssh username@server "sudo grep -E 'PubkeyAuthentication|PasswordAuthentication' /etc/ssh/sshd_config"
```

### Problèmes de transfert

#### Transferts interrompus
```bash
# scp : recommencer complètement
scp -C file.txt username@server:/path/

# rsync : reprendre où on s'est arrêté
rsync -avzP --partial file.txt username@server:/path/

# Vérifier l'intégrité après transfert
# Local
sha256sum file.txt

# Distant
ssh username@server "sha256sum /path/file.txt"
```

#### Problèmes de permissions
```bash
# Erreur : permission denied en écriture
# Vérifier permissions répertoire de destination
ssh username@server "ls -ld /destination/path/"

# Créer répertoire si nécessaire
ssh username@server "mkdir -p /destination/path/"

# Problème : fichier exists et non écrasable
rsync -avzP --force source/ destination/    # Force l'écrasement
```

### Optimisation des performances

#### Améliorer les vitesses de transfert
```bash
# Utiliser compression pour liaisons lentes
rsync -avzP -e "ssh -C" source/ username@server:/dest/

# Désactiver compression pour liaisons rapides locales
rsync -av --no-compress source/ username@server:/dest/

# Utiliser algorithmes SSH plus rapides
rsync -avzP -e "ssh -c aes128-ctr" source/ username@server:/dest/

# Augmenter le parallélisme (rsync récents)
rsync -avzP --parallel=4 source/ username@server:/dest/
```

#### Surveillance de transferts longs
```bash
# Utiliser screen/tmux pour transferts longs
screen -S transfer
rsync -avzP large_data/ username@server:/backup/
# Ctrl+A, D pour détacher

# Reprendre la session
screen -r transfer

# Logging détaillé
rsync -avzP --log-file=transfer.log source/ destination/
tail -f transfer.log
```

---

## Résumé

### Commandes essentielles de transfert
```bash
# SSH - Base des transferts sécurisés
ssh-keygen -t rsa -b 4096      # Générer clés SSH
ssh-copy-id user@server        # Déployer clé publique

# scp - Transferts simples
scp file.txt user@server:/path/           # Fichier local → distant
scp user@server:/path/file.txt ./         # Fichier distant → local
scp -r directory/ user@server:/path/      # Répertoire récursif

# rsync - Synchronisation avancée  
rsync -avzP source/ user@server:/dest/    # Synchronisation de base
rsync -avzP --delete src/ dest/           # Avec suppression
rsync -avzP --dry-run src/ dest/          # Test sans action
```

### Options importantes
```bash
# scp
-r          # Récursif (répertoires)
-p          # Préserver permissions/dates
-C          # Compression
-v          # Verbose
-P port     # Port SSH personnalisé
-i keyfile  # Clé SSH spécifique

# rsync
-a          # Archive (préserve tout)
-v          # Verbose
-z          # Compression
-P          # Progression + reprise
--delete    # Supprimer fichiers obsolètes
--exclude   # Exclure fichiers/dossiers
--dry-run   # Simulation
```

### Cas d'usage recommandés

#### Utiliser scp pour :
- Transferts ponctuels de fichiers
- Copies simples sans synchronisation
- Environnements avec rsync non disponible
- Scripts simples de déploiement

#### Utiliser rsync pour :
- Synchronisation régulière
- Gros volumes de données
- Sauvegardes incrémentales
- Transferts avec filtrage avancé
- Reprises de transfert nécessaires

### Scripts d'automatisation
- **Sauvegardes** : rsync avec rotation et logs
- **Déploiements** : tests + synchronisation + vérification
- **Planification** : crontab pour automatisation
- **Surveillance** : logs et alertes en cas d'échec

### Bonnes pratiques
- **Authentification** : clés SSH plutôt que mots de passe
- **Tests** : --dry-run avant transferts importants
- **Sauvegardes** : toujours sauvegarder avant synchronisation destructive
- **Logs** : enregistrer les transferts importants
- **Permissions** : vérifier les droits d'accès
- **Compression** : activer selon la bande passante disponible

---

**Temps de lecture estimé** : 25-30 minutes
**Niveau** : Intermédiaire
**Pré-requis** : SSH de base, navigation fichiers, concepts réseau