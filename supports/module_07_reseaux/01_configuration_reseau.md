# Module 7.1 : Configuration réseau de base

## Objectifs d'apprentissage
- Comprendre les concepts réseau fondamentaux sous Linux
- Utiliser les commandes ip, ping, wget, curl pour diagnostiquer
- Configurer les interfaces réseau de base
- Analyser la connectivité réseau
- Résoudre les problèmes réseau courants

## Introduction

La **configuration réseau** est essentielle sous Linux pour la connectivité Internet, les services, et la communication entre systèmes. Linux offre de nombreux outils pour configurer, diagnostiquer et surveiller le réseau.

---

## 1. Concepts réseau fondamentaux

### Architecture réseau TCP/IP

#### Modèle en couches simplifié
```
Application  │ HTTP, SSH, DNS, etc.
Transport    │ TCP, UDP (ports)
Réseau       │ IP (adresses IPv4/IPv6)  
Liaison      │ Ethernet, WiFi (MAC)
Physique     │ Câbles, ondes radio
```

#### Éléments clés
- **Adresse IP** : identifiant unique sur le réseau (ex: 192.168.1.100)
- **Masque de réseau** : définit la taille du réseau (ex: 255.255.255.0 ou /24)
- **Passerelle** : routeur pour sortir du réseau local
- **DNS** : résolution nom → adresse IP
- **Port** : point d'entrée pour services (ex: 80=HTTP, 22=SSH)

### Types d'adresses IP

#### IPv4 (Internet Protocol version 4)
```bash
# Format : X.X.X.X où X = 0-255
# Exemples :
192.168.1.100    # Adresse privée (réseau local)
10.0.0.50        # Adresse privée (réseau local)
8.8.8.8          # Adresse publique (DNS Google)
127.0.0.1        # Adresse de bouclage (localhost)
```

#### Plages d'adresses privées (RFC 1918)
```bash
10.0.0.0/8          # 10.0.0.0 à 10.255.255.255
172.16.0.0/12       # 172.16.0.0 à 172.31.255.255  
192.168.0.0/16      # 192.168.0.0 à 192.168.255.255
```

#### IPv6 (Internet Protocol version 6)
```bash
# Format : XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX
# Exemples :
::1                           # Localhost IPv6
2001:db8::1                   # Exemple documenté
fe80::a00:27ff:fe4e:66a1     # Adresse link-local
```

---

## 2. Commande ip - Outil moderne de configuration

### Remplacement des anciennes commandes

#### Correspondances commandes
```bash
# Anciennes commandes → Nouvelles commandes ip
ifconfig         → ip addr, ip link
route           → ip route  
arp             → ip neigh
netstat         → ss
```

### Gestion des interfaces avec ip link

#### Lister les interfaces
```bash
# Voir toutes les interfaces réseau
ip link show
ip link

# Interface spécifique
ip link show eth0
ip link show wlan0

# Format concis
ip -br link show    # Brief format
```

#### État des interfaces
```bash
# Activer une interface
sudo ip link set eth0 up

# Désactiver une interface  
sudo ip link set eth0 down

# Changer l'adresse MAC (si supporté)
sudo ip link set eth0 address 02:01:02:03:04:05

# Modifier le MTU
sudo ip link set eth0 mtu 1400
```

### Gestion des adresses avec ip addr

#### Afficher les adresses IP
```bash
# Toutes les adresses
ip addr show
ip addr
ip a           # Forme courte

# Interface spécifique
ip addr show eth0
ip a s eth0    # Forme courte

# Format concis
ip -br addr show    # Brief format
```

#### Configurer des adresses IP
```bash
# Ajouter une adresse IP
sudo ip addr add 192.168.1.100/24 dev eth0

# Ajouter plusieurs adresses (aliasing)
sudo ip addr add 192.168.1.101/24 dev eth0
sudo ip addr add 10.0.0.50/8 dev eth0

# Supprimer une adresse
sudo ip addr del 192.168.1.101/24 dev eth0

# Vider toutes les adresses d'une interface
sudo ip addr flush dev eth0
```

### Gestion des routes avec ip route

#### Afficher la table de routage
```bash
# Toutes les routes
ip route show
ip route
ip r           # Forme courte

# Route par défaut seulement
ip route show default

# Routes vers un réseau spécifique
ip route show 192.168.1.0/24
```

