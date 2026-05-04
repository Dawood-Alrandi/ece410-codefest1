// tb_interface.sv - Testbench for interface.sv (PCIe register-map)
// ECE 410/510 HW4AI Spring 2026 - Project Milestone 2
`timescale 1ns/1ps
module tb_interface;
    reg clk, rst;
    reg wr_valid; reg [3:0] wr_addr; reg [31:0] wr_data;
    wire wr_ready; reg [3:0] rd_addr; wire [31:0] rd_data; wire rd_valid;
    interface_mod dut(.clk(clk),.rst(rst),.wr_valid(wr_valid),.wr_addr(wr_addr),.wr_data(wr_data),.wr_ready(wr_ready),.rd_addr(rd_addr),.rd_data(rd_data),.rd_valid(rd_valid));
    initial clk = 0; always #5 clk = ~clk;
    integer errors = 0;
    task write_reg(input [3:0] addr, input [31:0] data);
        @(posedge clk); #1; wr_valid=1; wr_addr=addr; wr_data=data;
        @(posedge clk); #1; wr_valid=0;
    endtask
    initial begin
        $dumpfile("sim/interface_run.log.vcd"); $dumpvars(0,tb_interface);
        rst=1; wr_valid=0; wr_addr=0; wr_data=0; rd_addr=4'h8;
        @(posedge clk); #1; @(posedge clk); #1; rst=0; @(posedge clk); #1;
        $display("--- Write transaction 1: a=5, b=3 ---");
        write_reg(4'h0,32'h0000_0305); @(posedge clk); #1;
        $display("--- Write transaction 2: a=2, b=4 ---");
        write_reg(4'h0,32'h0000_0402); @(posedge clk); #1; @(posedge clk); #1;
        $display("--- Read transaction: expect acc=23 ---");
        rd_addr=4'h8; @(posedge clk); #1; @(posedge clk); #1;
        if (rd_data===32'd23) $display("PASS: read acc_out=%0d (expected 23)",rd_data);
        else begin $display("FAIL: read acc_out=%0d",rd_data); errors=errors+1; end
        $display("--- Write reset transaction ---");
        write_reg(4'h4,32'h1); @(posedge clk); #1;
        write_reg(4'h4,32'h0); @(posedge clk); #1;
        $display("--- Read transaction after reset: expect 0 ---");
        rd_addr=4'h8; @(posedge clk); #1; @(posedge clk); #1;
        if (rd_data===32'd0) $display("PASS: acc_out=0 after reset");
        else begin $display("FAIL: acc_out=%0d after reset",rd_data); errors=errors+1; end
        if (errors==0) $display("\nPASS: All interface tests passed.");
        else $display("\nFAIL: %0d test(s) failed.",errors);
        $finish;
    end
endmodule
