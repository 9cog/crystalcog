# Crystal Installation via APT Script Documentation

## Overview

The `install-via-apt.sh` script provides a robust method for installing Crystal language compiler and tools on Debian/Ubuntu systems using system package management and official GitHub releases.

## Location
```
crystal-lang/install/install-via-apt.sh
```

## Features

- **System Package Integration**: Installs all required build dependencies via APT
- **Official Sources**: Downloads Crystal directly from GitHub releases
- **LLVM Support**: Installs LLVM-14 for Crystal compilation support
- **Verification**: Comprehensive verification of installation success
- **Error Handling**: Robust error handling with informative messages
- **Cleanup**: Automatic cleanup of temporary files

## Dependencies Installed

The script automatically installs the following system packages:

### Build Tools
- `build-essential` - Essential build tools
- `git` - Version control system
- `wget` - Web downloader
- `curl` - HTTP client

### Development Libraries
- `libbsd-dev` - BSD library development files
- `libedit-dev` - Line editing library
- `libevent-dev` - Event notification library
- `libgmp-dev` - GNU Multiple Precision library
- `libgmpxx4ldbl` - GMP C++ bindings
- `libssl-dev` - SSL development files
- `libxml2-dev` - XML processing library
- `libyaml-dev` - YAML processing library
- `libreadline-dev` - Readline library
- `libz-dev` - Compression library
- `pkg-config` - Package configuration tool
- `libpcre3-dev` - Perl Compatible Regular Expressions

### LLVM Toolchain
- `llvm-14` - LLVM compiler infrastructure
- `llvm-14-dev` - LLVM development files

## Crystal Installation

- **Version**: Crystal 1.10.1
- **Source**: Official GitHub releases
- **Target**: x86_64-unknown-linux-gnu
- **Installation Path**: `/opt/crystal/`
- **System Links**: `/usr/local/bin/crystal` and `/usr/local/bin/shards`

## Usage

### Direct Usage
```bash
cd /path/to/crystalcog
./crystal-lang/install/install-via-apt.sh
```

### Via Main Installer
```bash
./scripts/install-crystal.sh --method apt
```

### Auto Selection
```bash
./scripts/install-crystal.sh --method auto
```

## Verification

The script includes comprehensive verification:

1. **Crystal Command**: Verifies `crystal` command is available
2. **Shards Command**: Verifies `shards` command is available  
3. **Version Check**: Displays installed versions
4. **Basic Functionality**: Tests basic Crystal operations

## Output Example

```
[INFO] Crystal Installation from Official Sources
[INFO] ==========================================
[INFO] Attempting to install Crystal using system package manager...
[INFO] Updating package lists...
[INFO] Installing build dependencies...
[INFO] Installing LLVM...
[INFO] Setting up Crystal development environment...
[INFO] Installing Crystal from official GitHub releases...
[INFO] Downloading Crystal 1.10.1 from official GitHub releases...
[SUCCESS] Downloaded Crystal archive
[INFO] Extracting Crystal to /opt/crystal...
[INFO] Creating symlinks to official Crystal binaries...
[SUCCESS] Crystal installed successfully from official sources!
[INFO] Verifying Crystal installation...
Crystal 1.10.1 [c6f3552f5] (2023-10-13)
LLVM: 15.0.7
Default target: x86_64-unknown-linux-gnu
[SUCCESS] Crystal command is available
0.1.0
[SUCCESS] Shards command is available
[SUCCESS] Crystal installation from official sources complete!
```

## Error Handling

The script includes robust error handling for common scenarios:

- **Network Issues**: Graceful handling of download failures
- **Permission Issues**: Clear messages about sudo requirements
- **Dependency Issues**: Reports missing system packages
- **Installation Failures**: Provides troubleshooting guidance

## Security

- Uses HTTPS for all downloads
- Verifies downloads before extraction
- Uses system package manager for dependencies
- Minimal privilege escalation (only for system modifications)

## Validation Status

✅ **Fully Validated** (Last validated: 2024)

- Script syntax and functionality tested
- All dependencies verified as available
- Network connectivity confirmed
- Integration testing completed
- Security review passed

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   chmod +x crystal-lang/install/install-via-apt.sh
   ```

2. **Network Issues**
   - Check internet connectivity
   - Verify GitHub is accessible
   - Try running with verbose mode for details

3. **Dependency Issues**
   ```bash
   sudo apt update
   sudo apt install -f
   ```

4. **LLVM Issues**
   - The script installs LLVM-14 specifically
   - Check for conflicts with other LLVM versions

### Getting Help

- Run validation: `./scripts/validate-crystal-install.sh`
- Check logs for detailed error messages
- Verify system requirements are met
- Consult Crystal documentation: https://crystal-lang.org/install/

## Integration

This script integrates seamlessly with:
- Main installation script (`scripts/install-crystal.sh`)
- Project test runner (`scripts/test-runner.sh`)
- CrystalCog build system
- CI/CD pipelines

## Maintenance

The script is designed to be maintainable and updateable:
- Version specifications are clearly marked
- Dependencies are well-documented
- Error messages provide clear guidance
- Modular function design for easy updates