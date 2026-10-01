# Captures de l'installeur Debian

Produit les captures d'écran de l'installation graphique de Debian 13.7
(DVD-1) utilisées par l'annexe VirtualBox :
`ressources/images/installation/debian-*.png` et la liste
`ressources/images/installation/debian-captures.txt` (fichier -> écran).

```bash
outils/captures/debian/capturer.sh
```

Prérequis : Docker, `/dev/kvm` accessible à l'utilisateur, environ 40 Go
libres, accès Internet (miroir Debian pendant l'installation). Hors CI.

## Fonctionnement

- `capturer.sh` télécharge l'ISO dans `build/captures/cache/` (une seule
  fois, SHA256 vérifié), construit l'image Docker (`Dockerfile`) et lance
  `piloter.py` dans le conteneur.
- `piloter.py` démarre QEMU/KVM sans affichage (4 Go, 2 CPU, disque qcow2
  de 30 Go en SATA, carte e1000, écran 1280x800), pilote l'installeur au
  clavier par QMP (`send-key`) et capture l'écran (`screendump`).
- Chaque étape attend un écran **stable** (captures successives quasi
  identiques) contenant un texte attendu, reconnu par OCR (`tesseract`,
  français). Si l'écran ne vient pas dans le délai imparti, le script
  s'arrête en nommant l'étape et garde la dernière capture dans
  `build/captures/debian/echec-<étape>.png`.
- Les saisies suivent la spec : français, France, clavier français,
  `debian-formation`, domaine vide, root `cid`, utilisateur `cid`/`cid`,
  disque entier en une partition, miroir réseau, GNOME + serveur SSH.
- Fichiers de travail (disque, journal `piloter.log`, captures brutes) :
  `build/captures/debian/`, ignoré par git.

## Nouvelle version de Debian

Changer `ISO`, `URL` et `SHA256` dans `capturer.sh`, relancer, puis
regarder chaque capture : l'OCR reconnaît les écrans, mais les positions dans les listes (langue, cases
de la sélection des logiciels) sont supposées connues.
