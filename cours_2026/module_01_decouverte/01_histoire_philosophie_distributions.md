# Chapitre 1.1 — Linux : histoire, philosophie et distributions

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - retracer les grandes étapes de la naissance de Linux, d'Unix au noyau de 1991 ;
> - expliquer les quatre libertés du logiciel libre et ce qu'implique la licence GPL ;
> - distinguer distribution, noyau et gestionnaire de paquets ;
> - citer les domaines dans lesquels Linux est aujourd'hui présent.
>
> **Durée en séance** : ~30 min.

---

## D'Unix à Linux

### Unix, le point de départ (1969)

En 1969, Ken Thompson et Dennis Ritchie, ingénieurs chez Bell Labs (AT&T), créent le système
d'exploitation **Unix**. Pour la première fois, un OS est conçu de façon modulaire, avec un
principe fondateur qui restera célèbre : *faire une seule chose, mais la faire bien*. Unix
introduit également le langage C, qui deviendra le langage de programmation système de référence.

Unix est rapidement adopté par les universités et les administrations, mais il reste **propriétaire
et coûteux**. Les chercheurs peuvent en lire le code source à des fins pédagogiques, mais ils
n'ont pas le droit de le modifier ni de le redistribuer. Cette contrainte va engendrer une réaction
en chaîne.

### Le projet GNU et la naissance du logiciel libre (1983)

