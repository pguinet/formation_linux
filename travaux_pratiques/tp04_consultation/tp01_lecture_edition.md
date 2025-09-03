# TP04.1 - Lecture et édition de fichiers

## Objectifs
- Maîtriser les commandes de lecture de fichiers
- Apprendre à utiliser les éditeurs nano et vim
- Pratiquer la navigation et la recherche dans les fichiers
- Comprendre quand utiliser chaque outil

## Durée estimée
- **Formation complète** : 1h30
- **Formation accélérée** : 45 minutes

---

## Exercice 1 : Exploration avec les commandes de lecture (20 min)

### 1.1 Préparation de l'environnement
```bash
# Créer un répertoire de travail
mkdir ~/tp_lecture_edition
cd ~/tp_lecture_edition

# Créer des fichiers de test de différentes tailles
echo "Fichier court avec une seule ligne" > court.txt

# Fichier moyen (50 lignes)
for i in {1..50}; do
    echo "Ligne $i : Ceci est un exemple de contenu pour tester les outils de lecture"
done > moyen.txt

# Fichier long (500 lignes)
for i in {1..500}; do
    echo "Ligne $i : $(date) - Message de test avec du contenu variable"
done > long.txt

# Fichier avec du contenu structuré (log simulé)
cat > application.log << 'EOF'
2024-01-15 08:30:00 INFO Application démarrée
2024-01-15 08:30:05 INFO Connexion à la base de données réussie
2024-01-15 08:31:00 ERROR Échec de connexion utilisateur 'john'
2024-01-15 08:31:15 WARN Tentative de connexion suspecte depuis 192.168.1.100
2024-01-15 08:32:00 INFO Utilisateur 'marie' connecté avec succès
2024-01-15 08:33:00 DEBUG Traitement de la requête GET /api/users
2024-01-15 08:33:30 ERROR Timeout sur la requête vers service externe
2024-01-15 08:34:00 INFO Transaction financière validée (ID: 12345)
2024-01-15 08:35:00 WARN Espace disque faible : 85% utilisé
2024-01-15 08:36:00 INFO Sauvegarde automatique effectuée
EOF
```

### 1.2 Utilisation de cat
```bash
# Afficher le fichier court
cat court.txt

# Afficher avec numérotation des lignes
cat -n court.txt

# Concaténer plusieurs fichiers
cat court.txt application.log > combine.txt

# Vérifier la taille avant d'utiliser cat
ls -lh *.txt *.log
```

**Question 1.1** : Que se passe-t-il si vous utilisez `cat long.txt` ? Pourquoi est-ce problématique ?

### 1.3 Navigation avec less
```bash
# Ouvrir le fichier long avec less
less long.txt

# Dans less, pratiquer les commandes :
# - Espace : page suivante
# - b : page précédente
# - g : début du fichier
# - G : fin du fichier
# - /ERROR : rechercher "ERROR"
# - n : occurrence suivante
# - q : quitter

# Ouvrir avec numérotation
less -N application.log
```

**Question 1.2** : Trouvez toutes les lignes contenant "ERROR" dans application.log en utilisant less.

### 1.4 Utilisation de head et tail
```bash
# Premières lignes
head application.log
head -3 application.log

# Dernières lignes  
tail application.log
tail -3 application.log

# Suivre un fichier en temps réel (simulation)
# Dans un terminal :
tail -f application.log

# Dans un autre terminal, ajouter du contenu :
echo "2024-01-15 08:37:00 INFO Nouvelle connexion utilisateur" >> application.log
```

**Question 1.3** : Comment afficher les lignes 5 à 10 d'un fichier en combinant head et tail ?

---

## Exercice 2 : Édition avec nano (25 min)

### 2.1 Création d'un script simple
```bash
# Créer un nouveau script avec nano
nano mon_script.sh

# Saisir le contenu suivant :
#!/bin/bash
# Script de démonstration pour le TP

echo "=== Script de gestion système ==="
echo "Date actuelle : $(date)"
echo "Utilisateur connecté : $(whoami)"
echo "Répertoire actuel : $(pwd)"

# Fonction pour afficher l'usage disque
show_disk_usage() {
    echo "=== Usage disque ==="
    df -h / | grep -v Filesystem
}

# Fonction pour afficher les processus
show_processes() {
    echo "=== Top 5 processus CPU ==="
    ps aux --sort=-%cpu | head -6
}

# Menu principal
echo "Que souhaitez-vous faire ?"
echo "1) Afficher l'usage disque"
echo "2) Afficher les processus"
echo "3) Quitter"

read -p "Votre choix : " choice

case $choice in
    1) show_disk_usage ;;
    2) show_processes ;;
    3) echo "Au revoir !" ;;
    *) echo "Option invalide" ;;
esac

# Sauvegarder : Ctrl+O, puis Entrée
# Quitter : Ctrl+X
```

