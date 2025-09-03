# Utilisateurs et groupes

## Vue d'ensemble du système de permissions Linux

### Principe fondamental
Linux est un système multi-utilisateurs où chaque fichier et processus appartient à un utilisateur et un groupe spécifiques. Cette appartenance détermine qui peut accéder à quoi et comment.

### Architecture des permissions
```
Utilisateur (User)
    ↓
Groupe principal (Primary Group)
    ↓  
Groupes secondaires (Secondary Groups)
    ↓
Permissions sur fichiers/dossiers
```

## Gestion des utilisateurs

### Fichiers système importants

#### /etc/passwd - Base des utilisateurs
```bash
# Structure du fichier
cat /etc/passwd

# Format : username:password:UID:GID:description:home:shell
# Exemple :
# john:x:1001:1001:John Doe,,,:/home/john:/bin/bash
```

**Champs détaillés :**
- **username** : nom d'utilisateur
- **password** : `x` (mot de passe dans /etc/shadow)
- **UID** : User ID numérique
- **GID** : Group ID principal
- **description** : nom complet et informations
- **home** : répertoire personnel
- **shell** : shell de connexion

#### /etc/shadow - Mots de passe cryptés
```bash
# Fichier sécurisé (root seulement)
sudo cat /etc/shadow

# Format : username:encrypted_password:last_change:min_age:max_age:warning:inactive:expire
```

### Types d'utilisateurs

#### Utilisateur root (administrateur)
```bash
# UID = 0, privilèges maximaux
id root
# uid=0(root) gid=0(root) groups=0(root)

# Basculer vers root
sudo su -
su -

# Exécuter une commande en tant que root
sudo command
```

#### Utilisateurs système (services)
```bash
# UID < 1000, généralement pas de shell interactif
grep -E ":/(bin/false|sbin/nologin)" /etc/passwd

# Exemples :
# www-data (serveur web)
# mysql (base de données)
# sshd (service SSH)
```

#### Utilisateurs normaux
```bash
# UID >= 1000, shell interactif
grep -E ":[0-9]{4,}:" /etc/passwd | head -5
```

### Commandes de gestion des utilisateurs

#### Informations sur l'utilisateur courant
```bash
# Utilisateur actuel
whoami

# Informations détaillées
id

# Groupes de l'utilisateur
groups

# Utilisateurs connectés
who
w
```

#### Création d'utilisateurs - `useradd`
```bash
# Création simple
sudo useradd nouvel_utilisateur

# Création avec options
sudo useradd -m -s /bin/bash -c "Nom Complet" -G sudo utilisateur2

# Options importantes :
# -m : créer le répertoire home
# -s : spécifier le shell
# -c : commentaire (nom complet)
# -G : groupes supplémentaires
# -u : UID spécifique
# -d : répertoire home personnalisé
```

#### Définir le mot de passe
```bash
# Définir/changer le mot de passe d'un utilisateur
sudo passwd utilisateur

# Changer son propre mot de passe
passwd

# Forcer le changement au prochain login
sudo passwd -e utilisateur
```

#### Modification d'utilisateurs - `usermod`
```bash
# Ajouter à un groupe
sudo usermod -aG sudo utilisateur

# Changer le shell
sudo usermod -s /bin/zsh utilisateur

# Changer le répertoire home
sudo usermod -d /new/home/path -m utilisateur

# Verrouiller un compte
sudo usermod -L utilisateur

# Déverrouiller un compte
sudo usermod -U utilisateur

# Changer le nom d'utilisateur
sudo usermod -l nouveau_nom ancien_nom
```

#### Suppression d'utilisateurs - `userdel`
```bash
# Suppression simple (garde le home)
sudo userdel utilisateur

# Suppression complète (avec home et mail)
sudo userdel -r utilisateur

# Forcer la suppression même si connecté
sudo userdel -f utilisateur
```

## Gestion des groupes

### Fichiers système des groupes

#### /etc/group - Définition des groupes
```bash
# Structure du fichier
cat /etc/group

# Format : groupname:password:GID:members
# Exemple :
# sudo:x:27:john,marie
# developers:x:1010:alice,bob,charlie
```

#### /etc/gshadow - Mots de passe de groupes
```bash
# Généralement peu utilisé
sudo cat /etc/gshadow
```

### Types de groupes

#### Groupe principal
```bash
# Chaque utilisateur a un groupe principal (défini dans /etc/passwd)
id utilisateur

# Voir le groupe principal
groups utilisateur | cut -d' ' -f1
```

#### Groupes secondaires
```bash
# Groupes supplémentaires auxquels appartient l'utilisateur
groups utilisateur
```

#### Groupes système importants
```bash
# Groupes courants et leurs fonctions
grep -E "(sudo|wheel|adm|www-data|docker)" /etc/group

# sudo/wheel : administration système
# adm : lecture logs système
# www-data : serveur web
# docker : gestion Docker
```

