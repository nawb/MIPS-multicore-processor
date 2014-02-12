//File name: 	testbench/datapath_tb.sv
//Created: 	02/11/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

`include "datapath_cache_if.vh"
`include "cpu_ram_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module datapath_tb;
   //interface
   datapath_cache_if dpif ();
   
   logic CLK = 0;   
   logic nRST;
   logic [4:0] regs, regd, regt;
   
   parameter PERIOD = 10;
   
   datapath DUT(CLK, nRST, dpif);

   always #(PERIOD/2) CLK++;
   
   initial begin
      //initial values
      nRST = 0;
      #PERIOD;      
      nRST = 1;
      regs = 0;
      regt = 0;
      regd = 0;

      $display("ORI $21, $0, 0x80");      
      #(PERIOD);
      regs = 0;
      regt = 21;
      dpif.imemload = {ORI, regs, regt, 16'h080};

      $display("ORI $22, $0, 0xF0");
      #(2*PERIOD);
      regs = 0;
      regt = 22;
      dpif.imemload = {ORI, regs, regt, 16'h0F0}; 

      $display("ADD $4, $5, $6");
      #(10*PERIOD);
      regs = 4;
      regt = 5;
      regd = 6;      
      //d=s+t      
      dpif.imemload = {RTYPE, regs, regt, regd, 5'b0, ADD}; 
      
      nRST = 0;
      
   end // initial begin


endmodule