En 1983, Richard Stallman, chercheur au MIT, annonce le projet **GNU** (acronyme récursif de
« GNU's Not Unix »). Son objectif : construire un système d'exploitation entièrement libre,
compatible Unix, que chacun pourrait utiliser, étudier, modifier et redistribuer librement.

Stallman fonde la **Free Software Foundation (FSF)** en 1985 et rédige la première version de
la **General Public License (GPL)**. Cette licence dit, en substance : vous pouvez utiliser ce
code, le modifier et le redistribuer, mais toute version dérivée doit rester soumise aux mêmes
termes — c'est le principe du *copyleft*.

En 1991, le projet GNU a produit de nombreux outils indispensables (compilateur GCC, éditeur
Emacs, shell Bash...) mais il lui manque toujours un élément central : le noyau.

### Linux, le noyau manquant (1991)

Le 25 août 1991, Linus Torvalds, étudiant finlandais de 21 ans à l'Université d'Helsinki, publie
sur le forum Usenet `comp.os.minix` un message resté célèbre :

> « Je travaille sur un système d'exploitation libre (juste un passe-temps, ce ne sera pas aussi
> grand ni aussi professionnel qu'GNU) pour les clones AT 386. »

Ce « passe-temps » devient le noyau **Linux**. Quelques semaines plus tard, la version 0.01 est
publiée : environ 10 000 lignes de code, fonctionnant uniquement sur les processeurs Intel 386.

La combinaison **noyau Linux + outils GNU** forme alors un système d'exploitation complet, souvent
appelé **GNU/Linux** pour rendre hommage aux deux projets fondateurs.

### L'essor des années 1990 et 2000

Les premières distributions apparaissent rapidement : Slackware en 1993, Red Hat en 1994,
Debian en 1996. Linux commence à équiper des serveurs web, attire les développeurs du monde
entier et grossit à une vitesse que personne n'avait anticipée.

En 2004, Mark Shuttleworth fonde **Canonical** et publie la première version d'**Ubuntu**, dont
l'ambition est de rendre Linux accessible au grand public, avec un cycle de sortie régulier et
une interface soignée.

---

## Le logiciel libre

### Les quatre libertés fondamentales

La **Free Software Foundation** définit le logiciel libre autour de quatre libertés que tout
utilisateur doit posséder :

| Numéro | Liberté |
|--------|---------|
| Liberté 0 | Utiliser le logiciel pour n'importe quel usage |
| Liberté 1 | Étudier le fonctionnement du logiciel (accès au code source) |
| Liberté 2 | Redistribuer des copies du logiciel |
| Liberté 3 | Améliorer le logiciel et publier ses améliorations |

Ces libertés ne sont pas indépendantes : la liberté 1 et la liberté 3 supposent l'accès au code
source. Un logiciel dont le code est caché ne peut pas être qualifié de logiciel libre.

### La GPL en une phrase

La licence **GPL** (General Public License) garantit ces quatre libertés et y ajoute une
obligation : toute redistribution d'un programme GPL — modifié ou non — doit rester soumise à
la GPL. Ce mécanisme dit de *copyleft* empêche qu'une version améliorée soit rendue propriétaire.

### Le modèle communautaire

Linux est développé par des milliers de contributeurs à travers le monde : des bénévoles, des
étudiants, mais aussi des ingénieurs salariés chez IBM, Red Hat, Google, Intel ou Microsoft. Le
noyau Linux dépasse aujourd'hui **28 millions de lignes de code** et reçoit chaque journée des
dizaines de corrections et d'améliorations.

Ce modèle repose sur la **revue collective** : toute modification est soumise à un groupe de
mainteneurs qui la valide avant intégration. La transparence est totale et n'importe qui peut
signaler un problème ou proposer une correction.

---

## Les distributions

### Qu'est-ce qu'une distribution ?

Le noyau Linux seul ne suffit pas à faire un système utilisable. Une **distribution** rassemble :

- le **noyau Linux**, qui dialogue avec le matériel ;
- les **outils GNU** (shell Bash, compilateur GCC, utilitaires courants) ;
- un **gestionnaire de paquets** (outil qui installe, met à jour et supprime des logiciels) ;
- des **applications** préinstallées (navigateur, bureau graphique, éditeur de texte...) ;
- une **documentation** et une communauté de support.

Si l'on compare Linux à un moteur d'automobile, la distribution est la voiture complète, prête
à rouler.

### Panorama des principales distributions

| Distribution | Public visé | Particularité |
|-------------|-------------|---------------|
| **Debian** | Administrateurs, serveurs | Stabilité maximale, cycle de sortie prudent (~2 ans) |
| **Ubuntu** | Débutants, postes de travail | Basée sur Debian, interface soignée, LTS tous les 2 ans |
| **Fedora** | Développeurs, early adopters | Technologies récentes, incubateur de Red Hat |
| **Arch Linux** | Utilisateurs avancés | Installation manuelle, rolling release, contrôle total |

Il existe plus de **1 000 distributions actives**, mais ces quatre représentent bien la diversité
des approches possibles.

### Pourquoi Debian pour cette formation ?

Cette formation s'appuie sur **Debian 13 (Trixie)**. Ce choix s'explique par plusieurs raisons :

- **Stabilité** : Debian privilégie des logiciels éprouvés, ce qui réduit les surprises en
  formation ;
- **Représentativité** : Debian est la base d'Ubuntu et de nombreuses distributions serveur ;
- **Référence** : ses comportements par défaut (chemins, configuration, nommage des services)
  se retrouvent dans la majorité des environnements professionnels ;
- **Gratuité et pérennité** : projet communautaire indépendant depuis 1993, sans intérêts
  commerciaux particuliers.

Les commandes et concepts vus dans cette formation sont, pour l'écrasante majorité, identiques
sur toutes les distributions.

---

## Où vit Linux aujourd'hui ?

Linux est de loin le système d'exploitation le plus répandu dans le monde, même si beaucoup
d'utilisateurs l'ignorent. Les **serveurs web** qui hébergent les sites que vous visitez
quotidiennement tournent à plus de 95 % sous Linux. Les infrastructures **cloud** des grands
fournisseurs (AWS, Azure, Google Cloud) reposent massivement sur Linux pour leurs machines
virtuelles.

**Android**, installé sur environ 70 % des smartphones dans le monde, est lui-même fondé sur le
noyau Linux. Les **objets connectés** — routeurs, téléviseurs intelligents, systèmes embarqués
dans les voitures — utilisent fréquemment des variantes de Linux, notamment pour sa légèreté et
sa licence permissive.

Les **supercalculateurs** constituent le cas le plus extrême : les 500 machines les plus puissantes
au monde tournent toutes sous Linux.

Apprendre Linux, c'est donc apprendre à interagir avec la grande majorité de l'infrastructure
numérique mondiale.

---

## L'essentiel

| Notion | À retenir |
|--------|-----------|
| Unix (1969) | Ancêtre de Linux, système modulaire, propriétaire |
| GNU (1983) | Projet de système libre par Stallman, outils essentiels |
| Noyau Linux (1991) | Créé par Linus Torvalds, publié le 25 août 1991 |
| GPL | Licence copyleft : modifications redistribuées sous les mêmes termes |
| Distribution | Noyau + outils + gestionnaire de paquets + applications |
| Debian | Base de la formation : stable, représentative, indépendante |
| Présence de Linux | Serveurs (>95 %), cloud, Android (~70 %), embarqué, supercalculateurs (100 %) |

**À retenir absolument** :

- Linux est le **noyau** ; GNU/Linux est le **système complet**.
- Le logiciel libre repose sur **quatre libertés**, dont l'accès au code source est la clé.
- Une distribution choisit et assemble les briques pour un usage donné.

---

## Pour aller plus loin

### La généalogie des distributions

Les distributions ne sont pas isolées : elles forment une arborescence. Debian est la souche d'une
famille importante : Ubuntu en dérive directement, Linux Mint dérive d'Ubuntu, et des dizaines
d'autres projets s'appuient sur cette base. Red Hat a sa propre lignée : Fedora sert de terrain
d'expérimentation, RHEL (Red Hat Enterprise Linux) est la version commerciale, et Rocky Linux ou
AlmaLinux sont des clones communautaires de RHEL.

Arch Linux est à part : il ne dérive de rien et a lui-même engendré Manjaro. Cette généalogie
explique pourquoi les commandes et fichiers de configuration se ressemblent au sein d'une même
famille (même gestionnaire de paquets, mêmes répertoires par défaut) et diffèrent d'une famille
à l'autre.

### Les différences de licences : GPL, BSD, MIT en survol

Toutes les licences libres ne se ressemblent pas :

- **GPL** : copyleft fort. Toute redistribution, modifiée ou non, doit rester sous GPL. Protège
  la liberté des utilisateurs finaux.
- **LGPL** (Lesser GPL) : copyleft affaibli. Utilisée pour les bibliothèques que des logiciels
  propriétaires peuvent intégrer sans être contaminés par la GPL.
- **BSD et MIT** : licences dites « permissives ». Vous pouvez réutiliser le code dans un
  logiciel propriétaire sans obligation de redistribuer sous les mêmes termes. FreeBSD, macOS et
  de nombreuses bibliothèques JavaScript utilisent ce type de licences.

En pratique, le noyau Linux est sous **GPL v2**, ce qui a contribué à l'essor de l'écosystème
en obligeant les constructeurs matériels à publier leurs pilotes modifiés.

### Quelques ressources de référence

- **kernel.org** : site officiel du noyau Linux, source des archives depuis la version 0.01.
- **debian.org** : site officiel de Debian, documentation en français disponible.
- **gnu.org/philosophy** : les textes fondateurs du mouvement du logiciel libre par Stallman.
- **distrowatch.com** : panorama des distributions actives avec statistiques de popularité.

---

## Exercices

### Exercice 1 — Frise chronologique

Replacez les événements suivants dans l'ordre chronologique en indiquant l'année :

- Première version d'Ubuntu
- Naissance d'Unix chez Bell Labs
- Annonce du noyau Linux par Linus Torvalds
- Lancement du projet GNU par Richard Stallman
- Parution de la première version stable de Debian

### Exercice 2 — Les quatre libertés

Pour chacune des situations suivantes, indiquez quelle liberté (0, 1, 2 ou 3) est exercée :

a) Un enseignant installe LibreOffice sur les postes de sa salle de classe et l'utilise pour
   préparer ses cours — sans aucune restriction.

