`timescale 1ns/1ns

module butterfly2p_tb;
    reg [31:0] num1, num2;
    reg [2:0] twiddle_index;
    reg clk;
    wire [31:0] result1, result2;

    butterfly2p #(8, 32) uut(
        .num1(num1),
        .num2(num2),
        .twiddle_index(twiddle_index),
        .clk(clk),
        .result1(result1),
        .result2(result2)
    );

    initial begin
        // Initialize inputs
        num1 = 32'h00000000;
        num2 = 32'h00000000;
        twiddle_index = 3'b000;
        clk = 0;

        // Open VCD file for waveform viewing
        $dumpfile("../outputs/butterfly.vcd");
        $dumpvars(0, butterfly2p_tb);
        
        // Apply test vectors
        #10;
        num1 = 32'hc2000000; // -3
        num2 = 32'h3c000000; // 1
        twiddle_index = 3'b010;
        #60 $display("num1: %h, num2: %h, twiddle_index: %b, result1: %h, result2: %h", num1, num2, twiddle_index, result1, result2);

        #10 $finish;
    end

    always #5 clk = ~clk; // Clock generation
endmodule