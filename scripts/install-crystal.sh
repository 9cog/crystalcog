#!/bin/bash

# Crystal Language Installation Script for CrystalCog
# Provides multiple installation methods with fallbacks when online sources are unavailable
# Usage: ./scripts/install-crystal.sh [OPTIONS]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
FORCE_INSTALL=false
CRYSTAL_VERSION="1.10.1"
INSTALL_METHOD=""
VERBOSE=false
DRY_RUN=false

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show help
show_help() {
    cat << EOF
Crystal Language Installation Script for CrystalCog

Usage: $0 [OPTIONS]

OPTIONS:
    -f, --force         Force reinstallation even if Crystal is already installed
    -v, --version VER   Specify Crystal version to install (default: $CRYSTAL_VERSION)
    -m, --method METHOD Specify installation method: snap, apt, binary, source
    --verbose          Enable verbose output
    --dry-run          Show what would be done without actually installing
    -h, --help         Show this help message

INSTALLATION METHODS:
    snap     - Install via Ubuntu snap (recommended)
    apt      - Install via apt package manager (may require adding repositories)
    binary   - Download and install precompiled binaries
    source   - Build from source (requires development tools)
    auto     - Automatically choose best available method (default)

EXAMPLES:
    $0                          # Auto-install using best method
    $0 --method snap            # Install via snap
    $0 --force --version 1.10.1 # Force install specific version
    $0 --dry-run                # Show what would be done

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                FORCE_INSTALL=true
                shift
                ;;
            -v|--version)
                CRYSTAL_VERSION="$2"
                shift 2
                ;;
            -m|--method)
                INSTALL_METHOD="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Check if Crystal is already installed
check_crystal_installed() {
    if command -v crystal &> /dev/null; then
        local version=$(crystal version | head -n1)
        print_status "Crystal is already installed: $version"
        
        if [[ "$FORCE_INSTALL" == "false" ]]; then
            print_success "Crystal installation is complete. Use --force to reinstall."
            exit 0
        else
            print_warning "Forcing reinstallation..."
        fi
    else
        print_status "Crystal is not installed or not in PATH"
    fi
}

# Install Crystal via snap
install_via_snap() {
    print_status "Installing Crystal via snap..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would run: sudo snap install crystal --classic"
        return 0
    fi
    
    if ! command -v snap &> /dev/null; then
        print_error "Snap is not available on this system"
        return 1
    fi
    
    # Install Crystal via snap
    sudo snap install crystal --classic
    
    # Verify installation
    if command -v crystal &> /dev/null; then
        local version=$(crystal version | head -n1)
        print_success "Crystal installed successfully via snap: $version"
        return 0
    else
        print_error "Crystal installation via snap failed"
        return 1
    fi
}

# Install Crystal via apt (requires adding repository)
install_via_apt() {
    print_status "Installing Crystal via apt..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would run apt-based installation commands"
        return 0
    fi
    
    # Check if apt is available
    if ! command -v apt &> /dev/null; then
        print_error "APT is not available on this system"
        return 1
    fi
    
    # Try the dedicated official Crystal installation script
    local apt_script="$(dirname "$0")/../crystal-lang/install/install-via-apt.sh"
    if [[ -f "$apt_script" ]]; then
        print_status "Using official Crystal installation script..."
        "$apt_script"
        return $?
    fi
    
    # Fallback: Try to use snap or other methods
    print_status "Falling back to snap installation method..."
    install_via_snap
}

