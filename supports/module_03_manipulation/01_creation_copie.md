# Création, copie, déplacement

## Créer des fichiers avec `touch`

### Principe de base
La commande `touch` permet de créer des fichiers vides ou de modifier les horodatages de fichiers existants.

### Syntaxe
```bash
touch [options] fichier1 [fichier2 ...]
```

### Utilisation simple
```bash
# Créer un fichier vide
touch nouveau_fichier.txt

# Créer plusieurs fichiers à la fois
touch file1.txt file2.txt file3.txt

# Créer des fichiers avec des extensions différentes
touch rapport.pdf notes.md script.sh
```

### Vérifier la création
```bash
ls -la
# -rw-r--r-- 1 john john    0 Jan 15 14:30 nouveau_fichier.txt
```

### Cas d'usage courants
```bash
# Créer une structure de fichiers rapidement
touch projet/{readme.md,config.json,main.py}

# Créer des fichiers de log
touch /var/log/monapp.log

# Créer des fichiers placeholder
touch TODO.txt CHANGELOG.md
```

### Options utiles
```bash
# Modifier seulement la date d'accès
touch -a fichier.txt

# Modifier seulement la date de modification
touch -m fichier.txt

# Utiliser une date spécifique
touch -t 202401151430 fichier_date.txt  # Format: AAAAMMJJHHMM
```

## Créer des répertoires avec `mkdir`

### Syntaxe de base
```bash
mkdir [options] répertoire1 [répertoire2 ...]
```

### Création simple
```bash
# Créer un répertoire
mkdir mon_dossier

# Créer plusieurs répertoires
mkdir docs images scripts

# Vérifier la création
ls -la
# drwxr-xr-x 2 john john 4096 Jan 15 14:30 mon_dossier
```

### Option `-p` : création de hiérarchies
```bash
# Créer une arborescence complète
mkdir -p projets/webapp/src/components
mkdir -p projets/webapp/tests/unit
mkdir -p projets/mobile/{android,ios}/src

# Vérifier avec tree (si installé)
tree projets/
```

### Applications pratiques
```bash
# Structure de projet standard
mkdir -p myproject/{src,tests,docs,config}
mkdir -p myproject/src/{models,views,controllers}

# Organisation par dates
mkdir -p archives/2024/{01,02,03,04,05,06}

# Environnement de développement
mkdir -p dev/{frontend,backend,database,devops}
```

### Permissions à la création
```bash
# Créer avec permissions spécifiques
mkdir -m 755 public_folder
mkdir -m 700 private_folder

# Vérifier les permissions
ls -la
# drwxr-xr-x 2 john john 4096 Jan 15 14:30 public_folder
# drwx------ 2 john john 4096 Jan 15 14:30 private_folder
```

## Copier des fichiers avec `cp`

### Syntaxe
```bash
cp [options] source destination
cp [options] fichier1 [fichier2 ...] répertoire_destination
```

### Copie simple
```bash
# Copier un fichier
cp document.txt sauvegarde_document.txt

# Copier vers un autre répertoire
cp document.txt ~/Documents/

# Copier avec nouveau nom
cp document.txt ~/Documents/rapport_final.txt
```

### Options essentielles

#### `-r` : Copie récursive (répertoires)
```bash
# Copier un répertoire complet
cp -r mon_projet sauvegarde_projet

# Copier vers un autre emplacement
cp -r /home/john/webapp /backup/webapp_backup
```

#### `-i` : Mode interactif (confirmation)
```bash
# Demander confirmation avant écrasement
cp -i fichier.txt existing_file.txt
# cp: overwrite 'existing_file.txt'? y
```

#### `-u` : Copie seulement si plus récent
```bash
# Mise à jour seulement des fichiers modifiés
cp -u source.txt destination.txt
```

