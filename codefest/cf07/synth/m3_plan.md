# M3 Synthesis Plan
ECE 410/510 Codefest 7, HW4AI Spring 2026

## CF07 Context (Option B Fallback)

For CF07 I synthesized the CF06 crossbar_mac because the full project systolic array RTL is not done yet. The result was a -0.23 ns timing violation at 100 MHz, a cell area of 412.5 um^2 with 87 cells, and one hold violation on the reset path with -0.05 ns slack.

## M3 Plan (due May 24)

For M3 I will synthesize the actual project module compute_core.sv using the same sky130_fd_sc_hd PDK at 100 MHz. The compute_core is a single-lane INT8 MAC unit with 8-bit inputs and a 32-bit accumulator. It is much smaller than the 4x4 crossbar so cell area and path depth should both be lower. The adder tree is only one level deep which should give positive slack at 100 MHz without pipelining. I will fix the hold violation on the reset path by adding a CLKBUF before synthesis. If timing still does not close at 100 MHz I will drop the target to 90 MHz, which the CF07 result shows is achievable since the violation at 100 MHz was only 0.23 ns.
