# Module Docker - Chapitre 3 : Volumes et réseaux

## Objectifs du chapitre
À l'issue de ce chapitre, vous serez capable de :
- Comprendre la persistance des données avec les volumes Docker
- Gérer les différents types de stockage (volumes, bind mounts, tmpfs)
- Maîtriser les réseaux Docker pour la communication inter-conteneurs
- Configurer l'isolation et la sécurité réseau
- Utiliser les réseaux personnalisés pour des architectures complexes
- Appliquer les bonnes pratiques de stockage et réseau

---

## 1. Persistance des données avec les volumes

### Problématique du stockage éphémère

**Comportement par défaut :**
```bash
# Conteneur avec données
docker run -it --name test-data alpine
# Dans le conteneur:
echo "données importantes" > /data/fichier.txt
exit

# Les données disparaissent avec le conteneur
docker rm test-data
# fichier.txt perdu !
```

**Pourquoi les conteneurs sont éphémères :**
- Conteneurs conçus pour être jetables et remplaçables
- Données stockées dans la couche d'écriture du conteneur
- Suppression du conteneur = perte des données

### Solutions de persistance

Docker offre trois mécanismes de persistance :

```
Host filesystem          Docker managed
+----------------+       +----------------+
|  Bind mounts   |       |    Volumes     |
| /host/path --> |       |   docker vol   |
| container/path |       |   container    |
+----------------+       +----------------+
                   \     /
                    \   /
               +-------------+
               |   tmpfs     |  <- Mémoire
               | (temporary) |     vive
               +-------------+
```

---

## 2. Volumes Docker

### Qu'est-ce qu'un volume ?

Un **volume** est un répertoire géré par Docker pour la persistance :
- Stocké en dehors du système de fichiers du conteneur
- Persiste après la suppression du conteneur
- Partageable entre conteneurs
- Sauvegardable et restaurable

### Gestion des volumes

#### Création et utilisation
```bash
# Créer un volume
docker volume create mon-volume

# Lister les volumes
docker volume ls

# Inspecter un volume
docker volume inspect mon-volume

# Utiliser un volume
docker run -v mon-volume:/data nginx

# Volume anonyme (créé automatiquement)
docker run -v /data nginx
```

#### Utilisation avancée
```bash
# Volume avec options
docker run --mount source=mon-volume,target=/data,readonly nginx

# Pilote de volume spécifique
docker run --mount type=volume,src=mon-volume,dst=/data,volume-driver=local nginx

# Partage entre conteneurs
docker run -d --name web1 -v shared-data:/var/www/html nginx
docker run -d --name web2 -v shared-data:/var/www/html nginx
```

### Exemple pratique : Base de données PostgreSQL

```bash
# Créer un volume pour PostgreSQL
docker volume create postgres-data

# Lancer PostgreSQL avec volume persistant
docker run -d \
  --name postgres-db \
  -e POSTGRES_PASSWORD=secret123 \
  -e POSTGRES_DB=myapp \
  -v postgres-data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13

# Vérifier la persistance
docker exec -it postgres-db psql -U postgres -d myapp -c "CREATE TABLE users (id SERIAL PRIMARY KEY, name TEXT);"

# Arrêter et redémarrer le conteneur
docker stop postgres-db
docker rm postgres-db

# Redémarrer avec le même volume
docker run -d \
  --name postgres-db-new \
  -e POSTGRES_PASSWORD=secret123 \
  -e POSTGRES_DB=myapp \
  -v postgres-data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13

# Les données sont toujours là !
docker exec -it postgres-db-new psql -U postgres -d myapp -c "\dt"
```

---

## 3. Bind mounts

### Principe des bind mounts

Un **bind mount** lie un répertoire de l'hôte à un répertoire du conteneur :

```bash
# Syntaxe bind mount
docker run -v /chemin/host:/chemin/conteneur image

# Exemple développement web
docker run -d \
  --name dev-web \
  -v $(pwd)/src:/var/www/html:ro \
  -p 8080:80 \
  nginx
```

### Cas d'usage typiques

#### Développement d'applications
```bash
# Projet Node.js en développement
mkdir mon-projet-node
cd mon-projet-node

# Structure du projet
cat > package.json << 'EOF'
{
  "name": "mon-app",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

cat > app.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello Docker Development!');
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App running on port ${port}`);
});
EOF

# Développement avec bind mount
docker run -d \
  --name node-dev \
  -v $(pwd):/usr/src/app \
  -w /usr/src/app \
  -p 3000:3000 \
  node:16-alpine \
  sh -c "npm install && npm start"

# Modifications du code répercutées instantanément
```

#### Configuration d'applications
```bash
# Configuration Nginx personnalisée
docker run -d \
  --name custom-nginx \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  -p 8080:80 \
  nginx

# Logs externalisés
docker run -d \
  --name app-with-logs \
  -v $(pwd)/logs:/var/log/app \
  mon-application
```

### Permissions et sécurité

```bash
# Problèmes de permissions courants
docker run --rm -v $(pwd):/data alpine touch /data/fichier.txt
ls -la fichier.txt
# fichier.txt appartient à root !

