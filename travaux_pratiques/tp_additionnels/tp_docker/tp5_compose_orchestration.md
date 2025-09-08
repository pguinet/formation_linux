# TP5 - Docker Compose et orchestration d'applications

## Objectifs
- Maîtriser Docker Compose pour orchestrer des applications multi-conteneurs
- Comprendre la gestion des environnements (dev/test/prod)
- Implémenter des stratégies de déploiement
- Gérer les dépendances entre services

## Durée estimée
3 heures

---

## Exercice 1 : Premier docker-compose.yml

### 1.1 Application LAMP basique
```bash
# Créer la structure de projet
mkdir -p ~/docker-tp/wordpress-stack
cd ~/docker-tp/wordpress-stack
```

#### Fichier docker-compose.yml de base
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  database:
    image: mysql:8.0
    container_name: wordpress-db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppassword
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - wordpress-network

  wordpress:
    image: wordpress:latest
    container_name: wordpress-app
    restart: unless-stopped
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: database:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppassword
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wp_data:/var/www/html
    depends_on:
      - database
    networks:
      - wordpress-network

  phpmyadmin:
    image: phpmyadmin:latest
    container_name: wordpress-phpmyadmin
    restart: unless-stopped
    ports:
      - "8081:80"
    environment:
      PMA_HOST: database
      PMA_PORT: 3306
    depends_on:
      - database
    networks:
      - wordpress-network

volumes:
  db_data:
  wp_data:

networks:
  wordpress-network:
    driver: bridge
EOF
```

### 1.2 Déploiement et test
```bash
# Lancer la stack
docker-compose up -d

# Vérifier le statut
docker-compose ps

# Voir les logs
docker-compose logs --tail 10

# Tester WordPress
echo "WordPress: http://localhost:8080"
echo "phpMyAdmin: http://localhost:8081"

# Attendre le démarrage complet
sleep 30
curl -I http://localhost:8080

# Vérifier les volumes
docker volume ls | grep wordpress-stack
```

### 1.3 Gestion du cycle de vie
```bash
# Arrêter les services
docker-compose stop

# Redémarrer
docker-compose start

# Voir l'état détaillé
docker-compose ps -a

# Logs d'un service spécifique
docker-compose logs database

# Logs en temps réel
docker-compose logs -f wordpress &
LOGS_PID=$!
sleep 5
kill $LOGS_PID 2>/dev/null || true
```

---

## Exercice 2 : Application Node.js avec base de données

### 2.1 Créer une API REST complète
```bash
mkdir -p ~/docker-tp/nodejs-api
cd ~/docker-tp/nodejs-api
```

#### Code de l'application
```bash
# Package.json
cat > package.json << 'EOF'
{
  "name": "nodejs-api-docker",
  "version": "1.0.0",
  "description": "API REST avec Docker Compose",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "mysql2": "^3.0.0",
    "redis": "^4.0.0",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "nodemon": "^2.0.0"
  }
}
EOF

# Application principale
cat > server.js << 'EOF'
const express = require('express');
const mysql = require('mysql2/promise');
const redis = require('redis');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());

// Configuration base de données
const dbConfig = {
  host: process.env.DB_HOST || 'database',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'apiuser',
  password: process.env.DB_PASSWORD || 'apipass',
  database: process.env.DB_NAME || 'apidb'
};

// Configuration Redis
const redisClient = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST || 'cache',
    port: process.env.REDIS_PORT || 6379
  }
});

// Connexion Redis
redisClient.on('error', (err) => console.error('Redis Client Error', err));
redisClient.connect();

