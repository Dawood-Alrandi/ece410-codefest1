# HW/SW Partition Rationale

I will accelerate the convolution data preparation kernel, specifically `Conv2D._im2col`, in hardware. The profiler shows that training is dominated by the CNN execution path, and the arithmetic intensity result shows that this kernel has low arithmetic intensity, about 1.06 FLOP/byte. That means the current implementation is memory-bound on my platform, so improving only software will not be enough. The roofline result supports focusing on this kernel because it sits in the bandwidth-limited region and does not come close to the compute ceiling.

The software baseline will continue to handle the rest of the training flow, including dataset generation, control flow, loss calculation, gradient bookkeeping, and optimizer updates. Those parts are easier to keep in software because they are less regular and do not benefit as much from fixed hardware. The hardware block will focus only on the repeated convolution data movement and preparation work that happens every training step.

To avoid the accelerator becoming interface-bound, the interface must support enough bandwidth for the target operating point. If the accelerator target is about 80 GFLOP/s and the kernel arithmetic intensity is about 1.06 FLOP/byte, then the required bandwidth is about 80 / 1.06 = 75.5 GB/s. This means a very low-bandwidth interface would bottleneck the design, so the accelerator would need a high-throughput interface and strong on-chip memory support.

On the current hardware, this kernel is memory-bound. My proposed accelerator may reduce this problem by increasing local data reuse and reducing repeated DRAM traffic. Even so, bandwidth remains a major design concern, so the accelerator must be designed with both compute throughput and data movement in mind.
