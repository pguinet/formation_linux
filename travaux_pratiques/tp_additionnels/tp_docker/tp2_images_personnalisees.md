# TP2 - Création d'images personnalisées avec Dockerfile

## Objectifs
- Comprendre la structure d'un Dockerfile
- Créer vos premières images personnalisées
- Optimiser les images Docker
- Gérer les versions et tags d'images

## Durée estimée
2h30

---

## Exercice 1 : Premier Dockerfile simple

### 1.1 Application Python "Hello World"

Créez l'arborescence suivante :
```bash
mkdir -p ~/docker-tp/app-python
cd ~/docker-tp/app-python
```

#### Créer l'application Python
```bash
cat > app.py << 'EOF'
#!/usr/bin/env python3
import datetime
import os

print("=== Hello from Docker! ===")
print(f"Date/Heure: {datetime.datetime.now()}")
print(f"Hostname: {os.uname().nodename}")
print(f"Python version: {os.sys.version}")
print(f"Utilisateur: {os.environ.get('USER', 'unknown')}")
EOF
```

#### Créer le Dockerfile
```bash
cat > Dockerfile << 'EOF'
FROM python:3.9-alpine

# Métadonnées
LABEL maintainer="votre-nom@email.com"
LABEL description="Application Python simple pour TP Docker"

# Copier l'application
COPY app.py /app/app.py

# Définir le répertoire de travail
WORKDIR /app

# Commande par défaut
CMD ["python", "app.py"]
EOF
```

#### Construire et tester l'image
```bash
# Construire l'image
docker build -t mon-app-python .

# Vérifier que l'image existe
docker images | grep mon-app-python

# Tester l'application
docker run --rm mon-app-python

# Tester avec un nom de conteneur
docker run --rm --name test-python mon-app-python
```

**Questions :**
1. Que signifie le `.` dans `docker build -t mon-app-python .` ?
2. Quelle est la taille de votre image ?
3. Combien de couches (layers) contient-elle ?

---

## Exercice 2 : Application web Node.js

### 2.1 Créer une API REST simple
```bash
mkdir -p ~/docker-tp/app-nodejs
cd ~/docker-tp/app-nodejs
```

#### Fichier package.json
```bash
cat > package.json << 'EOF'
{
  "name": "api-docker-tp",
  "version": "1.0.0",
  "description": "API REST simple pour TP Docker",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "author": "Formation Linux",
  "license": "MIT"
}
EOF
```

#### Application Express
```bash
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

app.use(express.json());

// Route principale
app.get('/', (req, res) => {
    res.json({
        message: 'API Docker TP',
        timestamp: new Date().toISOString(),
        hostname: process.env.HOSTNAME,
        nodeVersion: process.version,
        uptime: process.uptime()
    });
});

// Route santé
app.get('/health', (req, res) => {
    res.json({
        status: 'OK',
        uptime: process.uptime(),
        memory: process.memoryUsage()
    });
});

// Route info système
app.get('/info', (req, res) => {
    res.json({
        platform: process.platform,
        arch: process.arch,
        nodeVersion: process.version,
        environment: process.env.NODE_ENV || 'development',
        pid: process.pid
    });
});

app.listen(port, '0.0.0.0', () => {
    console.log(`API Docker TP démarrée sur http://0.0.0.0:${port}`);
    console.log(`Hostname: ${process.env.HOSTNAME}`);
    console.log(`Node.js version: ${process.version}`);
});
EOF
```

### 2.2 Dockerfile pour Node.js
```bash
cat > Dockerfile << 'EOF'
FROM node:16-alpine

# Métadonnées
LABEL maintainer="votre-nom@email.com"
LABEL description="API REST Node.js pour TP Docker"

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le code source
COPY server.js .

# Changer le propriétaire des fichiers
RUN chown -R appuser:appgroup /app

# Basculer vers l'utilisateur non-root
USER appuser

# Port exposé
EXPOSE 3000

