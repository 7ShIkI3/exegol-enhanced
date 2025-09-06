#!/bin/bash

# Enhanced Nmap Scanner - Exegol Enhanced
# Developed with AI assistance for comprehensive network reconnaissance
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
OUTPUT_DIR="$HOME/exegol-workspace/recon/$(date +%Y%m%d_%H%M%S)"
THREADS=50
RATE_LIMIT=1000

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Banner
print_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    ENHANCED NMAP SCANNER                    ║"
    echo "║                     Exegol Enhanced                         ║"
    echo "║                                                              ║"
    echo "║           🎯 Advanced Network Reconnaissance 🎯             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print functions
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] TARGET"
    echo ""
    echo "OPTIONS:"
    echo "  -t, --target TARGET     Target IP/CIDR/hostname (required)"
    echo "  -p, --ports PORTS       Port specification (default: top 1000)"
    echo "  -s, --scan-type TYPE    Scan type: quick|full|stealth|aggressive"
    echo "  -o, --output DIR        Output directory (default: auto-generated)"
    echo "  -r, --rate RATE         Rate limit packets/sec (default: 1000)"
    echo "  -T, --threads NUM       Number of threads (default: 50)"
    echo "  --scripts CATEGORY      NSE script category (default: default,vuln)"
    echo "  --no-ping              Skip ping discovery"
    echo "  --udp                  Include UDP scan"
    echo "  --version-detection    Enable version detection"
    echo "  --os-detection         Enable OS detection"
    echo "  -v, --verbose          Verbose output"
    echo "  -h, --help             Show this help"
    echo ""
    echo "SCAN TYPES:"
    echo "  quick      - Fast TCP SYN scan of top 100 ports"
    echo "  full       - Comprehensive scan of all 65535 ports"
    echo "  stealth    - Stealthy scan with timing template T1"
    echo "  aggressive - Fast aggressive scan with all detection"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 -t 192.168.1.0/24 -s quick"
    echo "  $0 -t example.com -s full --version-detection"
    echo "  $0 -t 10.0.0.1 -p 80,443,8080 --scripts http-*"
}

# Parse arguments
parse_args() {
    SCAN_TYPE="quick"
    PORTS=""
    SCRIPTS="default,vuln"
    NO_PING=false
    UDP_SCAN=false
    VERSION_DETECTION=false
    OS_DETECTION=false
    VERBOSE=false
    TARGET=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--target)
                TARGET="$2"
                shift 2
                ;;
            -p|--ports)
                PORTS="$2"
                shift 2
                ;;
            -s|--scan-type)
                SCAN_TYPE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -r|--rate)
                RATE_LIMIT="$2"
                shift 2
                ;;
            -T|--threads)
                THREADS="$2"
                shift 2
                ;;
            --scripts)
                SCRIPTS="$2"
                shift 2
                ;;
            --no-ping)
                NO_PING=true
                shift
                ;;
            --udp)
                UDP_SCAN=true
                shift
                ;;
            --version-detection)
                VERSION_DETECTION=true
                shift
                ;;
            --os-detection)
                OS_DETECTION=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                if [[ -z "$TARGET" ]]; then
                    TARGET="$1"
                else
                    print_error "Unknown option: $1"
                    usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    if [[ -z "$TARGET" ]]; then
        print_error "Target is required!"
        usage
        exit 1
    fi
}

# Validate target
validate_target() {
    print_step "Validating target: $TARGET"
    
    # Check if target is reachable (unless no-ping is specified)
    if [[ "$NO_PING" == false ]]; then
        if ping -c 1 -W 3 "$TARGET" &>/dev/null; then
            print_success "Target is reachable"
        else
            print_warning "Target may not be reachable or blocks ping"
        fi
    fi
}

# Build nmap command based on scan type
build_nmap_command() {
    local base_cmd="nmap"
    local options=""
    
    # Base options
    options+=" --stats-every 30s"
    options+=" --max-rate $RATE_LIMIT"
    options+=" -oA $OUTPUT_DIR/nmap_scan"
    
    # Ping options
    if [[ "$NO_PING" == true ]]; then
        options+=" -Pn"
    fi
    
    # Version detection
    if [[ "$VERSION_DETECTION" == true ]]; then
        options+=" -sV"
    fi
    
    # OS detection
    if [[ "$OS_DETECTION" == true ]]; then
        options+=" -O"
    fi
    
    # Verbose output
    if [[ "$VERBOSE" == true ]]; then
        options+=" -v"
    fi
    
    # Scan type specific options
    case $SCAN_TYPE in
        quick)
            options+=" -sS -T4 --top-ports 100"
            ;;
        full)
            options+=" -sS -T4 -p-"
            ;;
        stealth)
            options+=" -sS -T1 -f"
            ;;
        aggressive)
            options+=" -sS -T4 -A"
            VERSION_DETECTION=true
            OS_DETECTION=true
            ;;
        *)
            print_error "Invalid scan type: $SCAN_TYPE"
            exit 1
            ;;
    esac
    
    # Port specification
    if [[ -n "$PORTS" ]]; then
        options+=" -p $PORTS"
    fi
    
    # NSE scripts
    if [[ -n "$SCRIPTS" ]]; then
        options+=" --script $SCRIPTS"
    fi
    
    # UDP scan (additional)
    if [[ "$UDP_SCAN" == true ]]; then
        UDP_CMD="nmap -sU -T4 --top-ports 100 -oA $OUTPUT_DIR/nmap_udp $TARGET"
    fi
    
    NMAP_CMD="$base_cmd$options $TARGET"
}

