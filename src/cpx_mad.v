//--------------------------------------------------------------------------------------------
// Module: cpx_mad
// Description: Performs a complex multiply-and-add (MAD) operation.
//   It calculates num1 + (num2 * TwiddleFactor), where all numbers
//   are complex and represented in a floating-point format.
//   The twiddle factor is retrieved from a ROM based on the provided index.
// Inputs:
//   - num1 [WORD_SIZE-1:0]: First complex input (real: MSB half, imag: LSB half).
//   - num2 [WORD_SIZE-1:0]: Second complex input (real: MSB half, imag: LSB half).
//   - twiddle_index [TW_IDX_SIZE-1:0]: Index to select the twiddle factor from a ROM.
//   - clk: Clock signal for synchronous operations.
// Parameters:
//   - WORD_SIZE: Total bit width of a complex number (e.g., 32 for 16-bit real/imag parts).
//   - TW_IDX_SIZE: Bit width of the twiddle index (e.g., 3 for 8 unique twiddle factors).
// Outputs:
//   - result [WORD_SIZE-1:0]: Complex output of the multiply-and-add operation
//     (real: MSB half, imag: LSB half).
//--------------------------------------------------------------------------------------------

module cpx_mad #(parameter WORD_SIZE = 32, TW_IDX_SIZE = 3) (
    input [WORD_SIZE-1:0] num1, num2,
    input [TW_IDX_SIZE-1:0] twiddle_index,
    input clk,
    output reg [WORD_SIZE-1:0] result
);

    reg [(WORD_SIZE/2 - 1):0] num1_real, num1_imag, num2_real, num2_imag;
    wire [(WORD_SIZE/2 - 1):0] twiddle_real, twiddle_imag;
    wire [(WORD_SIZE/2 - 1):0] mult_real1, mult_imag1, mult_real2, mult_imag2, mult_real, mult_imag;
    wire [(WORD_SIZE/2 - 1):0] real_part, imag_part;

    always @(posedge clk) begin
        num1_real <= num1[(WORD_SIZE-1) : (WORD_SIZE/2)];
        num1_imag <= num1[(WORD_SIZE/2 - 1):0];
        num2_real <= num2[(WORD_SIZE-1) : (WORD_SIZE/2)];
        num2_imag <= num2[(WORD_SIZE/2 - 1):0];
    end

    twiddleROM twiddle_inst(
        .index(twiddle_index),
        .clk(clk), 
        .Wreal(twiddle_real),
        .Wimag(twiddle_imag)
    );

    // Multiplication of num2 with twiddle factor
    // REAL PART
    float16_multi mult_inst1(
        .num1(twiddle_real),
        .num2(num2_real),
        .result(mult_real1),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    float16_multi mult_inst2(
        .num1(twiddle_imag),
        .num2(num2_imag),
        .result(mult_real2),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    float16_adder add_inst1(
        .num1(mult_real1),
        .num2({~mult_real2[WORD_SIZE/2 - 1], mult_real2[(WORD_SIZE/2 - 2):0]}), // Negate imaginary part (in IEEE-754, flip sign bit)
        .result(mult_real),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    // IMAGINARY PART
    float16_multi mult_inst3(
        .num1(twiddle_real),
        .num2(num2_imag),
        .result(mult_imag1),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    float16_multi mult_inst4(
        .num1(twiddle_imag),
        .num2(num2_real),
        .result(mult_imag2),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    float16_adder add_inst2(
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
    float16_adder add_inst3(
        .num1(num1_real),
        .num2(mult_real), 
        .result(real_part),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    // IMAGINARY PART
    float16_adder add_inst4(
        .num1(num1_imag),
        .num2(mult_imag), 
        .result(imag_part),
        .overflow(),
        .zero(),
        .NaN(),
        .precisionLost(),
        .clk(clk)
    );

    // Combine real and imaginary parts into the result
    always @(posedge clk) begin
        result <= {real_part, imag_part};
    end

endmodule