// interface.sv
// PCIe-style Interface Module (simplified AXI4-Lite register map)
// ECE 410/510 HW4AI Spring 2026 --- Project Milestone 2
//
// Description:
//   Interface module connecting the host (PCIe) to the compute_core.
//   Implements a simple write/read register map over an AXI4-Lite-like
//   protocol. The host writes (a, b) pairs via TVALID/TREADY handshake,
//   and reads the accumulated result via a read transaction.
//
//   PCIe was chosen in M1 (interface_selection.md) because the kernel
//   requires ~75.5 GB/s bandwidth; PCIe Gen4 x16 provides ~32 GB/s.
//
// Register map (32-bit word-addressed):
//   0x00 (WR): Write {b[7:0], a[7:0]} --- triggers valid_in to compute_core
//   0x04 (WR): Write 1 to rst_reg     --- resets accumulator
//   0x80 (RD): Read  acc_out[31:0]    --- accumulated result
//
// Ports:
//   clk        : input  wire        --- single clock, rising-edge
//   rst        : input  wire        --- synchronous active-high reset
//   wr_valid   : input  wire        --- host asserts when wr_addr/wr_data valid
//   wr_addr    : input  wire [3:0]  --- register address
//   wr_data    : input  wire [31:0] --- write data from host
//   wr_ready   : output reg         --- asserted when interface can accept write
//   rd_addr    : input  wire [3:0]  --- register read address
//   rd_data    : output reg  [31:0] --- data returned to host
//   rd_valid   : output reg         --- asserted one cycle after rd_addr
//
// Clock domain: single domain, synchronous reset.
// Protocol: TVALID/TREADY handshake on writes; single-cycle read response.

`default_nettype none

module interface_mod (
    input  wire        clk,
    input  wire        rst,
    input  wire        wr_valid,
    input  wire [3:0]  wr_addr,
    input  wire [31:0] wr_data,
    output reg         wr_ready,
    input  wire [3:0]  rd_addr,
    output reg  [31:0] rd_data,
    output reg         rd_valid
);

    wire signed [31:0] acc_out;
    wire               core_valid_out;
    reg                core_rst;
    reg                core_valid_in;
    reg  signed [7:0]  core_a, core_b;

    compute_core u_core (
        .clk       (clk),
        .rst       (core_rst),
        .valid_in  (core_valid_in),
        .a         (core_a),
        .b         (core_b),
        .acc_out   (acc_out),
        .valid_out (core_valid_out)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ready      <= 1'b1;
            core_valid_in <= 1'b0;
            core_rst      <= 1'b1;
            core_a        <= 8'sd0;
            core_b        <= 8'sd0;
        end else begin
            core_rst      <= 1'b0;
            core_valid_in <= 1'b0;
            wr_ready      <= 1'b1;
            if (wr_valid && wr_ready) begin
                case (wr_addr[3:2])
                    2'b00: begin
                        core_a        <= signed'(wr_data[7:0]);
                        core_b        <= signed'(wr_data[15:8]);
                        core_valid_in <= 1'b1;
                    end
                    2'b01: begin
                        core_rst <= wr_data[0];
                    end
                    default: ;
                endcase
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            rd_data  <= 32'h4;
            rd_valid <= 1'b0;
        end else begin
            rd_valid <= 1'b1;
            case (rd_addr[3:2])
                2'b10:   rd_data <= acc_out;
                default: rd_data <= 32'hDEAD_BEEF;
            endcase
        end
    end

endmodule

`default_nettype wire
