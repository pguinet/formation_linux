# Annexe — Installer Debian 13 dans VirtualBox

> Ce guide est un prérequis, réalisé hors séances : la formation commence
> une fois votre machine virtuelle Debian installée et vérifiée.

Cette annexe concerne les stagiaires qui travaillent sur un poste
Windows de la salle du CID. Vous allez installer Debian 13, avec son
bureau GNOME, dans une machine virtuelle (VM) VirtualBox.

Les postes du CID sont **figés** : le disque `C:` est remis à zéro à
chaque redémarrage. Tout ce qui est installé sur `C:`, VirtualBox
compris, disparaît donc d'une séance à l'autre. Le lecteur `D:`, lui,
est conservé : vous y rangez les installeurs et la VM.

Ce qui est fait **une seule fois**, lors de la première séance :

- télécharger les fichiers nécessaires dans votre dossier sur `D:` ;
- créer la VM et y installer Debian ;
- installer les Additions invité dans Debian.

Ce qui est refait **à chaque séance** : réinstaller VirtualBox, en
double-cliquant sur un script fourni, puis démarrer la VM. Comptez
quelques minutes.

## Prérequis matériels

- Un poste Windows 10 ou 11, 64 bits.
- Au moins 8 Go de mémoire vive : la VM en utilise 4 Go.
- Au moins 40 Go libres sur `D:` : environ 4 Go pour les fichiers
  téléchargés, et jusqu'à 30 Go pour le disque de la VM, qui grossit au
  fur et à mesure qu'il se remplit.
- La virtualisation matérielle activée (VT-x chez Intel, AMD-V chez
  AMD). C'est en général déjà le cas ; sinon, voir la section
  « Problèmes courants ».
- Un accès à Internet pour les téléchargements et les mises à jour.

## Préparer son dossier sur le lecteur D

Dans l'Explorateur Windows, créer un dossier à votre nom sur `D:`,
par exemple `D:\PrenomNOM`, avec deux sous-dossiers :

```
D:\
+-- PrenomNOM\
    +-- sources\          (installeurs, image de Debian, script)
    +-- VirtualBox\       (la machine virtuelle)
```

- `sources\` reçoit les cinq fichiers de la section suivante.
- `VirtualBox\` reçoit la VM : VirtualBox y crée un dossier
  `FormationLinux\`, qui contient le disque virtuel.

Dans la suite, remplacez `PrenomNOM` par le nom de votre dossier.

## Télécharger les fichiers

Télécharger les quatre fichiers suivants et les enregistrer dans
`D:\PrenomNOM\sources\` sans les renommer. Les versions ont été
vérifiées le 1er octobre 2026.

**1. Visual C++ Redistributable** (version 2015-2022 x64, 26 Mo) :
bibliothèques de Microsoft dont VirtualBox a besoin. VirtualBox 7.2 ne
les fournit plus : sans elles, il refuse de s'installer.

- Fichier : `VC_redist.x64.exe`
- Lien : <https://aka.ms/vs/17/release/vc_redist.x64.exe>

**2. VirtualBox** (version 7.2.20, 178 Mo) : le logiciel qui fait
fonctionner la VM.

- Fichier : `VirtualBox-7.2.20-175154-Win.exe`
- Lien : <https://download.virtualbox.org/virtualbox/7.2.20/VirtualBox-7.2.20-175154-Win.exe>

**3. Extension Pack** (version 7.2.20, 20 Mo) : un module officiel
d'Oracle qui complète VirtualBox. Le script l'installe avec le reste.

- Fichier : `Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack`
- Lien : <https://download.virtualbox.org/virtualbox/7.2.20/Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack>

**4. Image DVD de Debian** (version 13.7, 4,0 Go) : le disque
d'installation de Debian, sous forme de fichier. L'image DVD contient le
bureau GNOME : l'installation dépend peu de la vitesse du réseau.

- Fichier : `debian-13.7.0-amd64-DVD-1.iso`
- Lien : <https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-13.7.0-amd64-DVD-1.iso>

Le lien de Debian contient `current` : il change à chaque nouvelle
version mineure (13.8, 13.9...). S'il ne fonctionne plus, ouvrir la
page d'index et prendre le fichier `debian-13.x.0-amd64-DVD-1.iso` le
plus récent :

<https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/>

### Vérifier les fichiers téléchargés

Un fichier mal téléchargé provoque des erreurs difficiles à comprendre.
On vérifie donc son **empreinte SHA256** : une suite de 64 caractères
calculée à partir du contenu du fichier. Si un seul octet diffère,
l'empreinte change complètement.

Ouvrir une Invite de commandes (menu Démarrer, taper `cmd`), puis :

```
cd /d D:\PrenomNOM\sources
certutil -hashfile debian-13.7.0-amd64-DVD-1.iso SHA256
```

Comparer la ligne affichée avec l'empreinte publiée, ci-dessous sous
le nom de chaque fichier :

```
VirtualBox-7.2.20-175154-Win.exe
a81777d2b36380ce042a29e9c554cf032eb46a793f62e3cc82e7411e535c2c26

Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack
0a050da993f2e3cf2e4e9cda2fa8667e44a2b25479b27abd41af6812c1e43591

