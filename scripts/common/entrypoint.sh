#!/bin/bash

# Exegol Enhanced - Container Entrypoint Script
# Developed with AI assistance for optimal container initialization
# Version: 1.0.0

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
EXEGOL_ENHANCED_DIR="/opt/exegol-enhanced"
WORKSPACE_DIR="/workspace"
TOOLS_DIR="/opt/exegol-enhanced"
CONFIG_DIR="/opt/exegol-enhanced/configs"

# Print functions
print_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 EXEGOL ENHANCED CONTAINER                    ║"
    echo "║                    Initializing...                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Initialize Exegol Enhanced environment
initialize_environment() {
    print_info "Initializing Exegol Enhanced environment..."
    
    # Create necessary directories
    mkdir -p "$WORKSPACE_DIR"
    mkdir -p "$TOOLS_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p /root/.exegol-enhanced
    
    # Set permissions
    chmod 755 "$WORKSPACE_DIR"
    chmod 755 "$TOOLS_DIR"
    
    # Create workspace subdirectories
    mkdir -p "$WORKSPACE_DIR"/{recon,exploitation,post-exploitation,reports,loot}
    
    print_success "Environment initialized"
}

# Setup enhanced tools
setup_enhanced_tools() {
    print_info "Setting up Exegol Enhanced tools..."
    
    # Make scripts executable
    if [[ -d "$TOOLS_DIR/tools" ]]; then
        find "$TOOLS_DIR/tools" -name "*.sh" -exec chmod +x {} \;
        find "$TOOLS_DIR/tools" -name "*.py" -exec chmod +x {} \;
    fi
    
    # Add tools to PATH
    if [[ -d "$TOOLS_DIR/tools" ]]; then
        export PATH="$TOOLS_DIR/tools/recon:$TOOLS_DIR/tools/exploitation:$TOOLS_DIR/tools/post-exploitation:$PATH"
        echo 'export PATH="/opt/exegol-enhanced/tools/recon:/opt/exegol-enhanced/tools/exploitation:/opt/exegol-enhanced/tools/post-exploitation:$PATH"' >> /root/.bashrc
    fi
    
    # Create aliases
    cat >> /root/.bashrc << 'EOF'

# Exegol Enhanced aliases
alias enhanced-nmap='/opt/exegol-enhanced/tools/recon/enhanced-nmap.sh'
alias web-fuzzer='/opt/exegol-enhanced/tools/exploitation/web-fuzzer.py'
alias crypto-analyzer='/opt/exegol-enhanced/tools/post-exploitation/crypto-analyzer.py'
alias workspace='cd /workspace'
alias reports='cd /workspace/reports'
alias loot='cd /workspace/loot'

# Enhanced functions
function scan-network() {
    enhanced-nmap -t "$1" -s quick
}

function fuzz-web() {
    web-fuzzer -u "$1" -t 20
}

function analyze-hash() {
    crypto-analyzer --hash "$1"
}

function crack-hash() {
    crypto-analyzer --crack "$1" --wordlist /usr/share/wordlists/rockyou.txt
}

EOF
    
    print_success "Enhanced tools configured"
}

# Setup GUI environment
setup_gui() {
    if [[ -n "${DISPLAY:-}" ]]; then
        print_info "Setting up GUI environment..."
        
        # Fix X11 permissions
        if [[ -f /root/.Xauthority ]]; then
            xauth merge /root/.Xauthority 2>/dev/null || true
        fi
        
        # Test X11 connection
        if xset q &>/dev/null; then
            print_success "GUI environment ready"
            export GUI_AVAILABLE=true
        else
            print_warning "GUI environment not available"
            export GUI_AVAILABLE=false
        fi
    else
        print_info "No DISPLAY variable set, GUI disabled"
        export GUI_AVAILABLE=false
    fi
}

# Setup networking
setup_networking() {
    print_info "Configuring networking..."
    
    # Enable IP forwarding if running as privileged
    if [[ -w /proc/sys/net/ipv4/ip_forward ]]; then
        echo 1 > /proc/sys/net/ipv4/ip_forward
        print_success "IP forwarding enabled"
    fi
    
    # Setup iptables rules for common pentesting scenarios
    if command -v iptables &>/dev/null && [[ -w /proc/sys/net/ipv4/ip_forward ]]; then
        # Allow forwarding
        iptables -P FORWARD ACCEPT 2>/dev/null || true
        print_success "Networking configured"
    fi
}

