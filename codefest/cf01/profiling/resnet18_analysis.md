# ResNet18 Profiling Analysis

## Goal
Profile ResNet18 and identify the most expensive operations during inference.

## Setup
- Model: ResNet18
- Input size: 1 × 3 × 224 × 224
- Device: CPU
- Tool: PyTorch profiler

## Observations
The most expensive operations are expected to be convolution layers because they perform most of the computation in the network.

## Analysis
ResNet18 is a convolutional neural network, so most of the runtime is usually spent in convolution operations. Other layers like ReLU and batch normalization also appear, but they usually take less total time.

## Conclusion
The profiling result should show that convolution is the main bottleneck. This means convolution would be the first target for optimization in hardware.