debian-13.7.0-amd64-DVD-1.iso
347b6c67a3cc0b7ddb60b178f683470c4e2b7ac426c996d9337a2ff36c1a32d2
```

Faire de même pour les deux fichiers de VirtualBox, en remplaçant le
nom du fichier dans la commande `certutil`. Pour l'image de Debian, le
calcul peut prendre une minute. Si l'empreinte ne correspond pas,
supprimer le fichier et le télécharger à nouveau.

`VC_redist.x64.exe` n'a pas d'empreinte ici : le lien de Microsoft
donne toujours la dernière version, dont l'empreinte change à chaque
mise à jour.

### Récupérer le script d'installation

Le script `installer_virtualbox.bat` réinstalle VirtualBox en une seule
opération. Il est disponible à cette adresse :

<https://raw.githubusercontent.com/pguinet/formation_linux/master/ressources/scripts/installer_virtualbox.bat>

Depuis une page web qui contient ce lien, faire un clic droit sur le
lien, puis **Enregistrer le lien sous** et choisir le dossier
`D:\PrenomNOM\sources\`. Si le lien s'ouvre directement dans le
navigateur (du texte s'affiche), utiliser **Ctrl+S** pour enregistrer
la page. Dans les deux cas, vérifier que le fichier s'appelle bien
`installer_virtualbox.bat`, et non `installer_virtualbox.bat.txt`.

Son contenu intégral est reproduit à la fin de ce document. Il :

- retrouve les trois installeurs dans `sources\`, quelle que soit leur
  version, et s'arrête avec un message clair s'il en manque un ;
- installe Visual C++, VirtualBox et l'Extension Pack sans poser de
  question ;
- indique à VirtualBox que les machines virtuelles sont rangées dans
  `D:\PrenomNOM\VirtualBox\` ;
- réenregistre la VM `FormationLinux` si elle existe déjà ;
- affiche un résumé de chaque étape.

À la fin, `sources\` contient cinq fichiers : les quatre téléchargements
et le script.

## Première séance : installer VirtualBox

Double-cliquer sur `installer_virtualbox.bat` dans `D:\PrenomNOM\sources\`.
Une fenêtre noire s'ouvre et affiche la progression. Si Windows demande
une autorisation, répondre **Oui**.

L'installation de VirtualBox prend une à trois minutes. À la fin, le
script affiche un résumé. Lors de la première séance, la ligne
« Machine virtuelle » indique `pas encore de VM` : c'est normal. Appuyer
sur une touche pour fermer la fenêtre.

Lancer ensuite **Oracle VirtualBox** depuis le menu Démarrer.

> Les captures de VirtualBox de ce document ont été réalisées sous
> Linux : les chemins y commencent par `/mnt/D/PrenomNOM`. Sur votre
> poste, ils commencent par `D:\PrenomNOM`. Certains libellés de
> VirtualBox 7.2.20 ne sont pas traduits en français (« VM Name »,
> « Finish »...) : ils sont cités tels quels.

Au premier lancement, VirtualBox propose deux modes d'affichage.
Cliquer sur **Basic Mode** : l'interface simplifiée suffit pour la
formation.

![Premier lancement : choisir Basic Mode](../../ressources/images/installation/vbox-01-premier-lancement.png)

Le profil Windows étant remis à zéro, cette question reviendra à chaque
séance : répondre de la même façon.

## Première séance : créer la machine virtuelle

Cliquer sur **Nouvelle** dans la barre d'outils. L'assistant « New
Virtual Machine » s'ouvre.

### Nom, dossier et image de Debian

Remplir la première page :

- **VM Name** : `FormationLinux`. Le script retrouve la VM grâce à ce
  nom : le recopier exactement.
- **VM Folder** : `D:\PrenomNOM\VirtualBox`. Le champ est normalement
  déjà rempli grâce au script ; sinon, le choisir dans la liste.
- **ISO Image** : ouvrir la liste déroulante du champ, choisir
  **Autre...**, puis sélectionner
  `D:\PrenomNOM\sources\debian-13.7.0-amd64-DVD-1.iso`.

VirtualBox reconnaît alors Debian 13 Trixie (64-bit) et remplit seul
les champs OS, OS Distribution et OS Version.

Il coche aussi la case **Proceed with Unattended Installation**
(installation sans surveillance) : **la décocher**. On veut l'installeur
classique de Debian, décrit pas à pas dans ce document.

![Page 1 de l'assistant : installation sans surveillance décochée](../../ressources/images/installation/vbox-08-nouvelle-machine-sans-surveillance-decochee.png)

Cliquer sur **Suivant**.

### Matériel virtuel

- **Base Memory** : `4096` Mo, soit 4 Go de mémoire pour la VM.
- **Number of CPUs** : `2`, pour que le bureau reste fluide.
- **Disk Size** : `30 Gio`. Le disque est créé au format VDI et
  « dynamique » : il n'occupe sur `D:` que la place réellement utilisée.
- **Use EFI** : laisser décoché.

![Page 2 : mémoire, processeurs et disque](../../ressources/images/installation/vbox-09-nouvelle-machine-materiel.png)

Cliquer sur **Suivant**. Le récapitulatif doit indiquer
`Proceed with Unattended Installation : false`, 4096 Mo de mémoire,
2 processeurs et un disque de 30 Gio.

![Récapitulatif avant création](../../ressources/images/installation/vbox-10-nouvelle-machine-recapitulatif.png)

Cliquer sur **Finish**. La VM `FormationLinux` apparaît dans la liste,
à l'état « Éteinte ».

### Réseau en accès par pont

Par défaut, la VM est en mode « NAT » : elle accède à Internet, mais
reste invisible depuis le reste du réseau. On choisit plutôt l'**accès
par pont** : la VM obtient sa propre adresse sur le réseau du CID, comme
un poste de plus. On pourra ainsi s'y connecter en SSH depuis Windows.

1. Sélectionner `FormationLinux` et cliquer sur **Configuration**.
2. Dans la colonne de gauche, choisir **Réseau**.
3. Dans **Attached to**, choisir **Accès par pont**.
4. Dans **Name**, choisir la carte Ethernet du poste (la carte filaire,
   pas une carte Wi-Fi).
5. Cliquer sur **OK**.

![Configuration > Réseau : accès par pont](../../ressources/images/installation/vbox-12-configuration-reseau-pont.png)

Sur la capture, la carte s'appelle `eth0` (nom Linux) ; sous Windows,
la liste affiche le nom de la carte réseau du poste.

Les détails de la VM résument maintenant sa configuration : 4096 Mo,
2 processeurs, l'image de Debian dans le lecteur optique, le disque de
30 Gio et la ligne Réseau en « Interface pont ».

![La machine virtuelle prête à démarrer](../../ressources/images/installation/vbox-14-machine-configuree.png)

Cliquer sur **Démarrer** : une nouvelle fenêtre s'ouvre, l'écran de la
VM.

> Quand vous cliquez dans la fenêtre de la VM, le clavier et la souris
> lui sont réservés. Pour les rendre à Windows, appuyer sur la touche
> **Ctrl de droite** (la « touche hôte » de VirtualBox).

## Première séance : installer Debian

L'installeur de Debian démarre sur l'image DVD. Il se pilote à la
souris ou au clavier : **Entrée** valide, les flèches déplacent la
sélection, **Tab** passe d'un champ à l'autre. Le bouton **Continuer**
fait passer à l'écran suivant ; **Revenir en arrière** permet de
corriger une réponse.

Les captures de l'installeur ont été réalisées dans un autre logiciel
de virtualisation (QEMU) : le disque y apparaît sous le nom
« ATA QEMU HARDDISK ». Dans VirtualBox, il s'appellera « ATA VBOX
HARDDISK ». Le reste est identique.

### Menu de démarrage

Choisir **Graphical install** (installation graphique) et appuyer sur
Entrée.

![Menu de démarrage du DVD](../../ressources/images/installation/debian-01-menu-demarrage.png)

### Langue, pays et clavier

**Langue** : choisir **French - Français**. Ce premier écran est encore
en anglais ; les suivants seront en français.

![Choix de la langue](../../ressources/images/installation/debian-02-langue.png)

**Pays** : choisir **France**. Ce choix règle aussi le fuseau horaire
(Europe/Paris) : l'installeur ne le demandera pas.

![Choix du pays](../../ressources/images/installation/debian-03-pays.png)

**Clavier** : choisir **Français**, la disposition AZERTY des postes
du CID.

![Disposition du clavier](../../ressources/images/installation/debian-04-clavier.png)

L'installeur charge ensuite ses composants et configure le réseau seul :
grâce à l'accès par pont, la VM reçoit une adresse du réseau du CID.

### Nom de la machine

**Nom de machine** : `debian-formation`. C'est le nom qui apparaîtra
dans l'invite du terminal (`cid@debian-formation`).

![Nom de la machine](../../ressources/images/installation/debian-05-nom-machine.png)

**Domaine** : laisser le champ vide et continuer. Il ne sert que dans un
réseau d'entreprise organisé en domaine.

### Comptes et mots de passe

**Mot de passe du superutilisateur (root)** : `cid`, saisi deux fois.
Le compte root est l'administrateur du système (voir chapitre 5.1). Un
mot de passe aussi simple ne convient qu'à une VM de formation.

![Mot de passe de root](../../ressources/images/installation/debian-07-mot-de-passe-root.png)

**Nom complet du nouvel utilisateur** : `cid`. C'est le compte que vous
utiliserez au quotidien.

![Nom complet de l'utilisateur](../../ressources/images/installation/debian-08-nom-complet.png)

**Identifiant** : l'installeur propose `cid` ; le garder et continuer.

**Mot de passe de l'utilisateur** : `cid`, saisi deux fois.

![Mot de passe de l'utilisateur cid](../../ressources/images/installation/debian-10-mot-de-passe-utilisateur.png)

### Partitionnement du disque

Le partitionnement découpe le disque en zones (partitions). La VM
n'ayant qu'un disque, vide, on laisse l'installeur faire.

**Méthode** : **Assisté - utiliser un disque entier**.

![Méthode de partitionnement](../../ressources/images/installation/debian-11-partitionnement-methode.png)

**Disque** : il n'y en a qu'un, de 32,2 Go (les 30 Gio de VirtualBox,
comptés autrement) ; le sélectionner. Seul le disque virtuel est
effacé : vos fichiers Windows ne risquent rien.

![Choix du disque](../../ressources/images/installation/debian-12-partitionnement-disque.png)

**Schéma** : **Tout dans une seule partition (recommandé pour les
débutants)**.

![Schéma de partitionnement](../../ressources/images/installation/debian-13-partitionnement-schema.png)

L'installeur affiche le résultat : une grande partition `ext4` montée
sur `/`, et une petite partition d'échange (`swap`). Choisir
**Terminer le partitionnement et appliquer les changements**.

![Résumé du partitionnement](../../ressources/images/installation/debian-14-partitionnement-resume.png)

À la question « Faut-il appliquer les changements sur les disques ? »,
choisir **Oui**, puis **Continuer**.

![Confirmation de l'écriture sur le disque](../../ressources/images/installation/debian-15-partitionnement-confirmation.png)

L'installeur copie alors le système de base : quelques minutes.

### Gestionnaire de paquets

**Analyser d'autres supports** : **Non**. Il n'y a qu'un DVD.

![Analyse d'autres supports](../../ressources/images/installation/debian-17-autres-supports.png)

**Utiliser un miroir sur le réseau** : **Oui**. Un miroir est un
serveur qui distribue les logiciels de Debian. Le DVD suffit pour
l'installation, mais le miroir apporte les mises à jour de sécurité.

![Utilisation d'un miroir réseau](../../ressources/images/installation/debian-18-miroir-reseau.png)

**Pays du miroir** : **France**. **Miroir** : garder **deb.debian.org**,
proposé en premier.

![Choix du miroir](../../ressources/images/installation/debian-20-miroir-choix.png)

**Mandataire HTTP** (proxy) : laisser vide et continuer, sauf consigne
contraire du formateur.

### Enquête de popularité

**Participer à l'étude statistique** : **Non**. Ce service envoie
chaque semaine à Debian la liste des logiciels utilisés : inutile pour
une VM de formation.

![Enquête de popularité des paquets](../../ressources/images/installation/debian-22-popularite.png)

### Sélection des logiciels

C'est l'écran le plus important. Cocher (avec la souris ou la barre
d'espace) **exactement** :

- **environnement de bureau Debian** : l'interface graphique ;
- **... GNOME** : le bureau utilisé pendant la formation ;
- **serveur SSH** : pour se connecter à la VM depuis Windows ;
- **utilitaires usuels du système** : les commandes de base.

Toutes les autres cases restent vides.

![Sélection des logiciels](../../ressources/images/installation/debian-23-logiciels.png)

Cliquer sur **Continuer**. L'installation des logiciels est l'étape la
plus longue : de 10 à 30 minutes selon le poste et le réseau.

### Programme de démarrage

**Installer GRUB sur le disque principal** : **Oui**. GRUB est le
programme qui démarre Debian quand on allume la VM.

![Installation de GRUB](../../ressources/images/installation/debian-25-grub.png)

**Périphérique** : choisir **/dev/sda**, le disque de la VM (et non
« Choix manuel du périphérique »).

![Disque où installer GRUB](../../ressources/images/installation/debian-26-grub-disque.png)

### Fin de l'installation

L'installation est terminée. Cliquer sur **Continuer** : la VM
redémarre. L'installeur éjecte normalement le DVD virtuel ; s'il
réapparaît au redémarrage, voir « Problèmes courants ».

![Fin de l'installation](../../ressources/images/installation/debian-27-fin-installation.png)

## Première séance : premier démarrage

Le menu de GRUB s'affiche quelques secondes, puis lance **Debian
GNU/Linux** tout seul.

![Menu de GRUB au démarrage](../../ressources/images/installation/debian-28-menu-grub.png)

L'écran de connexion de GNOME apparaît. Cliquer sur **cid**, saisir le
mot de passe `cid`, puis Entrée.

![Écran de connexion](../../ressources/images/installation/debian-29-connexion.png)

À la première connexion, une fenêtre « Bienvenue dans Debian
GNU/Linux 13 (trixie) » propose une visite guidée : cliquer sur
**Passer**.

![Fenêtre de bienvenue : cliquer sur Passer](../../ressources/images/installation/debian-31-bienvenue.png)

### Ouvrir un terminal

Le terminal est la fenêtre où l'on tape les commandes. Pour l'ouvrir :
appuyer sur la touche **Windows** (ou cliquer sur **Activités**, en
haut à gauche), taper `terminal`, puis cliquer sur **Terminal**.

![Recherche de l'application Terminal](../../ressources/images/installation/debian-33-recherche-terminal.png)

L'invite `cid@debian-formation:~$` indique que le terminal attend une
commande.

![Le terminal ouvert](../../ressources/images/installation/debian-34-terminal.png)

### Donner les droits d'administration à cid et mettre à jour

Le compte `cid` ne peut pas encore administrer le système. On l'ajoute
au groupe `sudo`, ce qui lui permettra d'utiliser la commande `sudo`
(voir chapitre 5.3). On en profite pour mettre le système à jour, puis
on redémarre. Taper, ligne par ligne :

```bash
su -
apt install -y sudo
usermod -aG sudo cid
apt update
apt upgrade -y
systemctl reboot
```

- `su -` ouvre une session root : saisir le mot de passe de root
  (`cid`). Rien ne s'affiche pendant la saisie : c'est normal.
- `apt install -y sudo` installe la commande `sudo` si elle manque
  (le plus souvent, elle est déjà là).
- `usermod -aG sudo cid` ajoute `cid` au groupe `sudo`.
- `apt update` récupère la liste des mises à jour, `apt upgrade -y` les
  installe.
- `systemctl reboot` redémarre la VM.

Pourquoi redémarrer ? L'ajout à un groupe ne prend effet qu'à
l'ouverture d'une nouvelle session, et sous GNOME une simple
déconnexion ne suffit pas toujours. Le redémarrage règle aussi le cas
d'un nouveau noyau Linux installé par la mise à jour.

Au retour, se reconnecter avec `cid`, rouvrir un terminal et vérifier :

```bash
groups
sudo apt update
```

La liste affichée par `groups` doit contenir `sudo`. `sudo` demande le
mot de passe de `cid` (`cid`), puis `apt update` doit se terminer sans
erreur.

### Installer les Additions invité

Les **Additions invité** sont des pilotes fournis par VirtualBox. Elles
adaptent l'affichage à la taille de la fenêtre et rendent la souris et
la VM plus fluides. Elles s'installent **une seule fois** : elles restent
sur le disque de la VM.

**1. Installer les outils de compilation.** Les Additions doivent être
compilées pour le noyau Linux :

```bash
sudo apt install -y build-essential linux-headers-amd64 bzip2
```

`build-essential` fournit le compilateur, `linux-headers-amd64` les
fichiers du noyau et `bzip2` l'outil qui décompresse l'archive des
Additions. `linux-headers-amd64` est un « méta-paquet » : il suit les
mises à jour du noyau, et les fichiers restent donc à jour pour chaque
nouveau noyau.

**2. Insérer le CD des Additions.** Dans le menu de la fenêtre de la VM,
choisir **Périphériques > Insérer l'image CD des Additions invité...**.
Un CD virtuel apparaît dans Debian. Si GNOME propose de lancer un
logiciel du CD, refuser : on l'installe à la main ci-dessous.

**3. Trouver le CD.** Sous GNOME, le CD est en général monté dans
`/media/cid/VBox_GAs_7.2.20` (le nom suit la version de VirtualBox).
Pour le vérifier, ouvrir l'application **Fichiers** : le CD apparaît
dans la colonne de gauche. On peut aussi taper :

```bash
ls /media/cid/
```

Si cette commande n'affiche rien, le CD n'est pas monté : le monter
soi-même dans `/mnt`, et utiliser `/mnt` à l'étape suivante.

```bash
sudo mount /dev/sr0 /mnt
```

Le message `WARNING: source write-protected, mounted read-only` est
normal : un CD est toujours en lecture seule.

**4. Lancer l'installation**, en adaptant le chemin si besoin :

```bash
sudo sh /media/cid/VBox_GAs_7.2.20/VBoxLinuxAdditions.run
```

L'installation dure une à deux minutes et se termine sans message
d'erreur. Redémarrer :

```bash
sudo reboot
```

Après le redémarrage, l'affichage de Debian suit la taille de la
fenêtre de la VM. Le CD des Additions peut être éjecté depuis
l'application Fichiers.

## Séances suivantes

Au début de chaque séance, le poste a été remis à zéro : VirtualBox a
disparu, mais votre VM est intacte sur `D:`.

1. Double-cliquer sur `D:\PrenomNOM\sources\installer_virtualbox.bat`.
   Si Windows demande une autorisation, répondre **Oui**.
2. Attendre le résumé. La ligne « Machine virtuelle » doit indiquer
   `OK (VM reenregistree)` ou `OK (VM deja enregistree)` ; appuyer sur
   une touche.
3. Lancer **Oracle VirtualBox** depuis le menu Démarrer et choisir
   **Basic Mode**.
4. Sélectionner `FormationLinux` et cliquer sur **Démarrer**.

Si le résumé signale une erreur, lire le message affiché au-dessus :
il indique la cause et la marche à suivre. En cas de doute, appliquer la
procédure manuelle ci-dessous.

### Procédure manuelle de secours

Si le script ne fonctionne pas, faire ses étapes à la main, dans cet
ordre.

**1. Visual C++.** Double-cliquer sur `VC_redist.x64.exe`, accepter la
licence et cliquer sur **Installer**.

**2. VirtualBox.** Double-cliquer sur `VirtualBox-7.2.20-175154-Win.exe`
et garder les choix proposés. L'installeur prévient que la connexion
réseau sera brièvement coupée : accepter. Si Windows demande une
autorisation, répondre **Oui**.

**3. Extension Pack.** Lancer VirtualBox, puis menu **Fichier > Outils >
Extensions** (ou Ctrl+T) et cliquer sur **Install**. Sélectionner
`Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack`. Un
double-clic sur ce fichier dans l'Explorateur mène au même écran.
VirtualBox demande une confirmation : cliquer sur **Installation**.

![Confirmation de l'installation de l'Extension Pack](../../ressources/images/installation/vbox-03-extension-confirmation.png)

La licence s'affiche ensuite. Le bouton **J'accepte** ne devient actif
qu'une fois le texte parcouru jusqu'en bas : faire défiler, puis
cliquer sur **J'accepte**.

![Licence de l'Extension Pack, lue jusqu'au bout](../../ressources/images/installation/vbox-05-extension-licence-fin.png)

L'Extension Pack apparaît alors dans la liste, coché comme actif.

![Extension Pack installé](../../ressources/images/installation/vbox-06-extension-installee.png)

**4. Dossier des machines.** Menu **Fichier > Paramètres**, rubrique
**Général** : choisir `D:\PrenomNOM\VirtualBox` comme dossier par
défaut des machines, puis **OK**.

**5. Retrouver la VM.** Cliquer sur **Open** dans la barre d'outils
(selon les versions : menu **Machine > Ajouter...**) et sélectionner le
fichier :

```
D:\PrenomNOM\VirtualBox\FormationLinux\FormationLinux.vbox
```

Attention : utiliser **Open** (ou **Ajouter**), jamais **Nouvelle**.
**Nouvelle** créerait une deuxième VM, vide.

## Vérifier que tout fonctionne

Dans un terminal de la VM, exécuter les commandes suivantes :

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

# Vérifier l'accès à Internet
ping -c 3 debian.org
```

