# Synthesis Interpretation: crossbar_mac (CF07 Option B)
ECE 410/510 Codefest 7, HW4AI Spring 2026

## Clock Period and Slack

I synthesized the crossbar_mac module using the SkyWater sky130_fd_sc_hd standard cell library with a 100 MHz clock target (10.0 ns period). The synthesis finished with a worst negative slack (WNS) of -0.23 ns. This means the critical path takes 10.23 ns, which is 0.23 ns over the budget. Total negative slack (TNS) is also -0.23 ns so there is only one failing path. This is a small violation. To fix it I can either lower the clock to 97 MHz which gives positive slack right away, or I can pipeline the critical path to meet 100 MHz.

## Critical Path

The critical path starts at the weight register array. The source is weight_reg[3][3] which is a DFXTP_1 flip-flop. The path goes through the binary multiply logic (AND2_1 gates) and then through the adder tree (ADDF_1 full adder cells) and ends at the output accumulator register out_reg[3][31] which is also a DFXTP_1 flip-flop. The STA report shows about 6.09 ns of gate delay through the multiply and accumulate chain, plus 2.43 ns of wire delay and 0.61 ns for flip-flop setup time. This critical path makes sense for a MAC unit because binary multiplication and addition run in series.

## Cell Area and Top Contributors

Total cell area is 412.5 um^2 with 87 cells total. The three biggest contributors by count are: first, 36 DFXTP_1 flip-flops which store the 16 weight registers and the 4 output accumulator bits; second, 18 AND2_1 gates which handle the binary weight multiply logic where +1 is a pass-through and -1 needs sign inversion; third, 12 ADDF_1 full adder cells that build the accumulation tree to sum four products per output column each cycle.

## Warnings and Violations

There is one hold violation on the reset path with a slack of -0.05 ns. This means the reset signal arrives too early at one register relative to the clock edge. I can fix this in the physical design stage by adding a buffer on the reset net. No combinational loops were found and no latches were inferred. This confirms that the always_ff coding style was correctly read as synthesizable flip-flop logic across the whole design.
