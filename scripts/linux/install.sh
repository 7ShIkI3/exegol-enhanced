#!/bin/bash

# Exegol Enhanced - Installation Script for Linux (Ubuntu/Mint)
# Developed with AI assistance for optimal user experience
# Version: 1.0.0

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
EXEGOL_VERSION="latest"
INSTALL_DIR="$HOME/.exegol-enhanced"
LOG_FILE="$INSTALL_DIR/install.log"

# Create install directory and log file
mkdir -p "$INSTALL_DIR"
touch "$LOG_FILE"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Print functions
print_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    EXEGOL ENHANCED                           ║"
    echo "║              Ultimate Cybersecurity Environment             ║"
    echo "║                                                              ║"
    echo "║                  🚀 Installation Script 🚀                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
    log "STEP: $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log "SUCCESS: $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log "WARNING: $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log "ERROR: $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log "INFO: $1"
}

# Error handling
handle_error() {
    print_error "Installation failed at line $1"
    print_error "Check the log file: $LOG_FILE"
    print_error "You can run the script again or contact support"
    exit 1
}

trap 'handle_error $LINENO' ERR

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        print_info "Please run as a regular user with sudo privileges"
        exit 1
    fi
}

# Detect Linux distribution
detect_distro() {
    print_step "Detecting Linux distribution..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
        print_success "Detected: $PRETTY_NAME"
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi
    
    case $DISTRO in
        ubuntu|linuxmint)
            print_success "Supported distribution detected"
            ;;
        *)
            print_warning "Untested distribution. Proceeding with Ubuntu-compatible installation..."
            ;;
    esac
}

# Check system requirements
check_requirements() {
    print_step "Checking system requirements..."
    
    # Check available space (minimum 10GB)
    AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
    REQUIRED_SPACE=10485760 # 10GB in KB
    
    if [[ $AVAILABLE_SPACE -lt $REQUIRED_SPACE ]]; then
        print_error "Insufficient disk space. Required: 10GB, Available: $((AVAILABLE_SPACE/1024/1024))GB"
        exit 1
    fi
    
    # Check RAM (minimum 4GB)
    TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')
    if [[ $TOTAL_RAM -lt 4096 ]]; then
        print_warning "Less than 4GB RAM detected. Performance may be affected."
    fi
    
    # Check if user has sudo privileges
    if ! sudo -n true 2>/dev/null; then
        print_error "This script requires sudo privileges"
        print_info "Please ensure your user is in the sudo group"
        exit 1
    fi
    
    print_success "System requirements check passed"
}

# Update system packages
update_system() {
    print_step "Updating system packages..."
    
    sudo apt update -qq
    sudo apt upgrade -y -qq
    
    print_success "System packages updated"
}

# Install required packages
install_dependencies() {
    print_step "Installing required dependencies..."
    
    local packages=(
        "curl"
        "wget"
        "git"
        "python3"
        "python3-pip"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "software-properties-common"
        "unzip"
        "jq"
    )
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            print_info "Installing $package..."
            sudo apt install -y -qq "$package"
        else
            print_info "$package is already installed"
        fi
    done
    
    print_success "Dependencies installed"
}

# Install Docker
install_docker() {
    print_step "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        print_info "Docker is already installed"
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_info "Docker version: $DOCKER_VERSION"
    else
        print_info "Installing Docker from official repository..."
        
        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        # Add Docker repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker
        sudo apt update -qq
        sudo apt install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        print_success "Docker installed successfully"
    fi
    
    # Add user to docker group
    if ! groups $USER | grep -q docker; then
        print_info "Adding user to docker group..."
        sudo usermod -aG docker $USER
        print_warning "You need to log out and log back in for docker group changes to take effect"
    fi
    
    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    print_success "Docker configuration completed"
}

# Install Docker Compose (if not already installed with Docker)
install_docker_compose() {
    print_step "Checking Docker Compose..."
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_info "Installing Docker Compose..."
        
        # Get latest version
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
        
        # Download and install
        sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        print_success "Docker Compose installed: $COMPOSE_VERSION"
    else
        print_info "Docker Compose is already available"
    fi
}

# Install Exegol
install_exegol() {
    print_step "Installing Exegol..."
    
    # Install Exegol using pip
    pip3 install --user exegol
    
    # Add ~/.local/bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    print_success "Exegol installed successfully"
}

