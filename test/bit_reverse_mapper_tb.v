`timescale 1ns / 1ns

module bit_reverse_mapper_tb;

    localparam N = 8;
    localparam SIZE = 32;

    reg [(SIZE*N)-1:0] in;
    wire [(SIZE*N)-1:0] out;

    // Instantiate the module
    bit_reverse_mapper #(N,SIZE) uut (
        .in(in),
        .out(out)
    );

    integer i;

    initial begin
        $dumpfile("../outputs/bitreverse.vcd"); 
        $dumpvars(0);

        // Initialize inputs with index value for visibility
        for (i = 0; i < N; i = i + 1) begin
            in[i*SIZE +: SIZE] = i;
        end

        #10; // Wait for outputs to settle

        // Display outputs
        $display("Input Index -> Output Index (bit-reversed)");
        for (i = 0; i < N; i = i + 1) begin
            $display("in[%0d]=%0d -> out[%0d]=%0d", 
                i, in[i*SIZE +: SIZE], i, out[i*SIZE +: SIZE]);
        end

        $finish;
    end

endmodule