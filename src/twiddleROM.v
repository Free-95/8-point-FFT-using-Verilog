//------------------------------------------------------------------------------
// Module: twiddleROM
// Description: Provides pre-calculated twiddle factors (complex numbers)
//   from a ROM for use in FFT computations.
//   Each twiddle factor is stored as two 16-bit values, representing
//   its real and imaginary parts in a floating-point format.
// Inputs:
//   - index [2:0]: Input address to select the desired twiddle factor.
//   - clk: Clock signal.
// Outputs:
//   - Wreal [15:0]: Real part of the selected twiddle factor.
//   - Wimag [15:0]: Imaginary part of the selected twiddle factor.
//------------------------------------------------------------------------------

module twiddleROM (
  input [2:0] index,
  input clk,
  output reg [15:0] Wreal, Wimag
);
  
  reg [15:0] W [15:0]; // ROM declaration
  reg [3:0] add_reg; // Address Register
  
  initial begin // Store twiddle factor values in ROM
      // W**0
      W[4'h0] <= 16'h3c00; // 1 (Real)
      W[4'h1] <= 16'h0000; // 0 (Imaginary)
      // W**1
      W[4'h2] <= 16'h39a8; // 0.707
      W[4'h3] <= 16'hb9a8; // -0.707
      // W**2
      W[4'h4] <= 16'h0000; // 0
      W[4'h5] <= 16'hbc00; // -1
      // W**3
      W[4'h6] <= 16'hb9a8; // -0.707
      W[4'h7] <= 16'hb9a8; // -0.707
      // W**4
      W[4'h8] <= 16'hbc00; // -1
      W[4'h9] <= 16'h0000; // 0
      // W**5
      W[4'ha] <= 16'hb9a8; // -0.707
      W[4'hb] <= 16'h39a8; // 0.707
      // W**6
      W[4'hc] <= 16'h0000; // 0
      W[4'hd] <= 16'h3c00; // 1
      // W**7
      W[4'he] <= 16'h39a8; // 0.707
      W[4'hf] <= 16'h39a8; // 0.707
  end
  
  always @(posedge clk)
      add_reg <= {1'b0,index};
  
  always @(posedge clk) begin
      // Output corresponding W 
      Wreal <= W[2*add_reg];
      Wimag <= W[2*add_reg+1];
  end

endmodule