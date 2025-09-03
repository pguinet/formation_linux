# Chemins absolus et relatifs

## Concept fondamental

Un **chemin** (path) indique l'emplacement d'un fichier ou répertoire dans l'arborescence. Il existe deux types de chemins :

- **Chemin absolu** : Depuis la racine `/`
- **Chemin relatif** : Depuis le répertoire courant

## Chemins absolus

### Définition
Un chemin absolu **commence toujours par `/`** et décrit le chemin complet depuis la racine du système.

### Caractéristiques
- **Unique** : Il n'y a qu'un seul chemin absolu pour chaque élément
- **Sans ambiguïté** : Fonctionne depuis n'importe où
- **Indépendant** du répertoire courant

### Exemples
```bash
/home/john/Documents/rapport.txt
/etc/passwd
/var/log/syslog
/usr/bin/ls
/tmp/fichier_temp.txt
```

### Utilisation
```bash
# Ces commandes fonctionnent depuis n'importe où
ls /etc/passwd
cat /var/log/syslog
cd /home/john/Documents
```

## Chemins relatifs

### Définition
Un chemin relatif **ne commence PAS par `/`** et décrit le chemin depuis le répertoire courant.

### Éléments spéciaux
- `.` : répertoire courant
- `..` : répertoire parent
- `~` : répertoire personnel (équivaut à `/home/username`)

### Exemples selon la position

**Si je suis dans `/home/john/` :**
```bash
# Chemin relatif → Chemin absolu équivalent
Documents/rapport.txt → /home/john/Documents/rapport.txt
../marie/photo.jpg → /home/marie/photo.jpg
./script.sh → /home/john/script.sh
../../etc/passwd → /etc/passwd
```

**Si je suis dans `/home/john/Documents/` :**
```bash
# Chemin relatif → Chemin absolu équivalent
rapport.txt → /home/john/Documents/rapport.txt
../Pictures/vacances.jpg → /home/john/Pictures/vacances.jpg
../../marie/documents/ → /home/marie/documents/
../../../etc/ → /etc/
```

## Utilisation pratique des chemins

### Exemple concret : Navigation relative

**Situation initiale :**
```bash
pwd
# /home/john
```

**Structure des répertoires :**
```
/home/john/
├── Documents/
│   ├── travail/
│   │   └── rapport.pdf
│   └── personnel/
│       └── notes.txt
├── Pictures/
│   └── vacances.jpg
└── Videos/
    └── demo.mp4
```

**Navigation avec chemins relatifs :**
```bash
# Depuis /home/john
cd Documents              # Aller dans Documents
pwd                       # /home/john/Documents

cd travail               # Aller dans travail  
pwd                      # /home/john/Documents/travail

cd ../personnel          # Remonter puis aller dans personnel
pwd                      # /home/john/Documents/personnel

cd ../../Pictures        # Remonter 2 fois puis aller dans Pictures
pwd                      # /home/john/Pictures

cd ../Videos             # Aller dans Videos (même niveau)
pwd                      # /home/john/Videos
```

**Même navigation avec chemins absolus :**
```bash
cd /home/john/Documents
cd /home/john/Documents/travail
cd /home/john/Documents/personnel  
cd /home/john/Pictures
cd /home/john/Videos
```

## Compréhension des niveaux

### Visualisation des niveaux
```bash
/                        # Niveau 0 (racine)
├── home/                # Niveau 1
│   └── john/            # Niveau 2
│       ├── Documents/   # Niveau 3
│       │   └── travail/ # Niveau 4
│       └── Pictures/    # Niveau 3
```

### Remonter dans l'arborescence
```bash
# Depuis /home/john/Documents/travail/
cd ..                    # → /home/john/Documents/
cd ../..                 # → /home/john/
cd ../../..              # → /home/
cd ../../../..           # → / (racine)
```

### Descendre dans l'arborescence
```bash
# Depuis /home/john/
cd Documents/travail     # → /home/john/Documents/travail/
cd ../../Pictures        # → /home/john/Pictures/
```

## Le répertoire personnel (`~`)

### Utilisation du tilde
```bash
# Ces commandes sont équivalentes :
cd ~                     # Aller au répertoire personnel
cd /home/john            # (si vous êtes l'utilisateur john)
cd                       # Sans argument = répertoire personnel
```

### Chemins avec tilde
```bash
~/Documents              # = /home/john/Documents
~/Pictures/vacances.jpg  # = /home/john/Pictures/vacances.jpg
~/../marie/              # = /home/marie/
```

### Autres utilisateurs
```bash
~marie                   # Répertoire personnel de marie (/home/marie)
~root                    # Répertoire personnel de root (/root)
```

## Avantages et inconvénients

### Chemins absolus

**Avantages :**
- **Précision** : Aucune ambiguïté
- **Fiabilité** : Fonctionnent depuis n'importe où
- **Scripts** : Idéaux pour l'automatisation

**Inconvénients :**
- **Longueur** : Plus longs à taper
- **Rigidité** : Difficiles à adapter si structure change

### Chemins relatifs