#### Configurer le routage
```bash
# Ajouter route par défaut (passerelle)
sudo ip route add default via 192.168.1.1

# Ajouter route vers réseau spécifique
sudo ip route add 10.0.0.0/8 via 192.168.1.254

# Supprimer une route
sudo ip route del default via 192.168.1.1
sudo ip route del 10.0.0.0/8

# Route via interface spécifique
sudo ip route add 172.16.0.0/16 dev eth1
```

---

## 3. Tests de connectivité

### Commande ping - Test basique de connectivité

#### Utilisation de base
```bash
# Test simple (Ctrl+C pour arrêter)
ping google.com
ping 8.8.8.8

# Nombre limité de pings
ping -c 5 google.com       # 5 pings seulement
ping -c 1 192.168.1.1      # Un seul ping (test rapide)

# Intervalles personnalisés
ping -i 2 google.com       # Toutes les 2 secondes
ping -i 0.2 localhost      # 5 fois par seconde (root requis)
```

#### Options utiles
```bash
# Timeout personnalisé
ping -W 3 192.168.1.100    # Timeout 3 secondes

# Taille des paquets
ping -s 1000 google.com    # Paquets de 1000 bytes

# Interface source spécifique
ping -I eth0 google.com

# IPv6
ping6 ipv6.google.com
ping -6 google.com

# Mode silencieux (résultats seulement)
ping -q -c 5 google.com
```

#### Interpréter les résultats
```bash
ping -c 4 google.com
# PING google.com (142.250.191.14) 56(84) bytes of data.
# 64 bytes from par21s19-in-f14.1e100.net: icmp_seq=1 ttl=118 time=23.4 ms
# 64 bytes from par21s19-in-f14.1e100.net: icmp_seq=2 ttl=118 time=22.8 ms
# 64 bytes from par21s19-in-f14.1e100.net: icmp_seq=3 ttl=118 time=24.1 ms
# 64 bytes from par21s19-in-f14.1e100.net: icmp_seq=4 ttl=118 time=23.7 ms
#
# --- google.com ping statistics ---
# 4 packets transmitted, 4 received, 0% packet loss, time 3005ms
# rtt min/avg/max/mdev = 22.756/23.500/24.065/0.509 ms

# Métriques importantes :
# - ttl (Time To Live) : nombre de sauts restants
# - time : latence (round-trip time)
# - packet loss : pourcentage de paquets perdus
# - rtt : statistiques de latence (min/moyenne/max/écart-type)
```

### Commande traceroute - Tracer le chemin réseau

#### Installation et utilisation
```bash
# Installation si nécessaire
sudo apt install traceroute

# Tracer le chemin vers une destination
traceroute google.com
traceroute 8.8.8.8

# IPv6
traceroute6 ipv6.google.com

# Utiliser ICMP au lieu d'UDP
traceroute -I google.com

# Spécifier l'interface source
traceroute -i eth0 google.com
```

#### Interpréter traceroute
```bash
traceroute google.com
# traceroute to google.com (142.250.191.14), 30 hops max, 60 byte packets
#  1  192.168.1.1 (192.168.1.1)  1.245 ms  1.189 ms  1.162 ms
#  2  10.0.0.1 (10.0.0.1)  12.456 ms  12.234 ms  12.123 ms
#  3  * * *
#  4  172.16.1.1 (172.16.1.1)  45.678 ms  45.234 ms  44.987 ms
# ...

# Analyse :
# - Chaque ligne = un saut (routeur)
# - 3 temps par saut = 3 tests de latence
# - * = timeout (routeur ne répond pas)
# - Progression normale : latence qui augmente
```

---

## 4. Commandes wget et curl - Transfert de données

### wget - Téléchargeur de fichiers

#### Utilisation de base
```bash
# Télécharger un fichier
wget https://example.com/file.txt

# Télécharger avec nom personnalisé
wget -O mon_fichier.txt https://example.com/file.txt

# Télécharger dans un répertoire spécifique
wget -P /tmp https://example.com/file.txt

# Téléchargement récursif (site complet)
wget -r -np -k https://example.com/
```

