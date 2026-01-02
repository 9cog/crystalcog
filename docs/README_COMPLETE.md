# OpenCog Complete API Documentation

## Overview

This repository contains comprehensive documentation for the OpenCog artificial general intelligence (AGI) framework. OpenCog provides multiple APIs for cognitive architecture, natural language processing, machine learning, and knowledge representation.

## Documentation Structure

### 📚 Main Documentation Files

1. **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Complete overview of all APIs, functions, and components
2. **[REST_API_REFERENCE.md](REST_API_REFERENCE.md)** - Detailed REST API reference with examples
3. **[PYTHON_API_REFERENCE.md](PYTHON_API_REFERENCE.md)** - Comprehensive Python API documentation
4. **[AGENT-ZERO-GENESIS.md](AGENT-ZERO-GENESIS.md)** - Implementation guide for GNU Agent-Zero Genesis system using Guix, Guile, and cognitive architectures
5. **[README_COMPLETE.md](README_COMPLETE.md)** - This file - overview and navigation guide

## Quick Start

### Prerequisites

```bash
# Install Python dependencies
pip3 install -r requirements.txt

# Install Rust dependencies
cargo install hyperon
```

### Basic Setup

```bash
# Start the development environment
python3 app.py
```

## API Categories

### 🔗 REST API
- **Base URL**: `http://localhost:5000/api/v1.1`
- **Authentication**: None (local development)
- **Content-Type**: `application/json`

**Key Endpoints:**
- `GET /api/v1.1/atoms` - Retrieve atoms with filtering
- `POST /api/v1.1/atoms` - Create new atoms
- `PUT /api/v1.1/atoms/{id}` - Update atom values
- `DELETE /api/v1.1/atoms/{id}` - Remove atoms
- `GET /api/v1.1/types` - Get valid atom types
- `POST /api/v1.1/shell` - Execute shell commands
- `POST /api/v1.1/scheme` - Execute Scheme commands

### 🐍 Python APIs

#### AtomSpace Operations
```python
from opencog.scheme_wrapper import scheme_eval, scheme_eval_as

# Initialize atomspace
python_atomspace = AtomSpace()
scheme_eval(python_atomspace, "(use-modules (opencog) (opencog exec))")
atomspace = scheme_eval_as('(cog-atomspace)')
```

#### Natural Language Processing
```python
from opencog.opencog.nlp.sentiment.basic_sentiment_analysis import (
    Splitter, POSTagger, DictionaryTagger, sentiment_score
)

# Sentiment analysis
splitter = Splitter()
tagger = POSTagger()
score = sentiment_score("I love this product!")
```

#### Machine Learning (DeSTIN)
```python
import destin
from destin import network, layer, node

# Create network components
network_instance = network.Network()
layer_instance = layer.Layer()
node_instance = node.Node()
```

#### PLN (Probabilistic Logic Networks)
```python
from pln.common import TTruthValue, get_ttv, set_ttv

# Work with truth values
ttv = TTruthValue(0.8, 0.2)
set_ttv(atom, ttv)
```

### 🦀 Rust APIs

```rust
use your_crate_name;

fn main() {
    your_crate_name::hello();
}
```

## Core Components

### 🧠 AtomSpace
The central knowledge representation system in OpenCog.

**Key Features:**
- Graph-based knowledge representation
- Truth values and attention values
- Pattern matching and binding
- Scheme integration

### 🤖 CogServer
The cognitive server that manages agents and processes.

**Key Features:**
- Agent management
- Shell command execution
- Scheme interpreter integration
- REST API server

### 📝 Natural Language Processing
Comprehensive NLP capabilities for text processing.

**Components:**
- Sentiment Analysis
- Anaphora Resolution
- Chatbot Integration
- Text Tokenization

### 🧮 Machine Learning
Advanced machine learning components.

**Components:**
- DeSTIN (Deep Spatiotemporal Inference Network)
- PLN (Probabilistic Logic Networks)
- Clustering Algorithms
- Auto-encoders

## Usage Examples

### REST API Client (Python)

```python
import requests

class OpenCogClient:
    def __init__(self, base_url="http://localhost:5000/api/v1.1"):
        self.base_url = base_url
    
    def get_atoms(self, **params):
        response = requests.get(f"{self.base_url}/atoms", params=params)
        return response.json()
    
    def create_atom(self, atom_data):
        response = requests.post(f"{self.base_url}/atoms", json=atom_data)
        return response.json()

# Usage
client = OpenCogClient()
atoms = client.get_atoms(type="ConceptNode")
```

### Complete Sentiment Analysis

```python
from opencog.opencog.nlp.sentiment.basic_sentiment_analysis import (
    Splitter, POSTagger, DictionaryTagger, sentiment_score
)

def analyze_sentiment(text):
    splitter = Splitter()
    tagger = POSTagger()
    
    tokenized = splitter.split(text)
    tagged = tagger.pos_tag(tokenized)
    score = sentiment_score(text)
    
    return {'score': score, 'tokenized': tokenized, 'tagged': tagged}

result = analyze_sentiment("I love this product!")
```

