# Critical Path Analysis
ECE 410/510 HW4AI Spring 2026, Milestone 3

## Critical Path Description

The critical path in the integrated top module starts at the weight register in the interface module and ends at the output accumulator register in the compute core.

Start point: interface_mod weight_reg[1][0] (DFXTP_1 flip-flop, output Q)
End point: compute_core out_reg[1][31] (DFXTP_1 flip-flop, input D)

Logic stages along the path:
1. Weight register output Q drives the first AND2_1 gate (binary multiply, 0.44 ns)
2. Chain of 3 AND2_1 gates completing the 8-bit x 2-bit multiply (1.38 ns)
3. AND2_1 output feeds into the first ADDF_1 full adder (0.41 ns)
4. Chain of 4 ADDF_1 full adder stages building the accumulation tree (5.12 ns)
5. ADDF_1 sum output drives the D input of the output accumulator flip-flop (0.33 ns)
6. Flip-flop setup time requirement (0.62 ns)
7. Wire delays (2.01 ns)
Total: 10.31 ns, slack = -0.31 ns

## Why This is the Critical Path

The multiply-accumulate chain is the critical path because it has the deepest combinational logic between two flip-flops. The binary multiply needs 3 AND gate stages, and the 32-bit accumulation needs 4 full-adder stages. Both run in series before the result can be registered. No other path in the design has this depth. The interface glue logic (MUX and control) has very shallow logic depth (1 to 2 gates) and is nowhere near critical.

## What Would Shorten It

The fastest fix is to pipeline the path: insert a register between the multiply output and the adder tree input. This cuts the path roughly in half, making both halves about 5 ns, well within a 10 ns budget. The cost is one extra clock cycle of latency. A second option is to reduce the clock period from 10.0 ns to 10.4 ns (96 MHz), which gives positive slack with no design changes. For M4 pipelining will be implemented to reach 100 MHz with margin.
