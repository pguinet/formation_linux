# Annexe -- Installer son environnement de travail

> Ce guide est un prerequis : la formation commence une fois
> l'environnement installe et fonctionnel.

---

## Option A -- VM Linux distante (acces SSH)

Cette option concerne les stagiaires qui disposent d'une VM Linux
fournie par le formateur et d'un client SSH configure a l'avance.

### Ce dont vous avez besoin

- L'adresse IP de votre VM (communiquee par le formateur)
- Votre nom d'utilisateur
- Votre fichier de cle privee (extension `.ppk` pour PuTTY, ou `.pem`/sans extension pour OpenSSH)

### Connexion avec PuTTY (Windows)

1. Ouvrir PuTTY.
2. Dans le champ **Host Name**, saisir l'adresse IP de votre VM.
3. Aller dans **Connection > SSH > Auth > Credentials** et charger votre cle privee.
4. Revenir dans **Session**, donner un nom dans **Saved Sessions**, puis cliquer **Save**.
5. Cliquer **Open** pour lancer la connexion.
6. A l'invite `login as:`, saisir votre nom d'utilisateur.

### Connexion avec le Terminal Windows (OpenSSH)

Si votre poste dispose de Windows 10 version 1809 ou superieure,
OpenSSH est integre. Ouvrir un terminal PowerShell ou Invite de
commandes, puis :

```bash
ssh -i C:\chemin\vers\cle_privee utilisateur@ADRESSE_IP
```

### Verification de la connexion

Une fois connecte, le prompt doit ressembler a :

```
utilisateur@debian-formation:~$
```

Taper les commandes suivantes pour confirmer que tout fonctionne :

```bash
whoami
hostname
cat /etc/os-release
```

### Premiers reglages recommandes

```bash
# Historique plus grand pour ne pas perdre les commandes precedentes
echo 'export HISTSIZE=5000' >> ~/.bashrc
echo 'alias ll="ls -la"' >> ~/.bashrc
source ~/.bashrc
```

---

## Option B -- VM VirtualBox sur poste Windows

Cette option concerne les stagiaires qui travaillent sur un poste
Windows en salle, soumis au "freeze" (les applications installees
sont supprimees a chaque redemarrage). Vous travaillerez donc sur
le lecteur `D:\` qui, lui, est persistant.

### Prerequis

- Poste Windows 10 ou 11 avec au moins 4 Go de RAM et 25 Go libres sur `D:\`
- Virtualisation materielle activee (VT-x ou AMD-V -- generalement deja active)

### Etape 1 : Creer votre repertoire personnel sur D:\

```
D:\
+-- PrenomNOM\
    +-- VirtualBox\       (disque de la VM)
    +-- iso\              (image ISO Debian)
```

Dans l'Explorateur Windows, creer ce repertoire avant de commencer.
Tous vos fichiers de formation seront dans `D:\PrenomNOM\`.

### Etape 2 : Installer VirtualBox

1. Telecharger VirtualBox sur https://www.virtualbox.org (section
   "Windows hosts").
2. Executer l'installateur et suivre l'assistant avec les options
   par defaut.
3. Redemarrer le poste si VirtualBox le demande.

> VirtualBox sera supprime au prochain redemarrage du poste (freeze).
> Cependant, le disque de votre VM reste sur `D:\PrenomNOM\VirtualBox\`
> et sera reutilisable la semaine suivante apres reinstallation de VirtualBox.

### Etape 3 : Telecharger l'image ISO Debian 13

1. Aller sur https://www.debian.org/distrib/
2. Choisir "Small CDs or USB sticks" puis l'image **amd64** (netinst).
3. Sauvegarder le fichier `.iso` dans `D:\PrenomNOM\iso\`.

> La taille de l'ISO netinst est d'environ 400 Mo. Si l'acces
> internet est lent en salle, le formateur peut vous fournir l'ISO
> sur une cle USB.

### Etape 4 : Creer la machine virtuelle

Dans VirtualBox, cliquer **Nouveau** et renseigner :

```
Nom      : FormationLinux
Dossier  : D:\PrenomNOM\VirtualBox\
Type     : Linux
Version  : Debian (64-bit)
RAM      : 2048 Mo
Disque   : Creer un disque VDI de 20 Go (allocation dynamique)
```

Avant de demarrer, ouvrir les **Parametres** de la VM :

- **Systeme > Processeur** : mettre 2 CPU si le poste le permet.
- **Stockage** : cliquer sur le lecteur CD vide, puis l'icone de disque
  a droite et choisir "Choisir un fichier de disque" ; selectionner
  l'ISO Debian.
- **Reseau** : laisser la carte en mode NAT (par defaut).

### Etape 5 : Installer Debian

Demarrer la VM. Choisir **Install** (installation en mode texte,
plus rapide et suffisante pour cette formation).

Parametres recommandes pendant l'installation :

```
Langue              : Francais
Pays                : France
Clavier             : Francais (azerty)
Nom de machine      : debian-formation
Nom d'utilisateur   : votre prenom en minuscules
Mot de passe        : choisir quelque chose de simple a retenir
Partitionnement     : "Utiliser un disque entier" (option simple)
Selection logiciels : decocher "Environnement de bureau GNOME",
                      garder "Utilitaires usuels du systeme" et
                      "Serveur SSH"
