# Link Grammar Parser Integration

This document describes the Link Grammar parser integration in CrystalCog, which provides advanced natural language parsing capabilities for the OpenCog framework.

## Overview

Link Grammar is a syntactic parsing system that identifies typed links between words in a sentence. This integration allows CrystalCog to:

- Parse natural language sentences into detailed syntactic structures
- Represent parse results in the AtomSpace knowledge representation
- Enable advanced linguistic reasoning and analysis
- Support multiple languages (English by default)

## Architecture

### Components

1. **Parser**: Main interface to Link Grammar functionality
2. **Linkage**: Represents a single parse of a sentence
3. **Link**: Represents a typed connection between two words
4. **Connector**: Represents connection points on words
5. **Disjunct**: Represents the connector set used for a word in a parse

### AtomSpace Representation

The integration maps Link Grammar concepts to OpenCog Atoms:

- **WORD_NODE**: Represents lexical words
- **WORD_INSTANCE_NODE**: Represents specific occurrences of words in sentences
- **PARSE_NODE**: Represents a specific parse of a sentence
- **LG_LINK_NODE**: Represents link types (e.g., "S" for subject)
- **SENTENCE_LINK**: Groups word instances into sentences
- **PARSE_LINK**: Associates parses with sentences
- **LG_LINK_INSTANCE_LINK**: Connects word instances via links

## Usage

### Basic Parsing

```crystal
require "./src/nlp/nlp"

# Initialize subsystems
CogUtil.initialize
AtomSpace.initialize
NLP.initialize

# Create a parser
parser = NLP::LinkGrammar::Parser.new

# Parse a sentence
linkages = parser.parse("The cat sits on the mat")

# Examine the first linkage
linkage = linkages.first
puts "Words: #{linkage.words}"
puts "Links: #{linkage.links.size}"
puts "Disjuncts: #{linkage.disjuncts.size}"
```

### AtomSpace Integration

```crystal
# Create an AtomSpace
atomspace = AtomSpace::AtomSpace.new

# Parse and store in AtomSpace
atoms = parser.parse_to_atomspace("The dog runs", atomspace)

puts "Created #{atoms.size} atoms"

# Query the results
word_nodes = atomspace.get_atoms_by_type(AtomSpace::AtomType::WORD_NODE)
word_instances = atomspace.get_atoms_by_type(AtomSpace::AtomType::WORD_INSTANCE_NODE)
parse_nodes = atomspace.get_atoms_by_type(AtomSpace::AtomType::PARSE_NODE)

puts "Word nodes: #{word_nodes.size}"
puts "Word instances: #{word_instances.size}"
puts "Parses: #{parse_nodes.size}"
```

### Convenience Methods

```crystal
# Quick parse using module-level methods
linkages = NLP::LinkGrammar.parse("Hello world")

# Quick parse to AtomSpace
atomspace = AtomSpace::AtomSpace.new
atoms = NLP::LinkGrammar.parse_to_atomspace("The cat runs", atomspace)
```

### Dictionary Lookup

```crystal
parser = NLP::LinkGrammar::Parser.new

# Look up a word's connector sets
disjuncts = parser.dictionary_lookup("cat")

disjuncts.each do |disjunct|
  puts "#{disjunct.word}: #{disjunct.connectors.join(' ')}"
end
```

## Data Structures

### Linkage

Represents a complete parse of a sentence:

```crystal
linkage = NLP::LinkGrammar::Linkage.new(
  sentence: "The cat sits",
  words: ["The", "cat", "sits"],
  links: [...],
  disjuncts: [...],
  cost: 0.0
)
```

Properties:
- `sentence`: Original sentence text
- `words`: Array of words in the sentence
- `links`: Array of Link objects connecting words
- `disjuncts`: Array of Disjunct objects used in the parse
- `cost`: Parse cost/score (lower is better)

### Link

Represents a typed connection between two words:

```crystal
link = NLP::LinkGrammar::Link.new(
  left_word: 0,
  right_word: 1,
  label: "D",  # Determiner link
  left_connector: "D+",
  right_connector: "D-"
)
```

Properties:
- `left_word`: Index of left word
- `right_word`: Index of right word
- `label`: Link type (e.g., "D", "S", "O")
- `left_connector`: Connector on left word
- `right_connector`: Connector on right word

### Connector

Represents a connection point on a word:

```crystal
connector = NLP::LinkGrammar::Connector.new(
  label: "S",
  direction: "+",  # "+" for right, "-" for left
  multi: false     # true if multi-connector "@"
)
```

### Disjunct

Represents the connector set used for a word:

```crystal
disjunct = NLP::LinkGrammar::Disjunct.new(
  word_index: 1,
  word: "cat",
  connectors: [connector1, connector2]
)
```

## Integration with Other NLP Modules

The Link Grammar integration works seamlessly with other NLP components:

### With Tokenizer

```crystal
text = "The quick brown fox jumps"

# Tokenize
tokens = NLP::Tokenizer.tokenize(text)

# Parse with Link Grammar
linkages = NLP::LinkGrammar.parse(text)

# Compare results
puts "Tokens: #{tokens.size}"
puts "Words in parse: #{linkages.first.words.size}"
```

### With Text Processor

