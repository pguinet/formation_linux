# Chapitre 7.2 — Services et logs

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - expliquer ce qu'est un service système et pourquoi il est utile ;
> - démarrer, arrêter et surveiller un service avec `systemctl` ;
> - distinguer « démarrer un service » et « l'activer au démarrage » ;
> - consulter les logs d'un service avec `journalctl` et lire les fichiers de `/var/log`.
>
> **Durée en séance** : ~30 min.

---

## Qu'est-ce qu'un service ?

Un **service** (ou démon, en anglais *daemon*) est un programme qui tourne en permanence en
arrière-plan, sans fenêtre visible, pour rendre une fonction disponible à tout moment.

Exemples courants sur une Debian fraîchement installée :

- **ssh** — accepte les connexions entrantes en SSH ;
- **cron** — exécute des tâches planifiées à intervalles réguliers ;
- **rsyslog** — collecte et écrit les messages de journalisation.

Ces programmes démarrent automatiquement au démarrage de la machine et restent actifs jusqu'à
l'extinction. Sur les distributions Linux modernes, c'est **systemd** (PID 1) qui les gère.
systemd démarre les services dans le bon ordre, les surveille et les redémarre en cas de plantage.

---

## Gérer les services avec systemctl

`systemctl` est la commande qui permet d'interroger et de piloter systemd.

### Connaître l'état d'un service

```bash
systemctl status ssh
```

La sortie affiche :

- si le service est actif (*active (running)*) ou arrêté (*inactive*) ;
- depuis combien de temps il tourne ;
- les dernières lignes de son journal.

### Démarrer, arrêter, redémarrer

```bash
sudo systemctl start  ssh      # démarre maintenant
sudo systemctl stop   ssh      # arrête maintenant
sudo systemctl restart ssh     # arrête puis redémarre
```

Ces actions sont **immédiates mais temporaires** : elles ne survivent pas à un redémarrage de la
machine. Au prochain démarrage, le service reprendra l'état qu'il avait avant votre commande.

### Activer ou désactiver au démarrage

```bash
sudo systemctl enable  ssh     # sera lancé à chaque démarrage
sudo systemctl disable ssh     # ne sera plus lancé automatiquement
```

> **Distinction clé** : `start` agit *maintenant* ; `enable` agit *au prochain démarrage*.
> Les deux commandes sont indépendantes. Un service peut être démarré sans être activé, et
> inversement.
>
> Pour tout faire d'un coup :
> ```bash
> sudo systemctl enable --now ssh     # active + démarre
> sudo systemctl disable --now ssh    # désactive + arrête
> ```

### Vérifier le statut en une ligne

```bash
systemctl is-active  ssh     # affiche "active" ou "inactive"
systemctl is-enabled ssh     # affiche "enabled" ou "disabled"
```

Ces formes courtes sont pratiques dans les scripts.

---

## Lire les logs

### Le journal systemd : journalctl

Depuis que systemd gère les services, tous leurs messages sont stockés dans un journal centralisé,
interrogeable avec `journalctl`.

**Logs d'un service particulier :**

```bash
journalctl -u ssh
```

L'option `-u` (unit) filtre sur le service voulu. La sortie s'ouvre dans un paginateur
(quittez avec `q`).

**Suivre les logs en direct :**

```bash
journalctl -u ssh -f
```

L'option `-f` (follow) affiche les nouvelles lignes au fil de l'eau, comme `tail -f` (voir
chapitre 4.1). Utilisez `Ctrl+C` pour quitter.

**Afficher les N dernières lignes :**

```bash
journalctl -u ssh -n 20
```

**Filtrer par priorité (erreurs uniquement) :**

```bash
journalctl -u ssh -p err
```

Les niveaux vont de `debug` (le plus verbeux) à `emerg` (le plus critique). Pour le diagnostic
quotidien, `err` et `warning` sont les plus utiles.

**Tous les services depuis le dernier démarrage :**

```bash
journalctl -b
```

**Suivre tous les services en direct :**

```bash
journalctl -f
```

### Les fichiers de /var/log

Certains services (notamment ceux antérieurs à systemd, ou configurés pour écrire sur disque) écrivent
dans des fichiers texte sous `/var/log`. Ces fichiers se lisent avec les outils du module 4 —
`cat`, `less`, `tail -f`, `grep` (voir chapitre 4.1 pour les outils de lecture).

Fichiers courants sur Debian/Ubuntu :

