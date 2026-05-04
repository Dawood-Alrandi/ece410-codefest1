// tb_compute_core.sv
// Testbench for compute_core.sv
// ECE 410/510 HW4AI Spring 2026 — Project Milestone 2
//
// Representative input vector: weights = [3,-2,1,4,-1,2,-3,1,2] acts = [5,3,2,1,4,2,1,3,2]
// Expected output computed independently in Python: sum(weights*acts) = 19

`timescale 1ns/1ps
module tb_compute_core;
    reg clk; reg rst; reg valid_in;
    reg signed [7:0] a; reg signed [7:0] b;
    wire signed [31:0] acc_out; wire valid_out;
    compute_core dut(.clk(clk),.rst(rst),.valid_in(valid_in),.a(a),.b(b),.acc_out(acc_out),.valid_out(valid_out));
    initial clk = 0; always #5 clk = ~clk;
    localparam signed [31:0] EXPECTED = 32'sd19;
    integer errors = 0;
    initial begin
        $dumpfile("sim/compute_core_run.log.vcd"); $dumpvars(0,tb_compute_core);
        rst=1; valid_in=0; a=0; b=0;
        @(posedge clk); #1; @(posedge clk); #1; rst=0;
        $display("--- Feeding representative input vector (9 MACs) ---");
        a=8'sd5;  b=8'sd3;  valid_in=1; @(posedge clk); #1;
        a=8'sd3;  b=-8'sd2; valid_in=1; @(posedge clk); #1;
        a=8'sd2;  b=8'sd1;  valid_in=1; @(posedge clk); #1;
        a=8'sd1;  b=8'sd4;  valid_in=1; @(posedge clk); #1;
        a=8'sd4;  b=-8'sd1; valid_in=1; @(posedge clk); #1;
        a=8'sd2;  b=8'sd2;  valid_in=1; @(posedge clk); #1;
        a=8'sd1;  b=-8'sd3; valid_in=1; @(posedge clk); #1;
        a=8'sd3;  b=8'sd1;  valid_in=1; @(posedge clk); #1;
        a=8'sd2;  b=8'sd2;  valid_in=1; @(posedge clk); #1;
        valid_in=0; @(posedge clk); #1;
        $display("acc_out  = %0d", acc_out);
        $display("expected = %0d", EXPECTED);
        if (acc_out===EXPECTED) $display("PASS: acc_out matches expected value of %0d",EXPECTED);
        else begin $display("FAIL: acc_out=%0d, expected=%0d",acc_out,EXPECTED); errors=errors+1; end
        rst=1; @(posedge clk); #1; rst=0;
        if (acc_out===32'sd0) $display("PASS: reset cleared acc_out to 0");
        else begin $display("FAIL: after reset, acc_out=%0d",acc_out); errors=errors+1; end
        a=8'sd3; b=-8'sd5; valid_in=1; @(posedge clk); #1;
        a=8'sd3; b=-8'sd5; valid_in=1; @(posedge clk); #1;
        valid_in=0; @(posedge clk); #1;
        if (acc_out===-32'sd30) $display("PASS: negative accumulation correct (acc_out=%0d)",acc_out);
        else begin $display("FAIL: negative accumulation acc_out=%0d",acc_out); errors=errors+1; end
        if (errors==0) $display("\nPASS: All compute_core tests passed.");
        else $display("\nFAIL: %0d test(s) failed.",errors);
        $finish;
    end
endmodule
