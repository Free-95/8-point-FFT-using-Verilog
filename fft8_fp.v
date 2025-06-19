module fft8_fp (
    input [31:0] in1, in2, in3, in4, in5, in6, in7, in8, // 8 complex inputs
    input clk,
    output reg [31:0] out1, out2, out3, out4, out5, out6, out7, out8 // 8 complex outputs
);

<<<<<<< HEAD
    wire [31:0] num [0:7]; // Array to hold the inputs
    wire [31:0] num_dit [0:7]; // Array to hold the inputs in DIT order
    wire [31:0] stage1_result [0:7]; // Outputs of Stage 1
    wire [31:0] stage2_result [0:7]; // Outputs of Stage 2
    wire [31:0] stage3_result [0:7]; // Outputs of Stage 3

    assign num[0] = in1;
    assign num[1] = in2;
    assign num[2] = in3;
    assign num[3] = in4;
    assign num[4] = in5;
    assign num[5] = in6;
    assign num[6] = in7;
    assign num[7] = in8;

    always @(posedge clk) begin
        // Assign the final results to outputs
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
    bit_reverse_mapper #(3) br_mapper (
        .in(num),
        .out(num_dit)
    );

    // Butterfly stage 1
    butterfly2p butterfly1 (.num1(num_dit[0]), .num2(num_dit[1]), .twiddle_index(3'b000), .clk(clk), .result1(stage1_result[0]), .result2(stage1_result[1]));
    butterfly2p butterfly2 (.num1(num_dit[2]), .num2(num_dit[3]), .twiddle_index(3'b000), .clk(clk), .result1(stage1_result[2]), .result2(stage1_result[3]));
    butterfly2p butterfly3 (.num1(num_dit[4]), .num2(num_dit[5]), .twiddle_index(3'b000), .clk(clk), .result1(stage1_result[4]), .result2(stage1_result[5]));
    butterfly2p butterfly4 (.num1(num_dit[6]), .num2(num_dit[7]), .twiddle_index(3'b000), .clk(clk), .result1(stage1_result[6]), .result2(stage1_result[7]));

    // Butterfly stage 2
    butterfly2p butterfly5 (.num1(stage1_result[0]), .num2(stage1_result[2]), .twiddle_index(3'b000), .clk(clk), .result1(stage2_result[0]), .result2(stage2_result[2]));
    butterfly2p butterfly6 (.num1(stage1_result[1]), .num2(stage1_result[3]), .twiddle_index(3'b010), .clk(clk), .result1(stage2_result[1]), .result2(stage2_result[3]));
    butterfly2p butterfly7 (.num1(stage1_result[4]), .num2(stage1_result[6]), .twiddle_index(3'b000), .clk(clk), .result1(stage2_result[4]), .result2(stage2_result[6]));
    butterfly2p butterfly8 (.num1(stage1_result[5]), .num2(stage1_result[7]), .twiddle_index(3'b010), .clk(clk), .result1(stage2_result[5]), .result2(stage2_result[7]));

    // Butterfly stage 3
    butterfly2p butterfly9 (.num1(stage2_result[0]), .num2(stage2_result[4]), .twiddle_index(3'b000), .clk(clk), .result1(stage3_result[0]), .result2(stage3_result[4]));
    butterfly2p butterfly10 (.num1(stage2_result[1]), .num2(stage2_result[5]), .twiddle_index(3'b001), .clk(clk), .result1(stage3_result[1]), .result2(stage3_result[5]));
    butterfly2p butterfly11 (.num1(stage2_result[2]), .num2(stage2_result[6]), .twiddle_index(3'b010), .clk(clk), .result1(stage3_result[2]), .result2(stage3_result[6]));
    butterfly2p butterfly12 (.num1(stage2_result[3]), .num2(stage2_result[7]), .twiddle_index(3'b011), .clk(clk), .result1(stage3_result[3]), .result2(stage3_result[7]));

endmodule
=======
    // Internal input array
    wire [31:0] num [7:0];

    // Intermediate results after each stage
    wire [31:0] stage0 [7:0]; // bit-reversed input
    wire [31:0] stage1 [7:0];
    wire [31:0] stage2 [7:0];
    wire [31:0] stage3 [7:0]; // final output

    // Twiddle index map (customize as needed)
    reg [2:0] index [7:0];
    integer k;
    initial begin
        for (k = 0; k < 8; k = k + 1) begin
            index[k] = k[2:0];
        end
    end

    // Assign inputs
    assign num[0] = in1;
    assign num[1] = in2;
    assign num[2] = in3;
    assign num[3] = in4;
    assign num[4] = in5;
    assign num[5] = in6;
    assign num[6] = in7;
    assign num[7] = in8;

    // Assign final stage results to outputs
    always @(posedge clk) begin
        out1 <= stage3[0];
        out2 <= stage3[1];
        out3 <= stage3[2];
        out4 <= stage3[3];
        out5 <= stage3[4];
        out6 <= stage3[5];
        out7 <= stage3[6];
        out8 <= stage3[7];
    end

    // Bit-reverse the input
    bit_reverse_mapper #(3) br_mapper (
        .in(num),
        .out(stage0)
    );

    // === Stage 1 (Distance 1) ===
    butterfly2p b10 (.num1(stage0[0]), .num2(stage0[1]), .twiddle_index(index[0]), .clk(clk), .result1(stage1[0]), .result2(stage1[1]));
    butterfly2p b11 (.num1(stage0[2]), .num2(stage0[3]), .twiddle_index(index[0]), .clk(clk), .result1(stage1[2]), .result2(stage1[3]));
    butterfly2p b12 (.num1(stage0[4]), .num2(stage0[5]), .twiddle_index(index[0]), .clk(clk), .result1(stage1[4]), .result2(stage1[5]));
    butterfly2p b13 (.num1(stage0[6]), .num2(stage0[7]), .twiddle_index(index[0]), .clk(clk), .result1(stage1[6]), .result2(stage1[7]));

    // === Stage 2 (Distance 2) ===
    butterfly2p b20 (.num1(stage1[0]), .num2(stage1[2]), .twiddle_index(index[0]), .clk(clk), .result1(stage2[0]), .result2(stage2[2]));
    butterfly2p b21 (.num1(stage1[1]), .num2(stage1[3]), .twiddle_index(index[2]), .clk(clk), .result1(stage2[1]), .result2(stage2[3]));
    butterfly2p b22 (.num1(stage1[4]), .num2(stage1[6]), .twiddle_index(index[0]), .clk(clk), .result1(stage2[4]), .result2(stage2[6]));
    butterfly2p b23 (.num1(stage1[5]), .num2(stage1[7]), .twiddle_index(index[2]), .clk(clk), .result1(stage2[5]), .result2(stage2[7]));

    // === Stage 3 (Distance 4) ===
    butterfly2p b30 (.num1(stage2[0]), .num2(stage2[4]), .twiddle_index(index[0]), .clk(clk), .result1(stage3[0]), .result2(stage3[4]));
    butterfly2p b31 (.num1(stage2[1]), .num2(stage2[5]), .twiddle_index(index[1]), .clk(clk), .result1(stage3[1]), .result2(stage3[5]));
    butterfly2p b32 (.num1(stage2[2]), .num2(stage2[6]), .twiddle_index(index[2]), .clk(clk), .result1(stage3[2]), .result2(stage3[6]));
    butterfly2p b33 (.num1(stage2[3]), .num2(stage2[7]), .twiddle_index(index[3]), .clk(clk), .result1(stage3[3]), .result2(stage3[7]));

endmodule
>>>>>>> e06ec3024c0d1501268b5892eebf7a814c258ccb