// Initialisation de la base de données
async function initDatabase() {
  try {
    const connection = await mysql.createConnection(dbConfig);
    
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await connection.execute(`
      CREATE TABLE IF NOT EXISTS posts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(200) NOT NULL,
        content TEXT,
        user_id INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    `);

    // Données de test
    await connection.execute(`
      INSERT IGNORE INTO users (id, name, email) VALUES
      (1, 'John Doe', 'john@example.com'),
      (2, 'Jane Smith', 'jane@example.com'),
      (3, 'Bob Johnson', 'bob@example.com')
    `);

    await connection.execute(`
      INSERT IGNORE INTO posts (id, title, content, user_id) VALUES
      (1, 'Premier article', 'Contenu du premier article de blog', 1),
      (2, 'Docker et Node.js', 'Guide sur Docker avec Node.js', 2),
      (3, 'API REST', 'Comment créer une API REST moderne', 1)
    `);

    await connection.end();
    console.log('[OK] Base de données initialisée');
  } catch (error) {
    console.error('[NOK] Erreur d\'initialisation de la base:', error.message);
    setTimeout(initDatabase, 5000); // Retry après 5s
  }
}

// Routes API

// Health check
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
      services: {
        database: 'connected',
        cache: 'connected'
      },
      timestamp: new Date().toISOString(),
      hostname: process.env.HOSTNAME
    });
  } catch (error) {
    res.status(503).json({
      status: 'ERROR',
      error: error.message
    });
  }
});

// Users CRUD
app.get('/api/users', async (req, res) => {
  try {
    const cacheKey = 'users:all';
    
    // Vérifier le cache
    const cached = await redisClient.get(cacheKey);
    if (cached) {
      return res.json({
        source: 'cache',
        data: JSON.parse(cached)
      });
    }

    // Récupérer depuis la base
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute('SELECT * FROM users ORDER BY id');
    await connection.end();

    // Mettre en cache (30 secondes)
    await redisClient.setEx(cacheKey, 30, JSON.stringify(rows));

    res.json({
      source: 'database',
      data: rows
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/users', async (req, res) => {
  try {
    const { name, email } = req.body;
    
    const connection = await mysql.createConnection(dbConfig);
    const [result] = await connection.execute(
      'INSERT INTO users (name, email) VALUES (?, ?)',
      [name, email]
    );
    await connection.end();

    // Invalider le cache
    await redisClient.del('users:all');

    res.status(201).json({
      id: result.insertId,
      name,
      email,
      message: 'Utilisateur créé avec succès'
    });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'Email déjà utilisé' });
    }
    res.status(500).json({ error: error.message });
  }
});