```

L'installation dure environ 15 a 20 minutes.

### Etape 6 : Premier demarrage

Apres l'installation, la VM redemarrera sur Debian. Se connecter avec
le nom d'utilisateur et le mot de passe choisis.

Verifier que le reseau fonctionne :

```bash
ping -c 3 debian.org
```

Mettre le systeme a jour :

```bash
su -
apt update && apt upgrade -y
exit
```

### Reutilisation d'une semaine sur l'autre

Au debut de chaque seance :

1. Reinstaller VirtualBox (les installateurs peuvent etre places dans
   `D:\PrenomNOM\` pour eviter de les retelecharger).
2. Dans VirtualBox, cliquer **Ajouter** et pointer vers
   `D:\PrenomNOM\VirtualBox\FormationLinux\FormationLinux.vbox`.
3. Demarrer la VM : votre environnement est intact.

---

## Verifier que tout fonctionne

Quelle que soit l'option choisie, executer les commandes suivantes
dans le terminal Linux :

```bash
# Verifier l'identite
whoami

# Verifier le repertoire de travail
pwd

# Verifier la distribution
cat /etc/os-release

# Verifier l'espace disque disponible
df -h /

# Verifier la memoire disponible
free -h
```

Redimensionner la fenetre du terminal ou de PuTTY pour etre a l'aise.
Un terminal de 80 colonnes minimum est recommande.

---

## En cas de probleme

### Option A (SSH) -- Problemes courants

**La connexion est refusee ("Connection refused" ou "Connection timed out")**
Verifier l'adresse IP communiquee par le formateur. Si le message est
"Connection timed out", la VM cible est peut-etre eteinte ; prevenir
le formateur.

**"Permission denied (publickey)"**
La cle privee n'est pas celle attendue par le serveur, ou elle n'est
pas chargee dans PuTTY. Verifier le chemin du fichier `.ppk` dans
PuTTY > Connection > SSH > Auth > Credentials.

**Le prompt ne s'affiche pas apres la connexion**
Appuyer sur Entree. Si le probleme persiste, fermer et rouvrir la
session.

---

### Option B (VirtualBox) -- Problemes courants

**La VM ne demarre pas : "VT-x is not available"**
La virtualisation n'est pas activee dans le BIOS. Le formateur peut
activer cette option ; c'est une manipulation de quelques secondes
au demarrage du poste.

**L'installation de Debian se bloque sur "Configurer le reseau"**
Passer cette etape en choisissant "Ne pas configurer le reseau pour
l'instant". Le reseau peut etre configure apres l'installation avec
`sudo dhclient`.

**La VM est tres lente**
Verifier que le nombre de CPU est d'au moins 2 dans les parametres
VirtualBox. Si d'autres VMs tournent sur le poste, les eteindre.

**Apres le freeze, VirtualBox ne trouve plus la VM**
Utiliser **Ajouter** (pas **Nouveau**) et pointer vers le fichier
`.vbox` dans `D:\PrenomNOM\VirtualBox\FormationLinux\`.