# Solution 1: Spécifier l'utilisateur
docker run --rm --user $(id -u):$(id -g) -v $(pwd):/data alpine touch /data/fichier2.txt

# Solution 2: Dans le Dockerfile
# RUN adduser -D -s /bin/sh -u $(id -u) appuser
# USER appuser

# Montage en lecture seule pour la sécurité
docker run -v $(pwd):/data:ro alpine
```

---

## 4. Réseaux Docker

### Réseaux par défaut

Docker crée automatiquement plusieurs réseaux :

```bash
# Lister les réseaux
docker network ls

# Réseaux par défaut :
# - bridge    : réseau par défaut
# - host      : utilise directement la stack réseau de l'hôte
# - none      : pas de réseau
```

#### Réseau bridge (défaut)

```bash
# Les conteneurs communiquent via le réseau bridge
docker run -d --name web1 nginx
docker run -d --name web2 nginx

# Inspection du réseau bridge
docker network inspect bridge

# Communication via IP (pas idéal)
docker exec web1 ping 172.17.0.3
```

### Réseaux personnalisés

#### Création et gestion
```bash
# Créer un réseau personnalisé
docker network create mon-reseau

# Avec options spécifiques
docker network create \
  --driver bridge \
  --subnet 192.168.1.0/24 \
  --gateway 192.168.1.1 \
  --ip-range 192.168.1.128/25 \
  reseau-custom

# Utiliser le réseau
docker run -d --name web --network mon-reseau nginx

# Connecter un conteneur existant
docker network connect mon-reseau conteneur-existant

# Déconnecter
docker network disconnect mon-reseau conteneur-existant
```

#### Résolution de noms DNS

```bash
# Créer un réseau pour la découverte de services
docker network create app-network

# Lancer des services
docker run -d --name database --network app-network postgres:13
docker run -d --name backend --network app-network mon-api
docker run -d --name frontend --network app-network nginx

# Communication par nom de service
docker exec backend ping database
docker exec frontend curl http://backend:3000/api
```

### Exemple pratique : Stack LAMP

```bash
# Créer un réseau pour la stack LAMP
docker network create lamp-network

# Base de données MySQL
docker run -d \
  --name mysql-db \
  --network lamp-network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=webapp \
  -e MYSQL_USER=webuser \
  -e MYSQL_PASSWORD=webpass \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0

# Serveur web PHP
docker run -d \
  --name php-web \
  --network lamp-network \
  -v $(pwd)/html:/var/www/html \
  -p 8080:80 \
  php:8.1-apache

# Test de connexion à la base
cat > html/test-db.php << 'EOF'
<?php
$servername = "mysql-db";
$username = "webuser";
$password = "webpass";
$dbname = "webapp";

try {
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    echo "Connexion à MySQL réussie !";
} catch(PDOException $e) {
    echo "Erreur : " . $e->getMessage();
}
?>
EOF

# Accéder à http://localhost:8080/test-db.php
```

---

## 5. Types de réseaux avancés

### Réseau host

```bash
# Utilise directement la stack réseau de l'hôte
docker run -d --name web-host --network host nginx

# Avantages : performances réseau maximales
# Inconvénients : moins d'isolation, conflits de ports possibles
```

### Réseau none

```bash
# Pas de connectivité réseau
docker run -it --network none alpine

# Cas d'usage : traitement de données sensibles, conteneurs utilitaires
```

### Réseau overlay (multi-hôte)

```bash
# Pour Docker Swarm (clustering)
docker network create \
  --driver overlay \
  --attachable \
  multi-host-network

# Permet la communication entre conteneurs sur différents hôtes
```

### Réseau macvlan

```bash
# Assigne une adresse MAC unique au conteneur
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  macvlan-net

# Le conteneur apparaît comme un device physique sur le réseau
docker run -d --network macvlan-net --ip 192.168.1.100 nginx
```

---

## 6. Gestion des ports et exposition

### Publication de ports

```bash
# Port spécifique
docker run -p 8080:80 nginx               # Hôte:8080 -> Conteneur:80

# Tous les ports exposés
docker run -P nginx                       # Ports automatiques

# Interface spécifique
docker run -p 127.0.0.1:8080:80 nginx    # Seulement sur localhost

# Plage de ports
docker run -p 8080-8090:8080-8090 nginx  # Plage de ports

# Protocole UDP
docker run -p 53:53/udp dns-server        # Port UDP
```

### Découverte de ports

```bash
# Voir les ports d'un conteneur
docker port conteneur

# Via inspect
docker inspect --format='{{.NetworkSettings.Ports}}' conteneur

# Ports en cours d'utilisation
netstat -tlnp | grep docker
```

---

## 7. Sécurité réseau

### Isolation des réseaux

```bash
# Environnements séparés
docker network create production-network
docker network create development-network
docker network create testing-network

# Les conteneurs ne peuvent communiquer qu'au sein du même réseau
docker run -d --name prod-web --network production-network nginx
docker run -d --name dev-web --network development-network nginx

# prod-web et dev-web sont isolés
```

### Firewall et règles iptables

```bash
# Docker modifie automatiquement iptables
iptables -L DOCKER

