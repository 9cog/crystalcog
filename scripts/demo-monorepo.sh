#!/bin/bash

# OpenCog Central Monorepo Demo Script
# This script demonstrates the various ways to build and use the monorepo

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to show demo menu
show_menu() {
    cat << EOF
OpenCog Central Monorepo Demo

Available demos:
1.  Quick build (core components only)
2.  Full build with tests
3.  Development build (debug mode)
4.  Docker build
5.  Component-specific build
6.  Test specific component
7.  Generate documentation
8.  Create package
9.  Show build status
10. List all components
11. Setup development environment
12. Run integration tests
13. Clean and rebuild
14. Exit

Enter your choice (1-14): 
EOF
}

# Function to run quick build
demo_quick_build() {
    print_status "Demo 1: Quick build (core components only)"
    print_status "This will build only the core components: cogutil, atomspace, attention, ure, pln, link-grammar, cogserver"
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Running: make core"
        make core
        print_success "Quick build complete!"
    fi
}

# Function to run full build
demo_full_build() {
    print_status "Demo 2: Full build with tests"
    print_status "This will build all components and run tests"
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Running: make full"
        make full
        print_success "Full build complete!"
    fi
}

# Function to run development build
demo_dev_build() {
    print_status "Demo 3: Development build (debug mode)"
    print_status "This will build in debug mode with tests"
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Running: make dev"
        make dev
        print_success "Development build complete!"
    fi
}

# Function to run Docker build
demo_docker_build() {
    print_status "Demo 4: Docker build"
    print_status "This will build using Docker containers"
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Building Docker image..."
        docker build -f Dockerfile.monorepo -t opencog-monorepo .
        
        print_status "Running build in container..."
        docker run --rm -v $(pwd):/workspace opencog-monorepo
        
        print_success "Docker build complete!"
    fi
}

# Function to run component-specific build
demo_component_build() {
    print_status "Demo 5: Component-specific build"
    print_status "Available core components: cogutil, atomspace, attention, ure, pln, link-grammar, cogserver"
    
    read -p "Enter component name: " component
    if [[ -n "$component" ]]; then
        print_status "Running: make build-$component"
        make build-$component
        print_success "Component build complete!"
    fi
}

# Function to run component-specific test
demo_component_test() {
    print_status "Demo 6: Test specific component"
    print_status "Available core components: cogutil, atomspace, attention, ure, pln, link-grammar, cogserver"
    
    read -p "Enter component name: " component
    if [[ -n "$component" ]]; then
        print_status "Running: make test-$component"
        make test-$component
        print_success "Component test complete!"
    fi
}

# Function to generate documentation
demo_docs() {
    print_status "Demo 7: Generate documentation"
    print_status "This will build all components and generate documentation"
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Running: make doc"
        make doc
        print_success "Documentation generated!"
        print_status "Documentation is available in build/doc/"
    fi
}

# Function to create package
demo_package() {
    print_status "Demo 8: Create package"
    print_status "This will create a Debian package"
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Running: make package"
        make package
        print_success "Package created!"
        print_status "Package is available in build/"
    fi
}

# Function to show build status
demo_status() {
    print_status "Demo 9: Show build status"
    make status
}

# Function to list components
demo_components() {
    print_status "Demo 10: List all components"
    make components
}

# Function to setup development environment
demo_dev_env() {
    print_status "Demo 11: Setup development environment"
    print_status "This will create a .env file with development environment variables"
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Running: make dev-env"
        make dev-env
        print_success "Development environment setup complete!"
        print_status "To activate the environment, run: source .env"
    fi
}

# Function to run integration tests
demo_integration_tests() {
    print_status "Demo 12: Run integration tests"
    print_status "This will run all tests including integration tests"
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Running: make test"
        make test
        print_success "Integration tests complete!"
    fi
}

# Function to clean and rebuild
demo_clean_rebuild() {
    print_status "Demo 13: Clean and rebuild"
    print_status "This will clean the build directory and rebuild everything"
    
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Running: make rebuild"
        make rebuild
        print_success "Clean rebuild complete!"
    fi
}

# Main demo loop
main() {
    print_status "Welcome to the OpenCog Central Monorepo Demo!"
    print_status "This script demonstrates the various build options available."
    
    while true; do
        echo
        show_menu
        read -r choice
        
        case $choice in
            1) demo_quick_build ;;
            2) demo_full_build ;;
            3) demo_dev_build ;;
            4) demo_docker_build ;;
            5) demo_component_build ;;
            6) demo_component_test ;;
            7) demo_docs ;;
            8) demo_package ;;
            9) demo_status ;;
            10) demo_components ;;
            11) demo_dev_env ;;
            12) demo_integration_tests ;;
            13) demo_clean_rebuild ;;
            14) 
                print_success "Demo complete! Thank you for trying the OpenCog Central Monorepo."
                exit 0
                ;;
            *) 
                print_error "Invalid choice. Please enter a number between 1 and 14."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Check if we're in the right directory
if [[ ! -f "CMakeLists.txt" ]] || [[ ! -f "Makefile" ]]; then
    print_error "This script must be run from the root of the OpenCog Central monorepo."
    print_error "Please navigate to the repository root and try again."
    exit 1
fi

# Run main function
main "$@"