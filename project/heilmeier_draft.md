# Heilmeier Catechism — Project Draft (First 3 Questions)

## Q1: What are you trying to do?

I am trying to accelerate the convolution operation in a Convolutional Neural Network (CNN) using a dedicated hardware accelerator. Specifically, I am targeting the `im2col` (image-to-column) transformation, which is the dominant bottleneck in CNN inference and training. This function rearranges input feature map data into a format that allows convolution to be computed as a General Matrix Multiply (GEMM). From profiling, this step accounts for over 70% of total runtime, making it the highest-value target for hardware acceleration.

## Q2: How is it done today and what are the limits?

Today the CNN is implemented entirely in software using NumPy and Python. The `im2col` function is written using nested Python loops, which execute serially on a CPU. Profiling shows that the training function consumes approximately 71.5% of total execution time. The arithmetic intensity of the kernel is about 1.06 FLOP/byte, placing it firmly in the memory-bound region of the roofline model. This means that simply adding more compute (e.g., faster CPU clock) will not improve performance — the bottleneck is data movement, not computation. Python's interpreted overhead and lack of parallelism further limit throughput, making software-only optimization insufficient for real-time or embedded deployment.

## Q3: What is new in your approach?

My approach replaces the software `im2col` kernel with a dedicated hardware accelerator implemented in HDL (e.g., PyRTL or Verilog). The hardware design will use a local SRAM scratchpad sized to hold one full tile of input data, eliminating redundant DRAM loads by reusing data within the tile. This directly addresses the memory-bandwidth bottleneck identified in profiling. Unlike a GPU solution (which requires expensive hardware and high power), the target is a chiplet-style accelerator that is power-efficient and tightly integrated with the memory system. The roofline model guides the design: by increasing data reuse per DRAM byte loaded, the accelerator moves the operating point from the memory-bound slope toward the compute-bound plateau.