#### `-v` : Mode verbeux (affichage détaillé)
```bash
# Voir ce qui est copié
cp -v *.txt backup/
# 'file1.txt' -> 'backup/file1.txt'
# 'file2.txt' -> 'backup/file2.txt'
```

### Combinaisons d'options courantes
```bash
# Copie récursive avec confirmation et détails
cp -riv source_directory/ backup_directory/

# Sauvegarde intelligente (mise à jour uniquement)
cp -ruv documents/ backup/documents/

# Préservation des attributs
cp -a important_data/ backup/important_data/
# (-a équivaut à -dpR : préserve liens, permissions, timestamps)
```

### Cas d'usage pratiques

#### Sauvegarde de fichiers de configuration
```bash
# Sauvegarder avant modification
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
cp ~/.bashrc ~/.bashrc.$(date +%Y%m%d)
```

#### Duplication de structure
```bash
# Dupliquer un projet pour tests
cp -r projet_production/ projet_test/
```

#### Copie sélective avec wildcards
```bash
# Copier tous les fichiers .conf
cp /etc/*.conf ~/backup_config/

# Copier les logs du jour
cp /var/log/*$(date +%Y-%m-%d)* ~/logs_today/
```

## Déplacer/Renommer avec `mv`

### Syntaxe
```bash
mv [options] source destination
mv [options] fichier1 [fichier2 ...] répertoire_destination
```

### Renommage de fichiers
```bash
# Renommer un fichier
mv ancien_nom.txt nouveau_nom.txt

# Renommer un répertoire
mv old_folder new_folder

# Changer l'extension
mv script.txt script.sh
```

### Déplacement de fichiers
```bash
# Déplacer vers un répertoire
mv fichier.txt ~/Documents/

# Déplacer et renommer en une fois
mv rapport.txt ~/Documents/rapport_final.txt

# Déplacer plusieurs fichiers
mv file1.txt file2.txt file3.txt ~/backup/
```

### Options importantes

#### `-i` : Mode interactif
```bash
# Confirmation avant écrasement
mv -i fichier.txt existing_file.txt
# mv: overwrite 'existing_file.txt'? n
```

#### `-u` : Déplacement conditionnel
```bash
# Déplacer seulement si plus récent
mv -u source.txt destination.txt
```

#### `-v` : Mode verbeux
```bash
# Afficher les actions
mv -v *.log logs/
# 'app.log' -> 'logs/app.log'
# 'error.log' -> 'logs/error.log'
```

### Cas pratiques de déplacement

#### Organisation de fichiers
```bash
# Trier par extension
mv *.jpg images/
mv *.txt documents/
mv *.pdf archives/

# Organisation par date
mv *2024-01* archives/janvier/
mv *2024-02* archives/fevrier/
```

#### Renommage en masse
```bash
# Renommer avec préfixe
for file in *.txt; do
    mv "$file" "backup_$file"
done

# Changer toutes les extensions .htm en .html
for file in *.htm; do
    mv "$file" "${file%.htm}.html"
done
```

#### Restructuration de projets
```bash
# Réorganiser la structure
mv src/old_module src/legacy/
mv config/dev.json config/environments/development.json
```

## Différences importantes entre `cp` et `mv`

### Tableau comparatif