# Commande de démarrage
CMD ["npm", "start"]
EOF
```

### 2.3 Construire et tester
```bash
# Construire l'image
docker build -t api-nodejs .

# Lancer l'API
docker run -d --name mon-api -p 3000:3000 api-nodejs

# Tester les endpoints
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/info

# Voir les logs
docker logs mon-api

# Nettoyer
docker stop mon-api && docker rm mon-api
```

---

## Exercice 3 : Optimisation d'images

### 3.1 Comparer les tailles d'images

Créez deux versions d'une image Python :

#### Version non optimisée
```bash
mkdir -p ~/docker-tp/python-compare/version-lourde
cd ~/docker-tp/python-compare/version-lourde

cat > Dockerfile << 'EOF'
FROM python:3.9

# Installation de packages système
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    vim \
    git \
    build-essential

# Installation des dépendances Python
RUN pip install requests flask numpy pandas matplotlib

# Copier l'application
COPY app.py /app/app.py
WORKDIR /app

CMD ["python", "app.py"]
EOF

cat > app.py << 'EOF'
import requests
import json

print("Application Python avec beaucoup de dépendances")
response = requests.get('https://httpbin.org/json')
print(f"Réponse API: {response.status_code}")
EOF

docker build -t python-lourd .
```

#### Version optimisée
```bash
mkdir -p ~/docker-tp/python-compare/version-legere
cd ~/docker-tp/python-compare/version-legere

cat > requirements.txt << 'EOF'
requests==2.28.0
EOF

cat > Dockerfile << 'EOF'
FROM python:3.9-alpine

# Installation des dépendances système minimales
RUN apk add --no-cache gcc musl-dev

# Créer utilisateur non-root
RUN adduser -D appuser

# Copier et installer les dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier l'application
COPY app.py /app/app.py

# Changer vers utilisateur non-root
USER appuser
WORKDIR /app

CMD ["python", "app.py"]
EOF

cp ../version-lourde/app.py .
docker build -t python-leger .
```

#### Comparer les tailles
```bash
docker images | grep python-
docker history python-lourd
docker history python-leger
```

**Question :** Quelle est la différence de taille entre les deux images ?

---

## Exercice 4 : Build multi-étapes (Multi-stage build)

### 4.1 Application Go compilée
```bash
mkdir -p ~/docker-tp/app-go
cd ~/docker-tp/app-go
```

#### Code source Go
```bash
cat > main.go << 'EOF'
package main

import (
    "encoding/json"
    "fmt"
    "net/http"
    "os"
    "runtime"
    "time"
)

