# TP 1 : Exploration de l'arborescence

## Objectifs

À la fin de ce TP, vous saurez :
- Explorer l'arborescence Linux de manière méthodique
- Utiliser efficacement `ls`, `cd`, et `pwd`
- Différencier les chemins absolus et relatifs
- Naviguer dans les répertoires système principaux

## Durée estimée
45 minutes

---

## Partie A : Découverte de la structure système

### Exercice 1 : Explorer la racine

1. **Aller à la racine du système**
   ```bash
   cd /
   pwd
   ```

2. **Lister le contenu de la racine**
   ```bash
   ls
   ls -la
   ```

3. **Compléter le tableau** avec ce que vous observez :

   | Répertoire | Présent (O/N) | Description supposée |
   |------------|---------------|---------------------|
   | /bin       |               |                     |
   | /boot      |               |                     |
   | /dev       |               |                     |
   | /etc       |               |                     |
   | /home      |               |                     |
   | /lib       |               |                     |
   | /tmp       |               |                     |
   | /usr       |               |                     |
   | /var       |               |                     |

### Exercice 2 : Explorer les répertoires système

1. **Explorer /bin**
   ```bash
   cd /bin
   pwd
   ls | head -10
   ```
   
   **Question** : Que contient ce répertoire ? À quoi sert-il selon vous ?

2. **Explorer /etc**
   ```bash
   cd /etc
   ls | head -10
   ls -la | grep "\.conf"
   ```
   
   **Question** : Trouvez 3 fichiers de configuration importants.

3. **Explorer /home**
   ```bash
   cd /home
   ls -la
   ```
   
   **Question** : Combien d'utilisateurs ont un répertoire personnel ?

---

## Partie B : Navigation avec chemins absolus et relatifs

### Exercice 3 : Navigation absolue

1. **Série de déplacements avec chemins absolus**
   ```bash
   # Départ
   cd /
   pwd
   
   # Aller dans /usr/bin
   cd /usr/bin
   pwd
   
   # Aller dans /var/log
   cd /var/log
   pwd
   
   # Retour à votre répertoire personnel
   cd ~
   pwd
   ```

2. **Noter vos positions** après chaque `pwd` :
   - Position 1 : ________________
   - Position 2 : ________________ 
   - Position 3 : ________________
   - Position 4 : ________________

### Exercice 4 : Navigation relative

1. **Départ depuis votre répertoire personnel**
   ```bash
   cd ~
   pwd
   ```

2. **Navigation relative étape par étape**
   ```bash
   # Remonter à /home
   cd ..
   pwd
   
   # Remonter à la racine
   cd ..
   pwd
   
   # Descendre dans usr
   cd usr
   pwd
   
   # Descendre dans bin
   cd bin
   pwd
   
   # Remonter de 2 niveaux
   cd ../..
   pwd
   ```

3. **Vérification** : Où devriez-vous être après la dernière commande ?

### Exercice 5 : Comparaison absolu vs relatif

**Objectif** : Aller de votre répertoire personnel vers `/var/log`

1. **Méthode 1 - Chemin absolu**
   ```bash
   cd ~
   cd /var/log
   pwd
   ```

2. **Méthode 2 - Chemin relatif**
   ```bash
   cd ~
   cd ../../var/log
   pwd
   ```

3. **Questions** :
   - Quelle méthode est plus longue à taper ?
   - Quelle méthode fonctionne depuis n'importe où ?
   - Dans quel contexte utiliseriez-vous chaque méthode ?

---

## Partie C : Exploration approfondie avec `ls`

### Exercice 6 : Maîtriser les options de `ls`

1. **Explorer /usr avec différentes options**
   ```bash
   cd /usr
   
   # Liste simple
   ls
   
   # Format détaillé
   ls -l
   
   # Tout afficher (fichiers cachés)
   ls -la
   
   # Tailles lisibles
   ls -lah
   
   # Trié par date
   ls -lat
   ```

2. **Analyser la sortie de `ls -la`**
   ```bash
   ls -la | head -5
   ```
   
   **Compléter** pour la première ligne de fichier réel (pas . ou ..) :
   - Type de fichier : ________________
   - Permissions : ________________
   - Propriétaire : ________________
   - Groupe : ________________
   - Taille : ________________
   - Date : ________________

### Exercice 7 : Recherche ciblée

1. **Chercher des éléments spécifiques**
   ```bash
   cd /etc
   
   # Fichiers commençant par 'a'
   ls a*
   
   # Fichiers se terminant par '.conf'
   ls *.conf
   
   # Répertoires uniquement
   ls -ld */
   ```

2. **Dans /var/log**
   ```bash
   cd /var/log
   
   # Derniers fichiers modifiés
   ls -ltr | tail -5
   
   # Plus gros fichiers
   ls -laS | head -5
   ```

---

## Partie D : Le répertoire personnel et ses particularités

### Exercice 8 : Explorer votre home

