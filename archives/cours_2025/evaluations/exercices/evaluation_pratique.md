# Évaluation pratique - Formation Linux

## Instructions générales
- **Durée :** 2 heures
- **Type :** Évaluation pratique sur machine
- **Barème :** 100 points au total
- **Seuil de réussite :** 60/100 points
- **Documents autorisés :** Aucun (mais `man` et `--help` autorisés)

## Configuration initiale
Créer un répertoire de travail pour l'évaluation :
```bash
mkdir ~/evaluation_linux
cd ~/evaluation_linux
```

---

## Exercice 1 : Navigation et manipulation (15 points)

### 1.1 Création d'arborescence (5 points)
Créer l'arborescence suivante dans votre répertoire de travail :
```
projet/
├── src/
│   ├── main.c
│   └── utils.c
├── docs/
│   ├── README.txt
│   └── manual/
│       └── guide.txt
└── tests/
    └── test_main.c
```

**Commandes attendues :**
- [ ] Création des répertoires avec une seule commande `mkdir`
- [ ] Création des fichiers avec `touch`
- [ ] Vérification avec `tree` ou `ls -R`

### 1.2 Navigation et vérification (5 points)
1. Se placer dans le répertoire `manual`
2. Afficher le chemin complet actuel
3. Remonter au répertoire `projet` en une seule commande
4. Lister tout le contenu de façon récursive

### 1.3 Manipulation de fichiers (5 points)
1. Copier `main.c` vers le répertoire `tests` en le renommant `backup_main.c`
2. Déplacer `guide.txt` vers le répertoire `docs`  
3. Créer un lien symbolique de `README.txt` vers `src/readme_link.txt`

---

## Exercice 2 : Contenu et recherche (20 points)

### 2.1 Création de contenu (8 points)
Créer le fichier `projet/logs/system.log` avec ce contenu :
```
2024-01-15 08:30:12 INFO Démarrage du système
2024-01-15 08:30:15 INFO Chargement des modules
2024-01-15 08:31:02 WARNING Mémoire faible détectée
2024-01-15 08:31:45 ERROR Connexion à la base de données échouée
2024-01-15 08:32:10 INFO Tentative de reconnexion
2024-01-15 08:32:15 INFO Connexion rétablie
2024-01-15 08:35:20 WARNING Disque bientôt plein
2024-01-15 08:40:00 ERROR Timeout réseau
2024-01-15 08:41:30 INFO Système stable
```

### 2.2 Analyse du contenu (12 points)
En utilisant les commandes appropriées :

1. **Compter les lignes** contenant "ERROR" (2 points)
   - Commande : `grep "ERROR" system.log | wc -l`
   - Résultat attendu : 2

2. **Extraire les 3 premières lignes** du fichier (2 points)
   - Commande : `head -3 system.log`

3. **Afficher les lignes contenant "WARNING"** avec leur numéro (3 points)
   - Commande : `grep -n "WARNING" system.log`

4. **Créer un fichier `errors.log`** contenant uniquement les lignes d'erreur (3 points)
   - Commande : `grep "ERROR" system.log > errors.log`

5. **Compter le nombre total de mots** dans system.log (2 points)
   - Commande : `wc -w system.log`

---

## Exercice 3 : Droits et permissions (20 points)

### 3.1 Configuration des permissions (12 points)

1. **Créer les fichiers suivants** avec les permissions spécifiées :
   - `script.sh` : rwxr-xr-x (755) - 3 points
   - `config.conf` : rw-r--r-- (644) - 3 points  
   - `secret.txt` : rw------- (600) - 3 points
   - `public.txt` : rw-rw-r-- (664) - 3 points

**Vérification :** `ls -l` doit montrer les permissions exactes.

### 3.2 Manipulation des propriétaires (8 points)

**Note :** Cet exercice nécessite la simulation ou l'explication des commandes si sudo n'est pas disponible.

1. **Expliquer** comment changer le propriétaire de `secret.txt` vers l'utilisateur `admin` (2 points)
   - Réponse attendue : `chown admin secret.txt`

2. **Expliquer** comment changer le groupe de `config.conf` vers le groupe `developers` (2 points)
   - Réponse attendue : `chgrp developers config.conf`

3. **Donner la commande** pour retirer le droit d'écriture au groupe sur `public.txt` (2 points)
   - Réponse attendue : `chmod g-w public.txt`

