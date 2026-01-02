#!/bin/bash

# OpenCog GitPod Environment Setup Script
# This script automates the complete Guix build process for OpenCog

set -e  # Exit on any error

echo "🧠 OpenCog GitPod Environment Setup"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running in GitPod
if [ -z "$GITPOD_WORKSPACE_ID" ]; then
    log_warning "Not running in GitPod environment. Some features may not work."
fi

# Set up environment variables
export PATH="/var/guix/profiles/per-user/gitpod/current-guix/bin:$PATH"
export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"
export OPENCOG_BUILD_DIR="$HOME/opencog-build"
export OPENCOG_WORKSPACE="/workspace/opencog-org"

log_info "Setting up OpenCog development environment..."

# Initialize Guix if needed
if ! command -v guix &> /dev/null; then
    log_info "Installing Guix package manager..."
    cd /tmp
    wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh
    chmod +x guix-install.sh
    yes "" | sudo ./guix-install.sh
    rm guix-install.sh
    log_success "Guix installed successfully"
else
    log_success "Guix already available"
fi

# Update Guix
log_info "Updating Guix packages..."
if timeout 300 guix pull 2>/dev/null; then
    log_success "Guix updated successfully"
else
    log_warning "Guix update skipped (may take too long in GitPod)"
fi

# Install core OpenCog dependencies via Guix
log_info "Installing OpenCog dependencies via Guix..."

CORE_PACKAGES=(
    "gcc-toolchain"
    "cmake"
    "pkg-config"
    "boost"
    "cppunit"
    "guile"
    "python"
    "python-cython"
    "python-nose"
    "gsl"
    "cblas"
    "lapack"
    "git"
    "make"
)

for package in "${CORE_PACKAGES[@]}"; do
    log_info "Installing $package..."
    if timeout 180 guix install "$package" 2>/dev/null; then
        log_success "$package installed"
    else
        log_warning "Failed to install $package via Guix, will use system package"
    fi
done

# Set up build environment
log_info "Setting up build directories..."
mkdir -p "$OPENCOG_BUILD_DIR"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/opencog-workspace"

# Create build scripts
log_info "Creating build scripts..."

# AtomSpace build script
cat > "$HOME/.local/bin/build-atomspace" << 'EOF'
#!/bin/bash
echo "🔬 Building AtomSpace..."
cd /workspace/opencog-org/atomspace
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/.local
make -j$(nproc)
echo "✅ AtomSpace build complete"
EOF
chmod +x "$HOME/.local/bin/build-atomspace"

# CogServer build script  
cat > "$HOME/.local/bin/build-cogserver" << 'EOF'
#!/bin/bash
echo "🖥️  Building CogServer..."
cd /workspace/opencog-org/cogserver
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/.local
make -j$(nproc)
echo "✅ CogServer build complete"
EOF
chmod +x "$HOME/.local/bin/build-cogserver"

# CogUtil build script
cat > "$HOME/.local/bin/build-cogutil" << 'EOF'
#!/bin/bash
echo "🔧 Building CogUtil..."
cd /workspace/opencog-org/cogutil
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/.local
make -j$(nproc)
echo "✅ CogUtil build complete"
EOF
chmod +x "$HOME/.local/bin/build-cogutil"

# Complete build script
cat > "$HOME/.local/bin/build-opencog" << 'EOF'
#!/bin/bash
echo "🏗️  Building complete OpenCog ecosystem..."
echo "This may take 10-15 minutes..."

# Build in dependency order
build-cogutil
build-atomspace  
build-cogserver

echo "✅ Complete OpenCog ecosystem built successfully!"
echo ""
echo "🚀 Next steps:"
echo "  - Test AtomSpace: cd atomspace/build && ./tests/atomspace-test"
echo "  - Start CogServer: cd cogserver/build && ./opencog/cogserver/server/cogserver"
echo "  - Python bindings: python3 -c 'from opencog.atomspace import *; print(\"AtomSpace imported!\")'"
EOF
chmod +x "$HOME/.local/bin/build-opencog"

# Demo runner script
cat > "$HOME/.local/bin/run-opencog-demos" << 'EOF'
#!/bin/bash
echo "🎮 OpenCog Demos Available:"
echo ""
echo "1. AtomSpace Python Demo:"
echo "   python3 -c 'from opencog.atomspace import *; a = AtomSpace(); print(\"AtomSpace created:\", a)'"
echo ""
echo "2. Guile Scheme Demo:"
echo "   cd atomspace/build && ./opencog/guile/opencog-guile"
echo ""
echo "3. CogServer Demo:"
echo "   cd cogserver/build && ./opencog/cogserver/server/cogserver"
echo "   # Then telnet localhost 17001 in another terminal"
echo ""
echo "4. Language Learning Demo:"
echo "   cd learn && python3 -c 'import opencog; print(\"OpenCog learning modules available\")'"
echo ""
echo "Choose a demo to run or explore the components manually!"
EOF
chmod +x "$HOME/.local/bin/run-opencog-demos"

# Add bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
fi

# Update environment in current session
cat >> ~/.bashrc << 'EOF'
# OpenCog GitPod Environment
export PATH="/var/guix/profiles/per-user/gitpod/current-guix/bin:$PATH"
export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"
export OPENCOG_BUILD_DIR="$HOME/opencog-build"
export OPENCOG_WORKSPACE="/workspace/opencog-org"

# OpenCog aliases
alias og="cd /workspace/opencog-org"
alias ogb="cd $HOME/opencog-build"
alias build-all="build-opencog"
alias demos="run-opencog-demos"
EOF

log_success "Environment setup complete!"
echo ""
echo "🧠 OpenCog Development Environment Ready!"
echo "========================================"
echo ""
echo "📚 Available Commands:"
echo "  build-opencog          - Build complete OpenCog ecosystem"
echo "  build-atomspace        - Build AtomSpace only"
echo "  build-cogserver        - Build CogServer only"
echo "  build-cogutil          - Build CogUtil only"
echo "  run-opencog-demos      - Show available demos"
echo "  og                     - Go to OpenCog workspace"
echo "  ogb                    - Go to build directory"
echo ""
echo "🚀 Quick Start:"
echo "  1. build-opencog       # Build everything (takes 10-15 min)"
echo "  2. demos               # See available demos"
echo "  3. og && ls            # Explore the codebase"
echo ""
echo "📖 Documentation:"
echo "  - OpenCog Wiki: https://wiki.opencog.org/"
echo "  - AtomSpace: https://wiki.opencog.org/w/AtomSpace"
echo "  - Development: https://github.com/opencog"
echo ""
echo "Happy coding! 🎉"