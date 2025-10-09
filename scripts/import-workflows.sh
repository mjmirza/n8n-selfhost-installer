#!/bin/bash

###############################################################################
# NEXT8N Workflow Import Script
# Imports pre-built workflow templates into N8N instance
###############################################################################

set -e

# Colors
CYAN='\033[0;96m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
RED='\033[0;91m'
MAGENTA='\033[0;95m'
NC='\033[0m'
BOLD='\033[1m'

print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_header() {
    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${MAGENTA}  $1${NC}"
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

###############################################################################
# Configuration
###############################################################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WORKFLOWS_DIR="$PROJECT_ROOT/workflows/templates"
N8N_CONTAINER_NAME="n8n"
IMPORT_METHOD="cli"  # cli, api, or docker-cli

# Parse arguments
CATEGORY=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --category=*)
            CATEGORY="${1#*=}"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --method=*)
            IMPORT_METHOD="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--category=CATEGORY] [--dry-run] [--method=cli|api|docker-cli]"
            exit 1
            ;;
    esac
done

###############################################################################
# Check N8N Status
###############################################################################
check_n8n_running() {
    print_header "🔍 Checking N8N Status"

    if docker ps | grep -q "$N8N_CONTAINER_NAME"; then
        print_success "N8N container is running"
        return 0
    else
        print_error "N8N container is not running"
        print_info "Start N8N first: docker compose up -d"
        exit 1
    fi
}

###############################################################################
# Wait for N8N to be Ready
###############################################################################
wait_for_n8n() {
    print_info "Waiting for N8N to be ready..."
    local max_attempts=30
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:5678/healthz > /dev/null 2>&1; then
            print_success "N8N is ready"
            return 0
        fi
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done

    print_error "N8N did not become ready in time"
    exit 1
}

###############################################################################
# Import via Docker CLI (Most Compatible)
###############################################################################
import_via_docker_cli() {
    local workflow_file="$1"
    local workflow_name=$(basename "$workflow_file" .json)

    print_info "Importing: $workflow_name"

    # Copy workflow into container
    docker cp "$workflow_file" "${N8N_CONTAINER_NAME}:/tmp/workflow.json"

    # Import using n8n CLI inside container
    docker exec "$N8N_CONTAINER_NAME" n8n import:workflow --input=/tmp/workflow.json

    # Clean up
    docker exec "$N8N_CONTAINER_NAME" rm /tmp/workflow.json

    print_success "Imported: $workflow_name"
}

###############################################################################
# Import via N8N API
###############################################################################
import_via_api() {
    local workflow_file="$1"
    local workflow_name=$(basename "$workflow_file" .json)

    print_info "Importing via API: $workflow_name"

    # Get API key from environment or .env
    local api_key="${N8N_API_KEY:-}"

    if [ -z "$api_key" ]; then
        print_warning "N8N_API_KEY not set, skipping API import"
        print_info "Set N8N_API_KEY environment variable to use API import"
        return 1
    fi

    # Import workflow
    local response=$(curl -s -X POST http://localhost:5678/api/v1/workflows \
        -H "X-N8N-API-KEY: $api_key" \
        -H "Content-Type: application/json" \
        -d @"$workflow_file")

    if echo "$response" | grep -q "id"; then
        print_success "Imported: $workflow_name"
    else
        print_error "Failed to import: $workflow_name"
        echo "$response"
    fi
}

###############################################################################
# Import via Host CLI (if n8n installed locally)
###############################################################################
import_via_host_cli() {
    local workflow_file="$1"
    local workflow_name=$(basename "$workflow_file" .json)

    print_info "Importing: $workflow_name"

    if command -v n8n &> /dev/null; then
        n8n import:workflow --input="$workflow_file"
        print_success "Imported: $workflow_name"
    else
        print_error "n8n CLI not available on host"
        return 1
    fi
}

###############################################################################
# Import Workflow Based on Method
###############################################################################
import_workflow() {
    local workflow_file="$1"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would import: $(basename "$workflow_file")"
        return 0
    fi

    case $IMPORT_METHOD in
        cli)
            import_via_host_cli "$workflow_file" || import_via_docker_cli "$workflow_file"
            ;;
        api)
            import_via_api "$workflow_file"
            ;;
        docker-cli)
            import_via_docker_cli "$workflow_file"
            ;;
        *)
            print_error "Unknown import method: $IMPORT_METHOD"
            exit 1
            ;;
    esac
}

###############################################################################
# Find and Import Workflows
###############################################################################
import_workflows() {
    print_header "📦 Importing Workflow Templates"

    local workflow_count=0
    local success_count=0

    # Determine search path
    if [ -n "$CATEGORY" ]; then
        local search_path="$WORKFLOWS_DIR/$CATEGORY"
        print_info "Importing category: $CATEGORY"
    else
        local search_path="$WORKFLOWS_DIR"
        print_info "Importing all workflows"
    fi

    if [ ! -d "$search_path" ]; then
        print_error "Workflow directory not found: $search_path"
        exit 1
    fi

    # Find and import workflows
    for workflow_file in $(find "$search_path" -name "*.json" -type f); do
        workflow_count=$((workflow_count + 1))

        if import_workflow "$workflow_file"; then
            success_count=$((success_count + 1))
        fi
    done

    echo ""
    print_header "📊 Import Summary"
    echo "  Total workflows found: $workflow_count"
    echo "  Successfully imported: $success_count"
    echo "  Failed: $((workflow_count - success_count))"
    echo ""

    if [ $success_count -eq $workflow_count ]; then
        print_success "All workflows imported successfully!"
    elif [ $success_count -gt 0 ]; then
        print_warning "Some workflows failed to import"
    else
        print_error "No workflows were imported"
    fi
}

###############################################################################
# Main
###############################################################################
main() {
    print_header "🔄 NEXT8N Workflow Importer"

    if [ "$DRY_RUN" = false ]; then
        check_n8n_running
        wait_for_n8n
    fi

    import_workflows

    echo ""
    print_info "💡 Don't forget to configure credentials and API keys for imported workflows"
    echo ""
    print_info "🌐 Need help? https://services.next8n.com/"
    echo ""
}

main "$@"
