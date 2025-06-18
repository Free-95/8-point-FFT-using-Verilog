module butterfly2p (
    input [31:0] num1, num2,
    input [2:0] twiddle_index,
    input clk,
    output [31:0] result1, result2
);

    cpx_mad mad_inst(
        .num1(num1),
        .num2(num2),
        .twiddle_index(twiddle_index),
        .clk(clk),
        .result(result1)
    );

    cpx_mad mad_inst2(
        .num1(num1),
        .num2(num2),
        .twiddle_index(twiddle_index + 3'b100), // Offset for second butterfly
        .clk(clk),
        .result(result2)
    );

endmodule