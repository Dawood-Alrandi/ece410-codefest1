// crossbar_mac.sv
// 4×4 Binary-Weight Crossbar MAC Unit
// ECE 410/510 Codefest 6 — HW4AI Spring 2026
// Generated with LLM assistance (Claude Sonnet 4.6)
//
// Description:
//   Implements a 4×4 crossbar multiply-accumulate unit with binary weights (+1/-1).
//   Each clock cycle computes:
//     out[j] = sum_i (weight[i][j] * in[i])   for j = 0..3
//
//   Weights are stored in a 4×4 register array as signed 2-bit values (+1 or -1).
//   Inputs are 8-bit signed integers.
//   Outputs are 32-bit signed accumulators to prevent overflow.
//
// Ports:
//   clk        : input  wire        — rising-edge clock
//   rst        : input  wire        — synchronous active-high reset; clears accumulators
//   load_w     : input  wire        — when high, load weight matrix from w_in
//   w_in       : input  wire [3:0][3:0][1:0] — weight matrix, packed (row, col), +1=2'b01, -1=2'b11
//   valid_in   : input  wire        — when high, in_data is valid; perform one MAC cycle
//   in_data    : input  wire [3:0][7:0] — 4 signed 8-bit input activations
//   out        : output reg  [3:0][31:0] — 4 signed 32-bit accumulated outputs
//   valid_out  : output reg             — registered valid_in echo
//
// Clock domain: single, synchronous active-high reset.
// Weight encoding: +1 stored as 2'b01, -1 stored as 2'b11 (signed 2-bit).
//
// Compile: iverilog -g2012 -o sim crossbar_mac.sv crossbar_tb.sv && ./sim

`default_nettype none

module crossbar_mac #(
    parameter N = 4  // array dimension
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        load_w,
    // Weight matrix: w_in[row][col] = signed 2-bit (+1 or -1)
    input  wire signed [1:0] w_in [0:N-1][0:N-1],
    input  wire        valid_in,
    // Input activations: 4 x 8-bit signed
    input  wire signed [7:0] in_data [0:N-1],
    // Output accumulators: 4 x 32-bit signed
    output reg  signed [31:0] out [0:N-1],
    output reg                valid_out
);

    // Weight register array
    reg signed [1:0] weight [0:N-1][0:N-1];

    // Combinational partial products for current cycle
    // product[i][j] = weight[i][j] * in_data[i]  (signed 10-bit is safe: 2-bit * 8-bit)
    wire signed [9:0] product [0:N-1][0:N-1];

    genvar gi, gj;
    generate
        for (gi = 0; gi < N; gi++) begin : gen_row
            for (gj = 0; gj < N; gj++) begin : gen_col
                // Sign-extend 2-bit weight to 10 bits before multiply
                assign product[gi][gj] = $signed({{8{weight[gi][gj][1]}}, weight[gi][gj]})
                                         * $signed(in_data[gi]);
            end
        end
    endgenerate

    integer i, j;

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_out <= 1'b0;
            for (i = 0; i < N; i++) begin
                out[i] <= 32'sd0;
                for (j = 0; j < N; j++) begin
                    weight[i][j] <= 2'sb01;  // default weight = +1
                end
            end
        end else begin
            valid_out <= valid_in;

            if (load_w) begin
                for (i = 0; i < N; i++)
                    for (j = 0; j < N; j++)
                        weight[i][j] <= w_in[i][j];
            end

            if (valid_in) begin
                // Each output column accumulates its dot product
                for (j = 0; j < N; j++) begin
                    out[j] <= out[j] + product[0][j]
                                     + product[1][j]
                                     + product[2][j]
                                     + product[3][j];
                end
            end
        end
    end

endmodule

`default_nettype wire