| Aspect | `cp` | `mv` |
|--------|------|------|
| **Action** | Copie (crée un duplicata) | Déplace (change d'emplacement) |
| **Fichier source** | Reste inchangé | Est supprimé/déplacé |
| **Espace disque** | Consomme de l'espace | Ne consomme pas d'espace supplémentaire |
| **Répertoires** | Nécessite `-r` | Fonctionne directement |
| **Renommage** | Non (crée une copie) | Oui (même répertoire) |
| **Rapidité** | Plus lent (copie des données) | Plus rapide (change juste les métadonnées) |

### Quand utiliser chaque commande ?

**Utilisez `cp` quand :**
- Vous voulez garder l'original
- Créer une sauvegarde
- Dupliquer pour tests
- Distribution de fichiers

**Utilisez `mv` quand :**
- Réorganisation de fichiers
- Renommage
- Migration de données
- Économie d'espace disque

## Bonnes pratiques et conseils de sécurité

### 1. Toujours vérifier avant d'agir
```bash
# Voir ce qui va être affecté
ls -la source*
ls -la destination/

# Utiliser le mode interactif pour les opérations risquées
cp -i important.txt backup.txt
mv -i file.txt /destination/
```

### 2. Faire des sauvegardes
```bash
# Sauvegarder avant une modification importante
cp fichier_important.txt fichier_important.txt.backup
# Puis modifier...
```

### 3. Utiliser des chemins absolus pour les scripts
```bash
#!/bin/bash
# Bon
cp /home/user/source.txt /backup/source.txt

# Risqué (dépend du répertoire courant)
cp source.txt ../backup/
```

### 4. Gestion des espaces dans les noms
```bash
# Utiliser des guillemets
cp "Mon Document.txt" "Mon Document Backup.txt"
mv "Ancien Nom.txt" "Nouveau Nom.txt"

# Ou échapper les espaces
cp Mon\ Document.txt Mon\ Document\ Backup.txt
```

### 5. Vérifier les résultats
```bash
# Après une copie importante
cp -r projet/ backup_projet/
du -sh projet/ backup_projet/  # Comparer les tailles

# Après un déplacement
mv ancien_emplacement nouveau_emplacement
ls -la nouveau_emplacement  # Vérifier la présence
```

## Commandes avancées et astuces

### Copie avec préservation complète
```bash
# Préserver tous les attributs (équivalent à -dpR)
cp -a source/ destination/

# Préserver les liens symboliques
cp -d lien_symbolique nouveau_lien

# Préserver les permissions et timestamps
cp -p fichier.txt copie_preservee.txt
```

### Gestion des conflits
```bash
# Créer un nom unique si le fichier existe
cp fichier.txt fichier_$(date +%s).txt

# Fonction pour éviter l'écrasement
safe_copy() {
    if [ -e "$2" ]; then
        echo "Le fichier $2 existe déjà"
        return 1
    else
        cp "$1" "$2"
    fi
}
```

### Opérations en masse avec `find`
```bash
# Copier tous les .conf vers backup
find /etc -name "*.conf" -exec cp {} ~/backup_config/ \;

# Déplacer les fichiers anciens
find ~/Downloads -name "*.pdf" -mtime +30 -exec mv {} ~/Archives/ \;
```

## Points clés à retenir

- **`touch`** : créer des fichiers vides ou modifier les timestamps
- **`mkdir -p`** : créer des hiérarchies de répertoires
- **`cp -r`** : copier des répertoires (récursif obligatoire)
- **`mv`** : déplacer ET renommer (même commande)
- **Options importantes** : `-i` (interactif), `-v` (verbeux), `-u` (mise à jour)
- **`cp`** préserve l'original, **`mv`** le déplace
- **Toujours tester** avec des données non critiques d'abord
- **Sauvegarder** avant les opérations importantes

## Exercices pratiques

### Exercice 1 : Création de structure
```bash
# Créer cette arborescence
mkdir -p webapp/{frontend,backend}/{src,tests}
mkdir -p webapp/docs/{api,user}
touch webapp/README.md
touch webapp/frontend/src/{index.html,style.css}
tree webapp/
```

### Exercice 2 : Copie et organisation
```bash
# Créer des fichiers tests
touch doc{1..5}.txt
touch image{1..3}.jpg
touch script{1..2}.sh

# Les organiser
mkdir -p sorted/{documents,images,scripts}
cp *.txt sorted/documents/
cp *.jpg sorted/images/
cp *.sh sorted/scripts/
```

### Exercice 3 : Renommage intelligent
```bash
# Renommer avec date
for file in *.txt; do
    mv "$file" "$(date +%Y%m%d)_$file"
done
```