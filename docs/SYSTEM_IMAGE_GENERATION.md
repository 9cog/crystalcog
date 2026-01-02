# Agent-Zero System Image Generation

This document provides information about the system image generation functionality for Agent-Zero Genesis.

## Overview

The Agent-Zero system image generation creates complete bootable images containing:

- GNU/Linux system with Agent-Zero Genesis environment
- Pre-configured cognitive kernel framework
- Hypergraph-based OS services
- Meta-cognitive processing capabilities
- SSH access and development tools
- Automatic Agent-Zero daemon startup

## Prerequisites

### Required

- **Guix Package Manager**: The system image generation requires GNU Guix
  - Installation guide: https://guix.gnu.org/manual/en/html_node/Installation.html
  - Minimum version: Guix 1.4+

### System Resources

- **Disk Space**: At least 10GB free space for image generation
- **Memory**: 4GB+ RAM recommended during build
- **Time**: 30+ minutes for complete system image generation

## Image Types

### Disk Image (`disk-image`)
- Raw disk image suitable for writing to USB drives or hard disks
- Default format for deployment
- File extension: `.img`

### VM Image (`vm-image`)
- Optimized for virtual machine deployment
- Includes VM-specific optimizations
- File extension: `-vm.img`

### ISO Image (`iso`)
- Bootable ISO image for CD/DVD or virtual CD
- Useful for installation or live systems
- File extension: `.iso`

## Usage

### Command Line

```bash
# Generate default disk image
./scripts/generate-system-image.sh

# Generate VM image
./scripts/generate-system-image.sh --type vm-image

# Generate ISO image  
./scripts/generate-system-image.sh --type iso

# Custom output directory
./scripts/generate-system-image.sh --output /path/to/output

# Validate configuration only (no build)
./scripts/generate-system-image.sh --validate-only
```

### Makefile Targets

```bash
# Generate system disk image
make system-image

# Generate VM image
make vm-image

# Generate ISO image
make iso-image

# Validate system configuration
make validate-config
```

## Configuration

### System Configuration File

Location: `config/agent-zero-system.scm`

The system configuration is written in Guile Scheme and defines:
- Base system packages
- User accounts and permissions
- Network and SSH configuration
- Agent-Zero specific services
- Cognitive kernel settings

### Customization

Create a custom configuration file:

```scheme
;; custom-config.scm
(use-modules (gnu)
             (gnu system)
             (gnu services))

(operating-system
  (host-name "my-agent-zero")
  (timezone "America/New_York")
  ; ... additional customizations
)
```

Use with:
```bash
./scripts/generate-system-image.sh --config custom-config.scm
```

## Output

Generated images are placed in `build/system-images/` with:
- **Image file**: `agent-zero-system-YYYYMMDD-HHMMSS.img`
- **Info file**: `agent-zero-system-YYYYMMDD-HHMMSS.img.info`

The info file contains:
- Image metadata (size, type, checksums)
- Usage instructions
- Build information
- Verification data

## Deployment

### USB Drive
```bash
# Write to USB drive (replace /dev/sdX with actual device)
sudo dd if=agent-zero-system-20231027-143022.img of=/dev/sdX bs=4M status=progress
```

### Virtual Machine
```bash
# QEMU/KVM
qemu-system-x86_64 -hda agent-zero-system-20231027-143022.img -m 2G -enable-kvm

# VirtualBox
# Create new VM and use the .img file as hard disk
```

### ISO Boot
```bash
# Burn ISO to CD/DVD or mount in VM
# Boot from CD/DVD drive
```

## Default System Configuration

### User Account
- **Username**: `agent`
- **Groups**: `users`, `wheel`, `netdev`, `audio`, `video`
- **Home**: `/home/agent`
- **Shell**: Bash

### Services
- **SSH**: Port 22, password authentication enabled
- **NetworkManager**: Network configuration
- **Agent-Zero Daemon**: Automatic startup
- **CogServer**: Port 17001
- **REST API**: Port 8080

### Directory Structure
- **Agent-Zero**: `/opt/agent-zero/`
- **Configuration**: `/etc/agent-zero.conf`
- **Data**: `/var/lib/agent-zero/`
- **Logs**: `/var/log/agent-zero/`

## Troubleshooting

### Build Fails
1. Check Guix installation: `guix --version`
2. Verify Guix daemon is running: `sudo systemctl status guix-daemon`
3. Check available disk space: `df -h`
4. Review build logs in temporary directory

### Image Won't Boot
1. Verify image integrity: `sha256sum <image-file>`
2. Check write process: Use `sync` after `dd` command
3. Verify hardware compatibility
4. Check UEFI vs BIOS boot settings

### Network Issues
1. Check NetworkManager service status
2. Verify SSH configuration: `/etc/ssh/sshd_config`
3. Check firewall settings
4. Verify user permissions

## Development

### Testing
Run integration tests:
```bash
./tests/agent-zero/system-image-test.sh
```

### Custom Packages
Add packages to the system configuration:
```scheme
(packages
  (append %base-packages
          (list your-custom-package
                another-package)))
```

### Services
Add custom services:
```scheme
(services
  (append %base-services
          (list (service your-service-type
                        your-service-configuration))))
```

## Advanced Usage

### Cross-Architecture Building
```bash
# Build for different architecture (if supported)
./scripts/generate-system-image.sh --type disk-image --target aarch64-linux
```

### Custom Kernel
Modify system configuration to use specific kernel version:
```scheme
(operating-system
  (kernel linux-libre-6.1)
  ; ... rest of configuration
)
```

### Minimal Images
Create stripped-down images by removing unnecessary packages and services.

## Security Considerations

### Default Passwords
- No default root password set
- User 'agent' can use sudo
- SSH password authentication enabled (consider key-based auth)

### Network Services
- SSH enabled by default
- Agent-Zero services exposed on localhost
- Consider firewall configuration for production use

### Updates
- System includes Guix for package management
- Regular security updates recommended
- Agent-Zero components updatable via Git

## Support

For issues with system image generation:
1. Check the troubleshooting section
2. Review build logs
3. Consult Guix documentation
4. File issues in the project repository

## See Also

- [AGENT-ZERO-GENESIS.md](AGENT-ZERO-GENESIS.md) - Main documentation
- [Guix Manual](https://guix.gnu.org/manual/) - Guix system configuration
- [GNU System Configuration](https://guix.gnu.org/manual/en/html_node/System-Configuration.html) - Advanced configuration