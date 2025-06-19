module fft8_posit (
    input [31:0] in1, in2, in3, in4, in5, in6, in7, in8, // 8 complex inputs
    input clk,
    output reg [31:0] out1, out2, out3, out4, out5, out6, out7, out8 // 8 complex outputs
);

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
    butterfly2p_posit b10 (.num1(stage0[0]), .num2(stage0[1]), .twiddle_index(index[0]), .clk(clk), .result1(stage1[0]), .result2(stage1[1]));
    butterfly2p_posit b11 (.num1(stage0[2]), .num2(stage0[3]), .twiddle_index(index[0]), .clk(clk), .result1(stage1[2]), .result2(stage1[3]));
    butterfly2p_posit b12 (.num1(stage0[4]), .num2(stage0[5]), .twiddle_index(index[0]), .clk(clk), .result1(stage1[4]), .result2(stage1[5]));
    butterfly2p_posit b13 (.num1(stage0[6]), .num2(stage0[7]), .twiddle_index(index[0]), .clk(clk), .result1(stage1[6]), .result2(stage1[7]));

    // === Stage 2 (Distance 2) ===
    butterfly2p_posit b20 (.num1(stage1[0]), .num2(stage1[2]), .twiddle_index(index[0]), .clk(clk), .result1(stage2[0]), .result2(stage2[2]));
    butterfly2p_posit b21 (.num1(stage1[1]), .num2(stage1[3]), .twiddle_index(index[2]), .clk(clk), .result1(stage2[1]), .result2(stage2[3]));
    butterfly2p_posit b22 (.num1(stage1[4]), .num2(stage1[6]), .twiddle_index(index[0]), .clk(clk), .result1(stage2[4]), .result2(stage2[6]));
    butterfly2p_posit b23 (.num1(stage1[5]), .num2(stage1[7]), .twiddle_index(index[2]), .clk(clk), .result1(stage2[5]), .result2(stage2[7]));

    // === Stage 3 (Distance 4) ===
    butterfly2p_posit b30 (.num1(stage2[0]), .num2(stage2[4]), .twiddle_index(index[0]), .clk(clk), .result1(stage3[0]), .result2(stage3[4]));
    butterfly2p_posit b31 (.num1(stage2[1]), .num2(stage2[5]), .twiddle_index(index[1]), .clk(clk), .result1(stage3[1]), .result2(stage3[5]));
    butterfly2p_posit b32 (.num1(stage2[2]), .num2(stage2[6]), .twiddle_index(index[2]), .clk(clk), .result1(stage3[2]), .result2(stage3[6]));
    butterfly2p_posit b33 (.num1(stage2[3]), .num2(stage2[7]), .twiddle_index(index[3]), .clk(clk), .result1(stage3[3]), .result2(stage3[7]));

endmodule
