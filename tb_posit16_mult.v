`timescale 1ns / 1ps

module posit_mult_tb;

// Define the log2 function used in the posit_mult module
// This function needs to be declared within the scope where parameters are defined based on it.
function [31:0] log2;
    input reg [31:0] value;
    begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end
endfunction

// Parameters of the posit_mult module (must match the design)
parameter N = 16;
parameter Bs = log2(N);
parameter es = 3; // Ensure this matches the posit_mult module (it's 3 in your provided code)

// Inputs to the DUT (Device Under Test)
reg [N-1:0] in1;
reg [N-1:0] in2;
reg start;

// Outputs from the DUT
wire [N-1:0] out;
wire inf;
wire zero;
wire done;

// Instantiate the posit_mult module
// This is the ONLY module instantiated in this testbench
posit_mult #(
    .N(N),
    .es(es) // Pass the es parameter to the module
) uut_posit_mult (
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
    $display("Posit Multiplication Testbench (N=%0d, es=%0d)", N, es);
    $display("Time\t Start\t In1 (hex)\t In2 (hex)\t Out (hex)\t Inf\t Zero\t Done");
    $display("--------------------------------------------------------------------------------------------------");

    // Test Case 1: 0 * 1.0 = 0
    // Posit 16, es=3 for 1.0 is 0x4000
    // Expected: out = 0x0000, zero = 1, inf = 0
    #10;
    in1 = 16'h0000; // 0.0
    in2 = 16'h4000; // 1.0
    start = 1'b1;
    #1; // Wait a tiny bit for combinational logic to propagate
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0; // De-assert start
    #10;

    // Test Case 2: 1.0 * 1.0 = 1.0
    // Posit 16, es=3 for 1.0 is 0x4000
    // Expected: out = 0x4000, zero = 0, inf = 0
    #10;
    in1 = 16'h4000; // 1.0
    in2 = 16'h4000; // 1.0
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 3: 2.0 * 2.0 = 4.0
    // Posit 16, es=3 for 2.0 is 0x4800
    // Posit 16, es=3 for 4.0 is 0x4A00
    // Expected: out = 0x4A00, zero = 0, inf = 0
    #10;
    in1 = 16'h4800; // 2.0
    in2 = 16'h4800; // 2.0
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 4: 0.5 * 0.5 = 0.25
    // Posit 16, es=3 for 0.5 is 0x5C00
    // Posit 16, es=3 for 0.25 is 0x5800
    // Expected: out = 0x5800, zero = 0, inf = 0
    #10;
    in1 = 16'h5C00; // 0.5
    in2 = 16'h5C00; // 0.5
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 5: -1.0 * 2.0 = -2.0
    // Posit 16, es=3 for -1.0 is 0xC000
    // Posit 16, es=3 for 2.0 is 0x4800
    // Posit 16, es=3 for -2.0 is 0xC800
    // Expected: out = 0xC800, zero = 0, inf = 0
    #10;
    in1 = 16'hC000; // -1.0
    in2 = 16'h4800; // 2.0
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 6: Infinity * 1.0 = Infinity
    // Posit 16, es=3 for Inf is 0x8000
    // Expected: out = 0x8000, zero = 0, inf = 1
    #10;
    in1 = 16'h8000; // Infinity
    in2 = 16'h4000; // 1.0
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 7: 1.5 * 1.5 = 2.25 (Test for rounding)
    // Posit 16, es=3 for 1.5 is 0x4400
    // Posit 16, es=3 for 2.25 is 0x4900 (assuming RNE rounds correctly)
    // Expected: out = 0x4900, zero = 0, inf = 0
    #10;
    in1 = 16'h4400; // 1.5
    in2 = 16'h4400; // 1.5
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    // Test Case 8: Larger values - 128.0 * 2.0 = 256.0
    // Posit 16, es=3 for 128.0 is 0x5000 (0_10_111_0000000000)
    // Posit 16, es=3 for 256.0 is 0x6000 (0_110_000_0000000000)
    // Expected: out = 0x6000, zero = 0, inf = 0
    #10;
    in1 = 16'h5000; // 128.0
    in2 = 16'h4800; // 2.0
    start = 1'b1;
    #1;
    $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b", $time, start, in1, in2, out, inf, zero, done);
    start = 1'b0;
    #10;

    $display("--------------------------------------------------------------------------------------------------");
    $display("Simulation Finished.");
    $finish;
end

endmodule
