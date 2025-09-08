# Module Docker - Chapitre 2 : Images et conteneurs

## Objectifs du chapitre
À l'issue de ce chapitre, vous serez capable de :
- Comprendre la structure en couches des images Docker
- Créer des images personnalisées avec Dockerfile
- Gérer efficacement les conteneurs (démarrage, arrêt, logs)
- Utiliser les registres d'images (Docker Hub, registres privés)
- Optimiser les images pour la production
- Appliquer les bonnes pratiques de création d'images

---

## 1. Anatomie des images Docker

### Structure en couches (layers)

Les images Docker sont constituées de **couches empilées** :

```
Image finale
+------------------------+  <- Couche 4: COPY app.py /app/
| Application Python     |
+------------------------+  <- Couche 3: RUN pip install flask
| Dépendances Python     |
+------------------------+  <- Couche 2: RUN apt-get install python3
| Python installé        |
+------------------------+  <- Couche 1: FROM ubuntu:20.04
| Ubuntu base            |
+------------------------+  <- Couche 0: Système de base
```

### Avantages du système de couches

**Réutilisation :**
- Couches partagées entre images
- Téléchargement optimisé (seulement les nouvelles couches)
- Stockage efficace sur le disque

**Mise en cache :**
- Reconstruction rapide si les couches n'ont pas changé
- Optimisation des builds Docker

**Exemple concret :**
```bash
# Première image
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y python3

# Deuxième image réutilise les mêmes couches
FROM ubuntu:20.04  # <- Réutilisée
RUN apt-get update && apt-get install -y python3  # <- Réutilisée
RUN pip install flask  # <- Nouvelle couche
```

---

## 2. Dockerfile : créer ses propres images

### Structure d'un Dockerfile

Un **Dockerfile** est un script qui décrit comment construire une image :

```dockerfile
# Commentaire : image de base
FROM python:3.9-alpine

# Métadonnées
LABEL maintainer="votre.email@exemple.com"
LABEL version="1.0"

# Variables d'environnement
ENV PYTHONPATH=/app
ENV FLASK_ENV=production

# Répertoire de travail
WORKDIR /app

# Copie de fichiers
COPY requirements.txt .
COPY src/ ./src/

# Installation des dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Port exposé
EXPOSE 5000

# Utilisateur non-root pour la sécurité
RUN adduser -D -s /bin/sh appuser
USER appuser

# Commande par défaut
CMD ["python", "src/app.py"]
```

### Instructions Dockerfile essentielles

#### FROM - Image de base
```dockerfile
FROM ubuntu:20.04                    # Image officielle
FROM python:3.9-alpine              # Image légère Alpine
FROM scratch                        # Image vide (pour binaires)
```

#### WORKDIR - Répertoire de travail
```dockerfile
WORKDIR /app                        # Change le répertoire courant
# Équivaut à : RUN cd /app
```

#### COPY et ADD - Copier des fichiers
```dockerfile
COPY src/ /app/                     # Copie simple (recommandée)
COPY requirements.txt .             # . = WORKDIR actuel

ADD archive.tar.gz /app/            # Extraction automatique
ADD https://example.com/file.txt /app/  # Téléchargement (non recommandé)
```

#### RUN - Exécuter des commandes
```dockerfile
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*  # Nettoyage dans la même couche
```

#### ENV - Variables d'environnement
```dockerfile
ENV NODE_ENV=production
ENV PORT=3000
ENV DATABASE_URL=postgresql://localhost/myapp
```

#### EXPOSE - Documenter les ports
```dockerfile
EXPOSE 80                          # Port HTTP
EXPOSE 443                         # Port HTTPS
EXPOSE 5432                        # PostgreSQL
```

**Note :** EXPOSE ne publie pas le port, c'est seulement documentation.

#### USER - Utilisateur d'exécution
```dockerfile
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs                        # Sécurité : pas root
```

#### CMD vs ENTRYPOINT
```dockerfile
# CMD : commande par défaut (surchargeables)
CMD ["python", "app.py"]
CMD python app.py                   # Format shell (non recommandé)

# ENTRYPOINT : point d'entrée fixe
ENTRYPOINT ["python", "app.py"]

# Combinaison : ENTRYPOINT + CMD
ENTRYPOINT ["python"]
CMD ["app.py"]
# Permet : docker run image script.py
```

---

## 3. Construire des images

### Commande docker build

**Syntaxe de base :**
```bash
docker build -t nom-image:tag chemin/vers/context
```

**Exemple complet :**
```bash
# Dans le dossier contenant le Dockerfile
docker build -t mon-app:1.0 .

# Spécifier un Dockerfile différent
docker build -t mon-app:1.0 -f Dockerfile.prod .

# Build avec des arguments
docker build --build-arg VERSION=1.2.3 -t mon-app:1.0 .

# Build sans cache
docker build --no-cache -t mon-app:1.0 .
```

### Contexte de build

Le **contexte** est l'ensemble des fichiers envoyés au daemon Docker :

