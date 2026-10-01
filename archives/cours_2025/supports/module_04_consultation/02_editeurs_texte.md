# Éditeurs de texte

## Vue d'ensemble des éditeurs disponibles

### Classification des éditeurs

**Éditeurs simples (débutants) :**
- `nano` : Interface intuitive, menus visibles
- `gedit` : Éditeur graphique simple (si GUI disponible)

**Éditeurs avancés (experts) :**
- `vim` : Éditeur modal très puissant
- `emacs` : Éditeur extensible et programmable

**Éditeurs de ligne :**
- `sed` : Édition en flux pour scripts
- `ed` : Éditeur historique Unix

## L'éditeur `nano` - Simple et efficace

### Principe de nano
`nano` est l'éditeur recommandé pour débuter. Interface claire avec raccourcis affichés.

### Lancement de nano
```bash
# Créer/éditer un fichier
nano fichier.txt

# Ouvrir un fichier existant
nano /etc/hosts

# Ouvrir avec numérotation des lignes
nano -l script.sh

# Ouvrir en lecture seule
nano -v fichier.txt
```

### Interface de nano
```
  GNU nano 4.8                     fichier.txt                              

Première ligne du fichier
Deuxième ligne
Troisième ligne




^G Get Help  ^O Write Out  ^W Where Is   ^K Cut Text   ^J Justify
^X Exit      ^R Read File  ^\ Replace    ^U Uncut Text ^T To Spell
```

### Raccourcis essentiels de nano

#### Navigation
| Raccourci | Action |
|-----------|--------|
| **Ctrl+A** | Début de ligne |
| **Ctrl+E** | Fin de ligne |
| **Ctrl+Y** | Page précédente |
| **Ctrl+V** | Page suivante |
| **Ctrl+G** | Aide |

#### Édition de base
| Raccourci | Action |
|-----------|--------|
| **Ctrl+K** | Couper la ligne |
| **Ctrl+U** | Coller |
| **Ctrl+6** | Marquer le début de sélection |
| **Ctrl+W** | Rechercher |
| **Ctrl+\\** | Remplacer |

#### Sauvegarde et sortie
| Raccourci | Action |
|-----------|--------|
| **Ctrl+O** | Sauvegarder (Write Out) |
| **Ctrl+X** | Quitter |
| **Ctrl+R** | Insérer un fichier |

### Utilisation pratique de nano

#### Édition simple
```bash
# Créer un script simple
nano hello.sh

# Contenu à saisir :
#!/bin/bash
echo "Hello World"

# Sauvegarder : Ctrl+O, Entrée
# Quitter : Ctrl+X
```

#### Recherche et remplacement
```bash
# Ouvrir un fichier de configuration
nano /etc/nginx/nginx.conf

# Rechercher "server" : Ctrl+W, taper "server", Entrée
# Remplacer : Ctrl+\, taper ancien texte, nouveau texte
```

#### Configuration de nano
```bash
# Fichier de configuration personnel
nano ~/.nanorc

# Contenu utile :
set linenumbers          # Afficher les numéros de ligne
set mouse               # Activer la souris
set softwrap            # Retour à la ligne automatique
set tabsize 4           # Taille des tabulations
```

## L'éditeur `vim` - Puissant mais complexe

### Principe de vim
`vim` (Vi IMproved) est un éditeur modal : différents modes pour différentes actions.

### Les modes de vim

#### Mode Normal (par défaut)
- **Navigation** et **commandes**
- **Pas d'insertion** de texte

#### Mode Insertion
- **Saisie** de texte
- Activé par `i`, `a`, `o`, etc.

#### Mode Commande
- **Commandes complexes**
- Activé par `:` depuis le mode Normal

#### Mode Visuel
- **Sélection** de texte
- Activé par `v` depuis le mode Normal

### Commandes essentielles de vim

#### Ouverture et fermeture
```bash
# Ouvrir vim
vim fichier.txt

# Dans vim, sauvegarder et quitter
:wq

# Quitter sans sauvegarder
:q!

# Sauvegarder seulement
:w
```

#### Navigation (Mode Normal)
| Touche | Action |
|--------|--------|
| **h, j, k, l** | ←, ↓, ↑, → |
| **w** | Mot suivant |
| **b** | Mot précédent |
| **0** | Début de ligne |
| **$** | Fin de ligne |
| **gg** | Début de fichier |
| **G** | Fin de fichier |

