# TP 2 : Types de fichiers et liens

## Objectifs

À la fin de ce TP, vous saurez :
- Identifier les différents types de fichiers Linux
- Créer et utiliser des liens symboliques et physiques
- Comprendre les différences entre les types de liens
- Gérer les liens dans un environnement pratique

## Durée estimée
40 minutes

---

## Partie A : Identification des types de fichiers

### Exercice 1 : Explorer les types avec `ls -l`

1. **Préparer l'environnement**
   ```bash
   cd ~
   mkdir tp_types_fichiers
   cd tp_types_fichiers
   ```

2. **Créer des fichiers de test**
   ```bash
   # Fichier ordinaire
   echo "Contenu test" > fichier_normal.txt
   
   # Répertoire
   mkdir mon_repertoire
   
   # Script exécutable
   echo '#!/bin/bash\necho "Hello World"' > script.sh
   chmod +x script.sh
   ```

3. **Analyser les types**
   ```bash
   ls -la
   ```

4. **Compléter le tableau** :

   | Nom | 1er caractère | Type | Description |
   |-----|---------------|------|-------------|
   | fichier_normal.txt | | | |
   | mon_repertoire | | | |
   | script.sh | | | |
   | . (répertoire courant) | | | |
   | .. (répertoire parent) | | | |

### Exercice 2 : Explorer les types système

1. **Examiner /dev pour les périphériques**
   ```bash
   ls -la /dev | head -20
   ```

2. **Identifier les types** dans la sortie :
   - Trouvez un périphérique caractère (commence par `c`) : ________________
   - Trouvez un périphérique bloc (commence par `b`) : ________________
   - Trouvez un lien symbolique (commence par `l`) : ________________

3. **Tester quelques périphériques spéciaux**
   ```bash
   # /dev/null : "trou noir"
   echo "Ce texte disparaît" > /dev/null
   
   # /dev/zero : génère des zéros
   head -c 10 /dev/zero | od -c
   ```

### Exercice 3 : Utiliser la commande `file`

1. **Analyser différents types de contenu**
   ```bash
   cd ~/tp_types_fichiers
   
   # Créer différents types de fichiers
   echo "Texte simple" > texte.txt
   echo -e "\x7fELF" > binaire_fake
   cp /bin/ls programme_copie
   ```

2. **Utiliser `file` pour identifier**
   ```bash
   file texte.txt
   file binaire_fake
   file programme_copie
   file mon_repertoire
   file /dev/null
   ```

3. **Noter les résultats** :
   - texte.txt : ________________
   - programme_copie : ________________
   - /dev/null : ________________

---

## Partie B : Création et gestion des liens symboliques

### Exercice 4 : Créer des liens symboliques

1. **Préparer les fichiers sources**
   ```bash
   cd ~/tp_types_fichiers
   
   echo "Contenu du document original" > document_original.txt
   echo "Ligne 1\nLigne 2\nLigne 3" > fichier_donnees.txt
   mkdir dossier_source
   echo "Fichier dans le dossier" > dossier_source/fichier_interne.txt
   ```

2. **Créer des liens symboliques**
   ```bash
   # Lien vers un fichier
   ln -s document_original.txt lien_vers_document
   
   # Lien vers un répertoire
   ln -s dossier_source lien_vers_dossier
   
   # Lien avec chemin absolu
   ln -s $(pwd)/fichier_donnees.txt lien_absolu
   
   # Lien avec chemin relatif
   ln -s ../tp_types_fichiers/fichier_donnees.txt lien_relatif
   ```

3. **Examiner les liens créés**
   ```bash
   ls -la
   ```

4. **Questions** :
   - Comment reconnaît-on un lien symbolique dans `ls -la` ?
   - Que signifie la flèche `->` ?
   - Quelle différence entre lien_absolu et lien_relatif ?

### Exercice 5 : Tester les liens symboliques

1. **Tester l'accès via les liens**
   ```bash
   # Lire via les liens
   cat lien_vers_document
   cat document_original.txt
   
   # Sont-ils identiques ?
   diff lien_vers_document document_original.txt
   ```

