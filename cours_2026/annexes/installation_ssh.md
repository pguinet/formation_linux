# Annexe — Se connecter à sa VM distante (SSH)

> Ce guide est un prérequis, réalisé hors séances : la formation commence
> une fois la connexion à votre VM établie et vérifiée.

Cette annexe concerne les stagiaires qui disposent d'une VM Linux
fournie par le formateur et d'un client SSH configuré à l'avance avec
une paire de clés. Aucune installation n'est nécessaire : il suffit de
se connecter à la VM depuis son poste Windows, avec PuTTY ou avec le
client OpenSSH intégré à Windows.

## Ce dont vous avez besoin

Le formateur vous communique trois éléments :

- l'adresse IP de votre VM ;
- votre nom d'utilisateur ;
- votre fichier de clé privée : extension `.ppk` pour PuTTY, extension
  `.pem` ou sans extension pour OpenSSH.

La clé privée est personnelle : ne la partagez pas et ne la déposez pas
dans un dossier accessible à d'autres personnes.

## Se connecter avec PuTTY

1. Ouvrir PuTTY.
2. Dans le champ **Host Name**, saisir l'adresse IP de votre VM.
3. Aller dans **Connection > SSH > Auth > Credentials** et charger votre
   clé privée (fichier `.ppk`).
4. Revenir dans **Session**, donner un nom dans **Saved Sessions**, puis
   cliquer sur **Save**. Les fois suivantes, il suffira de sélectionner
   cette session enregistrée et de cliquer sur **Load**.
5. Cliquer sur **Open** pour lancer la connexion.
6. À l'invite `login as:`, saisir votre nom d'utilisateur.

## Se connecter avec le Terminal Windows (OpenSSH)

Si votre poste dispose de Windows 10 version 1809 ou supérieure, le
client OpenSSH est intégré. Ouvrir un terminal PowerShell ou une Invite
de commandes, puis taper :

```powershell
ssh -i C:\chemin\vers\cle_privee utilisateur@ADRESSE_IP
```

Remplacer `C:\chemin\vers\cle_privee` par l'emplacement de votre fichier
de clé, `utilisateur` par votre nom d'utilisateur et `ADRESSE_IP` par
l'adresse de votre VM.

## Vérifier la connexion

Une fois connecté, le prompt (l'invite) doit ressembler à celui-ci,
avec votre nom d'utilisateur et le nom de votre VM, par exemple
`debian-formation` :

```
utilisateur@debian-formation:~$
```

Taper les commandes suivantes pour confirmer que vous êtes bien sur
votre VM :

```bash
whoami
hostname
cat /etc/os-release
```

`whoami` affiche votre nom d'utilisateur, `hostname` le nom de la
machine et `cat /etc/os-release` la distribution installée.

## Premiers réglages recommandés

Ces trois lignes agrandissent l'historique des commandes, créent le
raccourci `ll` (liste détaillée des fichiers) et rechargent la
configuration :

```bash
# Historique plus grand pour ne pas perdre les commandes précédentes
echo 'export HISTSIZE=5000' >> ~/.bashrc
echo 'alias ll="ls -la"' >> ~/.bashrc
source ~/.bashrc
```

Ces notions seront expliquées pendant la formation (voir chapitres 6.3
et 8.3) : pour l'instant, il suffit de recopier les commandes.

## Vérifier que tout fonctionne

Une fois la connexion vérifiée, exécuter ces dernières commandes dans
le terminal Linux :

```bash
pwd        # répertoire de travail
df -h /    # espace disque disponible
free -h    # mémoire disponible
```

Redimensionner la fenêtre du terminal ou de PuTTY pour être à l'aise.
Un terminal de 80 colonnes minimum est recommandé.

## Problèmes courants

**« Connection timed out »**

Vérifier l'adresse IP communiquée par le formateur. Si elle est
correcte, la VM est peut-être éteinte ou injoignable : prévenir le
formateur.

**« Connection refused »**

La VM répond, mais le service SSH n'y fonctionne pas (arrêté ou en
cours de démarrage). Patienter une minute et réessayer ; si le message
persiste, prévenir le formateur.

**« Permission denied (publickey) »**

La clé privée n'est pas celle attendue par le serveur, ou elle n'est
pas chargée. Avec PuTTY, vérifier le chemin du fichier `.ppk` dans
**Connection > SSH > Auth > Credentials**. Avec OpenSSH, vérifier le
chemin indiqué après l'option `-i`.

**« WARNING: UNPROTECTED PRIVATE KEY FILE! » (OpenSSH)**

OpenSSH refuse une clé privée lisible par d'autres comptes du poste
(dossier partagé, clé USB...). Ranger la clé dans le dossier `.ssh` de votre
profil Windows, `%USERPROFILE%\.ssh` (le créer s'il n'existe pas), et
indiquer ce nouveau chemin après l'option `-i`.

**Le prompt ne s'affiche pas après la connexion**

Appuyer sur Entrée. Si le problème persiste, fermer et rouvrir la
session.
