# CMAN: Workload Accounting for a 3-Layer Fully Connected Network
ECE 410/510 Codefest 1, HW4AI Spring 2026

Network: input=784, hidden1=256, hidden2=128, output=10. Batch size=1. FP32 weights. No biases.

## MACs Per Layer

Layer 1 (784 to 256): 784 x 256 = 200,704 MACs
Layer 2 (256 to 128): 256 x 128 = 32,768 MACs
Layer 3 (128 to 10): 128 x 10 = 1,280 MACs

Total MACs = 200,704 + 32,768 + 1,280 = 234,752 MACs

## Total Parameters (weights only, no biases)

Same formula as MACs: 234,752 parameters

## Weight Memory (FP32 = 4 bytes per element)

234,752 x 4 = 939,008 bytes (about 917 KB)

## Activation Memory (FP32 = 4 bytes per element)

Input layer: 784 x 4 = 3,136 bytes
Layer 1 output: 256 x 4 = 1,024 bytes
Layer 2 output: 128 x 4 = 512 bytes
Layer 3 output: 10 x 4 = 40 bytes
Total = 4,712 bytes

## Arithmetic Intensity

FLOPs = 2 x 234,752 = 469,504
Total bytes = 939,008 + 4,712 = 943,720
AI = 469,504 / 943,720 = 0.497 FLOP/byte

Ridge point = 10,000 GFLOP/s / 320 GB/s = 31.25 FLOP/byte
Since 0.497 is well below 31.25 this network is memory-bandwidth-bound.
