//File name: 	testbench/icache_tb.sv
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

module icache_tb;
//internal signals
logic nRST, CLK = 0;
parameter PERIOD = 10;
parameter CPUID = 0;
parameter INSTRUCTIONS = 10; //# instructions to load into cache

always #(PERIOD/2) CLK++;
//interfaces
datapath_cache_if dcif ();
cache_control_if ccif ();

int i;
int unsigned cycles;
////////
//Comment out this portion to test icache in isolation
cpu_ram_if ramif();
ram #(.LAT(10)) CPURAM (CLK, nRST, ramif);
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
        icache #(0) DUT (CLK, nRST, dcif.icache, ccif.icache);
`else
icache DUT ( );
`endif

initial begin
    //initial values
    nRST = 0;
    dcif.imemaddr = '0;
    dcif.imemREN = 0;
    //ccif.iwait = '0;
    //ccif.iload = '0;
    ccif.dWEN = '0; ccif.dREN = '0; //so they don't interfere
    //initial reset
    #PERIOD nRST = 1;


    $display("\nChecking if everything reset to 0.");
    //Check it.

    //#0.1ns;

    $display("\nRequesting data that is not loaded: compulsory miss test.");
    //request_instr(32'h04);
    //request_instr(32'h00);


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

    $display("\nRequesting data that is in cache.");
    $display("\nRequesting same data continuously. -> cache hits");
    $display("\nRequesting data in closeby addresses. -> cache hits");
    $display("\nRequesting data with same index -> conflict miss test.");
    $display("\nRequesting data outside of index -> capacity miss test.");
    $display("\nMISC: Requesting data with correct tag but incorrect index -> cache miss");
    $display("Resetting.");
    //nRST = 0; #0.1ns; @(posedge CLK) nRST = 1;
    //#PERIOD;

    $display("\nFilling cache by generating misses.");

    for(i=0; i<64; i=i+4) begin
      request_instr(i);
    end

    for(i=0; i<64; i=i+4) begin
      request_instr(i);
    end

    for(i=64; i<128; i=i+4) begin
      request_instr(i);
    end
    /*
    for (i = 0; i < 64; i=i+4) begin
        dcif.imemaddr = i;
        dcif.imemREN = 1;
        cycles = 1;
        #(PERIOD);
        while (!dcif.ihit) begin
          #(PERIOD);
          cycles++;
        end
        dcif.imemREN = 0;
        $display("Loaded data: [0x%h]: %h in %d cycles", dcif.imemaddr, dcif.imemload, cycles);
    end
    $display("Check .wav to see if correct data has been uploaded.");

    //nRST = 0;
    //#(PERIOD);
    //nRST = 1;

    for (i = 0; i < 64; i=i+4) begin
        dcif.imemaddr = i;
        dcif.imemREN = 1;
        cycles = 1;
        #(PERIOD);
        while (!dcif.ihit) begin
          #(PERIOD);
          cycles++;
        end
        dcif.imemREN = 0;
        $display("Loaded data: [0x%h]: %h in %d cycles", dcif.imemaddr, dcif.imemload, cycles);
    end
    $display("Check .wav to see if correct data has been uploaded.");
    */

    $finish();
end // initial begin

task request_instr;
    input [31:0] address;
    begin
        dcif.imemaddr = address;
        dcif.imemREN = 1;
        #(PERIOD);
        cycles = 1;
        while(!dcif.ihit) begin
          #(PERIOD);
          cycles++;
        end
        #(PERIOD);
        $display("addr: %h data: %h %s", address, dcif.imemload, (cycles == 1)? "HIT" : "MISS");
    end
endtask

endmodule

