# Suppression et sécurité

## Supprimer des fichiers avec `rm`

### Principe et dangers
La commande `rm` (remove) supprime définitivement les fichiers. **Attention** : sous Linux, il n'y a pas de corbeille par défaut en ligne de commande !

### Syntaxe de base
```bash
rm [options] fichier1 [fichier2 ...]
```

### Suppression simple
```bash
# Supprimer un fichier
rm fichier_inutile.txt

# Supprimer plusieurs fichiers
rm file1.txt file2.txt file3.txt

# Supprimer avec pattern
rm *.tmp
rm backup_*
```

### Options cruciales pour la sécurité

#### `-i` : Mode interactif (RECOMMANDÉ)
```bash
# Demander confirmation pour chaque fichier
rm -i fichier.txt
# rm: remove regular file 'fichier.txt'? y

# Avec plusieurs fichiers
rm -i *.txt
# rm: remove regular file 'doc1.txt'? y
# rm: remove regular file 'doc2.txt'? n
# rm: remove regular file 'doc3.txt'? y
```

#### `-f` : Force (DANGEREUX)
```bash
# Supprimer sans confirmation, ignorer les erreurs
rm -f fichier_protege.txt

# ATTENTION : Ne pas utiliser à la légère !
rm -f *.txt  # Supprime TOUS les .txt sans demander
```

#### `-v` : Mode verbeux
```bash
# Afficher ce qui est supprimé
rm -v *.log
# removed 'app.log'
# removed 'error.log'
# removed 'access.log'
```

### Suppression de répertoires avec `-r`

#### Répertoires vides : `rmdir`
```bash
# Supprimer un répertoire vide
rmdir dossier_vide

# Erreur si non vide
rmdir dossier_avec_contenu
# rmdir: failed to remove 'dossier_avec_contenu': Directory not empty
```

#### Répertoires avec contenu : `rm -r`
```bash
# Suppression récursive (DANGEREUX)
rm -r dossier_et_contenu/

# Avec confirmation (RECOMMANDÉ)
rm -ri dossier_important/
# rm: descend into directory 'dossier_important/'? y
# rm: remove regular file 'dossier_important/fichier.txt'? y
# rm: remove directory 'dossier_important/'? y
```

### Combinaisons d'options courantes

#### Mode sécurisé recommandé
```bash
# Interactive + verbeux
rm -iv fichier.txt
rm -riv dossier/

# Pour les débutants (toujours demander)
alias rm='rm -i'  # À ajouter dans ~/.bashrc
```

#### Mode destructeur (À ÉVITER sauf expertise)
```bash
# Force + récursif (TRÈS DANGEREUX)
rm -rf dossier/
# Supprime tout sans confirmation ni possibilité de récupération !
```

## Mesures de sécurité et bonnes pratiques

### 1. Toujours vérifier avant de supprimer
```bash
# Voir ce qui va être supprimé
ls -la *.tmp
# Puis supprimer
rm -i *.tmp
```

### 2. Utiliser le mode interactif par défaut
```bash
# Ajouter dans ~/.bashrc
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
```

### 3. Faire des sauvegardes avant suppression massive
```bash
# Sauvegarder avant nettoyage
cp -r projet_important/ sauvegarde_avant_nettoyage/
# Puis nettoyer
rm -ri projet_important/fichiers_anciens/
```

### 4. Utiliser des commandes plus sûres

#### Déplacer vers une "corbeille" personnelle
```bash
# Créer une corbeille
mkdir -p ~/.corbeille

# Fonction de suppression sécurisée
trash() {
    mv "$@" ~/.corbeille/
    echo "Déplacé vers ~/.corbeille : $@"
}

# Utilisation
trash fichier_a_supprimer.txt
```

#### Suppression avec confirmation explicite
```bash
# Fonction de suppression sécurisée
safe_rm() {
    echo "Vous allez supprimer : $@"
    read -p "Êtes-vous sûr ? (oui/non) : " confirm
    if [ "$confirm" = "oui" ]; then
        rm "$@"
        echo "Supprimé."
    else
        echo "Annulé."
    fi
}
```

### 5. Éviter les caractères génériques dangereux
```bash
# DANGEREUX
rm -rf /*     # Supprime tout le système !
rm -rf $VAR/  # Si $VAR est vide, supprime tout depuis /

# PLUS SÛR
rm -rf /path/specific/directory/
rm -rf "${VAR:?}/"  # Arrête si VAR est vide
```

## Gestion des fichiers protégés

### Fichiers en lecture seule
```bash
# Créer un fichier protégé
echo "Contenu important" > fichier_protege.txt
chmod 444 fichier_protege.txt  # Lecture seule

# Tentative de suppression
rm fichier_protege.txt
# rm: remove write-protected regular file 'fichier_protege.txt'? y

# Suppression forcée (ignore la protection)
rm -f fichier_protege.txt
```

### Fichiers avec attributs spéciaux
```bash
# Fichier immutable (nécessite chattr)
sudo chattr +i fichier_immutable.txt

# Impossible à supprimer même avec rm -f
rm -f fichier_immutable.txt
# rm: cannot remove 'fichier_immutable.txt': Operation not permitted

# Retirer l'attribut immutable
sudo chattr -i fichier_immutable.txt
```

## Suppression ciblée et nettoyage

### Supprimer par âge
```bash
# Fichiers plus anciens que 7 jours
find /tmp -type f -mtime +7 -delete

# Avec confirmation
find /tmp -type f -mtime +7 -exec rm -i {} \;

# Logs anciens
find /var/log -name "*.log" -mtime +30 -exec rm {} \;
```

