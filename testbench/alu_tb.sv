//File name: 	testbench/alu_tb.sv
//Created: 	01/16/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module alu_tb;
   int testA = 32'hAAAAAAAA;
   int test5 = 32'h55555555;
   int test1 = 32'h11111111;
   int test0 = 32'h00000000;
   parameter [3:0] ADD  = 4'b0000;
   parameter [3:0] SUB  = 4'b0001;
   parameter [3:0] AND  = 4'b0010;
   parameter [3:0] OR   = 4'b0011;
   parameter [3:0] XOR  = 4'b0100;
   parameter [3:0] XNOR = 4'b0101;
   parameter [3:0] LSL  = 4'b0110;
   parameter [3:0] LSR  = 4'b0111;
   
   parameter PERIOD = 10;
   logic nRST = 1;
   word_t op1;
   word_t op2;
   word_t res;
   logic [3:0] opcode;   
   logic       flag_n;
   logic       flag_v;
   logic       flag_z;
   
   alu DUT(.*);
   
   initial begin
      //initial values
      op1 = '0;
      op2 = '0;
      opcode = '0;
      nRST = 0;
      //initial reset
      #PERIOD nRST = 1;

      //test add
      #PERIOD;
      op1 = testA;
      op2 = test5;
      opcode = ADD;
      $display("Testing ADD AAAA+5555");
      #0.5ns;
      if (res != 32'hffffffff) $display("FAILED: add AAAA+5555");
      
      //test add
      nRST = 0;  #PERIOD nRST = 1; //reset result
      op1 = test1;
      op2 = test1;
      opcode = ADD;
      $display("Testing ADD 1111+1111");
      #0.5ns;
      if (res != 32'h22222222) $display("FAILED: add 1111+1111");
      
      //test sub
      nRST = 0;  #PERIOD nRST = 1; //reset result
      op1 = test1;
      op2 = test1;
      opcode = SUB;
      $display("Testing SUB 1111-1111");
      #0.5ns;
      if (res != '0) $display("FAILED: sub 1111-1111");
      
      //test and
      nRST = 0;  #PERIOD nRST = 1; //reset result
      op1 = testA;
      op2 = test5;
      opcode = AND;
      $display("Testing AND 1111&1111");
      #0.5ns;
      if (res != '0) $display("FAILED: AND 1111&1111");
      
      
      
      
      
   end
endmodule
