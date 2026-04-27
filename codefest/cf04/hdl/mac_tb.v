module mac_tb;

logic clk;
logic rst;
logic signed [7:0] a;
logic signed [7:0] b;
logic signed [31:0] out;

mac uut (
    .clk(clk),
    .rst(rst),
    .a(a),
    .b(b),
    .out(out)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    a = 0;
    b = 0;

    #10;
    rst = 0;

    a = 8'sd3;
    b = 8'sd4;
    #30;

    a = -8'sd5;
    b = 8'sd2;
    #20;

    $display("Final out = %0d", out);

    if (out == 16)
        $display("TEST PASSED");
    else
        $display("TEST FAILED");

    $finish;
end

endmodule