#### Options avancées
```bash
# Mode silencieux
wget -q https://example.com/file.txt

# Reprendre un téléchargement interrompu
wget -c https://example.com/big_file.iso

# Limiter la bande passante
wget --limit-rate=200k https://example.com/file.txt

# Authentification HTTP
wget --user=username --password=password https://site.com/file.txt

# User-Agent personnalisé
wget --user-agent="Mozilla/5.0" https://site.com/file.txt

# Suivre les redirections
wget --max-redirect=5 https://site.com/file.txt
```

#### Tests de connectivité avec wget
```bash
# Test simple de connectivité HTTP
wget --spider https://google.com
echo $?    # 0 = succès, autre = échec

# Test avec timeout
wget --spider --timeout=10 https://example.com

# Headers seulement
wget --server-response --spider https://example.com

# Test HTTPS/certificat
wget --no-check-certificate https://self-signed-site.com
```

### curl - Client URL polyvalent

#### Utilisation de base
```bash
# Récupérer le contenu d'une page
curl https://httpbin.org/ip

# Sauvegarder dans un fichier
curl -o output.html https://example.com
curl -O https://example.com/file.txt    # Garde le nom original

# Afficher les headers HTTP
curl -I https://google.com              # Headers seulement
curl -i https://httpbin.org/ip          # Headers + contenu

# Suivre les redirections
curl -L https://bit.ly/short-url
```

#### Tests et diagnostics avec curl
```bash
# Test de performance détaillé
curl -w "@-" -o /dev/null -s https://google.com << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF

# Test connectivité par port
curl -v telnet://server.com:22    # Test SSH
curl -v telnet://server.com:80    # Test HTTP
curl -v telnet://server.com:443   # Test HTTPS

# Test API REST
curl -X GET https://api.github.com/users/octocat
curl -X POST -d "data=value" https://httpbin.org/post
curl -H "Content-Type: application/json" -d '{"key":"value"}' https://httpbin.org/post
```

#### Options avancées curl
```bash
# Authentification
curl -u username:password https://site.com/api
curl -H "Authorization: Bearer TOKEN" https://api.com/data

# Certificats SSL
curl -k https://self-signed-site.com    # Ignorer certificat
curl --cacert ca.pem https://site.com   # Certificat CA spécifique

# Proxy
curl --proxy http://proxy:8080 https://site.com

# Timeout et retry
curl --connect-timeout 10 --max-time 30 https://site.com
curl --retry 3 --retry-delay 5 https://unstable-site.com

# Upload de fichier
curl -F "file=@/path/to/file.txt" https://upload-site.com
curl -T file.txt https://site.com/upload
```

---

## 5. Résolution de noms (DNS)

### Commandes de résolution DNS

#### nslookup - Requêtes DNS interactives
```bash
# Résolution simple
nslookup google.com

# Serveur DNS spécifique
nslookup google.com 8.8.8.8

# Type d'enregistrement spécifique
nslookup -type=MX google.com       # Enregistrements mail
nslookup -type=NS google.com       # Serveurs de noms
nslookup -type=TXT google.com      # Enregistrements texte

# Résolution inverse (IP → nom)
nslookup 8.8.8.8
```

#### dig - Outil DNS avancé
```bash
# Installation si nécessaire
sudo apt install dnsutils

# Résolution simple
dig google.com

# Type d'enregistrement spécifique
dig google.com A        # IPv4
dig google.com AAAA     # IPv6
dig google.com MX       # Mail exchange
dig google.com NS       # Name servers
dig google.com TXT      # Text records

# Serveur DNS spécifique
dig @8.8.8.8 google.com

# Format court
dig +short google.com
dig +short google.com MX

# Trace complète de résolution
dig +trace google.com
```

#### host - Résolution DNS simple
```bash
# Résolution basique
host google.com

# Type spécifique
host -t MX google.com
host -t NS google.com

# Résolution inverse
host 8.8.8.8

# Serveur DNS spécifique
host google.com 8.8.8.8
```

### Configuration DNS locale

#### Fichier /etc/hosts
```bash
# Voir le contenu actuel
cat /etc/hosts

# Exemple de contenu :
# 127.0.0.1    localhost
# 127.0.1.1    hostname
# 192.168.1.10 server.local server
# 192.168.1.20 nas.local

# Ajouter une entrée locale
echo "192.168.1.100 monserver.local" | sudo tee -a /etc/hosts

# Tester la résolution locale
ping monserver.local
```

