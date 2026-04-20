# CMAN DRAM Traffic Analysis

## Given
- Matrix size: N = 32
- Tile size: T = 8
- Data type: FP32 = 4 bytes per element
- DRAM bandwidth = 320 GB/s
- Peak compute = 10 TFLOP/s

## 1. Naive triple loop (ijk order)

For one output element C[i][j], the inner loop runs over k = 0 to 31.

- A[i][k] is accessed 32 times total for one output element
- B[k][j] is accessed 32 times total for one output element

Each element of B is accessed 32 times across the full N×N output.

Across the full matrix multiply:

Total accesses to A:
N × N × N = 32^3 = 32,768 accesses

Total accesses to B:
N × N × N = 32^3 = 32,768 accesses

Total element reads:
32,768 + 32,768 = 65,536 reads

Total DRAM traffic for reads:
65,536 × 4 = 262,144 bytes

Output writes for C:
32 × 32 = 1,024 writes
1,024 × 4 = 4,096 bytes

Total naive DRAM traffic:
262,144 + 4,096 = 266,240 bytes

## 2. Tiled loop (tile size T = 8)

Number of tiles per dimension:
N / T = 32 / 8 = 4

For each output tile, we loop over 4 k-tiles.

Total output tiles:
4 × 4 = 16

For each output tile:
- 4 A tiles loaded
- 4 B tiles loaded

Each tile has:
8 × 8 = 64 elements
64 × 4 = 256 bytes

Total A tile loads:
16 × 4 = 64 tiles

Total B tile loads:
16 × 4 = 64 tiles

Total tile loads:
64 + 64 = 128 tiles

Total tiled DRAM traffic for reads:
128 × 256 = 32,768 bytes

Output writes for C:
1,024 × 4 = 4,096 bytes

Total tiled DRAM traffic:
32,768 + 4,096 = 36,864 bytes

## 3. Traffic ratio

Traffic ratio = naive / tiled
Traffic ratio = 266,240 / 36,864
Traffic ratio ≈ 7.22

Ignoring output writes, the main read traffic ratio is:

262,144 / 32,768 = 8

This equals the tile reuse benefit because each loaded tile is reused 8 times inside the tiled computation.

## 4. Execution time and bottleneck

### Naive case
Time = traffic / bandwidth
Time = 266,240 / (320 × 10^9)
Time ≈ 8.32 × 10^-7 s

FLOPs for matrix multiply:
2 × N^3 = 2 × 32^3 = 65,536 FLOPs

Compute time:
65,536 / (10 × 10^12)
≈ 6.55 × 10^-9 s

Naive bottleneck:
Memory-bound, because memory time is much larger than compute time.

### Tiled case
Time = 36,864 / (320 × 10^9)
Time ≈ 1.15 × 10^-7 s

Compute time is still:
≈ 6.55 × 10^-9 s

Tiled bottleneck:
Still memory-bound, but much closer to the ridge than the naive case.

## Final answer
- Naive DRAM traffic = 266,240 bytes
- Tiled DRAM traffic = 36,864 bytes
- Main read traffic ratio = 8
- Naive case is memory-bound
- Tiled case is also memory-bound, but improved
