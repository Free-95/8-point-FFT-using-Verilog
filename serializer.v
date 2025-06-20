module serializer (
    input clk, reset_n, start_serialize,     // Control signal: Assert high for one cycle to start serialization
    input [INPUT_SIZE-1:0] input_data, 
    output reg output_valid,        // Control signal: High when 'output_data' is valid
    output reg [OUTPUT_SIZE-1:0] output_data,   
    output reg serialization_done   // High for one cycle when entire input array has been serialized
);

    parameter INPUT_SIZE = 256; 
    parameter OUTPUT_SIZE = 16; 
    localparam NUM_OUTPUT_WORDS = INPUT_SIZE / OUTPUT_SIZE; 

    // Index vector size needed to index all input words
    localparam INDEX_SIZE = $clog2(INPUT_SIZE);

    // Internal register to hold the input_data during serialization
    reg [INPUT_SIZE-1:0] internal_buffer;

    // Index register to keep track of which word is currently being outputted
    reg [INDEX_SIZE-1:0] word_index;

    // State machine for managing the serialization process
    localparam  STATE_IDLE = 1'b0,        // Waiting for start_serialize
                STATE_SERIALIZING = 1'b1; // Actively outputting data

    reg state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset condition:
            state <= STATE_IDLE;
            internal_buffer <= 0;
            word_index <= 0;
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
                        word_index <= 0;
                        state <= STATE_SERIALIZING;
                        // output_valid and output_data will be set in the SERIALIZING state
                    end
                end
                STATE_SERIALIZING: begin
                    // Assert output_valid for the current chunk
                    output_valid <= 1;

                    output_data <= internal_buffer[word_index +: OUTPUT_SIZE];

                    // Check if this is the last word to be outputted
                    if (word_index == (INPUT_SIZE - OUTPUT_SIZE)) begin
                        serialization_done <= 1;
                        state <= STATE_IDLE; // Transition back to IDLE state
                        // word_index will be reset to 0 by the transition to IDLE state
                    end 
                    else begin
                        // Increment the index to point to the next word for the next cycle
                        word_index <= word_index + OUTPUT_SIZE;
                    end
                end
                default: state <= STATE_IDLE;
                    // Default case to handle unexpected states
            endcase
        end
    end

endmodule
