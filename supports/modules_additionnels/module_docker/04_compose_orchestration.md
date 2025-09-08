# Module Docker - Chapitre 4 : Docker Compose et orchestration

## Objectifs du chapitre
À l'issue de ce chapitre, vous serez capable de :
- Comprendre les limites des commandes Docker unitaires
- Maîtriser Docker Compose pour orchestrer des applications multi-conteneurs
- Écrire des fichiers docker-compose.yml efficaces
- Gérer des environnements (développement, test, production)
- Utiliser les fonctionnalités avancées de Compose (secrets, configs, healthchecks)
- Déployer et maintenir des stacks applicatives complètes
- Découvrir les outils d'orchestration pour la production

---

## 1. Problématique des applications multi-conteneurs

### Limites des commandes Docker simples

**Scenario typique :** Application web avec base de données
```bash
# Commandes manuelles longues et répétitives
docker network create app-network

docker run -d \
  --name postgres-db \
  --network app-network \
  -e POSTGRES_PASSWORD=secret123 \
  -e POSTGRES_DB=myapp \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:13

docker run -d \
  --name redis-cache \
  --network app-network \
  redis:7-alpine

docker run -d \
  --name backend-api \
  --network app-network \
  -e DATABASE_URL=postgresql://postgres:secret123@postgres-db:5432/myapp \
  -e REDIS_URL=redis://redis-cache:6379 \
  -p 3000:3000 \
  mon-backend:latest

docker run -d \
  --name frontend-web \
  --network app-network \
  -e API_URL=http://backend-api:3000 \
  -p 8080:80 \
  mon-frontend:latest
```

**Problèmes identifiés :**
- **Complexité** : nombreuses commandes à mémoriser
- **Ordre de démarrage** : dépendances entre services
- **Gestion d'état** : difficile de tout arrêter/redémarrer
- **Environnements multiples** : dev/test/prod avec configurations différentes
- **Maintenance** : mise à jour laborieuse

---

## 2. Introduction à Docker Compose

### Qu'est-ce que Docker Compose ?

**Docker Compose** est un outil pour définir et exécuter des applications multi-conteneurs :
- **Fichier YAML** déclaratif (`docker-compose.yml`)
- **Une commande** pour démarrer toute la stack
- **Gestion des dépendances** automatique
- **Variables d'environnement** et configurations flexibles

### Installation

```bash
# Vérifier si Compose est déjà installé (souvent inclus avec Docker Desktop)
docker compose version

# Installation sur Linux si nécessaire
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Alternative : installation via pip
pip install docker-compose
```

### Premier exemple simple

**Fichier docker-compose.yml :**
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro

  db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: secret123
      POSTGRES_DB: myapp
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

**Utilisation :**
```bash
# Démarrer tous les services
docker compose up -d

# Voir les logs
docker compose logs

# Arrêter tous les services
docker compose down

# Arrêter et supprimer les volumes
docker compose down -v
```

---

## 3. Structure et syntaxe du fichier Compose

### Sections principales

```yaml
version: '3.8'  # Version du format Compose

services:       # Définition des conteneurs
  service1:
    # Configuration du service 1
  service2:
    # Configuration du service 2

networks:       # Réseaux personnalisés
  frontend:
  backend:

volumes:        # Volumes persistants
  data:
  logs:

configs:        # Configurations (Swarm)
  app-config:

secrets:        # Secrets (Swarm)
  db-password:
```

### Configuration des services

#### Image et build
```yaml
services:
  # Depuis une image existante
  web:
    image: nginx:1.21-alpine
    
  # Build depuis un Dockerfile
  api:
    build: ./backend
    
  # Build avec contexte et Dockerfile spécifique
  app:
    build:
      context: ./app
      dockerfile: Dockerfile.prod
      args:
        - VERSION=1.2.3
        - ENV=production
```

#### Ports et réseaux
```yaml
services:
  web:
    ports:
      - "8080:80"           # Port simple
      - "443:443"           # HTTPS
      - "127.0.0.1:3000:3000"  # IP spécifique
      - "9090-9099:9090-9099"  # Plage de ports
    
    networks:
      - frontend
      - backend
    
    # Alias réseau
    networks:
      backend:
        aliases:
          - api-server
```

#### Variables d'environnement
```yaml
services:
  app:
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
      - DEBUG=false
    
    # Depuis un fichier
    env_file:
      - .env
      - .env.prod
```

