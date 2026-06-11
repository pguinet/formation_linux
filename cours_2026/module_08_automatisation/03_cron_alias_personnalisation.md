# Chapitre 8.3 — cron, alias et personnalisation

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - programmer des tâches automatiques avec `cron` ;
> - créer des alias pour raccourcir vos commandes fréquentes ;
> - rendre vos alias permanents en les ajoutant dans `~/.bashrc` ;
> - recharger votre configuration sans fermer le terminal.
>
> **Durée en séance** : ~30 min.

---

## Programmer une tâche avec cron

### Principe

**cron** est un service qui tourne en permanence en arrière-plan.
Toutes les minutes, il vérifie si une tâche planifiée doit être lancée.
Chaque utilisateur dispose de sa propre liste de tâches, appelée **crontab**.

Pour vérifier que le service est actif :

```bash
systemctl status cron
```

### Éditer et consulter sa crontab

```bash
# Ouvrir la crontab dans l'éditeur (nano par défaut)
crontab -e

# Afficher les tâches programmées
crontab -l

# Supprimer toute la crontab (attention, irréversible)
crontab -r
```

À la première utilisation de `crontab -e`, le système demande de choisir
un éditeur de texte. Choisissez nano si vous débutez.

### Syntaxe des cinq champs

Chaque ligne de la crontab suit ce schéma :

```
+------------- minute        (0 - 59)
| +----------- heure         (0 - 23)
| | +--------- jour du mois  (1 - 31)
| | | +------- mois          (1 - 12)
| | | | +----- jour semaine  (0 - 7, 0 et 7 = dimanche)
| | | | |
* * * * *   commande_a_executer
```

Les quatre caractères spéciaux les plus utiles :

| Caractère | Signification          | Exemple                         |
|-----------|------------------------|---------------------------------|
| `*`       | toutes les valeurs     | `* * * * *` = chaque minute     |
| `,`       | liste de valeurs       | `0,30 8 * * *` = 8h00 et 8h30   |
| `-`       | plage de valeurs       | `1-5` dans le 5e champ = lundi à vendredi |
| `/`       | intervalle             | `*/15` dans le 1er champ = toutes les 15 min |

### Deux exemples commentés

**Exemple 1 — tous les jours à 8h00**

```
0 8 * * *   /home/alice/scripts/sauvegarde.sh >> /home/alice/logs/sauvegarde.log 2>&1
```

Décomposition :
- `0 8` : à la minute 0 de l'heure 8, soit 8h00 pile.
- `* * *` : peu importe le jour du mois, le mois, le jour de la semaine.
- Chemin absolu obligatoire : cron démarre avec un environnement minimal,
  il ne connaît pas votre répertoire personnel.
- `>> ... 2>&1` : toutes les sorties (normales et erreurs) sont ajoutées au
  fichier de log. Sans cette redirection, les erreurs partent en silence ou
  déclenchent un email local souvent ignoré.

**Exemple 2 — toutes les 15 minutes**

```
*/15 * * * *   /home/alice/scripts/surveillance.sh > /dev/null 2>&1
```

Décomposition :
- `*/15` : toutes les 15 minutes (0, 15, 30, 45).
- `> /dev/null 2>&1` : on ignore volontairement toute sortie ; utile quand le
  script produit lui-même ses propres logs.

### Bonne pratique : chemins absolus

Cron ignore votre `PATH` habituel. Toujours écrire le chemin complet :

```bash
# Correct
0 8 * * *   /usr/bin/find /tmp -name "*.tmp" -mtime +7 -delete

# Incorrect : find sera introuvable dans l'environnement de cron
0 8 * * *   find /tmp -name "*.tmp" -mtime +7 -delete
```

Pour connaître le chemin absolu d'une commande : `which find` répond
`/usr/bin/find`.

---

## Les alias

### Qu'est-ce qu'un alias ?

Un alias est un raccourci : vous donnez un nom court à une commande que vous
tapez souvent, avec toujours les mêmes options.

```bash
# Déclarer un alias
alias ll='ls -la'

# Utiliser l'alias
ll
```

À partir de là, taper `ll` revient à taper `ls -la`.

### Voir et supprimer ses alias

```bash
# Lister tous les alias de la session
alias

# Détail d'un alias particulier
alias ll

# Supprimer un alias (pour la session courante)
unalias ll
```

### Limite importante : la durée de vie d'un alias

Un alias créé directement dans le terminal **disparaît à la fermeture de la
session**. Il n'est valable que pour la session en cours.

