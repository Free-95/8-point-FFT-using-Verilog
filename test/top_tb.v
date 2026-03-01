module top_tb;
    reg [255:0] in;
    reg start, reset_n, clk;
    wire [34:0] serial_out;
    wire output_valid, done;

    top #(8,32,32) dut (
        .clk(clk),
        .start(start), .reset_n(reset_n),
        .input_data(in),
        .serial_out(serial_out),
        .output_valid(output_valid), .done(done)
    );

    initial begin
        // Initialize inputs
        clk = 0; start = 0; reset_n = 0; 
        in = 256'h00000000000000000000000000000000; // 0 + 0i for all inputs

        $dumpfile("outputs/top.vcd");
        $dumpvars(0, top_tb);

        #5 start = 1; reset_n = 1;

        // Apply test vector
        #5 start = 1; reset_n = 1;
        #5 in = 256'h3c0000004000000042000000440000004400000042000000400000003c000000; // 1, 2, 3, 4, 4, 3, 2, 1
        $display("\n--- Parallel Inputs ---");        
        for (integer i = 0; i < 8; i=i+1) begin
            $display("[%0d]: %h+j%h", i, in[(255-i*32) -: 16], in[(239-i*32) -: 16]);
        end

        #550 // Wait for the outputs to be stable
    
        $display("\n--- Serial Outputs ---");
        repeat (10) begin
            #10 $display("[%h]: %h+j%h, Valid: %b, Done: %b", serial_out[34:32], serial_out[31:16], serial_out[15:0], output_valid, done);
        end
        $display();
        #10 $finish;
    end

    always #5 clk = ~clk; // Clock generation
endmodule