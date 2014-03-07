//File name: 	testbench/hazard_unit_tb.sv
//Created: 	03/03/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

`include "cache_control_if.vh"
`include "cpu_ram_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module hazard_unit_tb;
   hazard_unit_if hzif();   
   hazard_unit DUT(hzif);
   
   logic CLK = 0;
   parameter PERIOD = 10;
   int 	 ii;   

   always #(PERIOD/2) CLK++;
   
   initial begin
      //initial values
      hzif.ihit = 0;
      hzif.dhit = 0;
      hzif.halt = 0;
      hzif.branching = 0;
      hzif.jumping = 0;
      hzif.dREN = 0;
      hzif.dWEN = 0;
      hzif.pc_src = 0;

      $display("------------------------");
      $display("FD  DE  EM  MW < FLUSHES");
      $display("------------------------");
      $monitor("%2d  %2d  %2d  %2d",
	       hzif.FDflush, hzif.DEflush, hzif.EMflush, hzif.MWflush);      
      
      $display("Normal execution (getting ihits)");      
      for (ii = 0; ii < 10; ii++) begin	 
	 #(PERIOD)   hzif.ihit = 1;
	 #(PERIOD*3) hzif.ihit = 0;
      end

      $display("Branch mispredicted");
      hzif.branching = 1;
      #PERIOD;
      hzif.branching = 0;
      
      $display("Branch mispredict with a halt already in the pipeline");
      hzif.branching = 1; 
      #PERIOD;
      hzif.halt = 1;
      #PERIOD;      
      hzif.halt = 0;
      hzif.branching = 0;


      $display("Jump");
      hzif.jumping = 1;
      #PERIOD;
      hzif.jumping = 1;
      
      $display("Jump followed by a halt already in the pipeline");
      hzif.jumping = 1; 
      #PERIOD;
      hzif.halt = 1;
      #PERIOD;      
      hzif.halt = 0;
      hzif.jumping = 0;      
      
      $finish();
      
   end

endmodule