#### Configuration DNS système
```bash
# Voir la configuration DNS (méthodes selon distribution)
cat /etc/resolv.conf

# Exemple de contenu :
# nameserver 8.8.8.8
# nameserver 8.8.4.4
# search localdomain

# Voir l'ordre de résolution
cat /etc/nsswitch.conf | grep hosts
# hosts: files dns    # Ordre : /etc/hosts puis DNS
```

---

## 6. Surveillance des connexions réseau

### Commande ss - Socket statistics

#### Remplace netstat (moderne)
```bash
# Toutes les connexions
ss

# Connexions TCP seulement
ss -t

# Connexions UDP seulement
ss -u

# Ports en écoute seulement
ss -l

# Combinaisons utiles
ss -tln     # TCP, listening, numerical
ss -tuln    # TCP+UDP, listening, numerical
ss -tulpn   # TCP+UDP, listening, processes, numerical
```

#### Filtrage avec ss
```bash
# Par port
ss -tln sport :22      # Connexions SSH sortantes
ss -tln dport :80      # Connexions HTTP entrantes

# Par état
ss -t state established    # Connexions établies
ss -t state listening     # Ports en écoute

# Par adresse
ss dst 192.168.1.100
ss src 10.0.0.0/8
```

### Commande netstat (traditionnel)

#### Utilisation de base
```bash
# Toutes les connexions
netstat -a

# Ports en écoute
netstat -l

# Avec processus et PID
netstat -p

# Format numérique (pas de résolution DNS)
netstat -n

# Combinaisons courantes
netstat -tlnp    # TCP listening avec processus
netstat -ulnp    # UDP listening avec processus
netstat -anp     # Tout avec processus
```

#### Statistiques réseau
```bash
# Statistiques par protocole
netstat -s

# Statistiques interfaces
netstat -i

# Table de routage
netstat -r
netstat -rn    # Format numérique
```

---

## 7. Diagnostic et résolution de problèmes

### Méthodologie de diagnostic réseau

#### Approche en couches (bottom-up)
```bash
# 1. Liaison physique
ip link show                    # Interface active ?
dmesg | grep -i eth            # Messages du noyau
ethtool eth0                   # État physique (si installé)

# 2. Configuration IP
ip addr show                   # Adresse IP configurée ?
ip route show                  # Route par défaut ?

# 3. Connectivité locale
ping 127.0.0.1                # Loopback OK ?
ping $(ip route | grep default | awk '{print $3}')  # Passerelle OK ?

# 4. Connectivité Internet
ping 8.8.8.8                  # DNS Google (IP)
ping google.com               # Résolution DNS + connectivité

# 5. Services applicatifs
curl -I http://website.com     # Service web
ssh user@server.com           # Service SSH
```

### Problèmes courants et solutions

#### Interface réseau non active
```bash
# Problème : interface DOWN
ip link show eth0
# Solution
sudo ip link set eth0 up

# Problème : pas d'adresse IP
ip addr show eth0
# Solution DHCP
sudo dhclient eth0
# Ou adresse statique
sudo ip addr add 192.168.1.100/24 dev eth0
```

#### Problèmes de routage
```bash
# Problème : pas de route par défaut
ip route show default
# Solution
sudo ip route add default via 192.168.1.1

# Problème : routage spécifique manquant
# Solution
sudo ip route add 10.0.0.0/8 via 192.168.1.254
```

#### Problèmes DNS
```bash
# Problème : résolution DNS échoue
nslookup google.com
# Solutions
# 1. Vérifier /etc/resolv.conf
sudo nano /etc/resolv.conf
# Ajouter : nameserver 8.8.8.8

# 2. Tester autres serveurs DNS
nslookup google.com 1.1.1.1

# 3. Vider cache DNS local
sudo systemctl restart systemd-resolved
# ou
sudo /etc/init.d/networking restart
```

### Scripts de diagnostic automatisé

