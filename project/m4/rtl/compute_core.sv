// compute_core.sv
// INT8 Multiply-Accumulate (MAC) Compute Core
// ECE 410/510 HW4AI Spring 2026 --- Project Milestone 2
//
// Description:
//   Pipelined systolic-style compute core that performs INT8 multiply-accumulate
//   on a stream of (weight, activation) pairs and accumulates into a 32-bit
//   signed output register. This implements the dominant kernel from M1 profiling:
//   Conv2D._im2col (69.6% of runtime, AI = 1.06 FLOP/byte, memory-bound on CPU).
//
// Ports:
//   clk        : input  wire        --- single clock domain, rising-edge triggered
//   rst        : input  wire        --- synchronous active-high reset; clears accumulator
//   valid_in   : input  wire        --- asserted when a and b are valid inputs
//   a          : input  wire [7:0]  --- signed INT8 activation value
//   b          : input  wire [7:0]  --- signed INT8 weight value
//   acc_out    : output reg  [31:0] --- signed 32-bit accumulated result
//   valid_out  : output reg         --- registered echo of valid_in (1-cycle pipeline delay)
//
// Interface: PCIe (from M1 interface_selection.md)
//   Data arrives via the interface module (interface.sv). This core is purely
//   compute; the interface module handles PCIe framing and handshaking.
//
// Reset behavior: synchronous, active-high. acc_out cleared to 0 on rst.
// Clock domain: single domain. No CDC crossings inside this module.
//
// Precision: INT8 inputs, INT32 accumulator (no overflow for up to 2^23 MACs).
//
// Compile:  iverilog -g2012 -o sim compute_core.sv tb/tb_compute_core.sv && ./sim
// Synthesize: yosys -p "synth; write_json" compute_core.sv

`default_nettype none

module compute_core (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid_in,
    input  wire signed [7:0]  a,        // INT8 activation
    input  wire signed [7:0]  b,        // INT8 weight
    output reg  signed [31:0] acc_out,  // INT32 accumulator
    output reg                valid_out
);

    // 16-bit signed intermediate product (INT8 x INT8 = up to 16 bits)
    wire signed [15:0] product;
    assign product = a * b;

    always_ff @(posedge clk) begin
        if (rst) begin
            acc_out   <= 32'sd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
            if (valid_in) begin
                // Sign-extend 16-bit product to 32 bits before accumulating
                acc_out <= acc_out + {{16{product[15]}}, product};
            end
        end
    end

endmodule

`default_nettype wire
