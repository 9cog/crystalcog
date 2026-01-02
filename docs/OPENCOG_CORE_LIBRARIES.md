# OpenCog Core Libraries Documentation

This document describes the completed OpenCog core libraries implementation in Crystal, addressing Phase 2 of the development roadmap.

## Overview

The OpenCog module now provides comprehensive core reasoning and cognitive architecture functionality, including:

1. **Core reasoning algorithms** - Inference and reasoning functions
2. **Atom manipulation functions** - Utilities for working with atoms
3. **Query processing foundation** - Basic query capabilities

## Modules

### OpenCog::Reasoning

Core reasoning algorithms that combine PLN and URE capabilities.

#### Methods

- `infer(atomspace, max_steps)` - Apply basic logical inference
- `can_conclude?(atomspace, goal)` - Check if a conclusion can be reached
- `find_most_confident(atomspace, type, limit)` - Find most confident atoms
- `similarity(atomspace, atom1, atom2)` - Calculate similarity between atoms

#### Example Usage

```crystal
atomspace = AtomSpace::AtomSpace.new
cat = atomspace.add_concept_node("Cat")
animal = atomspace.add_concept_node("Animal")
atomspace.add_inheritance_link(cat, animal)

# Perform inference
results = OpenCog::Reasoning.infer(atomspace, 10)
puts "Generated #{results.size} inferences"

# Check if conclusion is possible
goal = atomspace.add_inheritance_link(cat, animal)
can_conclude = OpenCog::Reasoning.can_conclude?(atomspace, goal)
puts "Can conclude: #{can_conclude}"

# Calculate similarity
dog = atomspace.add_concept_node("Dog")
similarity = OpenCog::Reasoning.similarity(atomspace, cat, dog)
puts "Cat-Dog similarity: #{similarity}"
```

### OpenCog::AtomUtils

Utilities for creating, manipulating, and working with atoms.

#### Methods

- `create_hierarchy(atomspace, hierarchy)` - Create concept hierarchy
- `create_semantic_network(atomspace, facts)` - Create semantic network from facts
- `extract_subgraph(atomspace, center, depth)` - Extract subgraph around an atom
- `merge_atoms(atomspace, atom1, atom2)` - Merge two identical atoms
- `find_matching_atoms(atomspace, pattern)` - Find atoms matching a pattern

#### Example Usage

```crystal
# Create concept hierarchy
hierarchy = {
  "Cat" => ["Mammal", "Pet"],
  "Dog" => ["Mammal", "Pet"],
  "Mammal" => ["Animal"]
}
created = OpenCog::AtomUtils.create_hierarchy(atomspace, hierarchy)

# Create semantic network
facts = [
  {"subject" => "Cat", "predicate" => "likes", "object" => "Fish"},
  {"subject" => "Dog", "predicate" => "likes", "object" => "Bone"}
]
network = OpenCog::AtomUtils.create_semantic_network(atomspace, facts)

# Extract subgraph
cat_node = atomspace.get_nodes_by_name("Cat").first
subgraph = OpenCog::AtomUtils.extract_subgraph(atomspace, cat_node, 2)
```

### OpenCog::Query

Basic query processing capabilities for the AtomSpace.

#### Classes

- `QueryResult` - Stores query results with variable bindings and confidence
- `Variable` - Represents query variables

#### String-Based Query Language

The OpenCog Query Language (OQL) provides SQL-like syntax for querying the AtomSpace:

```crystal
# Basic SELECT WHERE syntax
results = OpenCog::Query.execute_query(atomspace, 
  "SELECT $animal WHERE { $animal ISA Mammal }")

# Multiple variables with type constraints
results = OpenCog::Query.execute_query(atomspace,
  "SELECT $x:CONCEPT, $y WHERE { $x likes $y }")

# Complex patterns with multiple clauses
results = OpenCog::Query.execute_query(atomspace,
  "SELECT $pet WHERE { $pet ISA Dog . $pet likes Food }")
```

#### Query Language Features

- **Variables**: Use `$name` syntax, optional type constraints with `$name:TYPE`
- **Triple patterns**: `subject predicate object` for evaluation links
- **Inheritance patterns**: `child ISA parent` or `child -> parent`
- **Multiple clauses**: Separate with periods or newlines
- **Type constraints**: CONCEPT, PREDICATE, NODE, LINK types supported

#### Methods

