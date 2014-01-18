//File name: 	testbench/alu_tb.sv
//Created: 	01/16/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

`include "alu_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module alu_tb;
   int testA = 32'hAAAAAAAA;
   int test5 = 32'h55555555;
   int test1 = 32'h11111111;
   int test0 = 32'h00000000;
   int testF = 32'hFFFFFFFF;
   
   parameter PERIOD = 10;
   logic nRST = 1;

   //interface
   alu_if alum ();

`ifndef MAPPED
   alu DUT(nRST, alum);
`else
   alu DUT
     (
      .\alum.op1 (alum.op1),
      .\alum.op2 (alum.op2),
      .\alum.opcode (alum.opcode),
      .\alum.res (alum.res),
      .\alum.flag_v (alum.flag_n),
      .\alum.flag_v (alum.flag_v),
      .\alum.flag_v (alum.flag_z)
      );    
`endif
   
   initial begin
      //initial values
      alum.op1 = '0;
      alum.op2 = '0;
      alum.opcode = '0;
      nRST = 0;
      //initial reset
      #PERIOD nRST = 1;

      #PERIOD;
      
      ///////////////////////////////////////////////
      //     ADDITION TESTS
      ///////////////////////////////////////////////
      
      $display("Testing ADD AAAA+5555");
      do_op(testA, test5, ALU_ADD, 32'hffffffff);
      
      
      $display("Testing ADD 1111+1111");
      nRST = 0;  #PERIOD nRST = 1; //reset result
      do_op(test1, test1, ALU_ADD, 32'h22222222);
      
      
      $display("Testing ADD FFFF+1");
      do_op(testF, 32'h01, ALU_ADD, 32'h0);

      
      ///////////////////////////////////////////////
      //     SUBTRACTION TESTS
      ///////////////////////////////////////////////
      
      //nRST = 0;  #PERIOD nRST = 1; //no reset, want to see change in garbage value
      $display("Testing SUB 1111-1111");
      do_op(test1, test1, ALU_SUB, '0);
      
      
      ///////////////////////////////////////////////
      //     AND TESTS
      ///////////////////////////////////////////////
      
      //nRST = 0;  #PERIOD nRST = 1; //dont reset because result is going to be 0, so want a garbage value to see res change
      $display("Testing AND 1111&1111");
      do_op(testA, test5, ALU_AND, '0);
      
   end // initial begin

   
   task do_op;
      input [31:0] op1_;
      input [31:0] op2_;
      input [3:0]  opcode_;
      input [31:0] desired_res;
      
      begin
	 alum.op1 = op1_;
	 alum.op2 = op2_;
	 alum.opcode = opcode_;
	 #0.5ns;
	 if (alum.res != desired_res) $display("====FAILED===");
	 $display("res=%h, [V%d N%d Z%d]\n", alum.res, alum.flag_v, alum.flag_n, alum.flag_z);
      end
   endtask

endmodule

