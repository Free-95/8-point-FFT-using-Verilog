//----------------------------------------------------------------------------------------
// Module: serializer
// Description: Converts a wide, parallel input data array into a serial
//   stream of smaller output chunks. It operates based on a start signal
//   and provides valid and done signals after completion of process.
// Inputs:
//   - clk: Clock signal.
//   - reset_n: Asynchronous active-low reset signal.
//   - start_serialize: Control signal, asserted high for one cycle to
//     begin the serialization process.
//   - input_data [INPUT_SIZE-1:0]: Wide parallel input data array to be serialized.
// Parameters:
//   - INPUT_SIZE: Total bit width of the parallel input data.
//   - OUTPUT_SIZE: Bit width of each serial output chunk.
//   - WORD_SIZE: Bit width of a 'word' within the input data, influencing
//     how the `word_index` progresses for complex numbers (32 for
//     complex numbers where each part is 16 bits).
// Outputs:
//   - output_valid: Acknowledge signal, high for one cycle when 'output_data'
//     is valid and ready.
//   - output_data [OUTPUT_SIZE-1:0]: Serial output data chunk.
//   - serialization_done: Acknowledge signal, high for one cycle when the
//     entire 'input_data' array has been serialized.
//----------------------------------------------------------------------------------------

module serializer (
    input clk, reset_n, start_serialize,  
    input [INPUT_SIZE-1:0] input_data, 
    output reg output_valid,      
    output reg [OUTPUT_SIZE+INDEX_SIZE-1:0] output_data,   
    output reg serialization_done  
);

    parameter INPUT_SIZE = 256; 
    parameter OUTPUT_SIZE = 16;
    parameter WORD_SIZE = 32; 
    localparam NUM_OUTPUT_WORDS = INPUT_SIZE / OUTPUT_SIZE; 
    localparam INDEX_SIZE = $clog2(NUM_OUTPUT_WORDS);

    // Internal register to hold the input_data during serialization
    reg [INPUT_SIZE-1:0] internal_buffer;

    // Index register to keep track of which word is currently being outputted
    reg [$clog2(INPUT_SIZE)-1:0] word_index;

    reg [INDEX_SIZE-1:0] output_word_counter;

    // State machine for managing the serialization process
    localparam  STATE_IDLE = 1'b0,        // Waiting for start_serialize
                STATE_SERIALIZING = 1'b1; // Actively outputting data

    reg state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset condition:
            state <= STATE_IDLE;
            internal_buffer <= 0;
            word_index <= WORD_SIZE-1;
            output_word_counter <= 0;
            output_valid <= 0;
            output_data <= 0;
            serialization_done <= 0;
        end 
        else begin
            // Default outputs
            output_valid <= 0;
            serialization_done <= 0;

            case (state)
                STATE_IDLE: begin
                    // If start_serialize is asserted, load the input_data and reset index
                    if (start_serialize) begin
                        internal_buffer <= input_data;
                        word_index <= WORD_SIZE-1;
                        output_word_counter <= 0;
                        state <= STATE_SERIALIZING;
                        // output_valid and output_data will be set in the SERIALIZING state
                    end
                end
                STATE_SERIALIZING: begin
                    // Assert output_valid for the current chunk
                    output_valid <= 1;

                    output_data <= {output_word_counter, internal_buffer[word_index -: OUTPUT_SIZE]};

                    // Check if this is the last word to be outputted
                    if (word_index == (OUTPUT_SIZE - 1 + INPUT_SIZE - WORD_SIZE)) begin
                        serialization_done <= 1;
                        state <= STATE_IDLE; // Transition back to IDLE state
                        // word_index will be reset by the transition to IDLE state
                    end 
                    else begin
                        // Go to the start of the next word
                        if ((word_index + 1 - OUTPUT_SIZE) % WORD_SIZE == 0) begin
                            word_index <= word_index + 2*WORD_SIZE - OUTPUT_SIZE;
                            output_word_counter <= output_word_counter + 1;
                        end
                        // Decrement index to complete the current word
                        else
                            word_index <= word_index - OUTPUT_SIZE;
                    end
                end
                default: state <= STATE_IDLE;
                    // Default case to handle unexpected states
            endcase
        end
    end

endmodule