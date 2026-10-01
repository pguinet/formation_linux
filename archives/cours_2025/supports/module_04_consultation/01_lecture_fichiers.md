# Lecture de fichiers

## La commande `cat` - Afficher le contenu complet

### Principe de base
`cat` (concatenate) affiche le contenu complet d'un ou plusieurs fichiers sur la sortie standard.

### Syntaxe
```bash
cat [options] fichier1 [fichier2 ...]
```

### Utilisation simple
```bash
# Afficher un fichier
cat /etc/passwd

# Afficher plusieurs fichiers à la suite
cat file1.txt file2.txt

# Concaténer des fichiers vers un nouveau fichier
cat file1.txt file2.txt > combined.txt
```

### Options utiles de cat
```bash
# Numéroter toutes les lignes
cat -n /etc/passwd

# Numéroter seulement les lignes non vides
cat -b fichier.txt

# Afficher les caractères de fin de ligne
cat -E fichier.txt

# Afficher les tabulations comme ^I
cat -T fichier.txt

# Afficher tous les caractères non imprimables
cat -A fichier.txt
```

### Cas d'usage pratiques
```bash
# Voir le contenu d'un fichier de configuration
cat /etc/hosts

# Combiner plusieurs logs
cat /var/log/syslog.1 /var/log/syslog > combined_logs.txt

# Créer un fichier avec du contenu inline
cat > nouveau_fichier.txt << EOF
Première ligne
Deuxième ligne
Dernière ligne
EOF
```

## La commande `less` - Navigation dans les fichiers

### Principe
`less` permet de naviguer dans les fichiers volumineux page par page, avec défilement avant et arrière.

### Syntaxe
```bash
less [options] fichier
```

