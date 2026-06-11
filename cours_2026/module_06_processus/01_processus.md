# Chapitre 6.1 — Les processus : observer et contrôler

> **Objectifs** : à la fin de ce chapitre, vous saurez :
> - expliquer ce qu'est un processus et à quoi sert le PID ;
> - lire la sortie de `ps aux` et naviguer dans `top` ;
> - arrêter un processus avec `kill` ;
> - passer un processus en arrière-plan et le gérer avec `jobs`, `fg`, `bg`.
>
> **Durée en séance** : ~30 min.

---

## Qu'est-ce qu'un processus ?

Chaque programme que vous lancez devient un **processus** : une instance en cours d'exécution avec ses propres données en mémoire. Le noyau Linux attribue à chaque processus un **PID** (Process Identifier), un numéro entier unique qui sert à le désigner dans toutes les commandes de gestion.

Chaque processus s'exécute dans le contexte d'un **utilisateur** : c'est le propriétaire du processus. Ce propriétaire détermine les fichiers accessibles et les actions autorisées. Vous ne pouvez contrôler (arrêter, suspendre...) que vos propres processus ; seul root peut agir sur tous. Les utilisateurs et les permissions sont détaillés dans les chapitres 5.1 et 5.3.

Tout processus est créé par un autre processus (son **parent**). Lorsque vous tapez une commande dans le terminal, c'est votre shell qui crée le processus fils. Le processus numéro 1 (`init` ou `systemd`) est l'ancêtre de tous les autres.

---

## Observer les processus

### ps aux — la photographie instantanée

`ps aux` affiche tous les processus en cours au moment de l'exécution.

```bash
ps aux
```

Exemple de sortie :

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1 225316  9012 ?        Ss   10:00   0:01 /sbin/init
alice     5678  2.5  1.2 123456 23456 pts/0    S+   10:30   0:05 python script.py
```

Colonnes importantes :

| Colonne  | Signification                                         |
|----------|-------------------------------------------------------|
| USER     | Propriétaire du processus                             |
| PID      | Identifiant unique du processus                       |
| %CPU     | Part du processeur utilisée                           |
| %MEM     | Part de la mémoire utilisée                           |
| TTY      | Terminal associé (`?` = aucun, démon système)         |
| STAT     | État : `R` en cours, `S` endormi, `T` suspendu, `Z` zombie |
| COMMAND  | Commande qui a lancé le processus                     |

Deux variantes utiles :

```bash
# Trier par consommation CPU (les plus gourmands en premier)
ps aux --sort=-%cpu | head -10

# Processus d'un utilisateur précis
ps -u alice
```

### top — la surveillance en temps réel

`top` affiche les processus en les actualisant en continu (par défaut toutes les 3 secondes).

```bash
top
```

Une fois dans `top`, les touches essentielles :

- `q` : quitter
- `P` : trier par CPU (défaut)
- `M` : trier par mémoire
- `u` : filtrer par utilisateur (saisir le nom, puis Entrée)
- `k` : demander le PID d'un processus à arrêter

La ligne de titre indique la **charge système** (`load average`) : les trois chiffres représentent la charge moyenne sur 1, 5 et 15 minutes. Une valeur inférieure au nombre de coeurs est saine.

**htop** est une alternative plus lisible, avec navigation à la souris et vue en arbre. Il n'est pas toujours installé par défaut (`sudo apt install htop`).

---

## Arrêter un processus

### kill — envoyer un signal

La commande `kill` envoie un **signal** au processus. Le signal par défaut est `SIGTERM` (15), qui demande au processus de se terminer proprement.

```bash
# Arrêt propre (le processus peut sauvegarder ses données)
kill 5678