# Run host discovery
run_host_discovery() {
    if [[ "$TARGET" =~ "/" ]]; then  # CIDR notation
        print_step "Running host discovery on network: $TARGET"
        
        local discovery_cmd="nmap -sn -T4 -oA $OUTPUT_DIR/host_discovery $TARGET"
        
        print_info "Command: $discovery_cmd"
        eval "$discovery_cmd"
        
        # Parse results
        local alive_hosts=$(grep "Nmap scan report" "$OUTPUT_DIR/host_discovery.nmap" | wc -l)
        print_success "Found $alive_hosts alive hosts"
        
        # Extract IP addresses
        grep "Nmap scan report" "$OUTPUT_DIR/host_discovery.nmap" | \
            awk '{print $5}' | \
            grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' > "$OUTPUT_DIR/alive_hosts.txt"
    fi
}

# Run main scan
run_main_scan() {
    print_step "Running $SCAN_TYPE scan on: $TARGET"
    print_info "Output directory: $OUTPUT_DIR"
    print_info "Command: $NMAP_CMD"
    
    # Start time
    local start_time=$(date +%s)
    
    # Run the scan
    eval "$NMAP_CMD"
    
    # End time
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_success "Main scan completed in ${duration}s"
}

# Run UDP scan if requested
run_udp_scan() {
    if [[ "$UDP_SCAN" == true ]]; then
        print_step "Running UDP scan on: $TARGET"
        print_info "Command: $UDP_CMD"
        
        eval "$UDP_CMD"
        print_success "UDP scan completed"
    fi
}

# Parse and analyze results
analyze_results() {
    print_step "Analyzing scan results..."
    
    local nmap_file="$OUTPUT_DIR/nmap_scan.nmap"
    local xml_file="$OUTPUT_DIR/nmap_scan.xml"
    
    if [[ -f "$nmap_file" ]]; then
        # Count open ports
        local open_ports=$(grep "^[0-9]*/tcp.*open" "$nmap_file" | wc -l)
        local filtered_ports=$(grep "^[0-9]*/tcp.*filtered" "$nmap_file" | wc -l)
        local closed_ports=$(grep "^[0-9]*/tcp.*closed" "$nmap_file" | wc -l)
        
        print_info "Open ports: $open_ports"
        print_info "Filtered ports: $filtered_ports"
        print_info "Closed ports: $closed_ports"
        
        # Extract open ports to separate file
        grep "^[0-9]*/tcp.*open" "$nmap_file" > "$OUTPUT_DIR/open_ports.txt" 2>/dev/null || true
        
        # Extract services
        grep "^[0-9]*/tcp.*open" "$nmap_file" | \
            awk '{print $1 " " $3}' > "$OUTPUT_DIR/services.txt" 2>/dev/null || true
        
        # Check for interesting findings
        check_interesting_findings "$nmap_file"
    fi
}

# Check for interesting findings
check_interesting_findings() {
    local nmap_file="$1"
    local findings_file="$OUTPUT_DIR/interesting_findings.txt"
    
    print_step "Checking for interesting findings..."
    
    # Common interesting ports and services
    local interesting_patterns=(
        "21/tcp.*ftp"
        "22/tcp.*ssh"
        "23/tcp.*telnet"
        "25/tcp.*smtp"
        "53/tcp.*domain"
        "80/tcp.*http"
        "110/tcp.*pop3"
        "135/tcp.*msrpc"
        "139/tcp.*netbios"
        "143/tcp.*imap"
        "443/tcp.*https"
        "445/tcp.*microsoft-ds"
        "993/tcp.*imaps"
        "995/tcp.*pop3s"
        "1433/tcp.*ms-sql"
        "1521/tcp.*oracle"
        "3306/tcp.*mysql"
        "3389/tcp.*ms-wbt-server"
        "5432/tcp.*postgresql"
        "5900/tcp.*vnc"
        "6379/tcp.*redis"
        "8080/tcp.*http"
        "8443/tcp.*https"
        "27017/tcp.*mongodb"
    )
    
    echo "=== INTERESTING FINDINGS ===" > "$findings_file"
    echo "Scan Date: $(date)" >> "$findings_file"
    echo "Target: $TARGET" >> "$findings_file"
    echo "" >> "$findings_file"
    
    local found_interesting=false
    
    for pattern in "${interesting_patterns[@]}"; do
        if grep -i "$pattern" "$nmap_file" >> "$findings_file" 2>/dev/null; then
            found_interesting=true
        fi
    done
    
    # Check for vulnerabilities in NSE output
    if grep -i "VULNERABLE\|CVE-\|EXPLOIT" "$nmap_file" >> "$findings_file" 2>/dev/null; then
        found_interesting=true
        echo "" >> "$findings_file"
        echo "=== POTENTIAL VULNERABILITIES ===" >> "$findings_file"
        grep -i "VULNERABLE\|CVE-\|EXPLOIT" "$nmap_file" >> "$findings_file" 2>/dev/null || true
    fi
    
    if [[ "$found_interesting" == true ]]; then
        print_success "Interesting findings saved to: $findings_file"
    else
        print_info "No particularly interesting findings detected"
    fi
}

