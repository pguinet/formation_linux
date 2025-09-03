# Chapitre 8.3 : Taches programmees (cron)

## Objectifs
- Comprendre le principe des taches programmees sous Linux
- Decouvrir la commande cron et sa syntaxe
- Apprendre a creer et gerer des taches automatisees
- Savoir consulter et surveiller les taches programmees

## 1. Introduction a cron

**Cron** est un service systeme Linux qui permet d'executer des commandes ou des scripts automatiquement a des moments programmes. Il est particulierement utile pour :

- Les sauvegardes automatiques
- La maintenance systeme
- L'envoi de rapports
- Le nettoyage de fichiers temporaires
- Les mises a jour automatiques

### Le demon cron

Le service `crond` (ou `cron`) fonctionne en permanence et verifie toutes les minutes s'il y a des taches a executer.

```bash
# Verifier le statut du service cron
systemctl status cron

# Demarrer le service cron (si necessaire)
sudo systemctl start cron

# Activer cron au demarrage
sudo systemctl enable cron
```

## 2. La table cron (crontab)

Chaque utilisateur peut avoir sa propre **crontab** (table cron) qui contient ses taches programmees.

### Gestion de la crontab

```bash
# Editer sa crontab personnelle
crontab -e

# Lister ses taches cron
crontab -l

# Supprimer toute sa crontab
crontab -r

# Editer la crontab d'un autre utilisateur (root seulement)
sudo crontab -e -u nom_utilisateur
```

**Premier usage :**
A la premiere utilisation de `crontab -e`, le systeme vous demandera de choisir un editeur (nano, vim, etc.).

## 3. Syntaxe des entrees cron

Une ligne crontab respecte ce format :
```
+------------- minute (0 - 59)
| +----------- heure (0 - 23)
| | +--------- jour du mois (1 - 31)
| | | +------- mois (1 - 12)
| | | | +----- jour de la semaine (0 - 7, 0 et 7 = dimanche)
| | | | |
* * * * * commande_a_executer
```

### Exemples de base

```bash
# Tous les jours a 6h30
30 6 * * * /usr/bin/backup.sh

# Tous les dimanches a 2h15
15 2 * * 0 /home/user/scripts/maintenance.sh

# Le 1er de chaque mois a minuit
0 0 1 * * /usr/local/bin/monthly-report.sh

# Toutes les 5 minutes
*/5 * * * * /usr/bin/check-status.sh

# Du lundi au vendredi a 9h
0 9 * * 1-5 /usr/bin/workday-start.sh
```

### Caracteres speciaux

| Caractere | Signification | Exemple |
|-----------|---------------|---------|
| `*` | Toutes les valeurs | `* * * * *` = toutes les minutes |
| `,` | Liste de valeurs | `0,30 * * * *` = a 0 et 30 minutes |
| `-` | Plage de valeurs | `9-17 * * *` = de 9h a 17h |
| `/` | Intervalle | `*/15 * * * *` = toutes les 15 minutes |

### Raccourcis speciaux

```bash
# Au redemarrage du systeme
@reboot /home/user/startup.sh

# Une fois par an (1er janvier a minuit)
@yearly /usr/bin/annual-cleanup.sh

# Une fois par mois (1er du mois a minuit)
@monthly /usr/bin/monthly-backup.sh

# Une fois par semaine (dimanche a minuit)
@weekly /usr/bin/weekly-report.sh

# Une fois par jour (minuit)
@daily /usr/bin/daily-maintenance.sh

# Une fois par heure
@hourly /usr/bin/hourly-check.sh
```

## 4. Bonnes pratiques

### Chemins absolus
Toujours utiliser des chemins absolus dans les taches cron :

```bash
# [OK] Bon
0 2 * * * /usr/bin/rsync -av /home/user/data/ /backup/

# [NOK] A eviter
0 2 * * * rsync -av ~/data/ /backup/
```

### Variables d'environnement
Definir les variables necessaires au debut de la crontab :

```bash
# Variables d'environnement
PATH=/usr/bin:/bin:/usr/local/bin
SHELL=/bin/bash
HOME=/home/user

# Taches
0 2 * * * /home/user/scripts/backup.sh
```

