`timescale 1ns/1ns

module twiddleROM_tb;
  reg [2:0] index;
  reg clk;
  wire [15:0] Wreal, Wimag;

  twiddleROM dut (index, clk, Wreal, Wimag);

  initial begin
    $dumpfile("../outputs/tROM.vcd");
    $dumpvars(0,twiddleROM_tb);

    index = 3'b000; clk = 0;

    forever #5 clk = ~clk; // Clock Generation (10ns period)
  end

  initial begin
    // Initial state before any active clock edge or input change
    $display("Initial state: W = %h+j%h", Wreal, Wimag);

    #5 // At t=5, clk goes high (first active edge)
    index = 3'd0;
    #20 $display("index = %d, W = %h+j%h", index, Wreal, Wimag);

    // Repeat loop to iterate through index values 1 to 7
    repeat (7) begin 
      index = index + 1; // Increment index 
      #20 $display("index = %d, W = %h+j%h", index, Wreal, Wimag);
    end

    $finish; // End simulation
  end
endmodule