# Install additional tools if needed
install_additional_tools() {
    print_info "Checking for additional tools..."
    
    # Update package lists
    apt-get update -qq 2>/dev/null || true
    
    # Install commonly needed tools that might be missing
    local tools_to_install=(
        "curl"
        "wget"
        "git"
        "python3-pip"
        "jq"
        "xmlstarlet"
        "html2text"
    )
    
    for tool in "${tools_to_install[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            print_info "Installing $tool..."
            apt-get install -y -qq "$tool" 2>/dev/null || print_warning "Failed to install $tool"
        fi
    done
    
    # Install Python packages
    pip3 install --quiet --no-warn-script-location requests beautifulsoup4 lxml 2>/dev/null || true
    
    print_success "Additional tools check completed"
}

# Create welcome message
create_welcome_message() {
    cat > /root/.exegol-enhanced/welcome.txt << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    EXEGOL ENHANCED                           ║
║              Ultimate Cybersecurity Environment             ║
║                                                              ║
║  🎯 Enhanced Tools Available:                               ║
║    • enhanced-nmap    - Advanced network scanning           ║
║    • web-fuzzer       - Web application fuzzing             ║
║    • crypto-analyzer  - Cryptographic analysis              ║
║                                                              ║
║  📁 Workspace Structure:                                    ║
║    • /workspace/recon          - Reconnaissance results     ║
║    • /workspace/exploitation   - Exploitation artifacts     ║
║    • /workspace/post-exploitation - Post-exploitation data  ║
║    • /workspace/reports        - Generated reports          ║
║    • /workspace/loot           - Collected data             ║
║                                                              ║
║  🚀 Quick Commands:                                         ║
║    • workspace        - Go to workspace directory           ║
║    • scan-network IP  - Quick network scan                  ║
║    • fuzz-web URL     - Quick web fuzzing                   ║
║    • analyze-hash H   - Analyze hash type                   ║
║    • crack-hash H     - Attempt hash cracking               ║
║                                                              ║
║  📚 Documentation: /opt/exegol-enhanced/docs/               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

Welcome to Exegol Enhanced! 🚀

Type 'help' for basic commands or explore the enhanced tools above.
All your work will be saved in /workspace for persistence.

Happy hacking! 🔥
EOF

    # Add welcome message to bashrc
    echo "" >> /root/.bashrc
    echo "# Exegol Enhanced welcome message" >> /root/.bashrc
    echo "cat /root/.exegol-enhanced/welcome.txt" >> /root/.bashrc
    echo "" >> /root/.bashrc
}

# Health check function
health_check() {
    print_info "Performing health check..."
    
    local health_status=0
    
    # Check essential directories
    for dir in "$WORKSPACE_DIR" "$TOOLS_DIR"; do
        if [[ ! -d "$dir" ]]; then
            print_error "Missing directory: $dir"
            health_status=1
        fi
    done
    
    # Check essential tools
    local essential_tools=("nmap" "python3" "curl" "wget")
    for tool in "${essential_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            print_error "Missing essential tool: $tool"
            health_status=1
        fi
    done
    
    if [[ $health_status -eq 0 ]]; then
        print_success "Health check passed"
        
        # Create health check endpoint for docker-compose
        mkdir -p /tmp/health
        echo "OK" > /tmp/health/status
        
        # Start simple HTTP server for health checks
        (cd /tmp/health && python3 -m http.server 8080 &>/dev/null &) || true
    else
        print_error "Health check failed"
    fi
    
    return $health_status
}

# Main initialization function
main() {
    print_banner
    
    print_info "Starting Exegol Enhanced container initialization..."
    
    # Run initialization steps
    initialize_environment
    setup_enhanced_tools
    setup_gui
    setup_networking
    install_additional_tools
    create_welcome_message
    health_check
    
    print_success "🎉 Exegol Enhanced container ready!"
    print_info "Container initialized successfully"
    
    # If arguments provided, execute them
    if [[ $# -gt 0 ]]; then
        print_info "Executing command: $*"
        exec "$@"
    else
        # Start interactive bash session
        print_info "Starting interactive session..."
        exec /bin/bash
    fi
}

# Handle signals gracefully
trap 'print_info "Received shutdown signal, cleaning up..."; exit 0' SIGTERM SIGINT

# Run main function
main "$@"
