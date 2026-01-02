# Crystal Language Installation for CrystalCog

This document provides comprehensive instructions for installing Crystal language in the CrystalCog project, especially when standard online installation methods are not available.

## Quick Start

### Automatic Installation

The project includes an automatic Crystal installation system. When you run any script that requires Crystal, it will automatically install Crystal if not found:

```bash
# This will automatically install Crystal if needed
./scripts/test-runner.sh --lint
```

### Manual Installation

You can also install Crystal manually using the dedicated installation script:

```bash
# Auto-detect best installation method
./scripts/install-crystal.sh

# Use specific installation method
./scripts/install-crystal.sh --method snap
./scripts/install-crystal.sh --method apt
./scripts/install-crystal.sh --method binary

# Show what would be done without installing
./scripts/install-crystal.sh --dry-run

# Get help
./scripts/install-crystal.sh --help
```

## Installation Methods

### 1. Snap Installation (Recommended)

```bash
./scripts/install-crystal.sh --method snap
```

This installs Crystal via Ubuntu's snap package manager. Most reliable when network access to Snap Store is available.

### 2. APT-based Installation (Fallback)

```bash
./scripts/install-crystal.sh --method apt
```

This installs Crystal using official Crystal language sources.

### 3. Binary Installation

```bash
./scripts/install-crystal.sh --method binary
```

Downloads and installs precompiled Crystal binaries from official GitHub releases.

### 4. Source Installation (Future)

```bash
./scripts/install-crystal.sh --method source
```

Builds Crystal from source code (not yet implemented).

## Offline Installation

When network access is limited, the project includes offline installation resources in the `crystal-lang/` directory:

```
crystal-lang/
├── README.md           # This documentation
├── install/            # Installation scripts
│   └── install-via-apt.sh
├── binaries/           # Precompiled binaries (future)
└── sources/            # Source code (future)
```

The installation scripts automatically check for offline resources when online methods fail.

## Verification

After installation, verify that Crystal is working:

```bash
crystal version
shards version
```

## Installation from Official Sources

The project uses the official Crystal language installation system. All installation methods download and install the real Crystal compiler and Shards package manager from official sources:

- Crystal binaries from GitHub releases: https://github.com/crystal-lang/crystal/releases  
- Dependencies from crystal-lang organization repositories
- Installation methods follow https://crystal-lang.org/install/ guidelines

## Troubleshooting

### Crystal Command Not Found

If Crystal is installed but not found in PATH:

```bash
# Add to your shell profile (.bashrc, .zshrc, etc.)
export PATH="/usr/local/bin:$PATH"

# Or reload your shell
source ~/.bashrc
```

### Permission Issues

If installation fails due to permissions:

```bash
# Ensure sudo access is available
sudo ./scripts/install-crystal.sh
```

### Network Issues

If online installation methods fail:

1. The script automatically falls back to offline methods
2. Use the `--method apt` option for system-based installation
3. Check the `crystal-lang/` directory for offline resources

### Reinstalling

To force reinstallation:

```bash
./scripts/install-crystal.sh --force
```

## Integration with CrystalCog

The Crystal installation is fully integrated with the CrystalCog development workflow:

1. **Test Runner**: `./scripts/test-runner.sh` automatically installs Crystal if needed
2. **Build System**: Makefile and build scripts detect and use installed Crystal
3. **CI/CD**: GitHub Actions workflows use the same installation scripts
4. **Development**: IDE and editor configurations work with installed Crystal

## Dependencies

The installation process automatically installs required dependencies:

- Build tools (build-essential, git, curl, wget)
- LLVM development tools
- Various development libraries (ssl, yaml, xml2, etc.)
- Package management tools

## Supported Platforms

Currently supported:

- ✅ Ubuntu 24.04 LTS (primary)
- ✅ Ubuntu 22.04 LTS
- ✅ Debian-based distributions
- 🔄 Other Linux distributions (partial support)

Future support planned:

- macOS
- Windows (WSL)
- Docker containers

## Contributing

To improve the Crystal installation system:

1. Test installation on different platforms
2. Add precompiled binaries to `crystal-lang/binaries/`
3. Enhance installation scripts with new methods
4. Update documentation with platform-specific instructions

## References

- [Crystal Language Official Site](https://crystal-lang.org/)
- [Crystal Installation Guide](https://crystal-lang.org/install/)
- [Crystal GitHub Releases](https://github.com/crystal-lang/crystal/releases)
- [CrystalCog Development Roadmap](../DEVELOPMENT-ROADMAP.md)