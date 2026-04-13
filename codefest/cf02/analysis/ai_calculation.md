# Arithmetic Intensity Calculation

## Dominant Kernel
The dominant kernel is `Conv2D._im2col`, which accounts for the largest share of the runtime in the CNN with manual backpropagation implementation.

## FLOPs Calculation
For one forward pass through a Conv2D layer:

FLOPs = 2 × N × C_in × k² × H_out × W_out × C_out

Using:
- N = 1
- C_in = 3
- k = 3
- H_out = 7
- W_out = 7
- C_out = 512

FLOPs = 2 × 1 × 3 × 3² × 7 × 7 × 512  
FLOPs = 2 × 1 × 3 × 9 × 7 × 7 × 512  
FLOPs = 1,354,752

## Bytes Transferred (no reuse, FP64)
Input patch bytes:
N × C_in × k² × H_out × W_out × 8  
= 1 × 3 × 9 × 7 × 7 × 8  
= 10,584 bytes

Weights bytes:
C_out × C_in × k² × 8  
= 512 × 3 × 9 × 8  
= 110,592 bytes

Output bytes:
N × C_out × H_out × W_out × 8  
= 1 × 512 × 7 × 7 × 8  
= 200,704 bytes

Total bytes = 10,584 + 110,592 + 200,704  
Total bytes = 321,880 bytes

## Arithmetic Intensity
AI = FLOPs / Bytes  
AI = 1,354,752 / 321,880  
AI ≈ 4.21 FLOP/byte

## Runtime Share
The dominant kernel is `Conv2D._im2col`, accounting for the largest share of the total runtime based on the profiling results.
