# TP 2 : Archivage et compression

## Objectifs

À la fin de ce TP, vous saurez :
- Créer et extraire des archives tar avec différentes compressions
- Choisir le bon format selon le contexte
- Utiliser les archives pour la sauvegarde et la distribution
- Automatiser les tâches d'archivage

## Durée estimée
50 minutes

---

## Partie A : Création d'archives de base

### Exercice 1 : Préparer les données test

1. **Créer l'environnement de travail**
   ```bash
   cd ~
   mkdir tp_archivage
   cd tp_archivage
   ```

2. **Créer une structure de données variée**
   ```bash
   # Projet de démonstration
   mkdir -p demo_project/{src,docs,tests,config}
   
   # Fichiers sources
   echo "print('Hello World')" > demo_project/src/main.py
   echo "def test_main(): pass" > demo_project/tests/test_main.py
   echo "# Configuration\nDEBUG=True" > demo_project/config/settings.py
   
   # Documentation
   cat > demo_project/docs/README.md << EOF
   # Projet de Démonstration
   
   Ce projet sert à tester les fonctionnalités d'archivage.
   
   ## Structure
   - src/ : Code source
   - tests/ : Tests unitaires
   - config/ : Configuration
   - docs/ : Documentation
   EOF
   
   # Fichiers de différentes tailles
   echo "Petit fichier" > demo_project/small_file.txt
   dd if=/dev/zero of=demo_project/medium_file.dat bs=1024 count=50  # 50KB
   dd if=/dev/zero of=demo_project/big_file.dat bs=1024 count=500    # 500KB
   ```

3. **Vérifier la structure créée**
   ```bash
   tree demo_project/
   du -sh demo_project/
   ```

### Exercice 2 : Archives tar de base

1. **Créer une archive tar simple (sans compression)**
   ```bash
   # Archive basique
   tar -cvf demo_basic.tar demo_project/
   
   # Vérifier la création
   ls -lh demo_basic.tar
   ```

2. **Lister le contenu de l'archive**
   ```bash
   # Voir le contenu sans extraire
   tar -tvf demo_basic.tar
   
   # Avec plus de détails
   tar -tvf demo_basic.tar | head -10
   ```

3. **Compléter le tableau d'information** :

   | Archive | Taille | Nombre de fichiers | Répertoire racine |
   |---------|--------|--------------------|--------------------|
   | demo_basic.tar | | | |

---

## Partie B : Compression et formats

### Exercice 3 : Tester les différentes compressions

1. **Créer des archives avec différentes compressions**
   ```bash
   # Archive gzip (rapide, compression correcte)
   tar -czvf demo_gzip.tar.gz demo_project/
   
   # Archive bzip2 (plus lent, meilleure compression)
   tar -cjvf demo_bzip2.tar.bz2 demo_project/
   
   # Archive xz (plus lent, excellente compression)
   tar -cJvf demo_xz.tar.xz demo_project/
   ```

2. **Comparer les tailles et temps**
   ```bash
   # Afficher toutes les archives avec leurs tailles
   ls -lh demo_*.tar*
   
   # Calculer les ratios de compression
   echo "=== Comparaison des compressions ==="
   original_size=$(du -sb demo_project/ | cut -f1)
   echo "Taille originale: $(du -sh demo_project/ | cut -f1)"
   
   for archive in demo_*.tar*; do
       size=$(stat -c%s "$archive")
       ratio=$(echo "scale=1; $size * 100 / $original_size" | bc)
       echo "$archive: $(ls -lh $archive | awk '{print $5}') (${ratio}% de l'original)"
   done
   ```

3. **Noter les résultats** :

   | Format | Taille | Ratio | Temps (subjectif) |
   |--------|--------|-------|-------------------|
   | .tar | | 100% | Très rapide |
   | .tar.gz | | | |
   | .tar.bz2 | | | |
   | .tar.xz | | | |

### Exercice 4 : Archives avec exclusions

1. **Créer des fichiers à exclure**
   ```bash
   # Ajouter des fichiers temporaires et de log
   touch demo_project/{debug.log,temp.tmp,backup.bak}
   touch demo_project/.hidden_temp
   mkdir demo_project/.cache
   echo "cache data" > demo_project/.cache/data.txt
   ```

2. **Archive avec exclusions**
   ```bash
   # Exclure par pattern
   tar -czvf demo_clean.tar.gz \
       --exclude="*.tmp" \
       --exclude="*.log" \
       --exclude="*.bak" \
       --exclude=".cache" \
       demo_project/
   
   # Comparer avec l'archive complète
   ls -lh demo_gzip.tar.gz demo_clean.tar.gz
   ```