### Gestion des sorties

```bash
# Rediriger vers un fichier de log
0 2 * * * /usr/bin/backup.sh >> /var/log/backup.log 2>&1

# Supprimer toute sortie
0 2 * * * /usr/bin/silent-task.sh > /dev/null 2>&1

# Envoyer par email (si mail configure)
0 2 * * * /usr/bin/backup.sh 2>&1 | mail -s "Backup Report" admin@example.com
```

## 5. Surveillance et debogage

### Logs systeme
Les executions cron sont enregistrees dans les logs systeme :

```bash
# Consulter les logs cron (Debian/Ubuntu)
sudo tail -f /var/log/cron.log

# Sur d'autres distributions
sudo journalctl -u cron -f

# Rechercher des erreurs
grep CRON /var/log/syslog
```

### Test d'une tache

```bash
# Tester une commande avant de l'ajouter a cron
/chemin/vers/script.sh

# Verifier qu'elle fonctionne avec l'environnement cron
env - /bin/sh -c '/chemin/vers/script.sh'
```

### Debogage courant

**Probleme : Ma tache ne s'execute pas**
1. Verifier la syntaxe cron avec `crontab -l`
2. S'assurer que le service cron fonctionne
3. Utiliser des chemins absolus
4. Verifier les permissions du script
5. Consulter les logs

## 6. Exemples pratiques

### Sauvegarde quotidienne

```bash
# Sauvegarde a 3h du matin tous les jours
0 3 * * * /usr/bin/rsync -av --delete /home/user/documents/ /backup/documents/
```

### Nettoyage des fichiers temporaires

```bash
# Nettoyer les fichiers temporaires chaque dimanche a 1h
0 1 * * 0 /usr/bin/find /tmp -type f -mtime +7 -delete
```

### Surveillance disque

```bash
# Verifier l'espace disque toutes les heures
0 * * * * /usr/bin/df -h | /usr/bin/mail -s "Disk Usage Report" admin@localhost
```

### Script de maintenance

```bash
# Maintenance hebdomadaire le samedi a 4h
0 4 * * 6 /home/user/scripts/weekly-maintenance.sh
```

Contenu de `/home/user/scripts/weekly-maintenance.sh` :
```bash
#!/bin/bash
# Script de maintenance hebdomadaire

echo "$(date): Debut maintenance" >> /var/log/maintenance.log

# Nettoyage cache
apt-get clean

# Mise a jour de la base locate
updatedb

# Verification systeme
fsck -n /dev/sda1 >> /var/log/maintenance.log

echo "$(date): Fin maintenance" >> /var/log/maintenance.log
```

## 7. Securite et limitations

### Permissions

```bash
# Les fichiers de script doivent etre executables
chmod +x /home/user/scripts/backup.sh

# Eviter les permissions trop larges
chmod 750 /home/user/scripts/backup.sh  # rwxr-x---
```

### Limitation d'acces

```bash
# Seuls certains utilisateurs peuvent utiliser cron
# Fichier /etc/cron.allow (si existe, seuls ces utilisateurs)
# Fichier /etc/cron.deny (utilisateurs interdits)

# Voir qui peut utiliser cron
ls -l /etc/cron.allow /etc/cron.deny 2>/dev/null
```

### Environnement securise
Cron s'execute avec un environnement minimal. Toujours :
- Utiliser des chemins absolus
- Definir les variables necessaires
- Tester les scripts en environnement similaire

## Points cles a retenir

- **cron** automatise l'execution de taches selon un planning
- **crontab -e** pour editer, **crontab -l** pour lister
- Syntaxe : `minute heure jour mois jour_semaine commande`
- Toujours utiliser des **chemins absolus**
- Consulter les **logs systeme** pour le debogage
- Tester les scripts **avant** de les programmer
- Gerer les **sorties** (logs, redirection)

## Exercice pratique

1. Creer un script qui affiche la date dans un fichier
2. Le programmer pour qu'il s'execute toutes les 2 minutes
3. Observer les resultats et les logs
4. Modifier pour une execution quotidienne a 8h