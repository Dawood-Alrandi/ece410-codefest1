# CMAN — Workload accounting by hand

Network: 784 → 256 → 128 → 10  
Batch size: 1  
FP32 = 4 bytes  
No bias terms

## 1. MACs

Layer 1: 784 × 256 = 200,704  
Layer 2: 256 × 128 = 32,768  
Layer 3: 128 × 10 = 1,280  

## 2. Total MACs

234,752

## 3. Parameters

234,752

## 4. Weight memory

234,752 × 4 = 939,008 bytes

## 5. Activation memory

(784 + 256 + 128 + 10) × 4 = 4,712 bytes

## 6. Arithmetic intensity

(2 × 234,752) / (939,008 + 4,712) = 0.498 FLOP/byte
