module bit_reverse_mapper #(parameter N = 3)(
    input wire [31:0] in [0:2**N-1], // Input array of 2^N complex numbers
    output reg  [31:0] out [0:2**N-1] // Output array of 2^N complex numbers
);

    // Function to reverse the bits of an N-bit index
    function [0:N-1] bit_reverse; // Return type width
        input [0:N-1] index;      // Input argument width
        reg [0:N-1] reversed_index; // Local register to build the result bit by bit
        integer i;
        begin
            for (i = 0; i < N; i = i + 1) begin
                reversed_index[i] = index[N - 1 - i]; // Build result in local reg
            end
            bit_reverse = reversed_index; // Assign the final result to the function name
        end
    endfunction

    integer i;
    always @(*) begin // This is a combinational block
        for (i = 0; i < 2**N; i = i + 1) begin
            out[bit_reverse(i)] = in[i]; // Assign based on bit-reversed index
        end
    end

endmodule