#### Volumes
```yaml
services:
  app:
    volumes:
      - data:/app/data              # Volume nommé
      - ./src:/app/src:ro           # Bind mount lecture seule
      - /var/run/docker.sock:/var/run/docker.sock  # Socket Docker
      
volumes:
  data:
    driver: local
    driver_opts:
      type: none
      device: /opt/app-data
      o: bind
```

#### Dépendances et santé
```yaml
services:
  web:
    depends_on:
      - db
      - redis
    
    # Avec conditions de santé
    depends_on:
      db:
        condition: service_healthy
    
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

---

## 4. Exemple complet : Stack MEAN

### Architecture de l'application

```
Frontend (Angular) <-> Backend (Node.js) <-> Database (MongoDB)
                            |
                       Cache (Redis)
```

### Fichier docker-compose.yml

```yaml
version: '3.8'

services:
  # Base de données MongoDB
  mongodb:
    image: mongo:5.0
    container_name: mean-mongodb
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: adminpassword
      MONGO_INITDB_DATABASE: meanapp
    volumes:
      - mongodb-data:/data/db
      - ./mongodb-init:/docker-entrypoint-initdb.d:ro
    networks:
      - backend
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongo mongodb:27017/test --quiet
      interval: 30s
      timeout: 10s
      retries: 3

  # Cache Redis
  redis:
    image: redis:7-alpine
    container_name: mean-redis
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass redispassword
    volumes:
      - redis-data:/data
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "auth", "redispassword", "ping"]
      interval: 30s
      timeout: 5s
      retries: 3

  # Backend API Node.js
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: mean-backend
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - MONGODB_URL=mongodb://admin:adminpassword@mongodb:27017/meanapp?authSource=admin
      - REDIS_URL=redis://:redispassword@redis:6379
      - JWT_SECRET=your-jwt-secret-key
      - PORT=3000
    ports:
      - "3000:3000"
    volumes:
      - ./backend/uploads:/app/uploads
    networks:
      - backend
      - frontend
    depends_on:
      mongodb:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Frontend Angular
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        - API_URL=http://localhost:3000/api
    container_name: mean-frontend
    restart: unless-stopped
    ports:
      - "4200:80"
    networks:
      - frontend
    depends_on:
      - backend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 5s
      retries: 3

  # Proxy inverse Nginx
  nginx:
    image: nginx:alpine
    container_name: mean-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    networks:
      - frontend
    depends_on:
      - frontend
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # Réseau interne, pas d'accès internet

volumes:
  mongodb-data:
    driver: local
  redis-data:
    driver: local
```

### Fichiers de configuration associés

**backend/Dockerfile :**
```dockerfile
FROM node:16-alpine

WORKDIR /app

# Dépendances
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Application
COPY src/ ./src/
COPY public/ ./public/

