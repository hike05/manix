#!/bin/bash
set -euo pipefail

# Nix Darwin Configuration - System Compatibility Check
# This script checks system requirements and compatibility

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check results
PASS=0
FAIL=0
WARN=0

check_result() {
    case $1 in
        "pass") ((PASS++)) ;;
        "fail") ((FAIL++)) ;;
        "warn") ((WARN++)) ;;
    esac
}

# Check macOS version
check_macos_version() {
    log "Checking macOS version..."
    local version
    version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "$version" | cut -d. -f1)
    local minor_version
    minor_version=$(echo "$version" | cut -d. -f2)
    
    echo "  Current version: $version"
    
    if [[ $major_version -ge 14 ]]; then
        success "macOS version is optimal ($version)"
        check_result "pass"
    elif [[ $major_version -ge 12 ]]; then
        success "macOS version is supported ($version)"
        check_result "pass"
    elif [[ $major_version -ge 10 && $minor_version -ge 15 ]]; then
        warning "macOS version is old but may work ($version)"
        check_result "warn"
    else
        error "macOS version is too old ($version). Minimum: 10.15"
        check_result "fail"
    fi
}

# Check processor architecture
check_processor() {
    log "Checking processor architecture..."
    local arch
    arch=$(uname -m)
    
    echo "  Architecture: $arch"
    
    case $arch in
        "arm64")
            success "Apple Silicon (M1/M2/M3) - Optimal support"
            check_result "pass"
            ;;
        "x86_64")
            success "Intel x86_64 - Full support"
            check_result "pass"
            ;;
        *)
            error "Unsupported architecture: $arch"
            check_result "fail"
            ;;
    esac
}