# Configure Exegol Enhanced
configure_exegol_enhanced() {
    print_step "Configuring Exegol Enhanced..."
    
    # Create configuration directory
    mkdir -p "$INSTALL_DIR/config"
    mkdir -p "$INSTALL_DIR/workspace"
    mkdir -p "$INSTALL_DIR/tools"
    
    # Create enhanced configuration
    cat > "$INSTALL_DIR/config/exegol-enhanced.conf" << EOF
# Exegol Enhanced Configuration
WORKSPACE_DIR=$INSTALL_DIR/workspace
TOOLS_DIR=$INSTALL_DIR/tools
CUSTOM_SCRIPTS_DIR=$INSTALL_DIR/scripts
LOG_LEVEL=INFO
AUTO_UPDATE=true
GUI_ENABLED=true
EOF
    
    # Create useful aliases
    cat > "$INSTALL_DIR/config/aliases.sh" << 'EOF'
# Exegol Enhanced Aliases
alias exegol-start='exegol start'
alias exegol-stop='exegol stop'
alias exegol-gui='exegol start -X'
alias exegol-workspace='cd $HOME/.exegol-enhanced/workspace'
alias exegol-tools='cd $HOME/.exegol-enhanced/tools'
alias exegol-logs='tail -f $HOME/.exegol-enhanced/install.log'
alias exegol-update='$HOME/.exegol-enhanced/scripts/update.sh'
EOF
    
    # Add aliases to bashrc
    if ! grep -q "exegol-enhanced" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# Exegol Enhanced aliases" >> ~/.bashrc
        echo "source $INSTALL_DIR/config/aliases.sh" >> ~/.bashrc
    fi
    
    print_success "Exegol Enhanced configured"
}

# Create desktop shortcuts (if GUI available)
create_shortcuts() {
    if [[ -n "${DISPLAY:-}" ]] && command -v xdg-desktop-menu &> /dev/null; then
        print_step "Creating desktop shortcuts..."
        
        # Create desktop entry
        cat > "$HOME/.local/share/applications/exegol-enhanced.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Exegol Enhanced
Comment=Ultimate Cybersecurity Environment
Exec=gnome-terminal -- bash -c 'exegol start -X; exec bash'
Icon=utilities-terminal
Terminal=false
Categories=Development;Security;
EOF
        
        # Update desktop database
        update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
        
        print_success "Desktop shortcuts created"
    else
        print_info "GUI not available, skipping desktop shortcuts"
    fi
}

# Validate installation
validate_installation() {
    print_step "Validating installation..."
    
    # Check Docker
    if ! docker --version &> /dev/null; then
        print_error "Docker validation failed"
        return 1
    fi
    
    # Check Exegol
    if ! command -v exegol &> /dev/null; then
        print_error "Exegol validation failed"
        return 1
    fi
    
    # Test Docker permissions (may require newgrp or logout/login)
    if docker ps &> /dev/null; then
        print_success "Docker permissions OK"
    else
        print_warning "Docker permissions need refresh (logout/login required)"
    fi
    
    print_success "Installation validation completed"
}

# Main installation function
main() {
    print_banner
    
    print_info "Starting Exegol Enhanced installation..."
    print_info "This may take several minutes depending on your internet connection"
    print_info "Installation log: $LOG_FILE"
    echo ""
    
    check_root
    detect_distro
    check_requirements
    update_system
    install_dependencies
    install_docker
    install_docker_compose
    install_exegol
    configure_exegol_enhanced
    create_shortcuts
    validate_installation
    
    echo ""
    print_success "🎉 Exegol Enhanced installation completed successfully!"
    echo ""
    print_info "Next steps:"
    print_info "1. Logout and login again (or run: newgrp docker)"
    print_info "2. Run: exegol install"
    print_info "3. Start your first container: exegol start"
    print_info "4. For GUI support: exegol start -X"
    echo ""
    print_info "Useful commands:"
    print_info "- exegol-workspace: Go to workspace directory"
    print_info "- exegol-tools: Go to tools directory"
    print_info "- exegol-logs: View installation logs"
    echo ""
    print_info "Documentation: https://github.com/[your-repo]/exegol-enhanced"
    print_info "Support: Create an issue on GitHub"
    echo ""
    print_success "Happy hacking! 🚀"
}

# Run main function
main "$@"
