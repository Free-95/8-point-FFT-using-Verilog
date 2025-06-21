//-----------------------------------------------------------------------------------
// Module: butterfly2p
// Description: Implements a 2-point butterfly operation, commonly used in
//   Fast Fourier Transform algorithms. It performs two complex
//   multiply-and-add (MAD) operations.
// Inputs:
//   - num1 [WORD_SIZE-1:0]: First complex input number.
//   - num2 [WORD_SIZE-1:0]: Second complex input number.
//   - twiddle_index [TW_IDX_SIZE-1:0]: Index to select the base twiddle factor.
//   - clk: Clock signal for synchronous operations.
// Parameters:
//   - N: Total number of points in the FFT (used to calculate twiddle index size).
//   - WORD_SIZE: Bit width of each complex number (e.g., 32 for 32-bit numbers),
//     where real and imaginary parts each occupy half the word size.
// Outputs:
//   - result1 [WORD_SIZE-1:0]: First complex output of the butterfly.
//   - result2 [WORD_SIZE-1:0]: Second complex output of the butterfly,
//     calculated with an offset twiddle factor.
//-----------------------------------------------------------------------------------

module butterfly2p #(parameter N = 8, WORD_SIZE = 32) (
    input [WORD_SIZE-1:0] num1, num2,
    input [TW_IDX_SIZE-1:0] twiddle_index,
    input clk,
    output [WORD_SIZE-1:0] result1, result2
);

    localparam TW_IDX_SIZE = $clog2(N); // Size of twiddle index

    cpx_mad #(WORD_SIZE, TW_IDX_SIZE) mad_inst(
        .num1(num1),
        .num2(num2),
        .twiddle_index(twiddle_index),
        .clk(clk),
        .result(result1)
    );

    // Offset for second cross product
    wire [TW_IDX_SIZE-1:0] offset = N/2;
    cpx_mad #(WORD_SIZE, TW_IDX_SIZE) mad_inst2(
        .num1(num1),
        .num2(num2),
        .twiddle_index(twiddle_index + offset), 
        .clk(clk),
        .result(result2)
    );

endmodule