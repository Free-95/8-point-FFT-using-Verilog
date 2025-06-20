module deserializer (
    input clk, reset_n, input_valid,     // Control signal: high when 'in' is valid
    input [INPUT_SIZE-1:0] in,
    output reg output_valid,    // Control signal: high for one cycle when 'out' is valid
    output reg [OUTPUT_SIZE-1:0] out 
);

    parameter INPUT_SIZE = 16;
    parameter OUTPUT_SIZE = 256;
    localparam NUM_OUTPUT_WORDS = OUTPUT_SIZE / INPUT_SIZE; // Number of words in the output array
    localparam INDEX_SIZE = $clog2(OUTPUT_SIZE); // Number of bits needed to index the output array

    /* Internal register to keep track of the current position in the 'out' array
       where the next incoming 'in' should be stored. */
    reg [INDEX_SIZE-1:0] index;


    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset condition:
            // - Clear the index to start filling from the first slot
            // - Reset output_valid
            // - Initialize all elements of the 'out' array to zero
            index <= 0;
            output_valid <= 0;
            out <= 0; 
        end 
        else begin
            /* Default output_valid to low. It will only be asserted high
               when the last piece of data (here, 8th) for the current group is received. */
            output_valid <= 0;

            // Check if there is valid input data available in the current clock cycle
            if (input_valid) begin
                // Store the incoming 32-bit data into the current slot of the 'out' array
                out[index +: INPUT_SIZE] <= in;

                // Check if this is the last word needed to complete the group of 8
                if (index == (OUTPUT_SIZE - INPUT_SIZE)) begin
                    /* If the last word has just been stored,
                       then all outputs are now valid and ready. */
                    output_valid <= 1; 
                    index <= 0; // Reset the index to start filling the array again from the first slot
                end 
                else begin
                    // If it's not the last word, increment the index
                    index <= index + INPUT_SIZE;
                end
            end

            // If input_valid is 0, no action is taken:
            // - index retains its current value
            // - 'out' array retains its current buffered contents
            // - output_valid remains low (as it's defaulted at the start of the always block)
        end
    end

endmodule
