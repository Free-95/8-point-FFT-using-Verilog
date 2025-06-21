`timescale 1ns/1ns

module serializer_tb;
    reg clk, reset_n, start_serialize;
    reg [255:0] in; 
    wire output_valid, serialization_done;
    wire [15:0] out; 

    // Instantiate the serializer module
    serializer #(256, 16, 32) uut (
        .clk(clk), .reset_n(reset_n), .start_serialize(start_serialize),
        .input_data(in), .output_data(out),
        .output_valid(output_valid), .serialization_done(serialization_done)
    );

    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        start_serialize = 0;
        in = 0;

        $dumpfile("../outputs/serial.vcd");
        $dumpvars(0, serializer_tb);

        // Test input data
        in = 256'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
        
        // Deassert reset
        #5 reset_n = 1;
        
        // Start serialization
        #10 start_serialize = 1;
        
        // Wait for one clock cycle to process the start signal
        #10 start_serialize = 0;

        // Observe outputs for a few cycles
        repeat (18) begin
            #10; // Wait for clock cycles
            $display("Output Data: %h, Output Valid: %b, Serialization Done: %b", out, output_valid, serialization_done);
        end

        // Wait for a while to observe output
        #20;

        // Test with another input
        in = 256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;
        #10 start_serialize = 1; // Start serialization again
        #10 start_serialize = 0; // Clear start signal
        
        repeat (16) begin
            #10; // Wait for clock cycles
            $display("Output Data: %h, Output Valid: %b, Serialization Done: %b", out, output_valid, serialization_done);
        end
        
        // Finish simulation
        #20 $finish;
    end

    always #5 clk = ~clk; // Clock generation
endmodule