# TP4 - Réseaux Docker et communication inter-conteneurs

## Objectifs
- Comprendre les réseaux Docker
- Maîtriser la communication entre conteneurs
- Configurer des réseaux personnalisés
- Implémenter la découverte de services

## Durée estimée
2h30

---

## Exercice 1 : Types de réseaux Docker

### 1.1 Exploration des réseaux par défaut
```bash
# Lister les réseaux Docker
docker network ls

# Inspecter le réseau bridge par défaut
docker network inspect bridge

# Inspecter le réseau host
docker network inspect host

# Vérifier la configuration réseau de l'hôte
ip addr show docker0 2>/dev/null || echo "Interface docker0 non trouvée"
```

**Questions :**
1. Combien de réseaux sont créés par défaut ?
2. Quelle est la plage IP du réseau bridge ?

### 1.2 Test du réseau bridge par défaut
```bash
# Lancer deux conteneurs sur le réseau par défaut
docker run -d --name container-1 nginx
docker run -d --name container-2 nginx

# Vérifier leurs adresses IP
docker inspect container-1 | grep IPAddress
docker inspect container-2 | grep IPAddress

# Test de connectivité par IP
CONTAINER1_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container-1)
CONTAINER2_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container-2)

echo "Container 1 IP: $CONTAINER1_IP"
echo "Container 2 IP: $CONTAINER2_IP"

# Ping entre conteneurs (par IP)
docker exec container-1 ping -c 3 $CONTAINER2_IP

# Test de résolution DNS (va échouer sur le réseau par défaut)
docker exec container-1 ping -c 3 container-2 || echo "Résolution DNS non disponible sur le réseau bridge par défaut"

# Nettoyer
docker stop container-1 container-2
docker rm container-1 container-2
```

### 1.3 Test du réseau host
```bash
# Lancer un serveur web sur le réseau host
docker run -d --name web-host --network host nginx

# Vérifier qu'il écoute directement sur l'hôte
netstat -tlnp | grep :80 || ss -tlnp | grep :80

# Tester l'accès
curl http://localhost/ | head -5

# Nettoyer
docker stop web-host && docker rm web-host
```

---

## Exercice 2 : Réseaux personnalisés

### 2.1 Création d'un réseau custom
```bash
# Créer un réseau personnalisé
docker network create --driver bridge mon-reseau

# Inspecter le nouveau réseau
docker network inspect mon-reseau

# Lister tous les réseaux
docker network ls
```

### 2.2 Communication avec résolution DNS
```bash
# Lancer des conteneurs sur le réseau personnalisé
docker run -d --name app-frontend --network mon-reseau nginx
docker run -d --name app-backend --network mon-reseau redis

# Tester la résolution DNS automatique
docker exec app-frontend ping -c 3 app-backend
docker exec app-backend ping -c 3 app-frontend

# Vérifier les adresses IP
docker exec app-frontend nslookup app-backend
```