`whoami` doit afficher `cid`, `cat /etc/os-release` mentionner Debian
GNU/Linux 13 (trixie), et `ping` recevoir trois réponses. Certains
réseaux bloquent `ping` : dans ce cas, vérifier plutôt l'accès à
Internet avec `sudo apt update`, qui doit se terminer sans erreur.

### Se connecter à la VM en SSH depuis Windows

Grâce à l'accès par pont, la VM a sa propre adresse sur le réseau du
CID. On peut donc travailler depuis Windows, dans un terminal SSH, la VM
restant ouverte à côté.

**1. Trouver l'adresse de la VM.** Dans un terminal de la VM :

```bash
ip a
```

Repérer la carte réseau autre que `lo` (souvent `enp0s3`) et la ligne
`inet` qui la suit : l'adresse est le nombre qui suit `inet`, sans la
partie `/24` (par exemple `192.168.1.42`).

**2. Se connecter depuis Windows.** Ouvrir un terminal PowerShell ou une
Invite de commandes et taper, en remplaçant `ADRESSE` :

```powershell
ssh cid@ADRESSE
```

À la première connexion, SSH demande s'il faut faire confiance à cette
machine : taper `yes`, puis Entrée. Saisir ensuite le mot de passe
`cid`. L'invite `cid@debian-formation:~$` confirme la connexion ;
`exit` la ferme.

