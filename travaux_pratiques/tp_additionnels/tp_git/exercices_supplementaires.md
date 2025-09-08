# Exercices supplémentaires Git - Avec corrections

## Série 1 : Maîtrise des commandes de base

### Exercice 1.1 : Création de projet pas à pas
**Objectif :** Créer un projet de calculatrice avec historique Git complet

**Énoncé :**
Créez un projet `calculatrice-git` avec cette progression :
1. Initialiser le dépôt et créer un README
2. Ajouter une fonction addition dans `calc.py`
3. Ajouter une fonction soustraction 
4. Créer un fichier de tests `test_calc.py`
5. Ajouter multiplication et division
6. Créer un script principal `main.py` qui utilise toutes les fonctions
7. Ajouter un fichier .gitignore approprié

**Contraintes :**
- Un commit par étape
- Messages de commit respectant les conventions
- Vérifier l'état avec `git status` à chaque étape
- Utiliser `git diff` avant chaque commit

<details>
<summary>Solution</summary>

```bash
# 1. Initialisation
mkdir calculatrice-git
cd calculatrice-git
git init
echo "# Calculatrice Git

Projet d'exemple pour apprendre Git avec une calculatrice simple." > README.md
git add README.md
git commit -m "feat: initialiser projet calculatrice"

# 2. Addition
echo "def add(a, b):
    \"\"\"Additionne deux nombres\"\"\"
    return a + b" > calc.py
git add calc.py
git commit -m "feat: ajouter fonction addition"

# 3. Soustraction
echo "
def subtract(a, b):
    \"\"\"Soustrait deux nombres\"\"\"
    return a - b" >> calc.py
git add calc.py
git commit -m "feat: ajouter fonction soustraction"

# 4. Tests
echo "import calc

def test_add():
    assert calc.add(2, 3) == 5
    assert calc.add(-1, 1) == 0
    print(\"✓ Tests addition réussis\")

def test_subtract():
    assert calc.subtract(5, 3) == 2
    assert calc.subtract(0, 1) == -1
    print(\"✓ Tests soustraction réussis\")

if __name__ == \"__main__\":
    test_add()
    test_subtract()
    print(\"Tous les tests passent!\")" > test_calc.py
git add test_calc.py
git commit -m "test: ajouter tests pour addition et soustraction"

# 5. Multiplication et division
echo "
def multiply(a, b):
    \"\"\"Multiplie deux nombres\"\"\"
    return a * b

def divide(a, b):
    \"\"\"Divise deux nombres\"\"\"
    if b == 0:
        raise ValueError(\"Division par zéro impossible\")
    return a / b" >> calc.py

# Mettre à jour les tests
echo "
def test_multiply():
    assert calc.multiply(3, 4) == 12
    assert calc.multiply(-2, 3) == -6
    print(\"✓ Tests multiplication réussis\")

def test_divide():
    assert calc.divide(10, 2) == 5
    assert calc.divide(7, 2) == 3.5
    try:
        calc.divide(1, 0)
        assert False, \"Devrait lever une exception\"
    except ValueError:
        pass
    print(\"✓ Tests division réussis\")" >> test_calc.py

git add calc.py test_calc.py
git commit -m "feat: ajouter multiplication et division avec tests"

# 6. Script principal
echo "#!/usr/bin/env python3
import calc

def main():
    print(\"=== Calculatrice Git ===\")
    
    a, b = 10, 3
    
    print(f\"{a} + {b} = {calc.add(a, b)}\")
    print(f\"{a} - {b} = {calc.subtract(a, b)}\")
    print(f\"{a} × {b} = {calc.multiply(a, b)}\")
    print(f\"{a} ÷ {b} = {calc.divide(a, b):.2f}\")
    
    # Test division par zéro
    try:
        calc.divide(a, 0)
    except ValueError as e:
        print(f\"Erreur attendue: {e}\")

if __name__ == \"__main__\":
    main()" > main.py

chmod +x main.py
git add main.py
git commit -m "feat: ajouter script principal d'utilisation"

# 7. .gitignore
echo "# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/

# IDE
.vscode/
.idea/
*.swp

# Tests
.coverage
htmlcov/

# OS
.DS_Store
Thumbs.db" > .gitignore

git add .gitignore
git commit -m "chore: ajouter .gitignore pour Python"

# Vérification finale
git log --oneline
python main.py
python test_calc.py
```
</details>

