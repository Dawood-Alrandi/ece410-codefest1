# Roofline Analysis: HW Accelerator vs SW Baseline
ECE 410/510 Codefest 9, HW4AI Spring 2026

## Accelerator Position on Roofline

My HW accelerator (sky130 at 100 MHz, PCIe register-map interface) has:
Arithmetic intensity = 0.989 to 1.957 FLOP/byte (from CF09 CMAN)
Throughput = 100 MFLOP/s (projected, limited by interface)
Ridge point = 2.0 FLOP/byte

The accelerator landed in the memory-bound region, below the ridge point, just like the M1 software baseline. Both are labeled as projected on the roofline plot (see roofline_plot.png).

## Gap Analysis

I expected the INT8 accelerator to cross the ridge point because INT8 reduces data width by 4x compared to FP32, raising arithmetic intensity from 1.06 (FP32 baseline) to about 4 FLOP/byte. However the actual attained arithmetic intensity is 0.989 to 1.957 FLOP/byte, still below the ridge point of 2.0 FLOP/byte.

The gap exists because:

1. The PCIe register-map interface creates a bottleneck at about 100 MB/s effective bandwidth, not the theoretical peak of the PCIe bus. Each register write is a separate transaction and the host overhead per transaction dominates.

2. The ridge point for this design (2.0 FLOP/byte) is much lower than I estimated in M1 (which used 320 GB/s HBM bandwidth). The actual sky130 design with a register-map interface has very limited bandwidth.

The dominant uncertainty in the projection is the interface bandwidth. I assumed one register write per cycle at 100 MHz, but actual PCIe transaction overhead could be 10x to 100x slower than this. A measurement with real PCIe hardware would replace the projection with a real number.

To convert to a measurement I would need to run the design on an FPGA with a PCIe IP core and measure actual throughput using a logic analyzer or host-side timing.

## Summary

The accelerator is projected to be in the memory-bound region of the roofline, limited by interface bandwidth rather than compute. The compute core is capable of 200 MFLOP/s at 100 MHz but the interface caps effective throughput at 100 MFLOP/s. The fix is a burst DMA interface which would push the accelerator above the ridge point and into the compute-bound region as originally designed.