// Posts avec relations
app.get('/api/posts', async (req, res) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute(`
      SELECT p.*, u.name as author_name, u.email as author_email
      FROM posts p
      JOIN users u ON p.user_id = u.id
      ORDER BY p.created_at DESC
    `);
    await connection.end();

    res.json({ data: rows });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/posts', async (req, res) => {
  try {
    const { title, content, user_id } = req.body;
    
    const connection = await mysql.createConnection(dbConfig);
    const [result] = await connection.execute(
      'INSERT INTO posts (title, content, user_id) VALUES (?, ?, ?)',
      [title, content, user_id]
    );
    await connection.end();

    res.status(201).json({
      id: result.insertId,
      title,
      content,
      user_id,
      message: 'Article créé avec succès'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Statistiques avec cache
app.get('/api/stats', async (req, res) => {
  try {
    const cacheKey = 'stats:general';
    
    const cached = await redisClient.get(cacheKey);
    if (cached) {
      return res.json({
        source: 'cache',
        ...JSON.parse(cached)
      });
    }

    const connection = await mysql.createConnection(dbConfig);
    
    const [usersCount] = await connection.execute('SELECT COUNT(*) as count FROM users');
    const [postsCount] = await connection.execute('SELECT COUNT(*) as count FROM posts');
    const [latestPosts] = await connection.execute(`
      SELECT title, created_at FROM posts 
      ORDER BY created_at DESC LIMIT 3
    `);
    
    await connection.end();

    const stats = {
      users: usersCount[0].count,
      posts: postsCount[0].count,
      latest_posts: latestPosts,
      generated_at: new Date().toISOString()
    };

    await redisClient.setEx(cacheKey, 60, JSON.stringify(stats));

    res.json({
      source: 'database',
      ...stats
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', async () => {
  console.log(`[START] API démarrée sur le port ${PORT}`);
  console.log(` Health check: http://localhost:${PORT}/health`);
  
  // Initialiser la base de données
  await initDatabase();
});

// Gestion propre de l'arrêt
process.on('SIGTERM', async () => {
  console.log(' Arrêt en cours...');
  await redisClient.quit();
  process.exit(0);
});
EOF
```

#### Docker Compose pour l'API
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: nodejs-api
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: development
      DB_HOST: database
      DB_USER: apiuser
      DB_PASSWORD: apipass
      DB_NAME: apidb
      REDIS_HOST: cache
    volumes:
      - ./:/app
      - /app/node_modules  # Volume anonyme pour node_modules
    depends_on:
      database:
        condition: service_healthy
      cache:
        condition: service_started
    networks:
      - api-network
    command: npm run dev

  database:
    image: mysql:8.0
    container_name: mysql-api
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: rootpass123
      MYSQL_DATABASE: apidb
      MYSQL_USER: apiuser
      MYSQL_PASSWORD: apipass
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init-db:/docker-entrypoint-initdb.d
    ports:
      - "3306:3306"
    networks:
      - api-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 10s
      retries: 5
      interval: 10s
      start_period: 30s

  cache:
    image: redis:7-alpine
    container_name: redis-api
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - api-network
    command: redis-server --appendonly yes

  adminer:
    image: adminer:latest
    container_name: adminer-api
    restart: unless-stopped
    ports:
      - "8080:8080"
    depends_on:
      - database
    networks:
      - api-network

volumes:
  mysql_data:
  redis_data:

networks:
  api-network:
    driver: bridge
EOF
```

#### Dockerfile pour l'API
```bash
cat > Dockerfile << 'EOF'
FROM node:16-alpine

# Installer nodemon globalement pour le développement
RUN npm install -g nodemon

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances
RUN npm ci

# Copier le code source
COPY . .

# Changer le propriétaire
RUN chown -R nodejs:nodejs /app

# Basculer vers l'utilisateur non-root
USER nodejs

# Port exposé
EXPOSE 3000

# Commande par défaut
CMD ["npm", "start"]
EOF
```

### 2.2 Test de l'API complète
```bash
# Créer un dossier pour les scripts d'init MySQL (optionnel)
mkdir -p init-db

# Démarrer la stack
docker-compose up -d

# Attendre le démarrage
echo "[WAIT] Démarrage des services..."
sleep 30

# Vérifier le statut
docker-compose ps

# Tester l'API
echo "=== Health Check ==="
curl http://localhost:3000/health | jq '.' 2>/dev/null || curl http://localhost:3000/health

echo -e "\n=== Utilisateurs ==="
curl http://localhost:3000/api/users | jq '.' 2>/dev/null || curl http://localhost:3000/api/users

echo -e "\n=== Articles ==="
curl http://localhost:3000/api/posts | jq '.' 2>/dev/null || curl http://localhost:3000/api/posts

echo -e "\n=== Statistiques ==="
curl http://localhost:3000/api/stats | jq '.' 2>/dev/null || curl http://localhost:3000/api/stats

# Test de création d'utilisateur
echo -e "\n=== Création d'utilisateur ==="
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice Dupont", "email": "alice@example.com"}' | jq '.' 2>/dev/null || curl -X POST http://localhost:3000/api/users -H "Content-Type: application/json" -d '{"name": "Alice Dupont", "email": "alice@example.com"}'

echo -e "\n\nAccès Adminer: http://localhost:8080"
echo "Serveur: database | Utilisateur: apiuser | Mot de passe: apipass"
```

---

## Exercice 3 : Environments multiples

### 3.1 Configuration par environnement
```bash
mkdir -p ~/docker-tp/multi-env
cd ~/docker-tp/multi-env
```

#### Fichier de base
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    environment:
      - NGINX_ENVSUBST_TEMPLATE_DIR=/etc/nginx/templates
      - NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx/conf.d
      - SERVER_NAME=${SERVER_NAME:-localhost}
    networks:
      - app-network

  app:
    build: .
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - LOG_LEVEL=${LOG_LEVEL:-info}
      - API_KEY=${API_KEY}
    volumes:
      - ${APP_VOLUME_TYPE:-./src:/app/src}
    networks:
      - app-network

networks:
  app-network:
EOF
```

#### Fichiers d'environnement
```bash
# Environnement de développement
cat > .env.dev << 'EOF'
NODE_ENV=development
WEB_PORT=3000
LOG_LEVEL=debug
SERVER_NAME=localhost
API_KEY=dev-api-key-123
APP_VOLUME_TYPE=./src:/app/src
EOF

# Environnement de test
cat > .env.test << 'EOF'
NODE_ENV=test
WEB_PORT=3001
LOG_LEVEL=warn
SERVER_NAME=test.localhost
API_KEY=test-api-key-456
APP_VOLUME_TYPE=app_code:/app/src
EOF

# Environnement de production
cat > .env.prod << 'EOF'
NODE_ENV=production
WEB_PORT=80
LOG_LEVEL=error
SERVER_NAME=myapp.com
API_KEY=prod-api-key-789
APP_VOLUME_TYPE=app_code:/app/src
EOF
```

#### Application simple pour tester
```bash
mkdir -p src html

# Application Node.js simple
cat > src/app.js << 'EOF'
const http = require('http');
const os = require('os');

const config = {
  env: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 8080,
  logLevel: process.env.LOG_LEVEL || 'info',
  apiKey: process.env.API_KEY || 'no-key'
};

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: `Application en mode ${config.env}`,
    hostname: os.hostname(),
    config: config,
    timestamp: new Date().toISOString()
  }, null, 2));
});

server.listen(config.port, '0.0.0.0', () => {
  console.log(`[${config.env}] Serveur démarré sur le port ${config.port}`);
  console.log(`Log level: ${config.logLevel}`);
});
EOF

# Page HTML statique
cat > html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Multi-Environment App</title>
    <style>
        body { font-family: Arial; margin: 40px; }
        .env-dev { background: #d1ecf1; color: #0c5460; }
        .env-test { background: #fff3cd; color: #856404; }
        .env-prod { background: #d4edda; color: #155724; }
    </style>
</head>
<body class="env-${NODE_ENV}">
    <h1>Application Multi-Environnements</h1>
    <p>Serveur: ${SERVER_NAME}</p>
    <p>Port: ${WEB_PORT}</p>
    <div>
        <a href="/api">Tester l'API</a>
    </div>
</body>
</html>
EOF

# Dockerfile
cat > Dockerfile << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY src/ ./src/
EXPOSE 8080
CMD ["node", "src/app.js"]
EOF
```

### 3.2 Déploiement multi-environnements
```bash
# Fonction helper
deploy_env() {
  local env=$1
  echo "=== Déploiement en environnement: $env ==="
  
  # Copier le fichier d'environnement
  cp .env.$env .env
  
  # Déployer avec compose
  docker-compose --env-file .env.$env up -d
  
  # Attendre et tester
  sleep 5
  
  local port=$(grep WEB_PORT .env.$env | cut -d'=' -f2)
  echo "Test sur le port $port:"
  curl -s http://localhost:$port/api 2>/dev/null | head -5 || echo "Service non accessible"
  
  # Arrêter
  docker-compose --env-file .env.$env down
  echo ""
}

# Test des trois environnements
deploy_env dev
deploy_env test
deploy_env prod
```

### 3.3 Override files
```bash
# Fichier de base commun
cat > docker-compose.base.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:alpine
    networks:
      - app-network

  app:
    build: .
    networks:
      - app-network

networks:
  app-network:
EOF

# Override pour développement
cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  web:
    ports:
      - "3000:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro

  app:
    environment:
      - NODE_ENV=development
      - LOG_LEVEL=debug
    volumes:
      - ./src:/app/src
    ports:
      - "8080:8080"
EOF

# Override pour production
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  web:
    ports:
      - "80:80"
    restart: always
    
  app:
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=error
    restart: always
EOF

# Test avec les overrides
echo "=== Test avec fichiers override ==="
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml up -d
sleep 5
curl -s http://localhost:8080/api | head -3
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml down
```

---

## Exercice 4 : Scaling et load balancing

### 4.1 Application scalable
```bash
mkdir -p ~/docker-tp/scaling-demo
cd ~/docker-tp/scaling-demo
```

#### Application avec support de scaling
```bash
cat > app.js << 'EOF'
const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;
const HOSTNAME = os.hostname();

let requestCount = 0;

app.get('/', (req, res) => {
  requestCount++;
  res.json({
    message: 'Hello from scaled app!',
    hostname: HOSTNAME,
    pid: process.pid,
    requestCount: requestCount,
    timestamp: new Date().toISOString(),
    env: process.env.NODE_ENV || 'development'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'OK', hostname: HOSTNAME });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`[START] Serveur ${HOSTNAME} démarré sur le port ${PORT}`);
});
EOF

# Package.json
cat > package.json << 'EOF'
{
  "name": "scaling-demo",
  "version": "1.0.0",
  "main": "app.js",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Dockerfile
cat > Dockerfile << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY app.js .
EXPOSE 3000
CMD ["node", "app.js"]
EOF
```

#### Docker Compose avec scaling
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  app:
    build: .
    environment:
      - NODE_ENV=production
    networks:
      - app-network
    deploy:
      replicas: 3
      
  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOF
```

#### Configuration nginx pour load balancing
```bash
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream app_servers {
        server app_1:3000;
        server app_2:3000;
        server app_3:3000;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://app_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            
            # Headers pour identifier le backend
            add_header X-Served-By $upstream_addr always;
        }
        
        location /nginx_status {
            stub_status on;
            access_log off;
        }
    }
}
EOF
```

### 4.2 Test du scaling manuel
```bash
# Démarrer avec scaling
docker-compose up -d --scale app=3

# Vérifier les instances
docker-compose ps

# Test de répartition de charge
echo "=== Test de load balancing ==="
for i in {1..9}; do
  echo "Request $i:"
  curl -s http://localhost:8080/ | grep -E "(hostname|requestCount)"
  echo ""
done

# Voir les statistiques nginx
curl -s http://localhost:8080/nginx_status

# Scaler à 5 instances
docker-compose up -d --scale app=5
docker-compose ps
```

### 4.3 Simulation de charge
```bash
# Test de charge simple avec curl
echo "=== Test de charge (20 requêtes) ==="
for i in {1..20}; do
  curl -s http://localhost:8080/ | jq -r '.hostname' &
done
wait

# Compter les requêtes par instance
echo -e "\n=== Répartition finale ==="
for i in {1..5}; do
  count=$(curl -s http://scaling-demo_app_$i:3000/ 2>/dev/null | jq -r '.requestCount // 0')
  echo "Instance $i: $count requêtes"
done
```

---

## Exercice 5 : Monitoring et logs

### 5.1 Stack de monitoring
```bash
mkdir -p ~/docker-tp/monitoring
cd ~/docker-tp/monitoring
```

#### Docker Compose avec monitoring
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Application à monitorer
  app:
    image: nginx:alpine
    volumes:
      - ./html:/usr/share/nginx/html:ro
    networks:
      - monitoring-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`app.localhost`)"

  # Collecte de logs
  fluentd:
    image: fluentd:latest
    volumes:
      - ./fluentd.conf:/fluentd/etc/fluent.conf
      - logs_data:/fluentd/log
    ports:
      - "24224:24224"
    networks:
      - monitoring-network

  # Reverse proxy avec logs
  traefik:
    image: traefik:v2.9
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--accesslog=true"
      - "--accesslog.filepath=/var/log/traefik-access.log"
    ports:
      - "80:80"
      - "8080:8080"  # Interface web Traefik
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_logs:/var/log
    networks:
      - monitoring-network

  # Monitoring système
  portainer:
    image: portainer/portainer-ce:latest
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks:
      - monitoring-network

volumes:
  logs_data:
  traefik_logs:
  portainer_data:

networks:
  monitoring-network:
    driver: bridge
EOF
```

#### Configuration Fluentd
```bash
mkdir -p logs

cat > fluentd.conf << 'EOF'
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<match **>
  @type file
  path /fluentd/log/docker-logs
  time_slice_format %Y%m%d
  time_slice_wait 1m
  time_format %Y%m%dT%H%M%S%z
</match>
EOF

# Contenu web simple
mkdir -p html
cat > html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Monitored App</title>
    <script>
        function generateLoad() {
            for(let i = 0; i < 10; i++) {
                fetch('/api/data?id=' + i)
                    .then(response => response.text())
                    .catch(err => console.log('Request ' + i + ': ' + err.message));
            }
        }
        
        setInterval(generateLoad, 5000);
    </script>
</head>
<body>
    <h1>Application monitorée</h1>
    <p>Génération automatique de trafic...</p>
    <p><a href="http://localhost:8080" target="_blank">Tableau de bord Traefik</a></p>
    <p><a href="http://localhost:9000" target="_blank">Portainer</a></p>
</body>
</html>
EOF
```

### 5.2 Analyse des logs
```bash
# Démarrer la stack de monitoring
docker-compose up -d

# Attendre le démarrage
sleep 10

# Générer du trafic
echo "=== Génération de trafic ==="
for i in {1..20}; do
  curl -s -H "Host: app.localhost" http://localhost/ > /dev/null
  curl -s -H "Host: app.localhost" http://localhost/nonexistent > /dev/null
done

# Voir les logs Traefik
echo "=== Logs Traefik ==="
docker-compose exec traefik tail -5 /var/log/traefik-access.log

# Logs des conteneurs
echo -e "\n=== Logs applicatifs ==="
docker-compose logs --tail 5 app

# Statistiques des conteneurs
echo -e "\n=== Statistiques ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo -e "\nInterfaces disponibles:"
echo "- Traefik Dashboard: http://localhost:8080"
echo "- Portainer: http://localhost:9000"
echo "- Application: http://localhost (Host: app.localhost)"
```

---

## Exercice 6 : Profils et déploiements avancés

### 6.1 Profils Docker Compose
```bash
mkdir -p ~/docker-tp/profiles-demo
cd ~/docker-tp/profiles-demo

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Services de base (toujours démarrés)
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    networks:
      - app-network

  api:
    build: .
    networks:
      - app-network

  # Services de développement
  database:
    image: mysql:8.0
    profiles: ["dev", "full"]
    environment:
      MYSQL_ROOT_PASSWORD: devpass
      MYSQL_DATABASE: testdb
    networks:
      - app-network

  phpmyadmin:
    image: phpmyadmin:latest
    profiles: ["dev", "full"]
    ports:
      - "8081:80"
    environment:
      PMA_HOST: database
    depends_on:
      - database
    networks:
      - app-network

  # Services de monitoring
  prometheus:
    image: prom/prometheus:latest
    profiles: ["monitoring", "full"]
    ports:
      - "9090:9090"
    networks:
      - app-network

  grafana:
    image: grafana/grafana:latest
    profiles: ["monitoring", "full"]
    ports:
      - "3000:3000"
    networks:
      - app-network

  # Services de test
  selenium:
    image: selenium/standalone-chrome:latest
    profiles: ["testing"]
    ports:
      - "4444:4444"
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOF
```

#### Application simple
```bash
cat > app.js << 'EOF'
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: 'API avec profils Docker',
    path: req.url,
    timestamp: new Date().toISOString()
  }));
});

