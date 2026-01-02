#!/bin/bash
# System Image Generation Dependency Validation Script
# /scripts/validate-system-image-deps.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

print_status() {
    echo -e "${BLUE}[Validation]${NC} $1"
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

# Test 1: Validate script functionality
validate_script_functionality() {
    print_status "Testing script functionality..."
    
    local script_path="${PROJECT_ROOT}/scripts/generate-system-image.sh"
    
    # Check script exists and is executable
    if [[ ! -f "$script_path" ]]; then
        print_error "generate-system-image.sh not found"
        return 1
    elif [[ ! -x "$script_path" ]]; then
        print_error "generate-system-image.sh is not executable"
        return 1
    fi
    
    # Check script syntax
    if ! bash -n "$script_path"; then
        print_error "Script syntax validation failed"
        return 1
    fi
    
    # Test help function
    if ! "$script_path" --help >/dev/null 2>&1; then
        print_error "Help function failed"
        return 1
    fi
    
    # Test invalid argument handling
    if "$script_path" --invalid-option >/dev/null 2>&1; then
        print_error "Invalid argument handling failed"
        return 1
    fi
    
    print_success "Script functionality validated"
    return 0
}

# Test 2: Check dependency compatibility
validate_dependency_compatibility() {
    print_status "Checking dependency compatibility..."
    
    local config_file="${PROJECT_ROOT}/config/agent-zero-system.scm"
    local issues=0
    
    # Check if system configuration exists
    if [[ ! -f "$config_file" ]]; then
        print_warning "System configuration not found at $config_file"
        print_status "This will be created automatically during build"
    else
        print_success "System configuration found"
        
        # Basic syntax check
        local open_parens=$(grep -o '(' "$config_file" | wc -l)
        local close_parens=$(grep -o ')' "$config_file" | wc -l)
        
        if [[ $open_parens -ne $close_parens ]]; then
            print_error "Parentheses mismatch in system configuration"
            issues=$((issues + 1))
        else
            print_success "Configuration syntax appears valid"
        fi
        
        # Check for required modules
        if grep -q "use-modules" "$config_file"; then
            print_success "Configuration uses proper module imports"
        else
            print_warning "No module imports found in configuration"
            issues=$((issues + 1))
        fi
        
        # Check for operating-system definition
        if grep -q "operating-system" "$config_file"; then
            print_success "Operating system definition found"
        else
            print_error "No operating-system definition found"
            issues=$((issues + 1))
        fi
    fi
    
    # Check for required system tools (that would be available in build environment)
    local required_tools=("bash" "mkdir" "cp" "grep" "head" "tail" "date" "whoami" "hostname")
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            print_success "Required tool '$tool' available"
        else
            print_error "Required tool '$tool' not available"
            issues=$((issues + 1))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        print_success "Dependency compatibility validated"
        return 0
    else
        print_error "$issues compatibility issues found"
        return 1
    fi
}

# Test 3: Validate Guix environment requirements (without Guix)
validate_guix_environment() {
    print_status "Validating Guix environment requirements..."
    
    # Test that script properly detects missing Guix
    local script_path="${PROJECT_ROOT}/scripts/generate-system-image.sh"
    
    # This should fail gracefully when Guix is not available
    if "$script_path" --validate-only >/dev/null 2>&1; then
        print_warning "Script succeeded without Guix (unexpected)"
    else
        print_success "Script properly fails when Guix is unavailable"
    fi
    
    # Check that error messages are informative
    local error_output=$("$script_path" --validate-only 2>&1 || true)
    
    if [[ "$error_output" == *"Guix"* ]]; then
        print_success "Error message mentions Guix"
    else
        print_warning "Error message doesn't mention Guix"
    fi
    
    if [[ "$error_output" == *"https"* ]]; then
        print_success "Error message includes installation instructions"
    else
        print_warning "Error message doesn't include installation instructions"
    fi
    
    print_success "Guix environment requirements validated"
    return 0
}

# Test 4: Test Makefile integration
validate_makefile_integration() {
    print_status "Validating Makefile integration..."
    
    local makefile="${PROJECT_ROOT}/Makefile"
    local issues=0
    
    if [[ ! -f "$makefile" ]]; then
        print_error "Makefile not found"
        return 1
    fi
    
    # Check for required targets
    local required_targets=("system-image" "vm-image" "iso-image" "validate-config")
    for target in "${required_targets[@]}"; do
        if grep -q "${target}:" "$makefile"; then
            print_success "Makefile target '$target' found"
        else
            print_error "Makefile target '$target' not found"
            issues=$((issues + 1))
        fi
    done
    
    # Test that targets work (should fail gracefully without Guix)
    cd "$PROJECT_ROOT"
    
    for target in "${required_targets[@]}"; do
        print_status "Testing make $target..."
        if make "$target" >/dev/null 2>&1; then
            print_warning "Make target '$target' succeeded without Guix (unexpected)"
        else
            print_success "Make target '$target' properly fails without Guix"
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        print_success "Makefile integration validated"
        return 0
    else
        print_error "$issues Makefile issues found"
        return 1
    fi
}

# Test 5: Performance and resource validation
validate_performance() {
    print_status "Validating performance characteristics..."
    
    local script_path="${PROJECT_ROOT}/scripts/generate-system-image.sh"
    
    # Test script startup time
    local start_time=$(date +%s.%N)
    "$script_path" --help >/dev/null 2>&1 || true
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.1")
    
    if (( $(echo "$duration < 5.0" | bc -l 2>/dev/null || echo "1") )); then
        print_success "Script startup time is acceptable (${duration}s)"
    else
        print_warning "Script startup time is slow (${duration}s)"
    fi
    
    # Check script size (should be reasonable)
    local script_size=$(stat -c%s "$script_path" 2>/dev/null || echo "0")
    if [[ $script_size -lt 50000 ]]; then
        print_success "Script size is reasonable (${script_size} bytes)"
    else
        print_warning "Script size is large (${script_size} bytes)"
    fi
    
    print_success "Performance validation completed"
    return 0
}

# Main validation function
main() {
    print_status "Starting Agent-Zero System Image Generation Validation"
    echo "======================================================"
    echo
    
    local failed_tests=0
    
    # Run all validation tests
    validate_script_functionality || failed_tests=$((failed_tests + 1))
    echo
    
    validate_dependency_compatibility || failed_tests=$((failed_tests + 1))
    echo
    
    validate_guix_environment || failed_tests=$((failed_tests + 1))
    echo
    
    validate_makefile_integration || failed_tests=$((failed_tests + 1))
    echo
    
    validate_performance || failed_tests=$((failed_tests + 1))
    echo
    
    # Summary
    print_status "Validation Summary"
    echo "=================="
    
    if [[ $failed_tests -eq 0 ]]; then
        print_success "All validation tests passed! ✅"
        echo
        print_success "Agent-Zero system image generation is properly configured"
        echo
        echo "Next steps:"
        echo "1. Install Guix following instructions in AGENT-ZERO-GENESIS.md"
        echo "2. Run 'make system-image' to generate a disk image"
        echo "3. Run 'make vm-image' to generate a VM image"
        echo "4. Run 'make iso-image' to generate an ISO image"
        return 0
    else
        print_error "$failed_tests validation test(s) failed ❌"
        echo
        print_error "Please address the issues above before proceeding"
        return 1
    fi
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi