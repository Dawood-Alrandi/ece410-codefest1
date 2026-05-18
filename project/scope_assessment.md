# Project Scope Assessment
ECE 410/510 HW4AI Spring 2026, Updated May 2026

## Project Title
INT8 MAC Accelerator for CNN Inference

## Current Scope

This project builds a pipelined single-lane INT8 multiply-accumulate hardware accelerator that targets the Conv2D._im2col kernel. Profiling in M1 showed this kernel accounts for 69.6% of total CNN training runtime with an arithmetic intensity of 1.06 FLOP/byte, which is deeply memory-bound on a CPU. Using INT8 quantization raises the effective arithmetic intensity to about 25 FLOP/byte, which crosses the roofline ridge point and makes the kernel compute-bound on the accelerator. The interface uses a PCIe register-map similar to AXI4-Lite. The target technology is SkyWater sky130_fd_sc_hd at 100 MHz.

## Milestone Status

M1 (Complete): Workload profiling, roofline analysis, HW/SW partition rationale, Heilmeier catechism, and algorithm diagram are all done.

M2 (Complete): compute_core.sv and interface.sv are designed in synthesizable SystemVerilog. Testbenches were written and simulated and all 6 assertions pass. INT8 quantization was verified with MAE = 0.0043 which is under 0.5%. The precision analysis confirms INT8 is acceptable based on published baselines.

CF07 Synthesis (Option B fallback with crossbar_mac): Synthesized at 100 MHz on sky130. WNS = -0.23 ns (minor violation), cell area = 412.5 um^2, 87 cells total, one hold violation on the reset path. This confirms the RTL is synthesizable and the timing target is close.

M3 (Planned, due May 24): Synthesize compute_core.sv on sky130 at 100 MHz. Fix hold violation by buffering the reset net. Verify timing closes with positive slack. Stretch goal is to pipeline the MAC for a higher frequency target.

## Scope Assessment

The scope has not changed from M1. The goal is still an INT8 systolic MAC accelerator with a PCIe interface targeting the Conv2D bottleneck. The CF07 synthesis exercise showed the RTL coding style is clean with no latches and no combinational loops. The single-lane compute_core should be smaller and faster than the 4x4 crossbar used in CF07 so 100 MHz timing closure looks realistic for M3. No scope reduction is needed.
