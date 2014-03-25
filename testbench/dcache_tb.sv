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
   ram #(.LAT(2)) CPURAM (CLK, nRST, ramif);
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
      #(PERIOD*1.5) nRST = 1;
      @(posedge CLK);      

      $display("\nChecking if everything reset to 0.");
      //Check it.

      $display("\nRequesting data that is not loaded: compulsory miss test.");
      load_word(32'h00); //miss
      #PERIOD;
      
      load_word(32'h1c); //miss
      #PERIOD;      
      
      load_word(32'h18); //hit
      #PERIOD;

      load_word(32'h00000200); //miss, load into other set (must keep both 32'h00 and this)
      #PERIOD;
            
      load_word(32'h00);  //make set0 the most recently used again
      #PERIOD;      
      
      load_word(32'h00000400); //hit, loading into same set, must pick last used to replace
      #(2*PERIOD);
   
      store_word(32'h18, 32'hDEAD); //hit, storing over old value (should make it dirty)
      #PERIOD;
      
      store_word(32'h08, 32'hDED2); //miss
      #PERIOD;
      
      
      $display("\nRequesting data that is in cache.");
      $display("\nRequesting same data continuously. -> cache hits");
      $display("\nRequesting data in closeby addresses. -> cache hits");
      $display("\nRequesting data with same index -> conflict miss test.");
      $display("\nRequesting data outside of index -> capacity miss test.");
      $display("\nMISC: Requesting data with correct tag but incorrect index -> cache miss");      

      $finish();

   end // initial begin


   task automatic load_word;
      input [31:0] address;
      begin
	 dcif.dmemaddr = address;
	 dcif.dmemREN = 1;

	 for (i=0; i < 32; i++) begin
	    if (dcif.dhit == 1) begin
	       dcif.dmemREN = 0;
	       $display("Received data: %h", ccif.dload[CPUID]);
	       break;
	    end
	    else begin
	       $display("waiting");
	       #PERIOD;
	    end	    
	 end	
      end
   endtask

   
   task automatic store_word;
      input [31:0] address;
      input [31:0] data;      
      begin
	 dcif.dmemaddr = address;
	 dcif.dmemREN = 0;
	 dcif.dmemWEN = 1;
	 dcif.dmemstore = data;	 

	 for (i=0; i < 32; i++) begin
	    if (dcif.dhit == 1) begin
	       dcif.dmemWEN = 0;
	       $display("Storing data: %h", ccif.dstore[CPUID]);
	       break;
	    end
	    else begin
	       $display("waiting");
	       #PERIOD;
	    end	    
	 end	
      end
   endtask

   
endmodule
