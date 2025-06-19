`timescale 1ns / 1ps

module posit_add_tb;

// Log2 Function
function [31:0] log2;
    input reg [31:0] value;
    begin
        value = value - 1;
        for (log2 = 0; value > 0; log2 = log2 + 1)
            value = value >> 1;
    end
endfunction

// Parameters
parameter N = 16;
parameter Bs = log2(N);
parameter es = 2;

// Inputs
reg clk;
reg [N-1:0] in1;
reg [N-1:0] in2;
reg start;

// Outputs
wire [N-1:0] out;
wire inf;
wire zero;
wire done;

// Instantiate the Device Under Test (DUT)
posit_add #(
    .N(N),
    .es(es)
) uut_posit_add (
    .clk(clk),
    .in1(in1),
    .in2(in2),
    .start(start),
    .out(out),
    .inf(inf),
    .zero(zero),
    .done(done)
);

// Clock Generation
initial clk = 0;
always #5 clk = ~clk; // 10ns clock period

// Display helper
task print_status;
    begin
        $display("%0t\t %b\t %h\t\t %h\t\t %h\t\t %b\t %b\t %b",
                 $time, start, in1, in2, out, inf, zero, done);
    end
endtask

initial begin
    // Header
    $display("--------------------------------------------------------------------------------------------------");
    $display("Posit Addition Testbench (N=%0d, es=%0d)", N, es);
    $display("Time\t Start\t In1 (hex)\t In2 (hex)\t Out (hex)\t Inf\t Zero\t Done");
    $display("--------------------------------------------------------------------------------------------------");

    // Initial values
    in1 = 16'h0000;
    in2 = 16'h0000;
    start = 1'b0;

    // Wait for 1 clock cycle
    @(posedge clk);

    // Test Case 1: 0 + 0
    in1 = 16'h0000;
    in2 = 16'h0000;
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge clk); print_status;

    // Test Case 2: 1.0 + 0
    in1 = 16'h4000;
    in2 = 16'h0000;
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge clk); print_status;

    // Test Case 3: 1.0 + 1.0
    in1 = 16'h4000;
    in2 = 16'h4000;
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge clk); print_status;

    // Test Case 4: 1.0 + (-1.0)
    in1 = 16'h4000;
    in2 = 16'hC000;
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge clk); print_status;

    // Test Case 5: Inf + 1.0
    in1 = 16'h8000;
    in2 = 16'h4000;
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge clk); print_status;

    // Test Case 6: 0.5 + 0.5
    in1 = 16'h2000;
    in2 = 16'h2000;
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge clk); print_status;

    // Test Case 7: 4.0 + 4.0
    in1 = 16'h7000;
    in2 = 16'h7000;
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge clk); print_status;

    // Finish
    $display("--------------------------------------------------------------------------------------------------");
    $display("Simulation Finished.");
    $finish;
end

endmodule
