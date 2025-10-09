#!/bin/bash

###############################################################################
# Intelligent Deployment Tier Detection Script
# Analyzes system resources and environment to recommend best deployment tier
###############################################################################

# Colors
CYAN='\033[0;96m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
MAGENTA='\033[0;95m'
NC='\033[0m'
BOLD='\033[1m'

print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_header() { echo -e "${BOLD}${MAGENTA}$1${NC}"; }

detect_deployment_tier() {
    local score=0
    local recommended_tier="simple"

    print_header "\n🔍 Analyzing System for Optimal Deployment Tier..."
    echo ""

    # 1. Check for Kubernetes
    print_info "Checking for Kubernetes availability..."
    if command -v kubectl &> /dev/null; then
        if kubectl version --client &> /dev/null 2>&1; then
            print_success "Kubernetes client detected"
            if kubectl cluster-info &> /dev/null 2>&1; then
                print_success "Kubernetes cluster accessible!"
                score=$((score + 40))
                recommended_tier="kubernetes"
            else
                print_warning "Kubernetes client found but no cluster accessible"
            fi
        fi
    else
        print_info "Kubernetes not detected"
    fi
    echo ""

    # 2. Check System Resources
    print_info "Analyzing system resources..."
    TOTAL_RAM=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || sysctl -n hw.memsize 2>/dev/null | awk '{print $1/1024/1024}')
    CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "2")
    DISK_SPACE=$(df -BG / 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || echo "20")

    print_info "RAM: ${TOTAL_RAM}MB"
    print_info "CPU Cores: ${CPU_CORES}"
    print_info "Disk Space: ${DISK_SPACE}GB"

    if [ "$TOTAL_RAM" -ge 16000 ]; then
        score=$((score + 30))
        print_success "Excellent RAM for advanced deployments"
    elif [ "$TOTAL_RAM" -ge 8000 ]; then
        score=$((score + 20))
        print_success "Good RAM for production workloads"
    elif [ "$TOTAL_RAM" -ge 4000 ]; then
        score=$((score + 10))
        print_info "Adequate RAM for standard deployment"
    else
        print_warning "Limited RAM - simple deployment recommended"
    fi

    if [ "$CPU_CORES" -ge 8 ]; then
        score=$((score + 15))
    elif [ "$CPU_CORES" -ge 4 ]; then
        score=$((score + 10))
    fi
    echo ""

    # 3. Check existing Docker containers
    print_info "Checking for existing infrastructure..."
    if command -v docker &> /dev/null; then
        if docker ps &> /dev/null 2>&1; then
            if docker ps --format '{{.Names}}' | grep -q postgres; then
                print_success "PostgreSQL container detected"
                score=$((score + 10))
            fi
            if docker ps --format '{{.Names}}' | grep -q redis; then
                print_success "Redis container detected - worker mode capable"
                score=$((score + 10))
            fi
        fi
    fi
    echo ""

    # 4. Determine recommended tier
    if [ "$recommended_tier" != "kubernetes" ]; then
        if [ "$score" -ge 40 ]; then
            recommended_tier="postgres-worker"
        elif [ "$score" -ge 20 ]; then
            recommended_tier="postgres"
        else
            recommended_tier="simple"
        fi
    fi

    # Display results
    print_header "📊 Analysis Results:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  System Score: $score/100"
    echo "  Recommended Tier: ${BOLD}$recommended_tier${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Explain recommendation
    case "$recommended_tier" in
        "simple")
            print_info "✨ Tier 1: Simple (Docker + Caddy)"
            echo "  • Perfect for personal use and testing"
            echo "  • Quick 5-minute setup"
            echo "  • Lowest cost (~\$5-10/month)"
            echo "  • SQLite database (file-based)"
            ;;
        "postgres")
            print_info "🚀 Tier 2: PostgreSQL (Docker + PostgreSQL + Caddy)"
            echo "  • Ideal for small teams (5-20 users)"
            echo "  • Production-grade database"
            echo "  • Better performance than SQLite"
            echo "  • Cost: ~\$10-20/month"
            ;;
        "postgres-worker")
            print_info "⚡ Tier 3: PostgreSQL + Worker (Queue-Based)"
            echo "  • Best for medium-large teams (20-100+ users)"
            echo "  • Horizontal scaling with workers"
            echo "  • Queue-based execution (Redis)"
            echo "  • Can handle 10,000+ workflows/day"
            echo "  • Cost: ~\$20-50/month"
            ;;
        "kubernetes")
            print_info "🏢 Tier 4: Kubernetes (Enterprise Cloud-Native)"
            echo "  • Enterprise-grade deployment"
            echo "  • Auto-scaling and high availability"
            echo "  • Multi-node cluster support"
            echo "  • Best for 100+ users"
            echo "  • Cost: ~\$50-500+/month"
            ;;
    esac
    echo ""

    # Return the recommended tier
    echo "$recommended_tier"
}

# Interactive tier selection
select_deployment_tier() {
    local detected_tier=$(detect_deployment_tier)

    print_header "🎯 Select Deployment Tier:"
    echo ""
    echo "  1) Simple (Docker + Caddy)"
    echo "     └─ Personal use, testing, <500 workflows"
    echo ""
    echo "  2) PostgreSQL (Docker + PostgreSQL + Caddy)"
    echo "     └─ Small teams, 1,000-5,000 workflows"
    echo ""
    echo "  3) PostgreSQL + Worker (Queue-Based)"
    echo "     └─ Production, 10,000+ workflows/day"
    echo ""
    echo "  4) Kubernetes (Enterprise)"
    echo "     └─ Cloud-native, auto-scaling, HA"
    echo ""
    echo "  5) Auto-Detect (Recommended: $detected_tier)"
    echo ""

    while true; do
        read -p "$(echo -e ${CYAN}Select deployment tier ${NC}${YELLOW}[1-5]${NC}: )" tier_choice

        case $tier_choice in
            1) echo "simple"; return 0 ;;
            2) echo "postgres"; return 0 ;;
            3) echo "postgres-worker"; return 0 ;;
            4) echo "kubernetes"; return 0 ;;
            5) echo "$detected_tier"; return 0 ;;
            *) print_warning "Invalid choice. Please select 1-5." ;;
        esac
    done
}

# Run detection if script is executed directly
if [ "${BASH_SOURCE[0]}" -eq "${0}" ]; then
    select_deployment_tier
fi
