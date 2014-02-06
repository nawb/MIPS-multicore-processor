//File name: 	testbench/memory_control_tb.sv
//Created: 	02/04/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

`include "cache_control_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module memory_control_tb;
   //interface
   cache_control_if memif ();

   logic CLK;   
   logic nRST;
   parameter PERIOD = 10;
   
   memory_control DUT(CLK, nRST, memif);

   always #(PERIOD/2) CLK++;
   
   initial begin
      //initial values
      memif.iREN = 0;
      memif.iaddr = '0;

      memif.dREN = 0;
      memif.dWEN = 0;
      memif.dstore = '0;
      
      nRST = 0;
      $display("initial reset");
      #PERIOD nRST = 1;

      $monitor("%d %d %d %d %d", 
	       memif.iREN, memif.dREN, memif.dWEN, memif.iwait, memif.dwait);

      $display("Sending normal instruction request");
      #PERIOD memif.iREN = 1'b1;
      #PERIOD memif.iREN = 1'b0;

      $display("Sending ld/sw instruction request");
      #PERIOD memif.iREN = 1'b1;
      #PERIOD memif.iREN = 1'b0;

      #PERIOD memif.dREN = 1'b1;
      #PERIOD memif.dREN = 1'b0;

      $display("Sending d and i request at the same time");
      #PERIOD memif.iREN = 1'b1;
      memif.dREN = 1'b1;
      #PERIOD memif.dREN = 1'b0;
      #PERIOD memif.iREN = 1'b0;
      
   end
endmodule

