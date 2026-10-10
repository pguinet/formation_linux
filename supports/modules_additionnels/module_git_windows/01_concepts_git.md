# Git sous Windows 1 — Les concepts de Git

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - expliquer à quoi sert un logiciel de gestion de versions comme Git ;
> - définir un dépôt, un commit, un historique, une branche et un dépôt distant ;
> - distinguer cloner, mettre à jour et publier, et situer GitHub par rapport à Git.
>
> **Durée en séance** : ~30 min.

---

Ce module s'adresse aux stagiaires qui travaillent sur un poste Windows
de la salle du CID. Il installe Git sur le lecteur `D:`, récupère une
copie du dépôt de la formation et s'en sert pour garder à jour le script
d'installation de VirtualBox.

Avant de manipuler Git, ce premier chapitre pose le vocabulaire. Il ne
contient aucune commande : il explique ce que font les outils des
chapitres suivants.

## Le problème : suivre les versions d'un document

Tout le monde a déjà vu ce genre de dossier :

```
rapport.docx
rapport_v2.docx
rapport_v2_relu.docx
rapport_final.docx
rapport_final_VRAIMENT.docx
```

Cette méthode pose vite des questions sans réponse :

- quelle est la bonne version ?
- qu'est-ce qui a changé entre deux versions, et pourquoi ?
- comment revenir en arrière si la dernière modification était une
  erreur ?
- comment travailler à plusieurs sans écraser le travail des autres ?

Un **logiciel de gestion de versions** répond à ces questions. Il
enregistre l'histoire d'un ensemble de fichiers : chaque modification
est datée, signée par son auteur et accompagnée d'une explication. On
peut consulter n'importe quelle version passée, comparer deux versions,
ou revenir à un état antérieur.

**Git** est aujourd'hui le plus utilisé de ces logiciels. Il a été créé
en 2005 par Linus Torvalds, l'auteur du noyau Linux, pour gérer le code
source de ce noyau. Il sert aussi bien pour du code que pour de la
documentation : le support de cette formation est géré avec Git.

## Le dépôt

Un **dépôt** (*repository* en anglais) est un dossier dont Git suit
l'histoire. Il contient deux choses :

- les fichiers eux-mêmes, que l'on ouvre et modifie normalement : c'est
  la **copie de travail** ;
- un sous-dossier caché nommé `.git`, où Git range tout l'historique.

```
formation_linux\           <- le dépôt
+-- .git\                  <- l'historique (géré par Git, ne pas toucher)
+-- README.md              <- la copie de travail
+-- cours_2026\
+-- ressources\
```

Supprimer le dossier `.git` transforme le dépôt en simple dossier : les
fichiers restent, mais toute l'histoire est perdue.

## Le commit

Un **commit** est une photo de l'état des fichiers à un instant donné.
Chaque commit enregistre :

- le contenu de tous les fichiers suivis ;
- l'auteur et la date ;
- un **message** qui explique la modification (« Corrige le lien vers
  l'image de Debian ») ;
- un **identifiant** unique, une suite de 40 caractères comme
  `08062fe2fc39d4a2...`, que l'on abrège en général à ses 7 premiers
  caractères : `08062fe`.

Les commits s'enchaînent : chacun connaît celui qui le précède. Leur
suite forme l'**historique** du dépôt.

```
  924cc0a  <- 08062fe  <- 13feee5
  (ancien)               (récent)
```

Les identifiants semblent aléatoires : ils sont calculés à partir du
contenu du commit. Deux commits différents ont donc toujours deux
identifiants différents.

## La branche

Une **branche** est une ligne de développement : une suite de commits
qui porte un nom. Le dépôt de la formation a une branche principale,
`master`. Les auteurs créent d'autres branches pour préparer une
modification sans gêner la branche principale, puis les **fusionnent**
dans `master` une fois la modification terminée.

Dans ce module, on se contente de suivre `master`.

## Le dépôt distant et GitHub

Git est **distribué** : chaque copie d'un dépôt contient l'historique
complet. Il n'y a pas de serveur indispensable. En pratique, on désigne
pourtant une copie de référence, hébergée sur un serveur accessible à
tous : c'est le **dépôt distant** (*remote*).

**GitHub** est un service web qui héberge des dépôts Git. Le dépôt de
la formation s'y trouve, en accès public :

```
https://github.com/pguinet/formation_linux
```

Git et GitHub sont deux choses différentes : Git est le logiciel,
installé sur votre poste ; GitHub est un site qui héberge des dépôts et
ajoute des services autour (pages web, discussions, génération des PDF
de la formation...).

## Cloner, mettre à jour, publier

Trois opérations relient votre poste au dépôt distant :

```
                      cloner (une fois)
                 ---------------------------->
  GitHub              mettre à jour (pull)        D:\PrenomNOM\
  dépôt distant  ---------------------------->    formation_linux
                      publier (push)
                 <----------------------------
```

- **Cloner** (`clone`) : créer sur votre poste une copie complète du
  dépôt distant, historique compris. On ne le fait qu'une fois.
- **Mettre à jour** (`pull`) : récupérer les nouveaux commits du dépôt
  distant et avancer votre copie de travail jusqu'au dernier. On le fait
  aussi souvent qu'on veut.
- **Publier** (`push`) : envoyer vos propres commits vers le dépôt
  distant. Il faut pour cela des droits d'écriture sur le dépôt.

Dans ce module, vous clonez le dépôt de la formation puis le mettez à
jour. Vous ne publiez rien : le dépôt est en lecture seule pour vous, et
c'est suffisant pour récupérer la dernière version des supports et des
scripts.

## Les outils de ce module

Git s'utilise de deux façons :

- **en ligne de commande**, dans un terminal : `git clone`, `git pull`,
  `git log`... C'est la façon la plus complète ;
- **avec des outils graphiques**, qui présentent les mêmes opérations
  avec des fenêtres et des boutons.

Le chapitre suivant installe **Git for Windows**, qui fournit les deux :

| Outil | Rôle |
|-------|------|
| Git Bash | terminal bash, avec les commandes Linux et `git` |
| Git GUI | fenêtre pour cloner un dépôt et suivre les modifications |
| gitk | fenêtre pour parcourir l'historique des commits |

## L'essentiel

| Commande / Notion | Usage |
|-------------------|-------|
| Gestion de versions | Enregistrer l'histoire d'un ensemble de fichiers |
| Dépôt | Dossier suivi par Git : copie de travail + dossier caché `.git` |
| Copie de travail | Les fichiers du dépôt, ouverts et modifiés normalement |
| Commit | Photo des fichiers, avec auteur, date, message et identifiant |
| Historique | Suite des commits d'un dépôt |
| Branche | Suite de commits nommée ; `master` est la branche principale |
| Dépôt distant | Copie de référence, hébergée sur un serveur |
| GitHub | Service web qui héberge des dépôts Git |
| Cloner (`clone`) | Copier un dépôt distant sur son poste, une fois |
| Mettre à jour (`pull`) | Récupérer les nouveaux commits du dépôt distant |
| Publier (`push`) | Envoyer ses commits vers le dépôt distant (droits requis) |

## Pour aller plus loin

**Les trois zones de Git.** Quand on modifie des fichiers pour créer un
commit, Git distingue trois zones : la copie de travail (les fichiers
modifiés), l'**index** (les modifications choisies pour le prochain
commit) et le dépôt (les commits déjà enregistrés). On prépare un
commit en ajoutant des modifications à l'index (`git add`), puis on le
crée (`git commit`). Ce module n'en a pas besoin, puisqu'il ne crée pas
de commit.

