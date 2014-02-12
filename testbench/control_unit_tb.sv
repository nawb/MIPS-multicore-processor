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
      regs = 4;
      regt = 0;
      regd = 5;      
      cuif.instr = {RTYPE, regs, regt, regd, 5'b0, ADD};
      
      #PERIOD;
      
      
   end // initial begin   
endmodule

