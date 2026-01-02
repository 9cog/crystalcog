# CrystalCog Examples

This directory contains example programs and demonstrations of CrystalCog functionality.

## Directory Structure

### demos/
Interactive demonstrations showcasing CrystalCog features:
- `demo.cr` - Basic CrystalCog functionality demo
- `demo_advanced_pattern_matching.cr` - Advanced pattern matching capabilities
- `demo_advanced_reasoning.cr` - PLN and URE reasoning demonstrations
- `demo_ai_integration.cr` - AI system integration examples
- `demo_attention.cr` - Attention allocation (ECAN) demo
- `demo_cogserver.cr` - CogServer network API demo
- `demo_hypergraph_persistence.cr` - Persistence layer demo
- `demo_link_grammar.cr` - Link Grammar NLP demo
- `demo_storage_backends.cr` - Storage backend demonstrations

### tests/
Test programs and debugging utilities:
- `test_basic.cr` - Basic functionality tests
- `test_pln.cr` - PLN reasoning tests
- `test_pattern_matching.cr` - Pattern matching tests
- `test_persistence.cr` - Persistence layer tests
- `test_cogserver_api.cr` - CogServer API tests
- `test_advanced_nlp.cr` - NLP functionality tests
- And many more specialized test files...

### Distributed & Advanced Examples
Located in the main examples directory:
- `distributed_atomspace_demo.cr` - Multi-node AtomSpace clustering demo
- `moses_demo.cr` - MOSES evolutionary optimization demo

## Running Examples

### Basic Usage
```bash
# Run a basic demo
crystal run examples/demos/demo.cr

# Run with optimizations
crystal run --release examples/demos/demo_advanced_reasoning.cr
```

### Running Tests
```bash
# Run a specific test
crystal run examples/tests/test_basic.cr

# Run with verbose output
crystal run examples/tests/test_pln.cr -- --verbose
```

### Using the Main Test Suite
For comprehensive testing, use the spec directory:
```bash
crystal spec
```

## Example Categories

### 1. Core Functionality
- Basic AtomSpace operations
- Truth value manipulation
- Simple queries

### 2. Reasoning
- PLN (Probabilistic Logic Networks)
- URE (Unified Rule Engine)
- Forward/backward chaining
- Pattern-based inference

### 3. Pattern Matching
- Basic pattern matching
- Variable binding
- Complex query patterns
- Pattern mining

### 4. Natural Language Processing
- Tokenization and text processing
- Link Grammar parsing
- Linguistic atom creation
- Semantic analysis

### 5. Server & Networking
- CogServer TCP/WebSocket API
- REST API endpoints
- Distributed AtomSpace clustering

### 6. Persistence
- File-based storage
- Database backends (PostgreSQL, RocksDB, SQLite)
- State serialization/deserialization

### 7. Advanced Features
- Attention allocation (ECAN)
- Self-modification
- Meta-cognitive capabilities
- Performance profiling

## Learning Path

**Beginners**: Start with these examples in order:
1. `demos/demo.cr` - Understand basic concepts
2. `tests/test_basic.cr` - See core functionality
3. `tests/test_pln.cr` - Learn about reasoning
4. `demos/demo_advanced_reasoning.cr` - Explore PLN/URE

**Intermediate**: Explore these areas:
1. Pattern matching examples
2. NLP demos
3. CogServer demos
4. Persistence examples

**Advanced**: Dive into:
1. Distributed AtomSpace clustering
2. MOSES evolutionary optimization
3. Advanced reasoning patterns
4. Self-modification examples

## Performance Testing

Several examples include performance benchmarking:
- Check `benchmarks/` directory for dedicated performance tests
- Many demos include timing information
- Use `--release` flag for production-level performance

## Contributing Examples

When adding new examples:
1. Place demos in `demos/` directory
2. Place tests in `tests/` directory
3. Include clear comments explaining the example
4. Add error handling and validation
5. Update this README with a description

## See Also

- [Main README](../README.md) - Project overview
- [Documentation Index](../docs/INDEX.md) - Complete documentation
- [Development Roadmap](../docs/DEVELOPMENT-ROADMAP.md) - Implementation status
- [Spec Directory](../spec/) - Formal test specifications