L'adresse peut changer d'une séance à l'autre : la vérifier avec `ip a`
à chaque fois.

## Problèmes courants

**VirtualBox refuse de s'installer et réclame Visual C++**

Le Visual C++ Redistributable n'est pas installé. Vérifier que
`VC_redist.x64.exe` est bien dans `sources\`, puis relancer le script,
ou l'installer à la main (procédure manuelle, étape 1).

**La VM ne démarre pas : « VT-x is not available » (ou AMD-V)**

La virtualisation matérielle est désactivée dans le BIOS du poste.
Prévenir le formateur : l'option s'active au démarrage du poste, en
quelques secondes.

**La VM n'a pas de réseau (pas d'adresse, `ping` échoue)**

En accès par pont, la VM utilise la carte choisie dans **Name**. Si
c'est une carte inactive (Wi-Fi, carte virtuelle), elle n'obtient pas
d'adresse. Éteindre la VM, ouvrir **Configuration > Réseau** et choisir
la carte Ethernet du poste. Si le problème persiste, prévenir le
formateur. En dépannage, le mode **NAT** donne accès à Internet, mais
la connexion SSH depuis Windows ne fonctionne plus.

**L'installeur de Debian réapparaît au redémarrage**

Le DVD virtuel est resté dans le lecteur. Éteindre la VM, puis dans
**Configuration > Stockage**, sélectionner le lecteur optique et retirer
le disque. Redémarrer la VM.

**La VM est très lente**

Vérifier dans **Configuration > System > Processeur** que **Number of
CPUs** vaut 2, et que les Additions invité sont installées. Fermer les
applications Windows inutiles.

![Configuration > System > Processeur : 2 processeurs](../../ressources/images/installation/vbox-13-configuration-processeur.png)

**Après le freeze, VirtualBox ne trouve plus la VM**

Relancer le script : il réenregistre la VM. Sinon, utiliser **Open**
(pas **Nouvelle**) et choisir
`D:\PrenomNOM\VirtualBox\FormationLinux\FormationLinux.vbox`.

**Le clavier est en QWERTY dans Debian**

Une autre disposition a été choisie pendant l'installation. Dans GNOME,
ouvrir **Paramètres > Clavier**, ajouter la source de saisie
**Français** et supprimer les autres.

**La souris reste prisonnière de la VM**

Appuyer sur la touche **Ctrl de droite** pour rendre le clavier et la
souris à Windows.

**Windows bloque le script téléchargé**

Windows se méfie parfois des fichiers venus d'Internet et affiche
« Windows a protégé votre ordinateur ». Cliquer sur **Informations
complémentaires**, puis **Exécuter quand même**.

## Contenu du script installer_virtualbox.bat

Voici le contenu intégral du script, tel qu'il est publié sur GitHub.
Les messages sont volontairement sans accents : c'est la forme qui
s'affiche correctement dans la fenêtre noire de Windows.

```
@echo off
rem ======================================================================
rem  installer_virtualbox.bat -- Formation Linux (CID)
rem
rem  Reinstalle VirtualBox sur un poste "fige" (C: remis a zero a chaque
rem  redemarrage) et retrouve la VM conservee sur D:.
rem
rem  Utilisation :
rem    1. Placer ce fichier dans D:\PrenomNOM\sources\ avec :
rem         VC_redist.x64.exe
rem         VirtualBox-<version>-<build>-Win.exe
rem         Oracle_VirtualBox_Extension_Pack-<version>.vbox-extpack
rem    2. Double-cliquer sur le fichier. Si Windows demande une
rem       autorisation, repondre Oui.
rem
rem  Le script :
rem    - installe Visual C++ 2015-2022 x64, VirtualBox et l'Extension Pack
rem      en silencieux ;
rem    - regle le dossier des machines sur D:\PrenomNOM\VirtualBox ;
rem    - reenregistre la VM FormationLinux si elle existe deja.
rem
rem  Les messages sont volontairement sans accents : cmd.exe affiche les
rem  fichiers .bat dans la page de code OEM (850), et "chcp 65001" est
rem  source de bugs d'analyse des scripts sur certaines versions de
rem  Windows. L'ASCII pur fonctionne partout.
rem
rem  Precautions cmd.exe suivies dans ce fichier : aucune variable n'est
rem  modifiee puis lue dans un meme bloc entre parentheses (pas besoin de
rem  "delayed expansion"), les chemins sont toujours entre guillemets, et
rem  les codes retour sont recopies dans RC juste apres chaque commande.
rem ======================================================================

