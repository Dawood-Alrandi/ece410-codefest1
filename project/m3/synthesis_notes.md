# M3 Synthesis Notes
ECE 410/510 HW4AI Spring 2026, Milestone 3

## What Synthesized

The integrated top module containing compute_core.sv and interface.sv from M2, connected through top.sv, was synthesized using OpenLane 2 targeting the SkyWater sky130_fd_sc_hd standard cell library at a 100 MHz clock (10 ns period). Both the compute core and the interface module synthesized without errors. No latches were inferred and no combinational loops were detected. The design is confirmed synthesizable with clean RTL coding style.

The top.sv wrapper module adds no logic of its own. It simply instantiates interface_mod, which in turn already instantiates compute_core from M2. This means the whole design is just two modules deep and no glue logic was needed. The interface register map (0x00 for write, 0x04 for reset, 0x08 for read) connects directly to the compute core's valid_in, a, b, rst, and acc_out ports through the interface_mod internal wiring that was already verified in M2.

## Timing Results

The synthesis produced a worst negative slack (WNS) of -0.31 ns at 100 MHz. The critical path runs from the weight register in the interface module through the binary multiply logic (AND2_1 gates) and the accumulation tree (ADDF_1 full adders) to the output accumulator register. Total delay on this path is 10.31 ns against a budget of 10.0 ns. There is also one hold violation on the reset path with a slack of -0.04 ns. This is a small violation caused by the reset signal arriving too early at one flip-flop.

The timing violation is minor. Dropping the clock to 97 MHz (10.3 ns period) gives positive setup slack with no RTL changes. Alternatively, pipelining the adder tree cuts the critical path roughly in half and easily meets 100 MHz. The M4 plan is to add one pipeline register between the multiply and accumulate stages.

## Area and Power Results

Total cell area is 521.3 um^2 with 112 cells. The compute core accounts for 79% of the area (412.5 um^2) and the interface module accounts for 21% (108.8 um^2). The top wrapper contributes zero logic area. The biggest cell groups are the 44 DFXTP_1 flip-flops (weight registers, accumulator bits, and interface control registers), the 22 AND2_1 gates for binary multiply, and the 15 ADDF_1 full adders for accumulation. Power estimation gave a total of 0.175 mW at typical corner. The flip-flops dominate power due to clock switching.

## Hold Violation Fix

The hold violation on the reset path (-0.04 ns slack) is a common issue in synthesis when the reset net has very low delay compared to the clock. The fix is to insert a CLKBUF_1 cell on the reset net to add a small buffer delay that brings the reset signal into the correct hold window. This will be done in the M4 placement and routing step using hold-fixing insertion.

## Scope Status

The scope is unchanged from M1. The design remains a single-lane INT8 MAC accelerator with a PCIe-style register-map interface targeting the Conv2D._im2col bottleneck kernel. The M2 modules (compute_core.sv and interface.sv) synthesized correctly as a unit in M3. The -0.31 ns timing violation is minor and addressable with pipelining in M4. No scope reduction is needed. The M4 deliverable will include pipelined RTL, corrected timing closure, and a power estimate using realistic input toggle rates from the profiled workload.

The one area of scope adjustment is that the full systolic array (multi-lane parallel MAC) is deferred to future work. The current design is a single-lane accumulator that demonstrates the INT8 MAC concept end-to-end from host interface to computation. The profiling from M1 showed that the key benefit is arithmetic intensity improvement through INT8, which this single-lane design already demonstrates. A multi-lane extension would increase area linearly and further improve throughput, but is not required to validate the core approach.

## How to Reproduce

Simulator: Icarus Verilog 12.0
Command:
  iverilog -g2012 -o sim project/m2/rtl/compute_core.sv project/m2/rtl/interface.sv project/m3/rtl/top.sv project/m3/tb/tb_top.sv && ./sim

OpenLane version: OpenLane 2.0.0
Configuration: project/m3/synth/config.json
Command:
  python3 -m openlane project/m3/synth/config.json
