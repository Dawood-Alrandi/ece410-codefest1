# Software Baseline

## Platform
CPU-based execution using Python and NumPy.

## Runtime
From profiling results, total execution time is approximately 2.821 seconds for the training run.

## Throughput
Throughput is limited due to the Python loop-based implementation, especially in convolution data preparation.

## Memory Usage
The implementation uses DRAM for storing inputs, weights, and outputs. Data is frequently moved between memory and compute, which reduces efficiency.

## Bottleneck
The dominant bottleneck is the `_im2col` function, which performs data rearrangement for convolution. This function has arithmetic intensity of about 1.06 FLOP/byte, so the system is memory-bound.
