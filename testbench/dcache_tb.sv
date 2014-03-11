//File name: 	testbench/dcache_tb.sv
//Created: 	03/07/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

`include "cpu_types_pkg.vh"
`include "cache_control_if.vh"
`include "cpu_ram_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module dcache_tb;
   //internal signals
   logic nRST, CLK = 0;
   parameter PERIOD = 10;
   parameter CPUID = 0;
   parameter WORDS = 10; //# data words to load into cache
   int 	 i;
   

   //interfaces
   datapath_cache_if dcif ();
   cache_control_if ccif ();

   ////////
   //Comment out this portion to test dcache in isolation
   cpu_ram_if ramif();   
   ram CPURAM (CLK, nRST, ramif);
   memory_control MCTL(CLK, nRST, ccif.cc);
   //connections
   assign ccif.ramstate = ramif.ramstate;
   assign ccif.ramload = ramif.ramload;
   assign ramif.ramWEN = ccif.ramWEN;
   assign ramif.ramstore = ccif.ramstore;
   assign ramif.ramREN = ccif.ramREN;
   assign ramif.ramaddr = ccif.ramaddr;   
   ///////
   
   //blocks
`ifndef MAPPED
   dcache #(0) DUT (CLK, nRST, dcif.dcache, ccif.dcache);
`else
   dcache DUT ( );
`endif
   
   always #(PERIOD/2) CLK++;   
   
   initial begin
      //initial values
      nRST = 0;
      dcif.imemaddr = '0; dcif.imemREN = 0; //so they dont interfere with memctl      
      dcif.dmemWEN = 0; dcif.dmemREN = 0;
      dcif.dmemaddr = '0;
      dcif.dmemstore = '0;      
      //initial reset
      #PERIOD nRST = 1;
      

      $display("\nChecking if everything reset to 0.");
      //Check it.

      
      $display("\nRequesting data that is not loaded: compulsory miss test.");
      load_word(32'h04);
      load_word(32'h00);      

      
      $display("\nRequesting data that is in cache.");

		      
      
      $display("\nRequesting same data continuously. -> cache hits");



      $display("\nRequesting data in closeby addresses. -> cache hits");
            

      
      $display("\nRequesting data with same index -> conflict miss test.");

     

      $display("\nRequesting data outside of index -> capacity miss test.");

            

      $display("\nMISC: Requesting data with correct tag but incorrect index -> cache miss");

      
      $display("Resetting.");
      nRST = 0; #0.1ns; @(posedge CLK) nRST = 1;
      #PERIOD;
      
      $display("\nFilling cache by generating misses.");
      for (i = 0; i < WORDS*4; i=i+8) begin
	 dcif.dmemaddr = i;
	 dcif.dmemREN = 1;
	 #(2*PERIOD);
	 if (ccif.dwait[CPUID]) #(2*PERIOD);
	 dcif.dmemREN = 0;	 
	 $display("Loaded data: [0x%h]: %h", ccif.daddr[CPUID], dcif.dmemload);
      end
      $display("Check .wav to see if correct data has been uploaded.");

      
      $finish();      
   end // initial begin
   
   task load_word;
      input [31:0] address;
      begin
	 dcif.dmemaddr = address;
	 dcif.dmemREN = 1;
	 #(PERIOD);
	 if (dcif.dhit == 1)
	   $display("cache hit. %3d", $time);
	 else if (ccif.daddr[CPUID] == 32'h04 && ccif.dREN[CPUID] == 1) begin
	    $display("cache miss. %3d", $time);
	    #(2*PERIOD);	    
	 end
	 #(PERIOD);
	 $display("Received data: %h", dcif.dmemload);
	 dcif.dmemREN = 0;
      end
      /*
      dcif.imemaddr = 32'h04;
      dcif.imemREN = 1;
      if (dcif.ihit != 1) begin end
	else $display("Error! Should not have this data yet. %d", $time);
      #(PERIOD);
      if (ccif.iaddr[CPUID] == 32'h04 && ccif.iREN[CPUID] == 1)
	$display("Generated cache miss. Going to RAM. %d", $time);
      #(PERIOD);
      $display("Received data: %h", dcif.imemload);
      dcif.imemREN = 0;*/      
   endtask

endmodule

