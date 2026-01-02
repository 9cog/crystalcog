;; PLN Reasoning Module Usage Example
;; /examples/agent-zero-pln-usage.scm

;; This example demonstrates how to use the PLN reasoning module
;; in the Agent-Zero Genesis cognitive architecture

(use-modules (agent-zero kernel)
             (agent-zero meta-cognition)
             (agent-zero pln-reasoning))

;; Example 1: Basic PLN Reasoning
(define example-basic-pln-reasoning
  (lambda ()
    (display "=== Basic PLN Reasoning Example ===\n")
    
    ;; Create a PLN reasoner
    (let ((reasoner (make-pln-reasoner)))
      
      ;; Add some knowledge
      (pln-add-knowledge reasoner 'intelligent-agent (cons 0.9 0.85))
      (pln-add-knowledge reasoner 'learning-capable (cons 0.8 0.9))
      (pln-add-knowledge reasoner 'adaptive-behavior (cons 0.85 0.8))
      
      ;; Perform backward chaining
      (let ((result (pln-query reasoner 'backward-chain 'intelligent-agent)))
        (display "PLN Backward Chaining Result:\n")
        (display result)
        (newline)))))

;; Example 2: Cognitive Integration
(define example-cognitive-integration
  (lambda ()
    (display "\n=== Cognitive Integration Example ===\n")
    
    ;; Create a cognitive kernel
    (let ((kernel (spawn-cognitive-kernel '(64 32) 0.8)))
      
      ;; Perform meta-cognitive reflection using PLN
      (let ((reflection (meta-cognitive-reflection kernel)))
        (display "Meta-Cognitive Reflection with PLN:\n")
        (display "Current State: ")
        (display (assoc-ref reflection 'current-state))
        (newline)
        (display "Self Assessment: ")
        (display (assoc-ref reflection 'self-assessment))
        (newline)
        (display "Confidence Level: ")
        (display (assoc-ref reflection 'confidence-level))
        (newline)))))

;; Example 3: Knowledge-based Reasoning
(define example-knowledge-reasoning
  (lambda ()
    (display "\n=== Knowledge-based Reasoning Example ===\n")
    
    ;; Define cognitive state
    (let ((cognitive-state '((agent-active . #t)
                            (learning-enabled . #t)
                            (reasoning-mode . analytical)
                            (attention-level . 0.85))))
      
      ;; Perform cognitive PLN reasoning
      (let ((result (cognitive-pln-reasoning cognitive-state 'intelligent-behavior)))
        (display "Cognitive PLN Reasoning Result:\n")
        (display result)
        (newline)))))

;; Example 4: Multi-kernel Attention Allocation with PLN
(define example-multi-kernel-attention
  (lambda ()
    (display "\n=== Multi-kernel Attention with PLN Example ===\n")
    
    ;; Create multiple cognitive kernels
    (let ((kernel1 (spawn-cognitive-kernel '(32 32) 0.9))
          (kernel2 (spawn-cognitive-kernel '(64 32) 0.7))
          (kernel3 (spawn-cognitive-kernel '(16 16) 0.5)))
      
      ;; Use adaptive attention allocation with PLN reasoning
      (let ((allocations (adaptive-attention-allocation 
                         (list kernel1 kernel2 kernel3)
                         '(reasoning learning adaptation))))
        (display "Attention Allocation Results:\n")
        (for-each (lambda (alloc)
                    (display "Kernel: ")
                    (display (assoc-ref alloc 'kernel))
                    (display ", Priority: ")
                    (display (assoc-ref alloc 'activation-priority))
                    (newline))
                  allocations)))))

;; Example 5: Advanced PLN Integration
(define example-advanced-pln-integration
  (lambda ()
    (display "\n=== Advanced PLN Integration Example ===\n")
    
    ;; Create atomspace with knowledge
    (let ((atomspace (make-atomspace)))
      ;; Add facts to atomspace
      (hash-set! atomspace 'human-intelligence (cons 0.95 0.9))
      (hash-set! atomspace 'machine-reasoning (cons 0.85 0.8))
      (hash-set! atomspace 'cognitive-synthesis (cons 0.8 0.85))
      
      ;; Perform integrated PLN reasoning
      (let ((bc-result (pln-backward-chaining atomspace 'human-intelligence))
            (fc-result (pln-forward-chaining atomspace '(machine-reasoning))))
        
        (display "Backward Chaining on AtomSpace:\n")
        (display bc-result)
        (newline)
        (display "Forward Chaining on AtomSpace:\n")
        (display fc-result)
        (newline)))))

;; Run all examples
(define run-all-examples
  (lambda ()
    (display "Agent-Zero PLN Reasoning Module Examples\n")
    (display "=========================================\n")
    
    (example-basic-pln-reasoning)
    (example-cognitive-integration)
    (example-knowledge-reasoning)
    (example-multi-kernel-attention)
    (example-advanced-pln-integration)
    
    (display "\n=== Examples Complete ===\n")))

;; Uncomment the following line to run examples when loaded
;; (run-all-examples)