**Centralisé ou distribué.** Les anciens logiciels de gestion de
versions (CVS, Subversion) étaient centralisés : l'historique vivait sur
un serveur, et chaque poste n'en avait qu'une version. Avec Git, chaque
clone contient tout l'historique : on peut consulter les anciennes
versions sans réseau, et le dépôt survit à la perte du serveur.

**Autres hébergeurs.** GitHub n'est pas le seul : GitLab, Bitbucket ou
Codeberg offrent des services comparables, et une entreprise peut
héberger ses propres dépôts. Pour Git, ce ne sont que des adresses de
dépôts distants.

**Aller plus loin avec Git.** Le module additionnel « Git : contrôle de
version » enseigne Git en ligne de commande sous Linux : créer ses
propres dépôts, faire des commits, travailler avec des branches et à
plusieurs.

## Exercices

**Exercice 1.** Donnez trois questions auxquelles un logiciel de
gestion de versions permet de répondre.

**Exercice 2.** Un dossier contient les fichiers d'un projet, mais pas
de sous-dossier `.git`. Est-ce un dépôt Git ? Que manque-t-il ?

**Exercice 3.** Quelles informations un commit enregistre-t-il ?
Pourquoi parle-t-on souvent de `13feee5` plutôt que de l'identifiant
complet ?

**Exercice 4.** Pour chaque situation, indiquez l'opération à utiliser
(cloner, mettre à jour ou publier) :

1. Vous voulez une copie du dépôt de la formation sur votre poste.
2. Le formateur annonce une correction du script d'installation.
3. Vous avez corrigé une faute dans un chapitre et voulez l'envoyer sur
   GitHub.

**Exercice 5.** Expliquez en une phrase la différence entre Git et
GitHub.

### Solutions

**Solution 1.** Par exemple : quelle est la dernière version ?
qu'est-ce qui a changé entre deux versions, qui l'a changé et pourquoi ?
comment revenir à une version précédente ? Autre réponse possible :
comment travailler à plusieurs sans écraser le travail des autres ?

**Solution 2.** Non. Les fichiers forment une copie de travail, mais
sans le dossier `.git` il n'y a pas d'historique : Git ne suit pas ce
dossier.

**Solution 3.** Le contenu des fichiers suivis, l'auteur, la date, un
message explicatif et un identifiant unique. L'identifiant complet fait
40 caractères ; ses 7 premiers caractères suffisent en pratique à
désigner un commit sans ambiguïté, et sont plus faciles à lire et à
recopier.

**Solution 4.**

1. Cloner : on crée la copie une seule fois.
2. Mettre à jour (`pull`) : on récupère les nouveaux commits dans la
   copie existante.
3. Publier (`push`) : il faut des droits d'écriture sur le dépôt. Sans
   ces droits, on propose sa correction autrement, par exemple en la
   signalant au formateur.

**Solution 5.** Git est le logiciel de gestion de versions, installé
sur le poste ; GitHub est un site web qui héberge des dépôts Git et
ajoute des services autour.
