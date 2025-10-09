#!/bin/bash

###############################################################################
# NEXT8N Ollama Model Management Script
# Intelligently downloads and manages LLM models based on hardware capabilities
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

# Source GPU detector if available
if [ -f "$PROJECT_ROOT/includes/gpu-detector.sh" ]; then
    source "$PROJECT_ROOT/includes/gpu-detector.sh"
else
    print_warning "GPU detector not found - using defaults"
fi

OLLAMA_CONTAINER="ollama"

###############################################################################
# Model Catalog
###############################################################################
declare -A MODEL_INFO

# Format: "model_tag|size_gb|vram_needed_mb|description"
MODEL_INFO=(
    # Large Models (13B+)
    ["llama3.1:13b"]="13B|7.4|16000|Llama 3.1 13B - Best general purpose"
    ["codellama:13b"]="13B|7.4|16000|Code Llama 13B - Best for coding"
    ["mistral:latest"]="7B|4.1|8000|Mistral 7B - Fast and powerful"

    # Medium Models (7B)
    ["llama3.1:7b"]="7B|4.7|8000|Llama 3.1 7B - Good balance"
    ["codellama:7b"]="7B|3.8|8000|Code Llama 7B - Coding tasks"
    ["llama3.2:latest"]="3B|2.0|4000|Llama 3.2 3B - Efficient"

    # Small Models (1-3B)
    ["phi3:mini"]="3.8B|2.3|4000|Phi-3 Mini - Fast and capable"
    ["phi3:medium"]="14B|7.9|16000|Phi-3 Medium - Advanced reasoning"
    ["tinyllama:1.1b"]="1.1B|0.6|2000|TinyLlama - Ultra lightweight"
    ["qwen2:1.5b"]="1.5B|0.9|2000|Qwen2 1.5B - Multilingual"

    # Specialized Models
    ["llama3.2-vision:latest"]="11B|7.6|12000|Llama 3.2 Vision - Multimodal"
    ["deepseek-coder:6.7b"]="6.7B|3.8|8000|DeepSeek Coder - Code specialist"
    ["nomic-embed-text"]="Embedding|0.3|2000|Text embeddings for RAG"
)

###############################################################################
# Check Ollama Container
###############################################################################
check_ollama_running() {
    if ! docker ps | grep -q "$OLLAMA_CONTAINER"; then
        print_error "Ollama container is not running"
        print_info "Start with: docker compose up -d ollama"
        exit 1
    fi
    print_success "Ollama container is running"
}

###############################################################################
# Get Hardware Recommendations
###############################################################################
get_hardware_recommendations() {
    # Detect hardware if not already done
    if [ -z "$GPU_VRAM" ]; then
        detect_gpu 2>/dev/null || true
        calculate_gpu_score 2>/dev/null || true
    fi

    print_header "📊 Hardware Analysis"

    echo "  GPU Type: ${GPU_TYPE:-cpu-only}"
    echo "  GPU VRAM: ${GPU_VRAM:-0} MB"
    echo "  System RAM: ${TOTAL_RAM:-unknown} MB"
    echo "  CPU Cores: ${CPU_CORES:-unknown}"
    echo ""

    # Determine recommended models based on hardware
    if [ "${GPU_VRAM:-0}" -ge 24000 ]; then
        RECOMMENDED_MODELS=("llama3.1:13b" "codellama:13b" "mistral:latest" "nomic-embed-text")
        RECOMMENDED_TIER="High-End GPU (24GB+ VRAM)"
    elif [ "${GPU_VRAM:-0}" -ge 16000 ]; then
        RECOMMENDED_MODELS=("llama3.1:13b" "codellama:13b" "phi3:mini" "nomic-embed-text")
        RECOMMENDED_TIER="Mid-High GPU (16GB VRAM)"
    elif [ "${GPU_VRAM:-0}" -ge 12000 ]; then
        RECOMMENDED_MODELS=("llama3.1:13b" "phi3:mini" "nomic-embed-text")
        RECOMMENDED_TIER="Mid-Range GPU (12GB VRAM)"
    elif [ "${GPU_VRAM:-0}" -ge 8000 ]; then
        RECOMMENDED_MODELS=("llama3.1:7b" "codellama:7b" "phi3:mini" "nomic-embed-text")
        RECOMMENDED_TIER="Entry GPU (8GB VRAM)"
    elif [ "${GPU_VRAM:-0}" -ge 4000 ]; then
        RECOMMENDED_MODELS=("llama3.2:latest" "phi3:mini" "nomic-embed-text")
        RECOMMENDED_TIER="Low-End GPU (4GB VRAM)"
    elif [ "${CPU_CORES:-0}" -ge 16 ] && [ "${TOTAL_RAM:-0}" -ge 32000 ]; then
        RECOMMENDED_MODELS=("llama3.1:7b" "phi3:mini" "nomic-embed-text")
        RECOMMENDED_TIER="High-End CPU (16+ cores, 32GB+ RAM)"
    elif [ "${CPU_CORES:-0}" -ge 8 ] && [ "${TOTAL_RAM:-0}" -ge 16000 ]; then
        RECOMMENDED_MODELS=("llama3.2:latest" "phi3:mini" "nomic-embed-text")
        RECOMMENDED_TIER="Mid-Range CPU (8+ cores, 16GB+ RAM)"
    else
        RECOMMENDED_MODELS=("phi3:mini" "tinyllama:1.1b" "nomic-embed-text")
        RECOMMENDED_TIER="Low-End / Budget System"
    fi

    print_success "Detected tier: $RECOMMENDED_TIER"
}

