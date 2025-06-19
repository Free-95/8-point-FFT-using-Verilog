module fft8_fp (
    input [31:0] in1, in2, in3, in4, in5, in6, in7, in8, // 8 complex numbers
    input clk,
    output reg [31:0] out1, out2, out3, out4, out5, out6, out7, out8 // 8 complex results
);

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