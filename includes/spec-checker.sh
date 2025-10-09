#!/bin/bash

# NEXT8N Specification Checker
# Real-time system analysis with intelligent recommendations

# Source colors
CYAN='\033[0;96m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
RED='\033[0;91m'
MAGENTA='\033[0;95m'
BLUE='\033[0;94m'
NC='\033[0m'
BOLD='\033[1m'

print_spec_header() {
    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${MAGENTA}  $1${NC}"
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_check() { echo -e "${BLUE}🔍 $1${NC}"; }

###############################################################################
# System Specification Detection
###############################################################################
detect_system_specs() {
    print_spec_header "🔍 Analyzing Your Server Specifications"

    print_check "Detecting system specifications..."
    echo ""

    # RAM Detection
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        TOTAL_RAM=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024)}')
    else
        # Linux
        TOTAL_RAM=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}')
    fi

    # CPU Detection
    if [[ "$OSTYPE" == "darwin"* ]]; then
        CPU_CORES=$(sysctl -n hw.ncpu)
    else
        CPU_CORES=$(nproc 2>/dev/null || grep -c processor /proc/cpuinfo)
    fi

    # Disk Space Detection
    if [[ "$OSTYPE" == "darwin"* ]]; then
        DISK_SPACE=$(df -g / | awk 'NR==2 {print $4}')
    else
        DISK_SPACE=$(df -BG / 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//')
    fi

    # OS Detection
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_NAME="macOS"
        OS_VERSION=$(sw_vers -productVersion)
    else
        OS_NAME="Unknown"
        OS_VERSION="Unknown"
    fi

    # Display Current Specs
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                 CURRENT SYSTEM SPECIFICATIONS               │"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  Operating System: $OS_NAME $OS_VERSION"
    echo "│  RAM:              ${TOTAL_RAM} MB"
    echo "│  CPU Cores:        ${CPU_CORES}"
    echo "│  Available Disk:   ${DISK_SPACE} GB"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    # Export variables
    export TOTAL_RAM CPU_CORES DISK_SPACE OS_NAME OS_VERSION
}

###############################################################################
# Specification Analysis & Recommendations
###############################################################################
analyze_specifications() {
    print_spec_header "📊 Specification Analysis & Recommendations"

    local ram_score=0
    local cpu_score=0
    local disk_score=0
    local total_score=0

    # RAM Analysis
    print_check "Analyzing RAM..."
    if [ "$TOTAL_RAM" -ge 16000 ]; then
        print_success "RAM: ${TOTAL_RAM}MB - Excellent! Perfect for enterprise deployments"
        ram_score=100
        RAM_RATING="Excellent"
    elif [ "$TOTAL_RAM" -ge 8000 ]; then
        print_success "RAM: ${TOTAL_RAM}MB - Great! Suitable for production with workers"
        ram_score=80
        RAM_RATING="Great"
    elif [ "$TOTAL_RAM" -ge 4000 ]; then
        print_warning "RAM: ${TOTAL_RAM}MB - Good for standard production"
        ram_score=60
        RAM_RATING="Good"
    elif [ "$TOTAL_RAM" -ge 2000 ]; then
        print_warning "RAM: ${TOTAL_RAM}MB - Adequate for basic deployment"
        ram_score=40
        RAM_RATING="Adequate"
    else
        print_error "RAM: ${TOTAL_RAM}MB - Below minimum recommended (2GB)"
        ram_score=20
        RAM_RATING="Low"
    fi

    # CPU Analysis
    print_check "Analyzing CPU..."
    if [ "$CPU_CORES" -ge 8 ]; then
        print_success "CPU: ${CPU_CORES} cores - Excellent for multi-worker setups"
        cpu_score=100
        CPU_RATING="Excellent"
    elif [ "$CPU_CORES" -ge 4 ]; then
        print_success "CPU: ${CPU_CORES} cores - Great for production workloads"
        cpu_score=80
        CPU_RATING="Great"
    elif [ "$CPU_CORES" -ge 2 ]; then
        print_warning "CPU: ${CPU_CORES} cores - Adequate for moderate use"
        cpu_score=60
        CPU_RATING="Adequate"
    else
        print_error "CPU: ${CPU_CORES} core(s) - May experience slow performance"
        cpu_score=40
        CPU_RATING="Low"
    fi

    # Disk Analysis
    print_check "Analyzing Disk Space..."
    if [ "$DISK_SPACE" -ge 100 ]; then
        print_success "Disk: ${DISK_SPACE}GB - Excellent storage capacity"
        disk_score=100
        DISK_RATING="Excellent"
    elif [ "$DISK_SPACE" -ge 50 ]; then
        print_success "Disk: ${DISK_SPACE}GB - Great for standard deployments"
        disk_score=80
        DISK_RATING="Great"
    elif [ "$DISK_SPACE" -ge 20 ]; then
        print_warning "Disk: ${DISK_SPACE}GB - Adequate for basic deployment"
        disk_score=60
        DISK_RATING="Adequate"
    else
        print_error "Disk: ${DISK_SPACE}GB - Below minimum recommended (20GB)"
        disk_score=40
        DISK_RATING="Low"
    fi

    # Calculate total score
    total_score=$(( (ram_score + cpu_score + disk_score) / 3 ))

    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                    SPECIFICATION SCORE                      │"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  RAM Score:        ${ram_score}/100  (${RAM_RATING})"
    echo "│  CPU Score:        ${cpu_score}/100  (${CPU_RATING})"
    echo "│  Disk Score:       ${disk_score}/100  (${DISK_RATING})"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  OVERALL SCORE:    ${total_score}/100"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    export SPEC_SCORE=$total_score
    export RAM_RATING CPU_RATING DISK_RATING
}