3. **Archive avec fichier d'exclusion**
   ```bash
   # Créer un fichier d'exclusions
   cat > exclude_list.txt << EOF
   *.tmp
   *.log
   *.bak
   .cache/
   __pycache__/
   .git/
   EOF
   
   # Utiliser le fichier d'exclusion
   tar -czvf demo_excluded.tar.gz --exclude-from=exclude_list.txt demo_project/
   
   # Vérifier que les exclusions ont fonctionné
   tar -tzf demo_excluded.tar.gz | grep -E '\.(tmp|log|bak)$' || echo "Aucun fichier exclu trouvé - OK"
   ```

---

## Partie C : Extraction et manipulation

### Exercice 5 : Extraction contrôlée

1. **Extraction de base**
   ```bash
   # Créer un répertoire de test d'extraction
   mkdir test_extract
   cd test_extract
   
   # Extraire l'archive
   tar -xzvf ../demo_gzip.tar.gz
   
   # Vérifier le résultat
   ls -la
   tree demo_project/
   cd ..
   ```

2. **Extraction vers un répertoire spécifique**
   ```bash
   # Créer un répertoire de destination
   mkdir extracted_here
   
   # Extraire vers ce répertoire
   tar -xzvf demo_gzip.tar.gz -C extracted_here/
   
   # Vérifier
   ls extracted_here/
   ```

3. **Extraction sélective**
   ```bash
   # Extraire seulement la documentation
   mkdir docs_only
   tar -xzvf demo_gzip.tar.gz -C docs_only/ demo_project/docs/
   
   # Extraire avec pattern
   mkdir config_only
   tar -xzvf demo_gzip.tar.gz -C config_only/ --wildcards "*/config/*"
   
   # Vérifier les extractions sélectives
   ls -la docs_only/demo_project/
   ls -la config_only/demo_project/
   ```

### Exercice 6 : Modification d'archives

1. **Ajouter des fichiers à une archive existante**
   ```bash
   # Créer un nouveau fichier
   echo "Nouveau fichier ajouté après création" > new_file.txt
   
   # Ajouter à l'archive (attention : ne fonctionne qu'avec .tar)
   tar -rvf demo_basic.tar new_file.txt
   
   # Vérifier l'ajout
   tar -tvf demo_basic.tar | tail -5
   ```

2. **Mettre à jour une archive**
   ```bash
   # Modifier un fichier existant
   echo "Contenu mis à jour" >> demo_project/src/main.py
   
   # Mettre à jour l'archive (seulement si plus récent)
   tar -uvf demo_basic.tar demo_project/src/main.py
   
   # Vérifier la mise à jour
   tar -tvf demo_basic.tar | grep "main.py"
   ```

---

## Partie D : Formats alternatifs

### Exercice 7 : Archives ZIP

1. **Créer des archives ZIP**
   ```bash
   # Archive ZIP basique
   zip -r demo_project.zip demo_project/
   
   # ZIP avec compression maximale
   zip -r -9 demo_project_max.zip demo_project/
   
   # ZIP avec exclusions
   zip -r demo_project_clean.zip demo_project/ -x "*.tmp" "*.log" "*.bak"
   ```

2. **Manipuler les archives ZIP**
   ```bash
   # Lister le contenu
   unzip -l demo_project.zip | head -20
   
   # Tester l'intégrité
   unzip -t demo_project.zip
   
   # Extraire vers un répertoire
   mkdir zip_extract
   unzip demo_project.zip -d zip_extract/
   ```

3. **Comparer ZIP vs TAR.GZ**
   ```bash
   # Comparaison des tailles
   echo "=== Comparaison ZIP vs TAR.GZ ==="
   ls -lh demo_project.zip demo_gzip.tar.gz
   
   # Noter vos observations sur la compatibilité et l'usage
   ```

### Exercice 8 : Archives 7z (si disponible)

1. **Installer et tester 7z**
   ```bash
   # Vérifier si 7z est disponible
   which 7z || echo "7z non installé"
   
   # Si disponible, créer une archive 7z
   if command -v 7z > /dev/null; then
       7z a demo_project.7z demo_project/
       
       # Comparer la taille
       ls -lh demo_project.7z demo_gzip.tar.gz demo_project.zip
       
       # Lister le contenu
       7z l demo_project.7z | head -20
   else
       echo "7z n'est pas installé - exercice ignoré"
   fi
   ```

---

## Partie E : Sauvegarde et automatisation

### Exercice 9 : Système de sauvegarde

