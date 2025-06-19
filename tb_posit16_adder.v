`timescale 1ns / 1ps

module posit_add_tb;

// Define the log2 function used in the posit_add module
// This function needs to be declared within the scope where parameters are defined based on it.
function [31:0] log2;
    input reg [31:0] value;
    begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end
endfunction

// Parameters of the posit_add module (must match the design)
parameter N = 16;
parameter Bs = log2(N);
parameter es = 2;

// Inputs to the DUT (Device Under Test)
reg [N-1:0] in1;
reg [N-1:0] in2;
reg start;

// Outputs from the DUT
wire [N-1:0] out;
wire inf;
wire zero;
wire done;

// Instantiate the posit_add module
posit_add #(
    .N(N),
    .es(es) // Only parameters directly used by posit_add need to be passed
) uut_posit_add (
    .in1(in1),
    .in2(in2),
    .start(start),
    .out(out),
    .inf(inf),
    .zero(zero),
    .done(done)
);

initial begin
    // Initialize inputs
    in1 = 16'h0000;
    in2 = 16'h0000;
    start = 1'b0;

    // Display header
    $display("--------------------------------------------------------------------------------------------------");
    $display("Posit Addition Testbench (N=%0d, es=%0d)", N, es);
    $display("Time\t Start\t In1 (hex)\t In2 (hex)\t Out (hex)\t Inf\t Zero\t Done");
    $display("--------------------------------------------------------------------------------------------------");
    
    // Test Case 1: 0 + 0 = 0
    // Expected: out = 0x0000, zero = 1, inf = 0
    #10;
    in1 = 16'h0000;
    in2 = 16'h0000;
    start = 1'b1;
    #1; // Wait a tiny bit for combinational logic to propagate
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0; // De-assert start
    #10;

    // Test Case 2: 1.0 + 0 = 1.0
    // Posit 16, es=2 for 1.0 is 0x4000 (0_1_00_00...0)
    // Expected: out = 0x4000, zero = 0, inf = 0
    #10;
    in1 = 16'h4000; // 1.0
    in2 = 16'h0000; // 0
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 3: 1.0 + 1.0 = 2.0
    // Posit 16, es=2 for 2.0 is 0x6000 (0_11_00_00...0)
    // Expected: out = 0x6000, zero = 0, inf = 0
    #10;
    in1 = 16'h4000; // 1.0
    in2 = 16'h4000; // 1.0
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 4: 1.0 + (-1.0) = 0
    // Posit 16, es=2 for -1.0 is 0xC000 (1_1_00_00...0)
    // Expected: out = 0x0000, zero = 1, inf = 0
    #10;
    in1 = 16'h4000; // 1.0
    in2 = 16'hC000; // -1.0
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 5: Infinity + 1.0 = Infinity
    // Posit 16, es=2 for Inf is 0x8000 (1_0_0...0)
    // Expected: out = 0x8000, zero = 0, inf = 1
    #10;
    in1 = 16'h8000; // Infinity
    in2 = 16'h4000; // 1.0
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 6: 0.5 + 0.5 = 1.0
    // Posit 16, es=2 for 0.5 is 0x2000 (0_01_00_00...0)
    // Expected: out = 0x4000, zero = 0, inf = 0
    #10;
    in1 = 16'h2000; // 0.5
    in2 = 16'h2000; // 0.5
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 7: Larger numbers (e.g., 4.0 + 4.0 = 8.0)
    // Posit 16, es=2 for 4.0 is 0x7000 (0_111_00_00...0)
    // Posit 16, es=2 for 8.0 is 0x7800 (0_1111_00_00...0) - This is getting into longer regimes
    // Note: Max k for N=16, es=2 is k=13 (1_1_1_1_1_1_1_1_1_1_1_1_1_1_00), 14 ones, then 2 exp bits.
    // Smallest number is 2^( -((N-2) - es) * 2^es ) = 2^( -(14-2)*4 ) = 2^(-48)
    // Largest number is 2^( ((N-2) - es) * 2^es - 1 ) = 2^( (14-2)*4 - 1 ) = 2^(47)
    #10;
    in1 = 16'h7000; // 4.0
    in2 = 16'h7000; // 4.0
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Add more test cases as needed for comprehensive verification
    // - Negative numbers
    // - Mixed signs
    // - Values close to the limits of the posit range
    // - Values that might trigger rounding
    // - Specific values that might expose edge cases in regime/exponent/mantissa handling

    $display("--------------------------------------------------------------------------------------------------");
    $display("Simulation Finished.");
    $finish;
end

endmodule