---

### Exercice 1.2 : Détective Git
**Objectif :** Analyser l'historique et comprendre les modifications

**Énoncé :**
En utilisant le projet créé dans l'exercice 1.1 :
1. Trouvez le hash du commit qui a ajouté la multiplication
2. Affichez les différences introduites par ce commit
3. Trouvez tous les commits qui contiennent le mot "test" dans le message
4. Affichez l'historique sous forme graphique
5. Comptez le nombre total de lignes ajoutées dans tout l'historique

<details>
<summary>Solution</summary>

```bash
# 1. Trouver le hash du commit multiplication
git log --oneline --grep="multiplication"
# ou
git log --oneline | grep -i "multiplication"

# 2. Voir les différences de ce commit (remplacer abc1234 par le vrai hash)
git show abc1234

# 3. Tous les commits avec "test"
git log --grep="test" --oneline

# 4. Historique graphique
git log --oneline --graph --all

# 5. Compter les lignes ajoutées
git log --stat | grep insertions
# ou plus précis :
git log --numstat | awk '{added += $1} END {print "Total lignes ajoutées:", added}'
```
</details>

---

## Série 2 : Maîtrise des branches

### Exercice 2.1 : Développement en parallèle
**Objectif :** Simuler le développement de plusieurs fonctionnalités en parallèle

**Énoncé :**
À partir du projet calculatrice :
1. Créer une branche `feature-scientific` pour ajouter des fonctions scientifiques (sin, cos, sqrt, log)
2. Créer une branche `feature-history` pour ajouter un historique des calculs
3. Développer les deux fonctionnalités **sans les fusionner**
4. Créer une branche `feature-ui` qui améliore l'interface utilisateur
5. Fusionner dans l'ordre : scientific → master, history → master, ui → master
6. Résoudre tous les conflits qui apparaissent

<details>
<summary>Solution</summary>

