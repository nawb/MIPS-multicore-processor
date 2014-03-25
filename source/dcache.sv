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

   typedef enum
      {RESET, IDLE, WRITEBACK1, WRITEBACK2, FETCH1, FETCH1DONE, FETCH2, FETCH2DONE, FLUSH1, FLUSH2, FLUSHED} states;
   states cstate, nstate;
   
   typedef struct packed {
      logic [25:0] tag;
      word_t [1:0] data;
      logic 	   valid;
      logic 	   dirty;
   } cache_block;

   //internal signal
   logic 	   dhit_t;   
   
   cache_block [7:0][1:0] cache; //2-way set associative
   logic [DTAG_W-1:0] tag;
   logic [DIDX_W-1:0] index;
   logic [DBLK_W-1:0] offset;   //block offset
   //logic 	      set; //block_select
   logic 	      wset, rset;
   
   int 		      hitcount = 0; 
   logic [3:0] 	      flush_block, flush_block_next;   
   logic [2:0] 	      block;   
   logic 	      way;   
   cache_block flushing_block;  
   assign block = flush_block[2:0];   
   assign way = flush_block[3];   
   assign flushing_block = cache[block][way];
   
   //table storing recently used info
   logic [7:0] 	      used;
   
   dcachef_t addr;
   assign addr = dcachef_t'(dcif.dmemaddr);
   assign tag = addr.tag;
   assign index = addr.idx;
   assign offset = addr.blkoff;

   /* choosing which set to load into in LRU:
    * index matches. so have to check tag to pick which set.
    * - if tag matches one of them (and it is valid), return that one.  [dhit_t]
    * - if tag does not match either,                                   [!dhit_t]
    *   - if set0 is empty (valid=0), pick set0.
    *   - if set0 is not empty, and set1 is empty, pick set1.
    *   - if both are not empty,
    *     - check used[index]. it will tell which set was last used (it is either 0 or 1), so pick THE OTHER.
    *     - here it should already have gone into WRITEBACK, so we should provide the right set#.
    */

   // Divided set into two set selects: rset, wset. rset is used in IDLE (when we're only reading from a set.) wset otherwise.
   
   assign rset = ((cache[index][1].tag == tag) && cache[index][1].valid)? 1:0;   
   always_comb begin: WSET_LOGIC
      casez(cstate)
	RESET: begin
	   wset = 0;	   
	end
	IDLE, WRITEBACK1, FETCH1: begin
	   if (cache[index][0].valid == 0) begin
	      wset = 0;
	   end
	   else if (cache[index][1].valid == 0) begin
	      wset = 1;
	   end
	   else begin
	      wset = ~used[index];	      
	   end
	end
	//set should only be altered these 4 states...it is latched on for the rest.
	default: wset = wset;
      endcase
   end

   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 cstate <= RESET;
	 flush_block <= '0;
      end
      else begin
	 cstate <= nstate;
	 flush_block <= flush_block_next;
      end
   end
   
   always_comb begin : NEXT_STATE_LOGIC
      nstate = cstate;
      flush_block_next = flush_block;
      casez (cstate)
	RESET: begin
	   nstate = IDLE;	   
	end
	IDLE: begin
	   if (dcif.halt) begin
	      nstate = FLUSH1;	      
	   end
	   else if (dcif.dmemREN || dcif.dmemWEN) begin
              if (dhit_t) begin
		 nstate = IDLE;
		 hitcount++;
	      end
              else if (cache[index][rset].dirty) begin //miss and dirty
		 nstate = WRITEBACK1; end
              else begin //miss but not dirty	      
		 nstate = FETCH1; end
	   end
	   else begin
	      nstate = IDLE;    
	   end
	end
	WRITEBACK1: begin
           if (!ccif.dwait[CPUID]) begin
             nstate = WRITEBACK2; end
           else begin
             nstate = WRITEBACK1; end
	end
	WRITEBACK2: begin
           if (!ccif.dwait[CPUID]) begin
             nstate = FETCH1; end
           else begin
             nstate = WRITEBACK2; end
	end
	FETCH1: begin
           if (!ccif.dwait[CPUID]) begin
             nstate = FETCH1DONE; end
           else begin
             nstate = FETCH1; end
	end
	FETCH1DONE: begin
	   nstate = FETCH2;
	end
	FETCH2: begin
           if (!ccif.dwait[CPUID]) begin
              nstate = FETCH2DONE; end
           else begin
             nstate = FETCH2; end
	end
	FETCH2DONE: begin
	   nstate = IDLE;	   
	end
	FLUSH1: begin
	   if (flushing_block.dirty) begin	      
	      //writeback if dirty
	      if (!ccif.dwait) begin
		 nstate = FLUSH2;
	      end
	   end else begin
	      //skip to next block if not
	      if (flush_block == 4'hF) begin
		 nstate = FLUSHED;
	      end else begin
		 flush_block_next = flush_block + 1;
	      end
	   end
	end
	FLUSH2: begin
	   if (!ccif.dwait) begin
	      if (flush_block == '1) begin
		 nstate = FLUSHED;
	      end else begin
		 nstate = FLUSH1;
		 flush_block_next = flush_block + 1;
	      end
	   end
	end 
	default: begin
	   nstate = IDLE;
	   flush_block_next = flush_block;
	end

      endcase
      //if(dcif.halt && (cstate != FLUSH1)) nstate = FLUSH1;
   end   
   
   always_comb begin : OUTPUT_LOGIC            
      casez(cstate)
	RESET: begin
	   cache <= '0;
	   used <= '0;
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 0;
	   ccif.daddr[CPUID] <= '0;
	   ccif.dstore[CPUID] <= '0;	 
	   dcif.dmemload <= '0;
	   dcif.dhit <= 0;	   
	end
	IDLE: begin
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 0;
	   ccif.daddr[CPUID] <= dcif.dmemaddr;
	   dcif.dhit <= 0;	   
	   if (dhit_t) begin
	      if (dcif.dmemREN) begin
		 dcif.dmemload <= cache[index][rset].data[offset];
		 dcif.dhit <= 1;
		 used[index] <= rset;
	      end
	      else if (dcif.dmemWEN) begin
		 cache[index][rset].data[offset] <= dcif.dmemstore;
		 cache[index][rset].dirty <= 1;
		 used[index] <= rset;
		 dcif.dhit <= 1;		 
	      end
	   end
	end
	WRITEBACK1: begin
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 1;
	   ccif.daddr[CPUID] <= {tag, index, 3'b000};
	   ccif.dstore[CPUID] <= cache[index][wset].data[0];//(~used[index])].data[0];
	   cache[index][wset].dirty <= 0;
	end
	WRITEBACK2: begin
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 1;
	   ccif.daddr[CPUID] <= {tag, index, 3'b100};
	   ccif.dstore[CPUID] <= cache[index][wset].data[1];//(!used[index])].data[1];
	end
      	FETCH1: begin
	   ccif.dREN[CPUID] <= 1;
	   ccif.dWEN[CPUID] <= 0;
	   ccif.daddr[CPUID] <= {tag, index, 3'b000};
	   cache[index][wset].tag <= tag;
	   cache[index][wset].data[0] <= ccif.dload[CPUID];
	   $display("dload: %h | %h", ccif.dload[CPUID], cache[index][wset].data[offset]);	   
	end
	FETCH1DONE: begin
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 0;
	   cache[index][wset].valid <= 1;
	end
	FETCH2: begin
	   ccif.dREN[CPUID] <= 1;
	   ccif.dWEN[CPUID] <= 0;
	   ccif.daddr[CPUID] <= {tag, index, 3'b100};
	   cache[index][wset].data[1] <= ccif.dload[CPUID];
	   if (!dcif.dmemWEN) dcif.dhit <= ~ccif.dwait[CPUID];
	end
	FETCH2DONE: begin
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 0;
	   dcif.dmemload <= cache[index][wset].data[offset]; //return the one asked for
	   if (dcif.dmemWEN) begin
	      cache[index][rset].data[offset] <= dcif.dmemstore;
	      cache[index][rset].dirty <= 1;	      
	      dcif.dhit <= 1;
	   end 	   
	   used[index] <= wset;	   
	   $display("[%s]dmemload: %h", cstate, cache[index][wset].data[offset]);
	end
	FLUSH1: begin
	   ccif.daddr[CPUID] <= {flushing_block.tag, block, 3'b000};
	   ccif.dWEN[CPUID] <= 1;
	   ccif.dstore[CPUID] = flushing_block.data[0];
	end
	FLUSH2: begin
	   ccif.daddr[CPUID] <= {flushing_block.tag, block, 3'b100};
	   ccif.dWEN[CPUID] <= 1;
	   ccif.dstore[CPUID] = flushing_block.data[1];
	end
	default: begin
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 0;
	   ccif.daddr[CPUID] <= dcif.dmemaddr;
	end
      endcase
   end // block: OUTPUT_LOGIC

/*
   assign ccif.dWEN[CPUID] = ( ((cstate == FLUSH2) && flushing_block.dirty) || ((cstate == FLUSH1) && flushing_block.dirty) ||
	(cstate == WRITEBACK1) || (cstate == WRITEBACK2) || (cstate == WRITEBACK3)) && (dcif.dmemREN && !dcif.dhit);
    */

   assign dhit_t = (dcif.dmemREN || dcif.dmemWEN) && 
		   (((cache[index][0].tag == tag) && cache[index][0].valid) ||
		   ((cache[index][1].tag == tag) && cache[index][1].valid));
  
   always_comb begin : DCIFFLUSHED
      casez(cstate)
	FLUSHED: begin
	   dcif.flushed <= 1;
	end
	default:
	  dcif.flushed <= 0;
      endcase
   end
   
endmodule