setlocal EnableExtensions
title Installation de VirtualBox - Formation Linux

rem ----------------------------------------------------------------------
rem  Parametres
rem ----------------------------------------------------------------------

rem Hash de la licence de l'Extension Pack (SHA256 du fichier de licence,
rem releve pour la version 7.2.20). Si Oracle change la licence, ce hash
rem change et l'installation silencieuse du pack echoue : le script
rem affiche alors la commande a lancer a la main.
set "LICENCE_EXTPACK=eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae"

rem Nom de la VM et emplacement de VBoxManage (dossier d'installation
rem par defaut de VirtualBox).
set "NOM_VM=FormationLinux"
set "VBOXMANAGE=%ProgramFiles%\Oracle\VirtualBox\VBoxManage.exe"

rem Dossier du script (D:\PrenomNOM\sources\, avec la barre finale)
rem et dossier parent (D:\PrenomNOM).
set "SOURCES=%~dp0"
for %%I in ("%~dp0..") do set "BASE=%%~fI"
set "DOSSIER_VMS=%BASE%\VirtualBox"
set "FICHIER_VM=%DOSSIER_VMS%\%NOM_VM%\%NOM_VM%.vbox"
set "JOURNAL=%SOURCES%installation_virtualbox.log"

rem Etat de chaque etape, affiche dans le resume final.
set "ETAT_VCREDIST=non fait"
set "ETAT_VIRTUALBOX=non fait"
set "ETAT_EXTPACK=non fait"
set "ETAT_DOSSIER=non fait"
set "ETAT_VM=non fait"
set "AVERTISSEMENTS=0"