# Forcer l'arrêt immédiat (en dernier recours)
kill -9 5678
```

`kill -9` envoie `SIGKILL`, non interceptable par le processus. C'est efficace, mais il ne peut pas nettoyer ses fichiers temporaires — à réserver aux processus bloqués.

Pour trouver un PID rapidement sans lire toute la liste :

```bash
pgrep firefox
```

---

## Premier plan et arrière-plan

Par défaut, une commande s'exécute **au premier plan** : elle occupe le terminal jusqu'à sa fin. Pour reprendre la main sans attendre, vous avez plusieurs options.

### Lancer directement en arrière-plan

Ajoutez `&` à la fin de la commande. Le shell affiche le numéro de **job** et le PID, puis rend la main immédiatement.

```bash
sleep 120 &
# [1] 7890
```

### Suspendre et reprendre

Si une commande tourne déjà au premier plan :

- **Ctrl+C** : l'interrompt définitivement (envoie `SIGINT`)
- **Ctrl+Z** : la **suspend** sans la tuer (envoie `SIGTSTP`)

Après `Ctrl+Z`, le processus est en état `T` (arrêté). Vous pouvez alors :

```bash
bg %1    # reprendre le job 1 en arrière-plan
fg %1    # le ramener au premier plan
```

### Gérer les jobs

```bash
jobs        # lister tous les jobs de la session courante
jobs -l     # même affichage, avec les PID
```

La référence `%1` désigne le job numéro 1. Vous pouvez aussi écrire `%sleep` pour cibler le job dont la commande commence par « sleep ».

```bash
kill %1     # arrêter le job 1
```

### Exemple complet

```bash
# Lancer un processus long au premier plan
sleep 300

# Ctrl+Z le suspend
# [1]+  Stopped    sleep 300

