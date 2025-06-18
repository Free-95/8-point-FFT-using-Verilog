module fft8_fp (
    input [31:0] in1, in2, in3, in4, in5, in6, in7, in8, // 8 complex numbers
    input clk,
    output reg [31:0] out1, out2, out3, out4, out5, out6, out7, out8 // 8 complex results
);

    wire [31:0] num_dit [0:7]; // Array to hold the inputs in DIT order
    wire [31:0] stage1_result [0:7]; // Outputs of Stage 1
    wire [31:0] stage2_result [0:7]; // Outputs of Stage 2
    wire [31:0] stage3_result [0:7]; // Outputs of Stage 3

    assign num_dit[0] = in1;
    assign num_dit[1] = in5;
    assign num_dit[2] = in3;
    assign num_dit[3] = in7;
    assign num_dit[4] = in2;
    assign num_dit[5] = in6;
    assign num_dit[6] = in4;
    assign num_dit[7] = in8;

    always @(posedge clk) begin
        // Assign final results to outputs
        out1 <= stage3_result[0];
        out2 <= stage3_result[1];
        out3 <= stage3_result[2];
        out4 <= stage3_result[3];
        out5 <= stage3_result[4];
        out6 <= stage3_result[5];
        out7 <= stage3_result[6];
        out8 <= stage3_result[7];
    end

    // Instantiate the bit reverse mapper
    // bit_reverse_mapper #(3) br_mapper (
    //     .in(num),
    //     .out(stage_results[0:7]) 
    // );



    // Butterfly Stage 1
    generate 
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin : stage1
            butterfly2p butterfly_inst (
                .num1(num_dit[2*i]),
                .num2(num_dit[2*i + 1]),
                .twiddle_index(3'b000), 
                .clk(clk),
                .result1(stage1_result[2*i]),
                .result2(stage1_result[2*i + 1])
            );
        end
    endgenerate

    // Butterfly Stage 2
    generate 
        genvar j;
        for (j = 0; j < 4; j = j + 1) begin : stage2
            butterfly2p butterfly_inst2 (
                .num1(stage1_result[(j<2) ? j : j + 2]),
                .num2(stage1_result[(j<2) ? j+2 : j+4]),
                .twiddle_index(3'b001), 
                .clk(clk),
                .result1(stage2_result[4*j]),
                .result2(stage2_result[4*j + 1])
            );
        end
    endgenerate
endmodule