```bash
# Cet alias sera perdu dès que vous fermerez le terminal
alias maj='sudo apt update && sudo apt upgrade'
```

Pour le conserver, il faut l'écrire dans un fichier de configuration.

---

## Rendre vos alias permanents : ~/.bashrc

### Où écrire ses alias

Le fichier `~/.bashrc` est lu par le shell à chaque ouverture d'un nouveau
terminal (voir chapitre 6.3 pour les variables d'environnement, qui se
configurent au même endroit). C'est là qu'on ajoute ses alias permanents.

```bash
# Ouvrir .bashrc avec nano
nano ~/.bashrc
```

Ajoutez vos alias à la fin du fichier, dans une section clairement
identifiée :

```bash
# --- Mes alias personnels ---
alias ll='ls -la'
alias ..='cd ..'
alias maj='sudo apt update && sudo apt upgrade'
alias df='df -h'
alias free='free -h'
```

Sauvegardez (`Ctrl+O`, `Entrée`, `Ctrl+X` avec nano).

### Recharger la configuration

La modification ne prend effet qu'après rechargement. Deux façons équivalentes :

```bash
# Méthode 1 : source explicite
source ~/.bashrc

# Méthode 2 : raccourci identique
. ~/.bashrc
```

Vous n'avez pas besoin de fermer le terminal.

### Quelques alias pratiques à titre d'exemple

```bash
# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# Listing
alias ll='ls -la'
alias lt='ls -ltr'     # tri par date, le plus récent en bas

# Sécurité (demande confirmation avant suppression ou écrasement)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Lecture de l'espace disque en format lisible
alias df='df -h'
alias free='free -h'

# Raccourcis cron
alias cronedit='crontab -e'
alias cronlist='crontab -l'
```

---

## L'essentiel

| Commande | Usage type |
|----------|-----------|
| `crontab -e` | Éditer ses tâches planifiées |
| `crontab -l` | Lister ses tâches planifiées |
| `crontab -r` | Supprimer toute la crontab |
| `alias nom='cmd'` | Créer un alias pour la session courante |
| `alias` | Voir tous les alias actifs |
| `unalias nom` | Supprimer un alias |
| `nano ~/.bashrc` | Éditer sa configuration shell (alias permanents) |
| `source ~/.bashrc` | Recharger la configuration sans fermer le terminal |

---

## Pour aller plus loin

### La crontab système

En dehors de la crontab de chaque utilisateur, il existe des répertoires
système gérés par root. Les fichiers déposés dans `/etc/cron.d/` sont lus
directement par le démon cron. La syntaxe est identique, avec un champ
supplémentaire pour le nom d'utilisateur :

```
# Syntaxe dans /etc/cron.d/
minute heure jour mois jour_semaine   utilisateur   commande

# Exemple : sauvegarde quotidienne à 3h, lancée en tant que www-data
0 3 * * *   www-data   /opt/app/backup.sh >> /var/log/app-backup.log 2>&1
```

Les répertoires `/etc/cron.daily/`, `/etc/cron.weekly/` et
`/etc/cron.monthly/` accueillent des scripts exécutés automatiquement
par le système à la fréquence indiquée par leur nom.

### anacron

`cron` suppose que la machine tourne en permanence. Si elle est éteinte à
l'heure programmée, la tâche est simplement manquée.

`anacron` est prévu pour les machines qui ne fonctionnent pas en continu
(postes de travail). Il garantit qu'une tâche journalière ou hebdomadaire
sera exécutée au prochain démarrage si elle a été ratée. Les distributions
modernes (Debian, Ubuntu) l'utilisent pour leurs propres tâches de
maintenance.

### Timers systemd

Sur les systèmes récents, les **timers systemd** constituent une alternative
à cron. Ils offrent plus de contrôle (dépendances, journalisation intégrée,
activation au démarrage) mais leur configuration est plus complexe. Pour des
besoins simples, `crontab -e` reste la solution la plus directe. La commande
`systemctl list-timers` permet de voir les timers actifs sur votre système.

### Personnaliser son prompt PS1

La variable `PS1` définit l'apparence de votre invite de commande (voir
chapitre 6.3 pour les variables d'environnement). Elle se modifie dans
`~/.bashrc` :

```bash
# Invite avec heure, utilisateur, machine et répertoire courant
PS1='[\t] \u@\h:\w $ '
```

