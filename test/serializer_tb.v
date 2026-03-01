`timescale 1ns/1ns

module serializer_tb;
    reg clk, reset_n, start_serialize;
    reg [255:0] in; 
    wire output_valid, serialization_done;
    wire [34:0] out;  // Output is 35 bits: 3-bit index (out[34:32]) + 32-bit data (out[31:0])

    serializer #(256, 32, 32) uut (
        .clk(clk), .reset_n(reset_n), .start_serialize(start_serialize),
        .input_data(in), .output_data(out),
        .output_valid(output_valid), .serialization_done(serialization_done)
    );

    always #5 clk = ~clk; // Clock generation

    integer i;

    task run_test;
        input [255:0] test_data;
        input [319:0] test_name; // 40-character string
        begin
            $display("\n--- %0s ---", test_name);
            
            in = test_data;

            // Display the 256-bit input (8 chunks of 32 bits)
            $display("\n[INPUT] 256-bit Parallel Data:");
            for (i = 0; i < 8; i = i + 1) begin
                $display("  Chunk[%0d] = %h", 
                         i, 
                         in[(255 - i*32) -: 32]); 
            end

            // Synchronize and start serialization
            @(posedge clk);
            start_serialize = 1;
            @(posedge clk);
            start_serialize = 0;

            $display("\n[OUTPUT] Serialized Data Stream:");
            
            // Observe outputs for 9 cycles to capture all 8 elements + done state
            for (i = 1; i <= 9; i = i + 1) begin
                @(posedge clk);
                
                if (output_valid) begin
                    $display("  Tick %0d | Valid: 1 | Done: %b | Index: %0d | Data: %h", 
                             i, serialization_done, out[34:32], out[31:0]);
                end else begin
                    $display("  Tick %0d | Valid: 0 | Done: %b | No valid data this cycle", i, serialization_done);
                end
            end
        end
    endtask


    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        start_serialize = 0;
        in = 0;

        $dumpfile("../outputs/serial.vcd");
        $dumpvars(0, serializer_tb);

        #15 reset_n = 1;
        
        // Run test
        run_test(256'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF, "Test 1: Incrementing Pattern");
        
        #20;
        
        run_test(256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210, "Test 2: Decrementing Pattern");

        // Finish simulation
        $display();
        #20 $finish;
    end
endmodule