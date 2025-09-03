# TP 8.1 : Automatisation complète

## Objectifs
- Mettre en pratique les redirections et pipes
- Créer des scripts bash fonctionnels
- Programmer des tâches avec cron
- Personnaliser son environnement avec des alias

## Durée estimée
2 heures

## Prérequis
- Maîtrise des commandes de base Linux
- Compréhension des droits et permissions
- Notions de manipulation de fichiers

---

## Partie 1 : Redirections et pipes (30 min)

### Exercice 1.1 : Gestion des logs

**Objectif :** Créer un système de logging simple

1. **Créer un répertoire de travail**
   ```bash
   mkdir ~/tp-automatisation
   cd ~/tp-automatisation
   ```

2. **Générer des données de test**
   ```bash
   # Créer une liste de fichiers avec leurs tailles
   ls -la /etc > fichiers_etc.txt
   
   # Générer des données de processus
   ps aux > processus.txt
   
   # Créer des données d'erreur simulées
   echo "ERREUR: Connexion impossible" > erreurs.log
   echo "WARNING: Espace disque faible" >> erreurs.log
   echo "INFO: Sauvegarde terminée" >> erreurs.log
   echo "ERREUR: Fichier non trouvé" >> erreurs.log
   ```

3. **Utiliser les pipes pour analyser**
   ```bash
   # Compter les lignes de chaque type dans les logs
   cat erreurs.log | grep "ERREUR" | wc -l
   cat erreurs.log | grep "WARNING" | wc -l
   cat erreurs.log | grep "INFO" | wc -l
   
   # Trouver les plus gros fichiers dans /etc
   cat fichiers_etc.txt | sort -k5 -n | tail -5
   
   # Trouver les processus qui consomment le plus de CPU
   cat processus.txt | sort -k3 -n | tail -10
   ```

4. **Créer un rapport complet**
   ```bash
   # Créer un rapport en combinant plusieurs sources
   echo "=== RAPPORT SYSTÈME ===" > rapport.txt
   echo "Date: $(date)" >> rapport.txt
   echo "" >> rapport.txt
   
   echo "--- Erreurs système ---" >> rapport.txt
   grep "ERREUR" erreurs.log >> rapport.txt
   echo "" >> rapport.txt
   
   echo "--- Top 5 plus gros fichiers /etc ---" >> rapport.txt
   cat fichiers_etc.txt | sort -k5 -n | tail -5 >> rapport.txt
   echo "" >> rapport.txt
   
   echo "--- Nombre total de processus ---" >> rapport.txt
   cat processus.txt | wc -l >> rapport.txt
   ```

**Questions de vérification :**
- Combien d'erreurs avez-vous dans le fichier de log ?
- Quel est le plus gros fichier dans /etc ?
- Combien de processus tournent actuellement ?

### Exercice 1.2 : Filtrage avancé

**Objectif :** Utiliser des pipes complexes pour l'analyse de données

1. **Analyser les connexions réseau**
   ```bash
   # Lister les connexions (simuler avec des données)
   echo "tcp 192.168.1.10:22 192.168.1.100:2345 ESTABLISHED" > connexions.txt
   echo "tcp 192.168.1.10:80 192.168.1.101:1234 TIME_WAIT" >> connexions.txt
   echo "tcp 192.168.1.10:443 192.168.1.102:5678 ESTABLISHED" >> connexions.txt
   echo "udp 192.168.1.10:53 192.168.1.103:9876 ESTABLISHED" >> connexions.txt
   
   # Compter par type de protocole
   cat connexions.txt | cut -d' ' -f1 | sort | uniq -c
   
   # Compter par état de connexion
   cat connexions.txt | awk '{print $NF}' | sort | uniq -c
   
   # Extraire toutes les adresses IP sources
   cat connexions.txt | cut -d' ' -f2 | cut -d':' -f1 | sort | uniq
   ```

2. **Créer un pipeline de traitement**
   ```bash
   # Créer une commande complexe qui :
   # 1. Lit les connexions
   # 2. Filtre les connexions ESTABLISHED
   # 3. Extrait les ports de destination
   # 4. Les trie et compte les occurrences
   
   cat connexions.txt | grep "ESTABLISHED" | cut -d' ' -f3 | cut -d':' -f2 | sort | uniq -c | sort -n
   ```

---

## Partie 2 : Scripts bash (45 min)

### Exercice 2.1 : Script de sauvegarde

**Objectif :** Créer un script de sauvegarde automatisée