2. **Tester les liens vers répertoires**
   ```bash
   # Naviguer via le lien
   cd lien_vers_dossier
   pwd
   ls -la
   cd ..
   
   # Comparer avec l'original
   cd dossier_source
   pwd
   cd ..
   ```

3. **Modifier via un lien**
   ```bash
   echo "Ligne ajoutée via le lien" >> lien_vers_document
   cat document_original.txt
   ```

   **Question** : Le fichier original a-t-il été modifié ?

### Exercice 6 : Liens cassés

1. **Créer une situation de lien cassé**
   ```bash
   # Créer un lien
   ln -s fichier_temporaire.txt lien_vers_temporaire
   
   # Créer la cible
   echo "Contenu temporaire" > fichier_temporaire.txt
   
   # Tester le lien
   cat lien_vers_temporaire
   
   # Supprimer la cible
   rm fichier_temporaire.txt
   
   # Tester le lien cassé
   ls -la lien_vers_temporaire
   cat lien_vers_temporaire  # Que se passe-t-il ?
   ```

2. **Identifier les liens cassés**
   ```bash
   # Chercher les liens cassés dans le répertoire
   find . -type l -xtype l
   ```

---

## Partie C : Création et gestion des liens physiques

### Exercice 7 : Créer des liens physiques (hard links)

1. **Préparer le fichier source**
   ```bash
   echo "Contenu partagé entre plusieurs noms" > fichier_partage.txt
   ls -li fichier_partage.txt  # Noter l'inode et le nombre de liens
   ```

2. **Créer des liens physiques**
   ```bash
   # Premier lien physique
   ln fichier_partage.txt copie1.txt
   
   # Deuxième lien physique
   ln fichier_partage.txt copie2.txt
   
   # Examiner les résultats
   ls -li fichier_partage.txt copie1.txt copie2.txt
   ```

3. **Analyser la sortie** :
   - Quel est le numéro d'inode ? ________________
   - Combien de liens physiques existent ? ________________
   - Les tailles sont-elles identiques ? ________________

### Exercice 8 : Comprendre les liens physiques

1. **Tester les modifications**
   ```bash
   # Modifier via le premier nom
   echo "Nouvelle ligne" >> fichier_partage.txt
   
   # Vérifier les autres noms
   cat copie1.txt
   cat copie2.txt
   ```

   **Question** : Les modifications apparaissent-elles partout ?

2. **Tester la suppression**
   ```bash
   # Supprimer un nom
   rm fichier_partage.txt
   
   # Les autres existent-ils encore ?
   ls -li copie1.txt copie2.txt
   cat copie1.txt
   ```

3. **Vérifier le compteur de liens**
   ```bash
   ls -li copie1.txt
   ```
   
   **Question** : Le nombre de liens a-t-il changé ?

---

## Partie D : Comparaison pratique des liens

### Exercice 9 : Test comparatif

1. **Préparer les fichiers de test**
   ```bash
   echo "Contenu pour test de liens" > original_test.txt
   
   # Créer les deux types de liens
   ln -s original_test.txt lien_symbolique_test
   ln original_test.txt lien_physique_test
   ```

2. **Examiner les propriétés**
   ```bash
   ls -li original_test.txt lien_symbolique_test lien_physique_test
   ```

3. **Compléter le tableau comparatif** :

   | Fichier | Inode | Nombre de liens | Taille | Type |
   |---------|-------|-----------------|--------|------|
   | original_test.txt | | | | |
   | lien_symbolique_test | | | | |
   | lien_physique_test | | | | |

### Exercice 10 : Test de résistance

1. **Tester la suppression du fichier original**
   ```bash
   rm original_test.txt
   ```

2. **Tester l'accès via les liens**
   ```bash
   cat lien_symbolique_test  # Que se passe-t-il ?
   cat lien_physique_test    # Que se passe-t-il ?
   ```

3. **Analyser l'état des liens**
   ```bash
   ls -la lien_symbolique_test lien_physique_test
   ```

**Questions** :
- Quel lien fonctionne encore ?
- Pourquoi cette différence ?

---

## Partie E : Cas pratiques et applications

### Exercice 11 : Système de versioning simple

