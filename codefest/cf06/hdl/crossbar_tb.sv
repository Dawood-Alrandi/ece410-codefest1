// crossbar_tb.sv
// Testbench for crossbar_mac.sv — 4×4 Binary-Weight Crossbar MAC Unit
// ECE 410/510 Codefest 6 — HW4AI Spring 2026
//
// Weight matrix loaded (from assignment):
//   W = [[ 1,-1, 1,-1],
//        [ 1, 1,-1,-1],
//        [-1, 1, 1,-1],
//        [-1,-1,-1, 1]]
//
// Input vector: in = [10, 20, 30, 40]
//
// Hand-calculated expected outputs (out[j] = sum_i W[i][j]*in[i]):
//   out[0] = (+1)*10 + (+1)*20 + (-1)*30 + (-1)*40 = 10+20-30-40 = -40
//   out[1] = (-1)*10 + (+1)*20 + (+1)*30 + (-1)*40 = -10+20+30-40 =   0
//   out[2] = (+1)*10 + (-1)*20 + (+1)*30 + (-1)*40 = 10-20+30-40 = -20
//   out[3] = (-1)*10 + (-1)*20 + (-1)*30 + (+1)*40 = -10-20-30+40 = -20
//
// Compile & run:
//   iverilog -g2012 -o sim crossbar_mac.sv crossbar_tb.sv && ./sim

`timescale 1ns/1ps

module crossbar_tb;

    parameter N = 4;

    // DUT signals
    reg clk, rst, load_w, valid_in;
    reg signed [1:0] w_in [0:N-1][0:N-1];
    reg signed [7:0] in_data [0:N-1];
    wire signed [31:0] out [0:N-1];
    wire valid_out;

    // DUT instantiation
    crossbar_mac #(.N(N)) dut (
        .clk      (clk),
        .rst      (rst),
        .load_w   (load_w),
        .w_in     (w_in),
        .valid_in (valid_in),
        .in_data  (in_data),
        .out      (out),
        .valid_out(valid_out)
    );

    // 10 ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Expected outputs (hand-calculated, see header)
    localparam signed [31:0] EXP0 = -40;
    localparam signed [31:0] EXP1 =   0;
    localparam signed [31:0] EXP2 = -20;
    localparam signed [31:0] EXP3 = -20;

    integer errors = 0;
    integer k;

    initial begin
        $dumpfile("sim/crossbar_sim.log.vcd");
        $dumpvars(0, crossbar_tb);

        // Initialize
        rst = 1; load_w = 0; valid_in = 0;
        for (k = 0; k < N; k++) begin
            in_data[k] = 0;
            w_in[0][k] = 2'sb01; w_in[1][k] = 2'sb01;
            w_in[2][k] = 2'sb01; w_in[3][k] = 2'sb01;
        end

        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        // --- Load weight matrix ---
        // W row 0: [ 1,-1, 1,-1]
        // W row 1: [ 1, 1,-1,-1]
        // W row 2: [-1, 1, 1,-1]
        // W row 3: [-1,-1,-1, 1]
        // Encoding: +1 = 2'b01, -1 = 2'b11
        $display("--- Loading weight matrix ---");
        w_in[0][0] = 2'sb01; w_in[0][1] = 2'sb11; w_in[0][2] = 2'sb01; w_in[0][3] = 2'sb11;
        w_in[1][0] = 2'sb01; w_in[1][1] = 2'sb01; w_in[1][2] = 2'sb11; w_in[1][3] = 2'sb11;
        w_in[2][0] = 2'sb11; w_in[2][1] = 2'sb01; w_in[2][2] = 2'sb01; w_in[2][3] = 2'sb11;
        w_in[3][0] = 2'sb11; w_in[3][1] = 2'sb11; w_in[3][2] = 2'sb11; w_in[3][3] = 2'sb01;

        load_w = 1;
        @(posedge clk); #1;
        load_w = 0;

        // --- Apply input vector [10, 20, 30, 40] ---
        $display("--- Applying input [10, 20, 30, 40] ---");
        in_data[0] = 8'sd10;
        in_data[1] = 8'sd20;
        in_data[2] = 8'sd30;
        in_data[3] = 8'sd40;
        valid_in = 1;
        @(posedge clk); #1;
        valid_in = 0;

        // Wait one pipeline cycle for output to settle
        @(posedge clk); #1;

        // --- Check results ---
        $display("--- Results ---");
        $display("out[0] = %0d  (expected %0d)", out[0], EXP0);
        $display("out[1] = %0d  (expected %0d)", out[1], EXP1);
        $display("out[2] = %0d  (expected %0d)", out[2], EXP2);
        $display("out[3] = %0d  (expected %0d)", out[3], EXP3);

        if (out[0] === EXP0) $display("PASS out[0]");
        else begin $display("FAIL out[0]: got %0d, expected %0d", out[0], EXP0); errors++; end

        if (out[1] === EXP1) $display("PASS out[1]");
        else begin $display("FAIL out[1]: got %0d, expected %0d", out[1], EXP1); errors++; end

        if (out[2] === EXP2) $display("PASS out[2]");
        else begin $display("FAIL out[2]: got %0d, expected %0d", out[2], EXP2); errors++; end

        if (out[3] === EXP3) $display("PASS out[3]");
        else begin $display("FAIL out[3]: got %0d, expected %0d", out[3], EXP3); errors++; end

        // --- Test reset clears outputs ---
        rst = 1; @(posedge clk); #1; rst = 0;
        if (out[0] === 0 && out[1] === 0 && out[2] === 0 && out[3] === 0)
            $display("PASS reset: all outputs cleared to 0");
        else begin
            $display("FAIL reset: outputs not cleared");
            errors++;
        end

        // Summary
        if (errors == 0)
            $display("\nPASS: All crossbar_mac tests passed.");
        else
            $display("\nFAIL: %0d test(s) failed.", errors);

        $finish;
    end

endmodule
