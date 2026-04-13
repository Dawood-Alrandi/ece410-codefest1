# Interface Selection

## Chosen Interface
I chose PCIe as the interface between the host system and the hardware accelerator.

## Host Platform
The assumed host platform is a CPU-based system running the CNN software baseline in Python and NumPy.

## Bandwidth Requirement
The target accelerator performance is about 80 GFLOP/s. The arithmetic intensity of the kernel is about 1.06 FLOP/byte.

Required bandwidth = Throughput / Arithmetic Intensity  
Required bandwidth = 80 / 1.06  
Required bandwidth ≈ 75.5 GB/s

## Interface Comparison
The kernel needs about 75.5 GB/s to avoid becoming interface-bound. A very low-bandwidth interface such as SPI or I2C would not be enough. PCIe provides much higher bandwidth and is more realistic for a high-performance accelerator connection.

## Bottleneck Status
If the interface cannot provide enough bandwidth, then the accelerator will become interface-bound instead of compute-bound. Because of this, the interface must be chosen carefully to support high data movement rates.