### 2.3 Application multi-tiers
```bash
# Créer une structure d'application complète
mkdir -p ~/docker-tp/app-multi-tiers
cd ~/docker-tp/app-multi-tiers

# Créer un réseau pour l'application
docker network create app-network

# 1. Base de données
docker run -d \
  --name db-server \
  --network app-network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=appdb \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppass \
  mysql:8.0

# 2. Cache Redis
docker run -d \
  --name cache-server \
  --network app-network \
  redis:alpine

# 3. API Backend (Node.js)
cat > app-backend.js << 'EOF'
const express = require('express');
const mysql = require('mysql2/promise');
const redis = require('redis');

const app = express();
app.use(express.json());

// Configuration base de données
const dbConfig = {
  host: 'db-server',
  user: 'appuser',
  password: 'apppass',
  database: 'appdb'
};

// Configuration Redis
const redisClient = redis.createClient({
  socket: {
    host: 'cache-server',
    port: 6379
  }
});
redisClient.connect();

// Route de santé
app.get('/health', async (req, res) => {
  try {
    // Test MySQL
    const connection = await mysql.createConnection(dbConfig);
    await connection.execute('SELECT 1');
    await connection.end();

    // Test Redis
    await redisClient.ping();

    res.json({
      status: 'OK',
      database: 'connected',
      cache: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      status: 'ERROR',
      message: error.message
    });
  }
});

// Route API simple
app.get('/api/info', async (req, res) => {
  try {
    const cacheKey = 'app:info';
    
    // Vérifier le cache
    const cached = await redisClient.get(cacheKey);
    if (cached) {
      return res.json({
        source: 'cache',
        data: JSON.parse(cached)
      });
    }

    // Données depuis la base
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute('SELECT NOW() as current_time, CONNECTION_ID() as connection_id');
    await connection.end();

    const data = {
      message: 'API multi-tiers Docker',
      database_info: rows[0],
      hostname: process.env.HOSTNAME
    };

    // Mise en cache (5 secondes)
    await redisClient.setEx(cacheKey, 5, JSON.stringify(data));

    res.json({
      source: 'database',
      data: data
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, '0.0.0.0', () => {
  console.log('API Backend démarrée sur le port 3000');
});
EOF

# Package.json pour l'API
cat > package.json << 'EOF'
{
  "name": "api-backend",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0",
    "mysql2": "^3.0.0",
    "redis": "^4.0.0"
  }
}
EOF

# Dockerfile pour l'API
cat > Dockerfile << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY app-backend.js .
EXPOSE 3000
CMD ["node", "app-backend.js"]
EOF

# Build et lancement de l'API
docker build -t api-backend .
docker run -d \
  --name api-server \
  --network app-network \
  -p 3000:3000 \
  api-backend

# Attendre le démarrage
sleep 15

# 4. Frontend (nginx avec API proxy)
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream api_backend {
        server api-server:3000;
    }

    server {
        listen 80;
        
        location / {
            root /usr/share/nginx/html;
            try_files $uri /index.html;
        }
        
        location /api/ {
            proxy_pass http://api_backend/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location /health-check {
            proxy_pass http://api_backend/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
EOF

# Page web frontend
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>App Multi-tiers Docker</title>
    <style>
        body { font-family: Arial; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        .status { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .ok { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        button { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; }
        button:hover { background: #0056b3; }
        pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1> Application Multi-tiers avec Docker</h1>
        
        <div>
            <button onclick="checkHealth()">Vérifier la santé</button>
            <button onclick="getApiInfo()">Appeler l'API</button>
            <button onclick="testCache()">Tester le cache</button>
        </div>

        <div id="status"></div>
        <div id="results"></div>
    </div>

    <script>
        async function checkHealth() {
            try {
                const response = await fetch('/health-check');
                const data = await response.json();
                
                document.getElementById('status').innerHTML = `
                    <div class="status ok">
                        [OK] Application en bonne santé<br>
                        Base de données: ${data.database}<br>
                        Cache: ${data.cache}<br>
                        Timestamp: ${data.timestamp}
                    </div>
                `;
            } catch (error) {
                document.getElementById('status').innerHTML = `
                    <div class="status error">[NOK] Erreur: ${error.message}</div>
                `;
            }
        }

        async function getApiInfo() {
            try {
                const response = await fetch('/api/info');
                const data = await response.json();
                
                document.getElementById('results').innerHTML = `
                    <h3>Réponse API (Source: ${data.source})</h3>
                    <pre>${JSON.stringify(data, null, 2)}</pre>
                `;
            } catch (error) {
                document.getElementById('results').innerHTML = `
                    <div class="status error">[NOK] Erreur API: ${error.message}</div>
                `;
            }
        }

        async function testCache() {
            await getApiInfo();
            setTimeout(async () => {
                await getApiInfo();
                console.log('Test cache: appelez l\'API rapidement pour voir la différence cache/database');
            }, 1000);
        }

        // Vérification automatique au chargement
        checkHealth();
    </script>
</body>
</html>
EOF

# Lancement du frontend
docker run -d \
  --name frontend-server \
  --network app-network \
  -p 8080:80 \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/index.html:/usr/share/nginx/html/index.html:ro \
  nginx
```

### 2.4 Test de l'application complète
```bash
# Vérifier que tous les conteneurs sont démarrés
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Tester l'API backend directement
curl http://localhost:3000/health | jq '.' 2>/dev/null || curl http://localhost:3000/health

# Tester via le frontend
curl http://localhost:8080/health-check | jq '.' 2>/dev/null || curl http://localhost:8080/health-check

# Tester l'application web
echo "Ouvrir http://localhost:8080 dans un navigateur"

# Tests de performance cache
echo "=== Test 1 (database) ==="
time curl -s http://localhost:8080/api/info | grep source

echo "=== Test 2 (cache) ==="
time curl -s http://localhost:8080/api/info | grep source
```

---

## Exercice 3 : Isolation réseau

### 3.1 Réseaux isolés
```bash
# Créer deux réseaux isolés
docker network create reseau-dev
docker network create reseau-prod

# Déployer des services sur chaque réseau
docker run -d --name app-dev --network reseau-dev nginx
docker run -d --name app-prod --network reseau-prod nginx

# Tester l'isolation (doit échouer)
docker exec app-dev ping -c 2 app-prod || echo "Isolation confirmée - pas de communication entre réseaux"

# Vérifier les configurations réseau
docker network inspect reseau-dev | grep Subnet
docker network inspect reseau-prod | grep Subnet
```

