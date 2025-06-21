`timescale 1ns/1ns

module deserializer_tb;

    reg clk, reset_n, real_mode;
    reg input_valid;
    reg [15:0] in;
    wire output_valid;
    wire [255:0] out;

    // Instantiate the deserializer module
    deserializer #(16, 256, 32) uut (
        .clk(clk), .reset_n(reset_n), .real_mode(real_mode),
        .input_valid(input_valid),
        .in(in),
        .output_valid(output_valid),
        .out(out)
    );

    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        real_mode = 0;
        input_valid = 0;
        in = 0;

        $dumpfile("../outputs/deserial.vcd");
        $dumpvars(0, deserializer_tb);

        // Deassert reset
        #5 reset_n = 1;
           input_valid = 1;

        // Send valid inputs
        repeat (8) begin
            #10 in = $random; // Random input for testing
            $display("Mode: %b, Input: %h, Output: %h, Output Valid: %b", real_mode, in, out, output_valid);
        end

        real_mode = 1; // Go into real mode
        repeat (4) begin
            #10 in = $random; 
            $display("Mode: %b, Input: %h, Output: %h, Output Valid: %b", real_mode, in, out, output_valid);
        end

        real_mode = 0; // Return back to complex mode
        #10 in = $random;
        $display("Mode: %b, Input: %h, Output: %h, Output Valid: %b", real_mode, in, out, output_valid);

        #10 input_valid = 0; // Clear input valid signal
        // Send more inputs to check if deserializer handles it correctly
        #10 in = $random; 
        $display("Input: %h, Output: %h, Output Valid: %b", in, out, output_valid);
        $display("input_valid disabled");
        #10 in = $random; 
        $display("Input: %h, Output: %h, Output Valid: %b", in, out, output_valid);

        // Finish simulation
        $finish;
    end

    always #5 clk = ~clk; // Clock generation
endmodule