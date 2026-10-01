# Arborescence Linux

## Concept fondamental : tout est fichier

Dans Linux, **tout est fichier** : les documents, les programmes, les périphériques, les processus, et même les répertoires. Cette philosophie unifie l'accès à toutes les ressources du système.

### Types d'éléments dans le système

- **Fichiers ordinaires** : Documents, programmes, images, etc.
- **Répertoires** : Contenants pour organiser les fichiers
- **Liens** : Raccourcis vers d'autres fichiers ou répertoires
- **Fichiers spéciaux** : Périphériques, processus, informations système

## Structure de l'arborescence

L'arborescence Linux est **hiérarchique** et commence par la **racine** notée `/` (slash).

### Représentation visuelle

```
/                    <- Racine du système
├── bin/            <- Programmes essentiels
├── boot/           <- Fichiers de démarrage
├── dev/            <- Périphériques
├── etc/            <- Configuration système
├── home/           <- Répertoires utilisateurs
│   ├── john/       <- Home de l'utilisateur john
│   └── marie/      <- Home de l'utilisateur marie  
├── lib/            <- Bibliothèques partagées
├── mnt/            <- Points de montage temporaires
├── opt/            <- Logiciels optionnels
├── proc/           <- Informations processus
├── root/           <- Home de l'utilisateur root
├── tmp/            <- Fichiers temporaires
├── usr/            <- Programmes utilisateur
│   ├── bin/        <- Programmes non-essentiels
│   ├── lib/        <- Bibliothèques
│   └── local/      <- Logiciels installés localement
└── var/            <- Données variables
    ├── log/        <- Fichiers de logs
    └── tmp/        <- Autres fichiers temporaires
```

## Les répertoires système principaux

### `/` - La racine
- **Point de départ** de toute l'arborescence
- **Seul répertoire** sans parent
- **Contient** tous les autres répertoires

### `/bin` - Binaires essentiels
- **Programmes** indispensables au système
- **Disponibles** pour tous les utilisateurs
- **Exemples** : ls, cp, mv, cat, bash

```bash
ls /bin | head -5
# Résultat typique :
# bash
# cat  
# cp
# ls
# mv
```

### `/etc` - Configuration système
- **Fichiers de configuration** globaux
- **Paramètres** affectant tout le système
- **Format** principalement textuel

```bash
# Exemples de fichiers importants
ls /etc/passwd    # Informations utilisateurs
ls /etc/hosts     # Correspondances nom/IP
ls /etc/fstab     # Systèmes de fichiers
```

### `/home` - Répertoires personnels
- **Un sous-répertoire** par utilisateur
- **Espace privé** de chaque utilisateur
- **Raccourci** : `~` désigne votre home

```bash
# Structure typique
/home/john/        # Répertoire de john
/home/marie/       # Répertoire de marie
/home/admin/       # Répertoire d'admin
```

### `/usr` - Programmes utilisateur
- **Hiérarchie secondaire** pour les programmes
- **Répertoires** similaires à `/` : bin, lib, etc.
- **Logiciels** installés pour tous les utilisateurs

```bash
/usr/bin/          # Programmes non-essentiels
/usr/lib/          # Bibliothèques partagées
/usr/local/        # Logiciels compilés localement
/usr/share/        # Données partagées (doc, icônes)
```

### `/var` - Données variables
- **Fichiers** qui changent pendant le fonctionnement
- **Logs** du système et des applications
- **Données** temporaires et caches

```bash
/var/log/          # Journaux système
/var/tmp/          # Fichiers temporaires persistants
/var/cache/        # Cache des applications
/var/lib/          # Données d'état des applications
```

### `/tmp` - Fichiers temporaires
- **Accessible** en écriture à tous
- **Contenu supprimé** régulièrement
- **Usage** : fichiers temporaires d'applications

## Répertoires spéciaux

### `/dev` - Périphériques
- **Fichiers spéciaux** représentant les périphériques
- **Interface** entre logiciels et matériel
- **Exemples** :

```bash
/dev/sda1          # Premier disque dur, première partition
/dev/tty1          # Premier terminal
/dev/null          # "Trou noir" - ignore toute entrée
/dev/zero          # Génère des zéros à l'infini
```

### `/proc` - Système de fichiers virtuel
- **Informations** sur les processus et le système
- **Contenu généré** dynamiquement par le noyau
- **Exemples** :

