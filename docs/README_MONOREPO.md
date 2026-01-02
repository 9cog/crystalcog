# OpenCog Central Monorepo

This repository contains the complete OpenCog ecosystem as a monorepo, allowing you to build and install all OpenCog components in a single sequence.

## Overview

The OpenCog Central monorepo includes:

- **Core Components**: cogutil, atomspace, attention, ure, pln, link-grammar, cogserver
- **Extended Components**: All other OpenCog modules and extensions
- **Language Bindings**: Python, JavaScript, Rust, and more
- **Documentation**: API references and user guides
- **Tests**: Comprehensive test suites for all components

## Quick Start

### Prerequisites

- Ubuntu 20.04+ or equivalent Linux distribution
- CMake 3.10+
- GCC 7+ or Clang 6+
- Python 3.8+
- Node.js 14+
- Rust 1.50+ (optional)

### Building the Monorepo

1. **Clone the repository**:
   ```bash
   git clone https://github.com/opencog/opencog-central.git
   cd opencog-central
   ```

2. **Setup dependencies**:
   ```bash
   make setup
   ```

3. **Build all components**:
   ```bash
   make build
   ```

4. **Run tests**:
   ```bash
   make test
   ```

5. **Install components**:
   ```bash
   make install
   sudo ldconfig
   ```

### Alternative: Using the Build Script

You can also use the comprehensive build script:

```bash
# Setup dependencies only
./scripts/build-monorepo.sh --setup-only

# Build with default settings
./scripts/build-monorepo.sh

# Debug build with 4 jobs
./scripts/build-monorepo.sh -b Debug -j 4

# Clean build, skip tests
./scripts/build-monorepo.sh -c -t

# Setup development environment
./scripts/build-monorepo.sh -e
```

## Build Configuration

### Environment Variables

- `BUILD_TYPE`: Build type (Debug, Release, RelWithDebInfo) [default: Release]
- `JOBS`: Number of parallel jobs [default: number of CPU cores]
- `INSTALL_PREFIX`: Installation prefix [default: /usr/local]
- `BUILD_DIR`: Build directory [default: build]
- `SKIP_TESTS`: Skip tests (true/false) [default: false]
- `SKIP_INSTALL`: Skip installation (true/false) [default: false]
- `CLEAN_BUILD`: Clean build directory (true/false) [default: false]

### Make Targets

#### Basic Targets
- `make` or `make all` - Build all components (default)
- `make build` - Build all components
- `make test` - Run all tests
- `make install` - Install all components
- `make clean` - Clean build directory

#### Setup Targets
- `make setup` - Setup dependencies only
- `make dev-env` - Setup development environment
- `make deps` - Install system dependencies
- `make python-env` - Setup Python environment
- `make node-env` - Setup Node.js environment
- `make rust-env` - Setup Rust environment

#### Build Variants
- `make core` - Build core components only
- `make extended` - Build extended components
- `make dev` - Debug build with tests
- `make release` - Release build with tests and installation
- `make profile` - Profile build
- `make coverage` - Coverage build with tests

#### Documentation and Packaging
- `make doc` - Generate documentation
- `make package` - Create package
- `make rebuild` - Clean and rebuild

#### Component-Specific Targets
- `make build-<component>` - Build specific component
- `make test-<component>` - Test specific component
- `make install-<component>` - Install specific component

#### Utility Targets
- `make help` - Show help message
- `make status` - Show build status
- `make components` - List available components
- `make help-<component>` - Show help for specific component

### Examples

```bash
# Debug build with 4 jobs
make BUILD_TYPE=Debug JOBS=4

# Build without tests
make SKIP_TESTS=true

# Clean build
make clean build

# Build specific component
make build-atomspace

# Test specific component
make test-cogutil

# Development build
make dev

# Full release build
make release
```

## Component Dependencies

### Core Components (Built First)
1. **cogutil** - Core utilities and base classes
2. **atomspace** - Knowledge representation and reasoning engine
3. **attention** - Attention allocation system
4. **ure** - Unified Rule Engine
5. **pln** - Probabilistic Logic Networks
6. **link-grammar** - Natural language parsing
7. **cogserver** - Network server and API

### Extended Components (Built After Core)
All other components depend on the core components and are built in parallel after the core build completes.

## Development Environment

### Setting Up Development Environment

```bash
# Setup development environment
make dev-env

# Activate the environment
source .env
```

This creates a `.env` file with the necessary environment variables for development.

### IDE Integration

The build system generates `compile_commands.json` for IDE integration:

```bash
# Generate compile commands
make configure
```

### Debugging

For debugging, use the Debug build type:

```bash
make BUILD_TYPE=Debug
```

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run tests for specific component
make test-atomspace

# Skip tests during build
make SKIP_TESTS=true
```

### Test Configuration

Tests are configured to run with:
- Parallel execution (using all CPU cores)
- Output on failure
- Coverage reporting (when using Coverage build type)

## Installation

### System-Wide Installation

```bash
# Install all components
make install

# Update library cache
sudo ldconfig
```

### Custom Installation Prefix

```bash
# Install to custom location
make INSTALL_PREFIX=/opt/opencog install
```

### Package Creation

```bash
# Create Debian package
make package
```

## Continuous Integration

The repository includes a comprehensive GitHub Actions workflow that:

1. **Sets up dependencies** for all supported platforms
2. **Builds core components** in dependency order
3. **Builds extended components** in parallel
4. **Runs integration tests** with database services
5. **Generates documentation** and packages
6. **Provides build artifacts** for download

### Local CI Testing

You can test the CI workflow locally:

```bash
# Run the full CI sequence
make full
```

## Troubleshooting

### Common Issues

1. **Missing Dependencies**:
   ```bash
   make deps
   ```

2. **Build Failures**:
   ```bash
   make clean
   make build
   ```

3. **Test Failures**:
   ```bash
   make test-<component>
   ```

4. **Installation Issues**:
   ```bash
   sudo ldconfig
   ```

### Debug Information

```bash
# Show build status
make status

# Show component list
make components

# Get help for specific component
make help-atomspace
```

### Log Files

Build logs are available in the build directory:
- `build/CMakeFiles/CMakeOutput.log` - CMake configuration log
- `build/Testing/Temporary/LastTest.log` - Test results log

## Contributing

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Test your changes**:
   ```bash
   make test
   ```
5. **Submit a pull request**

### Code Style

- Follow the existing code style in each component
- Use the provided build system
- Add tests for new functionality
- Update documentation as needed

### Testing Your Changes

```bash
# Test specific component
make test-<component>

# Test all components
make test

# Run with debug information
make BUILD_TYPE=Debug test
```

## Documentation

### Generated Documentation

After building, documentation is available in:
- `build/doc/` - Generated documentation
- `API_DOCUMENTATION.md` - API reference
- `REST_API_REFERENCE.md` - REST API reference
- `PYTHON_API_REFERENCE.md` - Python API reference

### Building Documentation

```bash
# Generate documentation
make doc
```

## Support

### Getting Help

- **Documentation**: Check the generated documentation
- **Issues**: Report issues on GitHub
- **Discussions**: Use GitHub Discussions
- **Community**: Join the OpenCog community

### Reporting Issues

When reporting issues, please include:
- Build configuration (BUILD_TYPE, JOBS, etc.)
- Error messages and logs
- System information
- Steps to reproduce

## License

This project is licensed under the Apache License 2.0. See the LICENSE file for details.

## Acknowledgments

Thanks to all contributors to the OpenCog project and the open-source community.