# TP1 - Installation Docker et premiers conteneurs

## Objectifs
- Installer Docker sur votre système Linux
- Maîtriser les commandes de base
- Lancer vos premiers conteneurs
- Comprendre le cycle de vie des conteneurs

## Durée estimée
2 heures

---

## Exercice 1 : Installation de Docker

### 1.1 Vérification des prérequis
```bash
# Vérifier la version du système
cat /etc/os-release

# Vérifier l'espace disque disponible
df -h

# Vérifier les droits sudo
sudo whoami
```

**Question :** Quelle distribution Linux utilisez-vous ?

### 1.2 Installation Docker (Ubuntu/Debian)
```bash
# Mise à jour des paquets
sudo apt update

# Installation des prérequis
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Ajout de la clé GPG Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Ajout du dépôt
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Démarrage du service
sudo systemctl start docker
sudo systemctl enable docker
```

### 1.3 Configuration post-installation
```bash
# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER

# Recharger les groupes (ou se déconnecter/reconnecter)
newgrp docker

# Test de l'installation
docker --version
docker info
```

**Question :** Quelle version de Docker avez-vous installée ?

---

## Exercice 2 : Premier conteneur Hello World

### 2.1 Lancement du conteneur Hello World
```bash
# Premier conteneur
docker run hello-world
```

**Questions :**
1. Que fait cette commande ?
2. Où Docker a-t-il trouvé l'image `hello-world` ?
3. Que se passe-t-il après l'exécution ?

### 2.2 Analyse des images téléchargées
```bash
# Lister les images locales
docker images

# Examiner l'image hello-world
docker inspect hello-world
```

**Questions :**
1. Quelle est la taille de l'image `hello-world` ?
2. Combien de couches (layers) contient-elle ?

---

## Exercice 3 : Conteneur Ubuntu interactif

### 3.1 Lancement d'un shell Ubuntu
```bash
# Lancer un conteneur Ubuntu avec shell interactif
docker run -it ubuntu:20.04 bash
```

Une fois dans le conteneur :
```bash
# Explorer le système
cat /etc/os-release
whoami
pwd
ls /

# Installer un package
apt update
apt install -y curl

# Tester curl
curl --version

# Sortir du conteneur
exit
```

**Questions :**
1. Dans quel répertoire vous trouvez-vous au démarrage ?
2. Quel utilisateur êtes-vous dans le conteneur ?
3. Que se passe-t-il quand vous tapez `exit` ?

### 3.2 Relancement du conteneur
```bash
# Essayer de relancer le même conteneur
docker run -it ubuntu:20.04 bash
```

Dans le nouveau conteneur :
```bash
# Vérifier si curl est toujours installé
curl --version
```

**Question :** Pourquoi curl n'est-il plus installé ?

---

## Exercice 4 : Gestion des conteneurs

### 4.1 Conteneurs en arrière-plan
```bash
# Lancer nginx en arrière-plan
docker run -d --name mon-nginx nginx

# Vérifier qu'il tourne
docker ps

# Voir les logs
docker logs mon-nginx

# Examiner le conteneur en détail
docker inspect mon-nginx
```

### 4.2 Interaction avec un conteneur en cours
```bash
# Exécuter des commandes dans le conteneur
docker exec mon-nginx ls /etc/nginx

# Ouvrir un shell dans le conteneur
docker exec -it mon-nginx bash
```

Dans le conteneur nginx :
```bash
# Explorer la configuration nginx
cat /etc/nginx/nginx.conf
ls /usr/share/nginx/html/
cat /usr/share/nginx/html/index.html

# Sortir
exit
```

### 4.3 Arrêt et suppression
```bash
# Arrêter le conteneur
docker stop mon-nginx

# Vérifier l'état
docker ps
docker ps -a

# Redémarrer le conteneur
docker start mon-nginx

# Supprimer le conteneur (il doit être arrêté)
docker stop mon-nginx
docker rm mon-nginx
```

---

## Exercice 5 : Mapping de ports

### 5.1 Nginx accessible depuis l'hôte
```bash
# Lancer nginx avec mapping de port
docker run -d --name nginx-web -p 8080:80 nginx

# Vérifier que le port est mappé
docker port nginx-web

# Tester l'accès web
curl http://localhost:8080
```

