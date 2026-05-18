# CMAN: Sparsity Breakeven Analysis
ECE 410/510 Codefest 7, HW4AI Spring 2026

N = 512. Sparsity s = fraction of zeros in weight matrix W.

## (a) Dense MVM Expressions

Dense compute (FLOPs):
Dense FLOPs = 2 x N^2 = 2 x 512^2 = 524,288 FLOPs

Dense memory (bytes):
Dense memory = N^2 x 4 bytes = 512^2 x 4 = 1,048,576 bytes = 1 MB

## (b) Sparse Compute as a Function of s

Only (1-s) fraction of weights are non-zero so only those MACs run:

Sparse FLOPs = 2 x N^2 x (1-s)

## (c) Sparse Memory as a Function of s

CSR format stores three arrays:
- Values array: N^2 x (1-s) entries x 4 bytes = 4 x N^2 x (1-s) bytes
- Column index array: N^2 x (1-s) entries x 4 bytes = 4 x N^2 x (1-s) bytes
- Row pointer array: (N+1) entries x 4 bytes = 4 x (N+1) bytes

Total sparse memory = 8 x N^2 x (1-s) + 4 x (N+1) bytes

## (d) FLOPs Speedup and 2x Breakeven

FLOPs speedup = Dense FLOPs / Sparse FLOPs = 1 / (1-s)

For 2x speedup:
1 / (1-s) = 2
1-s = 0.5
s = 0.5

Sparsity must be at least 50% to get 2x FLOPs speedup.

## (e) Memory Breakeven Sparsity

Set sparse memory equal to dense memory and solve for s:

8 x N^2 x (1-s) + 4 x (N+1) = 4 x N^2

For N = 512:
8 x 262,144 x (1-s) + 2,052 = 1,048,576
2,097,152 x (1-s) = 1,046,524
(1-s) = 0.499
s = 0.501

Memory breakeven sparsity is about 50%.

Derivation:
8 x N^2 x (1-s) = 4 x N^2 - 4 x (N+1)
(1-s) = [N^2 - (N+1)] / (2 x N^2)
s = 1 - [N^2 - N - 1] / (2 x N^2)

For large N this simplifies to s = 0.5.

Above s = 0.5 sparse CSR uses less memory than dense.

## (f) End-to-End Speedup at s=0.9, Memory-Bandwidth-Limited System (320 GB/s)

At s = 0.9 and N = 512:

Dense memory = 1,048,576 bytes

Sparse memory = 8 x 262,144 x 0.1 + 4 x 513
             = 209,715 + 2,052
             = 211,767 bytes

Dense time  = 1,048,576 / (320 x 10^9) = 3.277 microseconds
Sparse time = 211,767 / (320 x 10^9) = 0.662 microseconds

End-to-end speedup = 3.277 / 0.662 = 4.95x

At 90% sparsity the sparse format is about 5x faster than dense for a memory-bandwidth-limited system.