| Fichier                  | Contenu                                         |
|--------------------------|-------------------------------------------------|
| `/var/log/syslog`        | Messages système généraux                       |
| `/var/log/auth.log`      | Connexions, sudo, échecs d'authentification     |
| `/var/log/kern.log`      | Messages du noyau                               |
| `/var/log/dpkg.log`      | Installations et mises à jour de paquets        |

Exemples d'utilisation fréquente :

```bash
# Suivre le journal système en direct
tail -f /var/log/syslog

# Retrouver ses propres connexions SSH
grep "session opened" /var/log/auth.log | grep "$(whoami)"

# Lister les échecs d'authentification récents
grep "Failed password" /var/log/auth.log | tail -20
```

> **Note** : sur les systèmes récents, `/var/log/syslog` peut ne pas exister si rsyslog n'est pas
> installé. Dans ce cas, `journalctl` est le seul outil disponible.

---

## L'essentiel

| Commande                               | Usage type                                        |
|----------------------------------------|---------------------------------------------------|
| `systemctl status <service>`           | État détaillé d'un service                        |
| `sudo systemctl start <service>`       | Démarrer un service immédiatement                 |
| `sudo systemctl stop <service>`        | Arrêter un service immédiatement                  |
| `sudo systemctl restart <service>`     | Redémarrer un service                             |
| `sudo systemctl enable <service>`      | Activer au démarrage                              |
| `sudo systemctl disable <service>`     | Désactiver au démarrage                           |
| `sudo systemctl enable --now <service>`| Activer et démarrer en une commande               |
| `systemctl is-active <service>`        | Vérifier si actif (pour scripts)                  |
| `systemctl is-enabled <service>`       | Vérifier si activé au démarrage                   |
| `journalctl -u <service>`              | Consulter les logs d'un service                   |
| `journalctl -u <service> -f`           | Suivre les logs en direct                         |
| `journalctl -u <service> -n 20`        | Afficher les 20 dernières lignes de log           |
| `journalctl -p err`                    | Filtrer sur les erreurs de tous les services      |
| `journalctl -b`                        | Tous les logs depuis le dernier démarrage         |
| `tail -f /var/log/syslog`              | Suivre le journal système traditionnel            |
| `grep "Failed password" /var/log/auth.log` | Chercher les échecs de connexion              |

---

## Pour aller plus loin

### Anatomie d'une unité systemd

Les services sont décrits par des fichiers texte appelés **unités** (extension `.service`).
Vous en trouverez dans `/lib/systemd/system/`. Celui de SSH donne une bonne idée de la structure :

