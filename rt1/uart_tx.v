// ============================================================================
// UART Transmitter (TX) Module
// ============================================================================

module uart_tx(
    input wire reset,     //Active-high synchronous reset
    input clk,            //  System clock
    input wire tx_start,  // Trigger signal to start a new transmission
    input [7:0]data_in,   //8-bit data to be transmitted
    output reg tx,        // UART serial transmit line
    output reg tx_done);  // Pulses high for one clock cycle when transmission ends

// --- FSM State Encoding ---  
  localparam IDLE = 2'b00; 
  localparam START = 2'b01;
  localparam DATA = 2'b10;
  localparam STOP = 2'b11;

  
  // --- Configurable Parameters ---
  parameter CLK_FREQ  = 50000000;  // System clock frequency in Hz (Default: 50MHz)
  parameter BAUD_RATE = 9600;     // Desired transmission baud rate
  localparam baud_wait = (CLK_FREQ / BAUD_RATE) - 1; //number of clock cycles required per single baud tick
  
  // --- Internal Registers and Wires ---
  reg [2:0] bit_index;    // Tracks which of the 8 data bits is being sent (0 to 7)
  reg [7:0] data_save;    // Latch to store data_in so it remains stable during transmission
  reg [1:0] state;        // Current FSM state
  reg [1:0] next_state;   // Next FSM state (determined by combinational logic)
  reg [15:0] baud_count;  // Counter for generating the baud rate tick
  wire baud_tik;          // 1-cycle pulse indicating it's time to process the next bit
  
  // --- Baud Rate Generator---
  always @(posedge clk) begin
    if(reset || state==IDLE)
      baud_count<=0;
    else begin if(baud_count==baud_wait)
      baud_count<=0;
      else
        baud_count<=baud_count+1; end end
         
  assign baud_tik = (baud_count==baud_wait);   // The tick is high for one clock cycle when the counter reaches the limit
  
// --- FSM Combinational Logic (Next State & Outputs)
  always @(*) begin
    next_state=state;
    tx_done=1'b0;
     
      case(state)
        IDLE: tx=1'b1;
        START: tx=1'b0;
        DATA: tx=data_save[bit_index];
        STOP:begin
          tx=1'b1;
          tx_done=1'b1; end
    endcase 
    
    if(state==IDLE) begin
      if(tx_start)
        next_state = START; end
    else begin
      if(baud_tik) begin
        case(state)
          START: next_state = DATA;
          DATA:  next_state = (bit_index == 7)?STOP: DATA;
          STOP:  next_state = IDLE;
        endcase
        end end end   
   
// --- FSM Sequential Logic (State Memory & Data Path)      
  
  always @(posedge clk) begin
    if(reset) state<=IDLE;
    else  state<=next_state; end
  
  always @(posedge clk) begin
    if(reset) data_save<=8'b0;
    else begin if(state==IDLE && tx_start)
      data_save<=data_in; end end
  
 // --- Data Bit Counter 
  always @(posedge clk) begin
    if(reset) bit_index<=0;
    else begin
      if (state==DATA) begin
        if(baud_tik)
          bit_index<=bit_index+1;
      end end end
  
endmodule
  

    
      
      