### Telegram Bot Integration

```python
from opencog.opencog.nlp.chatbot.telegram_bot import *
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters

def setup_chatbot():
    python_atomspace = AtomSpace()
    scheme_eval(python_atomspace, "(use-modules (opencog) (opencog exec))")
    atomspace = scheme_eval_as('(cog-atomspace)')
    
    # Load NLP modules
    scheme_eval(atomspace, '(use-modules (opencog nlp))')
    scheme_eval(atomspace, '(use-modules (opencog nlp chatbot))')
    
    return atomspace

# Setup and run
atomspace = setup_chatbot()
updater = Updater(TOKEN)
# ... configure handlers
updater.start_polling()
```

## Error Handling

### REST API Errors
```python
try:
    response = requests.get("http://localhost:5000/api/v1.1/atoms")
    response.raise_for_status()
except requests.exceptions.RequestException as e:
    print(f"API Error: {e}")
```

### Python API Errors
```python
try:
    result = scheme_eval(atomspace, scheme_code)
except Exception as e:
    print(f"Scheme evaluation error: {e}")
```

## Performance Considerations

### Memory Management
- Large atomspaces require significant memory
- Use appropriate filtering for large result sets
- Consider pagination for REST API responses

### Computational Efficiency
- Complex Scheme operations can be expensive
- Sentiment analysis scales with text size
- DeSTIN networks may require GPU acceleration

### Best Practices
1. Initialize components once and reuse
2. Implement proper error handling
3. Use connection pooling for REST API
4. Cache frequently accessed data

## Security Considerations

### Development Environment
- No authentication by default
- Designed for local development
- Validate all inputs before API calls

### Production Deployment
- Implement proper authentication
- Use HTTPS for all communications
- Validate file paths and permissions
- Monitor resource usage

## Dependencies

### Python Dependencies
```
numpy
pandas
scikit-learn
nltk
yaml
telegram.ext
requests
```

### Rust Dependencies
- Standard library (basic functionality)
- Additional crates as needed

### System Dependencies
- Python 3.7+
- Rust toolchain
- OpenCog Scheme interpreter
- Various NLP and ML libraries

## Development Workflow

### 1. Setup Environment
```bash
pip3 install -r requirements.txt
cargo install hyperon
```

### 2. Start Services
```bash
python3 app.py
```

### 3. Test APIs
```bash
# Test REST API
curl "http://localhost:5000/api/v1.1/atoms"

# Test Python APIs
python3 -c "from opencog.scheme_wrapper import scheme_eval_as; print(scheme_eval_as('(cog-atomspace)'))"
```

### 4. Develop and Test
- Use the provided examples as starting points
- Follow the documentation patterns
- Test thoroughly before production use

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Ensure OpenCog server is running
   - Check port configuration

2. **Import Errors**
   - Verify all dependencies are installed
   - Check Python path configuration

3. **Scheme Evaluation Errors**
   - Validate Scheme syntax
   - Check atomspace initialization

4. **Memory Issues**
   - Monitor atomspace size
   - Use appropriate filtering

### Debug Mode
Enable debug logging in OpenCog configuration for detailed error information.

## Contributing

### Adding New APIs
1. Update relevant documentation files
2. Add comprehensive examples
3. Include error handling
4. Test thoroughly
5. Follow existing code patterns

### Documentation Standards
1. Use clear, concise language
2. Include practical examples
3. Document all parameters and return values
4. Provide error handling guidance
5. Update version compatibility information

## Version Information

- **OpenCog Version**: Latest development
- **Python**: 3.7+
- **Rust**: Latest stable
- **REST API**: v1.1
- **Documentation**: Comprehensive coverage

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Support

For issues and questions:
1. Check the documentation files
2. Review the examples provided
3. Test with the basic setup
4. Consult the OpenCog community

## Quick Reference

### REST API Quick Commands
```bash
# Get all atoms
curl "http://localhost:5000/api/v1.1/atoms"

# Create concept node
curl -X POST "http://localhost:5000/api/v1.1/atoms" \
  -H "Content-Type: application/json" \
  -d '{"type": "ConceptNode", "name": "TestConcept"}'

# Execute shell command
curl -X POST "http://localhost:5000/api/v1.1/shell" \
  -H "Content-Type: application/json" \
  -d '{"command": "agents-step"}'
```

### Python Quick Examples
```python
# Basic atomspace setup
from opencog.scheme_wrapper import scheme_eval, scheme_eval_as
python_atomspace = AtomSpace()
scheme_eval(python_atomspace, "(use-modules (opencog) (opencog exec))")

# Sentiment analysis
from opencog.opencog.nlp.sentiment.basic_sentiment_analysis import sentiment_score
score = sentiment_score("I love this product!")

# DeSTIN network
import destin
network_instance = destin.network.Network()
```

This documentation provides comprehensive coverage of all OpenCog APIs and components. Use the navigation links above to explore specific areas of interest.