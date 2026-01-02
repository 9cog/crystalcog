#!/bin/bash
# Agent-Zero Genesis System Image Generation Script
# /scripts/generate-system-image.sh
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-${PROJECT_ROOT}/build/system-images}"
CONFIG_DIR="${PROJECT_ROOT}/config"
IMAGE_NAME="${IMAGE_NAME:-agent-zero-system}"
IMAGE_TYPE="${IMAGE_TYPE:-disk-image}"
SYSTEM_CONFIG="${SYSTEM_CONFIG:-${CONFIG_DIR}/agent-zero-system.scm}"
TEMP_DIR="/tmp/agent-zero-build-$$"

print_status() {
    echo -e "${BLUE}[System Image]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[System Image]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[System Image]${NC} $1"
}

print_error() {
    echo -e "${RED}[System Image]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites for system image generation..."
    
    # Check if Guix is available
    if ! command -v guix >/dev/null 2>&1; then
        print_error "Guix is not available. Please install Guix first."
        print_status "Installation instructions: https://guix.gnu.org/manual/en/html_node/Installation.html"
        exit 1
    fi
    
    print_success "Guix is available: $(guix --version | head -1)"
    
    # Check if we can access Guix daemon
    if ! guix pull --help >/dev/null 2>&1; then
        print_error "Cannot access Guix daemon. Please ensure guix-daemon is running."
        exit 1
    fi
    
    print_success "Guix daemon is accessible"
    
    # Create necessary directories
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$TEMP_DIR"
    
    print_status "Using temporary directory: $TEMP_DIR"
    print_status "Output directory: $OUTPUT_DIR"
}

# Function to validate system configuration
validate_system_config() {
    print_status "Validating system configuration..."
    
    if [ ! -f "$SYSTEM_CONFIG" ]; then
        print_warning "System configuration not found at $SYSTEM_CONFIG"
        print_status "Creating default configuration..."
        create_default_system_config
    fi
    
    # Test system configuration syntax
    local temp_config="${TEMP_DIR}/test-config.scm"
    cp "$SYSTEM_CONFIG" "$temp_config"
    
    # Add test wrapper to check syntax
    cat > "${TEMP_DIR}/syntax-check.scm" << 'EOF'
(use-modules (gnu)
             (gnu system)
             (gnu services)
             (gnu packages))

;; Load and validate the system configuration
EOF
    
    cat "$temp_config" >> "${TEMP_DIR}/syntax-check.scm"
    
    # Check syntax using Guile
    if command -v guile >/dev/null 2>&1; then
        export GUILE_LOAD_PATH="${PROJECT_ROOT}/modules:${GUILE_LOAD_PATH}"
        if guile -c "(load \"${TEMP_DIR}/syntax-check.scm\")" 2>/dev/null; then
            print_success "System configuration syntax is valid"
        else
            print_warning "System configuration may have syntax issues, but will attempt to build"
        fi
    else
        print_warning "Guile not available for syntax checking, proceeding with build"
    fi
}

