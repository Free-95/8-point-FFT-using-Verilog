`timescale 1ns

module tb_bit_reverse_mapper;

    parameter N = 4;
    localparam SIZE = 2**N;

    reg  [SIZE-1:0][31:0] in;
    wire [SIZE-1:0][31:0] out;

    // Instantiate the module
    bit_reverse_mapper #(N) uut (
        .in(in),
        .out(out)
    );

    integer i;

    initial begin
        $dumpfile("waveform.vcd");   // name of the output file
        $dumpvars(0); // dump all variables in this module
        // Initialize inputs with index value for visibility
        for (i = 0; i < SIZE; i = i + 1) begin
            in[i] = i;
        end

        #10; // Wait for outputs to settle

        // Display outputs
        $display("Input Index -> Output Index (bit-reversed)");
        for (i = 0; i < SIZE; i = i + 1) begin
            $display("in[%0d]=%0d -> out[%0d]=%0d", 
                i, in[i], i, out[i]);
        end

        $finish;
    end

endmodule
