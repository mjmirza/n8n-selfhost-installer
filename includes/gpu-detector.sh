#!/bin/bash

###############################################################################
# NEXT8N GPU Detection & Hardware Analysis
# Detects NVIDIA/AMD GPU, CUDA, system specs for AI/LLM deployment optimization
###############################################################################

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

###############################################################################
# Detect NVIDIA GPU
###############################################################################
detect_nvidia_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        GPU_TYPE="nvidia"

        # Get GPU count
        GPU_COUNT=$(nvidia-smi --list-gpus 2>/dev/null | wc -l)

        # Get GPU name
        GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)

        # Get GPU VRAM (in MB)
        GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)

        # Get driver version
        GPU_DRIVER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1)

        # Check for CUDA
        if command -v nvcc &> /dev/null; then
            CUDA_VERSION=$(nvcc --version 2>/dev/null | grep "release" | awk '{print $5}' | cut -d',' -f1)
            GPU_CAPABILITY="nvidia-cuda"
            HAS_CUDA=true
        else
            GPU_CAPABILITY="nvidia-nocuda"
            HAS_CUDA=false
            CUDA_VERSION="Not installed"
        fi

        # Check NVIDIA Container Toolkit (for Docker GPU support)
        if command -v nvidia-container-cli &> /dev/null; then
            NVIDIA_DOCKER_SUPPORT=true
        else
            NVIDIA_DOCKER_SUPPORT=false
        fi

        return 0
    else
        return 1
    fi
}

###############################################################################
# Detect AMD GPU
###############################################################################
detect_amd_gpu() {
    if command -v rocm-smi &> /dev/null; then
        GPU_TYPE="amd"
        GPU_CAPABILITY="amd-rocm"

        # Get basic AMD GPU info
        GPU_NAME=$(rocm-smi --showproductname 2>/dev/null | grep "Card series" | cut -d':' -f2 | xargs)
        GPU_COUNT=1  # Simplified for now

        return 0
    else
        return 1
    fi
}

###############################################################################
# Fallback to CPU-only
###############################################################################
detect_cpu_only() {
    GPU_TYPE="none"
    GPU_CAPABILITY="cpu-only"
    GPU_COUNT=0
    GPU_NAME="None"
    GPU_VRAM=0
    GPU_DRIVER="N/A"
    CUDA_VERSION="N/A"
    HAS_CUDA=false
    NVIDIA_DOCKER_SUPPORT=false
}

###############################################################################
# Main GPU Detection
###############################################################################
detect_gpu() {
    print_info "Detecting GPU hardware..."

    if detect_nvidia_gpu; then
        print_success "NVIDIA GPU detected: $GPU_NAME"
        print_info "GPU Count: $GPU_COUNT"
        print_info "VRAM: ${GPU_VRAM} MB"
        print_info "Driver Version: $GPU_DRIVER"
        print_info "CUDA Version: $CUDA_VERSION"

        if [ "$HAS_CUDA" = true ]; then
            print_success "CUDA is installed and available"
        else
            print_warning "CUDA is NOT installed - Install CUDA toolkit for GPU acceleration"
        fi

        if [ "$NVIDIA_DOCKER_SUPPORT" = true ]; then
            print_success "NVIDIA Container Toolkit is installed"
        else
            print_warning "NVIDIA Container Toolkit NOT found - Install for Docker GPU support"
            print_info "Install: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
        fi

    elif detect_amd_gpu; then
        print_success "AMD GPU detected: $GPU_NAME"
        print_info "ROCm support available"

    else
        detect_cpu_only
        print_warning "No GPU detected - Will use CPU-only mode"
    fi

    # Export variables
    export GPU_TYPE
    export GPU_CAPABILITY
    export GPU_COUNT
    export GPU_NAME
    export GPU_VRAM
    export GPU_DRIVER
    export CUDA_VERSION
    export HAS_CUDA
    export NVIDIA_DOCKER_SUPPORT
}