server.listen(3000, () => {
  console.log('API démarrée sur le port 3000');
});
EOF

cat > Dockerfile << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY app.js .
EXPOSE 3000
CMD ["node", "app.js"]
EOF

mkdir -p html
echo "<h1>App avec profils</h1><p><a href='/api'>API</a></p>" > html/index.html
```

### 6.2 Tests des profils
```bash
# Démarrage de base (sans profils)
echo "=== Services de base ==="
docker-compose up -d
docker-compose ps

# Ajouter les services de développement
echo -e "\n=== + Services de développement ==="
docker-compose --profile dev up -d
docker-compose ps

# Ajouter le monitoring
echo -e "\n=== + Services de monitoring ==="
docker-compose --profile dev --profile monitoring up -d
docker-compose ps

# Tout démarrer
echo -e "\n=== Tous les services ==="
docker-compose --profile full up -d
docker-compose ps

# Tests
curl -s http://localhost:8080/
echo -e "\nServices disponibles:"
echo "- Web: http://localhost:8080"
echo "- phpMyAdmin: http://localhost:8081"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000"

# Arrêt sélectif
docker-compose --profile full down
```

---

## Exercice 7 : CI/CD et déploiement

### 7.1 Pipeline de déploiement
```bash
mkdir -p ~/docker-tp/cicd-demo
cd ~/docker-tp/cicd-demo
```

#### Scripts de déploiement
```bash
cat > deploy.sh << 'EOF'
#!/bin/bash

