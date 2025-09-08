# TP3 - Gestion des volumes et persistance des données

## Objectifs
- Comprendre les différents types de volumes Docker
- Maîtriser la persistance des données
- Partager des données entre conteneurs
- Sauvegarder et restaurer des volumes

## Durée estimée
2h30

---

## Exercice 1 : Types de volumes - Découverte

### 1.1 Volume anonyme
```bash
# Créer un répertoire de travail
mkdir -p ~/docker-tp/volumes
cd ~/docker-tp/volumes

# Lancer un conteneur avec volume anonyme
docker run -it --rm -v /data alpine sh

# Dans le conteneur
echo "Données volume anonyme" > /data/test.txt
ls -la /data/
exit
```

**Question :** Que devient le fichier après la sortie du conteneur ?

### 1.2 Volume nommé
```bash
# Créer un volume nommé
docker volume create mon-volume

# Lister les volumes
docker volume ls

# Inspecter le volume
docker volume inspect mon-volume

# Utiliser le volume
docker run -it --rm -v mon-volume:/data alpine sh

# Dans le conteneur
echo "Données persistantes" > /data/persistant.txt
echo "Timestamp: $(date)" >> /data/persistant.txt
ls -la /data/
exit

# Vérifier la persistance
docker run --rm -v mon-volume:/data alpine cat /data/persistant.txt
```

### 1.3 Bind mount
```bash
# Créer un dossier local
mkdir -p ~/docker-tp/shared-data
echo "Données depuis l'hôte" > ~/docker-tp/shared-data/host-file.txt

# Monter le dossier dans le conteneur
docker run -it --rm -v ~/docker-tp/shared-data:/data alpine sh

# Dans le conteneur
ls -la /data/
echo "Modifié depuis le conteneur" >> /data/host-file.txt
echo "Nouveau fichier du conteneur" > /data/container-file.txt
exit

# Vérifier sur l'hôte
ls -la ~/docker-tp/shared-data/
cat ~/docker-tp/shared-data/host-file.txt
```

**Question :** Quelle est la différence entre un volume nommé et un bind mount ?

---

## Exercice 2 : Base de données persistante

### 2.1 MySQL avec volume
```bash
# Créer un volume pour MySQL
docker volume create mysql-data

# Lancer MySQL avec le volume
docker run -d \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=motdepasse123 \
  -e MYSQL_DATABASE=ma_base \
  -e MYSQL_USER=utilisateur \
  -e MYSQL_PASSWORD=password123 \
  -v mysql-data:/var/lib/mysql \
  -p 3306:3306 \
  mysql:8.0

# Attendre que MySQL soit prêt
echo "Attente du démarrage de MySQL..."
sleep 20

# Vérifier que MySQL fonctionne
docker logs mysql-db | tail -10
```

### 2.2 Créer des données de test
```bash
# Se connecter à MySQL
docker exec -it mysql-db mysql -u utilisateur -p

# Dans MySQL (mot de passe: password123)
USE ma_base;

CREATE TABLE employes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100),
    poste VARCHAR(100),
    salaire DECIMAL(10,2)
);

INSERT INTO employes (nom, poste, salaire) VALUES
('Jean Dupont', 'Développeur', 45000.00),
('Marie Martin', 'Chef de projet', 55000.00),
('Pierre Durand', 'Administrateur', 40000.00);

SELECT * FROM employes;
SHOW TABLES;
EXIT;
```

### 2.3 Test de persistance
```bash
# Arrêter et supprimer le conteneur
docker stop mysql-db
docker rm mysql-db

# Relancer MySQL avec le même volume
docker run -d \
  --name mysql-db-nouveau \
  -e MYSQL_ROOT_PASSWORD=motdepasse123 \
  -e MYSQL_DATABASE=ma_base \
  -e MYSQL_USER=utilisateur \
  -e MYSQL_PASSWORD=password123 \
  -v mysql-data:/var/lib/mysql \
  -p 3306:3306 \
  mysql:8.0

# Attendre le démarrage
sleep 20

# Vérifier que les données sont toujours là
docker exec -it mysql-db-nouveau mysql -u utilisateur -p -e "USE ma_base; SELECT * FROM employes;"
```

