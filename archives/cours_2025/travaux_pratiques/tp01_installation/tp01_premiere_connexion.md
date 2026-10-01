# TP 1 : Première connexion et découverte

## Objectifs

À la fin de ce TP, vous saurez :
- Vous connecter à votre environnement Linux
- Naviguer dans l'interface en ligne de commande
- Utiliser les commandes de base
- Comprendre la structure du prompt

## Durée estimée
30 minutes

---

## Partie A : Connexion à votre environnement

### Pour les utilisateurs SSH (Scénario 1)

1. **Ouvrir votre client SSH** (PuTTY, Terminal, etc.)

2. **Se connecter au serveur**
   ```
   Adresse IP : [Fournie par le formateur]
   Utilisateur : [Votre nom d'utilisateur]
   Port : 22
   ```

3. **Vérifier la connexion**
   ```bash
   # Première commande : vérifier qui vous êtes
   whoami
   
   # Résultat attendu : votre nom d'utilisateur
   ```

### Pour les utilisateurs VirtualBox (Scénario 2)

1. **Démarrer la VM** dans VirtualBox

2. **Se connecter localement**
   ```
   login: [votre nom d'utilisateur]  
   Password: [votre mot de passe]
   ```

3. **Vérifier le système**
   ```bash
   # Vérifier la distribution
   cat /etc/os-release
   ```

---

## Partie B : Exploration du prompt et commandes de base

### Exercice 1 : Analyser le prompt

1. **Observer votre prompt**
   ```bash
   # Votre prompt ressemble à quelque chose comme :
   utilisateur@machine:~$ 
   ```

2. **Questions à répondre** :
   - Quel est votre nom d'utilisateur ?
   - Quel est le nom de la machine ?
   - Dans quel répertoire êtes-vous actuellement ? (indice: le symbole ~)

### Exercice 2 : Commandes d'information

1. **Identifier votre environnement**
   ```bash
   # Nom d'utilisateur
   whoami
   
   # Répertoire courant
   pwd
   
   # Nom de la machine
   hostname
   
   # Date et heure
   date
   ```

2. **Noter les résultats** de chaque commande dans le tableau :

   | Commande | Résultat |
   |----------|----------|
   | whoami   |          |
   | pwd      |          |
   | hostname |          |
   | date     |          |

### Exercice 3 : Explorer les fichiers

1. **Lister le contenu de votre répertoire**
   ```bash
   # Liste simple
   ls
   
   # Liste détaillée
   ls -l
   
   # Tout afficher (y compris les fichiers cachés)
   ls -la
   ```

2. **Questions** :
   - Combien de fichiers voyez-vous avec `ls` ?
   - Combien de fichiers voyez-vous avec `ls -la` ?
   - Pourquoi y a-t-il une différence ?

---

## Partie C : Navigation de base

### Exercice 4 : Se déplacer dans le système

1. **Explorer la racine du système**
   ```bash
   # Aller à la racine
   cd /
   
   # Voir le contenu
   ls
   
   # Vérifier où vous êtes
   pwd
   ```

2. **Revenir à votre répertoire personnel**
   ```bash
   # Méthode 1
   cd ~
   pwd
   
   # Méthode 2  
   cd
   pwd
   ```

3. **Explorer un répertoire système**
   ```bash
   # Aller dans /tmp
   cd /tmp
   ls
   
   # Revenir en arrière (répertoire parent)
   cd ..
   pwd
   ```

### Exercice 5 : Utiliser l'historique

1. **Tester l'historique**
   - Appuyez sur la flèche ↑ plusieurs fois
   - Appuyez sur la flèche ↓ pour revenir

2. **Afficher l'historique complet**
   ```bash
   history
   ```

3. **Répéter une commande précédente**
   ```bash
   # Répéter la dernière commande
   !!
   ```

---

## Partie D : Utiliser l'aide

### Exercice 6 : Explorer les manuels

1. **Lire le manuel d'une commande**
   ```bash
   # Ouvrir le manuel de 'ls'
   man ls
   ```

2. **Navigation dans le manuel** :
   - Appuyez sur **Espace** pour la page suivante
   - Appuyez sur **q** pour quitter
   - Tapez **/word** pour rechercher "word"

3. **Trouver une option** :
   Dans le manuel de `ls`, trouvez ce que fait l'option `-h`

4. **Tester l'option trouvée**
   ```bash
   # Utiliser l'option -h avec -l
   ls -lh
   ```

### Exercice 7 : Aide rapide

1. **Utiliser l'aide courte**
   ```bash
   ls --help | head -10
   ```

2. **Comparer** : Quelle différence voyez-vous entre `man ls` et `ls --help` ?

---

## Partie E : Exercices pratiques

### Exercice 8 : Découverte libre

1. **Explorer les répertoires suivants** et noter ce que vous y trouvez :
   ```bash
   ls /home
   ls /usr
   ls /etc
   ls /var
   ```

2. **Compléter le tableau** :

   | Répertoire | Contenu observé | Utilité supposée |
   |------------|-----------------|------------------|
   | /home      |                 |                  |
   | /usr       |                 |                  |
   | /etc       |                 |                  |
   | /var       |                 |                  |

### Exercice 9 : Complétion automatique

1. **Tester la complétion** :
   ```bash
   # Taper 'ls /ho' puis appuyer sur Tab
   ls /ho[Tab]
   
   # Taper 'cat /etc/host' puis Tab
   cat /etc/host[Tab]
   ```

2. **Double Tab pour voir les options** :
   ```bash
   # Taper 'ls --' puis Tab Tab
   ls --[Tab][Tab]
   ```

---

## Validation des acquis

### Questions de contrôle

1. **Que signifie le symbole `~` dans le prompt ?**

2. **Quelle commande permet de savoir dans quel répertoire on se trouve ?**

3. **Comment revenir à son répertoire personnel ?**

4. **Quelle est la différence entre `ls` et `ls -la` ?**

5. **Comment obtenir de l'aide sur une commande ?**

### Commandes à maîtriser

À la fin de ce TP, vous devez maîtriser :
- [ ] `whoami` - Afficher le nom d'utilisateur
- [ ] `pwd` - Afficher le répertoire courant  
- [ ] `ls`, `ls -l`, `ls -la` - Lister les fichiers
- [ ] `cd`, `cd ~`, `cd /`, `cd ..` - Changer de répertoire
- [ ] `hostname` - Nom de la machine
- [ ] `date` - Date et heure
- [ ] `man commande` - Aide détaillée
- [ ] `history` - Historique des commandes

---

## Solutions

### Solution Exercice 2
| Commande | Exemple de résultat |
|----------|---------------------|
| whoami   | john                |
| pwd      | /home/john          |
| hostname | debian-formation    |
| date     | Mon Jan 15 14:30:25 CET 2024 |

### Solution Exercice 6
L'option `-h` de `ls` affiche les tailles de fichiers dans un format lisible par l'humain (K, M, G au lieu d'octets).

### Solution questions de contrôle
1. `~` représente le répertoire personnel de l'utilisateur
2. `pwd` (Print Working Directory)  
3. `cd` ou `cd ~`
4. `ls -la` affiche aussi les fichiers cachés (commençant par .) et les détails
5. `man commande` ou `commande --help`

---

## Pour aller plus loin

Si vous avez terminé rapidement, explorez :
```bash
# Information sur le système
uname -a
cat /proc/version

# Processus en cours
ps

# Utilisation disque
df -h
```