# Script de déploiement automatisé
set -e

ENVIRONMENT=${1:-dev}
VERSION=${2:-latest}

echo "[START] Déploiement en environnement: $ENVIRONMENT"
echo " Version: $VERSION"

# Vérifications préalables
check_requirements() {
    echo "[SEARCH] Vérification des prérequis..."
    
    if ! command -v docker-compose &> /dev/null; then
        echo "[NOK] Docker Compose n'est pas installé"
        exit 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        echo "[NOK] Fichier docker-compose.yml manquant"
        exit 1
    fi
    
    echo "[OK] Prérequis OK"
}

# Build des images
build_images() {
    echo "  Build des images..."
    docker-compose build --no-cache
    echo "[OK] Images construites"
}

# Tests de smoke
smoke_tests() {
    echo " Tests de smoke..."
    
    # Attendre que l'API soit disponible
    local timeout=60
    local count=0
    
    while [ $count -lt $timeout ]; do
        if curl -s http://localhost:3000/health > /dev/null; then
            echo "[OK] API accessible"
            return 0
        fi
        echo "[WAIT] Attente de l'API... ($count/$timeout)"
        sleep 1
        count=$((count + 1))
    done
    
    echo "[NOK] Tests de smoke échoués"
    return 1
}

# Déploiement
deploy() {
    echo "[START] Déploiement..."
    
    # Arrêter l'ancienne version
    docker-compose down || true
    
    # Démarrer la nouvelle version
    docker-compose --env-file .env.$ENVIRONMENT up -d
    
    # Attendre le démarrage
    sleep 10
    
    echo "[OK] Déploiement terminé"
}

