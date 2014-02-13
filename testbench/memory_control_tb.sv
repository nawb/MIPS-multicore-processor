//File name: 	testbench/memory_control_tb.sv
//Created: 	02/04/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

`include "cache_control_if.vh"
`include "cpu_ram_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module memory_control_tb;
   //interface
   cache_control_if ccif ();
   cpu_ram_if ramif();
   
   logic CLK = 0;   
   logic nRST;
   parameter PERIOD = 10;
   
   memory_control DUT(CLK, nRST, ccif);
   ram CPURAM(CLK, nRST, ramif);   

   always #(PERIOD/2) CLK++;

   //connections
   assign ccif.ramstate = ramif.ramstate;
   assign ccif.ramload = ramif.ramload;
   assign ramif.ramWEN = ccif.ramWEN;
   assign ramif.ramstore = ccif.ramstore;
   assign ramif.ramREN = ccif.ramREN;
   assign ramif.ramaddr = ccif.ramaddr;   
   
   initial begin
      //initial values
      ccif.iREN = 0;
      ccif.iaddr = '0;
      ccif.daddr = '0;      

      ccif.dREN = 0;
      ccif.dWEN = 0;
      ccif.dstore = '0;
            
      
      nRST = 0;
      $display("initial reset");
      #PERIOD nRST = 1;

      $display("dREN dWEN iREN | dwait iwait");      
      $monitor(" %3d  %3d  %3d |   %3d   %3d", 
	       ccif.dREN, ccif.dWEN, ccif.iREN, ccif.dwait, ccif.iwait);

      $display("Sending normal instruction request");
      #PERIOD ccif.iREN = 1'b1;
      #PERIOD ccif.iREN = 1'b0;

      $display("Sending ld/sw instruction request");
      #PERIOD ccif.iREN = 1'b1;
      #PERIOD ccif.iREN = 1'b0;

      #PERIOD ccif.dREN = 1'b1;
      #PERIOD ccif.dREN = 1'b0;

      $display("Sending dR and i request at the same time");
      #PERIOD ccif.iREN = 1'b1;
      ccif.dREN = 1'b1;
      #PERIOD ccif.dREN = 1'b0;
      #PERIOD ccif.iREN = 1'b0;

      $display("Sending dW and i request at the same time");
      #PERIOD ccif.iREN = 1'b1;
      ccif.dWEN = 1'b1;
      #PERIOD ccif.dWEN = 1'b0;
      #PERIOD ccif.iREN = 1'b0;

      $display("Writing to RAM");
      #(3*PERIOD);
      ccif.dWEN = 1'b1;
      ccif.daddr = 32'h00000024;
      ccif.dstore = 32'hBAAD;
      #PERIOD; //can wait only a period and still be safe and land in ACCESS state because the RAM clk is 2x CPU clk on the fpga and so we can never have an access longer than a cpu clock.
      ccif.dWEN = 1'b0;
      #PERIOD;
      ccif.dREN = 1'b1;      
      #PERIOD $display("wrote %h, read %h", ccif.dstore, ccif.dload);
      ccif.dREN = 1'b0;
      #PERIOD;
      
      dump_memory();           
      
   end // initial begin

   task automatic dump_memory();
      int memfd = $fopen("memchanged.hex","w");
      if (memfd)
	$display("Starting memory dump.");
      else
	begin $display("Failed to open."); $finish; end

      for (int unsigned i = 0; memfd && i < 8192; i++)
	begin
	   int chksum = 0;
	   bit [7:0][7:0] values;
	   string 	  ihex;

	   ccif.daddr = i << 2;
	   ccif.dREN = 1;
	   repeat (2) @(posedge CLK);
	   if (ccif.dload === 0)
             continue;
	   values = {8'h04,16'(i),8'h00,ccif.dload};
	   foreach (values[j])
             chksum += values[j];
	   chksum = 16'h100 - chksum;
	   ihex = $sformatf(":04%h00%h%h",16'(i),ccif.dload,8'(chksum));
	   $fdisplay(memfd,"%s",ihex.toupper());
	end //for
      if (memfd)
	begin
	   ccif.dREN = 0;
	   $fdisplay(memfd,":00000001FF");
	   $fclose(memfd);
	   $display("Finished memory dump.");
	end
   endtask

endmodule