###############################################################################
# Calculate GPU Score (0-100)
###############################################################################
calculate_gpu_score() {
    local score=0

    if [ "$GPU_TYPE" = "nvidia" ]; then
        # Base score for having NVIDIA GPU
        score=40

        # VRAM scoring (max 30 points)
        if [ "$GPU_VRAM" -ge 24000 ]; then
            score=$((score + 30))
        elif [ "$GPU_VRAM" -ge 16000 ]; then
            score=$((score + 25))
        elif [ "$GPU_VRAM" -ge 12000 ]; then
            score=$((score + 20))
        elif [ "$GPU_VRAM" -ge 8000 ]; then
            score=$((score + 15))
        elif [ "$GPU_VRAM" -ge 4000 ]; then
            score=$((score + 10))
        fi

        # CUDA bonus (20 points)
        if [ "$HAS_CUDA" = true ]; then
            score=$((score + 20))
        fi

        # Docker support bonus (10 points)
        if [ "$NVIDIA_DOCKER_SUPPORT" = true ]; then
            score=$((score + 10))
        fi

    elif [ "$GPU_TYPE" = "amd" ]; then
        score=50  # AMD ROCm support
    else
        score=0   # CPU-only
    fi

    export GPU_SCORE=$score

    if [ $score -ge 80 ]; then
        export GPU_RATING="Excellent"
    elif [ $score -ge 60 ]; then
        export GPU_RATING="Good"
    elif [ $score -ge 40 ]; then
        export GPU_RATING="Fair"
    else
        export GPU_RATING="Poor/None"
    fi
}

###############################################################################
# Recommend LLM Model Size
###############################################################################
recommend_model_size() {
    if [ "$GPU_TYPE" = "nvidia" ] && [ "$HAS_CUDA" = true ]; then
        if [ "$GPU_VRAM" -ge 24000 ]; then
            RECOMMENDED_MODEL_SIZE="13B-33B"
            RECOMMENDED_MODELS="llama3.1:13b, codellama:13b, mistral:7b"
            MAX_CONTEXT_LENGTH=8192
        elif [ "$GPU_VRAM" -ge 12000 ]; then
            RECOMMENDED_MODEL_SIZE="7B-13B"
            RECOMMENDED_MODELS="llama3.1:13b, codellama:13b, mistral:7b"
            MAX_CONTEXT_LENGTH=4096
        elif [ "$GPU_VRAM" -ge 8000 ]; then
            RECOMMENDED_MODEL_SIZE="7B"
            RECOMMENDED_MODELS="llama3.1:7b, codellama:7b, mistral:7b"
            MAX_CONTEXT_LENGTH=4096
        elif [ "$GPU_VRAM" -ge 4000 ]; then
            RECOMMENDED_MODEL_SIZE="3B-7B"
            RECOMMENDED_MODELS="phi3:mini, llama3.1:7b"
            MAX_CONTEXT_LENGTH=2048
        else
            RECOMMENDED_MODEL_SIZE="1B-3B"
            RECOMMENDED_MODELS="phi3:mini, tinyllama:1.1b"
            MAX_CONTEXT_LENGTH=2048
        fi
    elif [ "$CPU_CORES" -ge 16 ] && [ "$TOTAL_RAM" -ge 32000 ]; then
        RECOMMENDED_MODEL_SIZE="7B (CPU)"
        RECOMMENDED_MODELS="llama3.1:7b, phi3:mini"
        MAX_CONTEXT_LENGTH=2048
    elif [ "$CPU_CORES" -ge 8 ] && [ "$TOTAL_RAM" -ge 16000 ]; then
        RECOMMENDED_MODEL_SIZE="3B (CPU)"
        RECOMMENDED_MODELS="phi3:mini, tinyllama:1.1b"
        MAX_CONTEXT_LENGTH=2048
    else
        RECOMMENDED_MODEL_SIZE="1B (CPU)"
        RECOMMENDED_MODELS="tinyllama:1.1b"
        MAX_CONTEXT_LENGTH=1024
    fi

    export RECOMMENDED_MODEL_SIZE
    export RECOMMENDED_MODELS
    export MAX_CONTEXT_LENGTH
}