#### Script de diagnostic réseau complet
```bash
#!/bin/bash
# network_diag.sh - Diagnostic réseau automatisé

echo "=== DIAGNOSTIC RÉSEAU COMPLET ==="
echo "Date: $(date)"
echo

# Interface réseau
echo "1. INTERFACES RÉSEAU:"
ip -br link show
echo

echo "2. ADRESSES IP:"
ip -br addr show
echo

echo "3. TABLE DE ROUTAGE:"
ip route show
echo

echo "4. SERVEURS DNS:"
cat /etc/resolv.conf | grep nameserver
echo

# Tests de connectivité
echo "5. TESTS DE CONNECTIVITÉ:"

# Loopback
if ping -c 1 -W 2 127.0.0.1 > /dev/null 2>&1; then
    echo "   ✅ Loopback (127.0.0.1): OK"
else
    echo "   ❌ Loopback (127.0.0.1): ÉCHEC"
fi

# Passerelle
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
if [ -n "$GATEWAY" ]; then
    if ping -c 1 -W 3 "$GATEWAY" > /dev/null 2>&1; then
        echo "   ✅ Passerelle ($GATEWAY): OK"
    else
        echo "   ❌ Passerelle ($GATEWAY): ÉCHEC"
    fi
else
    echo "   ❌ Passerelle: NON CONFIGURÉE"
fi

# DNS externe
if ping -c 1 -W 3 8.8.8.8 > /dev/null 2>&1; then
    echo "   ✅ DNS externe (8.8.8.8): OK"
else
    echo "   ❌ DNS externe (8.8.8.8): ÉCHEC"
fi

# Résolution DNS
if nslookup google.com > /dev/null 2>&1; then
    echo "   ✅ Résolution DNS (google.com): OK"
else
    echo "   ❌ Résolution DNS (google.com): ÉCHEC"
fi

# Internet HTTP
if curl -s -m 10 http://google.com > /dev/null 2>&1; then
    echo "   ✅ Internet HTTP (google.com): OK"
else
    echo "   ❌ Internet HTTP (google.com): ÉCHEC"
fi

echo

# Ports en écoute
echo "6. PORTS EN ÉCOUTE:"
ss -tln | head -10
echo

# Recommandations
echo "7. RECOMMANDATIONS:"
if ! ip route | grep -q default; then
    echo "   - Configurer une route par défaut"
fi

if ! cat /etc/resolv.conf | grep -q nameserver; then
    echo "   - Configurer des serveurs DNS"
fi

echo "   - Vérifier les paramètres de pare-feu si problèmes persistent"
echo
echo "=== FIN DU DIAGNOSTIC ==="
```

---

## Résumé

### Commandes essentielles de réseau
```bash
# Configuration réseau moderne
ip link show            # Interfaces réseau
ip addr show            # Adresses IP
ip route show           # Table de routage
ip link set eth0 up     # Activer interface

# Tests de connectivité
ping google.com         # Test basique
traceroute google.com   # Tracer le chemin
wget --spider url       # Test HTTP
curl -I url            # Headers HTTP

# Résolution DNS
nslookup domain.com     # Requête DNS simple
dig domain.com         # Requête DNS avancée
host domain.com        # Résolution simple

# Surveillance connexions
ss -tuln               # Ports ouverts (moderne)
netstat -tuln          # Ports ouverts (traditionnel)
```

### Configuration IP de base
```bash
# Adresse IP statique
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip route add default via 192.168.1.1

# DHCP automatique
sudo dhclient eth0

# DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

### Diagnostic réseau méthodique
1. **Physique** : `ip link show` (interface UP?)
2. **IP** : `ip addr show` (adresse configurée?)
3. **Routage** : `ip route show` (route par défaut?)
4. **Local** : `ping 127.0.0.1` (pile TCP/IP OK?)
5. **Passerelle** : `ping gateway` (routeur accessible?)
6. **Internet** : `ping 8.8.8.8` (connectivité Internet?)
7. **DNS** : `ping google.com` (résolution de noms?)
8. **Services** : `curl -I website.com` (applications?)

### Fichiers de configuration importants
- `/etc/hosts` : résolution locale de noms
- `/etc/resolv.conf` : configuration DNS
- `/etc/nsswitch.conf` : ordre de résolution
- `/etc/network/interfaces` : configuration permanente (Debian)

### Bonnes pratiques
- **Tests systématiques** : suivre la méthodologie en couches
- **Sauvegarde config** : noter les paramètres qui fonctionnent
- **Documentation** : enregistrer les configurations personnalisées
- **Outils modernes** : préférer `ip` et `ss` aux anciennes commandes
- **Sécurité** : ne pas laisser de ports inutiles ouverts

---

**Temps de lecture estimé** : 30-35 minutes
**Niveau** : Intermédiaire
**Pré-requis** : Navigation fichiers, édition texte, concepts de base système