b) Un développeur télécharge le code source de Bash pour comprendre comment fonctionne le
   traitement des pipes.

c) Une entreprise corrige un bug dans le noyau Linux, compile sa version corrigée et la met
   en ligne pour que d'autres puissent l'utiliser.

d) Une association copie plusieurs fois une distribution Debian sur des clés USB et les
   distribue gratuitement lors d'une journée portes ouvertes.

### Exercice 3 — Vocabulaire

Associez chaque terme à sa définition :

| Terme | Définition |
|-------|-----------|
| A. Noyau (kernel) | 1. Ensemble complet : noyau + outils + gestionnaire de paquets |
| B. Distribution | 2. Licence garantissant que les versions dérivées restent libres |
| C. GPL | 3. Partie centrale de l'OS qui dialogue avec le matériel |
| D. Copyleft | 4. Principe imposant que les œuvres dérivées conservent les mêmes libertés |

### Exercice 4 — Questions de réflexion

Répondez en deux ou trois phrases à chacune des questions suivantes :

a) Citez deux différences concrètes entre Debian et Ubuntu du point de vue d'un utilisateur
   débutant.

b) Pourquoi dit-on « GNU/Linux » plutôt que simplement « Linux » ?

c) Android est basé sur le noyau Linux. Peut-on dire qu'Android est un logiciel libre ?
   Justifiez votre réponse.