```
projet/
+-- Dockerfile
+-- src/
|   +-- app.py
|   +-- utils.py
+-- tests/            # <- Exclu avec .dockerignore
+-- .dockerignore
+-- requirements.txt
```

### Fichier .dockerignore

Exclure des fichiers du contexte de build :

```dockerignore
# Version control
.git
.gitignore

# Build artifacts
node_modules/
dist/
build/

# Development files
.vscode/
*.log
*.tmp

# Documentation
README.md
docs/

# Tests (si pas nécessaires)
tests/
*.test.js
```

### Build multi-étapes

Optimiser la taille des images finales :

```dockerfile
# Étape 1: Build
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Étape 2: Runtime
FROM node:16-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/
EXPOSE 3000
CMD ["node", "src/app.js"]
```

**Avantages :**
- Image finale plus petite (pas d'outils de build)
- Sécurité renforcée (moins de surface d'attaque)
- Builds plus rapides (cache des étapes)

---

## 4. Gestion avancée des conteneurs

### Options de lancement détaillées

#### Gestion des ressources
```bash
# Limiter la mémoire
docker run -m 512m nginx

# Limiter le CPU
docker run --cpus="1.5" nginx

# Limiter les CPUs utilisés
docker run --cpuset-cpus="0,1" nginx

# Priorité CPU
docker run --cpu-shares=1024 nginx
```

#### Variables d'environnement
```bash
# Variable simple
docker run -e NODE_ENV=production mon-app

# Fichier d'environnement
docker run --env-file .env mon-app

# Exemple de .env :
# NODE_ENV=production
# DATABASE_URL=postgresql://localhost/myapp
# API_KEY=secret123
```

#### Mapping de ports
```bash
# Port spécifique
docker run -p 8080:80 nginx           # Hôte:8080 -> Conteneur:80

# Port aléatoire
docker run -P nginx                   # Ports automatiques

# IP spécifique
docker run -p 127.0.0.1:8080:80 nginx

# Protocole spécifique
docker run -p 53:53/udp dns-server
```

#### Volumes et montages
```bash
# Volume nommé
docker run -v data-vol:/data postgres

# Bind mount (dossier hôte)
docker run -v /host/path:/container/path nginx

# Montage en lecture seule
docker run -v /host/path:/container/path:ro nginx

# Volume temporaire en mémoire
docker run --tmpfs /tmp:rw,noexec,nosuid,size=100m nginx
```

### Inspection et debugging

#### Logs des conteneurs
```bash
# Voir tous les logs
docker logs conteneur

# Suivre les logs en temps réel
docker logs -f conteneur

# Dernières lignes
docker logs --tail 100 conteneur

# Avec timestamps
docker logs -t conteneur

# Depuis une date
docker logs --since "2023-12-01T10:00:00" conteneur
```

#### Inspection détaillée
```bash
# Configuration complète
docker inspect conteneur

# Filtrer les informations
docker inspect --format='{{.State.Status}}' conteneur
docker inspect --format='{{.NetworkSettings.IPAddress}}' conteneur

# Statistiques en temps réel
docker stats conteneur

# Processus dans le conteneur
docker top conteneur
```

#### Accès au conteneur
```bash
# Shell interactif
docker exec -it conteneur bash
docker exec -it conteneur sh        # Si bash absent

# Commande ponctuelle
docker exec conteneur ls -la /app

# En tant qu'autre utilisateur
docker exec -u root -it conteneur bash

# Variables d'environnement
docker exec -e VAR=value conteneur env
```

---

## 5. Registres d'images

### Docker Hub

**Recherche d'images :**
```bash
# Rechercher des images
docker search postgresql
docker search --filter stars=3 --limit 10 nginx

# Voir les tags disponibles (via web ou API)
curl -s "https://registry.hub.docker.com/v2/repositories/nginx/tags/" | jq '.results[].name'
```

**Publication d'images :**
```bash
# Se connecter
docker login

# Tagger l'image
docker tag mon-app:1.0 username/mon-app:1.0
docker tag mon-app:1.0 username/mon-app:latest

# Pousser l'image
docker push username/mon-app:1.0
docker push username/mon-app:latest
```

### Registres privés

#### Registry Docker local
```bash
# Démarrer un registre local
docker run -d -p 5000:5000 --name registry registry:2

# Pousser vers le registre local
docker tag mon-app:1.0 localhost:5000/mon-app:1.0
docker push localhost:5000/mon-app:1.0

# Tirer depuis le registre local
docker pull localhost:5000/mon-app:1.0
```

#### Configuration de registres sécurisés
```bash
# Fichier /etc/docker/daemon.json
{
  "insecure-registries": ["myregistry.local:5000"],
  "registry-mirrors": ["https://mirror.gcr.io"]
}

# Redémarrer Docker après modification
sudo systemctl restart docker
```

---

## 6. Optimisation des images

### Choix de l'image de base

**Images recommandées par taille :**
```bash
# Standard (Ubuntu/Debian)
FROM ubuntu:20.04              # ~70MB
FROM debian:bullseye-slim      # ~25MB

# Alpine (très légère)
FROM alpine:3.15               # ~5MB
FROM python:3.9-alpine         # ~45MB vs python:3.9 (~900MB)

# Distroless (Google)
FROM gcr.io/distroless/python3 # ~20MB, très sécurisée

# Scratch (vide)
FROM scratch                   # 0MB, pour binaires statiques
```

### Techniques d'optimisation

#### Multi-stage builds optimisé
```dockerfile
# Build stage
FROM node:16 AS builder
WORKDIR /build
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Production stage
FROM node:16-alpine
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /build/node_modules ./node_modules
COPY --chown=nodejs:nodejs src/ ./src/
USER nodejs
EXPOSE 3000
CMD ["node", "src/app.js"]
```

#### Optimisation des couches
```dockerfile
# Mauvais : plusieurs couches RUN
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get clean

# Bon : une seule couche optimisée
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*
```

#### Ordre des instructions
```dockerfile
# Bon ordre : instructions qui changent peu en premier
FROM python:3.9-alpine

# Dépendances (changent rarement) avant code (change souvent)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Code applicatif en dernier
COPY src/ ./src/
```

### Analyse de la taille
```bash
# Voir les couches d'une image
docker history mon-app:1.0

# Taille détaillée
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Outils d'analyse
docker run --rm -it wagoodman/dive:latest mon-app:1.0
```

---

## 7. Sécurité des images et conteneurs

### Scan de vulnérabilités
```bash
# Docker Desktop intégré
docker scan mon-app:1.0

# Trivy (outil externe)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image mon-app:1.0

# Snyk
docker run --rm -it \
  -v $(pwd):/project \
  snyk/snyk-docker test mon-app:1.0
```

### Bonnes pratiques de sécurité

#### Images sécurisées
```dockerfile
# Utiliser des images officielles et récentes
FROM node:16-alpine

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Changer de propriétaire si nécessaire
COPY --chown=nodejs:nodejs . .

# Utiliser l'utilisateur non-root
USER nodejs

# Supprimer les packages non nécessaires
RUN apk del .build-deps
```

#### Runtime sécurisé
```bash
# Limiter les capabilities
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE mon-app

# Mode lecture seule
docker run --read-only mon-app

# Pas de privilèges
docker run --security-opt=no-new-privileges mon-app

# Apparmor/SELinux
docker run --security-opt apparmor=docker-profile mon-app
```

---

## 8. Bonnes pratiques de production

### Dockerfile optimisé pour production

```dockerfile
FROM python:3.9-alpine AS base

# Métadonnées
LABEL maintainer="team@exemple.com" \
      version="1.0.0" \
      description="Application de production"

# Variables d'environnement
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Dépendances système
RUN apk add --no-cache \
    postgresql-libs \
    && apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    postgresql-dev

WORKDIR /app

# Dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

# Utilisateur non-root
RUN adduser -D -s /bin/sh appuser
COPY --chown=appuser:appuser . .
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
```

### Gestion des tags et versions

```bash
# Versioning sémantique
docker build -t mon-app:1.2.3 .
docker build -t mon-app:1.2 .
docker build -t mon-app:1 .
docker build -t mon-app:latest .

# Tags par environnement
docker build -t mon-app:dev .
docker build -t mon-app:staging .
docker build -t mon-app:prod .

# Tags avec hash de commit
docker build -t mon-app:$(git rev-parse --short HEAD) .
```

### Monitoring et observabilité

```bash
# Labels pour le monitoring
docker run -l "service=web" \
           -l "environment=production" \
           -l "team=backend" \
           mon-app

# Logs structurés
docker run --log-driver=json-file \
           --log-opt max-size=10m \
           --log-opt max-file=3 \
           mon-app
```

---

## Points clés à retenir

1. **Images en couches** optimisent stockage et construction
2. **Dockerfile** définit la construction d'images reproductibles
3. **Multi-stage builds** réduisent la taille finale
4. **Sécurité** : utilisateurs non-root, scan de vulnérabilités
5. **Optimisation** : ordre des instructions, nettoyage des couches
6. **Production** : health checks, logs, monitoring

---

## Commandes essentielles - Aide-mémoire

```bash
# Construction d'images
docker build -t nom:tag .
docker build --no-cache -t nom:tag .

# Gestion d'images
docker images
docker rmi image
docker tag source target
docker push nom:tag
docker pull nom:tag

# Conteneurs avancés
docker run -d -p 8080:80 --name web nginx
docker run -v data:/data -e ENV=prod app
docker exec -it conteneur bash
docker logs -f conteneur
docker inspect conteneur

# Nettoyage
docker system prune              # Nettoyer les éléments non utilisés
docker container prune          # Nettoyer les conteneurs arrêtés
docker image prune              # Nettoyer les images non utilisées
```

---

## Prochaine étape

Au chapitre suivant, nous explorerons les **volumes et réseaux** pour la persistance des données et la communication entre conteneurs.