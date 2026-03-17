`timescale 1ns / 1ps // הגדרת יחידות הזמן: כל '1' שווה ננו-שנייה

module tb_uart_tx();
  
  reg clk;
  reg reset;
  reg tx_start;
  reg [7:0] data_in;
  
  wire tx;
  wire tx_done;
  
  uart_tx uut(reset, tx_start, clk, data_in, tx, tx_done);
  
  always begin
    #10;
    clk=~clk; end
  
  initial begin
    clk=0;
    reset=1;
    tx_start=0;
    data_in=8'b0;
    #100;
    reset=0;
    #100;
    tx_start=1;
    data_in = 8'b10111001;
    #20;
    tx_start=0;
    wait (tx_done);
    #1000;
    $finish; end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_uart_tx);
  end
  
endmodule
    
  