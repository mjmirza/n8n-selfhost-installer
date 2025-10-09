# 🚀 NEXT8N - Professional N8N Deployment System

**Enterprise-grade N8N self-hosted deployment with AI/LLM capabilities**

Deploy N8N from simple Docker setups to AI-powered automation platforms with intelligent hardware detection and automatic optimization.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![N8N](https://img.shields.io/badge/n8n-latest-orange.svg)](https://n8n.io/)
[![Production Ready](https://img.shields.io/badge/Production-Ready-success.svg)]()

---

## ✨ What Makes NEXT8N Different

- 🎯 **7 Deployment Tiers** - From simple Docker to AI-GPU acceleration
- 🤖 **AI/LLM Integration** - Ollama + Supabase with RAG capabilities
- 🧠 **Intelligent Installer** - Detects hardware, recommends optimal setup
- 🔒 **Production Security** - SSL, JWT auth, API gateways, Docker isolation
- 📦 **Ready Workflows** - 5 production AI templates included
- 🛠️ **Model Management** - CLI for LLM models with hardware optimization
- 📚 **Complete Documentation** - 12+ comprehensive guides

---

## 🚀 Quick Start

### Prerequisites

- Ubuntu 22.04+ server
- Root/sudo access
- Domain name (for HTTPS)
- 4GB+ RAM (16GB for AI tiers)

### Installation (2 Commands)

```bash
# 1. Clone repository
git clone <repo-url> n8n-selfhost-installer
cd n8n-selfhost-installer

# 2. Run intelligent guided installer
sudo bash install-guided.sh
```

The installer will:
1. ✅ Detect your hardware (CPU, RAM, GPU)
2. ✅ Survey your needs (environment, org size, use case)
3. ✅ Recommend optimal deployment tier
4. ✅ Install everything automatically
5. ✅ Configure SSL with Let's Encrypt

**Total time:** 10-30 minutes (depending on tier)

---

## 📦 Deployment Tiers

### **Tier 1: Simple (Docker + Caddy)**
**Perfect for:** Personal projects, testing, development

**Components:**
- N8N workflow automation
- Caddy reverse proxy with SSL
- SQLite database

**Requirements:** 2GB RAM, 1 CPU core
**Setup time:** 5 minutes

```bash
cd deployments/simple
docker compose up -d
```

---

### **Tier 2: PostgreSQL Production**
**Perfect for:** Small businesses, production workloads

**Components:**
- N8N + PostgreSQL database
- Caddy with SSL
- Health checks

**Requirements:** 4GB RAM, 2 CPU cores
**Setup time:** 10 minutes

```bash
cd deployments/postgres
docker compose up -d
```

---

### **Tier 3: PostgreSQL + Worker (Scalable)**
**Perfect for:** Growing businesses, high workflow volumes

**Components:**
- N8N + PostgreSQL + Redis
- Worker nodes for queue processing
- Horizontal scaling ready

**Requirements:** 8GB RAM, 4 CPU cores
**Setup time:** 15 minutes

```bash
cd deployments/postgres-worker
docker compose up -d
```

---

### **Tier 4: Kubernetes Enterprise**
**Perfect for:** Enterprise, multi-instance, high availability

**Components:**
- Full K8s deployment (9 manifests)
- HA PostgreSQL
- Ingress controller
- Auto-scaling

**Requirements:** K8s cluster (3+ nodes)
**Setup time:** 30 minutes

```bash
kubectl apply -f kubernetes/
```

---

### **🆕 Tier 5: AI-GPU (High Performance AI)**
**Perfect for:** AI applications with GPU acceleration

**Components:**
- N8N workflow automation
- **Ollama** (local LLM with NVIDIA GPU)
- **Supabase** (PostgreSQL + pgvector for RAG)
- 9 Supabase services (Auth, Storage, Realtime, etc.)
- 5 pre-built AI workflows

**Requirements:**
- 16GB RAM, 4+ CPU cores
- NVIDIA GPU with 8GB+ VRAM (RTX 3060+)
- CUDA 12.0+ installed

**Performance:** 40-150 tokens/sec (depending on GPU)
**Setup time:** 20-30 minutes (includes model download)

```bash
cd deployments/ai-gpu
docker compose up -d

# Install AI models
../scripts/manage-ollama-models.sh install

# Import AI workflows
../scripts/import-workflows.sh --category=ai
```

**What you get:**
- Local LLM inference (Llama, CodeLlama, Mistral)
- Vector database for RAG applications
- Auto-generated REST APIs
- Authentication & storage
- Real-time subscriptions

---

### **🆕 Tier 6: AI-Local (CPU-Optimized AI)**
**Perfect for:** AI applications without GPU

**Components:**
- Same as AI-GPU but CPU-optimized
- Smaller, efficient models recommended

**Requirements:** 16GB RAM, 8+ CPU cores
**Performance:** 10-25 tokens/sec
**Setup time:** 20-30 minutes

**Recommended models:** phi3:mini, llama3.1:7b, tinyllama

```bash
cd deployments/ai-local
docker compose up -d
```

---

### **🆕 Tier 7: Standalone Supabase**
**Perfect for:** Any application needing backend services

**Components:**
- Complete Supabase stack (9 services)
- PostgreSQL 15 with pgvector
- Auto-generated REST API
- Authentication (email, OAuth)
- File storage (S3-compatible)
- Real-time WebSocket
- Admin dashboard

**Requirements:** 8GB RAM, 4 CPU cores
**Ports:** 8000 (dashboard), 8001 (API), 5433 (PostgreSQL)

```bash
cd deployments/databases/supabase
docker compose up -d

# Access dashboard: http://localhost:8000
# API endpoint: http://localhost:8001
```

---

## 🤖 AI/LLM Features

### **Ollama - Local LLM Inference**

Run LLMs locally with automatic optimization:

**GPU Support:**
- ✅ NVIDIA CUDA detection
- ✅ Automatic GPU passthrough
- ✅ VRAM-based model recommendations

**Model Management:**
```bash
# Interactive installation (recommended)
./scripts/manage-ollama-models.sh install

# Download specific model
./scripts/manage-ollama-models.sh download llama3.1:7b

# List installed models
./scripts/manage-ollama-models.sh list

# Test a model
./scripts/manage-ollama-models.sh test phi3:mini
```

**Included Models (13 total):**
- **Large (13B):** llama3.1:13b, codellama:13b
- **Medium (7B):** llama3.1:7b, codellama:7b, mistral:latest
- **Small (1-3B):** phi3:mini, tinyllama:1.1b
- **Embeddings:** nomic-embed-text (for RAG)

### **Supabase - Complete Backend**

Open-source Firebase alternative:

**Services Included:**
- PostgreSQL 15 with pgvector extension
- PostgREST (auto-generated REST API)
- GoTrue (authentication)
- Realtime (WebSocket subscriptions)
- Storage (S3-compatible file storage)
- Kong (API gateway)
- Supabase Studio (admin dashboard)

**Pre-configured for AI:**
- Vector similarity search
- Example documents table with embeddings
- Optimized indexes for RAG

**API Endpoints:**
```
http://localhost:8001/rest/v1/        - REST API
http://localhost:8001/auth/v1/        - Authentication
http://localhost:8001/realtime/v1/    - WebSocket
http://localhost:8001/storage/v1/     - File storage
http://localhost:8000                 - Admin dashboard
```

### **5 Ready-to-Use AI Workflows**

Located in `workflows/templates/ai/`:

1. **Simple Chat** - Webhook → Ollama → Response
2. **Vector Storage** - Document → Embedding → Supabase
3. **RAG Q&A** - Question → Search → LLM → Answer
4. **Code Generator** - Task → CodeLlama → Code
5. **Summarizer** - Content → LLM → Summary

**Import workflows:**
```bash
./scripts/import-workflows.sh --category=ai
```

**Test workflows:**
```bash
# Chat completion
curl -X POST http://localhost:5678/webhook/chat \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Explain AI", "model": "llama3.1:7b"}'

# RAG question
curl -X POST http://localhost:5678/webhook/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "What is machine learning?"}'
```

---

## 🧠 Intelligent Installation

The guided installer (`install-guided.sh`) automatically:

### **1. Hardware Detection**
- Detects NVIDIA GPU (name, VRAM, CUDA version)
- Detects AMD GPU (ROCm support)
- Analyzes CPU cores and RAM
- Scores hardware 0-100

### **2. User Survey**
- Environment type (localhost/VPS/cloud/K8s)
- Organization size (personal/startup/enterprise)
- Budget considerations
- Use case priorities

### **3. Intelligent Recommendations**
Based on your hardware + needs:
- RTX 4090 (24GB) → AI-GPU with llama3.1:13b
- RTX 3060 (8GB) → AI-GPU with llama3.1:7b
- 16-core CPU → AI-Local with phi3:mini
- No GPU/budget → Simple or PostgreSQL tier

### **4. Automated Deployment**
- Creates required volumes
- Configures environment variables
- Starts services with health checks
- Downloads models (if AI tier)
- Imports workflows

---

## 🛠️ Management Scripts

All located in `scripts/`:

### **General Management**
```bash
./check-status.sh           # Check all services
./restart-all.sh            # Restart everything
./backup.sh                 # Backup N8N data
./update-n8n.sh             # Update to latest N8N
./detect-deployment.sh      # Detect current tier
```

### **AI Management**
```bash
./manage-ollama-models.sh install     # Install models
./manage-ollama-models.sh list        # List models
./manage-ollama-models.sh test        # Test model
./import-workflows.sh --category=ai   # Import AI workflows
```

---

## 🔒 Security Features

### **Built-in Security**
- ✅ HTTPS via Caddy with Let's Encrypt
- ✅ JWT authentication (Supabase)
- ✅ API key validation
- ✅ Kong API Gateway with rate limiting
- ✅ Docker network isolation
- ✅ Health checks on all services
- ✅ UFW firewall (ports 22, 80, 443)

### **Security Headers**
- HSTS (HTTP Strict Transport Security)
- X-Frame-Options (clickjacking protection)
- X-Content-Type-Options (MIME sniffing protection)
- CSP (Content Security Policy)

---

## 📊 Performance Benchmarks

### **AI Inference Performance**

| Hardware | Model | Tokens/sec | Use Case |
|----------|-------|-----------|----------|
| RTX 4090 + Llama 13B | 13B | 80-100 | Production AI apps |
| RTX 3060 + Llama 7B | 7B | 40-60 | Development, testing |
| 16-core CPU + Llama 7B | 7B | 10-15 | Budget AI apps |
| 8-core CPU + Phi-3 | 3.8B | 15-25 | Lightweight AI |

### **Supabase Performance**
- REST API: 10-50ms response time
- Vector search: 50-200ms (dataset dependent)
- Real-time: <100ms WebSocket latency

---

## 📂 Repository Structure

```
n8n-selfhost-installer/
├── README.md                    ← You are here
├── LICENSE                      ← MIT License
├── install.sh                   ← Legacy installer
├── install-guided.sh            ← ⭐ Intelligent installer (USE THIS)
│
├── deployments/                 ← All deployment configurations
│   ├── simple/                  # Tier 1: Docker + Caddy
│   ├── postgres/                # Tier 2: PostgreSQL
│   ├── postgres-worker/         # Tier 3: Scalable
│   ├── ai-gpu/                  # Tier 5: AI with GPU
│   ├── ai-local/                # Tier 6: AI CPU-only
│   └── databases/supabase/      # Tier 7: Standalone Supabase
│
├── kubernetes/                  ← Tier 4: K8s manifests (9 files)
│
├── includes/                    ← Installer modules
│   ├── banner.sh                # NEXT8N branding
│   ├── survey.sh                # User questionnaire
│   ├── spec-checker.sh          # Hardware analysis
│   └── gpu-detector.sh          # GPU detection & recommendations
│
├── scripts/                     ← Management utilities
│   ├── check-status.sh          # System health
│   ├── restart-all.sh           # Restart services
│   ├── backup.sh                # Backup data
│   ├── update-n8n.sh            # Update N8N
│   ├── detect-deployment.sh     # Detect tier
│   ├── import-workflows.sh      # Import templates
│   └── manage-ollama-models.sh  # AI model management
│
├── workflows/templates/ai/      ← AI workflow templates (5 files)
│   ├── ollama-chat-simple.json
│   ├── supabase-vector-store.json
│   ├── rag-question-answer.json
│   ├── code-generator.json
│   └── content-summarizer.json
│
└── docs/                        ← Documentation
    ├── guides/                  # User guides
    ├── deployment-strategies/   # Architecture docs
    ├── technical/               # Implementation details
    ├── HETZNER-GUIDE.md
    ├── TROUBLESHOOTING.md
    ├── CONTRIBUTING.md
    └── CHANGELOG.md
```

**Total:** 55+ production-ready files

---

## 💼 Real-World Use Cases

### **1. AI Customer Support**
Deploy Tier 5 (AI-GPU) with RAG workflow:
- Store knowledge base in Supabase (vector embeddings)
- Customer asks question via webhook
- Search similar documents, generate context-aware answer
- Return personalized response

### **2. Automated Code Review**
Use CodeLlama model:
- GitHub webhook triggers on PR
- Extract code changes
- Analyze with CodeLlama
- Post review comments

### **3. Content Marketing**
Deploy summarizer workflow:
- Trigger on new blog post
- Generate summaries (short/medium/long)
- Create social media posts
- Publish across platforms

### **4. Document Processing**
Full RAG pipeline:
- Upload PDFs, extract text
- Generate embeddings
- Store in Supabase vector DB
- Enable semantic search

---

## 🆘 Troubleshooting

### **Common Issues**

**DNS not resolving:**
```bash
# Check DNS propagation
nslookup n8n.yourdomain.com 8.8.8.8

# Wait 5-30 minutes
```

**SSL certificate not generating:**
```bash
# Check Caddy logs
docker compose logs caddy | grep certificate

# Ensure port 80 is open
ufw allow 80/tcp
docker compose restart caddy
```

**GPU not detected:**
```bash
# Check NVIDIA driver
nvidia-smi

# Install CUDA toolkit
# https://developer.nvidia.com/cuda-downloads

# Install NVIDIA Container Toolkit
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/
```

**Ollama model download slow:**
```bash
# Check disk space
df -h

# Check download progress
docker exec ollama ollama list
```

**Supabase services not starting:**
```bash
# Check logs
docker compose logs supabase-db
docker compose logs supabase-kong

# Verify environment variables
cat .env | grep SUPABASE
```

For more help, see [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

## 📚 Documentation

### **User Guides**
- [SETUP.md](docs/guides/SETUP.md) - Manual installation
- [GUIDED-INSTALLER-GUIDE.md](docs/guides/GUIDED-INSTALLER-GUIDE.md) - Installer guide
- [HETZNER-GUIDE.md](docs/HETZNER-GUIDE.md) - Hetzner deployment

### **Technical Docs**
- [AI-LLM-INTEGRATION-STRATEGY.md](docs/technical/AI-LLM-INTEGRATION-STRATEGY.md) - AI architecture
- [WORKFLOW-INJECTION-SYSTEM.md](docs/technical/WORKFLOW-INJECTION-SYSTEM.md) - Workflow system
- [ULTRA-STRATEGIC-IMPLEMENTATION.md](docs/technical/ULTRA-STRATEGIC-IMPLEMENTATION.md) - Implementation

### **Other**
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Problem solving
- [CONTRIBUTING.md](docs/CONTRIBUTING.md) - How to contribute
- [CHANGELOG.md](docs/CHANGELOG.md) - Version history

---

## 🏗️ Minimum Requirements

### **Tier 1-2 (Simple/PostgreSQL)**
- 2 vCPU, 4GB RAM, 20GB storage
- Ubuntu 22.04+

### **Tier 3 (Worker)**
- 4 vCPU, 8GB RAM, 40GB storage
- Ubuntu 22.04+

### **Tier 4 (Kubernetes)**
- K8s cluster (3+ nodes)
- 8GB+ RAM per node

### **Tier 5 (AI-GPU)**
- 4 vCPU, 16GB RAM, 100GB storage
- NVIDIA GPU (8GB+ VRAM)
- CUDA 12.0+
- Ubuntu 22.04+

### **Tier 6 (AI-Local)**
- 8 vCPU, 16GB RAM, 100GB storage
- Ubuntu 22.04+

### **Tier 7 (Supabase)**
- 4 vCPU, 8GB RAM, 40GB storage
- Ubuntu 22.04+

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

### **How to Contribute**
1. Fork repository
2. Create feature branch
3. Make changes
4. Submit pull request

### **Areas for Contribution**
- More workflow templates
- Additional deployment tiers
- Documentation improvements
- Bug fixes
- Performance optimizations

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [N8N](https://n8n.io/) - Workflow automation platform
- [Caddy](https://caddyserver.com/) - Reverse proxy
- [Supabase](https://supabase.com/) - Open-source Firebase alternative
- [Ollama](https://ollama.com/) - Local LLM inference
- [Docker](https://www.docker.com/) - Containerization

---

## 💼 Professional Support

Need help with deployment, custom workflows, or consulting?

**🌐 Visit:** [https://services.next8n.com/](https://services.next8n.com/)

We offer:
- Custom deployment assistance
- Workflow development
- AI/LLM integration consulting
- Training and onboarding
- Priority support

---

## ⭐ Star This Project

If NEXT8N helped you, please give it a star! It helps others discover the project.

---

**Made with ❤️ for the N8N community**
**🚀 Production Ready - Deploy with Confidence**