echo ======================================================================
echo   Installation de VirtualBox - Formation Linux
echo ======================================================================
echo.
echo Dossier des installeurs : %SOURCES%
echo Dossier des machines    : %DOSSIER_VMS%
echo.

rem ----------------------------------------------------------------------
rem  Etape 1 : recherche des installeurs par motif
rem  (le script ne depend pas des numeros de version)
rem ----------------------------------------------------------------------

rem Le script n'a pas besoin d'etre lance en administrateur : chaque
rem installeur demande lui-meme l'autorisation. Lance en administrateur
rem (souvent un autre compte), il reglerait le profil de ce compte et non
rem celui du stagiaire : simple avertissement, non bloquant.
net session >nul 2>&1
if not errorlevel 1 echo [ATTENTION] Inutile de lancer en administrateur : un double-clic suffit.
if not errorlevel 1 echo.

echo Recherche des installeurs dans %SOURCES%
call :trouver FICHIER_VCREDIST "VC_redist.x64*.exe"
call :trouver FICHIER_VIRTUALBOX "VirtualBox-*-Win.exe"
call :trouver FICHIER_EXTPACK "Oracle_VirtualBox_Extension_Pack-*.vbox-extpack"

if not defined FICHIER_VCREDIST goto erreur_fichiers
if not defined FICHIER_VIRTUALBOX goto erreur_fichiers
if not defined FICHIER_EXTPACK goto erreur_fichiers
echo.

