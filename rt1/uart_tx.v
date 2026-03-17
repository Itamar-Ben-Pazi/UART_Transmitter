module uart_tx(input wire reset, input wire tx_start, input clk, input [7:0]data_in, output reg tx, output reg tx_done);
  
  localparam IDLE = 2'b00;
  localparam START = 2'b01;
  localparam DATA = 2'b10;
  localparam STOP = 2'b11;
  
  parameter CLK_FREQ  = 50000000;
  parameter BAUD_RATE = 9600;
  localparam baud_wait = (CLK_FREQ / BAUD_RATE) - 1;
  
  
  reg [2:0]bit_index;
  reg [7:0]data_save;
  reg [1:0] state, next_state;
  reg [15:0] baud_count;
  wire baud_tik;
  
  always @(posedge clk) begin
    if(reset || state==IDLE)
      baud_count<=0;
    else begin if(baud_count==baud_wait)
      baud_count<=0;
      else
        baud_count<=baud_count+1; end end
  assign baud_tik = (baud_count==baud_wait);
  
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
      
  
  always @(posedge clk) begin
    if(reset) state<=IDLE;
    else  state<=next_state; end
  
  always @(posedge clk) begin
    if(reset) data_save<=8'b0;
    else begin if(state==IDLE && tx_start)
      data_save<=data_in; end end
  
  
  always @(posedge clk) begin
    if(reset) bit_index<=0;
    else begin
      if (state==DATA) begin
        if(baud_tik)
          bit_index<=bit_index+1;
      end end end
  
endmodule
  

    
      
      
