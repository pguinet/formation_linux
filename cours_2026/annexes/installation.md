# Annexe — Installer son environnement de travail

> Ce guide est un prérequis : la formation commence une fois
> l'environnement installé et fonctionnel.

---

## Option A — VM Linux distante (accès SSH)

Cette option concerne les stagiaires qui disposent d'une VM Linux
fournie par le formateur et d'un client SSH configuré à l'avance.

### Ce dont vous avez besoin

- L'adresse IP de votre VM (communiquée par le formateur)
- Votre nom d'utilisateur
- Votre fichier de clé privée (extension `.ppk` pour PuTTY, ou `.pem`/sans extension pour OpenSSH)

### Connexion avec PuTTY (Windows)

1. Ouvrir PuTTY.
2. Dans le champ **Host Name**, saisir l'adresse IP de votre VM.
3. Aller dans **Connection > SSH > Auth > Credentials** et charger votre clé privée.
4. Revenir dans **Session**, donner un nom dans **Saved Sessions**, puis cliquer **Save**.
5. Cliquer **Open** pour lancer la connexion.
6. À l'invite `login as:`, saisir votre nom d'utilisateur.

### Connexion avec le Terminal Windows (OpenSSH)

Si votre poste dispose de Windows 10 version 1809 ou supérieure,
OpenSSH est intégré. Ouvrir un terminal PowerShell ou Invite de
commandes, puis :

```powershell
ssh -i C:\chemin\vers\cle_privee utilisateur@ADRESSE_IP
```

### Vérification de la connexion

Une fois connecté, le prompt doit ressembler à :

```
utilisateur@debian-formation:~$
```

Taper les commandes suivantes pour confirmer que tout fonctionne :

```bash
whoami
hostname
cat /etc/os-release
```

### Premiers réglages recommandés

```bash
# Historique plus grand pour ne pas perdre les commandes précédentes
echo 'export HISTSIZE=5000' >> ~/.bashrc
echo 'alias ll="ls -la"' >> ~/.bashrc
source ~/.bashrc
```

---

## Option B — VM VirtualBox sur poste Windows

Cette option concerne les stagiaires qui travaillent sur un poste
Windows en salle, soumis au « freeze » (les applications installées
sont supprimées à chaque redémarrage). Vous travaillerez donc sur
le lecteur `D:\` qui, lui, est persistant.

### Prérequis

- Poste Windows 10 ou 11 avec au moins 4 Go de RAM et 25 Go libres sur `D:\`
- Virtualisation matérielle activée (VT-x ou AMD-V — généralement déjà activée)

### Étape 1 : Créer votre répertoire personnel sur D:\

```
D:\
+-- PrenomNOM\
    +-- VirtualBox\       (disque de la VM)
    +-- iso\              (image ISO Debian)
```

Dans l'Explorateur Windows, créer ce répertoire avant de commencer.
Tous vos fichiers de formation seront dans `D:\PrenomNOM\`.

### Étape 2 : Installer VirtualBox

1. Télécharger VirtualBox sur https://www.virtualbox.org (section
   « Windows hosts »).
2. Exécuter l'installateur et suivre l'assistant avec les options
   par défaut.
3. Redémarrer le poste si VirtualBox le demande.

> VirtualBox sera supprimé au prochain redémarrage du poste (freeze).
> Cependant, le disque de votre VM reste sur `D:\PrenomNOM\VirtualBox\`
> et sera réutilisable la semaine suivante après réinstallation de VirtualBox.

### Étape 3 : Télécharger l'image ISO Debian 13

1. Aller sur https://www.debian.org/distrib/
2. Choisir « Small CDs or USB sticks » puis l'image **amd64** (netinst).
3. Sauvegarder le fichier `.iso` dans `D:\PrenomNOM\iso\`.

> La taille de l'ISO netinst est d'environ 400 Mo. Si l'accès
> internet est lent en salle, le formateur peut vous fournir l'ISO
> sur une clé USB.

### Étape 4 : Créer la machine virtuelle

Dans VirtualBox, cliquer **Nouveau** et renseigner :

```
Nom      : FormationLinux
Dossier  : D:\PrenomNOM\VirtualBox\
Type     : Linux
Version  : Debian (64-bit)
RAM      : 2048 Mo
Disque   : Créer un disque VDI de 20 Go (allocation dynamique)
```

Avant de démarrer, ouvrir les **Paramètres** de la VM :

- **Système > Processeur** : mettre 2 CPU si le poste le permet.
- **Stockage** : cliquer sur le lecteur CD vide, puis l'icône de disque
  à droite et choisir « Choisir un fichier de disque » ; sélectionner
  l'ISO Debian.
- **Réseau** : laisser la carte en mode NAT (par défaut).

### Étape 5 : Installer Debian

Démarrer la VM. Choisir **Install** (installation en mode texte,
plus rapide et suffisante pour cette formation).

Paramètres recommandés pendant l'installation :

```
Langue              : Français
Pays                : France
Clavier             : Français (azerty)
Nom de machine      : debian-formation
Nom d'utilisateur   : votre prénom en minuscules
Mot de passe        : choisir quelque chose de simple à retenir
Partitionnement     : "Utiliser un disque entier" (option simple)
Sélection logiciels : décocher "Environnement de bureau GNOME",
                      garder "Utilitaires usuels du système" et
                      "Serveur SSH"
