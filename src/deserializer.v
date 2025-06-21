//------------------------------------------------------------------------------
// Module: deserializer
// Description: Converts a serial stream of input data into a wider,
//   parallel output array. It can handle both real and complex input
//   data, assembling them into complex numbers of a specified WORD_SIZE.
//   For real-mode input, it pads the imaginary part with zeros.
// Inputs:
//   - clk: Clock signal.
//   - reset_n: Asynchronous active-low reset signal.
//   - input_valid: Control signal, high when 'in' is valid for sampling.
//   - real_mode: Control signal, high indicates 'in' is a real number;
//     low indicates 'in' is part of a complex number (alternating real/imag).
//   - in [INPUT_SIZE-1:0]: Serial input data.
// Parameters:
//   - INPUT_SIZE: Bit width of the incoming serial data.
//   - OUTPUT_SIZE: Total bit width of the parallel output array.
//   - WORD_SIZE: Bit width of each complex number in the output array
//     (real and imaginary parts each take WORD_SIZE/2).
// Outputs:
//   - output_valid: Acknowledge signal, high for one cycle when the
//     'out' array has been completely filled and is ready.
//   - out [OUTPUT_SIZE-1:0]: Parallel output array, containing
//     deserialized and possibly padded complex numbers.
//------------------------------------------------------------------------------

module deserializer (
    input clk, reset_n, input_valid,     
    input real_mode,            
    input [INPUT_SIZE-1:0] in,
    output reg output_valid,   
    output reg [OUTPUT_SIZE-1:0] out 
);

    parameter INPUT_SIZE = 16;
    parameter OUTPUT_SIZE = 256;
    parameter WORD_SIZE = 32;
    localparam NUM_OUTPUT_WORDS = OUTPUT_SIZE / INPUT_SIZE; // Number of words in the output array
    localparam INDEX_SIZE = $clog2(OUTPUT_SIZE); // Number of bits needed to index the output array

    /* Internal register to keep track of the current position in the 'out' array
       where the next incoming 'in' should be stored. */
    reg [INDEX_SIZE-1:0] index;


    always @(posedge clk or negedge reset_n) begin
        
        // Reset condition:
        // - Reset the index to start filling from the first slot
        // - Clear output_valid
        // - Initialize all elements of the 'out' array to zero    
        if (!reset_n) begin
            index <= WORD_SIZE-1;
            output_valid <= 0;
            out <= 0; 
        end 

        else begin
            /* Default output_valid to low. It will only be asserted high
               when the last piece of data for the current group of words is received. */
            output_valid <= 0;

            // Check if there is valid input data available in the current clock cycle
            if (input_valid && real_mode) begin     // REAL SIGNAL
                
                // Store the incoming data into the current slot of the 'out' array
                // If the slot is the last slot for real part of current word, pad zeros in the imaginary part
                if ((index + 1 - INPUT_SIZE - WORD_SIZE/2) % WORD_SIZE == 0)
                    out[index -: (INPUT_SIZE + (WORD_SIZE/2))] <= {in, { (WORD_SIZE/2){1'b0} }};
                else
                    out[index -: INPUT_SIZE] <= in;

                // Check if this is the last piece of real signal needed to complete the group 
                if (index == (OUTPUT_SIZE - 1 + INPUT_SIZE - WORD_SIZE/2)) begin
                    /* If the last piece has just been stored,
                       then all outputs are now valid and ready. */
                    output_valid <= 1; 
                    index <= WORD_SIZE-1; // Reset the index to start filling the array again from the first slot
                end 
                else begin
                    // Go to the start of the next word
                    if ((index + 1 - INPUT_SIZE - WORD_SIZE/2) % WORD_SIZE == 0)
                        index <= index + 3*WORD_SIZE/2 - INPUT_SIZE;
                    // Decrement index to complete the current word
                    else
                        index <= index - INPUT_SIZE;
                end
            end

            else if (input_valid && !real_mode) begin   // COMPLEX SIGNAL
                // Store the data
                out[index -: INPUT_SIZE] <= in;

                // Check for last piece
                if (index == (OUTPUT_SIZE - 1 + INPUT_SIZE - WORD_SIZE)) begin
                    output_valid <= 1; 
                    index <= WORD_SIZE-1; 
                end 
                else begin
                    // Start of next word
                    if ((index + 1 - INPUT_SIZE) % WORD_SIZE == 0)
                        index <= index + 2*WORD_SIZE - INPUT_SIZE;
                    else
                        index <= index - INPUT_SIZE;
                end
            end

            // If input_valid is 0, no action is taken:
            // - index retains its current value
            // - 'out' array retains its current buffered contents
            // - output_valid remains low (as it's defaulted at the start of the always block)
        end
    end

endmodule