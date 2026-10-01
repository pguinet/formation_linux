# TP 1 : Gestion complète des fichiers

## Objectifs

À la fin de ce TP, vous saurez :
- Créer et organiser des structures de fichiers et répertoires
- Copier, déplacer et renommer efficacement
- Utiliser les outils de recherche de fichiers
- Manipuler les fichiers en toute sécurité

## Durée estimée
60 minutes

---

## Partie A : Création et organisation

### Exercice 1 : Créer une structure de projet

1. **Préparer l'environnement**
   ```bash
   cd ~
   mkdir tp_gestion_fichiers
   cd tp_gestion_fichiers
   ```

2. **Créer une structure complète de projet**
   ```bash
   # Créer l'arborescence d'un projet web
   mkdir -p webapp/{frontend,backend,database}
   mkdir -p webapp/frontend/{src,tests,build}
   mkdir -p webapp/backend/{api,models,config}
   mkdir -p webapp/database/{migrations,seeds}
   mkdir -p webapp/docs/{user,api,deployment}
   ```

3. **Créer des fichiers dans la structure**
   ```bash
   # Frontend
   touch webapp/frontend/src/{index.html,style.css,app.js}
   touch webapp/frontend/tests/{test1.js,test2.js}
   
   # Backend
   touch webapp/backend/api/{users.py,auth.py,products.py}
   touch webapp/backend/models/{user.py,product.py}
   touch webapp/backend/config/{settings.py,database.py}
   
   # Documentation
   touch webapp/docs/{README.md,INSTALL.md,CHANGELOG.md}
   ```

4. **Vérifier la structure créée**
   ```bash
   tree webapp/
   ```

### Exercice 2 : Remplir les fichiers avec du contenu

1. **Créer du contenu pour les fichiers principaux**
   ```bash
   # README principal
   cat > webapp/README.md << EOF
   # Mon Projet Web
   
   Application web moderne avec frontend et backend séparés.
   
   ## Structure
   - frontend/ : Interface utilisateur
   - backend/ : API et logique métier
   - database/ : Scripts de base de données
   - docs/ : Documentation
   EOF
   
   # Fichier HTML de base
   cat > webapp/frontend/src/index.html << EOF
   <!DOCTYPE html>
   <html>
   <head>
       <title>Mon App</title>
       <link rel="stylesheet" href="style.css">
   </head>
   <body>
       <h1>Bienvenue sur Mon App</h1>
       <script src="app.js"></script>
   </body>
   </html>
   EOF
   
   # Configuration Python
   cat > webapp/backend/config/settings.py << EOF
   # Configuration de l'application
   DEBUG = True
   DATABASE_URL = "sqlite:///app.db"
   SECRET_KEY = "dev-key-not-for-production"
   EOF
   ```

2. **Vérifier le contenu créé**
   ```bash
   ls -la webapp/frontend/src/
   cat webapp/README.md
   ```

---

## Partie B : Opérations de copie et sauvegarde

### Exercice 3 : Sauvegardes intelligentes

1. **Créer une sauvegarde complète**
   ```bash
   # Sauvegarde avec date
   cp -r webapp/ webapp_backup_$(date +%Y%m%d)
   
   # Vérifier la sauvegarde
   ls -la
   du -sh webapp*
   ```

2. **Sauvegarde sélective**
   ```bash
   # Copier seulement les fichiers de configuration
   mkdir config_backup
   find webapp/ -name "*.py" -path "*/config/*" -exec cp {} config_backup/ \;
   ls config_backup/
   ```

3. **Copie avec préservation des attributs**
   ```bash
   # Modifier quelques permissions pour le test
   chmod 755 webapp/backend/api/users.py
   chmod 644 webapp/frontend/src/index.html
   
   # Copier en préservant tout
   cp -a webapp/ webapp_preserved/
   
   # Vérifier que les permissions sont préservées
   ls -la webapp/backend/api/users.py
   ls -la webapp_preserved/backend/api/users.py
   ```

### Exercice 4 : Organisation et déplacement