```bash
# 1. Branche scientifique
git checkout -b feature-scientific

echo "import math

def sin(x):
    \"\"\"Calcule le sinus (x en radians)\"\"\"
    return math.sin(x)

def cos(x):
    \"\"\"Calcule le cosinus (x en radians)\"\"\"
    return math.cos(x)

def sqrt(x):
    \"\"\"Calcule la racine carrée\"\"\"
    if x < 0:
        raise ValueError(\"Racine carrée de nombre négatif\")
    return math.sqrt(x)

def log(x):
    \"\"\"Calcule le logarithme naturel\"\"\"
    if x <= 0:
        raise ValueError(\"Logarithme de nombre négatif ou nul\")
    return math.log(x)" >> calc.py

# Tests pour les fonctions scientifiques
echo "
def test_scientific():
    import math
    assert abs(calc.sin(math.pi/2) - 1) < 0.0001
    assert abs(calc.cos(0) - 1) < 0.0001
    assert calc.sqrt(9) == 3
    assert abs(calc.log(math.e) - 1) < 0.0001
    print(\"✓ Tests fonctions scientifiques réussis\")" >> test_calc.py

git add calc.py test_calc.py
git commit -m "feat: ajouter fonctions scientifiques"

# 2. Branche historique
git checkout master
git checkout -b feature-history

echo "import calc
import datetime

class CalculatorHistory:
    def __init__(self):
        self.history = []
    
    def add_operation(self, operation, a, b, result):
        entry = {
            'timestamp': datetime.datetime.now(),
            'operation': operation,
            'operands': (a, b),
            'result': result
        }
        self.history.append(entry)
    
    def get_history(self):
        return self.history
    
    def clear_history(self):
        self.history.clear()
    
    def print_history(self):
        print(\"=== Historique des calculs ===\")
        for entry in self.history:
            ts = entry['timestamp'].strftime('%H:%M:%S')
            op = entry['operation']
            a, b = entry['operands']
            result = entry['result']
            print(f\"[{ts}] {a} {op} {b} = {result}\")" > history.py

git add history.py
git commit -m "feat: ajouter système d'historique des calculs"

# 3. Branche UI
git checkout master
git checkout -b feature-ui

# Modifier main.py pour une meilleure interface
cat > main.py << 'EOF'
#!/usr/bin/env python3
import calc

def display_menu():
    print("\n=== Calculatrice Git Avancée ===")
    print("1. Addition")
    print("2. Soustraction") 
    print("3. Multiplication")
    print("4. Division")
    print("0. Quitter")

def get_numbers():
    while True:
        try:
            a = float(input("Premier nombre: "))
            b = float(input("Second nombre: "))
            return a, b
        except ValueError:
            print("Veuillez entrer des nombres valides!")

def main():
    while True:
        display_menu()
        choice = input("Votre choix: ")
        
        if choice == '0':
            print("Au revoir!")
            break
        elif choice == '1':
            a, b = get_numbers()
            result = calc.add(a, b)
            print(f"Résultat: {a} + {b} = {result}")
        elif choice == '2':
            a, b = get_numbers()
            result = calc.subtract(a, b)
            print(f"Résultat: {a} - {b} = {result}")
        elif choice == '3':
            a, b = get_numbers()
            result = calc.multiply(a, b)
            print(f"Résultat: {a} × {b} = {result}")
        elif choice == '4':
            a, b = get_numbers()
            try:
                result = calc.divide(a, b)
                print(f"Résultat: {a} ÷ {b} = {result}")
            except ValueError as e:
                print(f"Erreur: {e}")
        else:
            print("Choix invalide!")

if __name__ == "__main__":
    main()
EOF

git add main.py
git commit -m "feat: améliorer interface utilisateur avec menu interactif"

# 4. Fusionner dans l'ordre
git checkout master

# Fusionner scientific
git merge feature-scientific
# Devrait être un fast-forward ou fusion simple

# Fusionner history  
git merge feature-history
# Peut créer un commit de merge

# Fusionner UI
git merge feature-ui
# Conflit probable sur main.py

# Résoudre le conflit en combinant les fonctionnalités
# Éditer main.py pour inclure les fonctions scientifiques et l'historique

# Version finale de main.py qui combine tout
cat > main.py << 'EOF'
#!/usr/bin/env python3
import calc
import math
from history import CalculatorHistory

history = CalculatorHistory()

def display_menu():
    print("\n=== Calculatrice Git Avancée ===")
    print("1. Addition")
    print("2. Soustraction") 
    print("3. Multiplication")
    print("4. Division")
    print("5. Sinus")
    print("6. Cosinus")
    print("7. Racine carrée")
    print("8. Logarithme naturel")
    print("9. Voir l'historique")
    print("0. Quitter")

def get_number():
    while True:
        try:
            return float(input("Nombre: "))
        except ValueError:
            print("Veuillez entrer un nombre valide!")

def get_numbers():
    while True:
        try:
            a = float(input("Premier nombre: "))
            b = float(input("Second nombre: "))
            return a, b
        except ValueError:
            print("Veuillez entrer des nombres valides!")

def main():
    while True:
        display_menu()
        choice = input("Votre choix: ")
        
        if choice == '0':
            print("Au revoir!")
            break
        elif choice == '1':
            a, b = get_numbers()
            result = calc.add(a, b)
            history.add_operation('+', a, b, result)
            print(f"Résultat: {a} + {b} = {result}")
        elif choice == '2':
            a, b = get_numbers()
            result = calc.subtract(a, b)
            history.add_operation('-', a, b, result)
            print(f"Résultat: {a} - {b} = {result}")
        elif choice == '3':
            a, b = get_numbers()
            result = calc.multiply(a, b)
            history.add_operation('×', a, b, result)
            print(f"Résultat: {a} × {b} = {result}")
        elif choice == '4':
            a, b = get_numbers()
            try:
                result = calc.divide(a, b)
                history.add_operation('÷', a, b, result)
                print(f"Résultat: {a} ÷ {b} = {result}")
            except ValueError as e:
                print(f"Erreur: {e}")
        elif choice == '5':
            a = get_number()
            result = calc.sin(a)
            history.add_operation('sin', a, 0, result)
            print(f"Résultat: sin({a}) = {result}")
        elif choice == '6':
            a = get_number()
            result = calc.cos(a)
            history.add_operation('cos', a, 0, result)
            print(f"Résultat: cos({a}) = {result}")
        elif choice == '7':
            a = get_number()
            try:
                result = calc.sqrt(a)
                history.add_operation('√', a, 0, result)
                print(f"Résultat: √{a} = {result}")
            except ValueError as e:
                print(f"Erreur: {e}")
        elif choice == '8':
            a = get_number()
            try:
                result = calc.log(a)
                history.add_operation('ln', a, 0, result)
                print(f"Résultat: ln({a}) = {result}")
            except ValueError as e:
                print(f"Erreur: {e}")
        elif choice == '9':
            history.print_history()
        else:
            print("Choix invalide!")

if __name__ == "__main__":
    main()
EOF

git add main.py
git commit -m "Résoudre conflits et intégrer toutes les fonctionnalités"

# Nettoyer les branches
git branch -d feature-scientific feature-history feature-ui

# Vérifier le résultat
git log --oneline --graph
```
</details>

