//------------------------------------------------------------------------------------------
// Module: fft_fp
// Description: Implements a floating-point Fast Fourier Transform (FFT) for N points.
//   It uses a Decimation-in-Time (DIT) algorithm with bit-reversed input
//   ordering and normal output ordering. The computation is broken down
//   into multiple stages, each consisting of 2-point butterfly operations.
// Inputs:
//   - inputs [IO_SIZE-1:0]: Flattened input array of N complex numbers.
//   - clk: Clock signal for synchronous operations.
// Parameters:
//   - N: Number of points in the FFT (must be a power of 2, e.g., 8).
//   - WORD_SIZE: Bit width of each complex number (e.g., 32 for 16-bit real/imag parts).
// Outputs:
//   - outputs [IO_SIZE-1:0]: Flattened output array containing the N-point
//     FFT results in normal order.
//------------------------------------------------------------------------------------------

module fft_fp (
    input [IO_SIZE-1:0] inputs,
    input clk, start, reset_n,
    output reg [IO_SIZE-1:0] outputs,
    output reg done
);

/* --- PARAMETERS --- */
    parameter N = 8;
    localparam NUM_STAGES = $clog2(N); // Number of stages in the FFT
    
    parameter WORD_SIZE = 32;
    localparam IO_SIZE = N * WORD_SIZE; // Total size of the input and output arrays


/* --- INTERNAL REGISTERS --- */
    reg [IO_SIZE-1:0] num; // Array to hold the inputs
    wire [IO_SIZE-1:0] num_dit; // Array to hold the inputs in DIT order
    reg [WORD_SIZE-1:0] stage_results [(N*(NUM_STAGES+1)-1):0]; // Outputs of the butterfly stages
    // First N are Stage 0 results (dit-ordered inputs), next N are Stage 1 results, and so on

    reg [NUM_STAGES-1:0] twarray [N-1:0]; // Twiddle factor index array for the butterfly stages

    
/* --- INPUT DECIMATION --- */
    bit_reverse_mapper #(N, WORD_SIZE) br_mapper (
        .in(num),
        .out(num_dit)
    );


/* --- STATE MACHINE --- */    
    // States for controlling FFT computation
    localparam [1:0] 
        STATE_IDLE = 2'b00,
        STATE_LOAD_INPUTS = 2'b01,
        STATE_COMPUTE = 2'b10,
        STATE_DONE = 2'b11;

    reg [1:0] current_state, next_state;
    reg [NUM_STAGES-1:0] stage_counter; // Counter to track the current FFT stage 


    // State Machine Block
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin 
            current_state <= STATE_IDLE;
            stage_counter <= 0;
            done <= 0;
            outputs <= 0; 
        end 
        
        else begin
            current_state <= next_state;
            done <= 0; // Default to low
            
            case (current_state)
                STATE_IDLE: begin
                    if (start) begin
                        next_state <= STATE_LOAD_INPUTS;
                        stage_counter <= 0; // Start at stage 0
                    end 
                    else begin
                        next_state <= STATE_IDLE;
                    end
                end

                STATE_LOAD_INPUTS: begin
                    // Load the inputs into the num array
                    num <= inputs;

                    // Assign dit-ordered inputs to stage 0 results
                    for (integer i = 0; i < N; i = i + 1) begin
                        stage_results[i] <= num_dit[i*WORD_SIZE +: WORD_SIZE];
                    end

                    // Initialize twiddle array
                    for (integer i = 0; i < N; i = i + 1) begin
                        twarray[i] <= i;
                    end

                    next_state <= STATE_COMPUTE; 
                end

                STATE_COMPUTE: begin
                    // Continue computation until stage counter reaches last stage
                    if (stage_counter < NUM_STAGES) begin
                        stage_counter <= stage_counter + 1;
                        next_state <= STATE_COMPUTE;
                    end 
                    else begin
                        next_state <= STATE_DONE; // All stages complete
                    end
                end

                STATE_DONE: begin
                    // Assign the final results to outputs
                    for (integer i = 0; i < N; i = i + 1) begin
                        outputs[i*WORD_SIZE +: WORD_SIZE] <= stage_results[N*NUM_STAGES + i];
                    end

                    done <= 1; // Assert done for one cycle
                    next_state <= STATE_IDLE; // Go back to idle
                end

                default: next_state <= STATE_IDLE;
            endcase
        end
    end


/* --- FFT COMPUTATION --- */
    generate 
        genvar i,j;

        for (j = 0; j < NUM_STAGES; j = j + 1) begin : stage

            // For each stage, we need to compute N/2 2-point butterflies
            for (i = 0; i < (N/2); i = i + 1) begin : butterfly

                // Expression for twiddle index
                localparam integer twindex = (i * (2 ** (NUM_STAGES - 1 - j))) % (N/2);

                // Calculate the indices for butterfly inputs
                localparam integer common_term = (1 << j) * (i / (1 << j));
                localparam integer num1_idx = i + common_term + N*j;
                localparam integer num2_idx = i + common_term + (1 << j) + N*j;
                localparam integer result1_idx = i + common_term + N*(j+1);
                localparam integer result2_idx = i + common_term + (1 << j) + N*(j+1);
                /* These complicated index expressions give error if used directly in the
                   butterfly instantiation, so we calculate them first and then use them. */

                // Intermediate results for the butterfly computation
                wire [WORD_SIZE-1:0] result1, result2;

                butterfly2p #(N, WORD_SIZE) butterfly_inst (
                    .num1(stage_results[num1_idx]),
                    .num2(stage_results[num2_idx]),
                    .twiddle_index(twarray[twindex]), 
                    .clk(clk),
                    .result1(result1),
                    .result2(result2)
                );

                // Assign the results back to the stage_results array and increment stage counter
                always @(posedge clk) begin
                    if (current_state == STATE_COMPUTE && stage_counter == j) begin
                        stage_results[result1_idx] <= result1;
                        stage_results[result2_idx] <= result2;
                    end
                end
            end
        end
    endgenerate

endmodule