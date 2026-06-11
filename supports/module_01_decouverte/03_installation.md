# Installation et configuration

Ce chapitre couvre les deux modes d'installation selon votre contexte de formation.

## Scénario 1 : Accès SSH à une VM Linux

### Présentation du scénario
Vous disposez déjà d'une machine virtuelle Linux configurée et d'un accès SSH avec authentification par clés.

### Configuration SSH

#### Vérification de votre accès
```bash
ssh utilisateur@adresse.ip.du.serveur
```

#### Éléments de la connexion SSH
- **Nom d'utilisateur** : fourni par le formateur
- **Adresse IP** : adresse de votre VM Linux
- **Clé privée** : stockée sur votre poste Windows
- **Port SSH** : généralement 22 (par défaut)

#### Clients SSH recommandés sur Windows
- **PuTTY** : Client SSH graphique classique
- **Windows Terminal** + OpenSSH : Intégré Windows 10/11
- **MobaXterm** : Terminal avec fonctionnalités avancées
- **VS Code** : Avec extension Remote SSH

#### Configuration de PuTTY
1. Ouvrir PuTTY
2. **Session** : Saisir l'adresse IP
3. **Connection > SSH > Auth** : Charger votre clé privée (.ppk)
4. **Connection > Data** : Saisir le nom d'utilisateur
5. Sauvegarder la session pour usage futur

### Première connexion
```bash
# Test de connexion
ssh -i chemin/vers/cle_privee utilisateur@IP_serveur

# Vérification du système
cat /etc/os-release
whoami
pwd
```

### Avantages de ce scénario
- **Démarrage immédiat** : Pas d'installation à faire
- **Environnement uniforme** : Tous sur la même configuration
- **Focus apprentissage** : Concentration sur les commandes Linux
- **Accès distant** : Simulation d'un vrai environnement de production

## Scénario 2 : Installation VirtualBox + Debian

### Présentation du scénario  
Installation complète d'un environnement Linux sur votre poste Windows via VirtualBox.

### Prérequis système
- **RAM** : 4 GB minimum (8 GB recommandés)
- **Stockage** : 20 GB libres sur D:/
- **Processeur** : Support de la virtualisation (VT-x/AMD-V)
- **Windows** : 10 ou 11

### Étape 1 : Installation de VirtualBox

#### Téléchargement
1. Aller sur https://www.virtualbox.org
2. Télécharger "VirtualBox for Windows hosts"
3. Télécharger aussi "VirtualBox Extension Pack"

#### Installation
1. Exécuter le fichier d'installation
2. Suivre l'assistant (options par défaut)
3. Installer l'Extension Pack après VirtualBox
4. Redémarrer si demandé

#### Vérification de la virtualisation
```cmd
# Dans PowerShell (en tant qu'administrateur)
Get-ComputerInfo | select WindowsProductName, TotalPhysicalMemory
systeminfo | findstr "Hyper-V"
```

### Étape 2 : Téléchargement de Debian

#### Image ISO recommandée
- **Debian 12 (Bookworm)** - netinst (400 MB environ)
- URL : https://www.debian.org/distrib/
- Choisir "Small CDs or USB sticks" → "amd64"

#### Pourquoi Debian ?
- **Stabilité** : Distribution de référence
- **Pédagogique** : Approche pure sans ajouts
- **Universelle** : Base de nombreuses autres distributions
- **Documentation** : Excellente qualité

### Étape 3 : Création de la VM

#### Configuration de la machine virtuelle
```
Nom : FormationLinux
Type : Linux
Version : Debian (64-bit)
RAM : 2048 MB (2 GB)
Disque dur : 20 GB (dynamique)
```

#### Paramètres détaillés
1. **Général** :
   - Nom : FormationLinux
   - Dossier : D:/MonNom/VirtualBox/
   
2. **Système** :
   - RAM : 2048 MB
   - Processeurs : 2 (si possible)
   - Accélération : VT-x/AMD-V activé

3. **Stockage** :
   - Disque dur : 20 GB (allocation dynamique)
   - Lecteur CD : Monter l'ISO Debian

4. **Réseau** :
   - Carte 1 : NAT (par défaut)
   - Redirections de ports optionnelles

### Étape 4 : Installation de Debian

#### Démarrage de l'installation
1. Démarrer la VM avec l'ISO montée
2. Choisir "Install" (pas graphical install)
3. Suivre l'assistant d'installation

#### Paramètres d'installation recommandés
```
Langue : Français
Pays : France  
Clavier : Français (azerty)
Nom de machine : debian-formation
Nom d'utilisateur : votre prénom
Mot de passe : choisir un mot de passe simple
Partitionnement : Tout sur une partition (option simple)
Miroir Debian : deb.debian.org
Logiciels : Décocher environnement de bureau, garder SSH et utilitaires
```

#### Installation minimale
- **Pas d'interface graphique** : Pour se concentrer sur la ligne de commande
- **SSH activé** : Pour pouvoir se connecter depuis Windows
- **Utilitaires standard** : Outils de base nécessaires

### Étape 5 : Configuration post-installation

#### Premier démarrage
```bash
# Connexion en tant qu'utilisateur normal
login: votre_nom_utilisateur
password: votre_mot_de_passe

# Vérification du système  
cat /etc/debian_version
ip addr show
```

#### Configuration réseau (si nécessaire)
```bash
# Vérifier la connectivité
ping google.com

# Si pas de réseau, configurer
sudo nano /etc/network/interfaces
```

#### Installation d'outils complémentaires
```bash
# Mise à jour du système
sudo apt update
sudo apt upgrade

# Installation d'outils utiles
sudo apt install curl wget tree vim htop
```

### Avantages de ce scénario
- **Apprentissage complet** : De l'installation à l'utilisation
- **Persistance** : VM sauvée sur D:/ entre les sessions  
- **Contrôle total** : Accès root, installation de paquets
- **Autonomie** : Environnement personnel configurable

## Comparaison des scénarios

| Aspect | SSH (Scénario 1) | VirtualBox (Scénario 2) |
|--------|------------------|-------------------------|
| **Temps setup** | 5 minutes | 2-3 heures |
| **Prérequis** | Client SSH | VirtualBox + ISO |
| **Contrôle** | Utilisateur limité | Contrôle complet |
| **Persistance** | Sessions temporaires | Sauvegarde locale |
| **Réseau** | Accès internet direct | Via NAT VirtualBox |
| **Performance** | Native serveur | Dépend du PC hôte |

## Configuration commune

### Personnalisation du shell
```bash
# Historique des commandes plus important
echo 'HISTSIZE=10000' >> ~/.bashrc

# Alias utiles
echo 'alias ll="ls -la"' >> ~/.bashrc
echo 'alias la="ls -A"' >> ~/.bashrc

# Rechargement de la configuration
source ~/.bashrc
```

### Vérification de l'environnement
```bash
# Informations système
uname -a
cat /proc/version
df -h
free -h
```

## Points clés à retenir

- **Scénario SSH** : Démarrage rapide, focus sur l'apprentissage
- **Scénario VirtualBox** : Apprentissage complet mais setup plus long
- **Debian** : Distribution stable et pédagogique
- **Configuration minimale** : Interface en ligne de commande privilégiée
- **Sauvegarde** : Important de sauver régulièrement l'état de la VM
- **Documentation** : Noter vos paramètres de connexion