1. **Créer le script de base**
   ```bash
   nano backup_script.sh
   ```

   Contenu :
   ```bash
   #!/bin/bash
   
   # Script de sauvegarde automatique
   # Auteur: [Votre nom]
   # Date: $(date +%Y-%m-%d)
   
   # Variables de configuration
   SOURCE_DIR="$HOME/Documents"
   BACKUP_DIR="$HOME/backups"
   DATE=$(date +%Y%m%d_%H%M%S)
   BACKUP_NAME="backup_$DATE.tar.gz"
   
   # Vérifications préliminaires
   echo "=== Script de sauvegarde ==="
   echo "Début: $(date)"
   
   # Créer le répertoire de sauvegarde s'il n'existe pas
   if [ ! -d "$BACKUP_DIR" ]; then
       echo "Création du répertoire $BACKUP_DIR"
       mkdir -p "$BACKUP_DIR"
   fi
   
   # Vérifier que le répertoire source existe
   if [ ! -d "$SOURCE_DIR" ]; then
       echo "ERREUR: Le répertoire source $SOURCE_DIR n'existe pas"
       exit 1
   fi
   
   # Effectuer la sauvegarde
   echo "Sauvegarde de $SOURCE_DIR vers $BACKUP_DIR/$BACKUP_NAME"
   tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$HOME" "Documents" 2>/dev/null
   
   # Vérifier le succès de la sauvegarde
   if [ $? -eq 0 ]; then
       echo "✓ Sauvegarde réussie"
       echo "Fichier: $BACKUP_DIR/$BACKUP_NAME"
       echo "Taille: $(du -h $BACKUP_DIR/$BACKUP_NAME | cut -f1)"
   else
       echo "✗ Erreur lors de la sauvegarde"
       exit 1
   fi
   
   # Nettoyage des anciennes sauvegardes (garder les 5 dernières)
   echo "Nettoyage des anciennes sauvegardes..."
   cd "$BACKUP_DIR"
   ls -t backup_*.tar.gz | tail -n +6 | xargs -r rm
   
   echo "Fin: $(date)"
   echo "========================"
   ```

2. **Rendre le script exécutable et le tester**
   ```bash
   chmod +x backup_script.sh
   ./backup_script.sh
   ```

3. **Vérifier les résultats**
   ```bash
   ls -la ~/backups/
   ```

### Exercice 2.2 : Script de monitoring système

**Objectif :** Créer un script de surveillance système

1. **Créer le script de monitoring**
   ```bash
   nano system_monitor.sh
   ```

   Contenu :
   ```bash
   #!/bin/bash
   
   # Script de monitoring système
   
   LOG_FILE="/tmp/system_monitor.log"
   
   # Fonction pour logger avec timestamp
   log_message() {
       echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
   }
   
   # Fonction pour vérifier l'espace disque
   check_disk_space() {
       local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
       
       if [ "$usage" -gt 80 ]; then
           log_message "ALERTE: Espace disque critique: ${usage}%"
           return 1
       elif [ "$usage" -gt 70 ]; then
           log_message "WARNING: Espace disque élevé: ${usage}%"
           return 2
       else
           log_message "INFO: Espace disque OK: ${usage}%"
           return 0
       fi
   }
   
   # Fonction pour vérifier la mémoire
   check_memory() {
       local mem_info=$(free | grep "Mem:")
       local total=$(echo $mem_info | awk '{print $2}')
       local used=$(echo $mem_info | awk '{print $3}')
       local usage=$((used * 100 / total))
       
       if [ "$usage" -gt 90 ]; then
           log_message "ALERTE: Mémoire critique: ${usage}%"
           return 1
       elif [ "$usage" -gt 80 ]; then
           log_message "WARNING: Mémoire élevée: ${usage}%"
           return 2
       else
           log_message "INFO: Mémoire OK: ${usage}%"
           return 0
       fi
   }
   
   # Fonction pour vérifier les processus
   check_processes() {
       local process_count=$(ps aux | wc -l)
       log_message "INFO: Nombre de processus: $process_count"
       
       # Vérifier si des processus consomment trop de CPU
       local high_cpu=$(ps aux --sort=-pcpu | head -2 | tail -1 | awk '{print $3}')
       local high_cpu_int=$(echo "$high_cpu" | cut -d'.' -f1)
       
       if [ "$high_cpu_int" -gt 80 ]; then
           local process_name=$(ps aux --sort=-pcpu | head -2 | tail -1 | awk '{print $11}')
           log_message "WARNING: Processus $process_name consomme ${high_cpu}% CPU"
       fi
   }
   
   # Script principal
   echo "Début du monitoring système..."
   log_message "=== DÉBUT MONITORING ==="
   
   check_disk_space
   check_memory  
   check_processes
   
   log_message "=== FIN MONITORING ==="
   
   echo "Monitoring terminé. Voir $LOG_FILE pour les détails."
   
   # Afficher les dernières lignes du log
   echo ""
   echo "Dernières entrées du log:"
   tail -10 "$LOG_FILE"
   ```