# Rollback
rollback() {
    echo "[ROLLBACK] Rollback en cours..."
    docker-compose down
    # Ici on pourrait restaurer une version précédente
    echo "[OK] Rollback terminé"
}

# Fonction principale
main() {
    check_requirements
    
    if [ "$ENVIRONMENT" != "prod" ]; then
        build_images
    fi
    
    deploy
    
    if ! smoke_tests; then
        echo "[NOK] Déploiement échoué, rollback..."
        rollback
        exit 1
    fi
    
    echo "[PARTY] Déploiement réussi en $ENVIRONMENT!"
}

# Gestion des signaux pour cleanup
trap 'echo " Déploiement interrompu"; rollback; exit 1' INT TERM

main
EOF

chmod +x deploy.sh
```

#### Configuration multi-environnements
```bash
# App simple avec healthcheck
cat > app.js << 'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

let isHealthy = true;

app.get('/health', (req, res) => {
    if (isHealthy) {
        res.json({ status: 'OK', env: process.env.NODE_ENV });
    } else {
        res.status(503).json({ status: 'NOT_OK' });
    }
});

app.get('/', (req, res) => {
    res.json({
        message: 'Application CI/CD',
        version: process.env.APP_VERSION || '1.0.0',
        env: process.env.NODE_ENV || 'development',
        timestamp: new Date().toISOString()
    });
});