### Supprimer par taille
```bash
# Fichiers plus gros que 100MB
find . -type f -size +100M -exec rm -i {} \;

# Fichiers vides
find . -type f -empty -delete
```

### Supprimer par type
```bash
# Fichiers temporaires courants
rm -f *.tmp *.bak *~ *.swp

# Fichiers de compilation
rm -f *.o *.pyc *.class

# Fichiers de logs volumineux
rm -f *.log.[0-9]*
```

### Nettoyage de répertoires système (avec sudo)
```bash
# Nettoyer le cache apt (Ubuntu/Debian)
sudo apt-get clean

# Vider la corbeille système
sudo rm -rf /tmp/*

# Nettoyer les logs anciens
sudo journalctl --vacuum-time=30d
```

## Récupération et alternatives

### Vérification avant suppression irréversible
```bash
# Taille totale à supprimer
du -sh dossier_a_supprimer/

# Nombre de fichiers
find dossier_a_supprimer/ -type f | wc -l

# Aperçu du contenu
find dossier_a_supprimer/ -type f | head -20
```

### Alternative : archivage avant suppression
```bash
# Archiver avant de supprimer
tar -czf sauvegarde_$(date +%Y%m%d).tar.gz dossier_a_supprimer/
rm -rf dossier_a_supprimer/
```

### Outils de récupération (cas d'urgence)
```bash
# Installer testdisk (contient photorec)
sudo apt-get install testdisk

# Utiliser extundelete pour ext3/ext4
sudo extundelete /dev/sda1 --restore-file chemin/vers/fichier

# IMPORTANT : Agir rapidement après la suppression !
```

## Cas d'erreurs courantes

### Erreur : "Directory not empty"
```bash
# Problème
rmdir dossier/
# rmdir: failed to remove 'dossier/': Directory not empty

# Solution 1 : Vérifier le contenu (fichiers cachés)
ls -la dossier/

# Solution 2 : Utiliser rm -r
rm -r dossier/
```

### Erreur : "Permission denied"
```bash
# Problème
rm fichier_systeme.txt
# rm: cannot remove 'fichier_systeme.txt': Permission denied

# Solution : Utiliser sudo (si justifié)
sudo rm fichier_systeme.txt

# Ou changer les permissions
chmod u+w fichier_systeme.txt
rm fichier_systeme.txt
```

### Erreur : "No such file or directory"
```bash
# Problème
rm fichier_inexistant.txt
# rm: cannot remove 'fichier_inexistant.txt': No such file or directory

# Solution : Utiliser -f pour ignorer
rm -f fichier_inexistant.txt

# Ou vérifier l'existence avant
[ -f fichier.txt ] && rm fichier.txt
```

## Scripts de nettoyage sécurisés

### Script de nettoyage interactif
```bash
#!/bin/bash
# clean_directory.sh

DIR="$1"
if [ -z "$DIR" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

if [ ! -d "$DIR" ]; then
    echo "Erreur : $DIR n'est pas un répertoire"
    exit 1
fi

echo "Répertoire à nettoyer : $DIR"
echo "Contenu :"
ls -la "$DIR"
echo ""

read -p "Continuer le nettoyage ? (oui/non) : " confirm
if [ "$confirm" = "oui" ]; then
    find "$DIR" -name "*.tmp" -delete
    find "$DIR" -name "*~" -delete
    find "$DIR" -type f -empty -delete
    echo "Nettoyage terminé."
else
    echo "Annulé."
fi
```

### Script de rotation des logs
```bash
#!/bin/bash
# rotate_logs.sh

LOG_DIR="/var/log/myapp"
RETENTION_DAYS=30

# Sauvegarder les logs actuels
if [ -f "$LOG_DIR/app.log" ]; then
    mv "$LOG_DIR/app.log" "$LOG_DIR/app.log.$(date +%Y%m%d_%H%M%S)"
    touch "$LOG_DIR/app.log"
fi

# Supprimer les anciens logs
find "$LOG_DIR" -name "app.log.*" -mtime +$RETENTION_DAYS -delete

echo "Rotation des logs terminée"
```

## Points clés à retenir

- **`rm`** supprime définitivement (pas de corbeille par défaut)
- **`rm -i`** : toujours demander confirmation (RECOMMANDÉ)
- **`rm -r`** : nécessaire pour les répertoires avec contenu
- **`rm -f`** : force la suppression (DANGEREUX)
- **`rmdir`** : seulement pour les répertoires vides
- **Vérifier** avec `ls` avant de supprimer
- **Sauvegarder** les données importantes avant nettoyage
- **Utiliser** des alias sécurisés (`alias rm='rm -i'`)
- **Éviter** `rm -rf` sans réflexion
- **Tester** les commandes sur des données non critiques

## Exercices pratiques

### Exercice 1 : Suppression sécurisée
```bash
# Créer des fichiers tests
touch test1.txt test2.txt test3.txt
mkdir test_dir
touch test_dir/file.txt

# Supprimer avec confirmation
rm -i test1.txt
rmdir test_dir  # Échouera
rm -ri test_dir  # Réussira
```

### Exercice 2 : Nettoyage ciblé
```bash
# Créer différents types de fichiers
touch file.txt file.bak file.tmp file~
echo "content" > important.txt

# Nettoyer seulement les temporaires
rm -f *.tmp *.bak *~
ls -la  # Vérifier que important.txt reste
```

### Exercice 3 : Fonction de corbeille
```bash
# Ajouter à ~/.bashrc
mkdir -p ~/.corbeille
trash() {
    mv "$@" ~/.corbeille/
}

# Tester
touch deleteme.txt
trash deleteme.txt
ls ~/.corbeille/
```