1. **Créer un script de sauvegarde**
   ```bash
   cat > backup_script.sh << 'EOF'
   #!/bin/bash
   # Script de sauvegarde automatisée
   
   # Configuration
   SOURCE_DIR="demo_project"
   BACKUP_DIR="backups"
   DATE=$(date +%Y%m%d_%H%M%S)
   
   # Créer le répertoire de sauvegarde
   mkdir -p "$BACKUP_DIR"
   
   # Nom de l'archive
   ARCHIVE_NAME="$BACKUP_DIR/backup_${DATE}.tar.gz"
   
   echo "Début de la sauvegarde..."
   echo "Source: $SOURCE_DIR"
   echo "Destination: $ARCHIVE_NAME"
   
   # Créer l'archive avec exclusions
   tar -czvf "$ARCHIVE_NAME" \
       --exclude="*.tmp" \
       --exclude="*.log" \
       --exclude=".cache" \
       "$SOURCE_DIR"
   
   # Afficher les informations
   echo "Sauvegarde terminée:"
   ls -lh "$ARCHIVE_NAME"
   
   # Nettoyer les sauvegardes anciennes (garder les 3 plus récentes)
   ls -t "$BACKUP_DIR"/backup_*.tar.gz | tail -n +4 | xargs rm -f
   
   echo "Sauvegardes actuelles:"
   ls -la "$BACKUP_DIR"
   EOF
   
   chmod +x backup_script.sh
   ```

2. **Tester le script de sauvegarde**
   ```bash
   # Exécuter plusieurs fois pour tester la rotation
   ./backup_script.sh
   sleep 2
   ./backup_script.sh
   sleep 2
   ./backup_script.sh
   
   # Vérifier les sauvegardes créées
   ls -la backups/
   ```

### Exercice 10 : Script de restauration

1. **Créer un script de restauration**
   ```bash
   cat > restore_script.sh << 'EOF'
   #!/bin/bash
   # Script de restauration
   
   if [ $# -ne 2 ]; then
       echo "Usage: $0 <archive.tar.gz> <destination>"
       echo "Archives disponibles:"
       ls -la backups/*.tar.gz 2>/dev/null || echo "Aucune archive trouvée"
       exit 1
   fi
   
   ARCHIVE="$1"
   DESTINATION="$2"
   
   if [ ! -f "$ARCHIVE" ]; then
       echo "Erreur: Archive $ARCHIVE introuvable"
       exit 1
   fi
   
   echo "Restauration de $ARCHIVE vers $DESTINATION"
   
   # Créer le répertoire de destination
   mkdir -p "$DESTINATION"
   
   # Extraire l'archive
   tar -xzvf "$ARCHIVE" -C "$DESTINATION"
   
   echo "Restauration terminée"
   ls -la "$DESTINATION"
   EOF
   
   chmod +x restore_script.sh
   ```

2. **Tester la restauration**
   ```bash
   # Supprimer le projet original (simulation de perte)
   mv demo_project demo_project_original
   
   # Trouver la sauvegarde la plus récente
   latest_backup=$(ls -t backups/backup_*.tar.gz | head -n 1)
   echo "Restauration depuis: $latest_backup"
   
   # Restaurer
   ./restore_script.sh "$latest_backup" restored/
   
   # Vérifier la restauration
   diff -r demo_project_original/ restored/demo_project/
   echo "Restauration $([ $? -eq 0 ] && echo 'réussie' || echo 'échouée')"
   ```

---

## Partie F : Cas pratiques avancés

### Exercice 11 : Distribution de logiciel

1. **Préparer une distribution propre**
   ```bash
   # Simuler un projet de développement
   mkdir -p software_project/{src,docs,examples,tests}
   
   # Code source
   echo "#!/usr/bin/env python3" > software_project/src/main.py
   echo "print('Software v1.0')" >> software_project/src/main.py
   
   # Documentation
   cat > software_project/README.md << EOF
   # Mon Logiciel v1.0
   
   ## Installation
   1. Extraire l'archive
   2. Exécuter: python3 src/main.py
   
   ## Licence
   MIT License
   EOF
   
   # Fichiers à exclure de la distribution
   touch software_project/{.gitignore,.env,debug.log}
   mkdir software_project/{.git,__pycache__}
   touch software_project/.git/config
   touch software_project/__pycache__/main.cpython-39.pyc
   ```

2. **Créer l'archive de distribution**
   ```bash
   # Archive de distribution propre
   tar -czvf software-v1.0.tar.gz \
       --exclude=".git*" \
       --exclude="__pycache__" \
       --exclude="*.pyc" \
       --exclude=".env" \
       --exclude="debug.log" \
       --transform 's,^software_project,software-v1.0,' \
       software_project/
   
   # Vérifier le contenu (le répertoire racine doit être renommé)
   tar -tzf software-v1.0.tar.gz | head -10
   ```

### Exercice 12 : Sauvegarde incrémentale

1. **Préparer les données pour la sauvegarde incrémentale**
   ```bash
   # Restaurer le projet original
   mv demo_project_original demo_project
   
   # Créer la première sauvegarde complète
   tar -czvf backup_full.tar.gz \
       --listed-incremental=backup.snar \
       demo_project/
   
   echo "Sauvegarde complète créée:"
   ls -lh backup_full.tar.gz
   ```