app.listen(PORT, () => {
    console.log(`App démarrée sur le port ${PORT}`);
});

// Simulation de problème de santé après 2 minutes (pour test)
if (process.env.NODE_ENV === 'test') {
    setTimeout(() => {
        console.log('Simulation d\'un problème de santé');
        isHealthy = false;
    }, 120000);
}
EOF

# Docker compose principal
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  app:
    build: .
    ports:
      - "${APP_PORT:-3000}:3000"
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - APP_VERSION=${APP_VERSION:-1.0.0}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-8080}:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      app:
        condition: service_healthy
    restart: unless-stopped
EOF

# Configurations d'environnements
cat > .env.dev << 'EOF'
NODE_ENV=development
APP_PORT=3000
WEB_PORT=8080
APP_VERSION=1.0.0-dev
EOF

cat > .env.test << 'EOF'
NODE_ENV=test
APP_PORT=3001
WEB_PORT=8081
APP_VERSION=1.0.0-test
EOF

cat > .env.prod << 'EOF'
NODE_ENV=production
APP_PORT=3002
WEB_PORT=80
APP_VERSION=1.0.0
EOF

# Configuration nginx
cat > nginx.conf << 'EOF'
events { worker_connections 1024; }
http {
    upstream app {
        server app:3000;
    }
    server {
        listen 80;
        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
        }
        location /health {
            proxy_pass http://app/health;
        }
    }
}
EOF

