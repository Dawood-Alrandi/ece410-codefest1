# CMAN: Arithmetic Intensity of Project Kernel from First Principles
ECE 410/510 Codefest 9, HW4AI Spring 2026

## Task 1: Dominant Kernel

The dominant kernel in my accelerator is a single-lane INT8 multiply-accumulate (MAC) operation.

Kernel: dot product of one input vector with one weight column.
Dimensions: input vector a[7:0] (INT8, signed), weight b[7:0] (INT8, signed), accumulator out[31:0] (INT32, signed).
Operating point: 1 MAC per clock cycle at 100 MHz. One invocation = 1 multiply and 1 add.

## Task 2: Total FLOPs

One invocation of the kernel performs:
1 multiply: a x b = 1 FLOP
1 add: acc += product = 1 FLOP
Total FLOPs per invocation = 2 FLOPs = 1 MAC

For a full Conv2D._im2col layer (the M1 dominant kernel) with 234,752 MACs:
Total FLOPs = 2 x 234,752 = 469,504 FLOPs

## Task 3: Arithmetic Intensity Bounds

### Lower Bound (no data reuse)

Every weight and activation is loaded fresh from off-chip memory for each MAC.

Bytes transferred:
Weight bytes: 234,752 x 1 byte (INT8) = 234,752 bytes
Activation bytes: 234,752 x 1 byte (INT8) = 234,752 bytes
Output bytes: output size x 4 bytes (INT32) = 1,280 x 4 = 5,120 bytes
Total bytes (no reuse) = 234,752 + 234,752 + 5,120 = 474,624 bytes

AI lower bound = 469,504 / 474,624 = 0.989 FLOP/byte

### Upper Bound (perfect on-chip weight reuse)

Weights are loaded once and reused for all input activations. Only activations stream in.

Weight bytes (loaded once): 234,752 x 1 = 234,752 bytes
Activation bytes (streamed): 234,752 x 1 = 234,752 bytes (same size)
Output bytes: 5,120 bytes

Wait, for a weight-stationary systolic array the weights stay fixed and only activations and outputs move:
Bytes (weight reuse) = activation bytes + output bytes = 234,752 + 5,120 = 239,872 bytes

AI upper bound = 469,504 / 239,872 = 1.957 FLOP/byte

The weight-reuse pattern is weight-stationary. Each weight is loaded once and used for all activations in the batch.

## Task 4: Roofline Sketch

Target synthesis platform: sky130 PDK nominal figures
Peak compute: 100 MHz x 1 MAC/cycle x 2 FLOP/MAC = 200 MFLOP/s = 0.2 GFLOP/s
Memory bandwidth: PCIe register-map interface, effective bandwidth = 100 MB/s = 0.8 Gbit/s

Ridge point = Peak compute / Bandwidth = 0.2 GFLOP/s / 0.1 GB/s = 2.0 FLOP/byte

My kernel AI lower bound = 0.989 FLOP/byte (below ridge point, memory-bound)
My kernel AI upper bound = 1.957 FLOP/byte (still below ridge point, still memory-bound)

M1 software baseline (Apple M1 CPU):
Peak compute = 2,600 GFLOP/s
Bandwidth = 68.3 GB/s
Ridge point = 38.1 FLOP/byte
Baseline AI = 1.06 FLOP/byte (memory-bound)

See codefest/cf09/cman_roofline_sketch.png for the hand-drawn roofline plot.

## Task 5: Bottleneck and Improvement

My current design is limited by the hardware interface bandwidth. The PCIe register-map interface I chose in M1 has high bandwidth on paper but the actual register-by-register write protocol (one MAC per write transaction) limits effective throughput to about 100 MB/s. The compute unit itself runs at 100 MHz and is ready every cycle, but it sits idle waiting for data from the interface.

The single highest-leverage change to improve performance is to add a FIFO or DMA burst interface so multiple input pairs (a, b) can be loaded per transaction instead of one at a time. This would raise the effective data rate by 10x to 100x, pushing the kernel toward the compute ceiling instead of being stuck at the interface bandwidth wall.
