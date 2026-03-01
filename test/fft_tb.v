`timescale 1ns / 1ns

module fft_tb;
    reg [255:0] in;
    reg clk, start, reset_n;
    wire [255:0] out;
    wire done;
    
    integer i; 

    fft_fp #(8, 32) uut (
        .inputs(in),
        .clk(clk), .start(start), .reset_n(reset_n),
        .outputs(out), .done(done)
    );

    always #5 clk = ~clk; // clock generation

    initial begin
        // Initialize inputs
        clk = 0; start = 0; reset_n = 0;
        in = 256'h0000000000000000000000000000000000000000000000000000000000000000;

        $dumpfile("outputs/fft.vcd");
        $dumpvars(0, fft_tb);

        // Apply test vector
        #5 start = 1; reset_n = 1;
        #5 in = 256'h3c0000004000000042000000440000004400000042000000400000003c000000; // 1, 2, 3, 4, 4, 3, 2, 1

        // Display Inputs
        $display("\n--- Time-Domain Digital Input Signal ---");
        for (i = 0; i < 8; i = i + 1) begin
            $display("x[%0d] = %h+j%h", 
                     i, 
                     in[(255 - i*32) -: 16],  // Top 16 bits (Real)
                     in[(239 - i*32) -: 16]); // Bottom 16 bits (Imaginary)
        end

        #500; 
        
        // Display Outputs
        $display("\n--- Frequency-Domain Digital Output Signal ---");
        for (i = 0; i < 8; i = i + 1) begin
            $display("X[%0d] = %h+j%h", 
                     i,  
                     out[(255 - i*32) -: 16], 
                     out[(239 - i*32) -: 16]);
        end

        $display("\n*** The result is being displayed in 16-bit floating point representation ***\n");
        $finish;
    end
endmodule