//------------------------------------------------------------------------------
// Module: bit_reverse_mapper
// Description: Reorders a flattened input array into bit-reversed order.
// Inputs:
//   - in [(NUM_SIZE*N) - 1:0]: Flattened input array of N numbers, where
//     each number has a size of NUM_SIZE bits.
// Parameters:
//   - N: Number of elements in the array (e.g., 8 for an 8-point FFT)
//   - NUM_SIZE: Bit width of each number (e.g., 32 for 32-bit numbers)
// Outputs:
//   - out [(NUM_SIZE*N) - 1:0]: Flattened output array with elements
//     reordered according to their bit-reversed index.
//------------------------------------------------------------------------------

module bit_reverse_mapper #(parameter N = 8, NUM_SIZE = 32)(
    input [(NUM_SIZE*N) - 1:0] in,  
    output [(NUM_SIZE*N) - 1:0] out 
);

    localparam INDEX_SIZE = $clog2(N);

    function [INDEX_SIZE-1:0] bit_reverse;
        input [INDEX_SIZE-1:0] index;
        integer i;
        begin
            for (i = 0; i < INDEX_SIZE; i = i + 1)
                bit_reverse[i] = index[INDEX_SIZE - 1 - i];
        end
    endfunction

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_assign
            assign out[bit_reverse(i)*NUM_SIZE +: NUM_SIZE] = in[i*NUM_SIZE +: NUM_SIZE];
        end
    endgenerate

endmodule