**Avantages :**
- **Concision** : Plus courts, plus rapides
- **Flexibilité** : S'adaptent au contexte
- **Navigation** : Naturels pour explorer

**Inconvénients :**
- **Contexte** : Dépendent du répertoire courant
- **Confusion** : Peuvent être ambigus

## Exemples pratiques avancés

### Cas d'usage : Administration système

**Aller dans les logs système :**
```bash
# Chemin absolu (fonctionne toujours)
cd /var/log
ls -ltr

# Chemin relatif (depuis /)
cd var/log
```

**Explorer la configuration :**
```bash
# Depuis n'importe où
cat /etc/passwd
ls -la /etc/ssh/

# Si on est déjà dans /etc
cat passwd
ls -la ssh/
```

### Cas d'usage : Développement

**Structure projet :**
```
/home/dev/projet/
├── src/
│   ├── main.py
│   └── utils.py
├── tests/
│   └── test_main.py
└── docs/
    └── README.md
```

**Navigation efficace :**
```bash
cd /home/dev/projet       # Aller à la racine du projet
cd src                    # Aller dans les sources
ls -la
cd ../tests               # Aller dans les tests
cd ../docs                # Aller dans la doc
cd ..                     # Retour à la racine projet
```

## Résolution de chemins par le shell

### Comment le shell interprète les chemins

1. **Chemin absolu** (`/...`) : Utilisation directe
2. **Tilde** (`~`) : Expansion vers le home
3. **Chemin relatif** : Ajout du répertoire courant

### Variables d'environnement liées
```bash
echo $PWD                # Répertoire courant
echo $OLDPWD             # Répertoire précédent
echo $HOME               # Répertoire personnel
```

## Outils pour comprendre les chemins

### `realpath` - Résolution des chemins
```bash
# Résoudre un chemin relatif en absolu
realpath Documents/rapport.txt
# /home/john/Documents/rapport.txt

# Résoudre les liens symboliques
realpath /usr/bin/python
# /usr/bin/python3.9
```

### `dirname` et `basename` - Décomposer les chemins
```bash
# Extraire le répertoire parent
dirname /home/john/Documents/rapport.txt
# /home/john/Documents

# Extraire le nom du fichier
basename /home/john/Documents/rapport.txt  
# rapport.txt

# Extraire l'extension
basename /home/john/Documents/rapport.txt .txt
# rapport
```

## Erreurs courantes et solutions

### Erreur 1 : Confusion absolu/relatif
```bash
# ERREUR : Mélanger les types
cd /home/john
ls etc/passwd            # Cherche dans /home/john/etc/passwd (n'existe pas)

# SOLUTION : Utiliser un chemin cohérent  
ls /etc/passwd           # Chemin absolu
# OU si on est dans /
ls etc/passwd            # Chemin relatif valide
```

### Erreur 2 : Oublier le répertoire courant
```bash
# Vérifier où on est avant d'utiliser un chemin relatif
pwd
ls Documents             # Ne fonctionne que si on est dans le bon répertoire
```

### Erreur 3 : Espaces dans les noms
```bash
# ERREUR
cd Mon Dossier          # Interprété comme 2 arguments

# SOLUTIONS
cd "Mon Dossier"        # Guillemets
cd Mon\ Dossier         # Échappement
cd 'Mon Dossier'        # Apostrophes
```

## Bonnes pratiques

### 1. Toujours vérifier sa position
```bash
pwd && ls -la
```

### 2. Utiliser la complétion Tab
```bash
cd /ho[Tab]             # Complète en /home/
cd Docu[Tab]            # Complète en Documents/
```

### 3. Dans les scripts : privilégier les chemins absolus
```bash
#!/bin/bash
# Bon
LOG_FILE="/var/log/monapp.log"

# Risqué (dépend du répertoire d'exécution)
LOG_FILE="logs/monapp.log"
```

### 4. Navigation interactive : utiliser les chemins relatifs
```bash
# Plus efficace pour l'exploration
cd ../..
cd Documents/travail
```

## Points clés à retenir

- **Chemin absolu** : commence par `/`, fonctionne partout
- **Chemin relatif** : depuis le répertoire courant
- **`.`** = répertoire courant, **`..`** = répertoire parent  
- **`~`** = répertoire personnel
- **`pwd`** pour connaître sa position
- **Tab** pour la complétion automatique
- **Scripts** : préférer les chemins absolus
- **Navigation** : les chemins relatifs sont plus pratiques

## Exercices pratiques

### Exercice 1 : Conversion des chemins
À partir de `/home/john/Documents/`, convertir ces chemins relatifs en absolus :
- `../Pictures/photo.jpg`
- `../../etc/passwd` 
- `travail/rapport.pdf`

### Exercice 2 : Navigation mixte  
```bash
cd /home                 # Absolu
cd john/Documents        # Relatif  
pwd                      # Vérifier
cd ../../..              # Relatif
pwd                      # Où êtes-vous ?
```

### Réponses exercice 1
- `/home/john/Pictures/photo.jpg`
- `/etc/passwd`
- `/home/john/Documents/travail/rapport.pdf`