###############################################################################
# Recommend AI Deployment Tier
###############################################################################
recommend_ai_tier() {
    if [ "$GPU_TYPE" = "nvidia" ] && [ "$HAS_CUDA" = true ] && [ "$NVIDIA_DOCKER_SUPPORT" = true ]; then
        if [ "$GPU_VRAM" -ge 12000 ]; then
            RECOMMENDED_AI_TIER="ai-gpu"
            AI_TIER_NAME="AI-GPU (High Performance)"
            AI_TIER_DESCRIPTION="Ollama with NVIDIA GPU acceleration + Supabase"
        elif [ "$GPU_VRAM" -ge 6000 ]; then
            RECOMMENDED_AI_TIER="ai-gpu-lite"
            AI_TIER_NAME="AI-GPU (Lite)"
            AI_TIER_DESCRIPTION="Ollama with GPU for smaller models + Supabase"
        else
            RECOMMENDED_AI_TIER="ai-local"
            AI_TIER_NAME="AI-Local (CPU)"
            AI_TIER_DESCRIPTION="Ollama CPU-optimized + Supabase"
        fi
    elif [ "$CPU_CORES" -ge 16 ] && [ "$TOTAL_RAM" -ge 32000 ]; then
        RECOMMENDED_AI_TIER="ai-local-pro"
        AI_TIER_NAME="AI-Local (CPU Pro)"
        AI_TIER_DESCRIPTION="Ollama CPU-optimized for high-end CPU + Supabase"
    elif [ "$CPU_CORES" -ge 8 ] && [ "$TOTAL_RAM" -ge 16000 ]; then
        RECOMMENDED_AI_TIER="ai-local"
        AI_TIER_NAME="AI-Local (CPU)"
        AI_TIER_DESCRIPTION="Ollama CPU with lightweight models + Supabase"
    else
        RECOMMENDED_AI_TIER="ai-ready"
        AI_TIER_NAME="AI-Ready (Cloud API)"
        AI_TIER_DESCRIPTION="Supabase + Cloud API integration (OpenAI/Anthropic)"
    fi

    export RECOMMENDED_AI_TIER
    export AI_TIER_NAME
    export AI_TIER_DESCRIPTION
}

###############################################################################
# Display GPU Analysis Results
###############################################################################
show_gpu_analysis() {
    echo ""
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${MAGENTA}  🎯 GPU & Hardware Analysis for AI/LLM${NC}"
    echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                    HARDWARE DETECTED                        │"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  GPU Type:         $GPU_TYPE"
    echo "│  GPU Name:         $GPU_NAME"
    echo "│  GPU Count:        $GPU_COUNT"
    echo "│  GPU VRAM:         ${GPU_VRAM} MB"
    echo "│  GPU Driver:       $GPU_DRIVER"
    echo "│  CUDA Version:     $CUDA_VERSION"
    echo "│  Docker GPU:       $NVIDIA_DOCKER_SUPPORT"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  GPU Score:        ${GPU_SCORE}/100 ($GPU_RATING)"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  RECOMMENDED AI TIER: $RECOMMENDED_AI_TIER"
    echo "│  Tier Name:        $AI_TIER_NAME"
    echo "│  Description:      $AI_TIER_DESCRIPTION"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  Recommended Model Size: $RECOMMENDED_MODEL_SIZE"
    echo "│  Suggested Models: $RECOMMENDED_MODELS"
    echo "│  Max Context:      $MAX_CONTEXT_LENGTH tokens"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    # Warnings and recommendations
    if [ "$GPU_TYPE" = "nvidia" ] && [ "$HAS_CUDA" = false ]; then
        print_warning "CUDA is not installed. Install CUDA toolkit for GPU acceleration:"
        print_info "https://developer.nvidia.com/cuda-downloads"
        echo ""
    fi

    if [ "$GPU_TYPE" = "nvidia" ] && [ "$NVIDIA_DOCKER_SUPPORT" = false ]; then
        print_warning "NVIDIA Container Toolkit not found. Install for Docker GPU support:"
        print_info "https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
        echo ""
    fi

    if [ "$GPU_TYPE" = "none" ]; then
        print_info "No GPU detected. You can still run LLMs on CPU (slower)."
        print_info "For better performance, consider:"
        print_info "  - Using cloud API services (OpenAI, Anthropic)"
        print_info "  - Deploying on a GPU-enabled server"
        echo ""
    fi
}

###############################################################################
# Run Complete Analysis
###############################################################################
run_gpu_analysis() {
    detect_gpu
    calculate_gpu_score
    recommend_model_size
    recommend_ai_tier
    show_gpu_analysis
}

# If script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" -eq "${0}" ]; then
    run_gpu_analysis
fi