```bash
/proc/cpuinfo      # Informations processeur
/proc/meminfo      # Informations mémoire
/proc/1/           # Informations sur le processus PID 1
```

### `/sys` - Interface sysfs
- **Informations** sur les pilotes et le matériel
- **Alternative moderne** à /proc pour certains aspects
- **Structure hiérarchique** du matériel

## Conventions de nommage

### Règles générales
- **Sensible à la casse** : `File.txt` ≠ `file.txt`
- **Caractères autorisés** : lettres, chiffres, `-`, `_`, `.`
- **Éviter** : espaces, caractères spéciaux
- **Longueur** : jusqu'à 255 caractères

### Fichiers cachés
- **Commencent par un point** : `.bashrc`, `.ssh/`
- **Non affichés** par `ls` par défaut
- **Visibles avec** `ls -a`

### Extensions de fichiers
Linux n'utilise pas les extensions comme Windows, mais par convention :
- `.txt` : fichiers texte
- `.sh` : scripts bash
- `.conf` : fichiers de configuration
- `.log` : fichiers de journalisation

## Navigation dans l'arborescence

### Répertoire courant et chemin
- **Répertoire courant** : où vous vous trouvez actuellement
- **Affiché par** : `pwd` (Print Working Directory)
- **Changement avec** : `cd` (Change Directory)

### Répertoires spéciaux
- `.` : répertoire courant
- `..` : répertoire parent
- `~` : répertoire personnel (home)
- `-` : répertoire précédent (avec cd)

```bash
# Exemples de navigation
cd /etc          # Aller dans /etc
pwd              # Affiche : /etc
cd ..            # Remonter au parent (/)
cd ~             # Aller au répertoire personnel
cd -             # Retourner au répertoire précédent (/etc)
```

## Permissions et propriétés

### Affichage des informations
```bash
ls -la /
# Résultat typique :
drwxr-xr-x  17 root root  4096 Jan 15 10:30 .
drwxr-xr-x  17 root root  4096 Jan 15 10:30 ..
drwxr-xr-x   2 root root  4096 Jan 10 09:15 bin
drwxr-xr-x   4 root root  4096 Jan 10 09:20 boot
```

### Interprétation
- **Premier caractère** : type (d=répertoire, -=fichier)
- **Permissions** : rwx pour propriétaire, groupe, autres
- **Propriétaire/Groupe** : qui possède le fichier
- **Taille** : en octets
- **Date** : dernière modification

## Comparaison avec Windows

| Aspect | Windows | Linux |
|--------|---------|-------|
| **Racine** | C:/, D:/ | / |
| **Séparateur** | \ (backslash) | / (slash) |
| **Casse** | Insensible | Sensible |
| **Fichiers cachés** | Attribut caché | Nom commence par . |
| **Lecteurs** | Lettres (C:, D:) | Montés dans l'arborescence |

### Équivalences approximatives

| Windows | Linux | Usage |
|---------|-------|-------|
| `C:\Windows\` | `/etc/` | Configuration système |
| `C:\Program Files\` | `/usr/` | Programmes installés |
| `C:\Users\` | `/home/` | Répertoires utilisateurs |
| `C:\Temp\` | `/tmp/` | Fichiers temporaires |

## Points clés à retenir

- **Racine unique** `/` pour toute l'arborescence
- **Séparateurs** : `/` (slash) et non `\` (backslash)
- **Sensible à la casse** : `File` ≠ `file`
- **Fichiers cachés** commencent par `.`
- **`/home/`** contient les répertoires utilisateurs
- **`/etc/`** contient la configuration système
- **`pwd`** pour savoir où on est
- **`~`** raccourci vers son répertoire personnel

## Exercices de compréhension

### Questions
1. Quel est le répertoire racine sous Linux ?
2. Où se trouvent les fichiers de configuration système ?
3. Comment s'appelle le répertoire personnel d'un utilisateur ?
4. Que signifie le caractère `~` ?
5. Quelle différence entre `/bin` et `/usr/bin` ?

### Réponses
1. `/` (slash)
2. Dans `/etc/`
3. `/home/nom_utilisateur/`
4. Le répertoire personnel de l'utilisateur courant
5. `/bin` contient les programmes essentiels, `/usr/bin` les programmes non-essentiels