4. **Expliquer** la différence entre les permissions 755 et 775 (2 points)
   - 755 : rwxr-xr-x (groupe et autres sans écriture)
   - 775 : rwxrwxr-x (groupe avec écriture)

---

## Exercice 4 : Processus et système (15 points)

### 4.1 Analyse des processus (8 points)

1. **Lister tous les processus** de l'utilisateur courant (2 points)
   - Commande : `ps -u $USER` ou `ps aux | grep $USER`

2. **Trouver le processus qui consomme le plus de CPU** (3 points)
   - Commande : `ps aux --sort=-pcpu | head -2`

3. **Compter le nombre total de processus** en cours d'exécution (3 points)
   - Commande : `ps aux | wc -l` (ou `ps aux | tail -n +2 | wc -l` pour exclure l'en-tête)

### 4.2 Surveillance système (7 points)

1. **Afficher l'utilisation du disque** en format lisible (2 points)
   - Commande : `df -h`

2. **Afficher l'utilisation mémoire** en format lisible (2 points)
   - Commande : `free -h`

3. **Afficher la charge système** (uptime) (3 points)
   - Commande : `uptime`

---

## Exercice 5 : Scripts et automatisation (20 points)

### 5.1 Création de script (12 points)

Créer un script `system_report.sh` qui :

1. **Affiche la date et l'heure** actuelles (2 points)
2. **Affiche l'utilisateur** connecté (2 points)  
3. **Compte le nombre de fichiers** dans le répertoire courant (3 points)
4. **Vérifie si l'espace disque racine** dépasse 80% et affiche un message approprié (5 points)

**Code attendu :**
```bash
#!/bin/bash

echo "=== Rapport système ==="
echo "Date: $(date)"
echo "Utilisateur: $USER"

file_count=$(ls -1 | wc -l)
echo "Nombre de fichiers: $file_count"

disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 80 ]; then
    echo "ALERTE: Disque plein à ${disk_usage}%"
else
    echo "Espace disque OK: ${disk_usage}%"
fi
```

### 5.2 Pipes et redirections (8 points)

1. **Créer une commande complexe** qui liste tous les fichiers .txt, les trie par taille, et sauvegarde le résultat dans `files_report.txt` (4 points)
   - Commande : `find . -name "*.txt" -exec ls -lh {} \; | sort -k5 > files_report.txt`

2. **Créer un alias** nommé `logcheck` qui affiche les 10 dernières lignes des fichiers .log du répertoire courant (4 points)
   - Commande : `alias logcheck='find . -name "*.log" -exec tail -10 {} \; -print'`

---

## Exercice 6 : Résolution de problèmes (10 points)

### Scénario : Diagnostic système

Un utilisateur signale des problèmes sur son système. Donner les commandes pour :

1. **Vérifier l'espace disque** disponible (2 points)
   - `df -h`

2. **Identifier les gros fichiers** dans /tmp (plus de 100MB) (3 points)
   - `find /tmp -type f -size +100M -ls`

3. **Voir les dernières connexions** utilisateur (2 points)
   - `last -10` ou `who`

4. **Vérifier les logs système** récents (3 points)
   - `tail -50 /var/log/syslog` ou `journalctl -n 50`

---

## Barème et évaluation

### Critères d'évaluation

**Syntaxe des commandes (40%):**
- Commandes exactes et fonctionnelles
- Options appropriées utilisées
- Pas d'erreurs de syntaxe

**Efficacité (30%):**
- Solutions optimales choisies
- Utilisation appropriée des pipes et redirections
- Scripts fonctionnels et robustes

**Compréhension (30%):**
- Logique des solutions
- Adaptation aux contextes
- Capacité à expliquer les choix

### Grille de notation

| Points | Appréciation |
|--------|-------------|
| 90-100 | Excellent - Maîtrise complète |
| 80-89  | Très bien - Bonnes compétences |
| 70-79  | Bien - Compétences satisfaisantes |
| 60-69  | Passable - Niveau minimal atteint |
| < 60   | Insuffisant - Formation complémentaire nécessaire |

### Conseils pour l'examen

1. **Lisez entièrement** chaque exercice avant de commencer
2. **Testez vos commandes** avant de passer à la suite
3. **Utilisez man et --help** en cas de doute
4. **Vérifiez vos résultats** avec ls, cat, etc.
5. **Gérez votre temps** : ne restez pas bloqué sur un exercice
6. **Documentez vos scripts** avec des commentaires

**Bonne chance !**