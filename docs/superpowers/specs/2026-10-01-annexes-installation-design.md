# Annexes d'installation (SSH et VirtualBox) -- Design

Date : 2026-10-01
Statut : validé

## Contexte

L'annexe actuelle `cours_2026/annexes/installation.md` traite les deux
publics dans un seul document, sans illustration. Pour le public B (CID),
elle est en partie fausse :

- les postes du CID sont **figés sur `C:`** : VirtualBox disparaît à chaque
  session et doit être réinstallé, avec ses dépendances ;
- elle propose l'ISO netinst et une installation **sans bureau**, alors que
  la saison 2026 vise Debian 13 avec environnement de bureau ;
- elle ne mentionne pas le Microsoft Visual C++ Redistributable, que
  VirtualBox 7.2 n'embarque plus et sans lequel il ne s'installe pas.

## Décisions

1. **Deux documents, deux PDF** :
   `cours_2026/annexes/installation_ssh.md` -> `annexe_installation_ssh.pdf`,
   `cours_2026/annexes/installation_virtualbox.md` ->
   `annexe_installation_virtualbox.pdf`. Chacun est autonome (distribué
   séparément) ; la courte section de vérification finale figure dans les
   deux. `installation.md` et `annexe_installation.pdf` disparaissent.
2. **Arborescence du stagiaire** : `D:\PrenomNOM\sources\` (installeurs,
   image Debian, script) et `D:\PrenomNOM\VirtualBox\` (la VM). Plus de
   dossier `iso\`.
3. **Versions vérifiées le 2026-10-01**, listées dans le document avec lien
   direct, taille et SHA256 :

   | Fichier | Version | Taille | Lien |
   |---|---|---|---|
   | `VC_redist.x64.exe` | Visual C++ 2015-2022 x64 | 26 Mo | https://aka.ms/vs/17/release/vc_redist.x64.exe |
   | `VirtualBox-7.2.20-175154-Win.exe` | 7.2.20 | 178 Mo | https://download.virtualbox.org/virtualbox/7.2.20/VirtualBox-7.2.20-175154-Win.exe |
   | `Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack` | 7.2.20 | 20 Mo | https://download.virtualbox.org/virtualbox/7.2.20/Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack |
   | `debian-13.7.0-amd64-DVD-1.iso` | Debian 13.7 | 4,0 Go | https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-13.7.0-amd64-DVD-1.iso |

   SHA256 publiés : VirtualBox
   `a81777d2b36380ce042a29e9c554cf032eb46a793f62e3cc82e7411e535c2c26`,
   Extension Pack
   `0a050da993f2e3cf2e4e9cda2fa8667e44a2b25479b27abd41af6812c1e43591`,
   Debian DVD-1
   `347b6c67a3cc0b7ddb60b178f683470c4e2b7ac426c996d9337a2ff36c1a32d2`.
   Le lien `current/` de Debian change à chaque version mineure : le
   document donne aussi la page d'index pour retrouver la dernière 13.x.
4. **VM** : nom `FormationLinux`, dossier `D:\PrenomNOM\VirtualBox`, 4 Go de
   RAM, 2 CPU, disque VDI dynamique de 30 Go, **réseau en accès par pont**
   (pas de NAT), installation sans surveillance **désactivée** (on veut
   l'installeur classique, illustré).
5. **Debian 13.7 DVD-1, installation graphique**, bureau **GNOME** et
   applications par défaut, **serveur SSH** coché dans la sélection des
   logiciels. Comptes : utilisateur **`cid` / `cid`**, root **`cid`** ;
   après le premier démarrage, `cid` est ajouté au groupe `sudo` (les
   chapitres `su` 5.1 et `sudo` 5.3 fonctionnent tels quels). Additions
   invité installées une fois dans Debian (elles restent sur le disque de
   la VM).
6. **Réinstallation à chaque séance** : script
   `installer_virtualbox.bat` à placer dans `sources\`, lancé par un
   simple double-clic (pas en administrateur) : chaque installeur demande
   lui-même l'autorisation à Windows, et les commandes VBoxManage tournent
   avec le compte du stagiaire (le dossier des machines et la VM sont
   propres à ce compte). Il retrouve les installeurs par motif (indépendant des
   versions), installe VC++, VirtualBox et l'Extension Pack en silencieux,
   règle le dossier des machines et réenregistre la VM. Il s'arrête avec un
   message clair si un fichier manque. La procédure manuelle reste décrite.
   Le script est versionné dans `ressources/scripts/` et reproduit dans le
   document. **Non testé sur Windows** depuis l'environnement de
   développement : à valider une fois au CID.
7. **Captures d'écran reproductibles** (`outils/captures/`, hors CI) :
   - installeur Debian : la vraie image DVD-1 sous QEMU/KVM dans Docker,
     pilotée au clavier (QMP `send-key`), une capture par écran
     (`screendump`) ;
   - VirtualBox : VirtualBox 7.2.20 pour Linux, interface en français, dans
     un conteneur avec Xvfb, piloté par `xdotool` ; captures de l'assistant
     « Nouvelle machine », des réglages (réseau par pont) et de l'Extension
     Pack. Fenêtres Linux, mêmes écrans et libellés que sous Windows ; des
     chemins `D:\...` sont saisis dans les champs. L'installeur Windows
     (MSI) n'est pas illustré.
   - PNG versionnés dans `ressources/images/installation/` ; scripts
     relancés à la main à chaque nouvelle version.
8. **Chaîne PDF** : prise en charge des images (`--resource-path` du
   dossier de chaque source), une image introuvable fait échouer le build,
   largeur des captures limitée, tests ajoutés ; catalogue de 11 à 12 PDF.

## Hors périmètre

- Captures de l'installeur Windows de VirtualBox.
- Test réel du `.bat` sur un poste Windows (à faire au CID).
- Contenu de cours sur le bureau GNOME (volet de saison distinct).