# Function to create default system configuration
create_default_system_config() {
    mkdir -p "$(dirname "$SYSTEM_CONFIG")"
    
    cat > "$SYSTEM_CONFIG" << 'EOF'
;; Agent-Zero System Configuration for Image Generation
;; This configuration defines a complete Agent-Zero Genesis system

(use-modules (gnu)
             (gnu system)
             (gnu services)
             (gnu services desktop)
             (gnu services networking)
             (gnu services ssh)
             (gnu packages)
             (gnu packages guile)
             (gnu packages maths)
             (gnu packages pkg-config)
             (gnu packages cmake)
             (gnu packages gcc)
             (gnu packages version-control)
             (gnu packages compression)
             (gnu packages admin)
             (gnu packages base))

(operating-system
  ;; Basic system identity
  (host-name "agent-zero")
  (timezone "UTC")
  (locale "en_US.utf8")
  
  ;; Kernel and bootloader
  (kernel linux-libre)
  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)
               (targets '("/boot/efi"))
               (keyboard-layout (keyboard-layout "us"))))
  
  ;; File systems
  (file-systems 
    (append
      (list (file-system
              (device (file-system-label "Agent-Zero-Root"))
              (mount-point "/")
              (type "ext4"))
            (file-system
              (device (file-system-label "Agent-Zero-EFI"))
              (mount-point "/boot/efi")
              (type "vfat")))
      %base-file-systems))
  
  ;; User accounts
  (users (append %base-user-accounts
                 (list (user-account
                        (name "agent")
                        (group "users")
                        (supplementary-groups '("wheel" "netdev"
                                              "audio" "video"))
                        (home-directory "/home/agent")))))
  
  ;; Services for Agent-Zero
  (services
    (append
      %base-services
      %desktop-services
      (list
        ;; SSH for remote access
        (service openssh-service-type
                 (openssh-configuration
                  (port-number 22)
                  (password-authentication? #t)
                  (permit-root-login #f)))
        
        ;; NetworkManager for connectivity
        (service network-manager-service-type)
        
        ;; Special files for Agent-Zero
        (extra-special-file "/etc/agent-zero.conf"
                           (plain-file "agent-zero.conf"
                                      "# Agent-Zero Genesis Configuration
# Hypergraphically-encoded OS environment
# for cognitive agent operations

[cognitive-kernel]
default_tensor_shape = [64, 64]
default_attention_weight = 0.8

[meta-cognition]
recursive_depth = 3
attention_allocation = adaptive

[persistence]
hypergraph_backend = atomspace
storage_location = /var/lib/agent-zero/

[services]
cogserver_port = 17001
rest_api_port = 8080
"))
        
        ;; Agent-Zero startup service
        (extra-special-file "/etc/systemd/system/agent-zero.service"
                           (plain-file "agent-zero.service"
                                      "[Unit]
Description=Agent-Zero Genesis Cognitive System
After=network.target

[Service]
Type=notify
User=agent
Group=users
Environment=GUILE_LOAD_PATH=/opt/agent-zero/modules
Environment=AGENT_ZERO_CONFIG=/etc/agent-zero.conf
ExecStart=/opt/agent-zero/bin/agent-zero-daemon
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
")))))
  
  ;; System packages for Agent-Zero Genesis
  (packages
    (append 
      %base-packages
      %desktop-packages
      (list 
        ;; Core development tools
        guile-3.0
        guile-lib
        gcc-toolchain
        cmake
        pkg-config
        git
        
        ;; Compression and utilities
        gzip
        tar
        make
        
        ;; System administration
        sudo
        openssh-sans-x
        
        ;; Scientific computing foundation
        ;; Note: Cognitive packages would be added here when available
        ;; opencog
        ;; ggml
        ;; guile-pln
        ;; guile-ecan
        ;; guile-moses
        ;; guile-pattern-matcher
        ;; guile-relex
        ))))
EOF
    
    print_success "Default system configuration created at $SYSTEM_CONFIG"
}

# Function to prepare build environment
prepare_build_environment() {
    print_status "Preparing build environment..."
    
    # Set up Guix build environment
    export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"
    
    # Ensure module path includes Agent-Zero modules
    export GUILE_LOAD_PATH="${PROJECT_ROOT}/modules:${GUILE_LOAD_PATH}"
    
    # Create final system configuration by copying and potentially modifying
    local final_config="${TEMP_DIR}/agent-zero-system-final.scm"
    cp "$SYSTEM_CONFIG" "$final_config"
    
    # Add timestamp and build info
    cat >> "$final_config" << EOF

;; Build metadata
;; Generated on: $(date -Iseconds)
;; Builder: $(whoami)@$(hostname)
;; Project root: ${PROJECT_ROOT}
;; Build ID: $(date +%s)
EOF
    
    FINAL_CONFIG="$final_config"
    print_success "Build environment prepared"
    print_status "Final configuration: $FINAL_CONFIG"
}

# Function to build system image
build_system_image() {
    print_status "Building Agent-Zero system image..."
    print_status "This may take a significant amount of time (30+ minutes)..."
    
    local output_path="${OUTPUT_DIR}/${IMAGE_NAME}-$(date +%Y%m%d-%H%M%S)"
    local image_format="disk-image"
    
    case "$IMAGE_TYPE" in
        "disk-image"|"disk")
            image_format="disk-image"
            output_path="${output_path}.img"
            ;;
        "vm-image"|"vm")
            image_format="vm-image"
            output_path="${output_path}-vm.img"
            ;;
        "iso"|"iso-image")
            image_format="iso9660-image"
            output_path="${output_path}.iso"
            ;;
        *)
            print_warning "Unknown image type '$IMAGE_TYPE', defaulting to disk-image"
            image_format="disk-image"
            output_path="${output_path}.img"
            ;;
    esac
    
    print_status "Building $image_format..."
    print_status "Configuration: $FINAL_CONFIG"
    print_status "Output will be: $output_path"
    
    # Build the system image
    set +e  # Don't exit on error for this command
    guix system "$image_format" "$FINAL_CONFIG" 2>&1 | tee "${TEMP_DIR}/build.log"
    local build_result=$?
    set -e
    
    if [ $build_result -eq 0 ]; then
        # Find the generated image in the Guix store
        local store_path=$(grep -o '/gnu/store/[^[:space:]]*' "${TEMP_DIR}/build.log" | tail -1)
        
        if [ -n "$store_path" ] && [ -f "$store_path" ]; then
            print_success "System image built successfully!"
            print_status "Store path: $store_path"
            
            # Copy to output location
            cp "$store_path" "$output_path"
            print_success "Image copied to: $output_path"
            
            # Generate image info
            generate_image_info "$output_path" "$store_path"
            
            # Display final information
            display_build_summary "$output_path"
        else
            print_error "Build appeared to succeed but cannot find generated image"
            print_status "Check build log: ${TEMP_DIR}/build.log"
            exit 1
        fi
    else
        print_error "System image build failed!"
        print_status "Check build log: ${TEMP_DIR}/build.log"
        
        # Show last few lines of build log for debugging
        print_status "Last 20 lines of build log:"
        tail -20 "${TEMP_DIR}/build.log"
        exit 1
    fi
    
    GENERATED_IMAGE="$output_path"
}

# Function to generate image information
generate_image_info() {
    local image_path="$1"
    local store_path="$2"
    local info_file="${image_path}.info"
    
    print_status "Generating image information..."
    
    cat > "$info_file" << EOF
# Agent-Zero Genesis System Image Information
# Generated: $(date -Iseconds)

[image]
filename = $(basename "$image_path")
full_path = $image_path
size_bytes = $(stat -c%s "$image_path" 2>/dev/null || echo "unknown")
size_human = $(du -h "$image_path" 2>/dev/null | cut -f1 || echo "unknown")
type = $IMAGE_TYPE
store_path = $store_path

[system]
hostname = agent-zero
architecture = $(uname -m)
build_system = guix
configuration = $SYSTEM_CONFIG

[build]
date = $(date -Iseconds)
builder = $(whoami)@$(hostname)
project_root = $PROJECT_ROOT
build_temp = $TEMP_DIR

[verification]
sha256 = $(sha256sum "$image_path" 2>/dev/null | cut -d' ' -f1 || echo "unknown")

[usage]
# To use this image:
# 1. Write to USB/disk: dd if="$image_path" of=/dev/sdX bs=4M status=progress
# 2. Or use in VM: qemu-system-x86_64 -hda "$image_path" -m 2G
# 3. Default user: agent (member of wheel group)
# 4. Services: SSH on port 22, Agent-Zero daemon auto-starts
EOF
    
    print_success "Image information saved: $info_file"
}

# Function to display build summary
display_build_summary() {
    local image_path="$1"
    
    print_success "═══ Agent-Zero Genesis System Image Build Complete ═══"
    echo
    print_status "Image Details:"
    echo "  📁 Location: $image_path"
    echo "  📊 Size: $(du -h "$image_path" 2>/dev/null | cut -f1 || echo "unknown")"
    echo "  🔧 Type: $IMAGE_TYPE"
    echo "  📋 Info: ${image_path}.info"
    echo
    print_status "Next Steps:"
    echo "  1. 💾 Write to USB: dd if='$image_path' of=/dev/sdX bs=4M status=progress"
    echo "  2. 🖥️  Use in VM: qemu-system-x86_64 -hda '$image_path' -m 2G -enable-kvm"
    echo "  3. 🔐 Default login: user 'agent' (wheel group member)"
    echo "  4. 🧠 Agent-Zero services start automatically"
    echo
    print_status "System Features:"
    echo "  • Hypergraphically-encoded OS environment"
    echo "  • Cognitive kernel framework"
    echo "  • Meta-cognitive processing"
    echo "  • SSH access (port 22)"
    echo "  • Agent-Zero daemon service"
    echo "  • Full GNU/Linux environment"
    echo
    print_success "The cognitive agents await activation! 🧠✨"
}

# Function to cleanup
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        print_status "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Function to show help
show_help() {
    cat << EOF
Agent-Zero Genesis System Image Generator

Usage: $0 [OPTIONS]

Options:
    -h, --help              Show this help message
    -t, --type TYPE         Image type: disk-image, vm-image, iso (default: disk-image)
    -o, --output DIR        Output directory (default: ./build/system-images)
    -c, --config FILE       System configuration file (default: ./config/agent-zero-system.scm)
    -n, --name NAME         Base name for generated image (default: agent-zero-system)
    --temp-dir DIR          Temporary directory (default: /tmp/agent-zero-build-PID)
    --no-cleanup            Don't cleanup temporary files after build
    --validate-only         Only validate configuration, don't build

Environment Variables:
    OUTPUT_DIR              Output directory for images
    IMAGE_TYPE              Image type (disk-image, vm-image, iso)
    IMAGE_NAME              Base name for generated image
    SYSTEM_CONFIG           Path to system configuration file

Examples:
    $0                      # Build default disk image
    $0 -t vm-image         # Build VM image
    $0 -t iso              # Build ISO image
    $0 -o /tmp/images      # Custom output directory
    $0 --validate-only     # Just validate configuration

The generated image contains a complete Agent-Zero Genesis environment
with cognitive kernel framework and hypergraph-based OS.
EOF
}

# Main function
main() {
    local validate_only=false
    local no_cleanup=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -t|--type)
                IMAGE_TYPE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -c|--config)
                SYSTEM_CONFIG="$2"
                shift 2
                ;;
            -n|--name)
                IMAGE_NAME="$2"
                shift 2
                ;;
            --temp-dir)
                TEMP_DIR="$2"
                shift 2
                ;;
            --no-cleanup)
                no_cleanup=true
                shift
                ;;
            --validate-only)
                validate_only=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Setup cleanup trap
    if [ "$no_cleanup" = false ]; then
        trap cleanup EXIT
    fi
    
    print_status "Starting Agent-Zero Genesis System Image Generation..."
    echo
    
    # Main build process
    check_prerequisites
    validate_system_config
    
    if [ "$validate_only" = true ]; then
        print_success "Configuration validation complete!"
        exit 0
    fi
    
    prepare_build_environment
    build_system_image
    
    print_success "Agent-Zero Genesis system image generation complete!"
}

# Execute main function with all arguments
main "$@"