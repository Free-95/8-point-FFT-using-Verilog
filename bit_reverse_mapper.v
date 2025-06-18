module bit_reverse_mapper #(parameter N = 3)(
    input  wire [2**N-1:0][31:0] in,
    output reg  [2**N-1:0][31:0] out
);

    // Function to reverse the bits of an N-bit index
    function [N-1:0] bit_reverse;
        input [N-1:0] index;
        integer i;
        begin
            for (i = 0; i < N; i = i + 1)
                bit_reverse[i] = index[N - 1 - i];
        end
    endfunction

    integer i;
    always @(*) begin
        for (i = 0; i < 2**N; i = i + 1)
            out[bit_reverse(i)] = in[i];
    end

endmodule
