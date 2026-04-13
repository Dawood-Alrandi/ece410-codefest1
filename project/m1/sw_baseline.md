# Software Baseline

## Platform and Configuration
- Host platform: Desktop system
- CPU: Intel Core i7-14700KF (3.40 GHz)
- RAM: 32 GB
- Architecture: 64-bit x86
- Software stack: Python + NumPy
- Operating system: Windows

## CNN Configuration
- Input shape: (1, 16, 16)
- Convolution layers: [(8, 3, 1)]
- Dense layers: [64]
- Number of classes: 10
- Batch size: 32
- Epochs: 5

## Execution Time
From profiling results, the total runtime is approximately 2.821 seconds for the training run.

## Throughput
The system processes 2000 samples in about 2.821 seconds.

Throughput = 2000 / 2.821  
Throughput ≈ 709 samples/second  

## Memory Usage
The implementation uses DRAM to store inputs, weights, and intermediate outputs. Data movement between memory and compute is frequent due to the structure of convolution operations.

## Bottleneck
The dominant kernel is `Conv2D._im2col`. The training function takes about 71.5% of total runtime, making it the main bottleneck. The arithmetic intensity is about 1.06 FLOP/byte, which means the system is memory-bound.
