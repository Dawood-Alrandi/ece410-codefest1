# Arithmetic Intensity Calculation

## Dominant kernel

The full training routine `cnn.py:train` takes about 71.5% of total runtime, because it uses 2.018 seconds out of 2.821 seconds in the profiler output. For roofline analysis, the dominant computational kernel is `Conv2D._im2col` in `cnn.py:91`, because the assignment appendix identifies `_im2col` as the main CNN bottleneck. :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}

## Kernel description

`Conv2D._im2col` builds the column matrix used by the convolution forward pass. In this project, the CNN uses the small config with `conv_layers = [(8, 3, 1)]`, `batch_size = 32`, and `input_shape = (1, 16, 16)`. The convolution code computes `H_out = H - k + 2p + 1` and `W_out = W - k + 2p + 1`, so with `H = 16`, `W = 16`, `k = 3`, and `p = 1`, we get `H_out = 16` and `W_out = 16`. :contentReference[oaicite:2]{index=2} :contentReference[oaicite:3]{index=3} :contentReference[oaicite:4]{index=4}

## FLOPs

For one forward pass through a Conv2D layer, the assignment appendix gives:

FLOPs = 2 × N × C_in × k^2 × H_out × W_out × C_out :contentReference[oaicite:5]{index=5}

From this project:
- N = 32
- C_in = 1
- k = 3
- H_out = 16
- W_out = 16
- C_out = 8 :contentReference[oaicite:6]{index=6} :contentReference[oaicite:7]{index=7}

Substitute values:

FLOPs = 2 × 32 × 1 × 3^2 × 16 × 16 × 8  
FLOPs = 2 × 32 × 1 × 9 × 16 × 16 × 8  
FLOPs = 1,179,648 FLOPs

## Bytes transferred

The appendix says to estimate bytes with no reuse by loading the input patch, the weights, and storing the output, each in FP64, which is 8 bytes per value. :contentReference[oaicite:8]{index=8}

Input bytes = N × C_in × k^2 × H_out × W_out × 8  
Input bytes = 32 × 1 × 9 × 16 × 16 × 8  
Input bytes = 589,824 bytes

Weight bytes = C_out × C_in × k^2 × 8  
Weight bytes = 8 × 1 × 9 × 8  
Weight bytes = 576 bytes

Output bytes = N × C_out × H_out × W_out × 8  
Output bytes = 32 × 8 × 16 × 16 × 8  
Output bytes = 524,288 bytes

Total bytes = 589,824 + 576 + 524,288  
Total bytes = 1,114,688 bytes

## Arithmetic intensity

AI = FLOPs / Bytes  
AI = 1,179,648 / 1,114,688  
AI ≈ 1.06 FLOP/byte

## Bound classification

This kernel has low arithmetic intensity, so it is memory-bound on current hardware. The profiler output and assignment appendix both support focusing on this kernel for roofline analysis and hardware acceleration discussion. :contentReference[oaicite:9]{index=9} :contentReference[oaicite:10]{index=10}
