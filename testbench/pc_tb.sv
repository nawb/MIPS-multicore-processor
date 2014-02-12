//File name: 	testbench/pc_tb.sv
//Created: 	02/11/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:  testbench for program counter

`include "cpu_types_pkg.vh"
// mapped needs this
`include "pc_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module pc_tb;
   parameter PERIOD = 10;
   logic CLK = 0, nRST = 1;
   always #(PERIOD/2) CLK++;

   // interface
   pc_if pcif ();
   // test program
   test PROG ();
   // DUT
`ifndef MAPPED
   pc DUT(CLK, nRST, pcif);
`else
   pc DUT
     (
      .\rfif.rdat2 (rfif.rdat2),
      .\rfif.rdat1 (rfif.rdat1),
      .\rfif.wdat (rfif.wdat),
      .\rfif.rsel2 (rfif.rsel2),
      .\rfif.rsel1 (rfif.rsel1),
      .\rfif.wsel (rfif.wsel),
      .\rfif.WEN (rfif.WEN),
      .\nRST (nRST),
      .\CLK (CLK)
      );
`endif
   
   initial begin
      //initial values
      nRST = 1;
      
      //initial reset
      nRST = 1;
      nRST = 0; #(PERIOD/2);
      @(posedge CLK) nRST = 1;

   end   
endmodule

program test;
endprogram
   
