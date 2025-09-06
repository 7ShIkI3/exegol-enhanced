#!/bin/bash

# Exegol Enhanced - Setup Script
# Developed with AI assistance for initial environment setup
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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VOLUMES_DIR="$HOME/.exegol-enhanced/volumes"

# Print functions
print_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 EXEGOL ENHANCED SETUP                       ║"
    echo "║              Initial Environment Setup                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

# Create directory structure
create_directories() {
    print_step "Creating directory structure..."
    
    # Main directories
    mkdir -p "$PROJECT_DIR"/{workspace,web,configs,examples}
    mkdir -p "$PROJECT_DIR/workspace"/{recon,exploitation,post-exploitation,reports,loot}
    
    # Volume directories for Docker
    mkdir -p "$VOLUMES_DIR"/{home,opt,postgres,redis,filebrowser}
    
    # Set permissions
    chmod 755 "$PROJECT_DIR/workspace"
    chmod 755 "$VOLUMES_DIR"
    
    print_success "Directory structure created"
}

# Create environment file
create_env_file() {
    print_step "Creating environment configuration..."
    
    cat > "$PROJECT_DIR/.env" << EOF
# Exegol Enhanced Environment Configuration
# Generated on $(date)

# Display configuration
DISPLAY=${DISPLAY:-:0}

# Timezone
TZ=${TZ:-UTC}

# Database passwords (change these in production!)
DB_PASSWORD=exegol_secure_$(openssl rand -hex 8)
REDIS_PASSWORD=exegol_redis_$(openssl rand -hex 8)
VNC_PASSWORD=exegol_vnc_$(openssl rand -hex 8)

# Volume paths
VOLUMES_DIR=$VOLUMES_DIR

# User configuration
USER_ID=$(id -u)
GROUP_ID=$(id -g)
EOF
    
    print_success "Environment file created: $PROJECT_DIR/.env"
}

# Create basic web interface
create_web_interface() {
    print_step "Creating basic web interface..."
    
    cat > "$PROJECT_DIR/web/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exegol Enhanced - Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        .header {
            background: rgba(0, 0, 0, 0.2);
            padding: 2rem;
            text-align: center;
            backdrop-filter: blur(10px);
        }
        
        .header h1 {
            font-size: 3rem;
            margin-bottom: 0.5rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        
        .header p {
            font-size: 1.2rem;
            opacity: 0.9;
        }
        
        .container {
            flex: 1;
            padding: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            width: 100%;
        }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }
        
        .card {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 2rem;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
        
        .card h3 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            color: #fff;
        }
        
        .card p {
            opacity: 0.9;
            line-height: 1.6;
            margin-bottom: 1rem;
        }
        
        .btn {
            display: inline-block;
            padding: 0.8rem 1.5rem;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            transition: all 0.3s ease;
        }
        
        .btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
        
        .status {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
        
        .status-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #4ade80;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        .footer {
            text-align: center;
            padding: 2rem;
            opacity: 0.7;
        }
        
        .emoji {
            font-size: 2rem;
            margin-bottom: 1rem;
            display: block;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Exegol Enhanced</h1>
        <p>Ultimate Cybersecurity Environment - Phase 1</p>
    </div>
    
    <div class="container">
        <div class="status">
            <div class="status-dot"></div>
            <span>System Online - Phase 1 Active</span>
        </div>
        
        <div class="grid">
            <div class="card">
                <span class="emoji">🎯</span>
                <h3>Enhanced Tools</h3>
                <p>Access to advanced reconnaissance, exploitation, and post-exploitation tools with enhanced capabilities.</p>
                <a href="#" class="btn">Launch Terminal</a>
            </div>
            
            <div class="card">
                <span class="emoji">📁</span>
                <h3>File Manager</h3>
                <p>Manage your workspace files, upload/download data, and organize your penetration testing artifacts.</p>
                <a href="http://localhost:8081" class="btn" target="_blank">Open Files</a>
            </div>
            
            <div class="card">
                <span class="emoji">🖥️</span>
                <h3>VNC Access</h3>
                <p>Remote desktop access to the full GUI environment with all graphical tools available.</p>
                <a href="http://localhost:6901" class="btn" target="_blank">Open VNC</a>
            </div>
            
            <div class="card">
                <span class="emoji">📊</span>
                <h3>Reports</h3>
                <p>View generated reports, scan results, and analysis outputs from your security assessments.</p>
                <a href="/workspace/reports" class="btn">View Reports</a>
            </div>
            
            <div class="card">
                <span class="emoji">🔧</span>
                <h3>Configuration</h3>
                <p>Manage container settings, environment variables, and tool configurations.</p>
                <a href="#" class="btn">Settings</a>
            </div>
            
            <div class="card">
                <span class="emoji">📚</span>
                <h3>Documentation</h3>
                <p>Access comprehensive documentation, tutorials, and usage guides for all enhanced features.</p>
                <a href="https://github.com/[your-repo]/exegol-enhanced" class="btn" target="_blank">View Docs</a>
            </div>
        </div>
        
        <div style="margin-top: 3rem; text-align: center;">
            <h2>🎉 Phase 1 Complete!</h2>
            <p style="margin-top: 1rem; font-size: 1.1rem;">
                You now have a fully functional Exegol Enhanced environment with advanced tools,
                automated installation, and professional documentation.
            </p>
            <p style="margin-top: 0.5rem; opacity: 0.8;">
                Phase 2 will add 20+ custom scripts and advanced automation features.
            </p>
        </div>
    </div>
    
    <div class="footer">
        <p>Exegol Enhanced v1.0.0 - Developed with AI assistance</p>
        <p>Built on the excellent foundation of Exegol by @ShutdownRepo</p>
    </div>
</body>
</html>
EOF
    
    print_success "Web interface created"
}