2. **Tester le script**
   ```bash
   chmod +x system_monitor.sh
   ./system_monitor.sh
   ```

---

## Partie 3 : Programmation avec cron (30 min)

### Exercice 3.1 : Planification de tâches

**Objectif :** Programmer des tâches automatiques avec cron

1. **Éditer la crontab**
   ```bash
   crontab -e
   ```

2. **Ajouter les tâches suivantes**
   ```bash
   # Sauvegarde quotidienne à 2h du matin
   0 2 * * * /home/[votre_user]/tp-automatisation/backup_script.sh
   
   # Monitoring toutes les 15 minutes
   */15 * * * * /home/[votre_user]/tp-automatisation/system_monitor.sh
   
   # Nettoyage des logs anciens chaque dimanche à 3h
   0 3 * * 0 find /tmp -name "*.log" -mtime +7 -delete
   
   # Test - affichage de la date toutes les 2 minutes (pour vérification)
   */2 * * * * echo "Test cron: $(date)" >> /tmp/cron_test.log
   ```

3. **Vérifier les tâches programmées**
   ```bash
   crontab -l
   ```

4. **Surveiller l'exécution**
   ```bash
   # Attendre quelques minutes puis vérifier
   tail -f /tmp/cron_test.log
   
   # Vérifier les logs système
   grep CRON /var/log/syslog | tail -5
   ```

### Exercice 3.2 : Script de maintenance

**Objectif :** Créer et programmer un script de maintenance

1. **Créer le script de maintenance**
   ```bash
   nano maintenance_script.sh
   ```

   Contenu :
   ```bash
   #!/bin/bash
   
   # Script de maintenance automatique
   
   MAINTENANCE_LOG="/tmp/maintenance.log"
   
   echo "=== MAINTENANCE $(date) ===" >> "$MAINTENANCE_LOG"
   
   # Nettoyage des fichiers temporaires
   echo "Nettoyage des fichiers temporaires..." >> "$MAINTENANCE_LOG"
   find /tmp -type f -mtime +1 -name "*.tmp" -delete 2>/dev/null
   find /tmp -type f -mtime +1 -name "core.*" -delete 2>/dev/null
   
   # Mise à jour de la base de données locate
   echo "Mise à jour base locate..." >> "$MAINTENANCE_LOG"
   sudo updatedb 2>/dev/null || echo "Pas de droits sudo pour updatedb" >> "$MAINTENANCE_LOG"
   
   # Vérification espace disque
   echo "Vérification espace disque:" >> "$MAINTENANCE_LOG"
   df -h >> "$MAINTENANCE_LOG"
   
   # Rotation des logs de monitoring
   if [ -f "/tmp/system_monitor.log" ]; then
       if [ $(wc -l < /tmp/system_monitor.log) -gt 100 ]; then
           echo "Rotation du log de monitoring..." >> "$MAINTENANCE_LOG"
           tail -50 /tmp/system_monitor.log > /tmp/system_monitor.log.tmp
           mv /tmp/system_monitor.log.tmp /tmp/system_monitor.log
       fi
   fi
   
   echo "=== FIN MAINTENANCE $(date) ===" >> "$MAINTENANCE_LOG"
   echo "" >> "$MAINTENANCE_LOG"
   ```

2. **Programmer la maintenance hebdomadaire**
   ```bash
   # Ajouter à la crontab
   crontab -e
   
   # Ajouter cette ligne pour une maintenance chaque dimanche à 4h
   # 0 4 * * 0 /home/[votre_user]/tp-automatisation/maintenance_script.sh
   ```

---

## Partie 4 : Alias et personnalisation (15 min)

### Exercice 4.1 : Création d'alias utiles

**Objectif :** Personnaliser l'environnement avec des alias

1. **Éditer le fichier .bash_aliases**
   ```bash
   nano ~/.bash_aliases
   ```