1. **Réorganiser les fichiers de documentation**
   ```bash
   # Créer une structure de doc plus organisée
   mkdir -p documentation/{guides,references,examples}
   
   # Déplacer les fichiers existants
   mv webapp/docs/*.md documentation/guides/
   
   # Créer de nouveaux fichiers de référence
   touch documentation/references/{api_reference.md,database_schema.md}
   touch documentation/examples/{tutorial1.md,tutorial2.md}
   ```

2. **Renommage intelligent**
   ```bash
   # Renommer les fichiers de test avec un préfixe
   cd webapp/frontend/tests/
   for file in test*.js; do
       mv "$file" "unit_$file"
   done
   ls -la
   cd ~/tp_gestion_fichiers
   ```

3. **Déplacement conditionnel**
   ```bash
   # Créer des fichiers avec différentes extensions
   touch webapp/{file1.txt,file2.log,file3.tmp,file4.bak}
   
   # Organiser par type
   mkdir -p sorted/{text_files,log_files,temp_files}
   mv webapp/*.txt sorted/text_files/ 2>/dev/null || true
   mv webapp/*.log sorted/log_files/ 2>/dev/null || true
   mv webapp/*.tmp sorted/temp_files/ 2>/dev/null || true
   
   # Supprimer les fichiers de sauvegarde
   rm -f webapp/*.bak
   ```

---

## Partie C : Recherche de fichiers

### Exercice 5 : Recherche par nom et type

1. **Recherches de base**
   ```bash
   # Trouver tous les fichiers .py
   find . -name "*.py"
   
   # Trouver tous les fichiers de configuration
   find . -name "*config*"
   
   # Trouver tous les README (insensible à la casse)
   find . -iname "*readme*"
   ```

2. **Compléter le tableau de recherche** :

   | Commande | Nombre de résultats | Premier résultat trouvé |
   |----------|---------------------|-------------------------|
   | `find . -name "*.py"` | | |
   | `find . -name "*config*"` | | |
   | `find . -type d -name "*test*"` | | |

### Exercice 6 : Recherche avancée

1. **Recherche par taille et date**
   ```bash
   # Créer des fichiers de tailles différentes pour le test
   dd if=/dev/zero of=webapp/big_file.dat bs=1024 count=100  # 100KB
   dd if=/dev/zero of=webapp/small_file.dat bs=100 count=1   # 100 bytes
   
   # Trouver les gros fichiers (plus de 50KB)
   find . -type f -size +50k
   
   # Fichiers modifiés dans les 5 dernières minutes
   find . -type f -mmin -5
   
   # Fichiers vides
   find . -type f -empty
   ```

2. **Recherche avec actions**
   ```bash
   # Lister les détails des fichiers Python
   find . -name "*.py" -exec ls -la {} \;
   
   # Compter les lignes dans tous les fichiers .md
   find . -name "*.md" -exec wc -l {} \;
   
   # Copier tous les .js vers un dossier
   mkdir js_files
   find . -name "*.js" -exec cp {} js_files/ \;
   ls js_files/
   ```

### Exercice 7 : Utiliser locate et which

1. **Tester locate (si disponible)**
   ```bash
   # Mettre à jour la base de données (peut nécessiter sudo)
   sudo updatedb 2>/dev/null || echo "updatedb non disponible ou pas de droits sudo"
   
   # Chercher des fichiers système
   locate passwd | head -5
   locate "*.conf" | head -10
   ```

2. **Localiser les commandes**
   ```bash
   # Où se trouvent les commandes que nous utilisons ?
   which find
   which tar
   which python
   which python3
   
   # Informations complètes
   whereis find
   whereis python
   ```

---

## Partie D : Suppression sécurisée

### Exercice 8 : Nettoyage contrôlé

1. **Créer des fichiers à nettoyer**
   ```bash
   # Créer différents types de fichiers temporaires
   touch webapp/{temp1.tmp,temp2.tmp,backup.bak,old.swp}
   touch webapp/.hidden_temp
   echo "log entry" > webapp/debug.log
   ```

