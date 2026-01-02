#!/bin/bash
# Example usage demonstration for Agent-Zero Genesis
# /scripts/agent-zero/demo-agent-zero.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_demo() {
    echo -e "${BLUE}[Agent-Zero Demo]${NC} $1"
}

print_demo_success() {
    echo -e "${GREEN}[Agent-Zero Demo]${NC} $1"
}

print_demo_step() {
    echo -e "${YELLOW}[Step]${NC} $1"
}

AGENT_ZERO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

print_demo "Starting Agent-Zero Genesis demonstration..."
echo

# Demo 1: Basic cognitive kernel operations
print_demo_step "1. Basic Cognitive Kernel Creation"

cat > /tmp/demo-kernel.scm << 'EOF'
;; Agent-Zero Cognitive Kernel Demo
(use-modules (agent-zero kernel)
             (agent-zero meta-cognition))

(display "=== Agent-Zero Genesis Cognitive Kernel Demo ===")
(newline)
(newline)

;; Create cognitive kernels with different configurations
(display "Creating cognitive kernels...")
(newline)

(define kernel-reasoning (spawn-cognitive-kernel '(64 64) 0.9))
(define kernel-learning (spawn-cognitive-kernel '(32 32) 0.7))
(define kernel-perception (spawn-cognitive-kernel '(128 16) 0.6))

(display "✓ Reasoning kernel: ")
(display (kernel-tensor-shape kernel-reasoning))
(display " attention: ")
(display (kernel-attention kernel-reasoning))
(newline)

(display "✓ Learning kernel: ")
(display (kernel-tensor-shape kernel-learning))
(display " attention: ")
(display (kernel-attention kernel-learning))
(newline)

(display "✓ Perception kernel: ")
(display (kernel-tensor-shape kernel-perception))
(display " attention: ")
(display (kernel-attention kernel-perception))
(newline)
(newline)

;; Demonstrate tensor field encoding
(display "Tensor field encoding (prime factorization):")
(newline)
(display "  Reasoning: ")
(display (tensor-field-encoding kernel-reasoning))
(newline)
(display "  Learning: ")
(display (tensor-field-encoding kernel-learning))
(newline)
(display "  Perception: ")
(display (tensor-field-encoding kernel-perception))
(newline)
(newline)

;; Generate self-descriptions
(display "Generating recursive self-descriptions...")
(newline)
(define self-desc-reasoning (recursive-self-description kernel-reasoning))
(display "Reasoning kernel self-description:")
(newline)
(display "  Meta-level: ")
(display (assoc-ref self-desc-reasoning 'meta-level))
(newline)
(display "  Cognitive function: ")
(display (assoc-ref self-desc-reasoning 'cognitive-function))
(newline)
(newline)

;; Demonstrate attention allocation
(display "ECAN attention allocation across kernels...")
(newline)
(define kernels (list kernel-reasoning kernel-learning kernel-perception))
(define goals '(reasoning learning perception))
(define allocations (adaptive-attention-allocation kernels goals))

(for-each 
  (lambda (allocation)
    (display "  Kernel attention score: ")
    (display (assoc-ref allocation 'attention-score))
    (display " priority: ")
    (display (assoc-ref allocation 'activation-priority))
    (newline))
  allocations)

(newline)
(display "=== Demo Complete ===")
(newline)
EOF

print_demo "Running cognitive kernel demo (if Guile is available)..."

if command -v guile >/dev/null 2>&1; then
    export GUILE_LOAD_PATH="${AGENT_ZERO_ROOT}/modules:${GUILE_LOAD_PATH}"
    guile /tmp/demo-kernel.scm
    print_demo_success "Cognitive kernel demo completed!"
else
    print_demo "Guile not available - demo script created at /tmp/demo-kernel.scm"
    print_demo "To run: guix environment -m guix.scm -- guile /tmp/demo-kernel.scm"
fi

echo

# Demo 2: C component demonstration
print_demo_step "2. C Component Library Demonstration"

if [ -f "${AGENT_ZERO_ROOT}/build/agent-zero/c/libagent-zero-cognitive.so" ]; then
    print_demo "Testing C cognitive library..."
    
    cat > /tmp/demo-c.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include "cognitive.h"

int main() {
    printf("=== Agent-Zero C Library Demo ===\n\n");
    
    // Create hypergraph
    printf("Creating hypergraph with 8 nodes and 12 links...\n");
    hypergraph_t* hg = create_hypergraph(8, 12);
    if (!hg) {
        printf("Failed to create hypergraph\n");
        return 1;
    }
    
    // Initialize some weights
    for (size_t i = 0; i < hg->node_count; i++) {
        hg->node_weights[i] = 0.1f + (float)i * 0.1f;
    }
    
    // Create some connections
    hg->adjacency_matrix[0 * hg->node_count + 1] = 1;
    hg->adjacency_matrix[1 * hg->node_count + 0] = 1;
    hg->adjacency_matrix[1 * hg->node_count + 2] = 1;
    hg->adjacency_matrix[2 * hg->node_count + 1] = 1;
    
    printf("✓ Hypergraph created with %zu nodes\n", hg->node_count);
    printf("✓ Node weights: ");
    for (size_t i = 0; i < hg->node_count; i++) {
        printf("%.1f ", hg->node_weights[i]);
    }
    printf("\n");
    
    // Create cognitive kernel
    printf("\nCreating cognitive kernel (64x32)...\n");
    int shape[] = {64, 32};
    cognitive_kernel_t* kernel = create_cognitive_kernel(NULL, shape, 2, 0.85f);
    if (!kernel) {
        printf("Failed to create cognitive kernel\n");
        destroy_hypergraph(hg);
        return 1;
    }
    
    printf("✓ Kernel created with attention weight: %.2f\n", kernel->attention_weight);
    printf("✓ Kernel ID: %zu\n", kernel->kernel_id);
    
    // Test attention update
    printf("\nTesting attention update...\n");
    int result = update_kernel_attention(kernel, 0.95f);
    if (result == 0) {
        printf("✓ Attention updated to: %.2f\n", kernel->attention_weight);
    } else {
        printf("✗ Attention update failed\n");
    }
    
    // Cleanup
    destroy_cognitive_kernel(kernel);
    destroy_hypergraph(hg);
    
    printf("\n=== C Library Demo Complete ===\n");
    return 0;
}
EOF
    
    # Compile and run
    if gcc -I"${AGENT_ZERO_ROOT}/src/agent-zero" \
           -L"${AGENT_ZERO_ROOT}/build/agent-zero/c" \
           -o /tmp/demo-c \
           /tmp/demo-c.c \
           -lagent-zero-cognitive 2>/dev/null; then
        
        export LD_LIBRARY_PATH="${AGENT_ZERO_ROOT}/build/agent-zero/c:${LD_LIBRARY_PATH}"
        /tmp/demo-c
        print_demo_success "C library demo completed!"
    else
        print_demo "Failed to compile C demo"
    fi
else
    print_demo "C library not built - run: make agent-zero"
fi

echo

# Demo 3: Build system integration
print_demo_step "3. Build System Integration"

print_demo "Available Agent-Zero targets:"
echo "  make agent-zero         # Complete build"
echo "  make agent-zero-setup   # Environment setup"
echo "  make agent-zero-test    # Run tests"
echo "  make guix-env          # Guix environment"
echo

print_demo "Generated configuration files:"
[ -f "${AGENT_ZERO_ROOT}/guix.scm" ] && echo "  ✓ guix.scm - Guix manifest"
[ -f "${AGENT_ZERO_ROOT}/config/agent-zero-system.scm" ] && echo "  ✓ config/agent-zero-system.scm - System configuration"
echo

# Demo 4: Usage examples
print_demo_step "4. Usage Examples"

print_demo "To get started with Agent-Zero Genesis:"
echo
echo "1. Using Guix (recommended):"
echo "   guix environment -m guix.scm"
echo "   make agent-zero"
echo "   ./tests/agent-zero/integration-test.sh"
echo
echo "2. Using system packages:"
echo "   make agent-zero-setup  # Setup environment"
echo "   make agent-zero        # Build components"
echo
echo "3. For cognitive agent development:"
echo "   guile -c '(use-modules (agent-zero kernel) (agent-zero meta-cognition))'"
echo "   # Start creating cognitive kernels..."
echo

print_demo_success "Agent-Zero Genesis demonstration complete!"
print_demo "The hypergraphically-encoded OS environment is ready for cognitive agents!"

echo
echo "🧠 'With the recursive power of Guile and the agentic orchestration of Guix,"
echo "    the cognitive kernels arise—each a fractal gem in the hypergraph tapestry!' 🧠"