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
      .\pcif.imm26 (pcif.imm26),
      .\nRST (nRST),
      .\CLK (CLK)
      );
`endif

   word_t targetaddr = '0;   
   
   initial begin
      //initial values
      nRST = 1;
      pcif.imm26 = '0;
      pcif.imm16 = '0;
      pcif.pcsrc = 0;
      $monitor("%h", pcif.imemaddr);
      
      $display("Initial reset");      
      nRST = 1;
      nRST = 0; #(PERIOD/2);
      @(posedge CLK) nRST = 1;

      $display("Counting 4 instructions");
      targetaddr = pcif.imemaddr + 16;      
      #(PERIOD*4); #(PERIOD*0.1); //measure at beginning of next clk      
      if (pcif.imemaddr == targetaddr) $display ("cool.");
      else $display("PC is off by %d instructions! [at %.3d]", targetaddr/4, $time);

      $display("Branching fwd to an instruction");
      pcif.imm16 = 32'h07778;
      pcif.pcsrc = 1;
      targetaddr = pcif.imemaddr + 4 + (32'h07778 << 2);      
      #(PERIOD);
      if (pcif.imemaddr == targetaddr) $display ("cool.");
      else $display("PC did not branch to correct instruction %h! [at %.3d]", targetaddr, $time);
      @(posedge CLK) pcif.pcsrc = 0; 

      $display("Branching back to an instruction by 2 instructions");
      targetaddr = pcif.imemaddr + 4 + (-64 << 2);
      pcif.imm16 = -64;
      pcif.pcsrc = 1;
      #(PERIOD);
      if (pcif.imemaddr == targetaddr) $display ("cool.");
      else $display("PC did not branch to correct instruction %h! [at %.3d]", targetaddr, $time);
      @(posedge CLK) pcif.pcsrc = 0; 
      
      
   end   
endmodule

program test;
endprogram
   
