// top.sv
// Integrated Top Module: Interface + Compute Core
// ECE 410/510 HW4AI Spring 2026, Milestone 3
//
// Description:
//   This module integrates the interface module (interface_mod) and the
//   compute core (compute_core) from M2 into a single top-level design.
//   The host communicates only through the interface ports. The interface
//   module drives the compute core internally. No direct host access to
//   compute core ports.
//
// Ports:
//   clk        : input  wire        - single clock, rising-edge triggered
//   rst        : input  wire        - synchronous active-high reset
//   wr_valid   : input  wire        - host write strobe
//   wr_addr    : input  wire [3:0]  - register address (0x00=write a,b  0x04=reset  0x08=read)
//   wr_data    : input  wire [31:0] - write data from host
//   wr_ready   : output wire        - interface ready for write
//   rd_addr    : input  wire [3:0]  - register read address
//   rd_data    : output wire [31:0] - data returned to host
//   rd_valid   : output wire        - read data valid
//
// Glue logic: none required. The interface_mod already instantiates
// compute_core internally and wires all signals. top.sv is a thin wrapper
// that exposes the interface ports to the outside world.

`default_nettype none

module top (
    input  wire        clk,
    input  wire        rst,
    input  wire        wr_valid,
    input  wire [3:0]  wr_addr,
    input  wire [31:0] wr_data,
    output wire        wr_ready,
    input  wire [3:0]  rd_addr,
    output wire [31:0] rd_data,
    output wire        rd_valid
);

    interface_mod u_interface (
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

endmodule

`default_nettype wire