1. **Créer un système de versions avec liens symboliques**
   ```bash
   mkdir projet_versions
   cd projet_versions
   
   # Créer différentes versions
   echo "Version 1.0 du projet" > config-v1.0.txt
   echo "Version 1.1 du projet" > config-v1.1.txt
   echo "Version 2.0 du projet" > config-v2.0.txt
   
   # Créer un lien vers la version actuelle
   ln -s config-v2.0.txt config-latest.txt
   ```

2. **Utiliser le système**
   ```bash
   # Lire la version actuelle
   cat config-latest.txt
   
   # Revenir à une version précédente
   ln -sf config-v1.1.txt config-latest.txt
   cat config-latest.txt
   
   # Mettre à jour vers la dernière version
   ln -sf config-v2.0.txt config-latest.txt
   ```

### Exercice 12 : Organisation avec liens

1. **Créer une structure organisée**
   ```bash
   cd ~/tp_types_fichiers
   mkdir -p projets/{webapp,mobile,desktop}
   mkdir -p archives/2024/{janvier,fevrier,mars}
   
   # Créer quelques fichiers
   echo "Code webapp" > projets/webapp/app.js
   echo "Archive janvier" > archives/2024/janvier/rapport.txt
   ```

2. **Créer des raccourcis pratiques**
   ```bash
   # Liens vers les projets actifs
   ln -s projets/webapp webapp_current
   ln -s projets/mobile mobile_current
   
   # Lien vers les archives récentes
   ln -s archives/2024 archives_current
   ```

3. **Tester la navigation**
   ```bash
   cd webapp_current
   pwd  # Où êtes-vous réellement ?
   ls -la
   cd ../archives_current/janvier
   pwd
   ```

---

## Partie F : Nettoyage et validation

### Exercice 13 : Nettoyer les liens

1. **Identifier tous les liens créés**
   ```bash
   cd ~/tp_types_fichiers
   find . -type l  # Liens symboliques
   ```

2. **Vérifier les liens cassés**
   ```bash
   find . -type l -xtype l  # Liens cassés uniquement
   ```

3. **Nettoyer sélectivement**
   ```bash
   # Supprimer les liens cassés
   find . -type l -xtype l -delete
   
   # Vérifier
   find . -type l
   ```

### Questions de validation

1. **Types de fichiers** :
   - Comment identifier un répertoire dans `ls -l` ? ________________
   - Comment identifier un lien symbolique ? ________________
   - Que signifie `c` comme premier caractère ? ________________

2. **Liens** :
   - Commande pour créer un lien symbolique : ________________
   - Commande pour créer un lien physique : ________________
   - Que devient un lien symbolique si on supprime la cible ? ________________

3. **Pratique** :
   - Dans quel cas préférer un lien symbolique ? ________________
   - Dans quel cas préférer un lien physique ? ________________

---

## Solutions

### Solutions Questions de validation
1. Premier caractère `d`, premier caractère `l`, périphérique caractère
2. `ln -s`, `ln`, il devient cassé/inactif
3. Liens vers répertoires ou systèmes de fichiers différents ; sauvegarde partagée du même contenu

### Tableau Exercice 4
| Nom | 1er caractère | Type | Description |
|-----|---------------|------|-------------|
| fichier_normal.txt | - | fichier ordinaire | document texte |
| mon_repertoire | d | répertoire | conteneur de fichiers |
| script.sh | - | fichier exécutable | script bash |
| . | d | répertoire | répertoire courant |
| .. | d | répertoire | répertoire parent |

---

## Points clés à retenir

- **Types principaux** : `-` (fichier), `d` (répertoire), `l` (lien symbolique)
- **Liens symboliques** : raccourcis, peuvent être cassés, `ln -s`
- **Liens physiques** : noms multiples pour même contenu, `ln`
- **`file`** : identifier le type de contenu
- **Inode** : identifiant unique du contenu sur disque
- **Liens cassés** : quand la cible d'un lien symbolique n'existe plus
- **Applications** : versioning, raccourcis, organisation

## Nettoyage final

```bash
# Supprimer le répertoire de travail
cd ~
rm -rf tp_types_fichiers
```