```ini
[Unit]
Description=OpenBSD Secure Shell server
After=network.target auditd.service

[Service]
Type=notify
ExecStart=/usr/sbin/sshd -D
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Trois sections :

- `[Unit]` — description et ordre de démarrage ;
- `[Service]` — commande à lancer, politique de redémarrage automatique ;
- `[Install]` — à quelle cible systemd ce service est rattaché.

Le champ `After=network.target` garantit que le réseau est prêt avant que SSH ne tente
de s'y attacher.

### Lister toutes les unités

```bash
systemctl list-units --type=service          # services actuellement chargés
systemctl list-units --type=service --state=failed   # services en échec
systemctl list-unit-files --type=service     # état de tous les fichiers .service
```

### Les messages du noyau : dmesg

`dmesg` affiche le tampon de messages du noyau, utile lors d'un diagnostic matériel ou d'un
problème au démarrage :

```bash
dmesg | tail -30         # derniers messages noyau
dmesg | grep -i error    # filtrer sur les erreurs
```

Sur les systèmes récents, `journalctl -k` (kernel) produit le même résultat avec les horodatages
systemd.

### Rotation des logs avec logrotate

Pour éviter que les fichiers de `/var/log` n'occupent tout l'espace disque, **logrotate** les
compresse et les archive automatiquement selon une fréquence configurable.

La configuration se trouve dans `/etc/logrotate.d/`. Exemple pour syslog :

```
/var/log/syslog {
    daily          # rotation quotidienne
    rotate 7       # conserver 7 archives
    compress       # compresser les archives
    missingok      # ne pas signaler d'erreur si le fichier est absent
    notifempty     # ne pas tourner si le fichier est vide
    postrotate
        /bin/kill -HUP $(cat /var/run/rsyslogd.pid)
    endscript
}
```

Pour forcer une rotation manuelle (utile pour tester) :

```bash
sudo logrotate -f /etc/logrotate.d/rsyslog
```

Le journal systemd a son propre mécanisme de nettoyage :

```bash
journalctl --disk-usage               # espace occupé par le journal
sudo journalctl --vacuum-time=30d     # supprimer les entrées de plus de 30 jours
sudo journalctl --vacuum-size=200M    # limiter le journal à 200 Mo
```

---

## Exercices

### Exercice 1 — État du service SSH

Affichez l'état complet du service SSH sur votre machine.

1. Quelle commande utilisez-vous ?
2. Le service est-il actif ? Est-il activé au démarrage ?
3. Depuis combien de temps tourne-t-il ?

---

### Exercice 2 — Démarrer/activer manuellement

Sur votre VM de TP, le service `cron` est peut-être déjà actif. Procédez dans l'ordre :

1. Vérifiez son état avec `systemctl status cron`.
2. Arrêtez-le.
3. Vérifiez qu'il est bien arrêté (`systemctl is-active cron`).
4. Redémarrez-le.
5. Vérifiez qu'il est à nouveau actif.

---

### Exercice 3 — Logs SSH en direct

1. Ouvrez un premier terminal et lancez `journalctl -u ssh -f`.
2. Dans un second terminal, ouvrez une nouvelle connexion SSH vers votre VM (ou utilisez
   `ssh localhost` si SSH est configuré localement).
3. Observez les nouvelles lignes qui apparaissent dans le premier terminal.
4. Déconnectez-vous de la seconde session. Quelles lignes nouvelles apparaissent ?

---

### Exercice 4 — Retrouver ses connexions dans auth.log

1. Affichez les 30 dernières lignes de `/var/log/auth.log` avec `tail`.
2. Filtrez uniquement les lignes contenant votre nom d'utilisateur avec `grep`.
3. Parmi ces lignes, identifiez celles indiquant une ouverture de session
   (`session opened`).

---

### Exercice 5 — Différence enable / start

1. Désactivez le service `cron` au démarrage : `sudo systemctl disable cron`.
2. Vérifiez avec `systemctl is-enabled cron` — que lisez-vous ?
3. Le service est-il toujours en train de tourner ? Vérifiez avec `systemctl is-active cron`.
4. Réactivez-le : `sudo systemctl enable cron`.
5. Concluez : qu'est-ce que `disable` fait et ne fait pas ?

---

### Exercice 6 — Filtrer les erreurs système

1. Affichez toutes les entrées de priorité `err` depuis le dernier démarrage :
   `journalctl -b -p err`.
2. Comparez avec `journalctl -b -p warning`. Y a-t-il plus de lignes ? Pourquoi ?
3. Limiter l'affichage aux 10 dernières lignes avec `-n 10`.

---

### Solutions

#### Exercice 1

```bash
systemctl status ssh
```

La sortie indique `active (running)` si le service tourne. La ligne `Loaded:` précise si le service
est `enabled` ou `disabled`. Le champ `Active:` indique depuis combien de temps il est en cours
d'exécution.

---

#### Exercice 2

```bash
systemctl status cron              # état initial
sudo systemctl stop cron           # arrêt
systemctl is-active cron           # doit afficher "inactive"
sudo systemctl start cron          # redémarrage
systemctl is-active cron           # doit afficher "active"
```

---

#### Exercice 3

Dans le premier terminal :

```bash
journalctl -u ssh -f
```

À chaque connexion entrante, systemd enregistre une ligne du type :

```
Accepted publickey for alice from 192.168.1.10 port 54321 ssh2
```

À la déconnexion, une ligne `Disconnected from user alice ...` apparaît. Ces messages permettent
de tracer qui s'est connecté, depuis quelle adresse et à quelle heure.

---

#### Exercice 4

```bash
tail -30 /var/log/auth.log
grep "$(whoami)" /var/log/auth.log | tail -20
grep "session opened" /var/log/auth.log | grep "$(whoami)"
```

Chaque ouverture de session apparaît sous la forme :

```
pam_unix(sshd:session): session opened for user alice by (uid=0)
```

---

#### Exercice 5

```bash
sudo systemctl disable cron
systemctl is-enabled cron          # affiche "disabled"
systemctl is-active cron           # affiche toujours "active"
sudo systemctl enable cron
```

**Conclusion** : `disable` retire simplement le lien symbolique qui provoque le lancement
automatique au démarrage. Il ne touche pas au processus en cours d'exécution. Le service
continue donc à tourner jusqu'au prochain arrêt ou jusqu'à un `systemctl stop` explicite.

---

#### Exercice 6

```bash
journalctl -b -p err
journalctl -b -p warning
journalctl -b -p warning -n 10
```

`-p warning` inclut les niveaux `warning`, `err`, `crit`, `alert` et `emerg` (tous les messages
de priorité inférieure ou égale à `warning`). Il y a donc en général plus de lignes qu'avec
`-p err` seul, car les avertissements (*warnings*) y sont inclus.
