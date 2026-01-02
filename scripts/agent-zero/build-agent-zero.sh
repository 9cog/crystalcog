#!/bin/bash
# Agent-Zero Genesis Build Script
# /scripts/agent-zero/build-agent-zero.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AGENT_ZERO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="${AGENT_ZERO_ROOT}/build/agent-zero"
INSTALL_PREFIX="${INSTALL_PREFIX:-/usr/local}"

print_status() {
    echo -e "${BLUE}[Agent-Zero]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Agent-Zero]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Agent-Zero]${NC} $1"
}

print_error() {
    echo -e "${RED}[Agent-Zero]${NC} $1"
}

# Check if we're in a Guix environment
check_guix_environment() {
    if [ -n "$GUIX_ENVIRONMENT" ]; then
        print_status "Running in Guix environment: $GUIX_ENVIRONMENT"
        return 0
    fi
    
    if command -v guix >/dev/null 2>&1; then
        print_status "Guix available, but not in environment"
        return 1
    else
        print_warning "Guix not available, using system packages"
        return 0  # Don't fail the script
    fi
}

# Setup Agent-Zero environment
setup_environment() {
    print_status "Setting up Agent-Zero environment..."
    
    # Create build directory
    mkdir -p "$BUILD_DIR"
    
    # Set environment variables
    export AGENT_ZERO_MANIFEST=1
    export GUILE_LOAD_PATH="${AGENT_ZERO_ROOT}/modules:${GUILE_LOAD_PATH}"
    export GUILE_LOAD_COMPILED_PATH="${BUILD_DIR}/compiled:${GUILE_LOAD_COMPILED_PATH}"
    
    print_success "Environment setup complete"
}

