# Module Docker - Chapitre 1 : Introduction et concepts de base

## Prérequis
- Avoir suivi les modules 1 à 4 de la formation Linux
- Maîtriser les commandes de base du terminal
- Comprendre les concepts de processus et services Linux
- Notions de base sur les réseaux

## Objectifs du chapitre
À l'issue de ce chapitre, vous serez capable de :
- Comprendre les concepts de conteneurisation
- Expliquer les avantages de Docker par rapport aux machines virtuelles
- Installer Docker sur votre système Linux
- Comprendre l'architecture Docker et ses composants
- Utiliser les commandes Docker de base

---

## 1. Qu'est-ce que la conteneurisation ?

### Problème traditionnel du déploiement

**Scenario typique :**
- Application développée sur Ubuntu 20.04 avec Python 3.8
- Serveur de production sous CentOS 7 avec Python 3.6
- Résultat : "Ça marche sur ma machine !" mais pas en production

**Problèmes courants :**
- Différences d'environnements (OS, versions des dépendances)
- Conflits entre applications sur le même serveur
- Installation et configuration complexes
- Isolation insuffisante entre les applications

### Solution : la conteneurisation

La **conteneurisation** permet d'empaqueter une application avec toutes ses dépendances dans un "conteneur" portable.

**Avantages :**
- **Portabilité** : même environnement partout
- **Isolation** : chaque conteneur est séparé
- **Légèreté** : partage du noyau de l'OS hôte
- **Scalabilité** : démarrage rapide des conteneurs
- **Reproductibilité** : même comportement garanti

---

## 2. Docker : présentation générale

### Qu'est-ce que Docker ?

Docker est une plateforme de conteneurisation qui permet de :
- Créer des conteneurs d'applications
- Distribuer ces conteneurs via des registres
- Exécuter des conteneurs sur différents environnements
- Orchestrer des applications multi-conteneurs

### Historique et adoption
- **2013** : Création de Docker par Solomon Hykes
- **2014** : Docker 1.0, adoption massive
- **2017** : Kubernetes devient le standard d'orchestration
- **Aujourd'hui** : Standard de facto pour la conteneurisation

---

## 3. Conteneurs vs Machines virtuelles

### Architecture des machines virtuelles
```
+---------------------+
|   Application A     |
+---------------------+
|   OS invité A       |
+---------------------+
|   Application B     |
+---------------------+
|   OS invité B       |
+---------------------+
|    Hyperviseur      |
+---------------------+
|     OS hôte         |
+---------------------+
|     Matériel        |
+---------------------+
```

### Architecture des conteneurs
```
+---------------------+
| App A | App B | App C|
+---------------------+
|   Docker Engine     |
+---------------------+
|     OS hôte         |
+---------------------+
|     Matériel        |
+---------------------+
```

### Comparaison détaillée

| Aspect | Machines Virtuelles | Conteneurs |
|--------|-------------------|------------|
| **Isolation** | Complète (OS séparé) | Processus (noyau partagé) |
| **Overhead** | Élevé (plusieurs OS) | Faible (partage du noyau) |
| **Démarrage** | Minutes | Secondes |
| **Taille** | GB (OS complet) | MB (app + dépendances) |
| **Densité** | 10-20 VMs par serveur | 100+ conteneurs |
| **Sécurité** | Très forte | Bonne (namespaces) |
| **Portabilité** | Limitée (formats propriétaires) | Excellente (standards ouverts) |

---

## 4. Architecture Docker

### Composants principaux

#### Docker Engine
Le moteur Docker comprend :
- **dockerd** : daemon Docker (serveur)
- **docker** : client CLI
- **containerd** : runtime de conteneurs
- **runc** : runtime bas niveau

#### Docker Client
Interface utilisateur pour interagir avec Docker :
```bash
docker run nginx        # Client envoie la commande
# -> Docker daemon traite la demande
# -> Télécharge l'image si nécessaire
# -> Lance le conteneur
```

#### Docker Registry
Stockage et distribution des images :
- **Docker Hub** : registre public par défaut
- **Registres privés** : Harbor, GitLab Registry, AWS ECR
- **Registre local** : pour les entreprises

### Architecture globale
```
+-------------------+    +-------------------+
|   Docker Client   |    |   Docker Client   |
|   (docker CLI)    |    |     (Docker      |
|                   |    |     Desktop)     |
+-------------------+    +-------------------+
         |                        |
         +------------------------+
                     |
         +-----------v-----------+
         |    Docker Daemon      |
         |     (dockerd)         |
         +-----------------------+
         |   Images | Containers |
         +-----------------------+
                     |
         +-----------v-----------+
         |     Docker Registry   |
         |    (Docker Hub, etc.) |
         +-----------------------+
```

---

## 5. Concepts clés de Docker

### Images
Une **image** est un modèle en lecture seule pour créer des conteneurs :
- Contient l'application et ses dépendances
- Organisée en couches (layers)
- Immuable une fois créée
- Stockée dans un registre

**Exemple :** `nginx:1.21-alpine`
- `nginx` : nom de l'image
- `1.21` : version
- `alpine` : variante (OS léger)

### Conteneurs
Un **conteneur** est une instance d'exécution d'une image :
- Processus isolé sur l'OS hôte
- Possède son propre système de fichiers
- État modifiable (peut être démarré/arrêté)
- Peut avoir des volumes pour la persistance

### Dockerfile
Un **Dockerfile** est un script de construction d'images :
```dockerfile
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y python3
COPY app.py /app/
WORKDIR /app
CMD ["python3", "app.py"]
```

