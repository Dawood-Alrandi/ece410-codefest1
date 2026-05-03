# Heilmeier Catechism — Project Draft

## Q1: What are you trying to do? Articulate your objectives using absolutely no jargon.

I am building a hardware accelerator for the most computationally expensive part of running a neural network: the multiply-accumulate (MAC) operations in convolutional layers. Today, running image-recognition models on edge devices (phones, cameras, embedded systems) is slow and burns a lot of battery because general-purpose processors are not designed specifically for this repetitive computation. My goal is to design a dedicated piece of hardware that performs this one operation extremely efficiently, so that inference can run faster and use far less energy than a general-purpose CPU or GPU.

## Q2: How is it done today, and what are the limits of the current approach?

Currently, inference on edge devices is handled either by general-purpose CPUs, mobile GPUs, or commercial AI accelerator chips (e.g., Google Edge TPU, Apple Neural Engine). General-purpose CPUs are flexible but waste energy executing instructions that are not relevant to the tight multiply-accumulate loop at the heart of convolution. Profiling a CNN backpropagation implementation (Conv2D._im2col kernel) shows that a single convolutional layer dominates total runtime and has an arithmetic intensity well below the hardware ridge point when all data is loaded from DRAM — meaning the workload is severely memory-bandwidth-limited. Commercial accelerators improve this but are expensive, proprietary, and not reconfigurable for research experimentation.

## Q3: What is your approach, and why do you think it will work?

My approach is to design a pipelined INT8 systolic-array MAC unit in synthesizable SystemVerilog. By using INT8 fixed-point arithmetic instead of FP32, I reduce the data width by 4×, directly cutting DRAM bandwidth demand by 4× and increasing arithmetic intensity by the same factor. A systolic array architecture maximizes data reuse: weights and activations flow through a grid of MAC elements, each element performing one multiply-accumulate per clock and passing data to its neighbor, eliminating redundant DRAM accesses. This approach is proven effective in hardware (Google's TPU uses a 256×256 systolic array), and at small scale it is implementable and verifiable with open-source tools (Yosys, Icarus Verilog). The arithmetic intensity improvement from INT8 + tiling is expected to push the dominant kernel from memory-bound to closer to the compute ceiling, yielding significant throughput gains over a CPU baseline.