# Create database initialization script
create_db_init() {
    print_step "Creating database initialization script..."
    
    cat > "$PROJECT_DIR/configs/init.sql" << 'EOF'
-- Exegol Enhanced Database Initialization
-- Created for storing scan results and configurations

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS exegol_enhanced;

-- Use the database
\c exegol_enhanced;

-- Create tables for scan results
CREATE TABLE IF NOT EXISTS scan_results (
    id SERIAL PRIMARY KEY,
    scan_type VARCHAR(50) NOT NULL,
    target VARCHAR(255) NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(20) DEFAULT 'running',
    results JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create table for tool configurations
CREATE TABLE IF NOT EXISTS tool_configs (
    id SERIAL PRIMARY KEY,
    tool_name VARCHAR(100) NOT NULL,
    config_name VARCHAR(100) NOT NULL,
    config_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create table for user sessions
CREATE TABLE IF NOT EXISTS user_sessions (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) UNIQUE NOT NULL,
    user_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_scan_results_target ON scan_results(target);
CREATE INDEX IF NOT EXISTS idx_scan_results_type ON scan_results(scan_type);
CREATE INDEX IF NOT EXISTS idx_scan_results_status ON scan_results(status);
CREATE INDEX IF NOT EXISTS idx_tool_configs_tool ON tool_configs(tool_name);
CREATE INDEX IF NOT EXISTS idx_sessions_id ON user_sessions(session_id);

-- Insert some default configurations
INSERT INTO tool_configs (tool_name, config_name, config_data) VALUES
('enhanced-nmap', 'default', '{"threads": 50, "rate_limit": 1000, "timeout": 30}'),
('web-fuzzer', 'default', '{"threads": 20, "delay": 0, "timeout": 10}'),
('crypto-analyzer', 'default', '{"wordlist_size": 1000, "algorithms": ["md5", "sha1", "sha256"]}'
);

-- Create a view for recent scans
CREATE OR REPLACE VIEW recent_scans AS
SELECT 
    id,
    scan_type,
    target,
    status,
    start_time,
    end_time,
    EXTRACT(EPOCH FROM (COALESCE(end_time, CURRENT_TIMESTAMP) - start_time)) as duration_seconds
FROM scan_results 
ORDER BY start_time DESC 
LIMIT 100;

COMMIT;
EOF
    
    print_success "Database initialization script created"
}

# Create file browser configuration
create_filebrowser_config() {
    print_step "Creating file browser configuration..."
    
    cat > "$PROJECT_DIR/configs/filebrowser.json" << 'EOF'
{
  "port": 80,
  "baseURL": "",
  "address": "",
  "log": "stdout",
  "database": "/database/filebrowser.db",
  "root": "/srv",
  "username": "admin",
  "password": "exegol",
  "scope": "/srv",
  "allowCommands": true,
  "allowEdit": true,
  "allowNew": true,
  "commands": [
    "git",
    "python3",
    "bash",
    "sh"
  ]
}
EOF
    
    print_success "File browser configuration created"
}

# Create quick start script
create_quick_start() {
    print_step "Creating quick start script..."
    
    cat > "$PROJECT_DIR/start.sh" << 'EOF'
#!/bin/bash

# Exegol Enhanced - Quick Start Script
# Version: 1.0.0

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                 EXEGOL ENHANCED LAUNCHER                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if Docker is running
if ! docker info &>/dev/null; then
    echo -e "${YELLOW}[WARNING]${NC} Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &>/dev/null && ! docker compose version &>/dev/null; then
    echo -e "${YELLOW}[WARNING]${NC} Docker Compose is not available."
    exit 1
fi

echo -e "${BLUE}[INFO]${NC} Starting Exegol Enhanced environment..."

# Use docker compose or docker-compose
if docker compose version &>/dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# Start the environment
$COMPOSE_CMD up -d

echo -e "${GREEN}[SUCCESS]${NC} Exegol Enhanced is starting up!"
echo ""
echo "🌐 Web Interface: http://localhost:8080"
echo "📁 File Manager: http://localhost:8081"
echo "🖥️  VNC Access: http://localhost:6901"
echo ""
echo "To access the main container:"
echo "  $COMPOSE_CMD exec exegol-main bash"
echo ""
echo "To stop the environment:"
echo "  $COMPOSE_CMD down"
echo ""
echo -e "${GREEN}Happy hacking! 🚀${NC}"
EOF
    
    chmod +x "$PROJECT_DIR/start.sh"
    
    print_success "Quick start script created"
}

# Create example configurations
create_examples() {
    print_step "Creating example configurations..."
    
    # Example nmap scan
    cat > "$PROJECT_DIR/examples/example-nmap-scan.sh" << 'EOF'
#!/bin/bash
# Example: Enhanced Nmap Scan

# Quick network discovery
./tools/recon/enhanced-nmap.sh -t 192.168.1.0/24 -s quick

# Full port scan with version detection
./tools/recon/enhanced-nmap.sh -t example.com -s full --version-detection

# Stealth scan with custom scripts
./tools/recon/enhanced-nmap.sh -t 10.0.0.1 -s stealth --scripts vuln,exploit
EOF
    
    # Example web fuzzing
    cat > "$PROJECT_DIR/examples/example-web-fuzzing.py" << 'EOF'
#!/usr/bin/env python3
# Example: Web Application Fuzzing

import subprocess
import sys

# Directory fuzzing
subprocess.run([
    "./tools/exploitation/web-fuzzer.py",
    "-u", "http://example.com/",
    "-m", "directory",
    "-t", "30",
    "-e", ".php,.html,.txt"
])

# Parameter fuzzing
subprocess.run([
    "./tools/exploitation/web-fuzzer.py",
    "-u", "http://example.com/search.php",
    "-m", "parameter",
    "-p", "q,search,query",
    "-t", "20"
])
EOF
    
    # Example crypto analysis
    cat > "$PROJECT_DIR/examples/example-crypto-analysis.py" << 'EOF'
#!/usr/bin/env python3
# Example: Cryptographic Analysis

import subprocess

# Hash identification
subprocess.run([
    "./tools/post-exploitation/crypto-analyzer.py",
    "--hash", "5d41402abc4b2a76b9719d911017c592"
])

# Caesar cipher analysis
subprocess.run([
    "./tools/post-exploitation/crypto-analyzer.py",
    "--caesar", "KHOOR ZRUOG"
])

# Frequency analysis
subprocess.run([
    "./tools/post-exploitation/crypto-analyzer.py",
    "--frequency", "ETAOIN SHRDLU"
])
EOF
    
    chmod +x "$PROJECT_DIR/examples"/*.sh
    chmod +x "$PROJECT_DIR/examples"/*.py
    
    print_success "Example configurations created"
}

# Main setup function
main() {
    print_banner
    
    print_info "Setting up Exegol Enhanced environment..."
    print_info "Project directory: $PROJECT_DIR"
    
    create_directories
    create_env_file
    create_web_interface
    create_db_init
    create_filebrowser_config
    create_quick_start
    create_examples
    
    echo ""
    print_success "🎉 Exegol Enhanced setup completed!"
    echo ""
    print_info "Next steps:"
    print_info "1. Review and customize .env file if needed"
    print_info "2. Run: ./start.sh to launch the environment"
    print_info "3. Access web interface at http://localhost:8080"
    echo ""
    print_info "For manual control:"
    print_info "  docker-compose up -d    # Start services"
    print_info "  docker-compose down     # Stop services"
    print_info "  docker-compose logs     # View logs"
    echo ""
    print_success "Ready to hack! 🚀"
}

# Run main function
main "$@"