# Install Crystal via precompiled binary
install_via_binary() {
    print_status "Installing Crystal via precompiled binary..."
    
    local crystal_dir="/opt/crystal"
    local crystal_url="https://github.com/crystal-lang/crystal/releases/download/${CRYSTAL_VERSION}/crystal-${CRYSTAL_VERSION}-1-linux-x86_64.tar.gz"
    local crystal_archive="/tmp/crystal-${CRYSTAL_VERSION}.tar.gz"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would download: $crystal_url"
        echo "Would extract to: $crystal_dir"
        echo "Would create symlinks in /usr/local/bin"
        return 0
    fi
    
    # Create crystal directory
    sudo mkdir -p "$crystal_dir"
    
    # Try to download from GitHub releases (official Crystal releases)
    print_status "Downloading Crystal ${CRYSTAL_VERSION} from official GitHub releases..."
    if curl -L -o "$crystal_archive" "$crystal_url"; then
        print_success "Downloaded Crystal archive"
    else
        print_error "Failed to download Crystal from official GitHub releases"
        
        # Try to use pre-downloaded binary if available in the monorepo
        local local_binary="$(dirname "$0")/../crystal-lang/crystal-${CRYSTAL_VERSION}-linux-x86_64.tar.gz"
        if [[ -f "$local_binary" ]]; then
            print_status "Using pre-downloaded Crystal binary from monorepo"
            crystal_archive="$local_binary"
        else
            print_error "No fallback Crystal binary found in monorepo"
            return 1
        fi
    fi
    
    # Extract and install
    print_status "Extracting Crystal to $crystal_dir..."
    sudo tar -xzf "$crystal_archive" -C "$crystal_dir" --strip-components=1
    
    # Create symlinks
    print_status "Creating symlinks..."
    sudo ln -sf "$crystal_dir/bin/crystal" /usr/local/bin/crystal
    sudo ln -sf "$crystal_dir/bin/shards" /usr/local/bin/shards
    
    # Verify installation
    if command -v crystal &> /dev/null; then
        local version=$(crystal version | head -n1)
        print_success "Crystal installed successfully via binary: $version"
        return 0
    else
        print_error "Crystal binary installation failed"
        return 1
    fi
}

# Install Crystal from source (last resort)
install_via_source() {
    print_status "Installing Crystal from source..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would clone Crystal source and build from source"
        return 0
    fi
    
    print_error "Source installation not implemented yet"
    print_status "This would require downloading Crystal source code and building"
    print_status "Consider using snap or binary installation methods instead"
    return 1
}

# Automatically choose the best installation method
auto_install() {
    print_status "Automatically choosing installation method..."
    
    # First try snap if available
    if command -v snap &> /dev/null; then
        print_status "Snap is available, trying snap installation"
        if install_via_snap; then
            return 0
        else
            print_warning "Snap installation failed, trying apt method"
        fi
    fi
    
    # Try apt-based installation
    if command -v apt &> /dev/null; then
        print_status "APT is available, trying apt installation"
        if install_via_apt; then
            return 0
        else
            print_warning "APT installation failed, trying binary method"
        fi
    fi
    
    # Fall back to binary installation
    print_status "Trying binary installation as last resort"
    install_via_binary
    return $?
}

# Verify Crystal and shards work correctly
verify_installation() {
    print_status "Verifying Crystal installation..."
    
    # Check Crystal
    if ! command -v crystal &> /dev/null; then
        print_error "Crystal command not found after installation"
        return 1
    fi
    
    # Check shards
    if ! command -v shards &> /dev/null; then
        print_error "Shards command not found after installation"
        return 1
    fi
    
    # Test Crystal version
    local version=$(crystal version | head -n1)
    print_success "Crystal is working: $version"
    
    # Test shards version
    local shards_version=$(shards version | head -n1)
    print_success "Shards is working: $shards_version"
    
    return 0
}

# Main installation logic
main() {
    print_status "Crystal Language Installation Script for CrystalCog"
    print_status "============================================="
    
    parse_args "$@"
    
    if [[ "$VERBOSE" == "true" ]]; then
        print_status "Verbose mode enabled"
        print_status "Crystal version: $CRYSTAL_VERSION"
        print_status "Install method: ${INSTALL_METHOD:-auto}"
        print_status "Force install: $FORCE_INSTALL"
        print_status "Dry run: $DRY_RUN"
    fi
    
    check_crystal_installed
    
    # Choose installation method
    case "$INSTALL_METHOD" in
        snap)
            install_via_snap || exit 1
            ;;
        apt)
            install_via_apt || exit 1
            ;;
        binary)
            install_via_binary || exit 1
            ;;
        source)
            install_via_source || exit 1
            ;;
        auto|"")
            auto_install || exit 1
            ;;
        *)
            print_error "Unknown installation method: $INSTALL_METHOD"
            show_help
            exit 1
            ;;
    esac
    
    if [[ "$DRY_RUN" == "false" ]]; then
        verify_installation || exit 1
        
        print_success "Crystal installation completed successfully!"
        print_status "You can now run Crystal commands:"
        print_status "  crystal --version"
        print_status "  shards --version"
        print_status ""
        print_status "To test the CrystalCog project:"
        print_status "  cd /path/to/crystalcog"
        print_status "  shards install"
        print_status "  ./scripts/test-runner.sh"
    fi
}

# Run main function
main "$@"