`timescale 1ns / 1ns

module fft_tb;
    reg [255:0] in;
    reg clk, start, reset_n;
    wire [255:0] out;
    wire done;

    // Instantiate the 8-point FFT module
    fft_fp #(8, 32) uut (
        .inputs(in),
        .clk(clk), .start(start), .reset_n(reset_n),
        .outputs(out), .done(done)
    );

    always #5 clk = ~clk; // clock generation

    initial begin
        // Initialize inputs
        clk = 0; start = 0; reset_n = 0;
        in = 256'h00000000000000000000000000000000; // 0 + 0i for all 8 inputs

        // Open VCD file for waveform viewing
        $dumpfile("../outputs/fft.vcd");
        $dumpvars(0, fft_tb);

        // Apply test vector
        #5 start = 1; reset_n = 1;
        #5 in = 256'h3c0000004000000042000000440000004400000042000000400000003c000000; // 1, 2, 3, 4, 4, 3, 2, 1

        #500 $display("Output: %h", out);
        $finish;
    end
endmodule