### Volumes
Les **volumes** permettent la persistance des données :
- Survient à l'arrêt du conteneur
- Partageable entre conteneurs
- Sauvegardable et restaurable

### Réseaux
Les **réseaux** Docker permettent la communication :
- Isolation réseau entre conteneurs
- Communication inter-conteneurs
- Exposition de ports vers l'hôte

---

## 6. Installation de Docker

### Installation sur Ubuntu/Debian
```bash
# Mise à jour du système
sudo apt update

# Installation des prérequis
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Ajout de la clé GPG Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Ajout du dépôt Docker
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Démarrage et activation
sudo systemctl start docker
sudo systemctl enable docker
```

### Installation sur CentOS/RHEL
```bash
# Installation des utils
sudo yum install -y yum-utils

# Ajout du dépôt Docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Installation
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Démarrage
sudo systemctl start docker
sudo systemctl enable docker
```

### Configuration post-installation
```bash
# Ajouter l'utilisateur au groupe docker (évite sudo)
sudo usermod -aG docker $USER

# Recharger les groupes (ou se reconnecter)
newgrp docker

# Vérifier l'installation
docker --version
docker info
```

### Test de l'installation
```bash
# Premier conteneur Hello World
docker run hello-world

# Si tout fonctionne, vous verrez :
# "Hello from Docker! This message shows that..."
```

---

## 7. Premières commandes Docker

### Informations système
```bash
# Version de Docker
docker version

# Informations détaillées sur Docker
docker info

# Aide sur les commandes
docker --help
docker run --help
```

### Gestion des images
```bash
# Lister les images locales
docker images

# Télécharger une image
docker pull nginx
docker pull python:3.9-alpine

# Rechercher des images sur Docker Hub
docker search mysql

# Supprimer une image
docker rmi nginx
```

### Gestion des conteneurs
```bash
# Lancer un conteneur
docker run nginx

# Lancer en arrière-plan (detached)
docker run -d nginx

# Lancer avec un nom
docker run --name mon-nginx -d nginx

# Lister les conteneurs actifs
docker ps

# Lister tous les conteneurs
docker ps -a

# Arrêter un conteneur
docker stop mon-nginx

# Démarrer un conteneur arrêté
docker start mon-nginx

# Supprimer un conteneur
docker rm mon-nginx
```

### Interaction avec les conteneurs
```bash
# Exécuter une commande dans un conteneur
docker exec -it mon-nginx bash

# Voir les logs d'un conteneur
docker logs mon-nginx

# Suivre les logs en temps réel
docker logs -f mon-nginx

# Inspecter un conteneur
docker inspect mon-nginx
```

---

## 8. Cas d'usage courants

### Développement d'applications
- **Environnements cohérents** entre développeurs
- **Tests automatisés** dans des conteneurs propres
- **Dépendances isolées** par projet

### Déploiement d'applications
- **Déploiement simplifié** : même image partout
- **Rollback facile** : changement de version d'image
- **Scalabilité horizontale** : multiplication des conteneurs

### Microservices
- **Isolation** : chaque service dans son conteneur
- **Technologies multiples** : différents langages/frameworks
- **Orchestration** : Kubernetes, Docker Swarm

### CI/CD
- **Builds reproductibles** : environnement de build fixe
- **Tests isolés** : chaque test dans un conteneur frais
- **Déploiement automatisé** : push d'images vers la production

---

## 9. Bonnes pratiques de sécurité

### Images
- Utiliser des **images officielles** quand possible
- **Scanner les vulnérabilités** avec des outils comme Trivy
- **Minimiser la surface d'attaque** (images Alpine)
- **Éviter les images latest** en production

### Conteneurs
- **Ne pas exécuter en root** dans les conteneurs
- **Limiter les capabilities** Linux
- **Utiliser des secrets** pour les données sensibles
- **Réseaux isolés** pour séparer les environnements

### Runtime
- **Limiter les ressources** (CPU, mémoire)
- **Logs centralisés** pour la surveillance
- **Mise à jour régulière** de Docker et des images
- **Sauvegarde des volumes** critiques

---

## Points clés à retenir

1. **Docker** révolutionne le déploiement d'applications
2. **Conteneurs** plus légers et rapides que les VMs
3. **Images** sont des modèles, **conteneurs** sont les instances
4. **Isolation** via les namespaces Linux
5. **Portabilité** : même comportement partout
6. **DevOps** : facilite développement, test et déploiement

---

## Commandes essentielles - Aide-mémoire

```bash
# Installation et info
docker --version
docker info

# Images
docker pull <image>          # Télécharger
docker images               # Lister
docker rmi <image>          # Supprimer

# Conteneurs
docker run <image>          # Lancer
docker run -d <image>       # En arrière-plan
docker ps                   # Lister (actifs)
docker ps -a               # Lister (tous)
docker stop <container>     # Arrêter
docker start <container>    # Démarrer
docker rm <container>       # Supprimer

# Interaction
docker exec -it <container> bash  # Shell interactif
docker logs <container>           # Voir les logs
```

---

## Pour aller plus loin

- Site officiel : [docker.com](https://docker.com)
- Documentation : [docs.docker.com](https://docs.docker.com)
- Docker Hub : [hub.docker.com](https://hub.docker.com)
- Tutoriel interactif : [play-with-docker.com](https://play-with-docker.com)

---

## Prochaine étape

Au chapitre suivant, nous approfondirons la **gestion des images et conteneurs** avec des exemples pratiques et la création de nos premières images personnalisées.