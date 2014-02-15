//File name: 	testbench/control_unit_tb.sv
//Created: 	01/16/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

`include "control_unit_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module control_unit_tb;
   control_unit_if cuif ();
   control_unit DUT(cuif);
   
   parameter PERIOD = 10; //just need a random time, but helpful if we match it against the clock period for counting cycles
   logic [4:0] regs, regd, regt;
   
   initial begin

      //ADDU
      regs = 4;
      regt = 0;
      regd = 5;
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, ADD};
      #PERIOD;

      //AND
      regs = 1;
      regt = 2;
      regd = 3;
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, AND};
      #PERIOD;

      //NOR
      regs = 4;
      regt = 0;
      regd = 5;
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, NOR};
      #PERIOD;

      //OR
      regs = 4;
      regt = 0;
      regd = 5;
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, OR};
      #PERIOD;

      regs = 4;
      regt = 0;
      regd = 5;
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, SLT};
      #PERIOD;

      regs = 4;
      regt = 0;
      regd = 5;
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, SLTU};
      #PERIOD;

      regs = 4;
      regt = 0;
      regd = 5;
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, SLL};
      #PERIOD;

      regs = 4;
      regt = 0;
      regd = 5;
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, SRL};
      #PERIOD;

      regs = 4;
      regt = 0;
      regd = 5;
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, SUBU};
      #PERIOD;

      regs = 4;
      regt = 0;
      regd = 5;
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, XOR};
      #PERIOD;

//I-TYPES
      regs = 1;
      regt = 2;
      regd = 3;
      cuif.instr = {ADDIU, regs, regt, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {ANDI, regs, regt, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {LUI, regs, regt, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {ORI, regs, regt, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {SLTI, regs, regt, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {SLTIU, regs, regt, 16'h0CAFE};
      #PERIOD;
      
      cuif.instr = {XORI, regs, regt, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {SW, regt, regs, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {LW, regs, regt, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {BEQ, regs, regt, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {BEQ, regs, regs, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {BNE, regs, regt, 16'h0CAFE};
      #PERIOD;

      cuif.instr = {BNE, regs, regs, 16'h0CAFE};
      #PERIOD;

//J-TYPE
      cuif.instr = {J, regs, 26'h0DEAAAAD};
      #PERIOD;

      cuif.instr = {JAL, regs, 26'h0DEAAAAD};
      #PERIOD;
      
   end // initial begin
   task do_op;
      input word_t instr;
      cuif.instr = instr;
      
   endtask
endmodule

