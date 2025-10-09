#!/bin/bash

###############################################################################
# NEXT8N N8N Rapid Deploy - Guided Installer
#
# A baby-steps, intelligent installer that surveys your environment,
# checks specifications, and guides you through optimal N8N deployment
#
# URL: https://services.next8n.com/
###############################################################################

set -e  # Exit on error

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required modules
source "$SCRIPT_DIR/includes/banner.sh" || { echo "Error: Cannot load banner.sh"; exit 1; }
source "$SCRIPT_DIR/includes/survey.sh" || { echo "Error: Cannot load survey.sh"; exit 1; }
source "$SCRIPT_DIR/includes/spec-checker.sh" || { echo "Error: Cannot load spec-checker.sh"; exit 1; }

# Colors for output
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
CYAN='\033[0;96m'
MAGENTA='\033[0;95m'
NC='\033[0m'
BOLD='\033[1m'

###############################################################################
# Helper Functions
###############################################################################
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
print_step() {
    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${MAGENTA}$1${NC}"
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

pause_for_user() {
    echo ""
    read -p "$(echo -e ${CYAN}Press ENTER to continue...${NC})"
}

###############################################################################
# Check Root Privileges
###############################################################################
check_root() {
    if [ "$EUID" -ne 0 ]; then
        show_banner
        print_error "This installer requires root privileges."
        echo ""
        print_info "Please run: sudo bash $0"
        echo ""
        exit 1
    fi
}

###############################################################################
# Installation Summary
###############################################################################
show_installation_summary() {
    print_step "📋 Installation Summary"

    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                  DEPLOYMENT CONFIGURATION                   │"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  Environment:      $ENVIRONMENT_NAME"
    echo "│  Organization:     $ORG_NAME ($EXPECTED_USERS users)"
    echo "│  Budget Range:     $BUDGET_RANGE"
    echo "│  Priority:         $PRIORITY"
    echo "│  Experience:       $EXPERIENCE"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  Server RAM:       ${TOTAL_RAM}MB ($RAM_RATING)"
    echo "│  Server CPU:       ${CPU_CORES} cores ($CPU_RATING)"
    echo "│  Available Disk:   ${DISK_SPACE}GB ($DISK_RATING)"
    echo "│  Overall Score:    ${SPEC_SCORE}/100"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  RECOMMENDED:      $RECOMMENDED_TIER"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    print_info "This configuration will give you the best N8N experience for your needs."
    echo ""

    while true; do
        read -p "$(echo -e ${CYAN}Proceed with recommended deployment? ${NC}${YELLOW}[Y/n]${NC}: )" confirm

        case ${confirm:-Y} in
            [Yy]* )
                print_success "Great! Let's proceed with the installation."
                return 0
                ;;
            [Nn]* )
                print_warning "Installation cancelled by user."
                echo ""
                print_info "Need help choosing? Contact us: https://services.next8n.com/"
                exit 0
                ;;
            * )
                print_error "Please answer Y or n."
                ;;
        esac
    done
}

###############################################################################
# Main Guided Installation Flow
###############################################################################
main() {
    # Display banner
    show_banner
    show_welcome

    # Check root
    check_root

    print_info "This intelligent installer will analyze your environment and recommend"
    print_info "the optimal N8N deployment strategy for your infrastructure."
    pause_for_user

    # Run survey
    run_survey

    print_success "Survey complete! Now analyzing your server..."
    pause_for_user

    # Check specifications and generate recommendations
    run_spec_check

    pause_for_user

    # Show summary and confirm
    show_installation_summary

    # Based on recommended tier, call appropriate installer
    print_step "🚀 Starting Installation"

    case $RECOMMENDED_TIER in
        "simple")
            print_info "Installing: Simple (Docker + Caddy) Deployment"
            # Call existing install.sh with simple tier
            export DEPLOYMENT_TIER="simple"
            ;;
        "postgres")
            print_info "Installing: PostgreSQL Production Deployment"
            export DEPLOYMENT_TIER="postgres"
            ;;
        "postgres-worker")
            print_info "Installing: PostgreSQL + Worker (Scalable) Deployment"
            export DEPLOYMENT_TIER="postgres-worker"
            ;;
        "kubernetes")
            print_info "Installing: Kubernetes Enterprise Deployment"
            export DEPLOYMENT_TIER="kubernetes"
            ;;
    esac

    print_info "Transferring to main installer..."
    echo ""

    # Note: This would call the main install.sh with the selected tier
    print_warning "Integration with main installer pending..."
    print_info "Selected tier: $DEPLOYMENT_TIER"

    echo ""
    show_footer
}

###############################################################################
# Run Main
###############################################################################
main "$@"
