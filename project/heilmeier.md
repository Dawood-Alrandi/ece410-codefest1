# Heilmeier Questions

## Q1: What are you trying to do?
I am trying to improve the performance of a convolutional neural network by accelerating the main bottleneck in the training process. From profiling results, the dominant kernel is the convolution data preparation step, specifically the `_im2col` function. This function is responsible for rearranging input data for convolution and is executed many times during training, making it a key target for optimization.

## Q2: How is it done today and what are the limits?
Currently, the CNN is implemented fully in software using NumPy. The `_im2col` function is written using Python loops, which makes it slow and inefficient. From the profiling results, the training function takes about 71.5% of total runtime, showing that the system is heavily bottlenecked. The arithmetic intensity of the kernel is about 1.06 FLOP/byte, which means the system is memory-bound. This limits performance because increasing compute power alone will not significantly improve speed.

## Q3: What is new in your approach?
My approach is to accelerate the `_im2col` kernel using hardware. By moving this computation to a dedicated hardware accelerator, I can reduce execution time and improve data movement efficiency. The roofline model shows that this kernel is limited by memory bandwidth, so the hardware design will focus on increasing data reuse and reducing memory traffic. This will allow the system to move closer to the compute roof and achieve higher performance compared to the current software-only implementation.

## Q4: Who cares?
Improving the performance of CNN training is important for many real-world applications such as image recognition, AI systems, and embedded devices. Faster training allows for quicker model development and more efficient deployment, especially in systems with limited resources.

## Q5: What are the risks?
The main risks include the complexity of hardware design and ensuring that the accelerator has enough memory bandwidth to avoid becoming the new bottleneck. If not designed properly, the hardware may not provide significant performance improvements.

## Q6: How much will it cost?
The cost depends on the hardware platform used, including FPGA or ASIC implementation. Additional costs include development time, testing, and integration with the existing software system.

## Q7: How long will it take?
The project can be completed in phases, starting with profiling and analysis, followed by design and implementation of the hardware accelerator, and finally testing and optimization. A rough estimate would be several weeks depending on complexity.
