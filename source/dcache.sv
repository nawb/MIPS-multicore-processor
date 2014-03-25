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
      {IDLE, SELECT, WRITEBACK1, WRITEBACK2, WRITEBACK3, FETCH1, FETCHWAIT, FETCH2, FETCH3, FLUSH1, FLUSH2, FLUSHED} states;
   states cstate, nstate;
   
   typedef struct packed {
      logic [25:0] tag;
      word_t [1:0] data;
      logic 	   valid;
      logic 	   dirty;
   } cache_block;
   
   
   cache_block [7:0][1:0] cache; //2-way set associative
   logic [DTAG_W-1:0] tag;
   logic [DIDX_W-1:0] index;
   logic [DBLK_W-1:0] offset;   //block offset
   logic 	      set; //block_select
   
   int 		      hitcount; 
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


   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 cstate <= IDLE;
	 cache <= '0;
	 used <= '0;
	 hitcount <= '0;
	 flush_block <= '0;
      end
      else begin
	 cstate <= nstate;
	 flush_block <= flush_block_next;	 
	 if (cstate == FETCH1) begin
	    cache[index][set].tag <= tag;         
	    cache[index][set].data[0] <= ccif.dload[CPUID];
	    cache[index][set].valid <= 1;
	 end
	 if (cstate == FETCH2) begin
	    used[index] = set;
	    cache[index][set].data[1] <= ccif.dload[CPUID];
	 end
	 if ((cstate != WRITEBACK2) && ccif.dWEN[CPUID]) begin
	    cache[index][set].dirty <= 1;
	 end
	 if (cstate == WRITEBACK2) begin
	    cache[index][set].dirty <= 0;
	    end
	 if (cstate == FETCH2) begin	    
	    cache[index][set].data[0] <= ccif.dload[CPUID];	    
	    cache[index][set].valid <= 1;	    
	    //cache[index][set].tag <= tag;	       
	    used[index] = set;	
	 end
	 if (cstate == FETCH3) begin
	    cache[index][set].data[1] <= ccif.dload[CPUID];
	 end
	 if ((cstate != WRITEBACK2) && ccif.dWEN[CPUID]) begin
	    cache[index][set].dirty <= 1;
	 end
	 if (cstate == WRITEBACK2) begin
	    cache[index][set].dirty <= 0;
	 end
      end
   end
   
   always_comb begin : STATE_LOGIC
      set = ((cache[index][1].tag == tag) && (cache[index][1].valid))? 1:0;
      flush_block_next <= flush_block;
      
      casez (cstate)
	IDLE: begin
	   if (dcif.dmemREN || dcif.dmemWEN) begin
              if (dcif.dhit) begin //hit
		 nstate <= IDLE; end
              else if (cache[index][set].dirty) begin //miss and dirty
		 nstate <= WRITEBACK1; end
              else begin //miss but not dirty	      
		 nstate <= FETCH1; end
	   end
	   else begin
	      nstate <= IDLE;	      
	   end
	end
	WRITEBACK1: begin
           set <= !used[index];
           if (ccif.dwait[CPUID]) begin
             nstate <= WRITEBACK1; end
           else begin
             nstate <= WRITEBACK2; end
	end
	WRITEBACK2: begin
           set <= !used[index];
           if (ccif.dwait[CPUID]) begin
             nstate <= WRITEBACK2; end
           else begin
             nstate <= IDLE; end
	end
	FETCH1: begin
           if (ccif.dwait[CPUID]) begin
             nstate <= FETCH1; end
           else begin
             nstate <= FETCH2; end
	end
	FETCH2: begin
           if (ccif.dwait[CPUID]) begin
             nstate <= FETCH2; end
           else begin
             nstate <= IDLE; end
	end
	FLUSH1: begin
	   if (flushing_block.dirty) begin	      
	      //writeback if dirty
	      if (!ccif.dwait) begin
		 nstate <= FLUSH2;
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
	FLUSH2: begin
	   if (!ccif.dwait) begin
	      if (flush_block == '1) begin
		 nstate <= FLUSHED;
	      end else begin
		 nstate <= FLUSH1;
		 flush_block_next <= flush_block + 1;
	      end
	   end
	end 
	default: begin
	   nstate <= IDLE;
	   flush_block_next <= flush_block;
	end
	default: nstate <= IDLE;
      endcase
      if(dcif.halt && (cstate != FLUSH1)) nstate <= FLUSH1;
   end

   assign dcif.flushed = (cstate == FLUSHING);

   always_comb begin : DREN
      if (cstate == FETCH1) begin
	 ccif.dREN[CPUID] = dcif.dmemREN && !dcif.dhit;	 
      end
      else if (cstate == FETCH2) begin
	 ccif.dREN[CPUID] = !dcif.dhit;
      end
      else begin
	 ccif.dREN[CPUID] = 0;	 
      end
   end

   always_comb begin
      casez(cstate)
	FLUSHED: begin
	   dcif.flushed <= 1;
	end
	default:
	  dcif.flushed <= 0;
      endcase
   end
   
   assign ccif.dWEN[CPUID] = ( ((cstate == FLUSH2) && flushing_block.dirty) || ((cstate == FLUSH1) && flushing_block.dirty) ||
	(cstate == WRITEBACK1) || (cstate == WRITEBACK2) || (cstate == WRITEBACK3)) && (dcif.dmemREN && !dcif.dhit);

   //assign set = (cache[index][1].tag == tag)? 1:0;
   assign dcif.dmemload = cache[index][set].data[offset];
   assign dcif.dhit = (dcif.dmemREN || dcif.dmemWEN) && (cache[index][set].tag == tag) && cache[index][set].valid;
   assign ccif.dstore[CPUID] = '0;   
   
   always_comb begin : DADDR
      casez(cstate)
	FETCH1, WRITEBACK1: ccif.daddr[CPUID] = {tag, index, 3'b000};
	FETCH2, WRITEBACK2: ccif.daddr[CPUID] = {tag, index, 3'b100};
	FLUSH1: ccif.daddr[CPUID] = {flushing_block.tag, block, 3'b000};	
	FLUSH2: ccif.daddr[CPUID] = {flushing_block.tag, block, 3'b100};
	default: ccif.daddr[CPUID] = dcif.dmemaddr;
      endcase
   end

   
endmodule
