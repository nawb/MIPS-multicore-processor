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

   typedef enum  {IDLE, SELECT, WRITEBACK1, WRITEBACK2, FETCH1, FETCH2, HIT} states;
   states cstate, nstate;   
   
   typedef struct packed {
      logic [25:0] tag;
      word_t [1:0] data;
      logic 	      valid;
      logic 	      dirty;
   } cache_block;
   
   cache_block [8][2] cache; //2-way set associative
   logic [25:0]    tag;
   logic [3:0] 	   index;
   logic 	   offset;   
   logic 	   set;

   assign tag = dcif.dmemaddr[31:7];
   assign index = dcif.dmemaddr[6:3];
   assign offset = dcif.dmemaddr[2];

   assign set = (cache[index][1].tag == tag)? 1:0;
   assign dcif.dmemload = cache[index][set].data;//[offset];
   assign dcif.dhit = (cache[index][set].tag == tag) && cache[index][set].valid;// && !ccif.iwait;

   always_comb begin : DADDR
      casez(cstate) 
	FETCH1, WRITEBACK1: ccif.daddr[CPUID] = dcif.dmemaddr;
	FETCH2, WRITEBACK2: ccif.daddr[CPUID] = dcif.dmemaddr+4;
	default: ccif.daddr[CPUID] = dcif.dmemaddr;	
      endcase
   end
   
   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 cstate <= IDLE;
	 cache <= '0;	 
      end
      else
	cstate <= nstate;
      if (cstate == FETCH1) begin
	 cache[index][set].data[0] <= ccif.dload[CPUID];
	 cache[index][set].valid <= 1;
	 cache[index][set].tag <= tag;	 
      end
      if (cstate == FETCH2) begin
	 cache[index][set].data[1] <= ccif.dload[CPUID];
	 cache[index][set].valid <= 1;
	 cache[index][set].tag <= tag;	 
      end
      if (cstate == HIT && ccif.dWEN[CPUID]) begin
	 cache[index][set].dirty <= 1;
      end
   end
   
   always_comb begin : STATE_LOGIC
      casez (cstate)
	IDLE: begin
	   nstate = IDLE;
	   if (dcif.dmemWEN|dcif.dmemREN)
	     nstate = SELECT;
	end
	SELECT: begin
	   nstate = SELECT;
	   if (dcif.dhit) //hit
	     nstate = HIT;
	   else if (cache[index][set].dirty) //miss and dirty
	     nstate = WRITEBACK1;
	   else //miss but not dirty
	     nstate = FETCH1;
	end	
	WRITEBACK1: begin
	   if (ccif.dwait[CPUID])
	     nstate = WRITEBACK1;
	   else
	     nstate = WRITEBACK2;
	end	
	WRITEBACK2: begin
	   nstate = FETCH1;
	end	
	FETCH1: begin
	   if (ccif.dwait[CPUID])
	     nstate = FETCH1;
	   else
	     nstate = FETCH2;
	end	
	FETCH2: nstate = HIT;
	HIT: nstate = IDLE;
	default: nstate = IDLE;
      endcase
   end

   always_comb begin : OUTPUT_LOGIC
      casez(cstate)
	IDLE: begin
	   ccif.dWEN[CPUID] = 0;
	   ccif.dREN[CPUID] = 0;	   
	end
	SELECT: begin
	   ccif.dWEN[CPUID] = dcif.dmemWEN;
	   ccif.dREN[CPUID] = dcif.dmemREN; 
	end
	WRITEBACK1: begin
	   ccif.dWEN[CPUID] = 1;
	   ccif.dREN[CPUID] = 0;
	end
	WRITEBACK2: begin
	   ccif.dWEN[CPUID] = 1;
	   ccif.dREN[CPUID] = 0;
	end
	FETCH1: begin
	   ccif.dWEN[CPUID] = 0;
	   ccif.dREN[CPUID] = 1;
	end
	FETCH2: begin
	   ccif.dWEN[CPUID] = 0;
	   ccif.dREN[CPUID] = 1;	   
	end
	HIT: begin
	   //nothing
	end
	default: begin
	   ccif.dWEN[CPUID] = 0;
	   ccif.dREN[CPUID] = 0;
	end
      endcase
   end
   
/*
	  if (!dcif.dhit && !ccif.dwait[CPUID]) begin
	     cache[index].tag[offset] <= tag;
	     cache[index].valid <= 1;
	     cache[index].data[offset] <= ccif.dload[CPUID];
	  end
  */
   
endmodule