###############################################################################
# Download Model
###############################################################################
download_model() {
    local model_tag=$1
    local model_info="${MODEL_INFO[$model_tag]}"

    if [ -z "$model_info" ]; then
        print_error "Unknown model: $model_tag"
        return 1
    fi

    IFS='|' read -r size_param size_gb vram_needed description <<< "$model_info"

    print_info "Downloading: $model_tag"
    print_info "  Size: ${size_gb} GB"
    print_info "  VRAM needed: ${vram_needed} MB"
    print_info "  Description: $description"
    echo ""

    # Check if enough VRAM (if GPU available)
    if [ "${GPU_VRAM:-0}" -gt 0 ] && [ "${GPU_VRAM}" -lt "$vram_needed" ]; then
        print_warning "Your GPU VRAM (${GPU_VRAM}MB) is less than recommended (${vram_needed}MB)"
        print_warning "Model may run slower or fail to load"
        read -p "Continue anyway? [y/N]: " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            print_info "Skipping $model_tag"
            return 0
        fi
    fi

    print_info "⏳ This may take 5-30 minutes depending on model size and connection speed..."

    # Pull model
    if docker exec "$OLLAMA_CONTAINER" ollama pull "$model_tag"; then
        print_success "Downloaded: $model_tag"
        return 0
    else
        print_error "Failed to download: $model_tag"
        return 1
    fi
}

###############################################################################
# List Installed Models
###############################################################################
list_installed_models() {
    print_header "📦 Installed Models"

    if docker exec "$OLLAMA_CONTAINER" ollama list 2>/dev/null; then
        echo ""
    else
        print_warning "No models installed yet"
    fi
}

###############################################################################
# Show Model Catalog
###############################################################################
show_model_catalog() {
    print_header "📚 Available Models"

    echo "┌────────────────────────────────────────────────────────────────────────────┐"
    echo "│  Model Tag                │ Size │ VRAM  │ Description                   │"
    echo "├────────────────────────────────────────────────────────────────────────────┤"

    for model_tag in "${!MODEL_INFO[@]}"; do
        IFS='|' read -r size_param size_gb vram_needed description <<< "${MODEL_INFO[$model_tag]}"
        printf "│  %-25s │ %-4s │ %-5s │ %-29s │\n" "$model_tag" "$size_gb GB" "$((vram_needed/1000))GB" "${description:0:29}"
    done

    echo "└────────────────────────────────────────────────────────────────────────────┘"
    echo ""
}

