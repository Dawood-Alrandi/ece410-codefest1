# Remaining Tasks Before M4
ECE 410/510 HW4AI Spring 2026

## Task 1: Replace register-map interface with DMA burst interface

The current PCIe register-map interface limits throughput to one MAC per host write transaction. Replace it with a DMA burst interface that can load 64 or 256 input pairs (a, b) per transaction. This requires adding a FIFO (depth 256, width 16 bits) between the PCIe interface and the compute core, and a DMA controller that fills the FIFO from host memory in one burst. Expected result: 64x to 256x throughput improvement, moving the accelerator from memory-bound to compute-bound on the roofline.

## Task 2: Fix the 32-bit adder on the critical path with a carry-save adder

The M3 timing report shows WNS = -0.31 ns at 100 MHz. The critical path runs from the weight register through the multiply (AND2_1 chain) and the accumulate (ADDF_1 chain) to the output register. The ADDF_1 ripple-carry adder chain has 4 stages and is the dominant delay. Replace the 4-stage ripple-carry adder with a carry-save adder (CSA) tree that reduces the critical path from 5.12 ns (4 ADDF stages) to about 2.5 ns (2 CSA stages). This should give positive timing slack at 100 MHz and allow targeting 130 MHz or higher.

## Task 3: Add power measurement with realistic toggle rates for M4 power report

The M3 power estimate of 0.175 mW used default 10% toggle rates from OpenSTA. M4 requires a real power estimate with workload-realistic toggle rates. Use the M1 profiling data (Conv2D._im2col with real image data) to estimate actual toggle rates for each signal, run OpenSTA with annotated switching activity (SAIF file or manually annotated), and report power at the realistic operating point. This is needed to compute energy per MAC and compare against the CPU baseline for the M4 energy efficiency metric.