type InfoResponse struct {
    Message   string    `json:"message"`
    Hostname  string    `json:"hostname"`
    GoVersion string    `json:"go_version"`
    OS        string    `json:"os"`
    Arch      string    `json:"arch"`
    Timestamp time.Time `json:"timestamp"`
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
    hostname, _ := os.Hostname()
    
    info := InfoResponse{
        Message:   "API Go dans Docker",
        Hostname:  hostname,
        GoVersion: runtime.Version(),
        OS:        runtime.GOOS,
        Arch:      runtime.GOARCH,
        Timestamp: time.Now(),
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(info)
}

func main() {
    http.HandleFunc("/", infoHandler)
    fmt.Println("Serveur Go démarré sur :8080")
    http.ListenAndServe(":8080", nil)
}
EOF
```

#### Dockerfile multi-étapes
```bash
cat > Dockerfile << 'EOF'
# Étape 1: Build
FROM golang:1.19-alpine AS builder

# Installer git (souvent nécessaire pour les modules Go)
RUN apk add --no-cache git

# Répertoire de travail
WORKDIR /app

# Copier et télécharger les dépendances
COPY go.mod go.sum ./
RUN go mod download

# Copier le code source
COPY main.go .

# Compiler l'application (binaire statique)
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Étape 2: Runtime
FROM alpine:latest

# Installer les certificats CA pour HTTPS
RUN apk --no-cache add ca-certificates

# Créer utilisateur non-root
RUN adduser -D -s /bin/sh appuser

# Répertoire de travail
WORKDIR /root/

# Copier le binaire depuis l'étape de build
COPY --from=builder /app/app .

# Basculer vers utilisateur non-root
USER appuser

# Port exposé
EXPOSE 8080

# Commande de démarrage
CMD ["./app"]
EOF
```

#### Module Go
```bash
cat > go.mod << 'EOF'
module docker-tp-go

go 1.19
EOF

touch go.sum
```

### 4.2 Build et test
```bash
# Construire l'image
docker build -t api-go .

# Comparer avec une version simple
docker build -t api-go-simple -f - . << 'EOF'
FROM golang:1.19-alpine
WORKDIR /app
COPY . .
RUN go build -o app .
CMD ["./app"]
EOF

# Comparer les tailles
docker images | grep api-go

# Tester l'API
docker run -d --name test-go -p 8080:8080 api-go
curl http://localhost:8080/
docker stop test-go && docker rm test-go
```

---

## Exercice 5 : Dockerfile avancé avec arguments

### 5.1 Image configurable
```bash
mkdir -p ~/docker-tp/app-configurable
cd ~/docker-tp/app-configurable
```

#### Application Python configurable
```bash
cat > app.py << 'EOF'
import os
import time
import json

# Configuration depuis les variables d'environnement
app_name = os.environ.get('APP_NAME', 'Application par défaut')
app_version = os.environ.get('APP_VERSION', '1.0.0')
sleep_time = int(os.environ.get('SLEEP_TIME', '5'))
debug_mode = os.environ.get('DEBUG', 'false').lower() == 'true'

def log_info(message):
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] INFO: {message}")

def log_debug(message):
    if debug_mode:
        timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        print(f"[{timestamp}] DEBUG: {message}")

def main():
    log_info(f"Démarrage de {app_name} v{app_version}")
    log_debug(f"Mode debug activé")
    log_debug(f"Temps d'attente configuré: {sleep_time}s")
    
    counter = 0
    while True:
        counter += 1
        info = {
            'app': app_name,
            'version': app_version,
            'counter': counter,
            'hostname': os.uname().nodename,
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
        }
        
        log_info(json.dumps(info, indent=2 if debug_mode else None))
        time.sleep(sleep_time)

if __name__ == "__main__":
    main()
EOF
```

#### Dockerfile avec arguments
```bash
cat > Dockerfile << 'EOF'
FROM python:3.9-alpine

# Arguments de build
ARG APP_VERSION=1.0.0
ARG BUILD_DATE
ARG VCS_REF

# Métadonnées (labels)
LABEL maintainer="formation@example.com"
LABEL org.label-schema.name="App Configurable"
LABEL org.label-schema.description="Application Python configurable pour TP Docker"
LABEL org.label-schema.version=$APP_VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.schema-version="1.0"

# Variables d'environnement par défaut
ENV APP_NAME="Application TP Docker"
ENV APP_VERSION=$APP_VERSION
ENV SLEEP_TIME=10
ENV DEBUG=false

# Créer utilisateur non-root
RUN adduser -D -s /bin/sh appuser

# Copier l'application
COPY app.py /app/app.py

# Permissions
RUN chown -R appuser:appuser /app

# Basculer vers utilisateur non-root
USER appuser
WORKDIR /app

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ps aux | grep -v grep | grep python || exit 1

# Commande par défaut
CMD ["python", "app.py"]
EOF
```

### 5.2 Build avec arguments
```bash
# Build avec arguments personnalisés
docker build \
  --build-arg APP_VERSION=2.1.0 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "no-git") \
  -t app-configurable:2.1.0 .

# Vérifier les métadonnées
docker inspect app-configurable:2.1.0 | grep -A 20 '"Labels"'
```

### 5.3 Tests avec différentes configurations
```bash
# Configuration par défaut
docker run --rm --name test1 app-configurable:2.1.0 &
sleep 15 && docker stop test1

