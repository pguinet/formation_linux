# Chapitre 8.3 : Tâches programmées (cron)

## Objectifs
- Comprendre le principe des tâches programmées sous Linux
- Découvrir la commande cron et sa syntaxe
- Apprendre à créer et gérer des tâches automatisées
- Savoir consulter et surveiller les tâches programmées

## 1. Introduction à cron

**Cron** est un service système Linux qui permet d'exécuter des commandes ou des scripts automatiquement à des moments programmés. Il est particulièrement utile pour :

- Les sauvegardes automatiques
- La maintenance système
- L'envoi de rapports
- Le nettoyage de fichiers temporaires
- Les mises à jour automatiques

### Le démon cron

Le service `crond` (ou `cron`) fonctionne en permanence et vérifie toutes les minutes s'il y a des tâches à exécuter.

```bash
# Vérifier le statut du service cron
systemctl status cron

# Démarrer le service cron (si nécessaire)
sudo systemctl start cron

# Activer cron au démarrage
sudo systemctl enable cron
```

## 2. La table cron (crontab)

Chaque utilisateur peut avoir sa propre **crontab** (table cron) qui contient ses tâches programmées.

### Gestion de la crontab

```bash
# Éditer sa crontab personnelle
crontab -e

# Lister ses tâches cron
crontab -l

# Supprimer toute sa crontab
crontab -r

# Éditer la crontab d'un autre utilisateur (root seulement)
sudo crontab -e -u nom_utilisateur
```

**Premier usage :**
À la première utilisation de `crontab -e`, le système vous demandera de choisir un éditeur (nano, vim, etc.).

## 3. Syntaxe des entrées cron

Une ligne crontab respecte ce format :
```
┌───────────── minute (0 - 59)
│ ┌─────────── heure (0 - 23)
│ │ ┌───────── jour du mois (1 - 31)
│ │ │ ┌─────── mois (1 - 12)
│ │ │ │ ┌───── jour de la semaine (0 - 7, 0 et 7 = dimanche)
│ │ │ │ │
* * * * * commande_à_exécuter
```

### Exemples de base

```bash
# Tous les jours à 6h30
30 6 * * * /usr/bin/backup.sh

# Tous les dimanches à 2h15
15 2 * * 0 /home/user/scripts/maintenance.sh

# Le 1er de chaque mois à minuit
0 0 1 * * /usr/local/bin/monthly-report.sh

# Toutes les 5 minutes
*/5 * * * * /usr/bin/check-status.sh

# Du lundi au vendredi à 9h
0 9 * * 1-5 /usr/bin/workday-start.sh
```

### Caractères spéciaux

| Caractère | Signification | Exemple |
|-----------|---------------|---------|
| `*` | Toutes les valeurs | `* * * * *` = toutes les minutes |
| `,` | Liste de valeurs | `0,30 * * * *` = à 0 et 30 minutes |
| `-` | Plage de valeurs | `9-17 * * *` = de 9h à 17h |
| `/` | Intervalle | `*/15 * * * *` = toutes les 15 minutes |

### Raccourcis spéciaux

```bash
# Au redémarrage du système
@reboot /home/user/startup.sh

# Une fois par an (1er janvier à minuit)
@yearly /usr/bin/annual-cleanup.sh

# Une fois par mois (1er du mois à minuit)
@monthly /usr/bin/monthly-backup.sh

# Une fois par semaine (dimanche à minuit)
@weekly /usr/bin/weekly-report.sh

# Une fois par jour (minuit)
@daily /usr/bin/daily-maintenance.sh

# Une fois par heure
@hourly /usr/bin/hourly-check.sh
```

## 4. Bonnes pratiques

### Chemins absolus
Toujours utiliser des chemins absolus dans les tâches cron :

```bash
# ✅ Bon
0 2 * * * /usr/bin/rsync -av /home/user/data/ /backup/

# ❌ À éviter
0 2 * * * rsync -av ~/data/ /backup/
```

### Variables d'environnement
Définir les variables nécessaires au début de la crontab :

```bash
# Variables d'environnement
PATH=/usr/bin:/bin:/usr/local/bin
SHELL=/bin/bash
HOME=/home/user

# Tâches
0 2 * * * /home/user/scripts/backup.sh
```