2. **Ajouter des alias spécifiques à ce TP**
   ```bash
   # Alias pour le TP automatisation
   alias tpdir='cd ~/tp-automatisation'
   alias backup='~/tp-automatisation/backup_script.sh'
   alias monitor='~/tp-automatisation/system_monitor.sh'
   alias maintenance='~/tp-automatisation/maintenance_script.sh'
   
   # Alias pour surveiller les logs
   alias logmon='tail -f /tmp/system_monitor.log'
   alias logcron='tail -f /tmp/cron_test.log'
   alias logmaint='tail -f /tmp/maintenance.log'
   
   # Alias pour les tâches cron
   alias cronedit='crontab -e'
   alias cronlist='crontab -l'
   
   # Fonction pour créer rapidement un script
   newscript() {
       if [ -z "$1" ]; then
           echo "Usage: newscript nom_du_script"
           return 1
       fi
       
       cat > "$1" << 'EOF'
   #!/bin/bash
   
   # Nouveau script
   # Créé le: $(date)
   
   echo "Script $1 démarré à $(date)"
   
   # Votre code ici
   
   echo "Script $1 terminé à $(date)"
   EOF
       
       chmod +x "$1"
       echo "Script $1 créé et rendu exécutable"
   }
   ```

3. **Recharger la configuration**
   ```bash
   source ~/.bashrc
   ```

4. **Tester les alias**
   ```bash
   tpdir
   cronlist
   newscript test_script.sh
   ```

### Exercice 4.2 : Personnalisation de l'invite

**Objectif :** Personnaliser l'invite de commande

1. **Modifier le PS1 dans ~/.bashrc**
   ```bash
   # Ajouter à la fin de ~/.bashrc
   echo "" >> ~/.bashrc
   echo "# Personnalisation de l'invite pour le TP" >> ~/.bashrc
   echo 'PS1="[\t] \u@\h:\w $ "' >> ~/.bashrc
   ```

2. **Recharger et tester**
   ```bash
   source ~/.bashrc
   ```

---

## Vérifications finales et tests

### Tests de fonctionnement

1. **Vérifier que tous les scripts fonctionnent**
   ```bash
   cd ~/tp-automatisation
   ./backup_script.sh
   ./system_monitor.sh
   ./maintenance_script.sh
   ```

2. **Vérifier les tâches cron**
   ```bash
   # Attendre quelques minutes et vérifier
   cat /tmp/cron_test.log
   ```

3. **Tester les alias**
   ```bash
   tpdir
   backup
   monitor
   logmon
   ```

### Questions de validation

1. **Scripts** :
   - Vos scripts s'exécutent-ils sans erreur ?
   - Les logs sont-ils créés correctement ?
   - Les permissions sont-elles correctes ?

2. **Cron** :
   - Vos tâches cron apparaissent-elles dans `crontab -l` ?
   - Le fichier de test `/tmp/cron_test.log` se remplit-il ?
   - Voyez-vous vos tâches dans les logs système ?

3. **Alias** :
   - Vos alias fonctionnent-ils après redémarrage du terminal ?
   - La fonction `newscript` crée-t-elle correctement des scripts ?
   - Votre invite personnalisée s'affiche-t-elle ?

### Défis supplémentaires (optionnel)

1. **Améliorer le script de monitoring** :
   - Ajouter la vérification de la charge système
   - Envoyer des alertes par email (si configuré)
   - Créer des graphiques des tendances

2. **Créer un dashboard** :
   - Script qui affiche un résumé de tous les logs
   - Interface simple en mode texte
   - Rafraîchissement automatique

3. **Gestion avancée des sauvegardes** :
   - Sauvegardes incrémentales
   - Compression avec différents algorithmes
   - Sauvegarde vers un serveur distant

## Résumé des livrables

À la fin de ce TP, vous devriez avoir :

- ✅ 3 scripts bash fonctionnels
- ✅ Tâches cron programmées et opérationnelles  
- ✅ Fichier d'alias personnalisés
- ✅ Invite de commande personnalisée
- ✅ Logs de fonctionnement de tous les systèmes
- ✅ Système de maintenance automatique

**Fichiers créés :**
- `~/tp-automatisation/backup_script.sh`
- `~/tp-automatisation/system_monitor.sh` 
- `~/tp-automatisation/maintenance_script.sh`
- `~/.bash_aliases`
- Logs dans `/tmp/`

Ce TP vous donne une base solide pour l'automatisation sous Linux !