###############################################################################
# Generate Recommendations Based on Specs + Survey
###############################################################################
generate_recommendations() {
    print_spec_header "🎯 Personalized Deployment Recommendations"

    local recommended_tier=""
    local reasoning=()

    # Start with spec-based recommendation
    if [ "$SPEC_SCORE" -ge 80 ]; then
        recommended_tier="postgres-worker"
        reasoning+=("Your server specs are excellent (${SPEC_SCORE}/100)")
    elif [ "$SPEC_SCORE" -ge 60 ]; then
        recommended_tier="postgres"
        reasoning+=("Your server specs are good (${SPEC_SCORE}/100)")
    else
        recommended_tier="simple"
        reasoning+=("Your server specs are adequate (${SPEC_SCORE}/100)")
    fi

    # Adjust for environment
    if [ "$ENVIRONMENT_TYPE" = "localhost" ]; then
        recommended_tier="simple"
        reasoning+=("Localhost environment - simple setup recommended")
    elif [ "$ENVIRONMENT_TYPE" = "kubernetes" ]; then
        recommended_tier="kubernetes"
        reasoning+=("Kubernetes environment detected")
    fi

    # Adjust for organization size
    if [ "$ORG_SIZE" = "enterprise" ]; then
        if [ "$recommended_tier" != "kubernetes" ]; then
            recommended_tier="postgres-worker"
        fi
        reasoning+=("Enterprise scale requires robust infrastructure")
    elif [ "$ORG_SIZE" = "personal" ] && [ "$recommended_tier" = "postgres-worker" ]; then
        recommended_tier="simple"
        reasoning+=("Personal use - simple deployment is more cost-effective")
    fi

    # Adjust for budget
    if [ "$BUDGET_RANGE" = "minimal" ] && [ "$recommended_tier" != "simple" ]; then
        reasoning+=("⚠️  Budget constraints detected - consider 'simple' tier")
    fi

    # Adjust for priority
    if [ "$PRIORITY" = "ease" ] && [ "$recommended_tier" != "simple" ]; then
        reasoning+=("💡 For easiest setup, consider 'simple' tier")
    elif [ "$PRIORITY" = "cost" ] && [ "$recommended_tier" = "postgres-worker" ]; then
        reasoning+=("💡 For cost optimization, consider 'postgres' tier")
    fi

    # Adjust for experience
    if [ "$EXPERIENCE" = "beginner" ] && [ "$recommended_tier" != "simple" ]; then
        reasoning+=("🌱 For beginners, 'simple' tier is easiest to manage")
    fi

    # Display recommendation
    echo "Based on your responses and server analysis:"
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│           RECOMMENDED DEPLOYMENT TIER                       │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    case $recommended_tier in
        "simple")
            echo -e "${GREEN}${BOLD}  ✨ TIER 1: Simple (Docker + Caddy)${NC}"
            echo ""
            echo "  Perfect for:"
            echo "  • Personal projects and testing"
            echo "  • Quick deployment (5 minutes)"
            echo "  • Cost: \$5-10/month"
            echo "  • No database management needed"
            ;;
        "postgres")
            echo -e "${GREEN}${BOLD}  🚀 TIER 2: PostgreSQL (Production-Grade)${NC}"
            echo ""
            echo "  Perfect for:"
            echo "  • Small-medium teams (5-20 users)"
            echo "  • Production workloads"
            echo "  • Cost: \$10-20/month"
            echo "  • Better performance & reliability"
            ;;
        "postgres-worker")
            echo -e "${GREEN}${BOLD}  ⚡ TIER 3: PostgreSQL + Worker (Scalable)${NC}"
            echo ""
            echo "  Perfect for:"
            echo "  • Medium-large teams (20-100+ users)"
            echo "  • High workflow volume"
            echo "  • Cost: \$20-50/month"
            echo "  • Horizontal scaling capability"
            ;;
        "kubernetes")
            echo -e "${GREEN}${BOLD}  🏢 TIER 4: Kubernetes (Enterprise)${NC}"
            echo ""
            echo "  Perfect for:"
            echo "  • Enterprise deployments"
            echo "  • Mission-critical workflows"
            echo "  • Cost: \$50-500+/month"
            echo "  • Auto-scaling & high availability"
            ;;
    esac

    echo ""
    echo "  Reasoning:"
    for reason in "${reasoning[@]}"; do
        echo "    • $reason"
    done
    echo ""

    export RECOMMENDED_TIER=$recommended_tier
}

###############################################################################
# Show Upgrade Path Recommendations
###############################################################################
show_upgrade_recommendations() {
    echo ""
    print_spec_header "💡 Future Growth Path"

    case $RECOMMENDED_TIER in
        "simple")
            echo "  Current: Simple Deployment"
            echo "  Next Step: PostgreSQL (when you have 5+ active users)"
            echo "  Future: Worker Mode (when exceeding 5,000 workflows)"
            ;;
        "postgres")
            echo "  Current: PostgreSQL Deployment"
            echo "  Next Step: Worker Mode (when you need horizontal scaling)"
            echo "  Future: Kubernetes (for enterprise-grade requirements)"
            ;;
        "postgres-worker")
            echo "  Current: Worker Mode Deployment"
            echo "  Next Step: Kubernetes (for auto-scaling & HA)"
            ;;
        "kubernetes")
            echo "  Current: Enterprise Kubernetes Deployment"
            echo "  You're at the highest tier! 🎉"
            ;;
    esac
    echo ""
}

###############################################################################
# Run Complete Spec Check
###############################################################################
run_spec_check() {
    detect_system_specs
    analyze_specifications
    generate_recommendations
    show_upgrade_recommendations
}

# Export functions
export -f detect_system_specs
export -f analyze_specifications
export -f generate_recommendations
export -f run_spec_check
