#!/bin/bash

# Configuration globale pour les scripts de génération
# Ce fichier contient les paramètres partagés entre tous les scripts

# === CONFIGURATION GÉNÉRALE ===
export FORMATION_TITLE="Formation Linux"
export FORMATION_AUTHOR="Formation Linux - Prima Solutions"
export FORMATION_VERSION="1.0"

# === CHEMINS ===
export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SCRIPTS_DIR="$PROJECT_ROOT/scripts"
export TEMPLATES_DIR="$SCRIPTS_DIR/templates"
export BUILD_DIR="$PROJECT_ROOT/build"
export SUPPORTS_DIR="$PROJECT_ROOT/supports"
export TP_DIR="$PROJECT_ROOT/travaux_pratiques"
export RESOURCES_DIR="$PROJECT_ROOT/ressources"

# === CONFIGURATION PANDOC ===
export PDF_ENGINE="pdflatex"
export HIGHLIGHT_STYLE="tango"
export TOC_DEPTH=3
export FONT_SIZE="11pt"
export PAPER_SIZE="a4"
export MARGIN="2.5cm"
export LANGUAGE="fr"

# === MODULES DISPONIBLES ===
# Format: "numero:nom_interne:titre_affichage"
export AVAILABLE_MODULES=(
    "01:decouverte:Découverte et premiers pas"
    "02:navigation:Navigation et système de fichiers"
    "03:manipulation:Manipulation de fichiers et dossiers"
    "04:consultation:Consultation et édition de fichiers"
    "05:droits:Droits et sécurité"
    "06:processus:Processus et système"
    "07:reseaux:Réseaux et services"
    "08:automatisation:Automatisation et scripts"
)

# === MODULES POUR FORMATION ACCÉLÉRÉE ===
# Modules inclus dans la version accélérée (8h)
export ACCELERATED_MODULES=(
    "01:decouverte"
    "02:navigation" 
    "03:manipulation"
    "04:consultation"
    "05:droits"
)

# === COULEURS POUR LES LOGS ===
export COLOR_RED='\033[0;31m'
export COLOR_GREEN='\033[0;32m'
export COLOR_YELLOW='\033[1;33m'
export COLOR_BLUE='\033[0;34m'
export COLOR_PURPLE='\033[0;35m'
export COLOR_CYAN='\033[0;36m'
export COLOR_NC='\033[0m' # No Color

# === FONCTIONS UTILITAIRES ===

# Fonction de log avec couleur
log_info() {
    echo -e "${COLOR_BLUE}ℹ️  $1${COLOR_NC}"
}

log_success() {
    echo -e "${COLOR_GREEN}✅ $1${COLOR_NC}"
}

log_warning() {
    echo -e "${COLOR_YELLOW}⚠️  $1${COLOR_NC}"
}

log_error() {
    echo -e "${COLOR_RED}❌ $1${COLOR_NC}"
}

log_step() {
    echo -e "${COLOR_PURPLE}🔄 $1${COLOR_NC}"
}

# Fonction pour vérifier les dépendances
check_dependencies() {
    local missing_deps=()
    
    # Vérification de pandoc
    if ! command -v pandoc &> /dev/null; then
        missing_deps+=("pandoc")
    fi
    
    # Vérification de pdflatex
    if ! command -v pdflatex &> /dev/null; then
        missing_deps+=("texlive-latex-base")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Dépendances manquantes: ${missing_deps[*]}"
        log_info "Installation sur Ubuntu/Debian:"
        log_info "sudo apt-get update"
        log_info "sudo apt-get install pandoc texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended"
        return 1
    fi
    
    return 0
}

# Fonction pour créer les répertoires nécessaires
ensure_directories() {
    mkdir -p "$BUILD_DIR"
    mkdir -p "$BUILD_DIR/supports_par_module"
    mkdir -p "$BUILD_DIR/temp"
}

# Fonction pour nettoyer les fichiers temporaires
cleanup_temp() {
    rm -rf "$BUILD_DIR/temp"
    rm -f "$BUILD_DIR"/*.tmp
    rm -f "$BUILD_DIR"/*.aux
    rm -f "$BUILD_DIR"/*.log
    rm -f "$BUILD_DIR"/*.toc
}

# Fonction pour obtenir la date formatée
get_formatted_date() {
    date "+%d/%m/%Y"
}

# Fonction pour parser les informations d'un module
parse_module_info() {
    local module_string="$1"
    local field="$2"
    
    IFS=':' read -r num name title <<< "$module_string"
    
    case "$field" in
        "number") echo "$num" ;;
        "name") echo "$name" ;;
        "title") echo "$title" ;;
    esac
}

# Export des fonctions pour qu'elles soient disponibles dans les autres scripts
export -f log_info log_success log_warning log_error log_step
export -f check_dependencies ensure_directories cleanup_temp
export -f get_formatted_date parse_module_info