### Commandes de gestion des groupes

#### Création de groupes - `groupadd`
```bash
# Création simple
sudo groupadd nouveau_groupe

# Avec GID spécifique
sudo groupadd -g 2000 groupe_special

# Groupe système (GID < 1000)
sudo groupadd -r groupe_systeme
```

#### Modification de groupes - `groupmod`
```bash
# Changer le nom du groupe
sudo groupmod -n nouveau_nom ancien_nom

# Changer le GID
sudo groupmod -g 2500 nom_groupe
```

#### Suppression de groupes - `groupdel`
```bash
# Supprimer un groupe (doit être vide)
sudo groupdel nom_groupe

# Vérifier qu'aucun utilisateur n'utilise le groupe comme groupe principal
grep ":$(getent group nom_groupe | cut -d: -f3):" /etc/passwd
```

#### Gestion de l'appartenance aux groupes
```bash
# Ajouter un utilisateur à un groupe
sudo gpasswd -a utilisateur groupe

# Retirer un utilisateur d'un groupe  
sudo gpasswd -d utilisateur groupe

# Définir les membres d'un groupe
sudo gpasswd -M user1,user2,user3 groupe

# Lister les membres d'un groupe
getent group nom_groupe
```

## Concepts avancés de gestion des utilisateurs

### UID et GID - Identifiants numériques

#### Plages d'identifiants
```bash
# Voir la configuration des plages
cat /etc/login.defs | grep -E "(UID|GID)_"

# Généralement :
# 0 : root
# 1-999 : utilisateurs/groupes système
# 1000+ : utilisateurs normaux
```

#### Résolution nom ↔ numérique
```bash
# Obtenir l'UID d'un utilisateur
id -u utilisateur

# Obtenir le GID d'un groupe
getent group nom_groupe | cut -d: -f3

# Résolution inverse
getent passwd 1001
getent group 1001
```

### Changement d'identité

#### su - Switch User
```bash
# Devenir root (shell non-login)
su

# Devenir root (shell login - recommandé)
su -

# Devenir un autre utilisateur
su - utilisateur

# Exécuter une commande en tant qu'autre utilisateur
su -c "commande" utilisateur
```

#### sudo - Super User Do
```bash
# Configuration dans /etc/sudoers
sudo visudo

# Syntaxe de base :
# user_or_group HOST=(TARGET_USER:TARGET_GROUP) COMMANDS

# Exemples de règles :
# john ALL=(ALL:ALL) ALL
# %admin ALL=(ALL) NOPASSWD: /usr/bin/systemctl
# marie ALL=(www-data) /usr/bin/php
```

#### newgrp - Changer de groupe principal temporairement
```bash
# Changer de groupe principal pour la session
newgrp nom_groupe

# Revenir au groupe original
exit
```

### Gestion avancée avec getent

#### Interrogation des bases d'utilisateurs/groupes
```bash
# Lister tous les utilisateurs
getent passwd

# Informations sur un utilisateur spécifique
getent passwd john

# Lister tous les groupes
getent group

# Rechercher les utilisateurs d'un groupe
getent group sudo | cut -d: -f4 | tr ',' '\n'
```

## Surveillance et audit des utilisateurs

### Sessions actives

#### Qui est connecté ?
```bash
# Utilisateurs connectés actuellement
who

# Informations détaillées sur les sessions
w

# Dernières connexions
last

# Dernières connexions échouées
lastb

# Historique de connexion d'un utilisateur
last utilisateur
```

#### Processus par utilisateur
```bash
# Processus de l'utilisateur courant
ps aux | grep "^$(whoami)"

# Processus d'un utilisateur spécifique
ps aux | grep "^john"

# Compter les processus par utilisateur
ps aux | awk '{print $1}' | sort | uniq -c | sort -nr
```

### Audit des permissions et accès

#### Fichiers appartenant à un utilisateur
```bash
# Trouver tous les fichiers d'un utilisateur
find /home -user john

# Trouver les fichiers d'un groupe
find /var -group www-data

# Fichiers sans propriétaire (orphelins)
find /home -nouser -o -nogroup
```

#### Historique des commandes
```bash
# Historique de l'utilisateur courant
history

# Fichier d'historique
cat ~/.bash_history

# Historique des commandes sudo
sudo cat /var/log/auth.log | grep sudo
```

## Scripts d'automatisation pour la gestion utilisateurs