**Question :** Les données sont-elles toujours présentes ? Pourquoi ?

---

## Exercice 3 : Partage de données entre conteneurs

### 3.1 Conteneur producteur
```bash
# Créer un volume partagé
docker volume create donnees-partagees

# Conteneur qui génère des données
docker run -d \
  --name generateur \
  -v donnees-partagees:/data \
  alpine \
  sh -c 'while true; do echo "$(date): Log généré" >> /data/logs.txt; sleep 5; done'

# Vérifier la génération
sleep 10
docker run --rm -v donnees-partagees:/data alpine tail -5 /data/logs.txt
```

### 3.2 Conteneurs consommateurs
```bash
# Conteneur qui lit les logs
docker run -d \
  --name lecteur \
  -v donnees-partagees:/data:ro \
  alpine \
  sh -c 'while true; do echo "=== Lecture des logs ==="; tail -3 /data/logs.txt; sleep 10; done'

# Conteneur qui analyse les logs
docker run -d \
  --name analyseur \
  -v donnees-partagees:/data:ro \
  alpine \
  sh -c 'while true; do COUNT=$(wc -l < /data/logs.txt); echo "Nombre total de logs: $COUNT"; sleep 15; done'

# Observer les logs des différents conteneurs
docker logs --tail 5 generateur
docker logs --tail 5 lecteur
docker logs --tail 5 analyseur
```

### 3.3 Application web avec données partagées
```bash
# Créer une application web simple
mkdir -p ~/docker-tp/webapp-shared
cd ~/docker-tp/webapp-shared

cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Données partagées Docker</title>
    <meta http-equiv="refresh" content="5">
</head>
<body>
    <h1>Monitoring des logs</h1>
    <h2>Logs récents:</h2>
    <pre id="logs"></pre>
    <script>
        fetch('/logs.txt')
            .then(response => response.text())
            .then(data => {
                const lines = data.split('\n').slice(-10);
                document.getElementById('logs').textContent = lines.join('\n');
            });
    </script>
</body>
</html>
EOF

# Serveur web nginx qui lit les données partagées
docker run -d \
  --name web-monitor \
  -v donnees-partagees:/usr/share/nginx/html/logs:ro \
  -v ~/docker-tp/webapp-shared/index.html:/usr/share/nginx/html/index.html:ro \
  -p 8080:80 \
  nginx

# Tester l'accès web
echo "Ouvrir http://localhost:8080 dans un navigateur"
curl http://localhost:8080/logs.txt | tail -5
```

---

## Exercice 4 : Sauvegarde et restauration

### 4.1 Sauvegarde d'un volume
```bash
# Créer un répertoire de sauvegarde
mkdir -p ~/docker-tp/backups

# Sauvegarder le volume MySQL
docker run --rm \
  -v mysql-data:/data:ro \
  -v ~/docker-tp/backups:/backup \
  alpine \
  tar czf /backup/mysql-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .

# Lister les sauvegardes
ls -la ~/docker-tp/backups/
```

### 4.2 Sauvegarde avec dump MySQL
```bash
# Sauvegarde logique de MySQL
docker exec mysql-db-nouveau mysqldump \
  -u utilisateur -ppassword123 \
  --all-databases > ~/docker-tp/backups/mysql-dump-$(date +%Y%m%d).sql

# Vérifier le contenu du dump
head -20 ~/docker-tp/backups/mysql-dump-*.sql
grep -n "employes" ~/docker-tp/backups/mysql-dump-*.sql
```

### 4.3 Restauration depuis sauvegarde
```bash
# Créer un nouveau volume pour test
docker volume create mysql-restore

# Restaurer les données
BACKUP_FILE=$(ls ~/docker-tp/backups/mysql-backup-*.tar.gz | head -1)
docker run --rm \
  -v mysql-restore:/data \
  -v ~/docker-tp/backups:/backup \
  alpine \
  tar xzf /backup/$(basename $BACKUP_FILE) -C /data

# Lancer MySQL avec le volume restauré
docker run -d \
  --name mysql-restore \
  -e MYSQL_ROOT_PASSWORD=motdepasse123 \
  -v mysql-restore:/var/lib/mysql \
  -p 3307:3306 \
  mysql:8.0

# Attendre et tester
sleep 25
docker exec -it mysql-restore mysql -u utilisateur -ppassword123 -e "USE ma_base; SELECT * FROM employes;"
```

