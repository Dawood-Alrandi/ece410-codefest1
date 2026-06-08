// tb_top.sv
// End-to-End Co-Simulation Testbench for top.sv
// ECE 410/510 HW4AI Spring 2026, Milestone 3
//
// This testbench drives the interface from the host side only.
// No direct access to compute core ports.
//
// Test: write a=5, b=3 (product=15), then a=2, b=4 (product=8),
//       read back acc_out, expect 23.
// Expected value computed independently by hand: 5*3 + 2*4 = 15 + 8 = 23
//
// Compile and run:
//   iverilog -g2012 -o sim project/m2/rtl/compute_core.sv project/m2/rtl/interface.sv project/m3/rtl/top.sv project/m3/tb/tb_top.sv && ./sim

`timescale 1ns/1ps

module tb_top;

    reg        clk, rst;
    reg        wr_valid;
    reg  [3:0] wr_addr;
    reg [31:0] wr_data;
    wire        wr_ready;
    reg  [3:0] rd_addr;
    wire [31:0] rd_data;
    wire        rd_valid;

    top dut (
        .clk      (clk),
        .rst      (rst),
        .wr_valid (wr_valid),
        .wr_addr  (wr_addr),
        .wr_data  (wr_data),
        .wr_ready (wr_ready),
        .rd_addr  (rd_addr),
        .rd_data  (rd_data),
        .rd_valid (rd_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;

    task host_write(input [3:0] addr, input [31:0] data);
        @(posedge clk); #1;
        wr_valid = 1; wr_addr = addr; wr_data = data;
        @(posedge clk); #1;
        wr_valid = 0;
    endtask

    initial begin
        $dumpfile("project/m3/sim/cosim_run.log.vcd");
        $dumpvars(0, tb_top);

        rst = 1; wr_valid = 0; wr_addr = 0; wr_data = 0; rd_addr = 4'h8;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;
        @(posedge clk); #1;

        // Host writes a=5, b=3 via interface register 0x00
        // data[7:0]=a=5, data[15:8]=b=3
        $display("--- Host write: a=5, b=3 via interface ---");
        host_write(4'h0, 32'h0000_0305);
        @(posedge clk); #1;

        // Host writes a=2, b=4 via interface register 0x00
        $display("--- Host write: a=2, b=4 via interface ---");
        host_write(4'h0, 32'h0000_0402);
        @(posedge clk); #1;
        @(posedge clk); #1;

        // Host reads result via interface register 0x08
        $display("--- Host read: acc_out via interface ---");
        rd_addr = 4'h8;
        @(posedge clk); #1;
        @(posedge clk); #1;

        $display("rd_data = %0d (expected 23)", rd_data);

        if (rd_data === 32'd23) begin
            $display("PASS: end-to-end co-simulation result matches expected value of 23");
        end else begin
            $display("FAIL: rd_data=%0d expected=23", rd_data);
            errors = errors + 1;
        end

        // Test reset via interface register 0x04
        $display("--- Host write: reset via interface ---");
        host_write(4'h4, 32'h1);
        @(posedge clk); #1;
        host_write(4'h4, 32'h0);
        @(posedge clk); #1;

        rd_addr = 4'h8;
        @(posedge clk); #1;
        @(posedge clk); #1;

        if (rd_data === 32'd0)
            $display("PASS: reset via interface cleared accumulator to 0");
        else begin
            $display("FAIL: after reset rd_data=%0d expected=0", rd_data);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("PASS: All end-to-end co-simulation tests passed.");
        else
            $display("FAIL: %0d test(s) failed.", errors);

        $finish;
    end

endmodule
