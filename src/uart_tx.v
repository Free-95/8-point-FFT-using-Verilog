//------------------------------------------------------------------------------
// Module: uart_tx
// Description: This UART Transmitter is able to transmit DATA_BITS of serial data,
//              one start bit, one stop bit, and no parity bit.
//              When transmit is complete, o_Tx_Done will be driven high for one clock cycle.
//
// Parameters:
//   - CLKS_PER_BIT: Number of clock cycles per UART bit.
//                   CLKS_PER_BIT = (Frequency of i_Clock) / (Frequency of UART)
//                   Example: 10 MHz Clock, 115200 baud UART -> (10000000)/(115200) = 87
//   - DATA_BITS: The number of data bits to transmit per transaction (e.g., 8, 16, 32).
//------------------------------------------------------------------------------
 
module uart_tx #(
    parameter CLKS_PER_BIT = 87, // Default value for example usage
    parameter DATA_BITS    = 8  // New parameter: Number of data bits to transmit
    )
    (
    input        i_Clock,
    input        i_Tx_DV,
    input [DATA_BITS-1:0] i_Tx_Data, // Data input, width determined by DATA_BITS
    output       o_Tx_Active,
    output reg   o_Tx_Serial,
    output       o_Tx_Done
    );
 
  // State definitions remain the same (standard Verilog-2001 integer literals)
  parameter s_IDLE         = 3'b000;
  parameter s_TX_START_BIT = 3'b001;
  parameter s_TX_DATA_BITS = 3'b010;
  parameter s_TX_STOP_BIT  = 3'b011;
  parameter s_CLEANUP      = 3'b100;
    
  reg [2:0]    r_SM_Main     = s_IDLE; // Initialize state machine
  reg [7:0]    r_Clock_Count = 0;
  // r_Bit_Index width adjusted to accommodate DATA_BITS (e.g., $clog2(8) for 8 bits, $clog2(32) for 32 bits)
  reg [$clog2(DATA_BITS)-1:0] r_Bit_Index = 0; 
  reg [DATA_BITS-1:0] r_Tx_Data = 0; // Internal data register, width determined by DATA_BITS
  reg          r_Tx_Done     = 0;
  reg          r_Tx_Active   = 0;
      
  always @(posedge i_Clock)
    begin
        
      case (r_SM_Main)
        s_IDLE :
          begin
            o_Tx_Serial   <= 1'b1;         // Drive Line High for Idle
            r_Tx_Done     <= 1'b0;         // Clear done flag
            r_Clock_Count <= 0;            // Reset clock count
            r_Bit_Index   <= 0;            // Reset bit index
              
            if (i_Tx_DV == 1'b1)
              begin
                r_Tx_Active <= 1'b1;       // Assert active flag
                r_Tx_Data   <= i_Tx_Data;  // Capture the input data
                r_SM_Main   <= s_TX_START_BIT; // Move to send start bit
              end
            else
              r_SM_Main <= s_IDLE; // Stay in IDLE
          end // case: s_IDLE
          
        // Send out Start Bit. Start bit = 0
        s_TX_START_BIT :
          begin
            o_Tx_Serial <= 1'b0; // Drive line low for start bit
              
            // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1; // Increment clock count
                r_SM_Main     <= s_TX_START_BIT; // Stay in current state
              end
            else
              begin
                r_Clock_Count <= 0;           // Reset clock count
                r_SM_Main     <= s_TX_DATA_BITS; // Move to send data bits
              end
          end // case: s_TX_START_BIT
          
        // Send out Data Bits (DATA_BITS bits, LSB first)
        s_TX_DATA_BITS :
          begin
            o_Tx_Serial <= r_Tx_Data[r_Bit_Index]; // Transmit current data bit
              
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1; // Increment clock count
                r_SM_Main     <= s_TX_DATA_BITS; // Stay in current state
              end
            else
              begin
                r_Clock_Count <= 0;           // Reset clock count
                  
                // Check if we have sent out all DATA_BITS bits
                if (r_Bit_Index < DATA_BITS - 1) // Condition changed for DATA_BITS
                  begin
                    r_Bit_Index <= r_Bit_Index + 1; // Move to next bit
                    r_SM_Main   <= s_TX_DATA_BITS; // Stay in current state
                  end
                else
                  begin
                    r_Bit_Index <= 0;             // Reset bit index
                    r_SM_Main   <= s_TX_STOP_BIT; // Move to send stop bit
                  end
              end
          end // case: s_TX_DATA_BITS
          
        // Send out Stop bit. Stop bit = 1
        s_TX_STOP_BIT :
          begin
            o_Tx_Serial <= 1'b1; // Drive line high for stop bit
              
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1; // Increment clock count
                r_SM_Main     <= s_TX_STOP_BIT; // Stay in current state
              end
            else
              begin
                r_Tx_Done     <= 1'b1;         // Assert done flag
                r_Clock_Count <= 0;            // Reset clock count
                r_SM_Main     <= s_CLEANUP;    // Move to cleanup state
                r_Tx_Active   <= 1'b0;         // De-assert active flag
              end
          end // case: s_Tx_STOP_BIT
          
        // Stay here 1 clock to assert o_Tx_Done for one cycle
        s_CLEANUP :
          begin
            r_Tx_Done <= 1'b1; // Keep done asserted for one cycle
            r_SM_Main <= s_IDLE; // Move back to IDLE
          end
          
        default : // Should not happen, but good practice
          r_SM_Main <= s_IDLE;
          
      endcase
    end
 
  // Continuous assignments for outputs
  assign o_Tx_Active = r_Tx_Active;
  assign o_Tx_Done   = r_Tx_Done;
    
endmodule