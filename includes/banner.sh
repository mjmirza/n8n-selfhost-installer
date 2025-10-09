#!/bin/bash

# NEXT8N Brand ASCII Art Banner
show_banner() {
    clear
    cat << "EOF"
╔═════════════════════════════════════════════════════════════════════════════╗
║                                                                             ║
║   ███╗   ██╗███████╗██╗  ██╗████████╗ █████╗ ███╗   ██╗                   ║
║   ████╗  ██║██╔════╝╚██╗██╔╝╚══██╔══╝██╔══██╗████╗  ██║                   ║
║   ██╔██╗ ██║█████╗   ╚███╔╝    ██║   ╚█████╔╝██╔██╗ ██║                   ║
║   ██║╚██╗██║██╔══╝   ██╔██╗    ██║   ██╔══██╗██║╚██╗██║                   ║
║   ██║ ╚████║███████╗██╔╝ ██╗   ██║   ╚█████╔╝██║ ╚████║                   ║
║   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚════╝ ╚═╝  ╚═══╝                   ║
║                                                                             ║
║              🚀 N8N RAPID DEPLOYMENT SYSTEM 🚀                             ║
║                                                                             ║
║        Professional N8N Hosting Made Simple - From Startup to Enterprise   ║
║                                                                             ║
╚═════════════════════════════════════════════════════════════════════════════╝

EOF
}

show_welcome() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Welcome to NEXT8N - Your N8N Deployment Partner"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  This intelligent installer analyzes your infrastructure, evaluates your"
    echo "  requirements, and recommends the optimal N8N deployment architecture."
    echo ""
    echo "  📊 We'll analyze your infrastructure"
    echo "  🎯 Recommend the optimal deployment strategy"
    echo "  ⚡ Deploy production-ready N8N in minutes"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

show_footer() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  💡 Need Expert Help?"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  Our team specializes in N8N deployments, migrations, and optimization."
    echo "  Get professional consulting and support:"
    echo ""
    echo "  🌐 https://services.next8n.com/"
    echo ""
    echo "  • Custom deployment strategies"
    echo "  • Migration from other automation platforms"
    echo "  • Performance optimization"
    echo "  • Enterprise support packages"
    echo "  • Training and workshops"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Export functions
export -f show_banner
export -f show_welcome
export -f show_footer
