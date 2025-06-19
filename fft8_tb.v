`timescale 1ns / 1ps

module fft8_tb;
    reg [31:0] in1, in2, in3, in4, in5, in6, in7, in8;
    reg clk;
    wire [31:0] out1, out2, out3, out4, out5, out6, out7, out8;

    // Instantiate the 8-point FFT module
    fft8_fp dut (
        .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .in8(in8),
        .clk(clk),
        .out1(out1), .out2(out2), .out3(out3), .out4(out4), .out5(out5), .out6(out6), .out7(out7), .out8(out8)
    );

    always #5 clk = ~clk; // clock generation

    initial begin
        // Initialize inputs
        clk = 0;
        in1 = 32'h00000000; // 0 + 0i
        in2 = 32'h00000000; // 0 + 0i
        in3 = 32'h00000000; // 0 + 0i
        in4 = 32'h00000000; // 0 + 0i
        in5 = 32'h00000000; // 0 + 0i
        in6 = 32'h00000000; // 0 + 0i
        in7 = 32'h00000000; // 0 + 0i
        in8 = 32'h00000000; // 0 + 0i

        // Open VCD file for waveform viewing
        $dumpfile("outputs/fft8.vcd");
        $dumpvars(0, fft8_tb);

        // Apply test vectors
        #10;
        in1 = 32'h3c000000; // 1
        in2 = 32'h40000000; // 2
        in3 = 32'h42000000; // 3
        in4 = 32'h44000000; // 4
        in5 = 32'h44000000; // 4
        in6 = 32'h42000000; // 3
        in7 = 32'h40000000; // 2
        in8 = 32'h3c000000; // 1

<<<<<<< HEAD
        #1000 $finish;
=======
        // Apply test vectors
        #10;
        in1 = 32'h3c010000; // 1
        in2 = 32'h40450000; // 2
        in3 = 32'h42000640; // 3
        in4 = 32'h44030000; // 4
        in5 = 32'h44003020; // 4
        in6 = 32'h42004010; // 3
        in7 = 32'h40000401; // 2
        in8 = 32'h3c030303; // 1


        #1000 $finish;

        

>>>>>>> e06ec3024c0d1501268b5892eebf7a814c258ccb
    end
endmodule