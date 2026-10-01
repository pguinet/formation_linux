# Quiz général - Formation Linux

## Instructions
- 30 questions à choix multiples
- Une seule réponse correcte par question
- Durée recommandée : 45 minutes
- Seuil de réussite : 24/30 (80%)

---

## Module 1 : Découverte et premiers pas

**Question 1 :** Que signifie l'acronyme GNU dans GNU/Linux ?
- A) General Network Utilities
- B) GNU's Not Unix
- C) Global Network Unix
- D) General New Unix

**Question 2 :** Quelle distribution Linux est connue pour sa stabilité en entreprise ?
- A) Arch Linux  
- B) Debian
- C) Gentoo
- D) Slackware

**Question 3 :** Quel environnement de bureau est le plus léger ?
- A) GNOME
- B) KDE
- C) XFCE
- D) Unity

---

## Module 2 : Navigation et système de fichiers

**Question 4 :** Quel répertoire contient les fichiers de configuration système ?
- A) /home
- B) /var
- C) /etc
- D) /usr

**Question 5 :** La commande `pwd` permet de :
- A) Changer de mot de passe
- B) Afficher le répertoire courant
- C) Lister les fichiers
- D) Créer un répertoire

**Question 6 :** Comment remonter de deux niveaux dans l'arborescence ?
- A) cd ../
- B) cd ../../
- C) cd /../../
- D) cd back

**Question 7 :** Que représente le caractère ~ ?
- A) Le répertoire parent
- B) Le répertoire racine
- C) Le répertoire personnel de l'utilisateur
- D) Le répertoire courant

---

## Module 3 : Manipulation de fichiers et dossiers

**Question 8 :** Pour copier un répertoire avec tout son contenu, on utilise :
- A) cp -r
- B) cp -a
- C) cp -R
- D) Toutes les réponses précédentes

**Question 9 :** La commande `mv` permet de :
- A) Copier un fichier seulement
- B) Déplacer et renommer des fichiers
- C) Supprimer un fichier
- D) Afficher le contenu d'un fichier

**Question 10 :** Pour trouver tous les fichiers .txt dans le répertoire courant :
- A) find . -name "*.txt"
- B) locate *.txt
- C) grep "*.txt"
- D) search *.txt

---

## Module 4 : Consultation et édition de fichiers

**Question 11 :** Pour afficher les 10 dernières lignes d'un fichier :
- A) head -10 fichier
- B) tail -10 fichier
- C) last -10 fichier
- D) end -10 fichier

**Question 12 :** Dans nano, comment sauvegarder un fichier ?
- A) Ctrl+S
- B) Ctrl+O
- C) Ctrl+W
- D) Ctrl+X

**Question 13 :** La commande `grep "pattern" fichier` permet de :
- A) Modifier le fichier
- B) Supprimer le fichier
- C) Rechercher un motif dans le fichier
- D) Copier le fichier

---

## Module 5 : Droits et sécurité

**Question 14 :** Que signifie la permission rwxr-xr-- ?
- A) 754
- B) 644
- C) 755
- D) 744

**Question 15 :** Pour donner tous les droits au propriétaire seulement :
- A) chmod 700
- B) chmod 755
- C) chmod 777
- D) chmod 644

**Question 16 :** La commande `sudo` permet de :
- A) Changer d'utilisateur définitivement
- B) Exécuter une commande avec les droits administrateur
- C) Créer un nouvel utilisateur
- D) Modifier les mots de passe

**Question 17 :** Pour changer le propriétaire d'un fichier :
- A) chmod
- B) chown
- C) chgrp  
- D) usermod

---

## Module 6 : Processus et système

**Question 18 :** Pour voir tous les processus en cours :
- A) ps
- B) ps aux
- C) top
- D) B et C sont corrects

**Question 19 :** Pour arrêter un processus de PID 1234 :
- A) kill 1234
- B) stop 1234
- C) end 1234
- D) quit 1234

**Question 20 :** La commande `df -h` permet de :
- A) Voir l'espace disque utilisé
- B) Voir l'utilisation mémoire
- C) Lister les fichiers
- D) Voir les processus

---

## Module 7 : Réseaux et services

**Question 21 :** Pour tester la connectivité vers un serveur :
- A) ping serveur
- B) connect serveur
- C) test serveur
- D) link serveur

**Question 22 :** Pour télécharger un fichier depuis internet :
- A) get
- B) download
- C) wget
- D) fetch

**Question 23 :** Pour voir les services actifs :
- A) systemctl status
- B) systemctl list
- C) systemctl list-units --type=service
- D) services --list

---

## Module 8 : Automatisation et scripts

**Question 24 :** Dans un script bash, comment commencer ?
- A) #!/bin/sh
- B) #!/bin/bash  
- C) #!/usr/bin/bash
- D) B et C sont corrects

**Question 25 :** Pour rediriger la sortie vers un fichier :
- A) commande > fichier
- B) commande >> fichier
- C) commande 2> fichier
- D) Toutes les réponses selon le contexte

**Question 26 :** Pour programmer une tâche tous les jours à 6h :
- A) 0 6 * * * commande
- B) 6 0 * * * commande
- C) * * 6 0 * commande
- D) 6 * * * * commande

**Question 27 :** Un alias permet de :
- A) Créer un raccourci de commande
- B) Renommer un fichier
- C) Créer un lien symbolique
- D) Modifier les permissions

---

## Questions bonus

**Question 28 :** Le répertoire /proc contient :
- A) Des fichiers de programmes
- B) Des informations sur le système et les processus
- C) Des fichiers de procédures
- D) Des fichiers de configuration

**Question 29 :** Pour voir l'historique des commandes :
- A) history
- B) past
- C) log
- D) commands

**Question 30 :** Pour rechercher une commande dans l'historique avec Ctrl+R :
- A) Mode recherche inversée
- B) Mode recherche rapide
- C) Mode recherche récursive
- D) Mode recherche récente

---

## Correction

1. B) GNU's Not Unix
2. B) Debian
3. C) XFCE
4. C) /etc
5. B) Afficher le répertoire courant
6. B) cd ../../
7. C) Le répertoire personnel de l'utilisateur
8. D) Toutes les réponses précédentes
9. B) Déplacer et renommer des fichiers
10. A) find . -name "*.txt"
11. B) tail -10 fichier
12. B) Ctrl+O
13. C) Rechercher un motif dans le fichier
14. D) 744
15. A) chmod 700
16. B) Exécuter une commande avec les droits administrateur
17. B) chown
18. D) B et C sont corrects
19. A) kill 1234
20. A) Voir l'espace disque utilisé
21. A) ping serveur
22. C) wget
23. C) systemctl list-units --type=service
24. D) B et C sont corrects
25. D) Toutes les réponses selon le contexte
26. A) 0 6 * * * commande
27. A) Créer un raccourci de commande
28. B) Des informations sur le système et les processus
29. A) history
30. A) Mode recherche inversée

---

## Barème

- 30/30 : Excellent (100%)
- 27-29 : Très bien (90-96%)
- 24-26 : Bien (80-86%) - Seuil de réussite
- 21-23 : Assez bien (70-76%)
- 18-20 : Passable (60-66%)
- < 18 : Insuffisant - Formation complémentaire recommandée