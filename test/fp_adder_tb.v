`timescale 1ns / 1ns

module fp_adder_tb;
  reg [9:0] fra1, fra2;
  reg sign1, sign2;
  reg [4:0] exp1, exp2;
  reg clk; // Clock signal for the adder
  wire [15:0] result, num1, num2;
  wire overflow, zero;
  wire [9:0] res_fra, expected_fra;
  wire res_sign, nan, precisionLost, expected_sign;
  wire [4:0] res_exp, expected_exp;

  assign {res_sign, res_exp, res_fra} = result;
  assign num1 = {sign1, exp1, fra1};
  assign num2 = {sign2, exp2, fra2};

  float16_adder uut(num1, num2, clk, result, overflow, zero, nan, precisionLost);

  wire correct;
  reg [15:0] result_expected;

  assign correct = (result_expected == result);
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
      
      // Wait for adder logic to settle
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
      
    $dumpfile("outputs/adder.vcd");
    $dumpvars(1, fp_adder_tb);
    $display();

    // Basic additions
    run_test(16'h00e0, 16'h5060, 16'h5060, "Test 1: Basic Addition 1");
    run_test(16'h00b8, 16'h0080, 16'h0138, "Test 2: Basic Addition 2");
    
    // Addition with precision lost
    run_test({1'b0, 5'd21, 10'b10100101}, {1'b0, 5'd14, 10'b11001100}, 16'h54ae, "Test 3: Addition with Precision Lost");
    
    // Addition of two numbers with same exponent
    run_test({1'b0, 5'd4, 10'b10100000}, {1'b0, 5'd4, 10'b01101100}, 16'h1486, "Test 4: Same Exponent");
    
    // Addition with different signs without precision lost
    run_test({1'b0, 5'd5, 10'b10101100}, {1'b1, 5'd6, 10'b00101101}, 16'h935c, "Test 5: Different Signs");
    
    run_test({1'b1, 5'd13, 10'b00001100}, {1'b0, 5'd13, 10'b11101100}, 16'h2b00, "Test 6: Sign cancellation test 1");
    
    run_test({1'b1, 5'd30, 10'b10101010}, {1'b0, 5'd30, 10'b10101100}, 16'h5400, "Test 7: Sign cancellation test 2");
    
    // Zero flag test
    run_test({1'b1, 5'd25, 10'b10011101}, {1'b0, 5'd25, 10'b10011101}, 16'h8000, "Test 8: Zero Flag test (Result = -0)");

    // NaN flag test
    run_test({1'b0, 5'b10001, 10'b0011111111}, {1'b0, 5'b11111, 10'b0011111111}, 16'h7cff, "Test 9: NaN Flag Test");

    // Overflow flag test
    run_test({1'b0, 5'b11110, 10'b1111111111}, {1'b0, 5'b11110, 10'b1111111111}, 16'h7c00, "Test 10: Overflow Flag Test");
  
    // Inf + Num Test
    run_test({1'b0, 5'b11111, 10'b0000000000}, {1'b0, 5'b10010, 10'b1110000011}, 16'h7c00, "Test 11: Infinity + Number Test");

    $display();
    $finish;
  end

  always #5 clk = ~clk; // Generate clock

endmodule