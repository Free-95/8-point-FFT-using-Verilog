`timescale 1ns / 1ps

module fpmad_sim();
    reg [31:0] num1, num2;
    reg [2:0] twiddle_index;
    reg clk;
    wire [31:0] result;

    cpx_mad uut(
        .num1(num1),
        .num2(num2),
        .twiddle_index(twiddle_index),
        .clk(clk),
        .result(result)
    );

    initial begin
        // Initialize inputs
        num1 = 32'h00000000;
        num2 = 32'h00000000;
        twiddle_index = 3'b000;
        clk = 0;

        // Open VCD file for waveform viewing
        $dumpfile("fpmad.vcd");
        $dumpvars(0, fpmad_sim);
        
        // Apply test vectors
        #10;
        num1 = 32'h3c000000; // 1
        num2 = 32'h44000000; // 4
        twiddle_index = 3'b000;
        #5 $display("num1: %h, num2: %h, twiddle_index: %b, result: %h", num1, num2, twiddle_index, result);

        // #5;
        // num1 = 32'hc200bc00; // -3-i
        // num2 = 32'hbc00c200; // -1-3i
        // twiddle_index = 3'b001;
        // #5 $display("num1: %h, num2: %h, twiddle_index: %b, result: %h", num1, num2, twiddle_index, result);

        // #5;
        // num1 = 32'hc2000000; // -3
        // num2 = 32'h3c000000; // 1
        // twiddle_index = 3'b010;
        // #5 $display("num1: %h, num2: %h, twiddle_index: %b, result: %h", num1, num2, twiddle_index, result);

        // #5;
        // num1 = 32'hc2003c00; // -3+i
        // num2 = 32'hbc004200; // -1+3i
        // twiddle_index = 3'b011;
        // #5 $display("num1: %h, num2: %h, twiddle_index: %b, result: %h", num1, num2, twiddle_index, result);

        // #5;
        // num1 = 32'h45000000; // 5
        // num2 = 32'h45000000; // 5
        // twiddle_index = 3'b100;
        // #5 $display("num1: %h, num2: %h, twiddle_index: %b, result: %h", num1, num2, twiddle_index, result);

        // #5;
        // num1 = 32'hc200bc00; // -3-i
        // num2 = 32'hbc00c200; // -1-3i
        // twiddle_index = 3'b101;
        // #5 $display("num1: %h, num2: %h, twiddle_index: %b, result: %h", num1, num2, twiddle_index, result);

        // #5;
        // num1 = 32'h00000000; // 0
        // num2 = 32'h00000000; // 0
        // twiddle_index = 3'b110;
        // #5 $display("num1: %h, num2: %h, twiddle_index: %b, result: %h", num1, num2, twiddle_index, result);

        // #5;
        // num1 = 32'hc2003c00; // -3+i
        // num2 = 32'hbc004200; // -1+3i
        // twiddle_index = 3'b111;
        // #5 $display("num1: %h, num2: %h, twiddle_index: %b, result: %h", num1, num2, twiddle_index, result);

        repeat (10) begin
            // Wait for a while to observe results
            #100 $display("num1: %h, num2: %h, twiddle_index: %b, result: %h", num1, num2, twiddle_index, result);
        end
        $finish; // End simulation
    end

    always #5 clk = ~clk; // Generate clock

endmodule