2. **Simuler des modifications et sauvegarde incrémentale**
   ```bash
   # Attendre un moment et modifier des fichiers
   sleep 2
   echo "Nouvelle ligne" >> demo_project/src/main.py
   touch demo_project/nouveau_fichier.txt
   
   # Sauvegarde incrémentale
   tar -czvf backup_incremental.tar.gz \
       --listed-incremental=backup.snar \
       demo_project/
   
   echo "Sauvegarde incrémentale créée:"
   ls -lh backup_*.tar.gz
   
   echo "Contenu de la sauvegarde incrémentale:"
   tar -tzf backup_incremental.tar.gz
   ```

---

## Partie G : Vérification et maintenance

### Exercice 13 : Contrôle d'intégrité

1. **Créer des checksums pour les archives**
   ```bash
   # Générer les checksums
   md5sum *.tar.gz > archives.md5
   sha256sum *.tar.gz > archives.sha256
   
   # Afficher les checksums
   cat archives.md5
   ```

2. **Vérifier l'intégrité**
   ```bash
   # Vérifier avec md5
   md5sum -c archives.md5
   
   # Tester une archive corrompue (simulation)
   cp demo_gzip.tar.gz demo_test_corrupt.tar.gz
   echo "corruption" >> demo_test_corrupt.tar.gz
   
   # Tester l'intégrité de l'archive corrompue
   tar -tzf demo_test_corrupt.tar.gz > /dev/null && echo "Archive OK" || echo "Archive corrompue"
   ```

### Exercice 14 : Nettoyage et statistiques

1. **Script de statistiques d'archives**
   ```bash
   cat > archive_stats.sh << 'EOF'
   #!/bin/bash
   
   echo "=== Statistiques des archives ==="
   echo ""
   
   total_size=0
   archive_count=0
   
   echo "Archives trouvées:"
   for archive in *.tar* *.zip *.7z 2>/dev/null; do
       if [ -f "$archive" ]; then
           size=$(stat -c%s "$archive" 2>/dev/null || echo 0)
           size_mb=$(echo "scale=2; $size/1024/1024" | bc)
           echo "  $archive: ${size_mb}MB"
           total_size=$((total_size + size))
           archive_count=$((archive_count + 1))
       fi
   done
   
   if [ $archive_count -gt 0 ]; then
       total_mb=$(echo "scale=2; $total_size/1024/1024" | bc)
       echo ""
       echo "Total: $archive_count archives, ${total_mb}MB"
   else
       echo "Aucune archive trouvée"
   fi
   EOF
   
   chmod +x archive_stats.sh
   ./archive_stats.sh
   ```

2. **Nettoyage final**
   ```bash
   # Lister toutes les archives créées
   ls -lh *.tar* *.zip 2>/dev/null
   
   # Garder seulement les archives importantes
   mkdir final_archives
   cp demo_gzip.tar.gz software-v1.0.tar.gz final_archives/
   
   # Nettoyer les fichiers temporaires
   rm -f demo_*.tar* *.zip backup_*.tar.gz
   rm -f *.md5 *.sha256 exclude_list.txt
   
   echo "Archives finales conservées:"
   ls -la final_archives/
   ```

---

## Questions de validation

1. **Formats d'archives** :
   - Commande pour créer une archive tar.gz : ________________
   - Différence entre tar.gz et tar.bz2 : ________________
   - Comment exclure des fichiers lors de l'archivage : ________________

2. **Utilisation** :
   - Extraire une archive vers un répertoire spécifique : ________________
   - Lister le contenu d'une archive sans l'extraire : ________________
   - Format recommandé pour la distribution : ________________

3. **Maintenance** :
   - Comment vérifier l'intégrité d'une archive : ________________
   - Avantage des sauvegardes incrémentales : ________________

---

## Solutions

### Solutions des questions
1. `tar -czvf`, bzip2 compresse mieux mais plus lent, `--exclude="pattern"`
2. `tar -xzf archive.tar.gz -C /destination/`, `tar -tzf archive.tar.gz`, zip ou tar.gz
3. `tar -tzf` ou checksums, économie d'espace et temps

---

## Points clés à retenir

- **tar** : outil principal d'archivage Linux
- **Compression** : gz (rapide), bz2 (compact), xz (maximum)
- **Exclusions** : `--exclude` pour filtrer le contenu
- **Extraction** : `-C` pour choisir la destination
- **Intégrité** : toujours vérifier les archives importantes
- **Automatisation** : scripts pour sauvegardes régulières
- **Distribution** : zip pour compatibilité, tar.gz pour Linux

## Nettoyage final

```bash
# Nettoyer l'environnement de travail
cd ~
rm -rf tp_archivage
echo "TP terminé et nettoyé"
```