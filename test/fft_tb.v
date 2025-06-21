`timescale 1ns / 1ns

module fft_tb;
    reg [255:0] in;
    reg clk;
    wire [255:0] out;

    // Instantiate the 8-point FFT module
    fft_fp #(8, 32) uut (
        .inputs(in),
        .clk(clk),
        .outputs(out)
    );

    always #5 clk = ~clk; // clock generation

    initial begin
        // Initialize inputs
        clk = 0;
        in = 256'h00000000000000000000000000000000; // 0 + 0i for all 8 inputs

        // Open VCD file for waveform viewing
        $dumpfile("../outputs/fft.vcd");
        $dumpvars(0, fft_tb);

        // Apply test vector
        #10;
        in = 256'h3c0000004000000042000000440000004400000042000000400000003c000000; // 1, 2, 3, 4, 4, 3, 2, 1

        #1000 $display("Output: %h", out);
        $finish;
    end
endmodule