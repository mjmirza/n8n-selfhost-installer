#!/bin/bash

# NEXT8N Installation Survey System
# Intelligent questionnaire to determine optimal deployment strategy

# Source colors and utilities
CYAN='\033[0;96m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
RED='\033[0;91m'
MAGENTA='\033[0;95m'
NC='\033[0m'
BOLD='\033[1m'

print_step_header() {
    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${MAGENTA}  STEP $1: $2${NC}"
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

###############################################################################
# STEP 1: Environment Type Detection
###############################################################################
detect_environment_type() {
    print_step_header "1" "Understanding Your Environment"

    echo "Let's understand where you're deploying N8N."
    echo ""
    echo "  1) 💻 Localhost / Development Machine"
    echo "     └─ Testing, development, learning N8N"
    echo ""
    echo "  2) 🖥️  VPS / Cloud Server (DigitalOcean, Linode, Vultr, etc.)"
    echo "     └─ Single dedicated server for production"
    echo ""
    echo "  3) ☁️  Hyperscaler (AWS, Azure, GCP)"
    echo "     └─ Cloud provider with advanced services"
    echo ""
    echo "  4) 🏢 On-Premises / Private Data Center"
    echo "     └─ Self-hosted infrastructure"
    echo ""
    echo "  5) 🎯 Kubernetes Cluster"
    echo "     └─ Already have K8s running"
    echo ""

    while true; do
        read -p "$(echo -e ${CYAN}Select your environment ${NC}${YELLOW}[1-5]${NC}: )" env_choice

        case $env_choice in
            1)
                ENVIRONMENT_TYPE="localhost"
                ENVIRONMENT_NAME="Localhost/Development"
                print_success "Environment: Localhost/Development"
                return 0
                ;;
            2)
                ENVIRONMENT_TYPE="vps"
                ENVIRONMENT_NAME="VPS/Cloud Server"
                print_success "Environment: VPS/Cloud Server"
                return 0
                ;;
            3)
                ENVIRONMENT_TYPE="hyperscaler"
                ENVIRONMENT_NAME="Hyperscaler (AWS/Azure/GCP)"
                print_success "Environment: Hyperscaler"
                detect_hyperscaler
                return 0
                ;;
            4)
                ENVIRONMENT_TYPE="onpremise"
                ENVIRONMENT_NAME="On-Premises"
                print_success "Environment: On-Premises"
                return 0
                ;;
            5)
                ENVIRONMENT_TYPE="kubernetes"
                ENVIRONMENT_NAME="Kubernetes"
                print_success "Environment: Kubernetes"
                return 0
                ;;
            *)
                print_error "Invalid choice. Please select 1-5."
                ;;
        esac
    done
}

detect_hyperscaler() {
    echo ""
    print_info "Which hyperscaler are you using?"
    echo ""
    echo "  1) AWS (Amazon Web Services)"
    echo "  2) Azure (Microsoft Azure)"
    echo "  3) GCP (Google Cloud Platform)"
    echo "  4) Other"
    echo ""

    read -p "$(echo -e ${CYAN}Select provider ${NC}${YELLOW}[1-4]${NC}: )" cloud_choice

    case $cloud_choice in
        1) CLOUD_PROVIDER="AWS" ;;
        2) CLOUD_PROVIDER="Azure" ;;
        3) CLOUD_PROVIDER="GCP" ;;
        4) CLOUD_PROVIDER="Other" ;;
        *) CLOUD_PROVIDER="Unknown" ;;
    esac

    print_success "Cloud Provider: $CLOUD_PROVIDER"
}

###############################################################################
# STEP 2: Organization Size & Use Case
###############################################################################
detect_organization_size() {
    print_step_header "2" "Understanding Your Organization"

    echo "Tell us about your use case to recommend the best deployment."
    echo ""
    echo "  1) 👤 Personal / Solo Developer"
    echo "     └─ Individual use, learning, side projects"
    echo ""
    echo "  2) 🏃 Startup / Small Team (2-10 people)"
    echo "     └─ Growing business, limited budget"
    echo ""
    echo "  3) 🏢 Mid-Size Company (10-50 people)"
    echo "     └─ Established business, production workflows"
    echo ""
    echo "  4) 🏭 Large Enterprise (50+ people)"
    echo "     └─ Mission-critical, high availability required"
    echo ""

    while true; do
        read -p "$(echo -e ${CYAN}Select organization size ${NC}${YELLOW}[1-4]${NC}: )" org_choice

        case $org_choice in
            1)
                ORG_SIZE="personal"
                ORG_NAME="Personal/Solo"
                EXPECTED_USERS="1-2"
                EXPECTED_WORKFLOWS="<500"
                print_success "Organization: Personal/Solo Developer"
                return 0
                ;;
            2)
                ORG_SIZE="startup"
                ORG_NAME="Startup/Small Team"
                EXPECTED_USERS="2-10"
                EXPECTED_WORKFLOWS="500-5,000"
                print_success "Organization: Startup/Small Team"
                return 0
                ;;
            3)
                ORG_SIZE="midsize"
                ORG_NAME="Mid-Size Company"
                EXPECTED_USERS="10-50"
                EXPECTED_WORKFLOWS="5,000-50,000"
                print_success "Organization: Mid-Size Company"
                return 0
                ;;
            4)
                ORG_SIZE="enterprise"
                ORG_NAME="Enterprise"
                EXPECTED_USERS="50+"
                EXPECTED_WORKFLOWS="50,000+"
                print_success "Organization: Enterprise"
                return 0
                ;;
            *)
                print_error "Invalid choice. Please select 1-4."
                ;;
        esac
    done
}