rem ----------------------------------------------------------------------
rem  Etape 2 : Microsoft Visual C++ Redistributable (requis par VirtualBox)
rem  Codes retour acceptes : 0 = installe, 1638 = version plus recente deja
rem  presente, 3010 = installe, redemarrage demande (on ne redemarre pas :
rem  le poste fige perdrait tout).
rem
rem  Les installeurs sont lances avec start /wait (et non directement) :
rem  start passe par l'explorateur de Windows, qui affiche lui-meme la
rem  demande d'autorisation si l'installeur en a besoin. Lance directement
rem  depuis cmd, il echouerait avec le code 740 (elevation requise).
rem  start /wait attend la fin de l'installeur et recupere son code retour.
rem  Codes 740 et 1223 : autorisation impossible ou refusee ; 1602 :
rem  installation annulee (VC++). Code 1618 : une autre installation
rem  Windows est deja en cours.
rem ----------------------------------------------------------------------

echo [1/5] Installation de Visual C++ Redistributable...
start "" /wait "%FICHIER_VCREDIST%" /install /quiet /norestart
set "RC=%ERRORLEVEL%"
if "%RC%"=="740" goto vcredist_autorisation
if "%RC%"=="1223" goto vcredist_autorisation
if "%RC%"=="1602" goto vcredist_autorisation
if "%RC%"=="1618" goto vcredist_occupe
if "%RC%"=="0" set "ETAT_VCREDIST=OK"
if "%RC%"=="1638" set "ETAT_VCREDIST=OK (deja present)"
if "%RC%"=="3010" set "ETAT_VCREDIST=OK"
if "%ETAT_VCREDIST%"=="non fait" goto erreur_vcredist
echo       %ETAT_VCREDIST%
echo.

rem ----------------------------------------------------------------------
rem  Etape 3 : VirtualBox
rem  --silent        : installation sans fenetre ni question ;
rem  --ignore-reboot : renvoie 0 meme si Windows demande un redemarrage ;
rem  --msi-log-file  : journal detaille, garde sur D: en cas de probleme.
rem  Si VBoxManage existe deja (script relance dans la meme session),
rem  l'installation est sautee.
rem ----------------------------------------------------------------------

echo [2/5] Installation de VirtualBox (1 a 3 minutes, patienter)...
if exist "%VBOXMANAGE%" goto virtualbox_deja_la
start "" /wait "%FICHIER_VIRTUALBOX%" --silent --ignore-reboot --msi-log-file "%JOURNAL%"
set "RC=%ERRORLEVEL%"
if "%RC%"=="740" goto virtualbox_autorisation
if "%RC%"=="1223" goto virtualbox_autorisation
if "%RC%"=="1618" goto virtualbox_occupe
if not "%RC%"=="0" goto erreur_virtualbox
if not exist "%VBOXMANAGE%" goto erreur_vboxmanage
set "ETAT_VIRTUALBOX=OK"
goto virtualbox_fin
:virtualbox_deja_la
set "ETAT_VIRTUALBOX=OK (deja installe)"
:virtualbox_fin
echo       %ETAT_VIRTUALBOX%
echo.

rem ----------------------------------------------------------------------
rem  Etape 4 : Extension Pack
rem  --replace         : remplace une version deja installee ;
rem  --accept-license= : accepte la licence sans question (hash ci-dessus).
rem  Un echec n'est pas bloquant : la VM fonctionne sans le pack.
rem  Les commandes VBoxManage sont lancees normalement, avec le compte du
rem  stagiaire (le reglage du dossier et la VM sont propres a ce compte) ;
rem  VBoxManage demande lui-meme l'autorisation si l'installation du pack
rem  en a besoin.
rem ----------------------------------------------------------------------

echo [3/5] Installation de l'Extension Pack...
"%VBOXMANAGE%" extpack install --replace --accept-license=%LICENCE_EXTPACK% "%FICHIER_EXTPACK%"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto avertissement_extpack
set "ETAT_EXTPACK=OK"
goto extpack_fin
:avertissement_extpack
set "ETAT_EXTPACK=ECHEC (non bloquant, voir ci-dessus)"
set /a AVERTISSEMENTS+=1
echo.
echo   [ATTENTION] L'Extension Pack ne s'est pas installe (code %RC%).
echo   Cause probable : Oracle a modifie la licence, le hash du script
echo   n'est plus le bon. Pour l'installer a la main, double-cliquer sur
echo   le fichier .vbox-extpack, ou taper dans une invite de commandes :
echo.
echo   "%VBOXMANAGE%" extpack install --replace "%FICHIER_EXTPACK%"
echo.
echo   puis accepter la licence en tapant y. Si Windows demande une
echo   autorisation, repondre Oui.
:extpack_fin
echo       %ETAT_EXTPACK%
echo.

rem ----------------------------------------------------------------------
rem  Etape 5 : dossier des machines virtuelles
rem  Le reglage est stocke dans le profil Windows (sur C:, efface a chaque
rem  redemarrage) : on le refait a chaque fois.
rem ----------------------------------------------------------------------

echo [4/5] Reglage du dossier des machines : %DOSSIER_VMS%
if not exist "%DOSSIER_VMS%\" mkdir "%DOSSIER_VMS%"
"%VBOXMANAGE%" setproperty machinefolder "%DOSSIER_VMS%"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto erreur_dossier
set "ETAT_DOSSIER=OK"
echo       %ETAT_DOSSIER%
echo.

rem ----------------------------------------------------------------------
rem  Etape 6 : reenregistrement de la VM
rem  - VM absente (premiere seance) : rien a faire, on la creera ;
rem  - VM deja connue de VirtualBox : rien a faire ;
rem  - sinon : VBoxManage registervm.
rem ----------------------------------------------------------------------

