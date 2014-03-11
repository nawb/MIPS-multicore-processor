//File name: 	source/dcache.sv
//Created: 	03/07/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	

// interfaces
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"

// cpu types
`include "cpu_types_pkg.vh"

module dcache (
	       input logic CLK, nRST,
	       datapath_cache_if.dcache dcif,
	       cache_control_if.dcache ccif
	       );
   // import types
   import cpu_types_pkg::*;
   parameter CPUID = 0;

   typedef struct packed {
      logic 	  valid;
      logic [25:0] [2] tag;
      word_t [2] data;
   } cache_block;

   cache_block [8] cache;
   logic [25:0]    tag;
   logic [3:0] 	   index;
   logic 	   offset;   

   assign tag = dcif.dmemaddr[31:6];
   assign index = dcif.dmemaddr[6:3];
   assign offset = dcif.dmemaddr[2];

   always_ff @(posedge CLK, negedge nRST)
     begin
	if (!nRST)
	  begin
	     cache <= '0;
	  end
	else //if a cache miss:
	  if (!dcif.dhit && !ccif.dwait[CPUID]) begin
	     cache[index].tag[offset] <= tag;
	     cache[index].valid <= 1;
	     cache[index].data[offset] <= ccif.dload[CPUID];
	  end
     end
   
   assign dcif.dhit = (cache[index].tag == tag) && cache[index].valid;// && !ccif.iwait;
   assign dcif.dmemload = cache[index].data;
   
   assign ccif.dREN[CPUID] = dcif.dmemREN && !dcif.dhit;
   assign ccif.dWEN[CPUID] = dcif.dmemWEN && !dcif.dhit;   
   assign ccif.daddr[CPUID] = dcif.dmemaddr;
   
endmodule