---

### Exercice 2.2 : Urgence et hotfix
**Objectif :** Gérer une correction urgente pendant un développement en cours

**Énoncé :**
1. Vous êtes en train de développer une nouvelle fonctionnalité sur `feature-complex-numbers`
2. Un bug critique est découvert en production (division par zéro plante l'application)
3. Vous devez créer un hotfix, le corriger et le déployer immédiatement
4. Puis reprendre votre développement en intégrant le hotfix

<details>
<summary>Solution</summary>

```bash
# 1. Commencer le développement de la fonctionnalité
git checkout -b feature-complex-numbers

echo "class ComplexNumber:
    def __init__(self, real, imag):
        self.real = real
        self.imag = imag
    
    def __str__(self):
        return f\"{self.real} + {self.imag}i\"
    
    def add(self, other):
        return ComplexNumber(
            self.real + other.real,
            self.imag + other.imag
        )
    # TODO: implémenter autres opérations" > complex_calc.py

git add complex_calc.py
git commit -m "WIP: commencer implémentation nombres complexes"

# 2. Bug critique découvert ! Arrêter le travail en cours
git status  # Vérifier qu'on a tout commité

# 3. Créer hotfix depuis master
git checkout master
git checkout -b hotfix-division-zero

# Corriger le bug (améliorer la gestion d'erreur)
# Modifier calc.py pour améliorer la division
sed -i 's/raise ValueError("Division par zéro impossible")/print("ERREUR: Division par zéro!"); return float("inf")/' calc.py

git add calc.py
git commit -m "hotfix: améliorer gestion division par zéro"

# 4. Déployer le hotfix (fusionner dans master)
git checkout master
git merge hotfix-division-zero

# Tagger la version corrigée
git tag -a v1.0.1 -m "Version 1.0.1 - Correction division par zéro"

# 5. Reporter le hotfix dans la branche de développement
git checkout feature-complex-numbers
git merge master  # Intégrer le hotfix

# Continuer le développement
echo "    
    def multiply(self, other):
        # (a + bi)(c + di) = (ac - bd) + (ad + bc)i
        return ComplexNumber(
            self.real * other.real - self.imag * other.imag,
            self.real * other.imag + self.imag * other.real
        )" >> complex_calc.py

git add complex_calc.py
git commit -m "feat: implémenter multiplication nombres complexes"

# 6. Nettoyer
git branch -d hotfix-division-zero

# Vérifier l'historique
git log --oneline --graph --all
```
</details>

---

## Série 3 : Collaboration et remotes

### Exercice 3.1 : Simulation d'équipe
**Objectif :** Simuler le travail de 3 développeurs sur le même projet

**Énoncé :**
Simulez 3 développeurs (Alice, Bob, Charlie) travaillant sur un projet :
1. Alice initialise le projet et le pousse sur GitHub
2. Bob clone et ajoute une fonctionnalité
3. Charlie clone aussi et travaille sur autre chose **en parallèle**
4. Bob termine et pousse en premier
5. Charlie essaie de pousser → conflit !
6. Charlie résout le conflit et pousse
7. Alice récupère tout et fait une review

<details>
<summary>Solution</summary>

```bash
# === ALICE ===
mkdir projet-equipe && cd projet-equipe
git init

# Configuration Alice
git config user.name "Alice"
git config user.email "alice@example.com"

echo "# Projet Équipe

Projet collaboratif pour démontrer Git." > README.md
echo "def hello():
    return 'Hello from the team!'" > utils.py

git add .
git commit -m "feat: initialiser projet équipe"

# Créer dépôt sur GitHub et pousser
git remote add origin git@github.com:votre-nom/projet-equipe.git
git push -u origin master

# === BOB ===
cd ..
git clone git@github.com:votre-nom/projet-equipe.git projet-bob
cd projet-bob

git config user.name "Bob"
git config user.email "bob@example.com"

# Bob travaille sur une fonctionnalité
git checkout -b feature-logging

echo "import datetime

def log_message(message):
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    return f'[{timestamp}] {message}'

def log_error(error):
    return log_message(f'ERROR: {error}')" > logger.py

echo "from logger import log_message
from utils import hello

def main():
    print(log_message(hello()))

if __name__ == '__main__':
    main()" > main.py

git add .
git commit -m "feat: ajouter système de logging"

# Bob pousse sa branche et crée une PR
git push -u origin feature-logging

# Bob fusionne sa PR (simulation)
git checkout master
git merge feature-logging
git push origin master

# === CHARLIE (en parallèle) ===
cd ..
git clone git@github.com:votre-nom/projet-equipe.git projet-charlie
cd projet-charlie

git config user.name "Charlie"
git config user.email "charlie@example.com"

# Charlie travaille sur autre chose (avant de récupérer les changements de Bob)
git checkout -b feature-config

echo "import json

class Config:
    def __init__(self):
        self.config = {
            'debug': False,
            'log_level': 'INFO',
            'max_retries': 3
        }
    
    def get(self, key):
        return self.config.get(key)
    
    def set(self, key, value):
        self.config[key] = value
    
    def save(self, filename):
        with open(filename, 'w') as f:
            json.dump(self.config, f, indent=2)" > config.py

# Charlie modifie aussi main.py (différemment de Bob)
echo "from utils import hello
from config import Config

def main():
    config = Config()
    if config.get('debug'):
        print('Debug mode activated')
    print(hello())

if __name__ == '__main__':
    main()" > main.py

git add .
git commit -m "feat: ajouter système de configuration"

# Charlie essaie de pousser mais master a évolué
git checkout master
git push origin master  # ÉCHEC !

# Charlie doit d'abord récupérer les changements
git pull origin master  # CONFLIT sur main.py !

# Résoudre le conflit en combinant les deux approches
cat > main.py << 'EOF'
from logger import log_message
from utils import hello
from config import Config

def main():
    config = Config()
    
    if config.get('debug'):
        print(log_message('Debug mode activated'))
    
    print(log_message(hello()))

if __name__ == '__main__':
    main()
EOF

git add main.py
git commit -m "resolve: combiner logging et configuration"
git push origin master

# === ALICE - Review ===
cd ../projet-equipe
git pull origin master

echo "Alice fait sa review..."
git log --oneline --graph -n 10
python main.py

# Alice approuve et ajoute de la documentation
echo "
## Installation

\`\`\`bash
git clone <url>
cd projet-equipe
python main.py
\`\`\`

## Fonctionnalités
- Logging des messages avec timestamp
- Système de configuration JSON
- Interface simple" >> README.md

git add README.md
git commit -m "docs: ajouter documentation installation et fonctionnalités"
git push origin master
```
</details>

---

### Exercice 3.2 : Contribution Open Source
**Objectif :** Simuler une contribution à un projet open source

**Énoncé :**
1. Forkez un projet existant (ou créez-en un pour la simulation)
2. Identifiez un "bug" ou une amélioration possible
3. Créez une issue pour discuter du problème
4. Développez la correction sur une branche
5. Créez une Pull Request bien documentée
6. Simulez la review et les modifications demandées
7. Finalisez la contribution

<details>
<summary>Solution</summary>

```bash
# 1. Fork et clone (simulation)
git clone git@github.com:original-owner/awesome-project.git
cd awesome-project
git remote add upstream git@github.com:original-owner/awesome-project.git

# 2. Identifier un problème (simulation)
# Supposons qu'il y ait une typo dans README.md et un manque de validation

# 3. Créer une issue (sur GitHub)
# "Bug: Typo in README and missing input validation"

# 4. Développer la correction
git checkout -b fix-typo-and-validation

# Corriger la typo
sed -i 's/recieve/receive/g' README.md

# Ajouter validation (supposons un fichier input.py)
echo "def validate_email(email):
    \"\"\"Valide le format d'un email\"\"\"
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_non_empty(value):
    \"\"\"Vérifie qu'une valeur n'est pas vide\"\"\"
    return value is not None and str(value).strip() != ''

def validate_positive_number(num):
    \"\"\"Vérifie qu'un nombre est positif\"\"\"
    try:
        return float(num) > 0
    except (ValueError, TypeError):
        return False" > validation.py

# Tests pour la validation
echo "import validation

def test_validate_email():
    assert validation.validate_email('test@example.com') == True
    assert validation.validate_email('invalid-email') == False
    assert validation.validate_email('') == False
    print('✓ Tests email validation')

def test_validate_non_empty():
    assert validation.validate_non_empty('hello') == True
    assert validation.validate_non_empty('') == False
    assert validation.validate_non_empty(None) == False
    print('✓ Tests non-empty validation')

def test_validate_positive_number():
    assert validation.validate_positive_number('5') == True
    assert validation.validate_positive_number('-1') == False
    assert validation.validate_positive_number('abc') == False
    print('✓ Tests positive number validation')

if __name__ == '__main__':
    test_validate_email()
    test_validate_non_empty()
    test_validate_positive_number()
    print('All tests passed!')" > test_validation.py

git add .
git commit -m "fix: correct typo in README and add input validation

- Fix 'recieve' -> 'receive' typo in README
- Add email validation with regex
- Add non-empty string validation
- Add positive number validation
- Include comprehensive test suite

Closes #123"

# 5. Pousser et créer PR
git push -u origin fix-typo-and-validation

# 6. Simuler review et modifications demandées
# Le reviewer demande d'améliorer la documentation des fonctions

echo "def validate_email(email):
    \"\"\"
    Valide le format d'un email selon RFC 5322 (simplifié).
    
    Args:
        email (str): L'adresse email à valider
        
    Returns:
        bool: True si l'email est valide, False sinon
        
    Examples:
        >>> validate_email('user@example.com')
        True
        >>> validate_email('invalid-email')
        False
    \"\"\"
    if not email or not isinstance(email, str):
        return False
    
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_non_empty(value):
    \"\"\"
    Vérifie qu'une valeur n'est pas vide ou None.
    
    Args:
        value: La valeur à vérifier (tout type)
        
    Returns:
        bool: True si la valeur n'est pas vide, False sinon
        
    Examples:
        >>> validate_non_empty('hello')
        True
        >>> validate_non_empty('')
        False
        >>> validate_non_empty(None)
        False
    \"\"\"
    return value is not None and str(value).strip() != ''

def validate_positive_number(num):
    \"\"\"
    Vérifie qu'un nombre est strictement positif.
    
    Args:
        num: Le nombre à vérifier (str, int, float)
        
    Returns:
        bool: True si le nombre est positif, False sinon
        
    Examples:
        >>> validate_positive_number(5)
        True
        >>> validate_positive_number('3.14')
        True
        >>> validate_positive_number(-1)
        False
        >>> validate_positive_number('abc')
        False
    \"\"\"
    try:
        return float(num) > 0
    except (ValueError, TypeError):
        return False" > validation.py

git add validation.py
git commit -m "docs: improve function documentation with examples

- Add detailed docstrings with Args, Returns, Examples
- Improve type checking in validate_email
- Follow Google docstring style"

git push origin fix-typo-and-validation

# 7. Maintenir la branche à jour avec upstream
git fetch upstream
git checkout master
git merge upstream/master
git push origin master

git checkout fix-typo-and-validation
git rebase master
git push --force-with-lease origin fix-typo-and-validation

# Final: PR est acceptée et fusionnée
git checkout master
git pull upstream master
git push origin master
git branch -d fix-typo-and-validation
```
</details>

---

## Série 4 : Situations complexes et récupération

### Exercice 4.1 : Récupération après erreurs
**Objectif :** Apprendre à récupérer de situations problématiques

**Énoncé :**
Simules ces erreurs et leur récupération :
1. Commit par erreur avec des informations sensibles
2. Fusion malheureuse qui casse tout
3. Push de force accidentel
4. Perte de commits importants

<details>
<summary>Solution</summary>

```bash
# 1. Commit avec informations sensibles
mkdir recovery-demo && cd recovery-demo
git init

echo "# Projet Demo" > README.md
git add README.md
git commit -m "Initial commit"

# ERREUR: Commit avec mot de passe
echo "DATABASE_PASSWORD=super_secret_123
API_KEY=abc123xyz789
DEBUG=true" > .env

git add .env
git commit -m "feat: add configuration"

# RÉCUPÉRATION: Supprimer le commit et refaire proprement
git reset --soft HEAD~1  # Annule le commit, garde les changements
git reset HEAD .env       # Retire .env de l'index

# Ajouter .env au gitignore
echo ".env
*.secret
config/secrets/*" > .gitignore

# Créer un exemple sans secrets
echo "DATABASE_PASSWORD=your_password_here
API_KEY=your_api_key_here
DEBUG=false" > .env.example

git add .gitignore .env.example
git commit -m "feat: add configuration template and gitignore"

# 2. Fusion qui casse tout
git checkout -b feature-broken

echo "def broken_function():
    # Cette fonction va tout casser
    import os
    os.system('rm -rf /')  # TRÈS DANGEREUX - NE PAS EXÉCUTER
    return 'oops'" > broken.py

git add broken.py
git commit -m "feat: add dangerous function"

git checkout master
git merge feature-broken

# RÉCUPÉRATION: Annuler la fusion
git reset --hard HEAD~1  # Revenir avant la fusion

# Alternative: utiliser revert si déjà poussé
git merge feature-broken  # Refaire la fusion pour la demo
git revert -m 1 HEAD      # Annuler la fusion avec un nouveau commit

# 3. Push de force accidentel (simulation)
# Situation: quelqu'un a fait git push --force et écrasé l'historique
git log --oneline

# RÉCUPÉRATION: utiliser reflog si c'est local
git reflog
# git reset --hard HEAD@{2}  # Revenir à un état antérieur

# Si c'est sur le serveur, espérer avoir des backups ou des clones locaux

# 4. Perte de commits (simulation)
git checkout -b feature-important

echo "def very_important_function():
    # Code très important qu'on ne veut pas perdre
    return 'mission critical code'" > important.py

git add important.py
git commit -m "feat: add very important function"

# Plus de développement
echo "def another_important_function():
    return 'also very important'" >> important.py

git add important.py
git commit -m "feat: add another important function"

# ERREUR: Reset dur par accident
git reset --hard HEAD~2  # Perte des 2 derniers commits !

# RÉCUPÉRATION: utiliser reflog
git reflog
# Identifier les commits perdus et les récupérer
git cherry-pick <hash-commit-1>
git cherry-pick <hash-commit-2>

# Ou créer une nouvelle branche depuis un commit perdu
git checkout -b recovery-branch <hash-commit-perdu>
```
</details>

---

### Exercice 4.2 : Historique complexe et rebase interactif
**Objectif :** Nettoyer un historique compliqué

**Énoncé :**
1. Créez un historique "sale" avec plusieurs petits commits, des typos, des WIP
2. Utilisez rebase interactif pour nettoyer l'historique
3. Réorganisez, fusionnez, et corrigez les messages de commit

<details>
<summary>Solution</summary>

```bash
mkdir histoire-sale && cd histoire-sale
git init

# Créer un historique "sale"
echo "# Projet" > README.md
git add README.md
git commit -m "add readme"

echo "def hello():
    print('bonjour')" > main.py
git add main.py
git commit -m "WIP: add hello"

echo "def hello():
    print('Bonjour!')" > main.py
git add main.py
git commit -m "fix typo"

echo "def goodbye():
    print('Au revoir!')" >> main.py
git add main.py
git commit -m "add goodbye function"

echo "def goodbye():
    print('Au revoir et merci!')" > main.py
echo "def hello():
    print('Bonjour et bienvenue!')" >> main.py
git add main.py
git commit -m "improve messages"

echo "def hello():
    print('Bonjour et bienvenue!')" > main.py
echo "
def goodbye():
    print('Au revoir et merci!')
    
def status():
    print('Tout va bien!')" >> main.py
git add main.py
git commit -m "add status fonction"

echo "def hello():
    print('Bonjour et bienvenue!')" > main.py
echo "
def goodbye():
    print('Au revoir et merci!')
    
def status():
    print('Tout va bien!')" >> main.py
git add main.py
git commit -m "oops forgot to save"

# Historique sale créé
git log --oneline

# NETTOYAGE avec rebase interactif
git rebase -i HEAD~6

# Dans l'éditeur, modifier pour :
# pick abc1234 add readme
# pick def5678 WIP: add hello  
# squash ghi9012 fix typo
# pick jkl3456 add goodbye function
# squash mno7890 improve messages
# squash pqr1234 add status fonction
# drop stu5678 oops forgot to save

# Puis corriger les messages lors du rebase :
# "feat: add hello function with greeting"
# "feat: add goodbye and status functions with improved messages"

# Résultat final : historique propre
git log --oneline
```
</details>

---

## Série 5 : Défis avancés

### Défi 1 : Workflow GitFlow complet
Implémentez un workflow GitFlow complet avec :
- Branches master, develop, feature/*, release/*, hotfix/*
- Gestion des versions avec tags
- Simulation de cycle de développement complet

### Défi 2 : Résolution de conflits multiples
Créez une situation avec conflits sur plusieurs fichiers et branches, puis résolvez systématiquement.

### Défi 3 : Migration de SVN vers Git
Simulez la migration d'un projet SVN (avec historique) vers Git en préservant l'historique.

---

## Grille d'auto-évaluation

### Niveau Débutant ✅
- [ ] Initialiser un dépôt Git
- [ ] Faire des commits atomiques
- [ ] Comprendre les états des fichiers
- [ ] Utiliser .gitignore efficacement
- [ ] Consulter l'historique (log, show, diff)

### Niveau Intermédiaire ✅
- [ ] Créer et gérer des branches
- [ ] Fusionner des branches (merge)
- [ ] Résoudre des conflits simples
- [ ] Utiliser les remotes (clone, push, pull)
- [ ] Collaborer sur GitHub/GitLab

### Niveau Avancé ✅
- [ ] Utiliser rebase et rebase interactif
- [ ] Gérer des conflits complexes
- [ ] Contribuer à des projets open source
- [ ] Récupérer après des erreurs
- [ ] Maintenir un historique propre

### Niveau Expert 🚀
- [ ] Implémenter des workflows complexes (GitFlow, GitHub Flow)
- [ ] Utiliser reflog pour la récupération
- [ ] Scripter des tâches Git répétitives
- [ ] Former d'autres développeurs
- [ ] Optimiser les performances Git sur gros projets

---

Félicitations ! Si vous avez complété ces exercices, vous maîtrisez Git de manière professionnelle. 🎉