2. **Nettoyage sécurisé étape par étape**
   ```bash
   # D'abord, voir ce qui va être supprimé
   find . -name "*.tmp" -type f
   
   # Supprimer avec confirmation
   find . -name "*.tmp" -type f -exec rm -i {} \;
   
   # Supprimer les fichiers .bak directement
   find . -name "*.bak" -delete
   
   # Vérifier que les fichiers voulus ont été supprimés
   ls -la webapp/
   ```

3. **Créer une fonction de nettoyage sécurisée**
   ```bash
   # Définir une fonction de suppression sécurisée
   safe_cleanup() {
       echo "Fichiers qui seraient supprimés :"
       find "$1" -name "*.tmp" -o -name "*.bak" -o -name "*.swp"
       echo ""
       read -p "Continuer la suppression ? (oui/non) : " confirm
       if [ "$confirm" = "oui" ]; then
           find "$1" -name "*.tmp" -delete
           find "$1" -name "*.bak" -delete  
           find "$1" -name "*.swp" -delete
           echo "Nettoyage terminé."
       else
           echo "Nettoyage annulé."
       fi
   }
   
   # Tester la fonction
   touch webapp/test.tmp
   safe_cleanup webapp/
   ```

### Exercice 9 : Suppression de répertoires

1. **Préparer des répertoires de test**
   ```bash
   # Créer des répertoires avec et sans contenu
   mkdir empty_dir
   mkdir non_empty_dir
   touch non_empty_dir/some_file.txt
   ```

2. **Tester les différentes méthodes**
   ```bash
   # Supprimer un répertoire vide
   rmdir empty_dir
   
   # Essayer rmdir sur un répertoire non vide (échouera)
   rmdir non_empty_dir 2>/dev/null || echo "Erreur : répertoire non vide"
   
   # Supprimer avec rm -r (avec confirmation)
   rm -ri non_empty_dir
   ```

---

## Partie E : Cas pratiques et défis

### Exercice 10 : Réorganisation de projet

**Scénario** : Le projet a évolué et vous devez réorganiser la structure.

1. **Nouvelle organisation souhaitée**
   ```
   webapp_v2/
   ├── client/          (ancien frontend)
   ├── server/          (ancien backend) 
   ├── database/        (inchangé)
   ├── documentation/   (docs existantes)
   └── scripts/         (nouveau)
   ```

2. **Effectuer la migration**
   ```bash
   # Créer la nouvelle structure
   mkdir -p webapp_v2/{client,server,database,documentation,scripts}
   
   # Migrer les contenus
   cp -r webapp/frontend/* webapp_v2/client/
   cp -r webapp/backend/* webapp_v2/server/
   cp -r webapp/database/* webapp_v2/database/
   cp -r documentation/* webapp_v2/documentation/
   
   # Créer des scripts utiles
   cat > webapp_v2/scripts/start_dev.sh << EOF
   #!/bin/bash
   echo "Démarrage de l'environnement de développement..."
   # Commandes de démarrage ici
   EOF
   chmod +x webapp_v2/scripts/start_dev.sh
   ```

3. **Vérifier la migration**
   ```bash
   tree webapp_v2/
   
   # Comparer les tailles
   du -sh webapp/ webapp_v2/
   ```

### Exercice 11 : Script de maintenance

1. **Créer un script de maintenance complet**
   ```bash
   cat > maintenance.sh << 'EOF'
   #!/bin/bash
   # Script de maintenance du projet
   
   PROJECT_DIR="webapp_v2"
   
   echo "=== Maintenance du projet $PROJECT_DIR ==="
   
   # Statistiques générales
   echo "Taille totale du projet :"
   du -sh "$PROJECT_DIR"
   
   echo -e "\nNombre de fichiers par type :"
   find "$PROJECT_DIR" -name "*.py" | wc -l | sed 's/^/  Fichiers Python: /'
   find "$PROJECT_DIR" -name "*.js" | wc -l | sed 's/^/  Fichiers JavaScript: /'
   find "$PROJECT_DIR" -name "*.html" | wc -l | sed 's/^/  Fichiers HTML: /'
   find "$PROJECT_DIR" -name "*.css" | wc -l | sed 's/^/  Fichiers CSS: /'
   find "$PROJECT_DIR" -name "*.md" | wc -l | sed 's/^/  Fichiers Markdown: /'
   
   # Fichiers volumineux
   echo -e "\nFichiers les plus volumineux :"
   find "$PROJECT_DIR" -type f -exec ls -lh {} \; | sort -k5 -hr | head -5
   
   # Fichiers récents
   echo -e "\nFichiers modifiés récemment :"
   find "$PROJECT_DIR" -type f -mtime -1 -exec ls -la {} \;
   
   echo -e "\n=== Fin de la maintenance ==="
   EOF
   
   chmod +x maintenance.sh
   ```