# Generate HTML report
generate_html_report() {
    print_step "Generating HTML report..."
    
    local html_file="$OUTPUT_DIR/scan_report.html"
    local xml_file="$OUTPUT_DIR/nmap_scan.xml"
    
    if [[ -f "$xml_file" ]] && command -v xsltproc &>/dev/null; then
        # Use nmap's XSL stylesheet if available
        local nmap_xsl="/usr/share/nmap/nmap.xsl"
        if [[ -f "$nmap_xsl" ]]; then
            xsltproc "$nmap_xsl" "$xml_file" > "$html_file"
            print_success "HTML report generated: $html_file"
        else
            print_warning "Nmap XSL stylesheet not found, skipping HTML report"
        fi
    else
        print_warning "XML file not found or xsltproc not available, skipping HTML report"
    fi
}

# Generate summary
generate_summary() {
    print_step "Generating scan summary..."
    
    local summary_file="$OUTPUT_DIR/scan_summary.txt"
    
    cat > "$summary_file" << EOF
=== EXEGOL ENHANCED NMAP SCAN SUMMARY ===
Scan Date: $(date)
Target: $TARGET
Scan Type: $SCAN_TYPE
Output Directory: $OUTPUT_DIR

=== SCAN PARAMETERS ===
Ports: ${PORTS:-"default"}
Scripts: $SCRIPTS
Rate Limit: $RATE_LIMIT pps
Threads: $THREADS
Version Detection: $VERSION_DETECTION
OS Detection: $OS_DETECTION
UDP Scan: $UDP_SCAN
No Ping: $NO_PING

=== FILES GENERATED ===
EOF
    
    # List all generated files
    find "$OUTPUT_DIR" -type f -exec basename {} \; | sort >> "$summary_file"
    
    echo "" >> "$summary_file"
    echo "=== QUICK STATS ===" >> "$summary_file"
    
    if [[ -f "$OUTPUT_DIR/nmap_scan.nmap" ]]; then
        local open_ports=$(grep "^[0-9]*/tcp.*open" "$OUTPUT_DIR/nmap_scan.nmap" | wc -l)
        echo "Open TCP Ports: $open_ports" >> "$summary_file"
    fi
    
    if [[ -f "$OUTPUT_DIR/nmap_udp.nmap" ]]; then
        local open_udp=$(grep "^[0-9]*/udp.*open" "$OUTPUT_DIR/nmap_udp.nmap" | wc -l)
        echo "Open UDP Ports: $open_udp" >> "$summary_file"
    fi
    
    print_success "Summary generated: $summary_file"
}

# Main function
main() {
    print_banner
    
    parse_args "$@"
    validate_target
    build_nmap_command
    
    print_info "Starting enhanced nmap scan..."
    print_info "Target: $TARGET"
    print_info "Scan Type: $SCAN_TYPE"
    print_info "Output: $OUTPUT_DIR"
    echo ""
    
    # Run scans
    run_host_discovery
    run_main_scan
    run_udp_scan
    
    # Analyze and report
    analyze_results
    generate_html_report
    generate_summary
    
    echo ""
    print_success "🎉 Enhanced nmap scan completed!"
    print_info "Results saved in: $OUTPUT_DIR"
    print_info "Key files:"
    print_info "  - nmap_scan.nmap (main results)"
    print_info "  - scan_summary.txt (summary)"
    print_info "  - interesting_findings.txt (key findings)"
    if [[ -f "$OUTPUT_DIR/scan_report.html" ]]; then
        print_info "  - scan_report.html (visual report)"
    fi
    echo ""
    print_info "Next steps:"
    print_info "  - Review interesting_findings.txt for potential targets"
    print_info "  - Run targeted scans on specific services"
    print_info "  - Use results for further enumeration"
}

# Run main function
main "$@"