### Navigation dans less
| Touche | Action |
|--------|--------|
| **Espace** | Page suivante |
| **b** | Page précédente |
| **↑/↓** | Ligne par ligne |
| **g** | Début du fichier |
| **G** | Fin du fichier |
| **/**pattern | Rechercher vers le bas |
| **?**pattern | Rechercher vers le haut |
| **n** | Occurrence suivante |
| **N** | Occurrence précédente |
| **q** | Quitter |

### Options utiles de less
```bash
# Afficher les numéros de ligne
less -N fichier.txt

# Recherche insensible à la casse
less -i fichier.txt

# Suivre le fichier en temps réel (comme tail -f)
less +F /var/log/syslog
```

### Exemples pratiques
```bash
# Parcourir un log volumineux
less /var/log/syslog

# Examiner un fichier de configuration
less /etc/nginx/nginx.conf

# Voir la fin d'un fichier puis naviguer
less +G /var/log/messages
```

## La commande `more` - Paginateur simple

### Principe
`more` est l'ancêtre de `less`, plus simple mais moins fonctionnel.

### Utilisation
```bash
# Affichage paginé
more /etc/passwd

# Navigation limitée (seulement vers l'avant)
# Espace : page suivante
# Entrée : ligne suivante  
# q : quitter
```

### Comparaison more vs less
| Aspect | more | less |
|--------|------|------|
| **Navigation** | Avant seulement | Avant/arrière |
| **Recherche** | Basique | Avancée |
| **Mémoire** | Charge tout | Charge à la demande |
| **Fonctionnalités** | Limitées | Riches |

## Les commandes `head` et `tail` - Début et fin de fichiers

### La commande `head` - Premières lignes

#### Syntaxe et utilisation
```bash
# Afficher les 10 premières lignes (par défaut)
head /etc/passwd

# Spécifier le nombre de lignes
head -n 20 /var/log/syslog
head -20 /var/log/syslog     # Version courte

# Premiers caractères au lieu de lignes
head -c 100 fichier.txt
```

#### Exemples pratiques
```bash
# Voir l'en-tête d'un fichier CSV
head -5 data.csv

# Examiner le début d'un script
head -20 /usr/bin/apt

# Combiner avec d'autres commandes
ls -la | head -10
```

### La commande `tail` - Dernières lignes

#### Syntaxe et utilisation
```bash
# Afficher les 10 dernières lignes (par défaut)
tail /var/log/syslog

# Spécifier le nombre de lignes
tail -n 50 /var/log/messages
tail -50 /var/log/messages   # Version courte

# Derniers caractères
tail -c 200 fichier.txt
```

#### Suivi en temps réel avec `-f`
```bash
# Suivre un fichier de log en temps réel
tail -f /var/log/syslog

# Suivre avec nombre de lignes initial
tail -f -n 100 /var/log/apache2/access.log

# Suivre plusieurs fichiers
tail -f /var/log/syslog /var/log/auth.log
```

#### Exemples avancés
```bash
# Ignorer les premières lignes (afficher tout sauf les N premières)
tail -n +10 fichier.txt      # À partir de la ligne 10

# Surveiller les nouveaux fichiers de log
tail -F /var/log/app/*.log   # -F recharge si le fichier est recréé

# Suivre avec arrêt automatique
timeout 60 tail -f /var/log/syslog  # Arrêter après 60 secondes
```

## Combinaisons et techniques avancées

### Extraire des sections spécifiques

#### Lignes du milieu
```bash
# Lignes 20 à 30 d'un fichier
head -30 fichier.txt | tail -10

# Autre méthode avec sed
sed -n '20,30p' fichier.txt
```

#### Extractions complexes
```bash
# Première et dernière ligne
(head -1; tail -1) < fichier.txt

# Toutes les lignes sauf la première
tail -n +2 fichier.txt

# Toutes les lignes sauf la dernière
head -n -1 fichier.txt
```

### Surveillance de multiples fichiers
```bash
# Surveiller plusieurs logs avec identification
tail -f /var/log/syslog /var/log/auth.log | while read line; do
    echo "$(date): $line"
done

# Surveiller avec multitail (si installé)
multitail /var/log/syslog /var/log/auth.log
```

## Fichiers spéciaux et contenus binaires

### Gestion des fichiers binaires
```bash
# Éviter d'afficher des fichiers binaires avec cat
file fichier_inconnu.dat
if file fichier_inconnu.dat | grep -q "text"; then
    cat fichier_inconnu.dat
else
    echo "Fichier binaire - utiliser hexdump ou strings"
fi

# Extraire les chaînes de caractères d'un binaire
strings /bin/ls | head -20

# Affichage hexadécimal
hexdump -C fichier_binaire.dat | head -10
xxd fichier_binaire.dat | head -10
```

### Fichiers avec encodages spéciaux
```bash
# Déterminer l'encodage
file -i fichier.txt

# Convertir l'encodage si nécessaire
iconv -f ISO-8859-1 -t UTF-8 fichier_latin.txt > fichier_utf8.txt
```

## Fichiers volumineux et performances

### Stratégies pour les gros fichiers
```bash
# Éviter cat sur de très gros fichiers
ls -lh gros_fichier.log

# Préférer less pour la navigation
less gros_fichier.log

# Échantillonnage d'un gros fichier
head -1000 gros_fichier.log > echantillon.log
tail -1000 gros_fichier.log >> echantillon.log

# Statistiques rapides sans charger le fichier complet
wc -l gros_fichier.log       # Nombre de lignes
du -h gros_fichier.log       # Taille
```

### Lecture optimisée
```bash
# Lire par blocs pour de très gros fichiers
dd if=gros_fichier.log bs=1M count=1 | cat

# Utiliser split pour diviser en parties lisibles
split -l 10000 gros_fichier.log partie_

# Compression à la volée pour économiser l'espace
gzip -c gros_fichier.log > gros_fichier.log.gz
zless gros_fichier.log.gz
```

## Commandes de visualisation spécialisées

### Pour les logs système
```bash
# Journaux systemd
journalctl -f              # Suivi en temps réel
journalctl -n 50           # 50 dernières entrées
journalctl --since "1 hour ago"

# Logs avec couleurs
ccze < /var/log/syslog     # Colorisation des logs
```

### Pour les données structurées
```bash
# Fichiers CSV
column -t -s ',' data.csv  # Affichage en colonnes alignées

# JSON avec coloration
cat data.json | python -m json.tool  # Formatage JSON
jq '.' data.json           # Si jq est installé
```

## Redirection et pipes avec la lecture

### Redirection de la lecture
```bash
# Sauvegarder une partie d'un fichier
head -100 /var/log/syslog > debut_log.txt
tail -100 /var/log/syslog > fin_log.txt

# Combiner lecture et filtrage
cat /etc/passwd | grep "bash$" > users_bash.txt
```

### Pipes utiles
```bash
# Compter les lignes d'un type spécifique
cat /var/log/syslog | grep "ERROR" | wc -l

# Pagination d'une commande longue
ps aux | less

# Recherche dans une sortie longue
dmesg | less
```

## Bonnes pratiques de lecture

### 1. Choisir le bon outil
```bash
# Fichier court (< 1000 lignes) : cat
cat short_file.txt

# Fichier long : less
less long_file.txt

# Début/fin spécifique : head/tail
tail -20 /var/log/syslog
```

### 2. Vérifier avant de lire
```bash
# Toujours vérifier la taille avant cat
ls -lh fichier_inconnu.txt
file fichier_inconnu.txt
```

### 3. Utiliser les options appropriées
```bash
# Numérotation pour le debug
cat -n script.sh

# Suivi temps réel pour les logs
tail -f /var/log/application.log
```

### 4. Sécurité avec les fichiers inconnus
```bash
# Ne jamais faire cat sur des fichiers suspects
file fichier_suspect
head -10 fichier_suspect    # Test prudent
```

## Points clés à retenir

- **`cat`** : affichage complet, idéal pour fichiers courts
- **`less`** : navigation avancée, parfait pour gros fichiers
- **`head`/`tail`** : début/fin de fichiers, surveillance logs
- **Navigation less** : Espace (page), g/G (début/fin), /pattern (recherche)
- **`tail -f`** : suivi en temps réel des logs
- **Vérifier la taille** avant d'utiliser cat sur gros fichiers
- **Fichiers binaires** : utiliser `file` pour identifier le type
- **Performance** : less pour gros fichiers, cat pour petits

## Exercices pratiques

### Exercice 1 : Exploration de fichiers système
```bash
# Explorer /etc/passwd
head -5 /etc/passwd
tail -5 /etc/passwd
cat /etc/passwd | wc -l

# Rechercher dans less
less /etc/passwd
# Puis taper /bin/bash pour trouver les utilisateurs avec bash
```

### Exercice 2 : Surveillance de logs
```bash
# Dans un terminal, surveiller les logs
tail -f /var/log/syslog

# Dans un autre terminal, générer une activité
logger "Test message from $(whoami)"
```

### Exercice 3 : Extraction de données
```bash
# Créer un fichier test
seq 1 100 > numbers.txt

# Extraire les lignes 50 à 60
head -60 numbers.txt | tail -10
```