```crystal
text = "Natural language processing enables understanding"

# Extract keywords
keywords = NLP::TextProcessor.extract_keywords(text, 3)

# Parse structure
atomspace = AtomSpace::AtomSpace.new
atoms = NLP::LinkGrammar.parse_to_atomspace(text, atomspace)

# Combine insights
puts "Key concepts: #{keywords}"
puts "Syntactic atoms: #{atoms.size}"
```

### With Linguistic Atoms

```crystal
atomspace = AtomSpace::AtomSpace.new

# Parse with Link Grammar
NLP::LinkGrammar.parse_to_atomspace("The cat chases the mouse", atomspace)

# Query using Linguistic Atoms module
word_atoms = NLP::LinguisticAtoms.get_word_atoms(atomspace)
complexity = NLP::LinguisticAtoms.get_linguistic_complexity(atomspace)

puts "Word atoms: #{word_atoms.size}"
puts "Parse links: #{complexity["evaluation_links"]}"
```

## AtomSpace Structure Example

For the sentence "The cat sits", the parser creates this structure:

```
WORD_NODE "The"
WORD_NODE "cat"
WORD_NODE "sits"

WORD_INSTANCE_NODE "The_0"
WORD_INSTANCE_NODE "cat_1"
WORD_INSTANCE_NODE "sits_2"

WORD_INSTANCE_LINK
  WORD_INSTANCE_NODE "The_0"
  WORD_NODE "The"

WORD_INSTANCE_LINK
  WORD_INSTANCE_NODE "cat_1"
  WORD_NODE "cat"

WORD_INSTANCE_LINK
  WORD_INSTANCE_NODE "sits_2"
  WORD_NODE "sits"

LG_LINK_NODE "D"  # Determiner
LG_LINK_NODE "S"  # Subject

LG_LINK_INSTANCE_LINK
  LG_LINK_NODE "D"
  WORD_INSTANCE_NODE "The_0"
  WORD_INSTANCE_NODE "cat_1"

LG_LINK_INSTANCE_LINK
  LG_LINK_NODE "S"
  WORD_INSTANCE_NODE "cat_1"
  WORD_INSTANCE_NODE "sits_2"

SENTENCE_LINK
  WORD_INSTANCE_NODE "The_0"
  WORD_INSTANCE_NODE "cat_1"
  WORD_INSTANCE_NODE "sits_2"

PARSE_NODE "parse_<hash>"

PARSE_LINK
  PARSE_NODE "parse_<hash>"
  SENTENCE_LINK ...
```

## Link Types

Common Link Grammar link types include:

- **D**: Determiner (the, a, an)
- **S**: Subject-verb
- **O**: Object
- **J**: Preposition-object
- **MX**: Post-nominal modifier
- **E**: Adverb
- **A**: Adjective
- **CO**: Coordinating conjunction
- **TO**: Infinitive "to"
- **I**: Infinitive verb

## Implementation Notes

### Current Status

The current implementation provides:
- ✅ Complete parsing API
- ✅ AtomSpace integration
- ✅ Mock parser for development/testing
- ⚠️ Full Link Grammar C library integration (planned)

### Mock Parser

The current implementation includes a mock parser that generates simplified parse structures. This is sufficient for:
- Development and testing
- Demonstrating the integration architecture
- Building applications that will later use the full parser

### Future Enhancements

Planned improvements include:

1. **Full Link Grammar Library Integration**
   - FFI bindings to the C library
   - Access to full dictionaries
   - Multiple parse rankings
   - Cost-based parse selection

2. **Advanced Features**
   - Multi-language support beyond English
   - Custom dictionary extensions
   - Parse disambiguation
   - Confidence scoring

3. **Performance Optimizations**
   - Parse caching
   - Parallel parsing
   - Memory-efficient storage

## Error Handling

The integration provides specific exception types:

```crystal
begin
  parser = NLP::LinkGrammar::Parser.new
  linkages = parser.parse("")
rescue ex : NLP::LinkGrammar::ParserException
  puts "Parse error: #{ex.message}"
rescue ex : NLP::LinkGrammar::DictionaryException
  puts "Dictionary error: #{ex.message}"
rescue ex : NLP::LinkGrammar::LinkGrammarException
  puts "Link Grammar error: #{ex.message}"
end
```

## Testing

Comprehensive tests are available in `spec/nlp/link_grammar_spec.cr`:

```bash
crystal spec spec/nlp/link_grammar_spec.cr
```

Test coverage includes:
- Parser initialization
- Sentence parsing
- Linkage structure
- Link and connector creation
- AtomSpace integration
- Module-level convenience methods
- Integration with other NLP modules

## References

- [Link Grammar Website](https://www.abisource.com/projects/link-grammar/)
- [Link Grammar Theory](https://www.link.cs.cmu.edu/link/dict/introduction.html)
- [OpenCog lg-atomese](https://github.com/opencog/lg-atomese)
- [CrystalCog NLP Documentation](./NLP.md)

## See Also

- [NLP Module Overview](./NLP.md)
- [Tokenizer Documentation](./Tokenizer.md)
- [Text Processor Documentation](./TextProcessor.md)
- [Linguistic Atoms Documentation](./LinguisticAtoms.md)
