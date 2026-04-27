module mac_tb;

reg clk;
reg rst;
reg signed [7:0] a;
reg signed [7:0] b;
wire signed [31:0] out;

mac uut (
    .clk(clk),
    .rst(rst),
    .a(a),
    .b(b),
    .out(out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1;
    a = 0;
    b = 0;
    #10;

    rst = 0;

    // test a=3 b=4 for 3 cycles
    a = 3; b = 4;
    #30;

    // test a=-5 b=2 for 2 cycles
    a = -5; b = 2;
    #20;

    $finish;
end

endmodule
