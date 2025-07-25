//------------------------------------------------------------------------------
// Module: float16_adder
// Description: Performs addition of two 16-bit floating-point numbers.
//   It handles sign, exponent, and fraction parts, including alignment of 
//   exponents, addition/subtraction of significands, normalization, 
//   and rounding. 
//   It also provides flags for overflow, zero result, and Not-a-Number (NaN).
// Inputs:
//   - num1 [15:0]: First 16-bit floating-point input number.
//   - num2 [15:0]: Second 16-bit floating-point input number.
//   - clk: Clock signal.
// Outputs:
//   - result [15:0]: 16-bit floating-point sum of num1 and num2.
//   - overflow: High if the result exceeds the maximum representable value.
//   - zero: High if the result is positive or negative zero.
//   - NaN: High if either input is a Not-a-Number.
//   - precisionLost: High if any bits were truncated during the addition
//     due to right-shifting for exponent alignment.
//------------------------------------------------------------------------------

module float16_adder (
    input [15:0] num1, num2,
    input clk, 
    output reg [15:0] result,
    output overflow, 
    output zero, 
    output NaN, 
    output reg precisionLost
);

    // Intermediate result wire
    wire [15:0] resultt;

    // Reassigning numbers as big and small
    reg [15:0] bigNum, smallNum; //to separate big and small numbers
    wire [9:0] big_fra, small_fra; //to hold fraction part
    wire [4:0] big_ex_pre, small_ex_pre;
    wire [4:0] big_ex, small_ex; //to hold exponent part
    wire big_sig, small_sig; //to hold signs
    wire [10:0] big_float, small_float; //to hold as float number with integer
    
    reg [10:0] sign_small_float, shifted_small_float; //preparing small float
    wire [4:0] ex_diff; //difference between exponentials
    reg [9:0] sum_shifted; //Shift fraction part of sum
    reg [3:0] shift_am;
    wire neg_exp;

    // Extensions for higher precision
    reg [9:0] small_extension;
    wire [9:0] sum_extension;

    wire [10:0] sum; //sum of numbers with integer parts
    wire sum_carry;
    wire sameSign;
    wire zeroSmall;
    wire inf_num; //at least one of the operands is infinity.

    wire [4:0] res_exp_same_s, res_exp_diff_s;

    // Flags
    assign zero = (num1[14:0] == num2[14:0]) & (~num1[15] == num2[15]);
    assign overflow = ((&big_ex[4:1] & ~big_ex[0]) & sum_carry & sameSign) | inf_num;
    assign NaN = (&num1[14:10] & |num1[9:0]) | (&num2[14:10] & |num2[9:0]);
    assign inf_num = (&num1[14:10] & ~|num1[9:0]) | (&num2[14:10] & ~|num2[9:0]); //check for infinite number

    // Get result
    assign resultt[15] = big_sig; //result sign is same as bigger number sign
    assign res_exp_same_s = big_ex + {4'd0, (~zeroSmall & sum_carry & sameSign)} - {4'd0,({1'b0,result[9:0]} == sum)};
    assign res_exp_diff_s = (neg_exp | (shift_am == 4'd10)) ? 5'd0 : (~shift_am + big_ex + 5'd1);
    assign resultt[14:10] = ((sameSign) ? res_exp_same_s : res_exp_diff_s) | {5{overflow}}; //result exponent
    assign resultt[9:0] = ((zeroSmall) ? big_fra : ((sameSign) ? ((sum_carry) ? sum[10:1] : sum[9:0]) : ((neg_exp) ? 10'd0 : sum_shifted))) & {10{~overflow}};

    // Decode numbers
    assign {big_sig, big_ex_pre, big_fra} = bigNum;
    assign {small_sig, small_ex_pre, small_fra} = smallNum;
    assign sameSign = (big_sig == small_sig);
    assign zeroSmall = ~(|small_ex | |small_fra);
    assign big_ex = big_ex_pre + {4'd0, ~|big_ex_pre};
    assign small_ex = small_ex_pre + {4'd0, ~|small_ex_pre};

    // Add integer parts
    assign big_float = {|big_ex_pre, big_fra};
    assign small_float = {|small_ex_pre, small_fra};
    assign ex_diff = big_ex - small_ex; //difference between exponents
    assign {sum_carry, sum} = sign_small_float + big_float; //add numbers
    assign sum_extension = small_extension;

    // Get shift amount for subtraction
    assign neg_exp = (big_ex < shift_am);

    always @(posedge clk)
      result <= resultt; //assign result on clock edge

    always@(*) begin
        casex(sum)
            11'b1xxxxxxxxxx: shift_am = 4'd0;
            11'b01xxxxxxxxx: shift_am = 4'd1;
            11'b001xxxxxxxx: shift_am = 4'd2;
            11'b0001xxxxxxx: shift_am = 4'd3;
            11'b00001xxxxxx: shift_am = 4'd4;
            11'b000001xxxxx: shift_am = 4'd5;
            11'b0000001xxxx: shift_am = 4'd6;
            11'b00000001xxx: shift_am = 4'd7;
            11'b000000001xx: shift_am = 4'd8;
            11'b0000000001x: shift_am = 4'd9;
            default: shift_am = 4'd10;
        endcase
    end

    // Shift result for subtraction
    always@(*) begin
        case (shift_am)
            4'd0: sum_shifted =  sum[9:0];
            4'd1: sum_shifted = {sum[8:0],sum_extension[9]};
            4'd2: sum_shifted = {sum[7:0],sum_extension[9:8]};
            4'd3: sum_shifted = {sum[6:0],sum_extension[9:7]};
            4'd4: sum_shifted = {sum[5:0],sum_extension[9:6]};
            4'd5: sum_shifted = {sum[4:0],sum_extension[9:5]};
            4'd6: sum_shifted = {sum[3:0],sum_extension[9:4]};
            4'd7: sum_shifted = {sum[2:0],sum_extension[9:3]};
            4'd8: sum_shifted = {sum[1:0],sum_extension[9:2]};
            4'd9: sum_shifted = {sum[0],  sum_extension[9:1]};
            default: sum_shifted = sum_extension;
        endcase
        
        case (shift_am)
            4'd0: precisionLost = |sum_extension;
            4'd1: precisionLost = |sum_extension[8:0];
            4'd2: precisionLost = |sum_extension[7:0];
            4'd3: precisionLost = |sum_extension[6:0];
            4'd4: precisionLost = |sum_extension[5:0];
            4'd5: precisionLost = |sum_extension[4:0];
            4'd6: precisionLost = |sum_extension[3:0];
            4'd7: precisionLost = |sum_extension[2:0];
            4'd8: precisionLost = |sum_extension[1:0];
            4'd9: precisionLost = |sum_extension[0];
            default: precisionLost = 1'b0;
        endcase
    end

    // Take small number to exponent of big number
    always@(*) begin
        case (ex_diff)
            5'h0: {shifted_small_float,small_extension} = {small_float,10'd0};
            5'h1: {shifted_small_float,small_extension} = {small_float,9'd0};
            5'h2: {shifted_small_float,small_extension} = {small_float,8'd0};
            5'h3: {shifted_small_float,small_extension} = {small_float,7'd0};
            5'h4: {shifted_small_float,small_extension} = {small_float,6'd0};
            5'h5: {shifted_small_float,small_extension} = {small_float,5'd0};
            5'h6: {shifted_small_float,small_extension} = {small_float,4'd0};
            5'h7: {shifted_small_float,small_extension} = {small_float,3'd0};
            5'h8: {shifted_small_float,small_extension} = {small_float,2'd0};
            5'h9: {shifted_small_float,small_extension} = {small_float,1'd0};
            5'ha: {shifted_small_float,small_extension} = small_float;
            5'hb: {shifted_small_float,small_extension} = small_float[10:1];
            5'hc: {shifted_small_float,small_extension} = small_float[10:2];
            5'hd: {shifted_small_float,small_extension} = small_float[10:3];
            5'he: {shifted_small_float,small_extension} = small_float[10:4];
            5'hf: {shifted_small_float,small_extension} = small_float[10:5];
            5'h10: {shifted_small_float,small_extension} = small_float[10:5];
            5'h11: {shifted_small_float,small_extension} = small_float[10:6];
            5'h12: {shifted_small_float,small_extension} = small_float[10:7];
            5'h13: {shifted_small_float,small_extension} = small_float[10:8];
            5'h14: {shifted_small_float,small_extension} = small_float[10:9];
            5'h15: {shifted_small_float,small_extension} = small_float[10];
            5'h16: {shifted_small_float,small_extension} = 0;
        endcase
    end

    always@(*) //if signs are different take 2's compliment of small number
        begin
            if(sameSign) begin
                sign_small_float = shifted_small_float;
            end
            else begin
                sign_small_float = ~shifted_small_float + 11'b1;
            end
        end

    always@(*) //determine big number
        begin
            if(num2[14:10] > num1[14:10]) begin
                bigNum = num2;
                smallNum = num1;
            end
            else if(num2[14:10] == num1[14:10]) begin
                if(num2[9:0] > num1[9:0]) begin
                    bigNum = num2;
                    smallNum = num1;
                end
                else begin
                    bigNum = num1;
                    smallNum = num2;
                end
            end
            else begin
                bigNum = num1;
                smallNum = num2;
            end
        end

endmodule