`timescale 1ns/1ns

module tROM_tb;
  reg [2:0] index;
  reg en, clk;
  wire [15:0] Wreal, Wimag;

  twiddleROM dut (index, en, clk, Wreal, Wimag);

  initial begin
    $dumpfile("outputs/wave.vcd");
    $dumpvars(1,tROM_tb);

    index = 3'b000; en = 0; clk = 0;

    forever #5 clk = ~clk; // Clock Generation (10ns period)
  end

  initial begin
    // Initial state before any active clock edge or input change
    $display($time,": index = %d, en = %b, W = %h+j%h", index, en, Wreal, Wimag);

    #5 // At t=5, clk goes high (first active edge)
    en = 1'b1; index = 3'd0;
    $display($time,": index = %d, en = %b, W = %h+j%h", index, en, Wreal, Wimag);

    // Repeat loop to iterate through index values 1 to 7
    repeat (7) begin 
      #10
      index = index + 1; // Increment index 
      $display($time,": index = %d, en = %b, W = %h+j%h", index, en, Wreal, Wimag);
    end

    #10 $display($time,": index = %d, en = %b, W = %h+j%h", index, en, Wreal, Wimag);
    #10 $display($time,": index = %d, en = %b, W = %h+j%h", index, en, Wreal, Wimag);
    $finish; // End simulation
  end
endmodule