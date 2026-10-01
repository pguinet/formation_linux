# Captures d'écran des annexes d'installation

Ces outils produisent les captures de `ressources/images/installation/`,
utilisées par `cours_2026/annexes/installation_virtualbox.md`. Ils ne
tournent pas en CI (il faut Docker, `/dev/kvm` et environ 4 Go de
téléchargement) : on les relance à la main à chaque nouvelle version de
Debian ou de VirtualBox, puis on relit les images avant de committer.

| Dossier | Produit | Commande | Durée |
|---------|---------|----------|-------|
| `debian/` | `debian-*.png`, `debian-captures.txt` | `outils/captures/debian/capturer.sh` | ~12 min |
| `virtualbox/` | `vbox-*.png`, `vbox-captures.txt` | `outils/captures/virtualbox/capturer.sh` | ~1 min |

Les fichiers lourds (ISO, paquets, disque de la VM) restent dans
`build/captures/` (ignoré par git).

## Changer de version

Les versions et sommes SHA256 sont écrites à plusieurs endroits, à mettre
à jour ensemble :

- les deux `capturer.sh` (et le nom d'ISO par défaut de
  `debian/piloter.py`) ;
- l'annexe, section des téléchargements ;
- le hash de licence de l'Extension Pack dans
  `ressources/scripts/installer_virtualbox.bat` (le script de capture
  VirtualBox l'affiche ; il change si Oracle modifie la licence) ;
- la spec `docs/superpowers/specs/2026-10-01-annexes-installation-design.md`
  (historique).

## Captures non utilisées

Toutes les captures produites ne sont pas insérées dans l'annexe : celles
qui montrent un champ vide, une valeur proposée par défaut ou une barre de
progression sont gardées pour référence mais volontairement omises, le
texte décrivant l'étape. Au 2026-10-01 :

- Debian : 06 (domaine), 09 (identifiant), 16 (installation du système de
  base), 19 (pays du miroir), 21 (mandataire), 24 (installation des
  logiciels), 30 (saisie du mot de passe), 32 (vue d'ensemble GNOME) ;
- VirtualBox : 02 (outil Extensions vide), 04 (licence, début), 07 (ISO
  détectée, avant de décocher l'installation sans surveillance), 11 (VM
  créée, réseau encore en NAT).
