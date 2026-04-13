# Arithmetic Intensity Calculation

## Dominant kernel

The full training routine `cnn.py:train` takes about 71.5% of total runtime, because it uses 2.018 seconds out of 2.821 seconds in the profiler output. For roofline analysis, the dominant computational kernel is `Conv2D._im2col` in `cnn.py:91`, because the assignment identifies `_im2col` as the main CNN bottleneck.

## Kernel description

`Conv2D._im2col` builds the column matrix used by the convolution forward pass. In this project, the CNN uses the config `conv_layers = [(8, 3, 1)]`, `batch_size = 32`, and `input_shape = (1, 16, 16)`. Using the convolution formula:

H_out = H - k + 2p + 1  
W_out = W - k + 2p + 1  

With H = 16, W = 16, k = 3, p = 1:

H_out = 16  
W_out = 16  

## FLOPs

FLOPs = 2 × N × C_in × k^2 × H_out × W_out × C_out  

From this project:
- N = 32  
- C_in = 1  
- k = 3  
- H_out = 16  
- W_out = 16  
- C_out = 8  

Substitute values:

FLOPs = 2 × 32 × 1 × 3^2 × 16 × 16 × 8  
FLOPs = 2 × 32 × 1 × 9 × 16 × 16 × 8  
FLOPs = 1,179,648 FLOPs  

## Bytes transferred

Assuming no reuse from DRAM and FP64 (8 bytes per value):

Input bytes = N × C_in × k^2 × H_out × W_out × 8  
= 32 × 1 × 9 × 16 × 16 × 8  
= 589,824 bytes  

Weight bytes = C_out × C_in × k^2 × 8  
= 8 × 1 × 9 × 8  
= 576 bytes  

Output bytes = N × C_out × H_out × W_out × 8  
= 32 × 8 × 16 × 16 × 8  
= 524,288 bytes  

Total bytes = 589,824 + 576 + 524,288  
Total bytes = 1,114,688 bytes  

## Arithmetic intensity

AI = FLOPs / Bytes  
AI = 1,179,648 / 1,114,688  
AI ≈ 1.06 FLOP/byte  

## Bound classification

This kernel has low arithmetic intensity, so it is memory-bound on current hardware.