# Configuration personnalisée
docker run --rm --name test2 \
  -e APP_NAME="Mon App Custom" \
  -e SLEEP_TIME=3 \
  -e DEBUG=true \
  app-configurable:2.1.0 &
sleep 15 && docker stop test2
```

---

## Exercice 6 : Gestion des tags et versions

### 6.1 Stratégie de tagging
```bash
cd ~/docker-tp/app-nodejs

# Build avec plusieurs tags
docker build -t api-nodejs:1.0.0 .
docker build -t api-nodejs:1.0 .
docker build -t api-nodejs:latest .

# Tag existant
docker tag api-nodejs:1.0.0 api-nodejs:stable
docker tag api-nodejs:1.0.0 myregistry/api-nodejs:1.0.0

# Lister les images
docker images | grep api-nodejs
```

### 6.2 Simulation de versions
Modifiez `server.js` pour changer la version :
```bash
sed -i 's/"version": "1.0.0"/"version": "1.1.0"/' package.json
sed -i 's/API Docker TP/API Docker TP v1.1/' server.js

# Build nouvelle version
docker build -t api-nodejs:1.1.0 -t api-nodejs:latest .

# Tester les deux versions
docker run -d --name api-v1 -p 3001:3000 api-nodejs:1.0.0
docker run -d --name api-v11 -p 3002:3000 api-nodejs:1.1.0

curl http://localhost:3001/
curl http://localhost:3002/

# Nettoyer
docker stop api-v1 api-v11
docker rm api-v1 api-v11
```

---

## Exercice 7 : Debugging et inspection

### 7.1 Analyser une image
```bash
# Historique des couches
docker history api-nodejs:latest

# Inspection détaillée
docker inspect api-nodejs:latest

# Analyse de la taille par couche
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

# Export et analyse du filesystem
docker save api-nodejs:latest | tar -tv
```

### 7.2 Debug d'un build qui échoue
Créez intentionnellement une erreur :
```bash
mkdir -p ~/docker-tp/debug-build
cd ~/docker-tp/debug-build

cat > Dockerfile << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
CMD ["npm", "start"]
EOF

# Build sans package.json (va échouer)
docker build -t debug-app .

# Correction
echo '{"name": "debug-app", "version": "1.0.0"}' > package.json
echo 'console.log("Debug réussi!");' > index.js

# Modifier package.json pour pointer vers index.js
cat > package.json << 'EOF'
{
  "name": "debug-app",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  }
}
EOF

# Build réussi
docker build -t debug-app .
docker run --rm debug-app
```

---

## Questions de synthèse

1. **Dockerfile** : Expliquez la différence entre `COPY` et `ADD`.

2. **Optimisation** : Quelles sont les techniques pour réduire la taille des images Docker ?

3. **Sécurité** : Pourquoi est-il important de ne pas exécuter les conteneurs en tant que root ?

4. **Multi-stage** : Dans quels cas utiliser un build multi-étapes ?

5. **Cache** : Comment Docker utilise-t-il le cache lors du build d'images ?

---

## Défis bonus

### Défi 1 : Image polyglotte
Créez une image qui peut exécuter du Python, Node.js et Go selon un paramètre d'entrée.

### Défi 2 : Image avec SSL/TLS
Créez une image nginx avec des certificats SSL auto-signés.

### Défi 3 : Pipeline de build
Créez un script bash qui build, test et tag automatiquement vos images.

---

## Solutions

### Solution Exercice 1.1
Le `.` indique le contexte de build (répertoire courant). Docker envoie tous les fichiers de ce répertoire au daemon Docker pour le build.

### Solution Défi 1
```bash
cat > Dockerfile << 'EOF'
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y python3 nodejs golang
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
EOF

cat > entrypoint.sh << 'EOF'
#!/bin/bash
case "$1" in
  python) exec python3 "${@:2}" ;;
  node) exec node "${@:2}" ;;
  go) exec go "${@:2}" ;;
  *) echo "Usage: $0 {python|node|go} [args]" ;;
esac
EOF
```