###############################################################################
# STEP 3: Budget & Priorities
###############################################################################
ask_budget_priorities() {
    print_step_header "3" "Budget & Priorities"

    echo "What's your monthly infrastructure budget for N8N?"
    echo ""
    echo "  1) 💵 Minimal (<\$20/month)"
    echo "  2) 💰 Moderate (\$20-100/month)"
    echo "  3) 💎 Flexible (\$100-500/month)"
    echo "  4) 🏦 Enterprise (>\$500/month)"
    echo ""

    while true; do
        read -p "$(echo -e ${CYAN}Select budget range ${NC}${YELLOW}[1-4]${NC}: )" budget_choice

        case $budget_choice in
            1) BUDGET_RANGE="minimal"; print_success "Budget: Minimal (<\$20/month)"; break ;;
            2) BUDGET_RANGE="moderate"; print_success "Budget: Moderate (\$20-100/month)"; break ;;
            3) BUDGET_RANGE="flexible"; print_success "Budget: Flexible (\$100-500/month)"; break ;;
            4) BUDGET_RANGE="enterprise"; print_success "Budget: Enterprise (>\$500/month)"; break ;;
            *) print_error "Invalid choice. Please select 1-4." ;;
        esac
    done

    echo ""
    print_info "What's your top priority?"
    echo ""
    echo "  1) 🚀 Ease of Setup (Get running quickly)"
    echo "  2) 💰 Cost Optimization (Minimal expenses)"
    echo "  3) ⚡ Performance (Fast execution)"
    echo "  4) 🔒 Reliability (High uptime, backups)"
    echo "  5) 📈 Scalability (Handle growth)"
    echo ""

    while true; do
        read -p "$(echo -e ${CYAN}Select priority ${NC}${YELLOW}[1-5]${NC}: )" priority_choice

        case $priority_choice in
            1) PRIORITY="ease"; print_success "Priority: Ease of Setup"; break ;;
            2) PRIORITY="cost"; print_success "Priority: Cost Optimization"; break ;;
            3) PRIORITY="performance"; print_success "Priority: Performance"; break ;;
            4) PRIORITY="reliability"; print_success "Priority: Reliability"; break ;;
            5) PRIORITY="scalability"; print_success "Priority: Scalability"; break ;;
            *) print_error "Invalid choice. Please select 1-5." ;;
        esac
    done
}

###############################################################################
# STEP 4: Technical Experience Level
###############################################################################
ask_experience_level() {
    print_step_header "4" "Technical Experience"

    echo "What's your experience with server administration?"
    echo ""
    echo "  1) 🌱 Beginner (New to servers and deployments)"
    echo "  2) 🌿 Intermediate (Comfortable with Docker, SSH)"
    echo "  3) 🌳 Advanced (Managed production servers)"
    echo "  4) 🚀 Expert (DevOps/SRE experience, Kubernetes)"
    echo ""

    while true; do
        read -p "$(echo -e ${CYAN}Select experience level ${NC}${YELLOW}[1-4]${NC}: )" exp_choice

        case $exp_choice in
            1) EXPERIENCE="beginner"; print_success "Experience: Beginner"; break ;;
            2) EXPERIENCE="intermediate"; print_success "Experience: Intermediate"; break ;;
            3) EXPERIENCE="advanced"; print_success "Experience: Advanced"; break ;;
            4) EXPERIENCE="expert"; print_success "Experience: Expert"; break ;;
            *) print_error "Invalid choice. Please select 1-4." ;;
        esac
    done
}

###############################################################################
# Run Complete Survey
###############################################################################
run_survey() {
    detect_environment_type
    detect_organization_size
    ask_budget_priorities
    ask_experience_level

    # Export all variables
    export ENVIRONMENT_TYPE ENVIRONMENT_NAME CLOUD_PROVIDER
    export ORG_SIZE ORG_NAME EXPECTED_USERS EXPECTED_WORKFLOWS
    export BUDGET_RANGE PRIORITY EXPERIENCE
}

# Export functions
export -f detect_environment_type
export -f detect_organization_size
export -f ask_budget_priorities
export -f ask_experience_level
export -f run_survey
