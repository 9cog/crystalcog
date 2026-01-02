# Focused ECAN Attention Allocation Implementation

## Overview

This document describes the focused ECAN (Economic Cognitive Attention Networks) attention allocation system implemented for Agent-Zero Genesis. The enhancement transforms the basic attention allocation into a sophisticated cognitive attention management system based on OpenCog's ECAN architecture.

## Key Features Implemented

### 1. Attention Value System

**STI/LTI/VLTI Management:**
- **STI (Short-Term Importance)**: Dynamic attention values that change rapidly
- **LTI (Long-Term Importance)**: Stable attention values for persistent importance
- **VLTI (Very Long-Term Importance)**: Ultra-stable importance values

```scheme
;; Create attention values
(define av (make-attention-value 100 50 0)) ; STI=100, LTI=50, VLTI=0
```

### 2. Attention Diffusion Algorithms

**Importance Spreading:**
- Attention diffuses from high-STI kernels to connected neighbors
- Transfer efficiency of 80% to simulate attention economy
- Neighbor selection based on tensor shape similarity and attention compatibility

**Focused Diffusion Process:**
1. Select nodes in attentional focus (STI > 100)
2. Use tournament selection to choose diffusion sources  
3. Spread importance to neighbors based on connectivity
4. Update STI values maintaining attention economy

### 3. Rent Collection Mechanisms

**Economic Attention Management:**
- Periodic rent collection from attention values
- Maintains finite attention resources (STI/LTI funds)
- Tournament selection for rent targets
- Funds returned to global attention pool

### 4. Enhanced Priority Calculation

**Multi-factor Priority Scores:**
```scheme
priority-score = STI + (0.1 × LTI) + (0.05 × VLTI) + 
                 (0.2 × kernel-complexity) + (100 × kernel-attention)
```

**Priority Levels:**
- `critical`: score > 200
- `high`: score > 150  
- `medium`: score > 100
- `low`: score > 50
- `minimal`: score ≤ 50

### 5. Goal-Based Attention Boosting

**Dynamic Goal Integration:**
- Reasoning: 0.9 boost factor
- Learning: 0.7 boost factor
- Attention: 0.85 boost factor
- Memory: 0.65 boost factor
- Adaptation: 0.75 boost factor

## Architecture Changes

### Before (Basic ECAN)
```scheme
;; Simple hardcoded attention scores
(define (attention-score-for-goal goal)
  (case goal
    ((reasoning) 0.9)
    ((learning) 0.7)
    (else 0.5)))
```

### After (Focused ECAN)
```scheme
;; Dynamic STI/LTI-based attention with diffusion
(define (ecan-allocate-attention! network goals)
  ;; 1. Perform attention diffusion
  (focused-attention-diffusion network)
  ;; 2. Collect rent to maintain economy  
  (rent-collection network)
  ;; 3. Apply goal-based boosts
  ;; 4. Calculate focused priorities
  ;; 5. Return enhanced allocation results
  ...)
```

## ECAN Parameters

The system uses realistic ECAN parameters based on OpenCog's attention system:

- **AF_MAX_SIZE**: 1000 (maximum attentional focus size)
- **AF_MIN_SIZE**: 500 (minimum attentional focus size)  
- **MAX_SPREAD_PERCENTAGE**: 0.4 (40% of STI can be spread)
- **DIFFUSION_TOURNAMENT_SIZE**: 5 (tournament size for diffusion)
- **RENT_TOURNAMENT_SIZE**: 5 (tournament size for rent collection)
- **TARGET_STI_FUNDS**: 10000 (global STI fund target)
- **TARGET_LTI_FUNDS**: 10000 (global LTI fund target)

## Performance Improvements

### Test Results Comparison

**Before (Basic):**
```
Allocation: 0.8 Priority: medium
Allocation: 0.6 Priority: low
```

**After (Focused):**
```
Allocation: 1.222115 Priority: critical  
Allocation: 0.711 Priority: critical
```

### Enhanced Features:

1. **Dynamic Attention Values**: STI/LTI values change based on usage and diffusion
2. **Neighbor Connectivity**: Kernels influence each other based on similarity
3. **Economic Constraints**: Limited attention resources create realistic competition
4. **Tournament Selection**: Probabilistic selection creates focused attention
5. **Multi-dimensional Priority**: Complex priority calculation considering multiple factors

## Usage Examples

### Basic Usage
```scheme
;; Create kernels with different characteristics
(define kernels (list 
  (spawn-cognitive-kernel '(128 128) 0.95)  ; High complexity, high attention
  (spawn-cognitive-kernel '(32 32) 0.6)     ; Low complexity, medium attention
  (spawn-cognitive-kernel '(64 64) 0.8)))   ; Medium complexity, high attention

;; Perform focused attention allocation
(define allocations (adaptive-attention-allocation kernels '(reasoning learning attention)))

;; Results include STI/LTI values and focused priorities
;; ((kernel . #<kernel>) (attention-score . 1.25) (activation-priority . critical) 
;;  (sti . 182) (lti . 45))
```

### Advanced Usage
```scheme
;; Create focused ECAN network directly
(define network (make-ecan-network))
(ecan-add-node! network kernel1)
(ecan-add-node! network kernel2)

;; Manual attention diffusion
(focused-attention-diffusion network)

;; Manual rent collection  
(rent-collection network)

;; Get final attention allocation
(define results (ecan-allocate-attention! network goals))
```

## Integration with Agent-Zero Genesis

The focused ECAN system integrates seamlessly with the Agent-Zero Genesis architecture:

- **Cognitive Kernels**: Tensor-based cognitive processing units
- **Meta-Cognition**: Self-reflective attention management
- **Hypergraph States**: AtomSpace-compatible attention representation
- **Goal-Driven Processing**: Dynamic attention based on cognitive goals

## Future Enhancements

1. **Hebbian Learning Integration**: Attention-based connection strengthening
2. **Real AtomSpace Integration**: Direct OpenCog AtomSpace connectivity
3. **Distributed Attention**: Multi-node attention sharing
4. **Adaptive Parameters**: Self-tuning ECAN parameters based on performance
5. **Attention Visualization**: Real-time attention flow visualization

## Conclusion

The focused ECAN attention allocation system transforms Agent-Zero from basic attention management to a sophisticated cognitive attention network. This implementation provides the foundation for realistic artificial general intelligence attention dynamics, supporting the Agent-Zero Genesis roadmap goals.

## References

- OpenCog ECAN Documentation: https://wiki.opencog.org/w/ECAN
- Agent-Zero Genesis Roadmap: `AGENT-ZERO-GENESIS.md`
- AttentionBank Implementation: `/attention/opencog/attention/`