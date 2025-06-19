module cpx_mad_posit(
    input [31:0] num1, num2,
    input [2:0] twiddle_index,
    input clk,
    output reg [31:0] result
);

    reg [15:0] num1_real, num1_imag, num2_real, num2_imag;
    wire [15:0] twiddle_real, twiddle_imag;
    wire [15:0] mult_real1, mult_imag1, mult_real2, mult_imag2, mult_real, mult_imag;
    reg [15:0] real_part, imag_part;

    always @(posedge clk) begin
        num1_real <= num1[31:16];
        num1_imag <= num1[15:0];
        num2_real <= num2[31:16];
        num2_imag <= num2[15:0];
        real_part <= add_inst3.out;
        imag_part <= add_inst4.out;
        result <= {real_part, imag_part};
    end

    twiddleROM twiddle_inst(
        .index(twiddle_index),
        .en(1'b1), // Enable the ROM
        .clk(clk), 
        .Wreal(twiddle_real),
        .Wimag(twiddle_imag)
    );

    // Multiplication of num2 with twiddle factor
    // REAL PART
    posit_mult mult_inst1(
        .in1(twiddle_real),
        .in2(num2_real),
        .out(mult_real1),
        .inf(),
        .zero(),
        .start(),
        .done(),
        .clk(clk)
    );

    posit_mult mult_inst2(
        .in1(twiddle_imag),
        .in2(num2_imag),
        .out(mult_real2),
        .clk(clk),
        .inf(),
        .start(),
        .zero(),
        .done()
    );

    posit_add add_inst1(
        .in1(mult_real1),
        .in2({~mult_real2[15], mult_real2[14:0]}),
        .out(mult_real),
        .clk(clk),
        .start(),
        .zero(),
        .done()
    );

    // IMAGINARY PART
    posit_mult mult_inst3(
        .in1(twiddle_real),
        .in2(num2_imag),
        .out(mult_imag1),
        .start(),
        .inf(),
        .zero(),
        .done(),
        .clk(clk)
    );

    posit_mult mult_inst4(
        .in1(twiddle_imag),
        .in2(num2_real),
        .out(mult_imag2),
        .start(),
        .zero(),
        .inf(),
        .done(),
        .clk(clk)
    );

    posit_add add_inst2(
        .in1(mult_imag1),
        .in2(mult_imag2),    
        .out(mult_imag),
        .clk(clk),
        .start(),
        .zero(),
        .done(),
        .inf()
    );

    // Final addition of num1 with the product
    // REAL PART
    posit_add add_inst3(
        .in1(num1_real),
        .in2(mult_real), 
        .clk(clk),
        .out(),
        .inf(),
        .zero(),
        .done(),
        .start()
    );

    // IMAGINARY PART
    posit_add add_inst4(
        .in1(num1_imag),
        .in2(mult_imag), 
        .out(),
        .clk(clk),
        .out(),
        .inf(),
        .zero(),
        .done()
    );

endmodule