- `execute_query(atomspace, query_string)` - Execute string-based query
- `parse_query(query_string)` - Parse query string into structured form
- `create_query_interface(atomspace)` - Create query interface for atomspace
- `query_pattern(atomspace, pattern, variables)` - Execute pattern query
- `find_instances(atomspace, concept)` - Find all instances of a concept
- `find_predicates(atomspace, subject)` - Find predicates applied to a subject
- `query_conjunction(atomspace, patterns)` - Execute AND query
- `query_disjunction(atomspace, patterns)` - Execute OR query

#### Example Usage

```crystal
# Create atomspace and add knowledge
atomspace = AtomSpace::AtomSpace.new
dog = atomspace.add_concept_node("Dog")
animal = atomspace.add_concept_node("Animal")
atomspace.add_inheritance_link(dog, animal)

# String-based queries
results = OpenCog::Query.execute_query(atomspace, 
  "SELECT $x WHERE { $x ISA Animal }")

# Query interface for multiple queries
query_interface = OpenCog::Query.create_query_interface(atomspace)
results = query_interface.query("SELECT $pet WHERE { $pet ISA Dog }")

# Convenience methods
animal_instances = query_interface.find_all("Animal")
john_relations = query_interface.find_relations("John", "likes")

# Traditional pattern queries still work
cat = atomspace.add_concept_node("Cat")
results = OpenCog::Query.query_pattern(atomspace, cat)

# Find instances of a concept
animal = atomspace.add_concept_node("Animal")
instances = OpenCog::Query.find_instances(atomspace, animal)

# Find predicates
predicates = OpenCog::Query.find_predicates(atomspace, cat)
```

### OpenCog::PatternMatcher

Pattern matching engine for complex atom patterns.

#### Methods

- `match(atomspace, pattern)` - Match pattern against AtomSpace

### OpenCog::Learning

Learning algorithms for discovering patterns and implications.

#### Methods

- `learn_implications(atomspace, confidence_threshold)` - Learn implications from patterns

#### Example Usage

```crystal
# Learn implications from evaluation patterns
implications = OpenCog::Learning.learn_implications(atomspace, 0.7)
puts "Learned #{implications.size} implications"
```

### OpenCog::OpenCogReasoner

Main reasoner class that combines all OpenCog capabilities.

#### Methods

- `reason(steps)` - Perform comprehensive reasoning
- `query(pattern)` - Query the knowledge base
- `can_achieve?(goal)` - Check if a goal can be achieved

#### Example Usage

```crystal
reasoner = OpenCog.create_reasoner(atomspace)

# Perform reasoning
results = reasoner.reason(10)

# Query knowledge base
query_results = reasoner.query(some_pattern)

# Check goal achievement
can_achieve = reasoner.can_achieve?(goal_atom)
```

## Integration with Existing Systems

The OpenCog core libraries integrate seamlessly with:

- **AtomSpace** - Uses AtomSpace for knowledge storage and retrieval
- **PLN** - Leverages PLN for probabilistic reasoning
- **URE** - Uses URE for rule-based inference
- **CogUtil** - Uses logging and configuration systems

## Error Handling

All modules include comprehensive error handling with custom exception classes:

- `OpenCogException` - Base exception for OpenCog operations
- `ReasoningException` - Reasoning-specific errors
- `PatternMatchException` - Pattern matching errors
- `QueryException` - Query processing errors

## Performance Considerations

- Thread-safe operations using AtomSpace's internal synchronization
- Efficient indexing and caching in AtomSpace
- Configurable limits on reasoning steps and query complexity
- Memory-conscious subgraph extraction with depth limits

## Testing

Comprehensive test suite includes:

- Unit tests for each module (`spec/opencog/opencog_spec.cr`)
- Integration tests (`spec/opencog/integration_spec.cr`)
- End-to-end scenarios demonstrating full functionality
- Error condition testing

Run tests with:
```bash
crystal spec spec/opencog/
```

## Future Enhancements

The current implementation provides the foundation for:

- Advanced pattern matching with variables and constraints
- Distributed reasoning across multiple AtomSpaces
- Machine learning integration for pattern discovery
- Performance optimizations for large knowledge bases
- Integration with external reasoning systems

## Roadmap Completion

This implementation completes the Phase 2 requirement "Complete opencog core libraries" by providing:

✅ **Core reasoning algorithms** - Implemented in `OpenCog::Reasoning`  
✅ **Atom manipulation functions** - Implemented in `OpenCog::AtomUtils`  
✅ **Query processing foundation** - Implemented in `OpenCog::Query`

The OpenCog core libraries are now ready for Phase 3 development.