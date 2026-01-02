#!/bin/bash

# OpenCog Central Monorepo Build Script
# This script builds the entire OpenCog ecosystem in the correct dependency order

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUILD_TYPE=${BUILD_TYPE:-Release}
JOBS=${JOBS:-$(nproc)}
INSTALL_PREFIX=${INSTALL_PREFIX:-/usr/local}
BUILD_DIR=${BUILD_DIR:-build}
SKIP_TESTS=${SKIP_TESTS:-false}
SKIP_INSTALL=${SKIP_INSTALL:-false}
CLEAN_BUILD=${CLEAN_BUILD:-false}

# Function to print colored output
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install system dependencies
install_system_deps() {
    print_status "Installing system dependencies..."
    
    if command_exists apt-get; then
        # Ubuntu/Debian
        sudo apt-get update
        sudo apt-get install -y \
            build-essential \
            cmake \
            pkg-config \
            ccache \
            git \
            wget \
            curl \
            libboost-all-dev \
            libboost-filesystem-dev \
            libboost-program-options-dev \
            libboost-system-dev \
            libboost-thread-dev \
            python3-dev \
            python3-pip \
            python3-venv \
            guile-3.0-dev \
            cython3 \
            valgrind \
            doxygen \
            libpqxx-dev \
            postgresql-client \
            ghc \
            libghc-*-dev \
            stack \
            nodejs \
            npm \
            rustc \
            cargo
    elif command_exists yum; then
        # CentOS/RHEL
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y \
            cmake \
            pkg-config \
            ccache \
            git \
            wget \
            curl \
            boost-devel \
            python3-devel \
            python3-pip \
            guile-devel \
            valgrind \
            doxygen \
            postgresql-devel \
            nodejs \
            npm
    elif command_exists brew; then
        # macOS
        brew install \
            cmake \
            pkg-config \
            ccache \
            boost \
            python3 \
            guile \
            valgrind \
            doxygen \
            postgresql \
            node \
            rust
    else
        print_error "Unsupported package manager. Please install dependencies manually."
        exit 1
    fi
    
    print_success "System dependencies installed"
}

# Function to setup Python environment
setup_python_env() {
    print_status "Setting up Python environment..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install Python dependencies
    pip install --upgrade pip
    pip install -r requirements.txt
    
    print_success "Python environment setup complete"
}

# Function to setup Node.js environment
setup_node_env() {
    print_status "Setting up Node.js environment..."
    
    # Install Node.js dependencies
    if [ -f "package.json" ]; then
        npm install
    fi
    
    print_success "Node.js environment setup complete"
}

# Function to setup Rust environment
setup_rust_env() {
    print_status "Setting up Rust environment..."
    
    # Install Rust if not already installed
    if ! command_exists rustc; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    fi
    
    # Install Rust dependencies
    if [ -f "Cargo.toml" ]; then
        cargo build --release
    fi
    
    print_success "Rust environment setup complete"
}

# Function to clean build directory
clean_build() {
    if [ "$CLEAN_BUILD" = "true" ]; then
        print_status "Cleaning build directory..."
        rm -rf "$BUILD_DIR"
        print_success "Build directory cleaned"
    fi
}

# Function to configure CMake
configure_cmake() {
    print_status "Configuring CMake..."
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    cmake .. \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
    
    cd ..
    
    print_success "CMake configuration complete"
}

# Function to build components
build_components() {
    print_status "Building all components..."
    
    cd "$BUILD_DIR"
    
    # Build with specified number of jobs
    make -j"$JOBS"
    
    cd ..
    
    print_success "Build complete"
}

# Function to run tests
run_tests() {
    if [ "$SKIP_TESTS" = "true" ]; then
        print_warning "Skipping tests as requested"
        return
    fi
    
    print_status "Running tests..."
    
    cd "$BUILD_DIR"
    
    # Run tests with output on failure
    ctest --output-on-failure -j"$JOBS"
    
    cd ..
    
    print_success "Tests complete"
}

# Function to install components
install_components() {
    if [ "$SKIP_INSTALL" = "true" ]; then
        print_warning "Skipping installation as requested"
        return
    fi
    
    print_status "Installing components..."
    
    cd "$BUILD_DIR"
    
    # Install all components
    make install
    
    cd ..
    
    print_success "Installation complete"
}

# Function to create development environment
setup_dev_env() {
    print_status "Setting up development environment..."
    
    # Create .env file for development
    cat > .env << EOF
# OpenCog Central Development Environment
export OPENCOG_ROOT=\$(pwd)
export OPENCOG_BUILD_DIR=\$(pwd)/$BUILD_DIR
export OPENCOG_INSTALL_PREFIX=$INSTALL_PREFIX
export PYTHONPATH=\$PYTHONPATH:\$(pwd)/$BUILD_DIR/lib/python3.*/site-packages
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$(pwd)/$BUILD_DIR/lib
export PATH=\$PATH:\$(pwd)/$BUILD_DIR/bin
EOF
    
    print_success "Development environment setup complete"
    print_status "To activate the development environment, run: source .env"
}

# Function to show help
show_help() {
    cat << EOF
OpenCog Central Monorepo Build Script

Usage: $0 [OPTIONS]

Options:
    -h, --help              Show this help message
    -b, --build-type TYPE   Set build type (Debug, Release, RelWithDebInfo) [default: Release]
    -j, --jobs N            Number of parallel jobs [default: \$(nproc)]
    -p, --prefix PATH       Installation prefix [default: /usr/local]
    -d, --build-dir DIR     Build directory [default: build]
    -t, --skip-tests        Skip running tests
    -i, --skip-install      Skip installation
    -c, --clean             Clean build directory before building
    -s, --setup-only        Only setup dependencies, don't build
    -e, --dev-env           Setup development environment

Environment Variables:
    BUILD_TYPE              Build type (Debug, Release, RelWithDebInfo)
    JOBS                    Number of parallel jobs
    INSTALL_PREFIX          Installation prefix
    BUILD_DIR               Build directory
    SKIP_TESTS              Skip tests (true/false)
    SKIP_INSTALL            Skip installation (true/false)
    CLEAN_BUILD             Clean build directory (true/false)

Examples:
    $0                      # Build with default settings
    $0 -b Debug -j 4       # Debug build with 4 jobs
    $0 -c -t               # Clean build, skip tests
    $0 -s                  # Setup dependencies only
    $0 -e                  # Setup development environment
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--build-type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -p|--prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        -d|--build-dir)
            BUILD_DIR="$2"
            shift 2
            ;;
        -t|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        -i|--skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -s|--setup-only)
            SETUP_ONLY=true
            shift
            ;;
        -e|--dev-env)
            setup_dev_env
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_status "Starting OpenCog Central monorepo build..."
    print_status "Build type: $BUILD_TYPE"
    print_status "Jobs: $JOBS"
    print_status "Install prefix: $INSTALL_PREFIX"
    print_status "Build directory: $BUILD_DIR"
    
    # Install system dependencies
    install_system_deps
    
    # Setup language-specific environments
    setup_python_env
    setup_node_env
    setup_rust_env
    
    # Exit early if only setup is requested
    if [ "${SETUP_ONLY:-false}" = "true" ]; then
        print_success "Setup complete"
        exit 0
    fi
    
    # Clean build directory if requested
    clean_build
    
    # Configure and build
    configure_cmake
    build_components
    run_tests
    install_components
    
    print_success "OpenCog Central monorepo build complete!"
    print_status "To use the installed components, you may need to run: sudo ldconfig"
}

# Run main function
main "$@"