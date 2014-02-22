//File name: 	testbench/preg_IF_ID_tb.sv
//Created: 	02/19/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:  testbench for IF/ID pipeline reg

`include "cpu_types_pkg.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module pipelinereg_tb;
   parameter PERIOD = 10;
   logic CLK = 0, nRST = 1;
   always #(PERIOD/2) CLK++;
   
   logic EN = 0, flush = 0;
   word_t instr_i, pc_i, instr_o, pc_o;
   logic [63:0] in_ID, out_IF;
   logic [(32*3)-1:0] in_EX, out_ID;
   
   
   pipelinereg #(.RSIZE(64)) preg_IF_ID(CLK, nRST, EN, flush, in_ID, out_IF);
   pipelinereg #(32*3) preg_ID_EX(CLK, nRST, EN, flush, in_EX, out_ID);   
   
   assign in_ID = {instr_i, pc_i};
   assign instr_o = out_IF[63:32];
   assign pc_o = out_IF[31:0];
   
   initial begin
      //initial values
      nRST = 1;
      nRST = 0;
      #PERIOD;
      @ (posedge CLK) nRST = 1;

      instr_i = {RTYPE, 5'd4, 5'd3, 5'd2, 5'b0, ADD};
      pc_i = 32'd14;      
      EN = 1;
      #PERIOD;
      
      instr_i = {RTYPE, 5'd7, 5'd8, 5'd9, 5'b0, SUB};
      pc_i = 32'd16;
      #PERIOD;
      
      instr_i = {RTYPE, 5'd7, 5'd8, 5'd9, 5'b1, SLT};
      pc_i = 32'd18;
      #PERIOD;
      
      //next instruction must come in
      #PERIOD;
      
      EN = 0;
      #PERIOD;
      
      //instruction should stay stable here
      instr_i = {ANDI, 5'd7, 5'd8, 16'd15};
      pc_i = 32'd26;
      #PERIOD;
      
      EN = 1;
      
      
   end   
endmodule
   