### 3.2 Conteneur sur plusieurs réseaux
```bash
# Créer un conteneur "passerelle"
docker run -d --name gateway --network reseau-dev alpine sleep 3600

# Connecter le même conteneur au deuxième réseau
docker network connect reseau-prod gateway

# Vérifier les interfaces réseau
docker exec gateway ip addr show

# Tester la connectivité depuis la passerelle
docker exec gateway ping -c 2 app-dev
docker exec gateway ping -c 2 app-prod
```

### 3.3 Réseau avec sous-réseau personnalisé
```bash
# Créer un réseau avec configuration spécifique
docker network create \
  --driver bridge \
  --subnet 172.20.0.0/16 \
  --gateway 172.20.0.1 \
  --ip-range 172.20.240.0/20 \
  reseau-custom

# Lancer un conteneur avec IP fixe
docker run -d \
  --name server-fixe \
  --network reseau-custom \
  --ip 172.20.240.10 \
  nginx

# Vérifier la configuration
docker inspect server-fixe | grep IPAddress
docker exec server-fixe ip route show
```

---

## Exercice 4 : Load balancing et découverte de services

### 4.1 Multiple instances d'un service
```bash
# Créer un réseau pour le load balancing
docker network create lb-network

# Créer plusieurs instances du même service
for i in {1..3}; do
  docker run -d \
    --name web-$i \
    --network lb-network \
    --hostname web-$i \
    nginx
done

# Créer une page custom pour chaque instance
for i in {1..3}; do
  docker exec web-$i sh -c "echo '<h1>Serveur Web $i</h1><p>Hostname: \$(hostname)</p><p>Date: \$(date)</p>' > /usr/share/nginx/html/index.html"
done
```

### 4.2 Load balancer simple avec nginx
```bash
mkdir -p ~/docker-tp/load-balancer
cd ~/docker-tp/load-balancer

# Configuration du load balancer
cat > nginx-lb.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend_servers {
        server web-1:80;
        server web-2:80;
        server web-3:80;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://backend_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location /status {
            stub_status on;
            access_log off;
        }
    }
}
EOF

# Démarrer le load balancer
docker run -d \
  --name load-balancer \
  --network lb-network \
  -p 8080:80 \
  -v $(pwd)/nginx-lb.conf:/etc/nginx/nginx.conf:ro \
  nginx

# Tester la répartition de charge
echo "=== Tests de load balancing ==="
for i in {1..6}; do
  echo "Request $i:"
  curl -s http://localhost:8080/ | grep "Serveur Web"
done
```

### 4.3 Monitoring du trafic
```bash
# Voir les statistiques nginx
curl http://localhost:8080/status

# Logs en temps réel
docker logs -f load-balancer &
LOGS_PID=$!

# Générer du trafic
for i in {1..10}; do
  curl -s http://localhost:8080/ > /dev/null
  sleep 1
done

# Arrêter le suivi des logs
kill $LOGS_PID 2>/dev/null || true
```

---

## Exercice 5 : Réseaux externes et connectivité

### 5.1 Communication avec services externes
```bash
# Tester l'accès Internet depuis un conteneur
docker run --rm alpine ping -c 3 8.8.8.8

# Tester la résolution DNS
docker run --rm alpine nslookup google.com

# Vérifier les règles iptables Docker (sur l'hôte)
sudo iptables -L DOCKER -n 2>/dev/null | head -10 || echo "Nécessite des droits administrateur"
```

### 5.2 Service avec accès restreint
```bash
# Créer un réseau sans accès Internet
docker network create --internal reseau-interne

# Lancer un service sur ce réseau
docker run -d \
  --name app-isolee \
  --network reseau-interne \
  alpine sleep 3600

# Tester l'isolation (doit échouer)
docker exec app-isolee ping -c 2 8.8.8.8 || echo "Accès Internet bloqué (normal)"

# Créer un service de communication interne
docker run -d \
  --name service-interne \
  --network reseau-interne \
  nginx

# Tester la communication interne
docker exec app-isolee ping -c 2 service-interne
```

### 5.3 Proxy pour accès contrôlé
```bash
# Créer un conteneur proxy
docker network connect bridge app-isolee  # Connecter au réseau par défaut

# Configuration squid proxy (exemple)
mkdir -p ~/docker-tp/proxy
cat > ~/docker-tp/proxy/squid.conf << 'EOF'
http_port 3128
acl allowed_sites dstdomain .ubuntu.com .debian.org
http_access allow allowed_sites
http_access deny all
EOF

# Lancer le proxy (exemple conceptuel)
# docker run -d --name proxy --network reseau-interne -v ~/docker-tp/proxy/squid.conf:/etc/squid/squid.conf squid
echo "Proxy configuré (exemple conceptuel)"
```