#### Insertion de texte
| Touche | Action |
|--------|--------|
| **i** | Insérer avant le curseur |
| **a** | Insérer après le curseur |
| **I** | Insérer en début de ligne |
| **A** | Insérer en fin de ligne |
| **o** | Nouvelle ligne en dessous |
| **O** | Nouvelle ligne au-dessus |

#### Édition (Mode Normal)
| Touche | Action |
|--------|--------|
| **x** | Supprimer caractère |
| **dd** | Supprimer ligne |
| **yy** | Copier ligne |
| **p** | Coller après |
| **P** | Coller avant |
| **u** | Annuler (undo) |
| **Ctrl+r** | Refaire (redo) |

### Utilisation de base de vim

#### Premier script avec vim
```bash
# Ouvrir vim
vim script.sh

# Appuyer sur 'i' pour passer en mode insertion
# Taper le contenu :
#!/bin/bash
echo "Mon premier script vim"

# Appuyer sur Échap pour revenir en mode normal
# Taper :wq pour sauvegarder et quitter
```

#### Recherche dans vim
```bash
# En mode Normal :
/pattern      # Rechercher "pattern" vers le bas
?pattern      # Rechercher "pattern" vers le haut
n             # Occurrence suivante
N             # Occurrence précédente
```

#### Remplacer dans vim
```bash
# En mode Commande (:) :
:%s/ancien/nouveau/g      # Remplacer tout dans le fichier
:s/ancien/nouveau/g       # Remplacer sur la ligne courante
:%s/ancien/nouveau/gc     # Remplacer avec confirmation
```

### Configuration basique de vim
```bash
# Fichier de configuration
vim ~/.vimrc

# Configuration minimale :
set number          " Numéros de ligne
set showcmd         " Afficher les commandes
set hlsearch        " Surligner les recherches
set autoindent      " Indentation automatique
syntax on           " Coloration syntaxique
```

## Comparaison nano vs vim

### Tableau comparatif

| Aspect | nano | vim |
|--------|------|-----|
| **Courbe d'apprentissage** | Facile | Difficile |
| **Aide visible** | Oui (en bas) | Non (aide séparée) |
| **Modes** | Un seul | Multiples |
| **Productivité débutant** | Immédiate | Lente initialement |
| **Productivité expert** | Limitée | Très élevée |
| **Fonctionnalités** | Basiques | Très avancées |
| **Taille** | Légère | Plus lourde |

### Quand utiliser chaque éditeur ?

**Utilisez nano pour :**
- Modifications rapides de configuration
- Édition occasionnelle
- Utilisateurs débutants
- Environnements avec peu de ressources

**Utilisez vim pour :**
- Développement intensif
- Édition de gros fichiers
- Automatisation d'édition
- Une fois la courbe d'apprentissage maîtrisée

## Édition rapide en ligne de commande

### Modifications simples avec sed
```bash
# Remplacer dans un fichier (sans l'éditer)
sed 's/ancien/nouveau/g' fichier.txt

# Modifier le fichier directement
sed -i 's/ancien/nouveau/g' fichier.txt

# Supprimer des lignes
sed -i '/pattern/d' fichier.txt

# Ajouter une ligne après une pattern
sed -i '/pattern/a\nouvelle ligne' fichier.txt
```

### Édition avec echo et redirection
```bash
# Ajouter du contenu à un fichier
echo "nouvelle ligne" >> fichier.txt

# Remplacer complètement un fichier
echo "nouveau contenu" > fichier.txt

# Créer un fichier avec plusieurs lignes
cat > fichier.txt << EOF
Ligne 1
Ligne 2
Ligne 3
EOF
```

## Éditeurs graphiques (si interface disponible)

### gedit (GNOME)
```bash
# Lancer gedit
gedit fichier.txt &

# Avec privilèges administrateur
sudo gedit /etc/hosts
```

### kate (KDE)
```bash
# Lancer kate
kate fichier.txt &
```

### code (Visual Studio Code)
```bash
# Si VS Code est installé
code fichier.txt
code .              # Ouvrir le répertoire courant
```

## Bonnes pratiques d'édition

### 1. Toujours faire une sauvegarde
```bash
# Avant de modifier un fichier important
cp /etc/important.conf /etc/important.conf.backup
nano /etc/important.conf
```

