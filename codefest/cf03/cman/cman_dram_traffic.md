# CMAN: DRAM Traffic Analysis for Naive vs Tiled Matrix Multiply
ECE 410/510 Codefest 3, HW4AI Spring 2026

N = 32, FP32 (4 bytes per element), tile size T = 8.

## Naive DRAM Traffic

In the naive triple loop each element of B is loaded from DRAM once per output row. There are N output rows so each element of B is read N times.

Accesses to A: N^3 element reads = 32,768 reads
Accesses to B: N^3 element reads = 32,768 reads

Traffic formula: 2 x N^3 x 4 bytes
Naive DRAM traffic = 2 x 32,768 x 4 = 262,144 bytes

## Tiled DRAM Traffic (T = 8)

With tiling each T x T block is loaded into shared memory once and reused T times. Each element of A and B is loaded from DRAM exactly once.

Traffic formula: 2 x N^2 x 4 bytes
Tiled DRAM traffic = 2 x 1,024 x 4 = 8,192 bytes

## Traffic Ratio

Ratio = Naive traffic / Tiled traffic = 262,144 / 8,192 = 32 = N

The ratio equals N (not N/T) because in the naive case each element of B is re-read N times total across all output rows. Tiling loads each element exactly once and reuses it within shared memory for all T rows in the tile. The total savings factor is N not the tile size T.

Algebraic derivation:
Ratio = (2 x N^3 x 4) / (2 x N^2 x 4) = N^3 / N^2 = N = 32

## Execution Times (bandwidth = 320 GB/s, compute = 10 TFLOPS)

Total FLOPs = 2 x N^3 = 2 x 32,768 = 65,536 FLOPs

Naive case:
t_memory = 262,144 / (320 x 10^9) = 0.819 microseconds
t_compute = 65,536 / (10 x 10^12) = 0.007 microseconds
Bottleneck: memory-bound. Execution time = 0.819 microseconds.

Tiled case:
t_memory = 8,192 / (320 x 10^9) = 0.026 microseconds
t_compute = 65,536 / (10 x 10^12) = 0.007 microseconds
Bottleneck: still memory-bound at N=32 but much closer. Execution time = 0.026 microseconds.

Speedup = 0.819 / 0.026 = 31.5x, which is approximately N = 32.
