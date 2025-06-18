//------------------------------------------------------------------------------
// Module: cpx_mad
// Description: Performs complex multiply-and-add operation for FFT computations.
//   - Multiplies num2 (complex) by a twiddle factor (selected by twiddle_index)
//     and adds the result to num1 (complex).
// Inputs:
//   - num1 [31:0]: Complex input (real: [31:16], imag: [15:0])
//   - num2 [31:0]: Complex input (real: [31:16], imag: [15:0])
//   - twiddle_index [2:0]: Index to select twiddle factor
//   - clk: Clock signal
// Outputs:
//   - result [31:0]: Complex output (real: [31:16], imag: [15:0])
//------------------------------------------------------------------------------
module cpx_mad(
    input [31:0] num1, num2,
    input [2:0] twiddle_index,
    input clk,
    output reg [31:0] result
);

    reg [15:0] num1_real, num1_imag, num2_real, num2_imag;
    wire [15:0] twiddle_real, twiddle_imag;
    wire [15:0] mult_real1, mult_imag1, mult_real2, mult_imag2, mult_real, mult_imag;
    reg [15:0] real_part, imag_part;

    always @(posedge clk) begin
        num1_real <= num1[31:16];
        num1_imag <= num1[15:0];
        num2_real <= num2[31:16];
        num2_imag <= num2[15:0];
        real_part <= add_inst3.result;
        imag_part <= add_inst4.result;
        result <= {real_part, imag_part};
    end

    twiddleROM twiddle_inst(
        .index(twiddle_index),
        .en(1'b1), // Enable the ROM
        .clk(clk), 
        .Wreal(twiddle_real),
        .Wimag(twiddle_imag)
    );

    // Multiplication of num2 with twiddle factor
    // REAL PART
    float_multi mult_inst1(
        .num1(twiddle_real),
        .num2(num2_real),
        .result(mult_real1),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    float_multi mult_inst2(
        .num1(twiddle_imag),
        .num2(num2_imag),
        .result(mult_real2),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    float_adder add_inst1(
        .num1(mult_real1),
        .num2({~mult_real2[15], mult_real2[14:0]}), // Negate imaginary part (flip sign bit for sign-magnitude/IEEE-754)
        .result(mult_real),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    // IMAGINARY PART
    float_multi mult_inst3(
        .num1(twiddle_real),
        .num2(num2_imag),
        .result(mult_imag1),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    float_multi mult_inst4(
        .num1(twiddle_imag),
        .num2(num2_real),
        .result(mult_imag2),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    float_adder add_inst2(
        .num1(mult_imag1),
        .num2(mult_imag2), 
        .result(mult_imag),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    // Final addition of num1 with the product
    // REAL PART
    float_adder add_inst3(
        .num1(num1_real),
        .num2(mult_real), 
        .result(),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    // IMAGINARY PART
    float_adder add_inst4(
        .num1(num1_imag),
        .num2(mult_imag), 
        .result(),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

endmodule