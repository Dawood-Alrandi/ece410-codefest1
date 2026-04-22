# CMAN — DRAM Traffic Analysis: Naive vs. Tiled Matrix Multiply

## Given
- Matrix size: N = 32
- Tile size: T = 8
- Data type: FP32 = 4 bytes per element
- DRAM bandwidth = 320 GB/s
- Peak compute = 10 TFLOP/s

---

## 1. Naive Triple Loop (ijk order)

For computing one output element C[i][j] = Σ A[i][k] × B[k][j]:

- The inner loop runs k = 0 to N−1 (32 iterations)
- Each element of B[k][j] is accessed N = 32 times (once for every output row i)
- Each element of A[i][k] is accessed N = 32 times (once for every output column j)

**Total element accesses:**

A: N × N × N = 32 × 32 × 32 = 32,768 element reads  
B: N × N × N = 32 × 32 × 32 = 32,768 element reads  
C (writes): N × N = 1,024 writes

**Total DRAM traffic:**

= (32,768 + 32,768 + 1,024) × 4 bytes  
= 66,560 × 4  
= **266,240 bytes**

---

## 2. Tiled Loop (tile size T = 8)

Tiles per dimension: N / T = 32 / 8 = 4

For each (i-tile, j-tile) output pair, we loop over 4 k-tiles,
loading one A-tile and one B-tile per step into shared memory.

Total A tile loads: (N/T)³ = 4³ = 64 tiles  
Total B tile loads: 64 tiles  
Each tile size = T × T × 4 = 8 × 8 × 4 = 256 bytes

**Total DRAM traffic (reads):**

A reads: 64 × 256 = 16,384 bytes  
B reads: 64 × 256 = 16,384 bytes  
C writes: 1,024 × 4 = 4,096 bytes

**Total tiled DRAM traffic = 16,384 + 16,384 + 4,096 = 36,864 bytes**

---

## 3. Traffic Ratio

Read-only traffic ratio:

Naive reads = (32,768 + 32,768) × 4 = 262,144 bytes  
Tiled reads  = (16,384 + 16,384)    = 32,768 bytes

Ratio = 262,144 / 32,768 = **N = 32**

This ratio equals N because in the naive case every matrix element is loaded from DRAM N times (no reuse), while tiling loads each element exactly once and reuses it T times inside shared memory, so the total traffic reduction factor is N/1 = N.

---

## 4. Execution Time and Bottleneck

**FLOPs:** 2 × N³ = 2 × 32³ = 65,536 FLOPs

### Naive case

Memory time  = 266,240 / (320 × 10⁹) = **8.32 × 10⁻⁷ s**  
Compute time = 65,536 / (10 × 10¹²)  = **6.55 × 10⁻⁹ s**  
→ Memory time ≫ Compute time → **Memory-bound**

### Tiled case

Memory time  = 36,864 / (320 × 10⁹) = **1.15 × 10⁻⁷ s**  
Compute time = 65,536 / (10 × 10¹²) = **6.55 × 10⁻⁹ s**  
→ Memory time still > Compute time → **Memory-bound (but 7× closer to ridge than naive)**

---

## Summary

| Case  | DRAM Traffic | Time         | Bottleneck   |
|-------|-------------|--------------|--------------|
| Naive | 266,240 B   | 8.32 × 10⁻⁷ s | Memory-bound |
| Tiled | 36,864 B    | 1.15 × 10⁻⁷ s | Memory-bound (improved) |

**Traffic ratio (reads) = N = 32**