2. **Exécuter le script de maintenance**
   ```bash
   ./maintenance.sh
   ```

### Exercice 12 : Défi de recherche complexe

**Objectif** : Trouver tous les fichiers Python qui contiennent le mot "config" et les copier dans un dossier spécial.

1. **Créer du contenu pour le test**
   ```bash
   # Ajouter du contenu avec "config" dans certains fichiers Python
   echo "import config" >> webapp_v2/server/api/users.py
   echo "from config import settings" >> webapp_v2/server/models/user.py
   echo "# Configuration file" >> webapp_v2/server/config/settings.py
   ```

2. **Recherche et extraction**
   ```bash
   # Créer le dossier de destination
   mkdir config_files
   
   # Trouver les fichiers Python contenant "config"
   find webapp_v2/ -name "*.py" -exec grep -l "config" {} \;
   
   # Les copier vers le dossier spécial
   find webapp_v2/ -name "*.py" -exec grep -l "config" {} \; | xargs -I {} cp {} config_files/
   
   # Vérifier le résultat
   ls config_files/
   echo "Contenu des fichiers copiés :"
   for file in config_files/*.py; do
       echo "=== $file ==="
       cat "$file"
       echo ""
   done
   ```

---

## Partie F : Validation et nettoyage

### Questions de contrôle

1. **Commandes de base** :
   - Comment créer un répertoire et tous ses parents ? ________________
   - Différence entre `cp` et `mv` : ________________
   - Comment supprimer un répertoire non vide ? ________________

2. **Recherche** :
   - Trouver tous les fichiers .txt dans /home : ________________
   - Trouver les fichiers plus gros que 10MB : ________________
   - Exécuter `ls -la` sur tous les fichiers trouvés : ________________

3. **Sécurité** :
   - Option pour demander confirmation avant suppression : ________________
   - Comment voir ce qui va être supprimé avant de le faire : ________________

### Test pratique final

**Défi** : En une seule ligne de commande, trouvez tous les fichiers .py modifiés dans les dernières 24h et affichez leur taille.

```bash
# Votre commande ici :
_________________________________________________
```

### Nettoyage de l'environnement

```bash
# Nettoyer l'espace de travail
cd ~
rm -rf tp_gestion_fichiers

# Vérifier que tout est supprimé
ls | grep tp_gestion
```

---

## Solutions

### Solutions Questions de contrôle
1. `mkdir -p`, `cp` copie/`mv` déplace, `rm -r` ou `rm -rf`
2. `find /home -name "*.txt"`, `find . -size +10M`, `find . -name "*.py" -exec ls -la {} \;`
3. `-i`, `ls` ou `find` avant la commande de suppression

### Solution Défi final
```bash
find . -name "*.py" -mtime -1 -exec ls -lh {} \;
```

---

## Points clés à retenir

- **Organisation** : `mkdir -p` pour créer des hiérarchies
- **Copie sécurisée** : `cp -i` pour éviter les écrasements
- **Recherche puissante** : `find` avec critères multiples
- **Actions en lot** : `find ... -exec` pour traiter les résultats
- **Suppression prudente** : toujours vérifier avant de supprimer
- **Scripts** : automatiser les tâches répétitives
- **Vérification** : `tree`, `ls -la`, `du` pour contrôler les résultats

## Pour aller plus loin

Si vous terminez en avance :

1. **Explorez les liens symboliques**
   ```bash
   ln -s webapp_v2/client/src client_src
   ls -la client_src
   ```

2. **Créez des alias personnalisés**
   ```bash
   alias ll='ls -la'
   alias findpy='find . -name "*.py"'
   ```