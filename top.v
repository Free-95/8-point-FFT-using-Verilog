module fft8_fp (
    input [31:0] in1, in2, in3, in4, in5, in6, in7, in8, // 8 complex numbers
    input clk,
    output reg [31:0] out1, out2, out3, out4, out5, out6, out7, out8 // 8 complex results
);

    wire [31:0] num [0:7]; // Array to hold the 8 complex inputs
    wire [31:0] stage_results [0:31]; // Outputs of each butterfly stage including dit mapped inputs
    // First 8 are Stage 0 results (dit mapped inputs), next 8 are Stage 1 results, and so on

    // Assign inputs to the array using continuous assignment
    assign num[0] = in1;
    assign num[1] = in2;
    assign num[2] = in3;
    assign num[3] = in4;
    assign num[4] = in5;
    assign num[5] = in6;
    assign num[6] = in7;
    assign num[7] = in8;

    always @(posedge clk) begin
        // Assign final results to outputs
        out1 <= stage_results[24];
        out2 <= stage_results[25];
        out3 <= stage_results[26];
        out4 <= stage_results[27];
        out5 <= stage_results[28];
        out6 <= stage_results[29];
        out7 <= stage_results[30];
        out8 <= stage_results[31];
    end

    // Instantiate the bit reverse mapper
    bit_reverse_mapper #(3) br_mapper (
        .in(num),
        .out(stage_results[0:7]) 
    );

    
    // Butterfly structure for 8-point FFT
    generate 
        genvar i,j,size;
        for (j = 0; j < 3; j = j + 1) begin : stage

            for (i = 0; i < 4; i = i + 1) begin : butterfly
                butterfly2p butterfly_inst (
                    .num1(stage_results[i + 2**j * $floor(i/2**j) + 8*j]),
                    .num2(stage_results[i + 2**j * $floor(i/2**j) + 1 + 8*j]),
                    .twiddle_index((i*(2**(2-j)))%4), 
                    .clk(clk),
                    .result1(stage_results[i + 2**j * $floor(i/2**j) + 8*(j+1)]),
                    .result2(stage_results[i + 2**j * $floor(i/2**j) + 1 + 8*(j+1)])
                );
            end
        end
    endgenerate

endmodule