# Check available disk space
check_disk_space() {
    log "Checking available disk space..."
    local available_gb
    available_gb=$(df -H / | awk 'NR==2 {print int($4/1000000000)}')
    local used_percent
    used_percent=$(df -H / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    echo "  Available space: ${available_gb}GB"
    echo "  Disk usage: ${used_percent}%"
    
    if [[ $available_gb -ge 50 ]]; then
        success "Plenty of disk space available (${available_gb}GB)"
        check_result "pass"
    elif [[ $available_gb -ge 20 ]]; then
        success "Sufficient disk space available (${available_gb}GB)"
        check_result "pass"
    elif [[ $available_gb -ge 10 ]]; then
        warning "Limited disk space (${available_gb}GB). Monitor usage carefully"
        check_result "warn"
    else
        error "Insufficient disk space (${available_gb}GB). Minimum: 10GB"
        check_result "fail"
    fi
}

# Check memory
check_memory() {
    log "Checking system memory..."
    local memory_gb
    memory_gb=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
    
    echo "  Total RAM: ${memory_gb}GB"
    
    if [[ $memory_gb -ge 16 ]]; then
        success "Excellent RAM capacity (${memory_gb}GB)"
        check_result "pass"
    elif [[ $memory_gb -ge 8 ]]; then
        success "Good RAM capacity (${memory_gb}GB)"
        check_result "pass"
    elif [[ $memory_gb -ge 4 ]]; then
        warning "Limited RAM (${memory_gb}GB). Performance may be affected"
        check_result "warn"
    else
        error "Insufficient RAM (${memory_gb}GB). Minimum: 4GB"
        check_result "fail"
    fi
}

# Check Xcode Command Line Tools
check_xcode_tools() {
    log "Checking Xcode Command Line Tools..."
    
    if xcode-select -p >/dev/null 2>&1; then
        local xcode_path
        xcode_path=$(xcode-select -p)
        echo "  Installed at: $xcode_path"
        success "Xcode Command Line Tools are installed"
        check_result "pass"
    else
        warning "Xcode Command Line Tools not installed"
        echo "  Install with: xcode-select --install"
        check_result "warn"
    fi
}

# Check existing Nix installation
check_existing_nix() {
    log "Checking for existing Nix installation..."
    
    if command -v nix >/dev/null 2>&1; then
        local nix_version
        nix_version=$(nix --version 2>/dev/null | head -n1)
        echo "  Found: $nix_version"
        
        # Check if experimental features are enabled
        if nix flake --help >/dev/null 2>&1; then
            success "Nix with flakes support detected"
            check_result "pass"
        else
            warning "Nix found but flakes not enabled"
            check_result "warn"
        fi
    else
        log "Nix not installed (this is normal for fresh systems)"
        check_result "pass"
    fi
}

# Check for conflicting package managers
check_conflicting_managers() {
    log "Checking for potential conflicts..."
    
    local conflicts=()
    
    # Check for MacPorts
    if command -v port >/dev/null 2>&1; then
        conflicts+=("MacPorts")
    fi
    
    # Check for Fink
    if [[ -d /sw ]]; then
        conflicts+=("Fink")
    fi
    
    # Check for conda in PATH
    if command -v conda >/dev/null 2>&1; then
        conflicts+=("Conda (in PATH)")
    fi
    
    if [[ ${#conflicts[@]} -eq 0 ]]; then
        success "No conflicting package managers found"
        check_result "pass"
    else
        warning "Potential conflicts detected: ${conflicts[*]}"
        echo "  These may cause PATH or library conflicts"
        check_result "warn"
    fi
}

# Check Homebrew
check_homebrew() {
    log "Checking Homebrew installation..."
    
    if command -v brew >/dev/null 2>&1; then
        local brew_version
        brew_version=$(brew --version | head -n1)
        local brew_prefix
        brew_prefix=$(brew --prefix)
        
        echo "  Found: $brew_version"
        echo "  Prefix: $brew_prefix"
        
        # Check if Homebrew is in the right location
        local expected_prefix
        if [[ $(uname -m) == "arm64" ]]; then
            expected_prefix="/opt/homebrew"
        else
            expected_prefix="/usr/local"
        fi
        
        if [[ "$brew_prefix" == "$expected_prefix" ]]; then
            success "Homebrew is properly installed"
            check_result "pass"
        else
            warning "Homebrew is in unexpected location: $brew_prefix"
            check_result "warn"
        fi
    else
        log "Homebrew not installed (will be managed by nix-darwin)"
        check_result "pass"
    fi
}

# Check network connectivity
check_network() {
    log "Checking network connectivity..."
    
    # Check if we can reach essential services
    local services=("github.com" "cache.nixos.org" "api.github.com")
    local failed_services=()
    
    for service in "${services[@]}"; do
        if ! curl -s --connect-timeout 5 "https://$service" >/dev/null 2>&1; then
            failed_services+=("$service")
        fi
    done
    
    if [[ ${#failed_services[@]} -eq 0 ]]; then
        success "Network connectivity is good"
        check_result "pass"
    else
        warning "Cannot reach: ${failed_services[*]}"
        echo "  Check firewall/proxy settings"
        check_result "warn"
    fi
}

# Check file system permissions
check_permissions() {
    log "Checking file system permissions..."
    
    # Check if we can write to necessary directories
    local test_dirs=("$HOME" "/tmp")
    local permission_issues=()
    
    for dir in "${test_dirs[@]}"; do
        if ! touch "$dir/.nix-check-test" 2>/dev/null; then
            permission_issues+=("$dir")
        else
            rm -f "$dir/.nix-check-test"
        fi
    done
    
    if [[ ${#permission_issues[@]} -eq 0 ]]; then
        success "File system permissions are correct"
        check_result "pass"
    else
        error "Cannot write to: ${permission_issues[*]}"
        check_result "fail"
    fi
}

# Check System Integrity Protection (SIP)
check_sip() {
    log "Checking System Integrity Protection (SIP)..."
    
    local sip_status
    sip_status=$(csrutil status 2>/dev/null || echo "unknown")
    
    echo "  SIP Status: $sip_status"
    
    if [[ $sip_status == *"enabled"* ]]; then
        success "SIP is enabled (recommended for security)"
        check_result "pass"
    elif [[ $sip_status == *"disabled"* ]]; then
        warning "SIP is disabled (may cause issues)"
        check_result "warn"
    else
        warning "SIP status unknown"
        check_result "warn"
    fi
}

# Print summary
print_summary() {
    echo
    echo "🔍 System Compatibility Check Summary"
    echo "===================================="
    echo
    
    if [[ $FAIL -eq 0 && $WARN -eq 0 ]]; then
        success "🎉 Your system is fully compatible!"
        echo "  All checks passed. You can proceed with installation."
    elif [[ $FAIL -eq 0 ]]; then
        warning "⚠️  Your system is mostly compatible"
        echo "  ${WARN} warning(s) detected. Installation should work but monitor for issues."
    else
        error "❌ Compatibility issues detected"
        echo "  ${FAIL} critical issue(s) must be resolved before installation."
        echo "  ${WARN} additional warning(s) should be addressed."
    fi
    
    echo
    echo "📊 Check Results:"
    echo "  ✅ Passed: $PASS"
    echo "  ⚠️  Warnings: $WARN"
    echo "  ❌ Failed: $FAIL"
    echo
    
    if [[ $FAIL -gt 0 ]]; then
        echo "🔧 Recommended actions:"
        echo "  1. Resolve critical issues listed above"
        echo "  2. Re-run this check script"
        echo "  3. Proceed with installation once all issues are resolved"
        echo
        return 1
    else
        echo "🚀 Ready for installation!"
        echo "  Run: ./scripts/install.sh"
        echo
        return 0
    fi
}

# Main function
main() {
    echo "🔍 Nix Darwin System Compatibility Check"
    echo "======================================="
    echo
    
    check_macos_version
    check_processor
    check_disk_space
    check_memory
    check_xcode_tools
    check_existing_nix
    check_conflicting_managers
    check_homebrew
    check_network
    check_permissions
    check_sip
    
    print_summary
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo
        echo "This script checks system compatibility for Nix Darwin installation."
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --quiet, -q    Run in quiet mode (less output)"
        echo
        exit 0
        ;;
    --quiet|-q)
        # Suppress some output in quiet mode
        log() { :; }
        ;;
esac

# Run main check
main "$@"