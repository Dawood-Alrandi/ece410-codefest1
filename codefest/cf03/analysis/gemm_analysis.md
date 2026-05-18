# GEMM Analysis: Naive vs Tiled CUDA Kernels
ECE 410/510 Codefest 3, HW4AI Spring 2026

## Why the Naive Kernel is Memory-Bound

The naive GEMM kernel assigns one thread to compute one output element C[i][j]. Each thread independently reads an entire row of A and an entire column of B from global memory. The problem is that B is accessed column by column which is non-coalesced on a GPU. Adjacent threads in a warp read memory locations that are N x 4 = 4096 bytes apart, so the GPU has to issue many separate memory transactions instead of one coalesced 128-byte read. This makes the effective arithmetic intensity very low, around 0.25 FLOP per byte, which is far below the RTX 3060 ridge point of about 35 FLOP per byte. From Nsight Compute profiling the naive kernel achieves approximately 180 GFLOP/s which is only about 1.4% of the 12,700 GFLOP/s peak. The kernel is almost entirely waiting on memory.

## How Tiling Reduces DRAM Traffic

The tiled kernel loads T x T blocks of A and B into shared memory before computing. Each thread in the block reuses the shared memory data T times before the next tile is fetched. Because all threads in a warp load adjacent elements of A and B the access pattern is coalesced, meaning the GPU can issue efficient 128-byte transactions. Total DRAM traffic drops from 2 x N^3 x 4 bytes to 2 x N^2 x 4 bytes, a factor of N reduction. With T=8 the tiled kernel achieves approximately 1,200 GFLOP/s from Nsight Compute profiling, which is about 6.7x faster than the naive version.

## Remaining Bottleneck After Tiling

With T=8 the kernel still does not hit peak compute. Nsight Compute shows the bottleneck has shifted but the effective arithmetic intensity is still only about 8 FLOP per byte, which is below the ridge point of 35 FLOP per byte. The main remaining problem is that with only 64 threads per block (T x T = 8 x 8) there are not enough warps to hide memory latency. The GPU cannot keep its compute units busy because each block finishes too quickly and there is not enough parallelism to overlap memory loads with computation. To fix this a larger tile size like T=32 would increase both arithmetic intensity and occupancy, moving the kernel much closer to the compute ceiling.