### 2.2 Édition d'un fichier de configuration
```bash
# Créer un fichier de configuration
nano app.conf

# Contenu à saisir :
[database]
host=localhost
port=5432
name=myapp
user=appuser
password=secret123

[logging]
level=INFO
file=/var/log/myapp.log
max_size=100MB

[server]
port=8080
debug=false
workers=4
```

**Exercice pratique nano** :
1. Rechercher "port" avec Ctrl+W
2. Remplacer "localhost" par "192.168.1.50" avec Ctrl+\\
3. Ajouter une nouvelle section [cache] à la fin
4. Couper la ligne password avec Ctrl+K et la coller ailleurs avec Ctrl+U

### 2.3 Configuration de nano
```bash
# Créer un fichier de configuration nano personnalisé
nano ~/.nanorc

# Ajouter ces options :
set linenumbers
set mouse
set softwrap
set tabsize 4
set autoindent
```

---

## Exercice 3 : Initiation à vim (30 min - optionnel pour formation accélérée)

### 3.1 Premier contact avec vim
```bash
# Créer un fichier simple avec vim
vim test_vim.txt

# Une fois dans vim :
# 1. Appuyer sur 'i' pour entrer en mode insertion
# 2. Taper du texte
# 3. Appuyer sur Échap pour revenir en mode normal
# 4. Taper :w pour sauvegarder
# 5. Taper :q pour quitter (ou :wq pour sauvegarder et quitter)
```

**Contenu à saisir en mode insertion** :
```
Premiers pas avec vim
====================

Vim est un éditeur modal très puissant.
Les modes principaux sont :
- Normal : pour la navigation et les commandes
- Insertion : pour taper du texte  
- Visuel : pour sélectionner du texte
- Commande : pour les actions complexes

Navigation de base :
h, j, k, l = gauche, bas, haut, droite
w = mot suivant
b = mot précédent
0 = début de ligne
$ = fin de ligne
```

### 3.2 Navigation et édition simple dans vim
```bash
# Rouvrir le fichier
vim test_vim.txt

# Pratiquer la navigation (mode Normal) :
# - Utiliser h,j,k,l pour se déplacer
# - Aller au début avec gg
# - Aller à la fin avec G
# - Rechercher avec /texte puis Entrée
# - Aller au mot suivant avec n

# Édition simple :
# - x pour supprimer un caractère
# - dd pour supprimer une ligne
# - yy pour copier une ligne
# - p pour coller
# - u pour annuler
```

### 3.3 Configuration basique de vim
```bash
# Créer un fichier de configuration vim simple
vim ~/.vimrc

# Ajouter (en mode insertion) :
set number
set showcmd
set hlsearch
set autoindent
syntax on

# Sauvegarder et quitter : :wq
```

---

## Exercice 4 : Cas pratiques de lecture et édition (25 min)

### 4.1 Analyse de logs système
```bash
# Créer un log simulé plus complexe
cat > server.log << 'EOF'
[2024-01-15 08:00:00] INFO Server starting on port 8080
[2024-01-15 08:00:01] INFO Loading configuration from /etc/server.conf
[2024-01-15 08:00:02] INFO Database connection pool initialized (10 connections)
[2024-01-15 08:00:03] INFO SSL certificate loaded: /etc/ssl/server.crt
[2024-01-15 08:00:04] INFO Server ready to accept connections
[2024-01-15 08:05:15] INFO User login: john@example.com from 192.168.1.10
[2024-01-15 08:05:30] WARNING Failed login attempt: baduser@domain.com from 10.0.0.50
[2024-01-15 08:06:00] INFO Processing request: GET /api/users/123
[2024-01-15 08:06:01] DEBUG Database query: SELECT * FROM users WHERE id=123
[2024-01-15 08:06:02] INFO Response sent: 200 OK (45ms)
[2024-01-15 08:10:30] ERROR Database connection timeout after 30s
[2024-01-15 08:10:31] ERROR Failed to process request: POST /api/orders
[2024-01-15 08:10:32] INFO Retrying database connection...
[2024-01-15 08:10:35] INFO Database connection restored
[2024-01-15 08:15:00] INFO Hourly cleanup task started
[2024-01-15 08:15:05] INFO Cleaned 145 temporary files
[2024-01-15 08:15:10] INFO Memory usage: 2.3GB / 8GB (28%)
[2024-01-15 08:20:00] WARNING High CPU usage detected: 85%
[2024-01-15 08:20:30] ERROR Out of memory: Cannot allocate buffer
[2024-01-15 08:20:31] CRITICAL Server crash detected, initiating restart
[2024-01-15 08:20:35] INFO Server restarting...
EOF

# Missions d'analyse :
# 1. Combien y a-t-il d'erreurs au total ?
tail -20 server.log | grep -c ERROR

# 2. À quelle heure le serveur a-t-il planté ?
grep "crash" server.log

# 3. Afficher seulement les 5 dernières entrées
tail -5 server.log

# 4. Voir l'activité entre 08:05 et 08:06
grep "08:0[56]" server.log
```