### Script de création d'utilisateur
```bash
#!/bin/bash
# create_user.sh - Création d'utilisateur avec bonnes pratiques

USERNAME="$1"
FULLNAME="$2"

if [ $# -lt 2 ]; then
    echo "Usage: $0 <username> <fullname>"
    exit 1
fi

# Vérifier si l'utilisateur existe déjà
if id "$USERNAME" &>/dev/null; then
    echo "L'utilisateur $USERNAME existe déjà"
    exit 1
fi

# Créer l'utilisateur
sudo useradd -m -s /bin/bash -c "$FULLNAME" "$USERNAME"

# Définir le mot de passe
echo "Définition du mot de passe pour $USERNAME :"
sudo passwd "$USERNAME"

# Ajouter aux groupes de base
sudo usermod -aG users "$USERNAME"

echo "Utilisateur $USERNAME créé avec succès"
echo "Répertoire personnel : /home/$USERNAME"
```

### Script d'audit utilisateurs
```bash
#!/bin/bash
# user_audit.sh - Audit des utilisateurs système

echo "=== AUDIT UTILISATEURS $(date) ==="
echo

echo "Utilisateurs humains (UID >= 1000) :"
getent passwd | awk -F: '$3 >= 1000 {print $1, $3, $5}' | column -t
echo

echo "Utilisateurs connectés :"
who
echo

echo "Dernières connexions (5 dernières) :"
last -n 5
echo

echo "Utilisateurs avec privilèges sudo :"
getent group sudo | cut -d: -f4 | tr ',' '\n' | sort
echo

echo "Comptes verrouillés :"
sudo passwd -S -a | grep " L " | cut -d' ' -f1
```

### Fonction de gestion de groupes
```bash
# Fonction pour gérer facilement les groupes
manage_group() {
    local action="$1"
    local group="$2"
    local user="$3"
    
    case "$action" in
        "add-user")
            sudo gpasswd -a "$user" "$group"
            echo "Utilisateur $user ajouté au groupe $group"
            ;;
        "remove-user")
            sudo gpasswd -d "$user" "$group"
            echo "Utilisateur $user retiré du groupe $group"
            ;;
        "list-members")
            getent group "$group" | cut -d: -f4 | tr ',' '\n'
            ;;
        "create")
            sudo groupadd "$group"
            echo "Groupe $group créé"
            ;;
        "delete")
            sudo groupdel "$group"
            echo "Groupe $group supprimé"
            ;;
        *)
            echo "Usage: manage_group {add-user|remove-user|list-members|create|delete} <group> [user]"
            ;;
    esac
}

# Exemples d'utilisation :
# manage_group create developers
# manage_group add-user developers alice
# manage_group list-members developers
```

## Sécurité et bonnes pratiques

### Politique de mots de passe
```bash
# Configuration dans /etc/login.defs
sudo nano /etc/login.defs

# Paramètres importants :
# PASS_MAX_DAYS 90    # Expiration
# PASS_MIN_DAYS 7     # Délai minimum entre changements
# PASS_MIN_LEN 8      # Longueur minimale
# PASS_WARN_AGE 7     # Avertissement avant expiration
```

### Verrouillage de comptes
```bash
# Verrouiller un compte
sudo passwd -l utilisateur
sudo usermod -L utilisateur

# Déverrouiller
sudo passwd -u utilisateur
sudo usermod -U utilisateur

# Vérifier l'état
sudo passwd -S utilisateur
```

### Expiration de comptes
```bash
# Définir une date d'expiration
sudo chage -E 2024-12-31 utilisateur

# Voir les informations d'expiration
sudo chage -l utilisateur

# Forcer le changement de mot de passe au prochain login
sudo chage -d 0 utilisateur
```

## Points clés à retenir

- **Structure** : utilisateur → groupe principal → groupes secondaires
- **Fichiers importants** : /etc/passwd, /etc/group, /etc/shadow
- **Types d'utilisateurs** : root (UID 0), système (UID < 1000), normaux (UID ≥ 1000)
- **Commandes principales** : useradd, usermod, userdel, groupadd, groupmod, groupdel
- **Changement d'identité** : su, sudo, newgrp
- **Surveillance** : who, w, last, ps aux
- **Sécurité** : verrouillage, expiration, audit
- **Permissions** : chaque fichier appartient à un utilisateur et un groupe
- **Groupes système** : sudo/wheel (admin), www-data (web), docker, etc.

## Exercices pratiques

### Exercice 1 : Gestion de base
```bash
# Créer un utilisateur
sudo useradd -m -s /bin/bash alice

# Définir le mot de passe
sudo passwd alice

# Ajouter aux groupes
sudo usermod -aG users,sudo alice

# Vérifier
id alice
```

### Exercice 2 : Gestion de groupes
```bash
# Créer un groupe projet
sudo groupadd project_team

# Ajouter plusieurs utilisateurs
sudo gpasswd -M alice,bob,charlie project_team

# Vérifier les membres
getent group project_team
```

### Exercice 3 : Audit et surveillance
```bash
# Qui est connecté ?
who

# Processus par utilisateur
ps aux | awk '{print $1}' | sort | uniq -c | sort -nr | head -10

# Dernières connexions
last | head -10
```