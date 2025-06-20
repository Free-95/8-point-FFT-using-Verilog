module deserializer_tb;

    reg clk;
    reg reset_n;
    reg input_valid;
    reg [15:0] in;
    wire output_valid;
    wire [255:0] out;

    // Instantiate the deserializer module
    deserializer #(16, 256) uut (
        .clk(clk),
        .reset_n(reset_n),
        .input_valid(input_valid),
        .in(in),
        .output_valid(output_valid),
        .out(out)
    );

    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        input_valid = 0;
        in = 0;

        $dumpfile("deserial.vcd");
        $dumpvars(0, deserializer_tb);

        // Deassert reset
        #5 reset_n = 1;
           input_valid = 1;

        // Send valid inputs
        repeat (16) begin
            #10 in = $random; // Random input for testing
            $display("Input: %h, Output: %h, Output Valid: %b", in, out, output_valid);
        end

        #10 input_valid = 0; // Clear input valid signal
        #10 in = $random; // Send one more input to check if deserializer handles it correctly

        // Wait for a while to observe output
        #50;

        // Finish simulation
        $finish;
    end

    always #5 clk = ~clk; // Clock generation
endmodule