### 4.2 Édition de fichier de configuration système
```bash
# Simuler l'édition d'un fichier hosts local
nano hosts_local

# Contenu initial à créer :
127.0.0.1   localhost
127.0.1.1   mon-ordinateur

# Mission : ajouter ces entrées
192.168.1.10   serveur-web
192.168.1.20   serveur-db  
192.168.1.30   serveur-backup
```

### 4.3 Création d'un script de surveillance
```bash
# Créer un script de monitoring simple
nano monitor.sh

# Contenu du script :
#!/bin/bash
# Script de surveillance système simple

LOG_FILE="$HOME/monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Fonction pour logger les informations
log_info() {
    echo "[$DATE] $1" >> "$LOG_FILE"
}

# Vérifier l'espace disque
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 80 ]; then
    log_info "ALERTE: Espace disque critique: ${DISK_USAGE}%"
else
    log_info "INFO: Espace disque OK: ${DISK_USAGE}%"
fi

# Vérifier la charge système
LOAD=$(uptime | awk '{print $10}' | tr -d ',')
log_info "INFO: Charge système: $LOAD"

# Compter les utilisateurs connectés
USERS=$(who | wc -l)
log_info "INFO: Utilisateurs connectés: $USERS"

echo "Surveillance terminée. Voir $LOG_FILE pour les détails."

# Rendre exécutable et tester
chmod +x monitor.sh
./monitor.sh
cat monitor.log
```

---

## Questions de révision

### Questions théoriques
1. **Quelles sont les différences principales entre `cat`, `less`, et `more` ?**
2. **Dans quels cas utiliseriez-vous `head` vs `tail` ?**
3. **Quand choisir `nano` plutôt que `vim` ?**
4. **Comment suivre un fichier de log en temps réel ?**

### Questions pratiques
1. **Comment afficher les lignes 20 à 30 d'un fichier ?**
2. **Comment chercher et remplacer du texte dans nano ?**
3. **Comment naviguer rapidement au début/fin d'un fichier dans vim ?**
4. **Comment sauvegarder un fichier sans quitter l'éditeur ?**

---

## Défis avancés (bonus)

### Défi 1 : Analyse de performances
```bash
# Créer un gros fichier de test
seq 1 10000 > gros_fichier.txt

# Comparer les performances :
time cat gros_fichier.txt > /dev/null
time less gros_fichier.txt
```

### Défi 2 : Édition collaborative (simulation)
```bash
# Créer un fichier partagé
echo "Document collaboratif" > shared_doc.txt

# Simuler des modifications simultanées
# Terminal 1 : nano shared_doc.txt
# Terminal 2 : echo "Ajout externe" >> shared_doc.txt
# Observer les conflits potentiels
```

### Défi 3 : Automatisation d'édition
```bash
# Utiliser sed pour des modifications automatiques
sed -i 's/localhost/127.0.0.1/g' app.conf
sed -i '1i# Configuration modifiée automatiquement' app.conf
```

---

## Validation des acquis

### Checklist de compétences
- [ ] Ouvrir et lire des fichiers avec `cat`, `less`, `head`, `tail`
- [ ] Naviguer efficacement dans `less`
- [ ] Créer et éditer des fichiers avec `nano`
- [ ] Utiliser les raccourcis essentiels de `nano`
- [ ] Comprendre les modes de `vim` et navigation de base
- [ ] Choisir l'outil approprié selon la situation
- [ ] Suivre des fichiers de log en temps réel
- [ ] Configurer les éditeurs selon ses préférences

### Évaluation pratique
Créer un script qui :
1. Génère un fichier de log avec 100 lignes
2. Extrait les 10 premières et 10 dernières lignes
3. Compte le nombre d'occurrences d'un mot donné
4. Sauvegarde le résultat dans un fichier de rapport

---

## Points clés à retenir

### Commandes de lecture
- `cat` : fichiers courts, concaténation
- `less` : navigation avancée, gros fichiers  
- `head`/`tail` : début/fin, surveillance logs
- `tail -f` : suivi en temps réel

### Éditeurs
- `nano` : simple, intuitif, raccourcis visibles
- `vim` : puissant, modal, courbe d'apprentissage

### Bonnes pratiques
- Vérifier la taille avant `cat`
- Utiliser `less` pour les gros fichiers
- Sauvegarder avant modifications importantes
- Configurer son éditeur préféré