###############################################################################
# Interactive Model Selection
###############################################################################
interactive_model_selection() {
    get_hardware_recommendations

    print_header "🎯 Recommended Models for Your Hardware"

    echo "Based on your hardware tier: $RECOMMENDED_TIER"
    echo ""
    echo "Recommended models:"
    local i=1
    for model in "${RECOMMENDED_MODELS[@]}"; do
        IFS='|' read -r size_param size_gb vram_needed description <<< "${MODEL_INFO[$model]}"
        echo "  $i) $model - $description"
        ((i++))
    done
    echo "  $i) Download all recommended"
    ((i++))
    echo "  $i) Custom selection"
    ((i++))
    echo "  $i) Skip for now"
    echo ""

    read -p "Select option [1-$i]: " choice

    if [ "$choice" -eq "$((${#RECOMMENDED_MODELS[@]}+1))" ]; then
        # Download all recommended
        for model in "${RECOMMENDED_MODELS[@]}"; do
            download_model "$model"
            echo ""
        done
    elif [ "$choice" -eq "$((${#RECOMMENDED_MODELS[@]}+2))" ]; then
        # Custom selection
        custom_model_selection
    elif [ "$choice" -eq "$((${#RECOMMENDED_MODELS[@]}+3))" ]; then
        # Skip
        print_info "Skipping model download"
        return 0
    elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#RECOMMENDED_MODELS[@]}" ]; then
        # Download specific model
        local selected_model="${RECOMMENDED_MODELS[$((choice-1))]}"
        download_model "$selected_model"
    else
        print_error "Invalid selection"
        return 1
    fi
}

###############################################################################
# Custom Model Selection
###############################################################################
custom_model_selection() {
    show_model_catalog

    print_info "Enter model tags to download (space-separated), or 'list' to see catalog again:"
    read -p "> " -a models

    if [ "${models[0]}" = "list" ]; then
        custom_model_selection
        return
    fi

    for model in "${models[@]}"; do
        if [ -n "${MODEL_INFO[$model]}" ]; then
            download_model "$model"
            echo ""
        else
            print_error "Unknown model: $model"
        fi
    done
}

###############################################################################
# Remove Model
###############################################################################
remove_model() {
    local model_tag=$1

    if [ -z "$model_tag" ]; then
        list_installed_models
        echo ""
        read -p "Enter model tag to remove: " model_tag
    fi

    print_warning "Removing model: $model_tag"
    if docker exec "$OLLAMA_CONTAINER" ollama rm "$model_tag"; then
        print_success "Removed: $model_tag"
    else
        print_error "Failed to remove: $model_tag"
    fi
}

###############################################################################
# Test Model
###############################################################################
test_model() {
    local model_tag=$1

    if [ -z "$model_tag" ]; then
        list_installed_models
        echo ""
        read -p "Enter model tag to test: " model_tag
    fi

    print_header "🧪 Testing Model: $model_tag"

    print_info "Sending test prompt: 'Why is the sky blue?'"
    echo ""

    docker exec -it "$OLLAMA_CONTAINER" ollama run "$model_tag" "Why is the sky blue? Answer in one sentence."
}

###############################################################################
# Show Usage
###############################################################################
show_usage() {
    cat << EOF
┌─────────────────────────────────────────────────────────────────────────────┐
│                     NEXT8N Ollama Model Manager                             │
└─────────────────────────────────────────────────────────────────────────────┘

Usage: $0 [COMMAND] [OPTIONS]

Commands:
  install              Interactive model installation (recommended)
  list                 List installed models
  catalog              Show available models
  download <model>     Download specific model
  remove <model>       Remove installed model
  test <model>         Test model with sample prompt
  recommend            Show hardware-based recommendations

Examples:
  $0 install                    # Interactive installation
  $0 download llama3.1:7b       # Download specific model
  $0 list                       # List installed models
  $0 test phi3:mini             # Test a model
  $0 remove tinyllama:1.1b      # Remove a model

EOF
}

###############################################################################
# Main
###############################################################################
main() {
    print_header "🤖 NEXT8N Ollama Model Manager"

    check_ollama_running

    case "${1:-install}" in
        install)
            interactive_model_selection
            ;;
        list)
            list_installed_models
            ;;
        catalog)
            show_model_catalog
            ;;
        download)
            if [ -z "$2" ]; then
                print_error "Please specify a model tag"
                show_usage
                exit 1
            fi
            download_model "$2"
            ;;
        remove)
            remove_model "$2"
            ;;
        test)
            test_model "$2"
            ;;
        recommend)
            get_hardware_recommendations
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac

    echo ""
    print_info "💡 Manage models anytime with: $0"
    print_info "🌐 Need help? https://services.next8n.com/"
    echo ""
}

main "$@"
