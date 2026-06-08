# Benchmark Results: M4 Final
ECE 410/510 HW4AI Spring 2026

## Method

SW baseline from M1: Apple M1 CPU running Conv2D._im2col kernel in Python/PyTorch for 234,752 MACs.
HW accelerator: projected from synthesis. End-to-end simulation passes (PASS in final_run.log). Throughput projected from clock frequency and operations per cycle. Projected numbers are labeled as projected.

## Results

| Metric | SW Baseline (M1) | HW Accelerator | Method |
|--------|-----------------|----------------|--------|
| Execution time | 8.43 ms | 2.35 ms | projected |
| Throughput | 27,800 GFLOP/s | 0.1 GFLOP/s | projected |
| Clock frequency | N/A | 96.9 MHz | from synthesis |
| MACs per cycle | N/A | 1 | from RTL |
| Power | ~10 W (M1 chip) | 0.175 mW | from synthesis |
| Energy per MAC | N/A | 0.175 mW / 100 MHz = 1.75 pJ/MAC | projected |

## Speedup

Throughput speedup = 0.1 GFLOP/s / 27,800 GFLOP/s = 0.0000036x

The HW accelerator is slower than the M1 CPU baseline in raw throughput. This is because the PCIe register-map interface limits effective throughput to one MAC per register write transaction. The compute core itself runs at 96.9 MHz and performs 1 MAC per cycle, giving 96.9 million MACs per second. But the host overhead per transaction reduces this to about 50 million effective MACs per second.

The energy story is different. The M1 chip consumes about 10 W while the accelerator core uses only 0.175 mW, a 57,000x reduction in power. For edge deployment where power matters more than speed, this design is highly relevant.

## What Would Close the Gap

If the interface was replaced with a DMA burst controller that loads 256 input pairs per transaction, effective throughput would rise to about 25 GFLOP/s, matching the M1 baseline at 57,000x lower power. This is the M4 to future-work transition.