echo [5/5] Recherche de la VM %NOM_VM%...
if not exist "%FICHIER_VM%" goto vm_absente
"%VBOXMANAGE%" showvminfo "%NOM_VM%" >nul 2>&1
if not errorlevel 1 goto vm_deja_enregistree
"%VBOXMANAGE%" registervm "%FICHIER_VM%"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto avertissement_vm
set "ETAT_VM=OK (VM reenregistree)"
goto vm_fin
:vm_absente
set "ETAT_VM=pas encore de VM (normal a la premiere seance)"
goto vm_fin
:vm_deja_enregistree
set "ETAT_VM=OK (VM deja enregistree)"
goto vm_fin
:avertissement_vm
set "ETAT_VM=ECHEC (non bloquant, voir ci-dessus)"
set /a AVERTISSEMENTS+=1
echo.
echo   [ATTENTION] La VM n'a pas pu etre enregistree (code %RC%).
echo   Dans VirtualBox : menu Machine, Ajouter..., puis choisir le fichier
echo   %FICHIER_VM%
:vm_fin
echo       %ETAT_VM%
echo.

rem ----------------------------------------------------------------------
rem  Resume
rem ----------------------------------------------------------------------

call :resume
if not "%AVERTISSEMENTS%"=="0" echo Termine, mais avec des avertissements : lire les messages ci-dessus.
if "%AVERTISSEMENTS%"=="0" echo Termine. VirtualBox est pret : lancer "Oracle VirtualBox" depuis le menu Demarrer.
echo.
pause
endlocal
exit /b 0

rem ======================================================================
rem  Erreurs bloquantes : message, resume, pause, code retour 1
rem ======================================================================

:erreur_fichiers
echo.
echo [ERREUR] Il manque au moins un fichier dans %SOURCES%
echo   Fichiers attendus (le numero de version peut varier) :
echo     VC_redist.x64.exe
echo     VirtualBox-7.2.20-175154-Win.exe
echo     Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack
echo   Les telecharger (liens dans l'annexe d'installation), les placer
echo   dans ce dossier, puis relancer le script.
goto fin_erreur

:erreur_vcredist
echo.
echo [ERREUR] L'installation de Visual C++ a echoue (code %RC%).
echo   Essayer de lancer %FICHIER_VCREDIST% par un double-clic.
set "ETAT_VCREDIST=ECHEC (code %RC%)"
goto fin_erreur

:vcredist_autorisation
set "ETAT_VCREDIST=ECHEC (autorisation refusee, code %RC%)"
goto erreur_autorisation

:virtualbox_autorisation
set "ETAT_VIRTUALBOX=ECHEC (autorisation refusee, code %RC%)"
goto erreur_autorisation

:vcredist_occupe
set "ETAT_VCREDIST=ECHEC (autre installation en cours, code %RC%)"
goto erreur_occupe

:virtualbox_occupe
set "ETAT_VIRTUALBOX=ECHEC (autre installation en cours, code %RC%)"
goto erreur_occupe

:erreur_occupe
echo.
echo [ERREUR] Une autre installation est en cours sur ce poste (code %RC%).
echo   Patienter quelques minutes (par exemple la fin des mises a jour de
echo   Windows), puis relancer le script.
goto fin_erreur

:erreur_autorisation
echo.
echo [ERREUR] Windows n'a pas donne l'autorisation d'installer (code %RC%).
echo   Relancer le script et, quand Windows demande une autorisation,
echo   repondre Oui.
goto fin_erreur

:erreur_virtualbox
echo.
echo [ERREUR] L'installation de VirtualBox a echoue (code %RC%).
echo   Journal detaille : %JOURNAL%
echo   Essayer d'installer VirtualBox par un double-clic sur
echo   %FICHIER_VIRTUALBOX%
set "ETAT_VIRTUALBOX=ECHEC (code %RC%)"
goto fin_erreur

:erreur_vboxmanage
echo.
echo [ERREUR] VirtualBox semble installe, mais ce fichier est introuvable :
echo   %VBOXMANAGE%
echo   VirtualBox a peut-etre ete installe dans un autre dossier.
set "ETAT_VIRTUALBOX=ECHEC (VBoxManage introuvable)"
goto fin_erreur

:erreur_dossier
echo.
echo [ERREUR] Impossible de regler le dossier des machines (code %RC%).
echo   Dans VirtualBox : menu Fichier, Parametres, General, puis choisir
echo   %DOSSIER_VMS%
set "ETAT_DOSSIER=ECHEC (code %RC%)"
goto fin_erreur

:fin_erreur
echo.
call :resume
echo Installation interrompue. Prevenir le formateur si le probleme persiste.
echo.
pause
endlocal
exit /b 1

rem ======================================================================
rem  Sous-programmes
rem ======================================================================

rem ----------------------------------------------------------------------
rem  :trouver VARIABLE "motif"
rem  Cherche le motif dans le dossier du script et met le chemin complet
rem  dans VARIABLE (vide si aucun fichier). Une boucle "for" sur un motif
rem  sans correspondance ne fait aucun tour : la variable reste vide.
rem  Si plusieurs fichiers correspondent, le dernier trouve est garde et
rem  un avertissement est affiche.
rem ----------------------------------------------------------------------
:trouver
set "%~1="
set "NB_TROUVES=0"
for %%F in ("%SOURCES%%~2") do (
    set "%~1=%%~fF"
    set /a NB_TROUVES+=1
)
if "%NB_TROUVES%"=="0" echo   [MANQUANT] %~2
if "%NB_TROUVES%"=="0" exit /b 1
call echo   [OK]       %%%~1%%
if not "%NB_TROUVES%"=="1" echo   [ATTENTION] %NB_TROUVES% fichiers correspondent a %~2 : garder une seule version.
exit /b 0

rem ----------------------------------------------------------------------
rem  :resume -- affiche l'etat de chaque etape
rem ----------------------------------------------------------------------
:resume
echo ======================================================================
echo   Resume
echo ======================================================================
echo   Visual C++ Redistributable : %ETAT_VCREDIST%
echo   VirtualBox                 : %ETAT_VIRTUALBOX%
echo   Extension Pack             : %ETAT_EXTPACK%
echo   Dossier des machines       : %ETAT_DOSSIER%
echo   Machine virtuelle          : %ETAT_VM%
echo ======================================================================
echo.
exit /b 0
```