Codes disponibles : `\u` (utilisateur), `\h` (machine), `\w` (répertoire
courant), `\t` (heure), `\$` ($ ou # selon les droits).

---

## Exercices

### Exercice 1 — Explorer sa crontab

1. Affichez vos tâches cron actuelles :
   ```bash
   crontab -l
   ```
2. Notez le résultat (peut-être vide si c'est votre première utilisation).

---

### Exercice 2 — Créer une tâche de test

1. Ouvrez votre crontab :
   ```bash
   crontab -e
   ```
2. Ajoutez une ligne qui écrit la date dans un fichier toutes les 2 minutes :
   ```
   */2 * * * *   /bin/date >> /tmp/test_cron.log 2>&1
   ```
3. Attendez 2 à 4 minutes puis vérifiez :
   ```bash
   cat /tmp/test_cron.log
   ```
4. Supprimez cette ligne de test une fois que vous avez confirmé que cron
   fonctionne.

---

### Exercice 3 — Programmer le script de sauvegarde

Vous avez créé un script de sauvegarde au chapitre 8.2. Programmez son
exécution automatique tous les jours à 8h00.

1. Ouvrez votre crontab :
   ```bash
   crontab -e
   ```
2. Ajoutez la ligne suivante en remplaçant `alice` par votre nom
   d'utilisateur :
   ```
   0 8 * * *   /home/alice/scripts/sauvegarde.sh >> /home/alice/logs/sauvegarde.log 2>&1
   ```
3. Créez le répertoire de logs si besoin :
   ```bash
   mkdir -p ~/logs
   ```
4. Vérifiez que la tâche est bien enregistrée :
   ```bash
   crontab -l
   ```

---

### Exercice 4 — Créer trois alias utiles

Créez, pour la session courante, les trois alias suivants :

1. `ll` qui lance `ls -la`
2. `maj` qui lance `sudo apt update && sudo apt upgrade`
3. `cronlist` qui affiche vos tâches cron

Testez chacun d'eux.

---

### Exercice 5 — Rendre vos alias permanents

1. Ouvrez `~/.bashrc` :
   ```bash
   nano ~/.bashrc
   ```
2. Ajoutez à la fin du fichier les trois alias de l'exercice 4, dans une
   section intitulée `# Mes alias`.
3. Sauvegardez et rechargez la configuration :
   ```bash
   source ~/.bashrc
   ```
4. Vérifiez que les alias sont toujours disponibles :
   ```bash
   alias
   ```
5. Ouvrez un nouveau terminal et vérifiez que les alias sont présents.

---

### Exercice 6 — Alias de surveillance des logs

1. Ajoutez dans `~/.bashrc` un alias `logcron` qui affiche les dernières
   lignes de `/tmp/test_cron.log` :
   ```bash
   alias logcron='tail -f /tmp/test_cron.log'
   ```
2. Rechargez la configuration et testez l'alias.
3. Quittez la surveillance avec `Ctrl+C`.

---

### Solutions

#### Solution exercice 1

```bash
crontab -l
```

Si aucune tâche n'est encore définie, le système affiche le message
`no crontab for <utilisateur>`. C'est normal : cela confirme simplement
que la crontab est vide pour cet utilisateur.

#### Solution exercice 2

```bash
# Ajout dans la crontab
crontab -e
# Ajouter la ligne :
# */2 * * * *   /bin/date >> /tmp/test_cron.log 2>&1

# Après quelques minutes
cat /tmp/test_cron.log
# Résultat attendu (plusieurs lignes de ce type) :
# mer. 11 juin 2026 08:02:01 CEST
# mer. 11 juin 2026 08:04:01 CEST
```

#### Solution exercice 3

```bash
crontab -e
```

Ligne à ajouter (adapter le chemin à votre utilisateur) :

```
0 8 * * *   /home/alice/scripts/sauvegarde.sh >> /home/alice/logs/sauvegarde.log 2>&1
```

Vérification :

```bash
mkdir -p ~/logs
crontab -l
```

#### Solution exercice 4

```bash
alias ll='ls -la'
alias maj='sudo apt update && sudo apt upgrade'
alias cronlist='crontab -l'

# Test
ll
cronlist
```

#### Solution exercice 5

```bash
nano ~/.bashrc
```

Section à ajouter en fin de fichier :

```bash
# Mes alias
alias ll='ls -la'
alias maj='sudo apt update && sudo apt upgrade'
alias cronlist='crontab -l'
```

Rechargement et vérification :

```bash
source ~/.bashrc
alias | grep -E "ll|maj|cronlist"
```

#### Solution exercice 6

```bash
nano ~/.bashrc
```

Ajouter :

```bash
alias logcron='tail -f /tmp/test_cron.log'
```

Puis :

```bash
source ~/.bashrc
logcron
# Ctrl+C pour quitter
```
