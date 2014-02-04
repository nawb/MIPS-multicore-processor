//File name: 	testbench/ram_tb.sv
//Created: 	01/16/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

`include "cpu_ram_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module ram_tb;
   //interface
   cpu_ram_if sram ();
   logic nRST;
   parameter PERIOD = 10; //just need a random time, but helpful if we match it against the clock period for counting cycles

   cpu_ram_if DUT();

   int testA = 32'hAAAAAAAA;
   int test5 = 32'h55555555;
   int test1 = 32'h11111111;
   int test0 = 32'h00000000;
   int testF = 32'hFFFFFFFF;
   int test1_neg = -1;
   
   initial begin
      //initial values
      sram.ramaddr = '0;
      sram.ramstore = '0;
      sram.ramREN = 0;
      sram.ramWEN = 0;
      
      nRST = 0;
      //initial reset
      #PERIOD nRST = 1;

      #PERIOD;
      sram.ramaddr = 32'h000000A;
      sram.ramstore = 32'hAAAA5555;
      sram.ramWEN = 1;
      #PERIOD;
      
      
   end // initial begin   
endmodule