### Gestion des sorties

```bash
# Rediriger vers un fichier de log
0 2 * * * /usr/bin/backup.sh >> /var/log/backup.log 2>&1

# Supprimer toute sortie
0 2 * * * /usr/bin/silent-task.sh > /dev/null 2>&1

# Envoyer par email (si mail configuré)
0 2 * * * /usr/bin/backup.sh 2>&1 | mail -s "Backup Report" admin@example.com
```

## 5. Surveillance et débogage

### Logs système
Les exécutions cron sont enregistrées dans les logs système :

```bash
# Consulter les logs cron (Debian/Ubuntu)
sudo tail -f /var/log/cron.log

# Sur d'autres distributions
sudo journalctl -u cron -f

# Rechercher des erreurs
grep CRON /var/log/syslog
```

### Test d'une tâche

```bash
# Tester une commande avant de l'ajouter à cron
/chemin/vers/script.sh

# Vérifier qu'elle fonctionne avec l'environnement cron
env - /bin/sh -c '/chemin/vers/script.sh'
```

### Débogage courant

**Problème : Ma tâche ne s'exécute pas**
1. Vérifier la syntaxe cron avec `crontab -l`
2. S'assurer que le service cron fonctionne
3. Utiliser des chemins absolus
4. Vérifier les permissions du script
5. Consulter les logs

## 6. Exemples pratiques

### Sauvegarde quotidienne

```bash
# Sauvegarde à 3h du matin tous les jours
0 3 * * * /usr/bin/rsync -av --delete /home/user/documents/ /backup/documents/
```

### Nettoyage des fichiers temporaires

```bash
# Nettoyer les fichiers temporaires chaque dimanche à 1h
0 1 * * 0 /usr/bin/find /tmp -type f -mtime +7 -delete
```

### Surveillance disque

```bash
# Vérifier l'espace disque toutes les heures
0 * * * * /usr/bin/df -h | /usr/bin/mail -s "Disk Usage Report" admin@localhost
```

### Script de maintenance

```bash
# Maintenance hebdomadaire le samedi à 4h
0 4 * * 6 /home/user/scripts/weekly-maintenance.sh
```

Contenu de `/home/user/scripts/weekly-maintenance.sh` :
```bash
#!/bin/bash
# Script de maintenance hebdomadaire

echo "$(date): Début maintenance" >> /var/log/maintenance.log

# Nettoyage cache
apt-get clean

# Mise à jour de la base locate
updatedb

# Vérification système
fsck -n /dev/sda1 >> /var/log/maintenance.log

echo "$(date): Fin maintenance" >> /var/log/maintenance.log
```

## 7. Sécurité et limitations

### Permissions

```bash
# Les fichiers de script doivent être exécutables
chmod +x /home/user/scripts/backup.sh

# Éviter les permissions trop larges
chmod 750 /home/user/scripts/backup.sh  # rwxr-x---
```

### Limitation d'accès

```bash
# Seuls certains utilisateurs peuvent utiliser cron
# Fichier /etc/cron.allow (si existe, seuls ces utilisateurs)
# Fichier /etc/cron.deny (utilisateurs interdits)

# Voir qui peut utiliser cron
ls -l /etc/cron.allow /etc/cron.deny 2>/dev/null
```

### Environnement sécurisé
Cron s'exécute avec un environnement minimal. Toujours :
- Utiliser des chemins absolus
- Définir les variables nécessaires
- Tester les scripts en environnement similaire

## Points clés à retenir

- **cron** automatise l'exécution de tâches selon un planning
- **crontab -e** pour éditer, **crontab -l** pour lister
- Syntaxe : `minute heure jour mois jour_semaine commande`
- Toujours utiliser des **chemins absolus**
- Consulter les **logs système** pour le débogage
- Tester les scripts **avant** de les programmer
- Gérer les **sorties** (logs, redirection)

## Exercice pratique

1. Créer un script qui affiche la date dans un fichier
2. Le programmer pour qu'il s'exécute toutes les 2 minutes
3. Observer les résultats et les logs
4. Modifier pour une exécution quotidienne à 8h