### 2. Vérifier la syntaxe après édition
```bash
# Pour les scripts bash
bash -n script.sh

# Pour les fichiers de configuration
nginx -t                    # nginx
apache2ctl configtest      # apache
```

### 3. Utiliser des éditeurs appropriés aux privilèges
```bash
# Éviter sudo avec des éditeurs complexes
sudo nano /etc/hosts        # Préférable
sudo vim /etc/hosts         # Plus risqué pour débutants
```

### 4. Configurer l'éditeur par défaut
```bash
# Définir nano comme éditeur par défaut
export EDITOR=nano
echo 'export EDITOR=nano' >> ~/.bashrc

# Ou vim pour les experts
export EDITOR=vim
```

## Édition de fichiers système critiques

### Fichiers de configuration courants

#### /etc/hosts - Résolution de noms locaux
```bash
sudo nano /etc/hosts

# Structure type :
127.0.0.1    localhost
127.0.1.1    mon-hostname
192.168.1.10 serveur-local
```

#### ~/.bashrc - Configuration du shell
```bash
nano ~/.bashrc

# Ajouts typiques :
alias ll='ls -la'
export PATH="$PATH:/usr/local/bin"
export EDITOR=nano
```

#### /etc/crontab - Tâches programmées
```bash
sudo nano /etc/crontab

# Format : minute heure jour mois jour_semaine utilisateur commande
0 2 * * * root /usr/local/bin/backup.sh
```

### Précautions pour l'édition système
```bash
# 1. Toujours sauvegarder
sudo cp /etc/important.conf /etc/important.conf.$(date +%Y%m%d)

# 2. Utiliser visudo pour /etc/sudoers
sudo visudo

# 3. Vérifier la syntaxe
# 4. Tester les modifications

# 5. En cas d'erreur, restaurer
sudo cp /etc/important.conf.20240115 /etc/important.conf
```

## Scripts d'automatisation d'édition

### Script de configuration automatique
```bash
#!/bin/bash
# Configuration automatique d'un nouvel utilisateur

CONFIG_FILE="$HOME/.bashrc"

# Ajouter des alias si pas déjà présents
if ! grep -q "alias ll=" "$CONFIG_FILE"; then
    echo "" >> "$CONFIG_FILE"
    echo "# Alias personnalisés" >> "$CONFIG_FILE"
    echo "alias ll='ls -la'" >> "$CONFIG_FILE"
    echo "alias la='ls -A'" >> "$CONFIG_FILE"
    echo "alias grep='grep --color=auto'" >> "$CONFIG_FILE"
fi

# Configurer l'éditeur
if ! grep -q "EDITOR=" "$CONFIG_FILE"; then
    echo "export EDITOR=nano" >> "$CONFIG_FILE"
fi

echo "Configuration terminée"
```

### Fonction d'édition sécurisée
```bash
safe_edit() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "Fichier $file introuvable"
        return 1
    fi
    
    # Sauvegarde automatique
    cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Édition
    nano "$file"
    
    echo "Fichier édité. Sauvegarde créée."
}

# Usage
safe_edit /etc/hosts
```

## Points clés à retenir

- **nano** : éditeur recommandé pour débuter, interface claire
- **vim** : très puissant mais courbe d'apprentissage raide
- **Modes vim** : Normal (navigation), Insertion (saisie), Commande (:)
- **Raccourcis nano** : Ctrl+O (sauver), Ctrl+X (quitter), Ctrl+W (chercher)
- **Sauvegardes** : toujours sauvegarder avant modification importante
- **Éditeur par défaut** : configurer avec EDITOR=nano
- **Fichiers système** : précautions particulières, vérifier syntaxe

## Exercices pratiques

### Exercice 1 : Maîtriser nano
```bash
# Créer un fichier avec nano
nano test_nano.txt

# Saisir du contenu, rechercher, remplacer
# Pratiquer Ctrl+K (couper), Ctrl+U (coller)
```

### Exercice 2 : Premier pas avec vim
```bash
# Ouvrir vim
vim test_vim.txt

# Mode insertion : i
# Saisir du texte
# Mode normal : Échap
# Sauvegarder et quitter : :wq
```

### Exercice 3 : Configuration pratique
```bash
# Configurer nano
echo "set linenumbers" >> ~/.nanorc

# Tester la configuration
nano ~/.bashrc
```