# Dockerfile avec healthcheck
cat > Dockerfile << 'EOF'
FROM node:16-alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY app.js .
EXPOSE 3000
CMD ["node", "app.js"]
EOF

# Package.json
cat > package.json << 'EOF'
{
  "name": "cicd-demo",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF
```

### 7.2 Test du pipeline
```bash
# Test des déploiements
echo "=== Test déploiement DEV ==="
./deploy.sh dev

# Vérifier
curl http://localhost:8080/health
curl http://localhost:8080/

echo -e "\n=== Test déploiement TEST ==="
./deploy.sh test

# Vérifier sur un autre port
curl http://localhost:8081/health

echo -e "\n=== Simulation d'échec ==="
# Créer une version défaillante
sed -i 's/isHealthy = true/isHealthy = false/' app.js
./deploy.sh dev || echo "Rollback effectué comme attendu"

# Restaurer
sed -i 's/isHealthy = false/isHealthy = true/' app.js
```

---

## Questions de synthèse

1. **Docker Compose** : Quels sont les avantages de Docker Compose par rapport aux commandes Docker classiques ?

2. **Environnements** : Comment gérer efficacement les différences entre dev/test/prod ?

3. **Scaling** : Quelles sont les limites du scaling avec Docker Compose ?

4. **Monitoring** : Comment monitorer efficacement une stack Docker Compose ?

5. **Déploiement** : Quelles sont les bonnes pratiques pour un déploiement zéro-downtime ?

---

## Défis bonus

### Défi 1 : Blue-Green Deployment
Implémentez un système de déploiement blue-green avec Docker Compose.

### Défi 2 : Auto-scaling
Créez un système qui scale automatiquement selon la charge CPU.

### Défi 3 : Backup automatisé
Implémentez un système de sauvegarde automatique des volumes.

---

## Nettoyage final

```bash
# Nettoyer tous les exercices
cd ~/docker-tp

# Arrêter et supprimer toutes les stacks
for dir in wordpress-stack nodejs-api multi-env scaling-demo monitoring profiles-demo cicd-demo; do
  if [ -d "$dir" ]; then
    cd "$dir"
    docker-compose down -v 2>/dev/null || true
    cd ..
  fi
done

# Nettoyage global
docker system prune -a --volumes -f

echo "[OK] Nettoyage terminé"
```

---

## Solutions

### Solution Exercice 1.2
WordPress sera accessible sur http://localhost:8080 après environ 30 secondes de démarrage pour l'initialisation de MySQL.

### Solution Défi 1 (Blue-Green Deployment)
```bash
# docker-compose.blue.yml
version: '3.8'
services:
  app-blue:
    build: .
    environment:
      - COLOR=blue
  
# docker-compose.green.yml  
version: '3.8'
services:
  app-green:
    build: .
    environment:
      - COLOR=green
      
# Script de switch
# docker-compose -f docker-compose.green.yml up -d
# # Tests...
# docker-compose -f docker-compose.blue.yml down
```