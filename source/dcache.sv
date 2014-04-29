//File name: 	source/dcache.sv
//Created: 	03/07/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

// interfaces
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"
//`include "msi_if.vh"

// cpu types
`include "cpu_types_pkg.vh"

module dcache (
	       input logic CLK, nRST,
	       datapath_cache_if dcif,
	       cache_control_if ccif
	       );
   // import types
   import cpu_types_pkg::*;
   // import msi_pkg::*;   
   parameter CPUID = 0;

   // msi_if msif ();
   // msi    MSI(CLK, nRST, msif);
   
   typedef enum 	   
			   {RESET, IDLE, INVALIDATION, CCWRITEBACK0, CCWRITEBACK1, CCWRITEBACK2, WRITEBACK1, WRITEBACK2, FETCH1, FETCH2, FETCH2DONE, FLUSH1, FLUSH2, FLUSH1DONE, FLUSH2DONE, FLUSHED, FLUSHEDALLDONE} states;
   states cstate, nstate;

   typedef enum 	   logic[1:0] {I,S,M} msistate;   
   
   typedef struct 	   packed {      
      logic [25:0] 	   tag;
      word_t [1:0] data;
      logic 		   valid;
      logic 		   dirty;
      msistate     ccstate;
   } cache_block;
   
   //internal signal
   logic 		   dhit_t, snoophit;
   
   cache_block cache[7:0][1:0]; //2-way set associative
   cache_block cache_next[7:0][1:0];
   logic [DTAG_W-1:0] 	   tag, snooptag;
   logic [DIDX_W-1:0] 	   index, snoopindex;
   logic [DBLK_W-1:0] 	   offset, snoopoffset;   //block offset
   logic 		   wset, wset_next, rset, snoopset;
   
   int 			   hitcount; 
   int 			   hitcount_next;
   logic [3:0] 		   flush_block, flush_block_next;   
   logic [2:0] 		   block;
   logic 		   way;
   cache_block flushing_block;  
   assign block = flush_block[2:0];   
   assign way = flush_block[3];   
   assign flushing_block = cache[block][way];
   
   //table storing recently used info
   logic [7:0] 		   used, used_next;
   
   dcachef_t addr;
   assign addr = dcachef_t'(dcif.dmemaddr);
   assign tag = addr.tag;
   assign index = addr.idx;
   assign offset = addr.blkoff;

   dcachef_t snoopaddr;
   assign snoopaddr = dcachef_t'(ccif.ccsnoopaddr);
   assign snooptag = snoopaddr.tag;
   assign snoopindex = snoopaddr.idx;
   assign snoopoffset = snoopaddr.blkoff;

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
   assign snoopset = ((cache[snoopindex][1].tag == snooptag) && cache[snoopindex][1].valid)? 1:0;
   always_comb begin: WSET_LOGIC
      casez(cstate)
	RESET: begin
	   wset_next = 0;	   
	end
	IDLE, WRITEBACK1, FETCH1: begin
	   if (cache[index][0].valid == 0) begin
	      wset_next = 0;
	   end
	   else if (cache[index][1].valid == 0) begin
	      wset_next = 1;
	   end
	   else begin
	      wset_next = ~used[index];	      
	   end
	end
	//set should only be altered these 4 states...it is latched on for the rest.
	default: wset_next = wset;
      endcase
   end

   //LL/SC stuff:
   word_t linkreg, nextlinkreg;
   logic linkvalid, nextlinkvalid;
   
   word_t tempload;
   assign tempload = ccif.dload[CPUID];
   
   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 cstate <= RESET;
	 flush_block <= '0;
	 hitcount <= 0;
	 wset <= 0;
	 used <= '0;
	 linkreg <= '0;
	 linkvalid <= 0;
	 for (int i=0; i<8; i++) begin
	    cache[i][0].valid <= 0;//{ >> {'0 }};
	    cache[i][1].valid <= 0;//{ >> {'0 }};
	    cache[i][0].tag <= '0;
	    cache[i][1].tag <= '0;
	    cache[i][0].dirty <= 0;
	    cache[i][1].dirty <= 0;
	    cache[i][0].data[0] <= '0;
	    cache[i][0].data[1] <= '0;
	    cache[i][1].data[0] <= '0;
	    cache[i][1].data[1] <= '0;
	    cache[i][0].ccstate <= I;
	    cache[i][1].ccstate <= I;	    
	 end
      end
      else begin
	 cstate <= nstate;
	 flush_block <= flush_block_next;
	 hitcount <= hitcount_next;
	 cache <= cache_next;
	 wset <= wset_next;
	 used <= used_next;	 
	 linkreg <= nextlinkreg;
	 linkvalid <= nextlinkvalid;
      end
   end
   
   always_comb begin : NEXT_STATE_LOGIC
      nstate <= cstate;
      flush_block_next <= flush_block;
      hitcount_next <= hitcount;
      
      casez (cstate)
	RESET: begin
	   nstate <= IDLE;	   
	end
	IDLE: begin
	   //COHERENCE OPERATIONS:
	   if (ccif.ccwait[CPUID]) begin
	      if (snoophit && ccif.ccinv[CPUID]) begin
		 //M or S is getting invalidated
		 nstate <= INVALIDATION;
	      end else if (snoophit && cache[snoopindex][snoopset].ccstate == M) begin
		 //other core wants something we have in Modified
		 nstate <= CCWRITEBACK1;
	      end else begin		 
		 nstate <= IDLE;		    
	      end
	   end
	   //NORMAL OPERATIONS
	   else if (dcif.halt) begin
	      nstate <= FLUSH1;	      
	   end
	   else if (dcif.dmemREN || dcif.dmemWEN) begin
              if (dhit_t) begin
		 nstate <= IDLE;
		 hitcount_next <= hitcount + 1;
	 	 $display("hit %d", hitcount_next);
	      end
              else if (cache[index][rset].dirty && cache[index][wset_next].dirty) begin //miss and dirty
		 nstate <= WRITEBACK1; end
              else begin //miss but not dirty	      
		 nstate <= FETCH1; end
	   end
	   else begin
	      nstate <= IDLE;    
	   end
	end // case: IDLE
	INVALIDATION: begin
	   nstate <= IDLE;	   
	end
	CCWRITEBACK0: begin
	   nstate <= IDLE;	   
	end
	CCWRITEBACK1: begin //like WRITEBACK1 except doesnt go to fetch afterwards
	   if (!ccif.dwait[CPUID]) begin
	      nstate <= CCWRITEBACK2;	      
	   end else begin
	      nstate <= CCWRITEBACK1;	      
	   end
	end
	CCWRITEBACK2: begin
	   if (!ccif.dwait[CPUID]) begin
	      nstate <= CCWRITEBACK0;	      
	   end else begin
	      nstate <= CCWRITEBACK2;	      
	   end
	end
	WRITEBACK1: begin
           if (!ccif.dwait[CPUID]) begin
              nstate <= WRITEBACK2; end
           else begin
              nstate <= WRITEBACK1; end
	end
	WRITEBACK2: begin
           if (!ccif.dwait[CPUID]) begin
              nstate <= FETCH1; end
           else begin
              nstate <= WRITEBACK2; end
	end
	FETCH1: begin
           if (!ccif.dwait[CPUID]) begin
              nstate <= FETCH2; end
           else begin
              nstate <= FETCH1; end
	end
	FETCH2: begin
           if (!ccif.dwait[CPUID]) begin
              nstate <= FETCH2DONE; end
           else begin
              nstate <= FETCH2; end
	end
	FETCH2DONE: begin
	   nstate <= IDLE;	   
	end
	FLUSH1: begin
	   if (flushing_block.dirty) begin	      
	      //writeback if dirty
	      if (!ccif.dwait[CPUID]) begin
		 nstate <= FLUSH1DONE;
	      end else begin
		 nstate <= FLUSH1;
	      end
	   end else begin
	      //skip to next block if not
	      if (flush_block == 4'hF) begin
		 nstate <= FLUSHED;
	      end else begin
		 flush_block_next <= flush_block + 1;
	      end
	   end
	end
	FLUSH1DONE: begin
	   nstate <= FLUSH2;
	end
	FLUSH2: begin
	   if (!ccif.dwait[CPUID]) begin
	      if (flush_block == '1) begin
		 nstate <= FLUSHED;
		 flush_block_next <= flush_block;
	      end else begin
		 nstate <= FLUSH2DONE;
		 flush_block_next <= flush_block + 1;
	      end
	   end
	end
	FLUSH2DONE: begin
	   nstate <= FLUSH1;
	end
	FLUSHED: begin
	   nstate <= FLUSHEDALLDONE;
	end
	FLUSHEDALLDONE: begin
	   nstate <= FLUSHEDALLDONE;	   
	end
	default: begin
	   nstate <= IDLE;
	   flush_block_next <= flush_block;
	   hitcount_next <= hitcount;
	end

      endcase
      //if(dcif.halt && (cstate != FLUSH1)) nstate = FLUSH1;
   end // block: NEXT_STATE_LOGIC
   //word_t memstore_t;
   //logic temp;
   
   always_comb begin : OUTPUT_LOGIC
      cache_next <= cache;
      nextlinkreg <= linkreg;
      nextlinkvalid <= linkvalid;
      casez(cstate)
	RESET: begin
	   initial_values();	   
	   used_next <= '0;
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 0;
	   ccif.daddr[CPUID] <= '0;
	   ccif.dstore[CPUID] <= '0;
	   dcif.dmemload <= '0;
	   dcif.dhit <= 0;
	   //memstore_t <= '0;	   
	end
	IDLE: begin
	   initial_values();	   
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 0;
	   ccif.daddr[CPUID] <= dcif.dmemaddr;
	   dcif.dhit <= 0;
	   
	   if (dhit_t) begin
	      if (dcif.dmemREN) begin
		 dcif.dmemload <= cache[index][rset].data[offset];
		 dcif.dhit <= 1;
		 used_next[index] <= rset;
	      end
	      else if (dcif.dmemWEN) begin
		 if (linkreg == dcif.dmemaddr) begin : LOCK_BROKEN
		    nextlinkvalid <= 0;		 
		 end
		 if (!(dcif.datomic && !linkvalid)) begin //if lock HAD been broken, don't store
		    cache_next[index][rset].data[offset] <= dcif.dmemstore; 
		 end
		 
		 cache_next[index][rset].dirty <= 1;
		 used_next[index] <= rset;
		 dcif.dhit <= 1;
		 cache_next[index][rset].ccstate <= M;
		 if (cache[index][wset].ccstate != M) begin
		    //if previous state was S or I, issue a BusRdX to ccinv others
		    ccif.cctrans[CPUID] <= 1;
		    ccif.ccwrite[CPUID] <= 1;
		 end
	      end
	   end

	   //LL/SC IMPLEMENTATION:
	   if (dcif.datomic && dcif.dmemWEN) begin : STORE_CONDITIONAL
	      //check if linkreg holds correct address
	      if ((dcif.dmemaddr == linkreg) && linkvalid) begin : SC_SUCCESS
		 dcif.dmemload <= 1;
		 nextlinkreg <= linkreg|1'b1;
		 nextlinkvalid <= 0;	    
	      end else begin : SC_FAIL		 
		 dcif.dmemload <= 0;
		 nextlinkvalid <= 0;
	      end
	   end
	   else if (dcif.datomic && dcif.dmemREN) begin : LOAD_LINK
	      nextlinkreg <= dcif.dmemaddr;
	      nextlinkvalid <= 1;
	   end

	   if (snoophit && ccif.ccinv[CPUID]) begin
	      ccif.cctrans[CPUID] <= 1; //going to INVALIDATION state
	   end
	   if (snoophit && cache[snoopindex][snoopset].ccstate == M) begin
	      ccif.cctrans[CPUID] <= 1;	//going to CCWRITEBACK0 state
	      ccif.ccwrite[CPUID] <= 1;	      
	   end
	end // case: IDLE
	INVALIDATION: begin
	   initial_values();	   
	   cache_next[snoopindex][snoopset].ccstate <= I;
	   cache_next[snoopindex][snoopset].valid <= 0;
	   ccif.cctrans[CPUID] <= 0; //done transitioning
	   /*
	   if (cache[snoopindex][snoopset].ccstate == M) begin
	      //Modified is getting invalidated
	      ccif.dstore[CPUID] <= cache_next[snoopindex][snoopset].data[snoopoffset];
	      cache_next[snoopindex][snoopset].ccstate <= S;
	      ccif.cctrans[CPUID] <= 1;
	      ccif.dWEN[CPUID] <= 1;		    
	      ccif.ccwrite[CPUID] <= 1;
	   end
	   else if (cache[snoopindex][snoopset].ccstate == S) begin
	      ccif.dstore[CPUID] <= cache_next[snoopindex][snoopset].data[snoopoffset];
	      ccif.cctrans[CPUID] <= 0;
	      ccif.ccwrite[CPUID] <= 1;
	   end else begin    //BusRd			       
	      ccif.cctrans[CPUID] <= 0;
	      ccif.ccwrite[CPUID] <= 0;
	   end*/
	end 	
	CCWRITEBACK0: begin
	   initial_values();	   
	   ccif.dstore[CPUID] <= cache_next[snoopindex][snoopset].data[snoopoffset]; //send only the word in block that other cache asked for
	   ccif.ccwrite[CPUID] <= 1;
	   cache_next[snoopindex][snoopset].ccstate <= S;
	   ccif.cctrans[CPUID] <= 1;
	end
	CCWRITEBACK1: begin
	   initial_values();
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 1;
	   ccif.daddr[CPUID] <= {cache_next[snoopindex][snoopset].tag, snoopindex, 3'b000};
	   ccif.dstore[CPUID] <= cache_next[snoopindex][snoopset].data[0];//(~used[index])].data[0];
	   cache_next[snoopindex][snoopset].dirty <= 0;
	   ccif.ccwrite[CPUID] <= 1;
	end
	CCWRITEBACK2: begin
	   initial_values();
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 1;
	   ccif.daddr[CPUID] <= {cache_next[snoopindex][snoopset].tag, snoopindex, 3'b100};
	   ccif.dstore[CPUID] <= cache_next[snoopindex][snoopset].data[1];//(!used[index])].data[1];
	   ccif.ccwrite[CPUID] <= 0;
	end

	WRITEBACK1: begin
	   initial_values();
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 1;
	   ccif.daddr[CPUID] <= {cache_next[index][wset].tag, index, 3'b000};
	   ccif.dstore[CPUID] <= cache_next[index][wset].data[0];//(~used[index])].data[0];
	   cache_next[index][wset].dirty <= 0;
	   ccif.ccwrite[CPUID] <= 1;
	end
	WRITEBACK2: begin
	   initial_values();
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 1;
	   ccif.daddr[CPUID] <= {cache_next[index][wset].tag, index, 3'b100};
	   ccif.dstore[CPUID] <= cache_next[index][wset].data[1];//(!used[index])].data[1];
	   ccif.ccwrite[CPUID] <= 1;	   
	end	
      	FETCH1: begin	   
	   initial_values();
	   cache_next[index][wset].data[0] <= tempload;
	   ccif.dREN[CPUID] <= 1;
	   ccif.dWEN[CPUID] <= 0;
	   ccif.daddr[CPUID] <= {tag, index, 3'b000};	   
	   cache_next[index][wset].tag <= tag;
	end
	FETCH2: begin
	   initial_values();
	   cache_next[index][wset].data[1] <= tempload;
	   ccif.dREN[CPUID] <= 1;
	   ccif.dWEN[CPUID] <= 0;
	   ccif.daddr[CPUID] <= {tag, index, 3'b100};	
	end
	FETCH2DONE: begin
	   initial_values();
	   ccif.dREN[CPUID] <= 0;
	   ccif.dWEN[CPUID] <= 0;
	   dcif.dmemload <= cache_next[index][wset].data[offset]; //return the one asked for
	   ccif.daddr[CPUID] <= {tag, index, 3'b100};
	   cache_next[index][wset].valid <= 1;
	   cache_next[index][wset].ccstate <= S;
	   ccif.cctrans[CPUID] <= 1;
	   if (dcif.dmemWEN) begin
	      cache_next[index][wset].data[offset] <= dcif.dmemstore;
	      cache_next[index][wset].dirty <= 1;
	      cache_next[index][wset].ccstate <= M;
	   end
	   dcif.dhit <= 1;
	   used_next[index] <= rset;
	   //$display("[%s]dmemload: %h", cstate, cache_next[index][wset].data[offset]);
	end
	FLUSH1: begin
	   initial_values();
	   ccif.daddr[CPUID] <= {flushing_block.tag, block, 3'b000};
	   ccif.dWEN[CPUID] <= flushing_block.dirty;
	   ccif.dstore[CPUID] <= flushing_block.data[0];
	end
	FLUSH2: begin
	   initial_values();
	   ccif.daddr[CPUID] <= {flushing_block.tag, block, 3'b100};
	   ccif.dWEN[CPUID] <= flushing_block.dirty;
	   ccif.dstore[CPUID] <= flushing_block.data[1];
	end
	FLUSHED: begin
	   initial_values();
	   ccif.cctrans[CPUID] <= 1;
	end
	FLUSHEDALLDONE: begin
	   initial_values();
	   ccif.cctrans[CPUID] <= 0;	   
	end
	default: begin
	   initial_values();
	   ccif.daddr[CPUID] <= dcif.dmemaddr;
	   cache_next <= cache;
	end
      endcase
   end // block: OUTPUT_LOGIC

   /*
    assign ccif.dWEN[CPUID] = ( ((cstate == FLUSH2) && flushing_block.dirty) || ((cstate == FLUSH1) && flushing_block.dirty) ||
    (cstate == WRITEBACK1) || (cstate == WRITEBACK2) || (cstate == WRITEBACK3)) && (dcif.dmemREN && !dcif.dhit);
    */

   //if the tag matches either of the tags in the set
   assign dhit_t = (dcif.dmemREN || dcif.dmemWEN) && 
		   (((cache[index][0].tag == tag) && cache[index][0].valid) ||
		    ((cache[index][1].tag == tag) && cache[index][1].valid));

   assign snoophit = (((cache[snoopindex][0].tag == snooptag) && cache[snoopindex][0].valid) ||
		      ((cache[snoopindex][1].tag == snooptag) && cache[snoopindex][1].valid));

   //assign ccif.cctrans[CPUID] = msif.command == BUSRD || msif.command == BUSRDX ? 1:0;//msif.cctrans[snoopindex][snoopset];
   //assign ccif.ccwrite[CPUID] = (msif.command == BUSRDX) ? 1:0;
   //msif.ccwrite[snoopindex][snoopset];
   
   always_comb begin : DCIFFLUSHED
      casez(cstate)
	FLUSHED,FLUSHEDALLDONE: begin
	   dcif.flushed <= 1;
	end
	default:
	  dcif.flushed <= 0;
      endcase
   end   
   
   task initial_values; 
      //initializes all the variables in OUTPUT_LOGIC so they don't create latches
      dcif.dhit <= 0;
      dcif.dmemload <= '0;      
      ccif.dstore[CPUID] <= cache[snoopindex][snoopset].data[snoopoffset];
      ccif.daddr[CPUID] <= '0;//ccif.daddr[CPUID];
      ccif.dREN[CPUID] <= 0;
      ccif.dWEN[CPUID] <= 0;
      used_next <= used;  
      ccif.cctrans[CPUID] <= 0;
      ccif.ccwrite[CPUID] <= 0;
      //temp <= 0;      
   endtask
   
endmodule
