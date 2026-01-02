#!/bin/bash

# Alternative Crystal Installation via APT
# This script tries to install Crystal using system package managers
# as a fallback when snap and direct downloads don't work

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Install Crystal using available system tools
install_crystal_system() {
    print_status "Attempting to install Crystal using system package manager..."
    
    # Update package lists
    print_status "Updating package lists..."
    sudo apt update
    
    # Install build essentials and dependencies
    print_status "Installing build dependencies..."
    sudo apt install -y \
        build-essential \
        git \
        wget \
        curl \
        libbsd-dev \
        libedit-dev \
        libevent-dev \
        libgmp-dev \
        libgmpxx4ldbl \
        libssl-dev \
        libxml2-dev \
        libyaml-dev \
        libreadline-dev \
        libz-dev \
        pkg-config \
        libpcre3-dev
    
    # Try to install llvm (required for Crystal)
    print_status "Installing LLVM..."
    sudo apt install -y llvm-14 llvm-14-dev
    
    # Create a minimal Crystal environment by building a simple version
    print_status "Setting up Crystal development environment..."
    
    # Create crystal wrapper that can handle basic operations
    sudo mkdir -p /usr/local/bin
    
    # Remove any existing symlinks
    sudo rm -f /usr/local/bin/crystal /usr/local/bin/shards
    
    # Install Crystal from official sources using the install-crystal action method
    print_status "Installing Crystal from official GitHub releases..."
    
    # Download and install Crystal using the same method as crystal-lang/install-crystal action
    CRYSTAL_VERSION="1.10.1"
    CRYSTAL_URL="https://github.com/crystal-lang/crystal/releases/download/${CRYSTAL_VERSION}/crystal-${CRYSTAL_VERSION}-1-linux-x86_64.tar.gz"
    CRYSTAL_ARCHIVE="/tmp/crystal-${CRYSTAL_VERSION}.tar.gz"
    CRYSTAL_DIR="/opt/crystal"
    
    # Create Crystal directory
    sudo mkdir -p "$CRYSTAL_DIR"
    
    # Download Crystal from official GitHub releases
    print_status "Downloading Crystal ${CRYSTAL_VERSION} from official GitHub releases..."
    if curl -L -o "$CRYSTAL_ARCHIVE" "$CRYSTAL_URL"; then
        print_success "Downloaded Crystal archive"
        
        # Extract Crystal
        print_status "Extracting Crystal to $CRYSTAL_DIR..."
        sudo tar -xzf "$CRYSTAL_ARCHIVE" -C "$CRYSTAL_DIR" --strip-components=1
        
        # Create symlinks to official Crystal binaries
        print_status "Creating symlinks to official Crystal binaries..."
        sudo ln -sf "$CRYSTAL_DIR/bin/crystal" /usr/local/bin/crystal
        sudo ln -sf "$CRYSTAL_DIR/bin/shards" /usr/local/bin/shards
        
        # Clean up
        rm -f "$CRYSTAL_ARCHIVE"
        
    else
        print_error "Failed to download Crystal from official sources"
        print_error "Please install Crystal manually from https://crystal-lang.org/install/"
        return 1
    fi
    
    print_success "Crystal installed successfully from official sources!"
    return 0
}

# Verify the installation
verify_installation() {
    print_status "Verifying Crystal installation..."
    
    if command -v crystal &> /dev/null; then
        crystal version
        print_success "Crystal command is available"
    else
        print_error "Crystal command not found"
        return 1
    fi
    
    if command -v shards &> /dev/null; then
        shards version
        print_success "Shards command is available"
    else
        print_error "Shards command not found"
        return 1
    fi
    
    return 0
}

# Main function
main() {
    print_status "Crystal Installation from Official Sources"
    print_status "=========================================="
    
    install_crystal_system || {
        print_error "Failed to install Crystal from official sources"
        exit 1
    }
    
    verify_installation || {
        print_error "Failed to verify Crystal installation"
        exit 1
    }
    
    print_success "Crystal installation from official sources complete!"
    print_status ""
    print_status "Crystal has been installed from the official GitHub releases."
    print_status ""
    print_status "You can now run:"
    print_status "  crystal version"
    print_status "  shards version"
    print_status "  crystal build your_program.cr"
    print_status "  shards install"
}

main "$@"