```

L'installation dure environ 15 à 20 minutes.

### Étape 6 : Premier démarrage

Après l'installation, la VM redémarrera sur Debian. Se connecter avec
le nom d'utilisateur et le mot de passe choisis.

Vérifier que le réseau fonctionne :

```bash
ping -c 3 debian.org
```

Mettre le système à jour :

```bash
su -
apt update && apt upgrade -y
exit
```

### Réutilisation d'une semaine sur l'autre

Au début de chaque séance :

1. Réinstaller VirtualBox (les installateurs peuvent être placés dans
   `D:\PrenomNOM\` pour éviter de les retélécharger).
2. Dans VirtualBox, cliquer **Ajouter** et pointer vers
   `D:\PrenomNOM\VirtualBox\FormationLinux\FormationLinux.vbox`.
3. Démarrer la VM : votre environnement est intact.

---

## Vérifier que tout fonctionne

Quelle que soit l'option choisie, exécuter les commandes suivantes
dans le terminal Linux :

```bash
# Vérifier l'identité
whoami

# Vérifier le répertoire de travail
pwd

# Vérifier la distribution
cat /etc/os-release

# Vérifier l'espace disque disponible
df -h /

# Vérifier la mémoire disponible
free -h
```

Redimensionner la fenêtre du terminal ou de PuTTY pour être à l'aise.
Un terminal de 80 colonnes minimum est recommandé.

---

## En cas de problème

### Option A (SSH) — Problèmes courants

**La connexion est refusée (« Connection refused » ou « Connection timed out »)**
Vérifier l'adresse IP communiquée par le formateur. Si le message est
« Connection timed out », la VM cible est peut-être éteinte ; prévenir
le formateur.

**« Permission denied (publickey) »**
La clé privée n'est pas celle attendue par le serveur, ou elle n'est
pas chargée dans PuTTY. Vérifier le chemin du fichier `.ppk` dans
PuTTY > Connection > SSH > Auth > Credentials.

**Le prompt ne s'affiche pas après la connexion**
Appuyer sur Entrée. Si le problème persiste, fermer et rouvrir la
session.

---

### Option B (VirtualBox) — Problèmes courants

**La VM ne démarre pas : « VT-x is not available »**
La virtualisation n'est pas activée dans le BIOS. Le formateur peut
activer cette option ; c'est une manipulation de quelques secondes
au démarrage du poste.

**L'installation de Debian se bloque sur « Configurer le réseau »**
Passer cette étape en choisissant « Ne pas configurer le réseau pour
l'instant ». Le réseau peut être configuré après l'installation en
passant en root puis en lançant `dhclient` :

```bash
su -
dhclient
```

**La VM est très lente**
Vérifier que le nombre de CPU est d'au moins 2 dans les paramètres
VirtualBox. Si d'autres VMs tournent sur le poste, les éteindre.

**Après le freeze, VirtualBox ne trouve plus la VM**
Utiliser **Ajouter** (pas **Nouveau**) et pointer vers le fichier
`.vbox` dans `D:\PrenomNOM\VirtualBox\FormationLinux\`.