# Utilisateur non-root
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
RUN chown -R nodejs:nodejs /app
USER nodejs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "src/index.js"]
```

**nginx/nginx.conf :**
```nginx
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:3000;
    }

    upstream frontend {
        server frontend:80;
    }

    server {
        listen 80;
        server_name localhost;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # API Backend
        location /api/ {
            proxy_pass http://backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
```

---

## 5. Gestion des environnements

### Fichiers Compose multiples

**Structure recommandée :**
```
projet/
+-- docker-compose.yml          # Configuration de base
+-- docker-compose.dev.yml      # Surcharges pour développement
+-- docker-compose.prod.yml     # Surcharges pour production
+-- docker-compose.test.yml     # Surcharges pour tests
+-- .env                        # Variables par défaut
+-- .env.dev                    # Variables développement
+-- .env.prod                   # Variables production
+-- .env.test                   # Variables tests
```

**docker-compose.yml (base) :**
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-8080}:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro

  db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

**docker-compose.dev.yml (développement) :**
```yaml
version: '3.8'

services:
  web:
    volumes:
      - ./src:/usr/share/nginx/html  # Hot reload pour développement
    environment:
      - DEBUG=true

  db:
    ports:
      - "5432:5432"  # Exposition pour outils de dev
    environment:
      POSTGRES_PASSWORD: devpassword  # Mot de passe simple pour dev
```

**docker-compose.prod.yml (production) :**
```yaml
version: '3.8'

services:
  web:
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
```

### Utilisation avec override
```bash
# Développement
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Test
docker compose -f docker-compose.yml -f docker-compose.test.yml up --abort-on-container-exit
```

### Variables d'environnement

**.env :**
```env
# Base de données
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=changeme

# Application
WEB_PORT=8080
API_PORT=3000
NODE_ENV=development

# Monitoring
LOG_LEVEL=info
```

**.env.prod :**
```env
DB_PASSWORD=super-secure-production-password
NODE_ENV=production
LOG_LEVEL=warn
WEB_PORT=80
```

---

## 6. Commandes Docker Compose essentielles

### Gestion des services

```bash
# Démarrer tous les services
docker compose up

# En arrière-plan
docker compose up -d

# Services spécifiques
docker compose up db redis

# Avec rebuild des images
docker compose up --build

# Arrêter les services
docker compose down

# Arrêter et supprimer les volumes
docker compose down -v

# Redémarrer un service
docker compose restart web
```

### Logs et monitoring

```bash
# Voir tous les logs
docker compose logs

# Logs d'un service spécifique
docker compose logs web

# Suivre les logs en temps réel
docker compose logs -f

# Dernières lignes
docker compose logs --tail 100

# Status des services
docker compose ps

# Processus dans les conteneurs
docker compose top
```

### Exécution de commandes

```bash
# Commande ponctuelle
docker compose exec web nginx -s reload

# Shell interactif
docker compose exec db psql -U postgres

# Nouvelle instance (run vs exec)
docker compose run --rm web curl http://api:3000/health

# Variables d'environnement spécifiques
docker compose exec -e DEBUG=1 app npm test
```

### Scaling (mise à l'échelle)

```bash
# Multiplier les instances d'un service
docker compose up -d --scale web=3

# Scaling avec load balancer
docker compose up -d --scale backend=5 nginx
```

---

## 7. Fonctionnalités avancées

### Profiles pour différents cas d'usage

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"

  db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: secret

  # Service de développement seulement
  debug:
    image: busybox
    profiles:
      - debug
    command: sleep 3600

  # Service de test seulement
  test:
    build: ./tests
    profiles:
      - testing
    depends_on:
      - web
      - db
```

```bash
# Utilisation normale (web + db)
docker compose up -d

# Avec profil debug
docker compose --profile debug up -d

# Avec profil testing
docker compose --profile testing up --abort-on-container-exit
```

### Extensions et labels

```yaml
version: '3.8'

# Extension pour réutilisation
x-common-variables: &common
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: secret

x-logging: &default-logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"

services:
  db:
    image: postgres:13
    environment:
      <<: *common
      POSTGRES_DB: myapp
    logging: *default-logging
    labels:
      - "project=myapp"
      - "service=database"
      - "version=1.0"
```

### Configs et Secrets (Docker Swarm)

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    configs:
      - source: nginx-config
        target: /etc/nginx/nginx.conf
    secrets:
      - ssl-cert
      - ssl-key

configs:
  nginx-config:
    file: ./nginx.conf

secrets:
  ssl-cert:
    file: ./ssl/cert.pem
  ssl-key:
    file: ./ssl/key.pem
```

---

## 8. CI/CD avec Docker Compose

### Pipeline de développement

**docker-compose.test.yml :**
```yaml
version: '3.8'

services:
  test-db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: testpass
      POSTGRES_DB: testdb

  app-tests:
    build:
      context: .
      dockerfile: Dockerfile.test
    environment:
      DATABASE_URL: postgresql://postgres:testpass@test-db:5432/testdb
      NODE_ENV: test
    depends_on:
      - test-db
    command: npm test
    volumes:
      - ./coverage:/app/coverage
```

**Script CI/CD :**
```bash
#!/bin/bash

# Tests unitaires
docker compose -f docker-compose.test.yml up --build --abort-on-container-exit

# Vérifier que les tests passent
if [ $? -eq 0 ]; then
    echo "Tests réussis, construction de l'image de production"
    
    # Build pour production
    docker compose -f docker-compose.yml -f docker-compose.prod.yml build
    
    # Push vers le registre
    docker compose -f docker-compose.prod.yml push
else
    echo "Tests échoués, arrêt du pipeline"
    exit 1
fi

# Nettoyage
docker compose -f docker-compose.test.yml down -v
```

---

## 9. Introduction à l'orchestration avancée

### Limites de Docker Compose

**Docker Compose** est parfait pour :
- Développement local
- Tests automatisés
- Déploiements simples sur un seul serveur

**Mais limité pour :**
- Haute disponibilité multi-serveurs
- Mise à l'échelle automatique
- Rolling updates sans interruption
- Load balancing avancé

### Docker Swarm (intégré)

```bash
# Initialiser un cluster Swarm
docker swarm init

# Déployer une stack
docker stack deploy -c docker-compose.prod.yml mon-app

# Voir les services
docker service ls

# Scaler un service
docker service scale mon-app_web=5

# Mise à jour rolling
docker service update --image nginx:1.22-alpine mon-app_web
```

### Kubernetes (production enterprise)

**Avantages de Kubernetes :**
- Orchestration à grande échelle
- Self-healing et auto-scaling
- Service mesh et networking avancé
- Écosystème riche d'outils

**Migration Compose -> Kubernetes :**
```bash
# Outil Kompose pour conversion
kompose convert -f docker-compose.yml

# Génère des manifests Kubernetes YAML
# Nécessite souvent des ajustements manuels
```

### Autres solutions
- **Nomad** (HashiCorp) : simple et flexible
- **Rancher** : interface graphique pour Kubernetes
- **OpenShift** : Kubernetes enterprise (Red Hat)
- **AWS ECS/Fargate** : orchestration cloud AWS

---

## 10. Bonnes pratiques de production

### Structure de projet recommandée

```
projet/
+-- docker-compose.yml
+-- docker-compose.override.yml    # Développement (par défaut)
+-- docker-compose.prod.yml
+-- docker-compose.test.yml
+-- .env
+-- .env.example
+-- .dockerignore
+-- services/
|   +-- frontend/
|   |   +-- Dockerfile
|   |   +-- Dockerfile.prod
|   |   +-- src/
|   +-- backend/
|   |   +-- Dockerfile
|   |   +-- api/
|   +-- database/
|       +-- init/
|       +-- migrations/
+-- config/
|   +-- nginx/
|   +-- prometheus/
|   +-- grafana/
+-- scripts/
    +-- deploy.sh
    +-- backup.sh
    +-- health-check.sh
```

### Sécurité et monitoring

```yaml
version: '3.8'

services:
  app:
    image: mon-app:latest
    
    # Sécurité
    user: "1001:1001"
    read_only: true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    
    # Ressources
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    
    # Santé
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
    # Logs
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service,version"
    
    # Labels pour monitoring
    labels:
      - "traefik.enable=true"
      - "prometheus.scrape=true"
      - "prometheus.port=8080"
```

### Scripts de déploiement

**scripts/deploy.sh :**
```bash
#!/bin/bash

set -e

ENV=${1:-dev}
echo "Déploiement en environnement: $ENV"

# Variables
COMPOSE_FILES="-f docker-compose.yml -f docker-compose.$ENV.yml"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

# Sauvegarde avant déploiement
echo "Sauvegarde des données..."
mkdir -p $BACKUP_DIR
docker compose $COMPOSE_FILES exec -T db pg_dump -U postgres myapp > $BACKUP_DIR/database.sql

# Mise à jour des images
echo "Téléchargement des nouvelles images..."
docker compose $COMPOSE_FILES pull

# Déploiement avec rolling update
echo "Déploiement..."
docker compose $COMPOSE_FILES up -d --remove-orphans

# Vérification de santé
echo "Vérification de la santé des services..."
./scripts/health-check.sh

echo "Déploiement terminé avec succès !"
```

---

## Points clés à retenir

1. **Docker Compose** simplifie drastiquement les déploiements multi-conteneurs
2. **Fichiers YAML** déclaratifs et versionnés
3. **Environnements multiples** avec override et variables
4. **Dépendances et santé** gérées automatiquement
5. **Production** nécessite orchestration plus avancée (Kubernetes, Swarm)
6. **Bonnes pratiques** : sécurité, monitoring, sauvegardes

---

## Commandes essentielles - Aide-mémoire

```bash
# Gestion de base
docker compose up -d                # Démarrer en arrière-plan
docker compose down                 # Arrêter et supprimer
docker compose down -v              # Avec suppression des volumes
docker compose restart service      # Redémarrer un service

# Logs et monitoring
docker compose logs -f              # Suivre les logs
docker compose ps                   # Status des services
docker compose top                  # Processus

# Exécution
docker compose exec service bash    # Shell interactif
docker compose run --rm service cmd # Commande ponctuelle

# Mise à l'échelle
docker compose up -d --scale web=3  # Multiplier les instances

# Environnements
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Nettoyage
docker compose down --rmi all       # Supprimer aussi les images
docker system prune -a              # Nettoyage global Docker
```

---

## Conclusion du module Docker

Félicitations ! Vous maîtrisez maintenant :
- **Concepts fondamentaux** de la conteneurisation
- **Création et gestion** d'images et conteneurs
- **Volumes et réseaux** pour la persistance et communication
- **Docker Compose** pour l'orchestration multi-conteneurs

**Prochaines étapes suggérées :**
- Pratiquer sur vos propres projets
- Explorer Kubernetes pour la production
- Approfondir la sécurité des conteneurs
- Découvrir les outils DevOps (GitLab CI, Jenkins, etc.)