**Questions :**
1. Que signifie `-p 8080:80` ?
2. Comment accéder à ce serveur web depuis un navigateur ?

### 5.2 Personnaliser le contenu
```bash
# Créer une page HTML personnalisée
mkdir -p ~/docker-tp
echo "<h1>Mon premier serveur Docker</h1><p>TP Docker - $(date)</p>" > ~/docker-tp/index.html

# Monter le fichier dans le conteneur
docker stop nginx-web
docker rm nginx-web
docker run -d --name nginx-web -p 8080:80 -v ~/docker-tp/index.html:/usr/share/nginx/html/index.html nginx

# Tester la personnalisation
curl http://localhost:8080
```

---

## Exercice 6 : Exploration d'images diverses

### 6.1 Base de données Redis
```bash
# Lancer Redis
docker run -d --name mon-redis -p 6379:6379 redis

# Tester Redis avec un client
docker run -it --rm --link mon-redis:redis redis redis-cli -h redis ping
```

### 6.2 Python interactif
```bash
# Lancer un conteneur Python
docker run -it --rm python:3.9-alpine python

# Dans l'interpréteur Python
print("Hello from Docker!")
import os
print(os.uname())
exit()
```

### 6.3 Node.js
```bash
# Créer un fichier JavaScript
echo "console.log('Hello from Node.js in Docker!');" > ~/docker-tp/hello.js

# Exécuter avec Node.js
docker run --rm -v ~/docker-tp:/app -w /app node:16-alpine node hello.js
```

---

## Exercice 7 : Nettoyage et bonnes pratiques

### 7.1 Nettoyage des ressources
```bash
# Arrêter tous les conteneurs
docker stop $(docker ps -q)

# Supprimer tous les conteneurs arrêtés
docker container prune

# Supprimer les images non utilisées
docker image prune

# Voir l'utilisation d'espace
docker system df

# Nettoyage complet (ATTENTION: supprime tout ce qui n'est pas utilisé)
docker system prune -a
```

### 7.2 Informations système
```bash
# Statistiques en temps réel
docker stats

# Processus Docker
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Historique des commandes
docker history ubuntu:20.04
```

---

## Questions de synthèse

1. **Architecture** : Expliquez la différence entre une image et un conteneur Docker.

2. **Cycle de vie** : Décrivez le cycle de vie d'un conteneur depuis sa création jusqu'à sa suppression.

3. **Isolation** : Comment Docker assure-t-il l'isolation entre les conteneurs ?

4. **Performance** : Quels sont les avantages de Docker par rapport aux machines virtuelles ?

5. **Cas d'usage** : Dans quels scénarios utiliseriez-vous Docker ?

---

## Défis bonus

### Défi 1 : Serveur web multi-pages
Créez un serveur nginx qui sert plusieurs pages HTML personnalisées.

### Défi 2 : Base de données persistante
Lancez une base de données MySQL avec des données qui survivent au redémarrage du conteneur.

### Défi 3 : Application complète
Combinez un serveur web et une base de données pour créer une stack applicative simple.

---

## Ressources

- [Documentation Docker](https://docs.docker.com)
- [Docker Hub](https://hub.docker.com) - Registry d'images publiques
- [Docker Cheat Sheet](https://github.com/wsargent/docker-cheat-sheet)

---

## Solutions

### Solution Exercice 2.1
La commande `docker run hello-world` télécharge l'image hello-world depuis Docker Hub, crée un conteneur, l'exécute, affiche le message, puis le conteneur s'arrête automatiquement.

### Solution Exercice 3.2
curl n'est plus installé car chaque `docker run` crée un **nouveau** conteneur à partir de l'image de base. Les modifications faites dans un conteneur ne persistent pas dans l'image.

### Solution Défi 1
```bash
mkdir -p ~/docker-tp/website
echo "<h1>Accueil</h1>" > ~/docker-tp/website/index.html
echo "<h1>À propos</h1>" > ~/docker-tp/website/about.html
docker run -d --name site-web -p 8080:80 -v ~/docker-tp/website:/usr/share/nginx/html nginx
```