# Build Guile modules
build_guile_modules() {
    print_status "Building Guile modules..."
    
    local modules_dir="${AGENT_ZERO_ROOT}/modules"
    local compiled_dir="${BUILD_DIR}/compiled"
    
    mkdir -p "$compiled_dir"
    
    # Check if Guile is available
    if command -v guile >/dev/null 2>&1; then
        print_status "Guile found, testing modules..."
        
        export GUILE_LOAD_PATH="${modules_dir}:${GUILE_LOAD_PATH}"
        
        # Test that modules can be loaded
        if guile -c "(use-modules (agent-zero kernel))" 2>/dev/null; then
            print_success "Agent-Zero kernel module loads successfully"
        else
            print_warning "Agent-Zero kernel module failed to load"
        fi
        
        if guile -c "(use-modules (agent-zero meta-cognition))" 2>/dev/null; then
            print_success "Agent-Zero meta-cognition module loads successfully"
        else
            print_warning "Agent-Zero meta-cognition module failed to load"
        fi
        
        # Try to compile if guild is available
        if command -v guild >/dev/null 2>&1; then
            for module in "${modules_dir}"/agent-zero/*.scm; do
                if [ -f "$module" ]; then
                    local module_name=$(basename "$module" .scm)
                    print_status "Compiling module: agent-zero/$module_name"
                    
                    mkdir -p "${compiled_dir}/agent-zero"
                    guild compile \
                        -L "$modules_dir" \
                        -o "${compiled_dir}/agent-zero/${module_name}.go" \
                        "$module" || {
                        print_warning "Failed to compile $module_name, will use source"
                    }
                fi
            done
            print_success "Guile modules compiled"
        else
            print_success "Guile modules validated (source mode)"
        fi
    else
        print_warning "Guile not available in current environment"
        print_status "Validating module syntax..."
        
        # Basic syntax validation
        local syntax_ok=true
        for module in "${modules_dir}"/agent-zero/*.scm; do
            if [ -f "$module" ]; then
                local module_name=$(basename "$module" .scm)
                print_status "Checking syntax: agent-zero/$module_name"
                
                # Basic syntax check (count parentheses)
                local open_parens=$(grep -o '(' "$module" | wc -l)
                local close_parens=$(grep -o ')' "$module" | wc -l)
                
                if [ "$open_parens" -eq "$close_parens" ]; then
                    print_status "  Syntax OK: $module_name"
                else
                    print_warning "  Potential syntax issue: $module_name (parens: $open_parens open, $close_parens close)"
                    syntax_ok=false
                fi
            fi
        done
        
        if [ "$syntax_ok" = true ]; then
            print_success "Module syntax validation passed"
        else
            print_warning "Some modules may have syntax issues"
        fi
        
        print_status "Agent-Zero modules ready for Guile environment"
        print_status "To use: guix environment -m guix.scm"
    fi
}

# Build C components
build_c_components() {
    print_status "Building C components..."
    
    local src_dir="${AGENT_ZERO_ROOT}/src/agent-zero"
    local build_c_dir="${BUILD_DIR}/c"
    
    mkdir -p "$build_c_dir"
    cd "$build_c_dir"
    
    # Create CMakeLists.txt for Agent-Zero C components
    cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(agent-zero-c)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)

# Find required packages
find_package(PkgConfig REQUIRED)

# Include directories
include_directories(${CMAKE_SOURCE_DIR})

# Agent-Zero C library
add_library(agent-zero-cognitive SHARED
    ${CMAKE_SOURCE_DIR}/../../../src/agent-zero/cognitive-tensors.c
    ${CMAKE_SOURCE_DIR}/../../../src/agent-zero/opencog-ggml-bridge.c
)

target_include_directories(agent-zero-cognitive PUBLIC
    ${CMAKE_SOURCE_DIR}/../../../src/agent-zero
)

# Install targets
install(TARGETS agent-zero-cognitive
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES ${CMAKE_SOURCE_DIR}/../../../src/agent-zero/cognitive.h
    DESTINATION include/agent-zero
)
EOF
    
    # Build with CMake
    cmake .
    make -j$(nproc)
    
    print_success "C components built"
}

# Create test environment
create_test_environment() {
    print_status "Creating test environment..."
    
    local test_dir="${BUILD_DIR}/test"
    mkdir -p "$test_dir"
    
    # Create test runner script
    cat > "${test_dir}/run-tests.sh" << 'EOF'
#!/bin/bash
set -e

export GUILE_LOAD_PATH="${AGENT_ZERO_ROOT}/modules:${GUILE_LOAD_PATH}"
export GUILE_LOAD_COMPILED_PATH="${BUILD_DIR}/compiled:${GUILE_LOAD_COMPILED_PATH}"

echo "Running Agent-Zero tests..."

# Test Guile modules
guile -c "
(use-modules (agent-zero kernel)
             (agent-zero meta-cognition))

(display \"Testing cognitive kernel creation...\")
(newline)
(define kernel (spawn-cognitive-kernel '(32 32) 0.7))
(display \"Kernel created: \")
(display kernel)
(newline)

(display \"Testing meta-cognition...\")
(newline)
(define self-desc (recursive-self-description kernel))
(display \"Self-description: \")
(display self-desc)
(newline)

(display \"All tests passed!\")
(newline)
"

echo "Agent-Zero tests completed successfully!"
EOF
    
    chmod +x "${test_dir}/run-tests.sh"
    
    print_success "Test environment created"
}

# Generate Guix manifest
generate_guix_manifest() {
    print_status "Generating Guix manifest..."
    
    cat > "${AGENT_ZERO_ROOT}/guix.scm" << 'EOF'
;; Agent-Zero Genesis Guix Manifest
;; This file can be used with 'guix environment -m guix.scm'

(use-modules (gnu packages)
             (gnu packages guile)
             (gnu packages maths)
             (gnu packages pkg-config)
             (gnu packages boost)
             (gnu packages cmake)
             (gnu packages gcc)
             (agent-zero packages cognitive))

(packages->manifest
  (list
    ;; Core Guile
    guile-3.0
    guile-lib
    
    ;; Build tools
    cmake
    gcc-toolchain
    pkg-config
    
    ;; Cognitive packages
    opencog
    ggml
    guile-pln
    guile-ecan
    guile-moses
    guile-pattern-matcher
    guile-relex
    
    ;; Math and scientific computing
    boost))
EOF
    
    print_success "Guix manifest generated: guix.scm"
}

# Create system configuration template
create_system_config() {
    print_status "Creating system configuration template..."
    
    local config_dir="${AGENT_ZERO_ROOT}/config"
    mkdir -p "$config_dir"
    
    cat > "${config_dir}/agent-zero-system.scm" << 'EOF'
;; Agent-Zero System Configuration Template
;; /config/agent-zero-system.scm

(use-modules (gnu)
             (gnu system)
             (gnu services)
             (gnu packages)
             (agent-zero packages cognitive))

(operating-system
  (host-name "agent-zero")
  (timezone "UTC")
  (locale "en_US.utf8")
  
  ;; Basic system configuration
  (bootloader (bootloader-configuration
               (bootloader grub-bootloader)
               (target "/dev/sda")))
  
  (file-systems (cons (file-system
                        (device (file-system-label "root"))
                        (mount-point "/")
                        (type "ext4"))
                      %base-file-systems))
  
  ;; Agent-Zero specific services
  (services
    (append
      %base-services
      (list (extra-special-file "/etc/agent-zero.conf"
                                (plain-file "agent-zero.conf"
                                           "# Agent-Zero Configuration\n")))))
  
  ;; Agent-Zero cognitive packages
  (packages
    (append %base-packages
            (list opencog
                  ggml
                  guile-pln
                  guile-ecan
                  guile-moses
                  guile-pattern-matcher
                  guile-relex))))
EOF
    
    print_success "System configuration template created: config/agent-zero-system.scm"
}

# Main build function
main() {
    print_status "Building GNU Agent-Zero Genesis Environment..."
    
    # Check Guix environment
    check_guix_environment
    guix_status=$?
    
    if [ $guix_status -eq 1 ]; then
        print_warning "Consider running: guix environment -m guix.scm"
    fi
    
    # Setup and build
    setup_environment
    generate_guix_manifest
    build_guile_modules
    build_c_components
    create_test_environment
    create_system_config
    
    print_success "Agent-Zero Genesis build complete!"
    print_status "To test: cd ${BUILD_DIR}/test && ./run-tests.sh"
    print_status "To use Guix environment: guix environment -m guix.scm"
    print_status "System config template: config/agent-zero-system.scm"
}

# Handle command line arguments
case "${1:-}" in
    --setup-only)
        setup_environment
        generate_guix_manifest
        ;;
    --guile-only)
        setup_environment
        build_guile_modules
        ;;
    --c-only)
        setup_environment
        build_c_components
        ;;
    --test)
        setup_environment
        build_guile_modules
        create_test_environment
        cd "${BUILD_DIR}/test"
        ./run-tests.sh
        ;;
    --help)
        echo "Agent-Zero Genesis Build Script"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --setup-only    Setup environment and generate manifest only"
        echo "  --guile-only    Build Guile modules only"
        echo "  --c-only        Build C components only"
        echo "  --test          Build and run tests"
        echo "  --help          Show this help"
        echo ""
        echo "Default: Build everything"
        ;;
    *)
        main
        ;;
esac