---

## Exercice 5 : Volumes avec Docker Compose

### 5.1 Stack LAMP complète
```bash
mkdir -p ~/docker-tp/lamp-stack
cd ~/docker-tp/lamp-stack
```

#### Créer docker-compose.yml
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: lamp-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: webapp
      MYSQL_USER: webuser
      MYSQL_PASSWORD: webpass123
    volumes:
      - mysql-data:/var/lib/mysql
      - ./init-db:/docker-entrypoint-initdb.d
    ports:
      - "3306:3306"

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: lamp-phpmyadmin
    restart: always
    environment:
      PMA_HOST: mysql
      PMA_PORT: 3306
    ports:
      - "8081:80"
    depends_on:
      - mysql

  web:
    image: nginx:alpine
    container_name: lamp-web
    restart: always
    ports:
      - "8080:80"
    volumes:
      - ./web-content:/usr/share/nginx/html:ro
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - mysql

volumes:
  mysql-data:
EOF
```

#### Créer le contenu web
```bash
mkdir -p web-content init-db

# Page d'accueil
cat > web-content/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Stack LAMP Docker</title>
    <style>
        body { font-family: Arial; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .service { background: #f4f4f4; padding: 20px; margin: 10px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Stack LAMP avec Docker</h1>
        <div class="service">
            <h3> Base de données MySQL</h3>
            <p>Accès: <a href="http://localhost:8081" target="_blank">phpMyAdmin</a></p>
            <p>Port: 3306 | Utilisateur: webuser | Mot de passe: webpass123</p>
        </div>
        <div class="service">
            <h3> Serveur Web Nginx</h3>
            <p>Port: 8080 | Documents racine: /usr/share/nginx/html</p>
        </div>
        <div class="service">
            <h3> Données persistantes</h3>
            <p>Volume MySQL: mysql-data</p>
            <p>Volume Web: bind mount ./web-content</p>
        </div>
    </div>
</body>
</html>
EOF

# Script d'initialisation de la base
cat > init-db/01-init.sql << 'EOF'
USE webapp;

CREATE TABLE articles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(200),
    contenu TEXT,
    auteur VARCHAR(100),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO articles (titre, contenu, auteur) VALUES
('Bienvenue sur Docker', 'Premier article sur notre stack LAMP dockerisée', 'Admin'),
('Volumes Docker', 'Les volumes permettent la persistance des données', 'DevOps'),
('Docker Compose', 'Orchestration simple avec docker-compose', 'Développeur');
EOF
```

#### Configuration nginx
```bash
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }

        location /health {
            access_log off;
            return 200 "OK\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF
```

### 5.2 Déploiement et test
```bash
# Lancer la stack
docker-compose up -d

# Vérifier les services
docker-compose ps
docker-compose logs --tail 10

# Tester les services
echo "=== Test Web ==="
curl http://localhost:8080/

echo "=== Test PhpMyAdmin ==="
curl -I http://localhost:8081/

echo "=== Test MySQL ==="
docker-compose exec mysql mysql -u webuser -pwebpass123 -e "USE webapp; SELECT * FROM articles;"
```

### 5.3 Modification des données en temps réel
```bash
# Modifier le contenu web (bind mount)
echo "<p style='color: red;'>Modification en temps réel - $(date)</p>" >> web-content/index.html

# Vérifier la modification
curl http://localhost:8080/ | tail -5

# Ajouter des données en base
docker-compose exec mysql mysql -u webuser -pwebpass123 -e "
USE webapp;
INSERT INTO articles (titre, contenu, auteur) VALUES
('Test en temps réel', 'Article ajouté pendant le TP - $(date)', 'Stagiaire');
SELECT COUNT(*) as total_articles FROM articles;"
```

---

## Exercice 6 : Optimisation et monitoring

### 6.1 Analyse de l'utilisation des volumes
```bash
# Informations sur les volumes
docker volume ls
docker system df -v

# Inspection détaillée
docker volume inspect mysql-data
docker volume inspect donnees-partagees

# Utilisation d'espace par volume
docker run --rm -v mysql-data:/data alpine du -sh /data
```

### 6.2 Nettoyage des volumes
```bash
# Lister les volumes non utilisés
docker volume ls -f "dangling=true"

# Nettoyer les volumes orphelins
docker volume prune

# Arrêter et nettoyer la stack LAMP
cd ~/docker-tp/lamp-stack
docker-compose down

# Nettoyer avec suppression des volumes
docker-compose down -v
```

### 6.3 Monitoring des performances
```bash
# Statistiques en temps réel
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.BlockIO}}"

