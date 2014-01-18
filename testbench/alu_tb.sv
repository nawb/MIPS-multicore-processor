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

      ///////////////////////////////////////////////
      //     ADDITION TESTS
      ///////////////////////////////////////////////
 
      $display("Testing ADD AAAA+5555");
      #PERIOD;
      alum.op1 = testA;
      alum.op2 = test5;
      alum.opcode = ALU_ADD;
      #0.5ns;
      if (alum.res != 32'hffffffff) $display("====FAILED===");
      $display("res=%h, [V%d N%d Z%d]\n", alum.res, alum.flag_v, alum.flag_n, alum.flag_z);

      
      $display("Testing ADD 1111+1111");
      nRST = 0;  #PERIOD nRST = 1; //reset result
      alum.op1 = test1;
      alum.op2 = test1;
      alum.opcode = ALU_ADD;
      #0.5ns;
      if (alum.res != 32'h22222222) $display("====FAILED===");
      $display("res=%h, [V%d N%d Z%d]\n", alum.res, alum.flag_v, alum.flag_n, alum.flag_z);

      
      $display("Testing ADD FFFF+1");
      alum.op1 = testF;
      alum.op2 = 32'h01;      
      alum.opcode = ALU_ADD;
      #0.5ns;
      if (alum.res != 32'h0) $display("====FAILED===");
      $display("res=%h, [V%d N%d Z%d]\n", alum.res, alum.flag_v, alum.flag_n, alum.flag_z);


      ///////////////////////////////////////////////
      //     SUBTRACTION TESTS
      ///////////////////////////////////////////////
      
      //nRST = 0;  #PERIOD nRST = 1; //no reset, want to see change in garbage value
      $display("Testing SUB 1111-1111");
      alum.op1 = test1;
      alum.op2 = test1;
      alum.opcode = ALU_SUB;
      #0.5ns;
      if (alum.res != '0) $display("====FAILED===");
      $display("res=%h, [V%d N%d Z%d]\n", alum.res, alum.flag_v, alum.flag_n, alum.flag_z);

      
      ///////////////////////////////////////////////
      //     AND TESTS
      ///////////////////////////////////////////////
      
      //nRST = 0;  #PERIOD nRST = 1; //dont reset because result is going to be 0, so want a garbage value to see res change
      $display("Testing AND 1111&1111");
      alum.op1 = testA;
      alum.op2 = test5;
      alum.opcode = ALU_AND;
      #0.5ns;
      if (alum.res != '0) $display("====FAILED===");
      $display("res=%h, [V%d N%d Z%d]\n", alum.res, alum.flag_v, alum.flag_n, alum.flag_z);
      
      
      
      
   end
endmodule

