`timescale 1ns / 1ns

module fp_multi_tb;
  reg [9:0] fra1, fra2;
  reg sign1, sign2;
  reg [4:0] exp1, exp2;
  reg clk; // Clock signal for the multiplier
  wire [15:0] result, num1, num2;
  wire overflow, zero, precisionLost;
  wire [9:0] res_fra, expected_fra;
  wire res_sign, nan, expected_sign;
  wire [4:0] res_exp, expected_exp;
  reg [15:0] result_expected;

  assign {res_sign, res_exp, res_fra} = result;
  assign num1 = {sign1, exp1, fra1};
  assign num2 = {sign2, exp2, fra2};

  float16_multi uut(num1, num2, clk, result, overflow, zero, nan, precisionLost);
  wire correct;

  assign correct = (result == result_expected);
  assign {expected_sign, expected_exp, expected_fra} = result_expected;

  task run_test;
    input [15:0] in1;
    input [15:0] in2;
    input [15:0] expected;
    input [319:0] test_name; // 40-character string for test description
    begin
      // Drive the inputs
      {sign1, exp1, fra1} = in1;
      {sign2, exp2, fra2} = in2;
      result_expected = expected;
      
      // Wait for multiplier logic to settle
      #100;
      
      // Display Results
      $display("--- %0s ---", test_name);
      $display("  Inputs  : Num1 = %h, Num2 = %h", in1, in2);
      $display("  Expected: %h | Actual: %h | Status: %s", expected, result, (correct ? "PASS" : "FAIL"));
      $display("  Flags   : Overflow = %b, Zero = %b, NaN = %b, PrecisionLost = %b\n", overflow, zero, nan, precisionLost);
    end
  endtask


  initial begin
    clk = 0;
      
    $dumpfile("../outputs/multi.vcd");
    $dumpvars(0, fp_multi_tb);
    $display();

    // Buggy cases
    run_test(16'h1234, 16'h9876, 16'h801b, "Test 1: Buggy Case 1");
    run_test(16'h8216, 16'h20be, 16'h8004, "Test 2: Buggy Case 2");

    // Multiplication with precision lost
    run_test({1'b0, 5'd21, 10'b10100101}, {1'b0, 5'd4, 10'b11001100}, 16'h2992, "Test 3: Precision Lost");

    // Different signs
    run_test({1'b1, 5'd16, 10'b10110000}, {1'b0, 5'd7, 10'b11000000}, 16'ha191, "Test 4: Different Signs (No Prec Lost)");

    // Multiplication with Zero
    run_test({1'b0, 5'd16, 10'b10110000}, {1'b0, 5'd0, 10'b0000000000}, 16'h0000, "Test 5: Multiplication with Zero");

    // Multiplication with Infinity
    run_test({1'b0, 5'd16, 10'b10110000}, {1'b0, 5'b11111, 10'b0000000000}, 16'h7c00, "Test 6: Multiplication with Infinity");

    // Multiplication of subnormal with normal
    run_test({1'b0, 5'd0, 10'b11100000}, {1'b0, 5'd20, 10'b01100000}, 16'h0fa8, "Test 7: Subnormal * Normal");

    // Multiplication of 2 subnormal numbers
    run_test({1'b0, 5'd0, 10'b10111000}, {1'b0, 5'd0, 10'b10000000}, 16'h0000, "Test 8: Subnormal * Subnormal");

    // Multiplication with NaN
    run_test({1'b0, 5'b01101, 10'b10100111}, {1'b0, 5'b11111, 10'b11111111}, 16'h7cff, "Test 9: Multiplication with NaN");

    // Multiplication of two negative numbers
    run_test({1'b1, 5'b11011, 10'b0111111001}, {1'b1, 5'b01010, 10'b1010111000}, 16'h5d04, "Test 10: Two Negative Numbers");

    // Multiplication of zero and infinite
    run_test({1'b1, 5'b11111, 10'b0000000000}, {1'b0, 5'b00000, 10'b0000000000}, 16'hfcff, "Test 11: Zero * Infinity");

    $display();
    $finish;
  end

  always #5 clk = ~clk; // Generate clock

endmodule