1. **Aller dans votre répertoire personnel**
   ```bash
   cd ~
   pwd
   echo "Mon répertoire personnel : $(pwd)"
   ```

2. **Explorer le contenu (y compris fichiers cachés)**
   ```bash
   ls -la
   ```

3. **Identifier les éléments** :
   - Combien de fichiers cachés (commençant par .) ?
   - Quels fichiers de configuration trouvez-vous ?
   - Y a-t-il des répertoires standards (Documents, Pictures, etc.) ?

### Exercice 9 : Utilisation du tilde (~)

1. **Tester les différentes façons d'aller au home**
   ```bash
   # Méthode 1
   cd /tmp
   cd
   pwd
   
   # Méthode 2  
   cd /tmp
   cd ~
   pwd
   
   # Méthode 3 (si vous connaissez votre nom d'utilisateur)
   cd /tmp
   cd /home/$(whoami)
   pwd
   ```

2. **Utiliser le tilde dans les chemins**
   ```bash
   # Lister depuis n'importe où
   ls -la ~/
   
   # Naviguer vers un sous-répertoire (s'il existe)
   ls ~/Documents 2>/dev/null || echo "Documents n'existe pas"
   ```

---

## Partie E : Défis et cas pratiques

### Exercice 10 : Défi navigation

**Mission** : Aller de `/usr/local/bin` vers `/var/log` en utilisant UNIQUEMENT des chemins relatifs.

1. **Préparation**
   ```bash
   cd /usr/local/bin
   pwd
   ```

2. **Navigation** (complétez les commandes)
   ```bash
   cd _____    # Remonter vers /usr/local
   cd _____    # Remonter vers /usr
   cd _____    # Remonter vers /
   cd _____    # Descendre vers var
   cd _____    # Descendre vers log
   pwd         # Vérifier : doit afficher /var/log
   ```

### Exercice 11 : Exploration des logs système

1. **Explorer les logs**
   ```bash
   cd /var/log
   ls -la
   ```

2. **Analyser les logs disponibles**
   - Y a-t-il un fichier `syslog` ?
   - Trouvez-vous des logs d'applications spécifiques ?
   - Quel est le log le plus récemment modifié ?
   ```bash
   ls -lt | head -3
   ```

### Exercice 12 : Créer sa propre structure

1. **Dans votre répertoire personnel, créer cette structure**
   ```bash
   cd ~
   mkdir -p formation_linux/module02/exercices
   mkdir -p formation_linux/module02/notes
   ```

2. **Naviguer dans cette structure**
   ```bash
   cd formation_linux/module02/exercices
   pwd
   cd ../notes
   pwd
   cd ../../..
   pwd
   ```

---

## Partie F : Validation et synthèse

### Questions de compréhension

1. **Quelle commande utiliser pour** :
   - Savoir où on se trouve ? ________________
   - Voir tous les fichiers d'un répertoire ? ________________
   - Aller à la racine du système ? ________________
   - Retourner au répertoire précédent ? ________________

2. **Chemins - Compléter** :
   - Chemin absolu vers votre répertoire personnel : ________________
   - Chemin relatif depuis / vers usr/bin : ________________
   - Raccourci pour le répertoire personnel : ________________

3. **Interprétation de `ls -l`** :
   ```
   drwxr-xr-x 2 root root 4096 Jan 15 10:30 bin
   ```
   - Type d'élément : ________________
   - Propriétaire : ________________
   - Taille : ________________

### Test final : Navigation aveugle

**Sans regarder les réponses**, effectuez cette séquence et prédisez où vous allez arriver :

```bash
cd /usr/local
cd ../..
cd home
cd ..
cd var
cd log
cd ../../tmp
pwd  # Où devez-vous être ?
```

**Votre prédiction** : ________________

**Vérification** : Exécutez les commandes et comparez avec votre prédiction.

---

## Solutions

### Solution Exercice 10 (Défi navigation)
```bash
cd ../..    # Remonter vers /usr
cd ../..    # Remonter vers /
cd var      # Descendre vers var
cd log      # Descendre vers log
```

### Solutions Questions de compréhension
1. `pwd`, `ls -la`, `cd /`, `cd -`
2. `/home/votreusername`, `usr/bin`, `~`
3. répertoire, root, 4096 octets

### Solution Test final
Réponse : `/tmp`

---

## Points clés à retenir

- **Structure hiérarchique** : tout part de `/`
- **Chemins absolus** : commencent par `/`, universels
- **Chemins relatifs** : depuis position courante, plus courts
- **`pwd`** : toujours savoir où on est
- **`ls -la`** : explorer complètement un répertoire
- **`~`** : raccourci vers le répertoire personnel
- **Navigation** : combiner `cd` et vérification avec `pwd`

## Pour aller plus loin

Si vous terminez en avance :

1. **Explorer /proc**
   ```bash
   cd /proc
   ls | head -10
   cat /proc/cpuinfo | head -10
   ```

2. **Découvrir /dev**
   ```bash
   cd /dev
   ls | head -10
   file null zero random
   ```