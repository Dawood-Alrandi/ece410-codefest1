# Heilmeier Questions

## 1. What are you trying to do?
Design a simple neural network accelerator using a fully connected model (784 → 256 → 128 → 10).

## 2. How is it done today, and what are the limits?
Today, models are run in software using frameworks like PyTorch. This hides hardware cost and is not optimized for memory movement and efficiency.

## 3. What is new in your approach?
Use a small network that can be fully analyzed in terms of MACs, parameters, memory, and arithmetic intensity.

## 4. Who cares?
Students and engineers interested in AI hardware and efficient computation.

## 5. If successful, what difference will it make?
It will help connect neural network computation to hardware design decisions.

## 6. What are the risks?
The model is simple and may not represent large-scale AI systems.

## 7. How much will it cost?
Low cost, mainly time and computation.

## 8. How long will it take?
Short time for analysis, longer if implemented in hardware.

## 9. What are the midterm and final checks?
Midterm: complete analysis and profiling  
Final: map model to hardware and optimize performance