### Exercice 5 — Vrai ou Faux

Indiquez si les affirmations suivantes sont vraies ou fausses, et corrigez celles qui sont
fausses :

a) Le noyau Linux a été créé en 1983 par Richard Stallman.

b) Une distribution Linux peut être installée sans interface graphique.

c) La licence GPL interdit de vendre des logiciels libres.

d) Arch Linux est une distribution adaptée aux débutants souhaitant une installation simple.

e) Android est fondé sur le noyau Linux.

---

### Solutions

#### Solution exercice 1 — Frise chronologique

1. **1969** : Naissance d'Unix chez Bell Labs
2. **1983** : Lancement du projet GNU par Richard Stallman
3. **1991** : Annonce du noyau Linux par Linus Torvalds
4. **1996** : Parution de la première version stable de Debian
5. **2004** : Première version d'Ubuntu

#### Solution exercice 2 — Les quatre libertés

a) **Liberté 0** : utiliser le programme pour n'importe quel usage.

b) **Liberté 1** : étudier le fonctionnement du programme (accès au code source).

c) **Liberté 3** : améliorer le programme et publier ces améliorations.

d) **Liberté 2** : redistribuer des copies du programme.

#### Solution exercice 3 — Vocabulaire

- A -> 3 : Le noyau est la partie centrale de l'OS qui dialogue avec le matériel.
- B -> 1 : La distribution est l'ensemble complet (noyau + outils + gestionnaire de paquets).
- C -> 2 : La GPL est la licence garantissant que les versions dérivées restent libres.
- D -> 4 : Le copyleft est le principe imposant que les œuvres dérivées conservent les mêmes
  libertés.

#### Solution exercice 4 — Questions de réflexion

a) **Debian vs Ubuntu pour un débutant.**
Ubuntu propose un installateur plus guidé, un bureau GNOME préconfiguré et une documentation
abondante en français visant les néophytes. Debian est plus austère à l'installation et suppose
davantage d'autonomie, mais offre une stabilité supérieure et un cycle de mises à jour plus
prudent.

b) **GNU/Linux plutôt que Linux.**
Le noyau Linux seul ne constitue pas un système complet : sans les outils GNU (shell Bash,
compilateur GCC, utilitaires cp, ls, grep...), il est inutilisable. La dénomination GNU/Linux
rend hommage aux deux projets qui, ensemble, forment le système. Linus Torvalds lui-même utilise
parfois le terme « Linux » pour désigner l'ensemble, mais la FSF insiste sur « GNU/Linux ».

c) **Android est-il libre ?**
Android incorpore le noyau Linux, qui est sous GPL. Cependant, Android lui-même est composé de
nombreuses couches supplémentaires (bibliothèques Java, interfaces Google) dont une partie n'est
pas libre. La réponse est donc nuancée : le noyau utilisé par Android est libre, mais le système
Android dans son ensemble — tel que livré sur la plupart des appareils — ne l'est pas
intégralement.

#### Solution exercice 5 — Vrai ou Faux

a) **Faux.** Le noyau Linux a été créé en **1991** par **Linus Torvalds**. Richard Stallman
a lancé le projet GNU en 1983.

b) **Vrai.** Une distribution peut fonctionner en mode « headless » (sans interface graphique),
ce qui est courant sur les serveurs.

c) **Faux.** La GPL n'interdit pas la vente. Elle autorise la vente de logiciels libres, à
condition que l'acheteur reçoive le code source et les mêmes droits que le vendeur.

d) **Faux.** Arch Linux est conçu pour des utilisateurs expérimentés qui souhaitent assembler
leur système manuellement. Pour débuter, Debian ou Ubuntu sont beaucoup plus adaptés.

e) **Vrai.** Android utilise le noyau Linux comme base de son système.
