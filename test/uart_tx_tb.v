//------------------------------------------------------------------------------
// Testbench for parameterized uart_tx module
// Verifies the functionality of the UART transmitter for different data widths.
// This testbench adheres to Verilog-2001 standard.
//------------------------------------------------------------------------------

`timescale 1ns / 1ps // Define timescale for simulation

module uart_tx_tb;

    // --- Testbench Parameters ---
    parameter CLK_PERIOD       = 10;   // Clock period in ns (e.g., 10ns for 100MHz clock)
    parameter CLKS_PER_BIT_VAL = 1;   // Number of clock cycles per UART bit for simulation
                                       // (Set low for fast simulation).


    // --- Testbench Signals for 8-bit UART TX ---
    reg        tb_i_Clock_8bit;
    reg        tb_i_Tx_DV_8bit;
    reg  [7:0] tb_i_Tx_Data_8bit;

    wire       tb_o_Tx_Active_8bit;
    wire       tb_o_Tx_Serial_8bit;
    wire       tb_o_Tx_Done_8bit;

    // --- Testbench Signals for 16-bit UART TX ---
    reg        tb_i_Clock_16bit;
    reg        tb_i_Tx_DV_16bit;
    reg [15:0] tb_i_Tx_Data_16bit;

    wire       tb_o_Tx_Active_16bit;
    wire       tb_o_Tx_Serial_16bit;
    wire       tb_o_Tx_Done_16bit;


    // --- Instantiate the Unit Under Test (DUT) - 8-bit configuration ---
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT_VAL),
        .DATA_BITS   (8) // Transmit 8 bits
    ) u_uart_tx_8bit (
        .i_Clock    (tb_i_Clock_8bit),
        .i_Tx_DV    (tb_i_Tx_DV_8bit),
        .i_Tx_Data  (tb_i_Tx_Data_8bit),
        .o_Tx_Active(tb_o_Tx_Active_8bit),
        .o_Tx_Serial(tb_o_Tx_Serial_8bit),
        .o_Tx_Done  (tb_o_Tx_Done_8bit)
    );

    // --- Instantiate the Unit Under Test (DUT) - 16-bit configuration ---
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT_VAL),
        .DATA_BITS   (16) // Transmit 16 bits
    ) u_uart_tx_16bit (
        .i_Clock    (tb_i_Clock_16bit),
        .i_Tx_DV    (tb_i_Tx_DV_16bit),
        .i_Tx_Data  (tb_i_Tx_Data_16bit),
        .o_Tx_Active(tb_o_Tx_Active_16bit),
        .o_Tx_Serial(tb_o_Tx_Serial_16bit),
        .o_Tx_Done  (tb_o_Tx_Done_16bit)
    );


    // --- Clock Generation for 8-bit instance ---
    always #((CLK_PERIOD / 2)) tb_i_Clock_8bit = ~tb_i_Clock_8bit;

    // --- Clock Generation for 16-bit instance ---
    always #((CLK_PERIOD / 2)) tb_i_Clock_16bit = ~tb_i_Clock_16bit;


    // --- Test Scenario ---
    initial begin
        // Initialize inputs for 8-bit instance
        tb_i_Clock_8bit   = 1'b0;
        tb_i_Tx_DV_8bit   = 1'b0;
        tb_i_Tx_Data_8bit = 8'b0;

        // Initialize inputs for 16-bit instance
        tb_i_Clock_16bit   = 1'b0;
        tb_i_Tx_DV_16bit   = 1'b0;
        tb_i_Tx_Data_16bit = 16'b0;

        $display("---------------------------------------");
        $display(" Starting parameterized uart_tx Testbench ");
        $display(" CLK_PERIOD: %0d ns, CLKS_PER_BIT: %0d", CLK_PERIOD, CLKS_PER_BIT_VAL);
        $display("---------------------------------------");

        // Wait a few clock cycles for initial stabilization
        @(posedge tb_i_Clock_8bit); // Sync both to the same initial clock edge
        repeat(5) @(posedge tb_i_Clock_8bit);
        
        $display("%0t: Initial state. Waiting for transmission requests.", $time);
        $display("---------------------------------------");

        // --- Test Case 1: Send 8-bit byte 0x55 (0101_0101b) ---
        tb_i_Tx_Data_8bit = 8'h55;
        tb_i_Tx_DV_8bit = 1'b1; // Assert data valid for one cycle
        @(posedge tb_i_Clock_8bit);
        tb_i_Tx_DV_8bit = 1'b0; // De-assert data valid
        $display("%0t: [8-bit TX] Sent byte: 0x%h", $time, tb_i_Tx_Data_8bit);

        // Wait for 8-bit transmission to complete
        @(posedge tb_o_Tx_Done_8bit);
        $display("%0t: [8-bit TX] Transmission for 0x%h done.", $time, tb_i_Tx_Data_8bit);
        $display("---------------------------------------");

        // Wait in IDLE for a few cycles for both
        repeat(CLKS_PER_BIT_VAL * 2) @(posedge tb_i_Clock_8bit);
        $display("%0t: Idle period after 8-bit transmission.", $time);


        // --- Test Case 2: Send 16-bit word 0xDEAD (1101_1110_1010_1101b) ---
        tb_i_Tx_Data_16bit = 16'hDEAD;
        tb_i_Tx_DV_16bit = 1'b1; // Assert data valid for one cycle
        @(posedge tb_i_Clock_16bit);
        tb_i_Tx_DV_16bit = 1'b0; // De-assert data valid
        $display("%0t: [16-bit TX] Sent word: 0x%h", $time, tb_i_Tx_Data_16bit);

        // Wait for 16-bit transmission to complete
        @(posedge tb_o_Tx_Done_16bit);
        $display("%0t: [16-bit TX] Transmission for 0x%h done.", $time, tb_i_Tx_Data_16bit);
        $display("---------------------------------------");


        // End simulation
        #100; // Small delay to let signals settle
        $display("%0t: Testbench finished.", $time);
        $finish; // Standard Verilog system task to end simulation
    end

    // --- Waveform Dumping (Optional, for detailed debugging) ---
    // $dumpfile and $dumpvars are standard Verilog-2001 system tasks
    // initial begin
    //     $dumpfile("uart.vcd");
    //     $dumpvars(0, uart_tx_tb); // Dump all variables in the testbench
    // end

endmodule