bg %1         # reprend en arrière-plan
jobs          # [1]+  Running    sleep 300 &
fg %1         # ramène au premier plan
# Ctrl+C pour terminer
```

---

## L'essentiel

| Commande              | Usage type                                          |
|-----------------------|-----------------------------------------------------|
| `ps aux`              | Lister tous les processus avec propriétaire et ressources |
| `ps aux --sort=-%cpu` | Trouver les processus les plus gourmands en CPU     |
| `top`                 | Surveiller les processus en temps réel              |
| `q` (dans top)        | Quitter top                                         |
| `kill PID`            | Arrêt propre d'un processus (SIGTERM)               |
| `kill -9 PID`         | Arrêt forcé d'un processus (SIGKILL)                |
| `pgrep nom`           | Trouver le PID d'un processus par son nom           |
| `commande &`          | Lancer directement en arrière-plan                  |
| `Ctrl+Z`              | Suspendre le processus au premier plan              |
| `bg %N`               | Reprendre le job N en arrière-plan                  |
| `fg %N`               | Ramener le job N au premier plan                    |
| `jobs`                | Lister les jobs de la session                       |
| `kill %N`             | Arrêter le job N                                    |

---

## Pour aller plus loin

### nohup — survivre à la fermeture du terminal

Lorsque vous fermez un terminal ou une session SSH, le shell envoie `SIGHUP` à tous ses processus fils, ce qui les arrête. Pour protéger un processus de ce signal :

```bash
nohup ./script_long.sh > sortie.log 2>&1 &
```

La sortie est redirigée vers `sortie.log` (ou vers `nohup.out` si vous n'en précisez pas). Le processus continue après votre déconnexion.

### Liste des signaux

```bash
kill -l     # afficher tous les signaux disponibles
```

Les signaux les plus utiles :

| Signal      | Numéro | Description                                    |
|-------------|--------|------------------------------------------------|
| SIGTERM     | 15     | Arrêt propre (défaut de `kill`)                |
| SIGKILL     | 9      | Arrêt immédiat, non interceptable              |
| SIGHUP      | 1      | Fermeture du terminal ; aussi : recharger conf |
| SIGINT      | 2      | Interruption clavier (Ctrl+C)                  |
| SIGSTOP     | 19     | Suspension, non interceptable                  |
| SIGCONT     | 18     | Reprise d'un processus suspendu                |

### pgrep / pkill

`pgrep` et `pkill` évitent de passer par `ps | grep` pour trouver ou arrêter un processus par son nom.

```bash
pgrep -l firefox       # afficher PID et nom
pkill firefox          # envoyer SIGTERM à tous les processus "firefox"
pkill -9 firefox       # envoyer SIGKILL
```

### nice / renice — priorité d'un processus

Linux attribue une **priorité** à chaque processus (valeur `nice` de -20 à +19 ; plus le nombre est élevé, moins le processus est prioritaire).

```bash
nice -n 10 ./calcul.sh &    # lancer avec priorité réduite
renice +5 -p 7890           # baisser la priorité d'un processus existant
```

### pstree — arborescence des processus

```bash
pstree          # afficher l'arbre complet
pstree -p       # avec les PID
pstree alice    # uniquement les processus d'alice
```

---

## Exercices

### Exercice 1 — Explorer les processus en cours

Affichez tous les processus, puis répondez :

1. Combien y a-t-il de processus sur le système en ce moment ?
2. Quel est le PID de votre shell ?
3. Quels sont les 3 processus qui consomment le plus de mémoire ?

### Exercice 2 — Observer avec top

Lancez `top`, puis :

1. Triez par mémoire (touche `M`).
2. Filtrez pour n'afficher que vos propres processus (touche `u`).
3. Quittez (`q`).

### Exercice 3 — Processus en arrière-plan et gestion des jobs

Effectuez les opérations suivantes dans un seul terminal :

1. Lancez `sleep 200` au premier plan.
2. Suspendez-le avec Ctrl+Z.
3. Reprenez-le en arrière-plan avec `bg`.
4. Vérifiez qu'il tourne avec `jobs`.
5. Lancez `sleep 300 &` directement en arrière-plan.
6. Listez vos jobs avec `jobs -l` (notez les PID).
7. Arrêtez le premier job avec `kill %1`.
8. Vérifiez que seul le second reste avec `jobs`.

### Exercice 4 — Tuer un processus par PID

1. Lancez `sleep 500 &` et notez le PID affiché.
2. Retrouvez ce PID avec `pgrep sleep`.
3. Arrêtez-le avec `kill` suivi du PID.
4. Vérifiez avec `jobs` qu'il est bien terminé.

### Exercice 5 — Charge artificielle

1. Lancez la commande suivante pour créer une charge CPU :

   ```bash
   yes > /dev/null &
   ```

2. Ouvrez `top` dans le même terminal (le processus `yes` passe au premier plan de `top`).
3. Repérez le PID du processus `yes`.
4. Quittez `top` (`q`), puis arrêtez `yes` avec `kill %1` ou `kill PID`.
5. Relancez `top` et observez que la charge est retombée.

### Exercice 6 — Arrêt propre et forcé

1. Créez un script minimal qui tourne en boucle :

   ```bash
   while true; do sleep 1; done &
   ```

2. Notez le PID (ou retrouvez-le avec `pgrep sleep`).
3. Envoyez d'abord `SIGTERM` : `kill PID`. Attendez une seconde.
4. Si le processus résiste (ce ne sera pas le cas ici, mais c'est le principe),
   forcez avec `kill -9 PID`.
5. Confirmez l'arrêt avec `ps -p PID`.

---

### Solutions

#### Exercice 1

```bash
ps aux | wc -l          # nombre de lignes (inclut l'en-tête)
echo $$                 # PID du shell courant
ps aux --sort=-%mem | head -4   # top 3 mémoire (+ en-tête)
```

#### Exercice 2

Pas de commandes spécifiques : manipulations interactives dans `top`.

#### Exercice 3

```bash
sleep 200
# Ctrl+Z

bg %1
jobs

sleep 300 &
jobs -l

kill %1
jobs
```

#### Exercice 4

```bash
sleep 500 &
# [1] 8421

pgrep sleep
# 8421

kill 8421
jobs
# [1]+  Terminated    sleep 500
```

#### Exercice 5

```bash
yes > /dev/null &
top
# q pour quitter top
kill %1
# ou : kill PID_du_yes
top   # charge normale
```

#### Exercice 6

```bash
while true; do sleep 1; done &
# [1] 9123

kill 9123
# attendre une seconde
ps -p 9123
# aucune ligne = processus terminé
```