---

## Exercice 6 : Troubleshooting réseau

### 6.1 Diagnostic réseau
```bash
# Outils de diagnostic dans un conteneur
docker run -it --rm --network lb-network nicolaka/netshoot

# Dans le conteneur netshoot, tester:
# nmap -sn 172.18.0.0/16  # Scanner le réseau
# dig web-1              # Test DNS
# tcpdump -i eth0        # Capture de paquets
# iperf3 -s              # Test de bande passante
# exit
```

### 6.2 Analyse des connexions
```bash
# Voir les connexions réseau actives
docker exec load-balancer netstat -tlnp

# Tracer les connexions
docker exec load-balancer ss -tuln

# Vérifier les routes
docker exec load-balancer ip route show
```

### 6.3 Test de performance réseau
```bash
# Test de latence entre conteneurs
docker exec web-1 ping -c 10 web-2

# Test de débit (nécessite iperf dans les images)
docker run -d --name iperf-server --network lb-network networkstatic/iperf3 -s
docker run --rm --network lb-network networkstatic/iperf3 -c iperf-server -t 10

# Nettoyer
docker stop iperf-server && docker rm iperf-server
```

---

## Exercice 7 : Nettoyage et bonnes pratiques

### 7.1 Audit des réseaux
```bash
# Lister tous les réseaux
docker network ls

# Voir l'utilisation d'espace
docker system df

# Identifier les réseaux non utilisés
docker network ls --filter "dangling=true"

# Voir les conteneurs par réseau
for network in $(docker network ls --format "{{.Name}}"); do
  echo "=== Réseau: $network ==="
  docker network inspect $network --format '{{range .Containers}}{{.Name}} {{end}}' | tr ' ' '\n' | grep -v '^$' || echo "Aucun conteneur"
done
```

### 7.2 Nettoyage complet
```bash
# Arrêter tous les conteneurs créés
docker stop $(docker ps -aq --filter "name=web-" --filter "name=app-" --filter "name=db-server" --filter "name=cache-server" --filter "name=api-server" --filter "name=frontend-server" --filter "name=load-balancer" --filter "name=gateway" --filter "name=server-fixe") 2>/dev/null || echo "Certains conteneurs déjà arrêtés"

# Supprimer les conteneurs
docker rm $(docker ps -aq --filter "name=web-" --filter "name=app-" --filter "name=db-server" --filter "name=cache-server" --filter "name=api-server" --filter "name=frontend-server" --filter "name=load-balancer" --filter "name=gateway" --filter "name=server-fixe") 2>/dev/null || echo "Certains conteneurs déjà supprimés"

# Supprimer les réseaux personnalisés
docker network rm mon-reseau app-network reseau-dev reseau-prod reseau-custom lb-network reseau-interne 2>/dev/null || echo "Certains réseaux déjà supprimés"

# Vérification finale
docker network ls
docker ps -a
```

---

## Questions de synthèse

1. **Réseaux par défaut** : Quelle est la différence entre les réseaux bridge, host et none ?

2. **DNS** : Pourquoi la résolution DNS ne fonctionne-t-elle que sur les réseaux personnalisés ?

3. **Isolation** : Comment sécuriser la communication entre microservices ?

4. **Performance** : Quel est l'impact des réseaux Docker sur les performances ?

5. **Production** : Quelles sont les bonnes pratiques réseau pour un environnement de production ?

---

## Défis bonus

### Défi 1 : Service mesh simple
Créez une architecture de microservices avec un proxy sidecar pour chaque service.

### Défi 2 : Réseau multi-hôte
Simulez un réseau Docker spanning sur plusieurs hôtes avec overlay network.

### Défi 3 : Monitoring réseau
Implémentez un système de monitoring du trafic réseau entre conteneurs.

---

## Solutions

### Solution Exercice 1.1
Par défaut, Docker crée 3 réseaux : bridge (par défaut), host (réseau de l'hôte) et none (pas de réseau).

### Solution Défi 1
```yaml
version: '3.8'
services:
  app:
    image: nginx
    networks:
      - app-network
  
  app-proxy:
    image: envoyproxy/envoy:v1.22-latest
    networks:
      - app-network
    volumes:
      - ./envoy.yaml:/etc/envoy/envoy.yaml

networks:
  app-network:
    driver: bridge
```