# Désactiver la modification automatique (non recommandé)
# Dans /etc/docker/daemon.json :
{
  "iptables": false
}

# Règles personnalisées
iptables -I DOCKER-USER -s 10.0.0.0/8 -j DROP
iptables -I DOCKER-USER -s 172.16.0.0/12 -j DROP
```

### Chiffrement des communications

```bash
# Réseau avec chiffrement (Docker Swarm)
docker network create \
  --driver overlay \
  --opt encrypted \
  secure-network

# TLS entre conteneurs
docker run -d \
  --name secure-app \
  -v $(pwd)/certs:/certs:ro \
  --network secure-network \
  nginx-with-tls
```

---

## 8. Monitoring et debugging réseau

### Outils de diagnostic

```bash
# Inspecter les réseaux
docker network inspect bridge
docker network inspect mon-reseau

# Connectivité entre conteneurs
docker exec conteneur1 ping conteneur2
docker exec conteneur1 telnet conteneur2 80

# DNS dans les conteneurs
docker exec conteneur nslookup autre-conteneur
docker exec conteneur dig autre-conteneur

# Trafic réseau
docker exec conteneur netstat -tuln
docker exec conteneur ss -tuln
```

### Surveillance du trafic

```bash
# Stats réseau
docker stats --format "table {{.Name}}\t{{.NetIO}}"

# Capture de paquets
docker exec conteneur tcpdump -i eth0 -n

# Logs réseau (avec des pilotes de logs appropriés)
docker logs conteneur 2>&1 | grep -E "(connection|network|port)"
```

---

## 9. Cas d'usage avancés

### Stack de monitoring avec volumes et réseaux

```bash
# Créer un réseau de monitoring
docker network create monitoring

# Volume pour Prometheus
docker volume create prometheus-data

# Prometheus
docker run -d \
  --name prometheus \
  --network monitoring \
  -p 9090:9090 \
  -v prometheus-data:/prometheus \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
  prom/prometheus

# Grafana avec volume pour dashboards
docker volume create grafana-data
docker run -d \
  --name grafana \
  --network monitoring \
  -p 3000:3000 \
  -v grafana-data:/var/lib/grafana \
  grafana/grafana

# Node exporter
docker run -d \
  --name node-exporter \
  --network monitoring \
  -p 9100:9100 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /:/rootfs:ro \
  prom/node-exporter
```

### Développement avec hot reload

```bash
# Projet React avec hot reload
docker run -it \
  --name react-dev \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/public:/app/public \
  -v $(pwd)/package.json:/app/package.json \
  -v react-node-modules:/app/node_modules \
  -p 3000:3000 \
  -e CHOKIDAR_USEPOLLING=true \
  node:16-alpine \
  sh -c "cd /app && npm start"
```

---

## 10. Bonnes pratiques

### Volumes

#### Production
```bash
# Nommer explicitement les volumes
docker volume create --name app-data

# Sauvegardes régulières
docker run --rm \
  -v app-data:/source:ro \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/app-data-$(date +%Y%m%d).tar.gz -C /source .

# Monitoring de l'espace disque
docker system df
docker volume ls --filter dangling=true
```

#### Développement
```bash
# .dockerignore pour les bind mounts
echo "node_modules/" >> .dockerignore
echo ".git/" >> .dockerignore
echo "*.log" >> .dockerignore

# Volumes pour les dépendances
docker run -v $(pwd):/app -v node-modules:/app/node_modules node:16-alpine
```

### Réseaux

#### Sécurité
```bash
# Réseaux dédiés par environnement
docker network create --internal backend-network
docker network create frontend-network

# Proxy inverse pour l'exposition
docker run -d \
  --name proxy \
  --network frontend-network \
  -p 80:80 \
  -p 443:443 \
  nginx-proxy
```

#### Performance
```bash
# Réseaux host pour applications haute performance
docker run -d --network host high-performance-app

# Réglage des MTU si nécessaire
docker network create --opt com.docker.network.driver.mtu=9000 jumbo-network
```

---

## Points clés à retenir

1. **Volumes** pour la persistance, **bind mounts** pour le développement
2. **Réseaux personnalisés** permettent la découverte DNS
3. **Isolation réseau** sépare les environnements
4. **Nommage des ressources** facilite la gestion
5. **Monitoring** essentiel pour diagnostiquer les problèmes
6. **Sauvegardes** régulières des volumes critiques

---

## Commandes essentielles - Aide-mémoire

```bash
# Volumes
docker volume create nom
docker volume ls
docker volume inspect nom
docker volume rm nom
docker run -v volume:/path image

# Bind mounts
docker run -v /host:/container image
docker run -v $(pwd):/app image

# Réseaux
docker network create nom
docker network ls
docker network inspect nom
docker network rm nom
docker run --network nom image

# Ports
docker run -p host:container image
docker port conteneur
docker run -P image

# Nettoyage
docker volume prune
docker network prune
docker system prune
```

---

## Prochaine étape

Au chapitre suivant, nous découvrirons **Docker Compose** pour orchestrer des applications multi-conteneurs et simplifier la gestion des stacks complexes.