# Relancer quelques conteneurs pour le test
docker run -d --name test-mysql -v mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=test mysql:8.0
sleep 10
docker stats test-mysql --no-stream

# Nettoyer
docker stop test-mysql && docker rm test-mysql
```

---

## Exercice 7 : Cas d'usage avancés

### 7.1 Volume en lecture seule
```bash
# Créer des données de configuration
mkdir -p ~/docker-tp/config
echo "server_id=1" > ~/docker-tp/config/mysql.cnf
echo "log-bin=mysql-bin" >> ~/docker-tp/config/mysql.cnf

# Monter en lecture seule
docker run -d \
  --name mysql-readonly-config \
  -e MYSQL_ROOT_PASSWORD=test123 \
  -v ~/docker-tp/config/mysql.cnf:/etc/mysql/conf.d/custom.cnf:ro \
  mysql:8.0

# Tenter de modifier (va échouer)
docker exec mysql-readonly-config sh -c 'echo "test" >> /etc/mysql/conf.d/custom.cnf' || echo "Modification interdite (normal)"

docker stop mysql-readonly-config && docker rm mysql-readonly-config
```

### 7.2 Volume temporaire (tmpfs)
```bash
# Monter un filesystem en mémoire
docker run -it --rm \
  --tmpfs /tmp-memory:rw,size=100m \
  alpine sh -c '
    echo "Test tmpfs" > /tmp-memory/test.txt
    df -h /tmp-memory
    cat /tmp-memory/test.txt
  '
```

### 7.3 Volumes avec contraintes de sécurité
```bash
# Créer un utilisateur non-root dans le conteneur
docker run -it --rm \
  -v ~/docker-tp/shared-data:/data \
  --user 1001:1001 \
  alpine sh -c '
    id
    touch /data/user-file.txt || echo "Permission refusée"
    ls -la /data/
  '
```

---

## Questions de synthèse

1. **Types de volumes** : Quand utiliser un volume nommé vs un bind mount ?

2. **Persistance** : Comment garantir qu'aucune donnée ne sera perdue lors du redéploiement d'une application ?

3. **Sécurité** : Quels sont les risques liés aux bind mounts ?

4. **Performance** : Quelles sont les différences de performance entre les types de volumes ?

5. **Sauvegarde** : Quelle stratégie adopter pour sauvegarder les données Docker en production ?

---

## Défis bonus

### Défi 1 : Synchronisation bidirectionnelle
Créez un système où les modifications de fichiers côté hôte et côté conteneur sont synchronisées en temps réel.

### Défi 2 : Volume distribué
Simulez un volume partagé entre plusieurs "hôtes" Docker (utilisation de NFS ou autre).

### Défi 3 : Sauvegarde automatisée
Créez un conteneur qui sauvegarde automatiquement les volumes toutes les heures.

---

## Solutions

### Solution Exercice 1.1
Le fichier disparaît car un volume anonyme est automatiquement supprimé quand aucun conteneur ne l'utilise plus.

### Solution Exercice 1.3
Un volume nommé est géré par Docker et stocké dans `/var/lib/docker/volumes/`. Un bind mount lie directement un chemin de l'hôte au conteneur.

### Solution Défi 3
```bash
cat > backup-container.sh << 'EOF'
#!/bin/bash
while true; do
  docker run --rm \
    -v mysql-data:/data:ro \
    -v ~/backups:/backup \
    alpine \
    tar czf /backup/auto-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
  echo "Sauvegarde créée: $(date)"
  sleep 3600  # 1 heure
done
EOF
```