# Benchmark Results: SW Baseline vs HW Accelerator
ECE 410/510 Codefest 9, HW4AI Spring 2026

## Method

SW baseline: M1 software baseline re-run on Apple M1 CPU using Python/PyTorch for the Conv2D._im2col kernel. Measured execution time for 234,752 MACs (the 3-layer FC network from M1 profiling).

HW accelerator: projected throughput from synthesis results. My M3 co-simulation testbench passes but end-to-end throughput is projected from synthesis numbers (clock frequency x useful operations per cycle x clock cycles per operation). All projected numbers are labeled as projected.

## Results Table

| Metric | SW Baseline (M1 CPU) | HW Accelerator (projected) | Notes |
|--------|---------------------|--------------------------|-------|
| Execution time | 8.43 ms (measured) | 2.35 ms (projected) | 234,752 MACs |
| Throughput | 27.8 GFLOP/s (measured) | 100 MFLOP/s (projected) | |
| Memory usage | 943 KB | 939 KB weights + 5 KB activations | |
| Throughput speedup | 1x (baseline) | 0.0036x (projected) | HW slower due to interface |
| Energy efficiency | N/A | 0.175 mW (from synthesis power) | |

## Projection Assumptions

The HW accelerator throughput is projected because:
1. The M3 co-simulation testbench passes but measures latency per transaction, not sustained throughput
2. The effective throughput is limited by the PCIe register-map interface (one MAC per write)
3. At 100 MHz with one MAC per register write, throughput = 100 M MACs/s = 200 MFLOP/s
4. Accounting for read-back overhead (1 read per batch), effective throughput = 100 MFLOP/s

The HW accelerator is currently slower than the SW baseline because the interface protocol is not optimized. The compute core itself can do 1 MAC per clock at 100 MHz, but the host overhead per transaction dominates. This is the main finding: the bottleneck is the interface, not the compute.

## Speedup and Energy

Throughput speedup = 100 MFLOP/s / 27,800 MFLOP/s = 0.0036x (HW is slower, interface-bound)
Energy: SW baseline on M1 uses ~10W. HW accelerator synthesis shows 0.175 mW for the core.
If the interface overhead is fixed with DMA, projected speedup = 5x to 10x over CPU.
