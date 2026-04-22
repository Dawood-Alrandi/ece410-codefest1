# GEMM Analysis: Naive vs. Tiled Kernel

## (a) Why the Naive Kernel is Memory-Bound

The naive GEMM kernel assigns one thread per output element C[i][j]. Each thread independently computes a dot product over K=1024 elements, loading every value directly from global DRAM memory. For a 1024×1024 matrix, each element of A is read 1024 times (once per output column) and each element of B is read 1024 times (once per output row). This produces N³ = 1,073,741,824 total element reads with zero data reuse, resulting in roughly 8 GB of DRAM traffic for a single multiply. The arithmetic intensity is only 2×N³ FLOPs / (2×N²×4 bytes) = N/4 ≈ 256 FLOP/byte — but in practice far lower because accesses are not coalesced for B (column-major access pattern on a row-major stored matrix). This puts the naive kernel deep in the memory-bound region of the roofline, far below the ridge point, achieving only a small fraction of the GPU's peak compute throughput.

## (b) How Tiling Reduces DRAM Traffic

The tiled kernel loads a T×T block of A and T×T block of B into shared memory (SRAM) once per tile step, then all T² threads in the block compute their partial sums reusing that shared data — no DRAM access needed until the next tile. Each element of A and B is therefore loaded from DRAM exactly once across the full computation instead of N times. This reduces total DRAM read traffic by a factor of N (from N³ to N² element reads per matrix), increasing arithmetic intensity from roughly 0.25 FLOP/byte (naive) to approximately 10+ FLOP/byte (tiled with T=8), moving the operating point significantly rightward on the roofline toward the ridge point.

## (c) Whether the Tiled Kernel Achieved the Expected Improvement

The tiled kernel achieved substantially higher GFLOP/s than the naive kernel, confirming that reducing DRAM traffic improves performance as predicted by the roofline model. However, the tiled kernel with T=8 did not fully reach the compute-bound region. The remaining bottleneck is the tile size: with T=8, each thread block only holds 8×8=64 elements per matrix per tile, which limits the reuse factor and leaves shared memory underutilized. A larger tile size (T=16 or T=32) would increase arithmetic intensity further and push performance closer to the compute ceiling. Additionally, uncoalesced global memory access patterns and lack of prefetching contribute to remaining memory overhead even in the tiled version.
