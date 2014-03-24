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

typedef enum  {IDLE, SELECT, WRITEBACK1, WRITEBACK2, WRITEBACK3, FETCH1, FETCHWAIT, FETCH2, FETCH3, FLUSHING, FLUSHED} states;
states cstate, nstate;

typedef struct packed {
  logic [25:0] tag;
  word_t [1:0] data;
  logic 	      valid;
  logic 	      dirty;
} cache_block;


cache_block [8][2] cache; //2-way set associative
logic [DTAG_W-1:0]    tag;
logic [DIDX_W-1:0] 	 index;
logic [DBLK_W-1:0] 	 offset;   //block offset
logic 		 set; //block_select

//table storing recently used info
logic [7:0]    used;

dcachef_t addr;
assign addr = dcachef_t'(dcif.dmemaddr);
assign tag = addr.tag;
assign index = addr.idx;
assign offset = addr.blkoff;

assign ccif.dREN[CPUID] = ((cstate == FETCH1) || (cstate == FETCH2) || (cstate == FETCH3)) && (dcif.dmemREN && !dcif.dhit);
assign ccif.dWEN[CPUID] = ((cstate == WRITEBACK1) || (cstate == WRITEBACK2) || (cstate == WRITEBACK3)) && (dcif.dmemREN && !dcif.dhit);
//assign set = (cache[index][1].tag == tag)? 1:0;
assign dcif.dmemload = cache[index][set].data[offset];
assign dcif.dhit = (dcif.dmemREN || dcif.dmemWEN) && (cache[index][set].tag == tag) && cache[index][set].valid;

always_comb begin : DADDR
  casez(cstate)
    FETCH1, WRITEBACK1: ccif.daddr[CPUID] = {tag, index, 3'b000};
    FETCH2, WRITEBACK2: ccif.daddr[CPUID] = {tag, index, 3'b100};
    default: ccif.daddr[CPUID] = dcif.dmemaddr;
  endcase
end

  always_ff @ (posedge CLK, negedge nRST) begin
    if (!nRST) begin
      cstate <= IDLE;
      cache <= '0;
      used <= '0;
    end
    else
      cstate <= nstate;
      if (cstate == FETCH1) begin
        //cache[index][set].valid <= 1;
        cache[index][set].tag <= tag;
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

  always_comb begin : STATE_LOGIC
  set = ((cache[index][1].tag == tag) && (cache[index][1].valid))? 1:0;
    casez (cstate)
      IDLE: begin
        if (dcif.dhit) //hit
          nstate <= IDLE;
        else if (cache[index][set].dirty) //miss and dirty
          nstate <= WRITEBACK1;
        else //miss but not dirty
          nstate <= FETCH1;
      end
      WRITEBACK1: begin
        set <= !used[index];
        if (ccif.dwait[CPUID])
          nstate <= WRITEBACK1;
        else
          nstate <= WRITEBACK2;
      end
      WRITEBACK2: begin
        set <= !used[index];
        if (ccif.dwait[CPUID])
          nstate <= WRITEBACK2;
        else
          nstate <= IDLE;
      end
      WRITEBACK3: begin
        nstate <= FETCH1;
        set <= !used[index];
      end
      FETCH1: begin
        if (ccif.dwait[CPUID])
          nstate <= FETCH1;
        else
          nstate <= FETCH2;
      end
      FETCHWAIT: begin
      end
      FETCH2: begin
        if (ccif.dwait[CPUID])
          nstate <= FETCH2;
        else
          nstate <= FETCH3;
      end
      FETCH3: begin
        nstate <= IDLE;
      end
      default: nstate <= IDLE;
    endcase
    if(dcif.halt[CPUID]) nstate <= FLUSHING;
  end

  always_comb begin : OUTPUT_LOGIC
	assign dcif.flushed = (cstate == FLUSHING);
  /*
  casez(cstate)
    IDLE: begin
      ccif.dWEN[CPUID] = 0;
      ccif.dREN[CPUID] = 0;
    end
    WRITEBACK1: begin
      ccif.dWEN[CPUID] = 1;
      ccif.dREN[CPUID] = 0;
      set = !used[index];
    end
    WRITEBACK2: begin
      ccif.dWEN[CPUID] = 1;
      ccif.dREN[CPUID] = 0;
      set = !used[index];
    end
    FETCH1: begin
      ccif.dWEN[CPUID] = 0;
      ccif.dREN[CPUID] = 1;
    end
    FETCH2: begin
      ccif.dWEN[CPUID] = 0;
      ccif.dREN[CPUID] = 1;
    end
    default: begin
      ccif.dWEN[CPUID] = 0;
      ccif.dREN[CPUID] = 0;
    end
  endcase
  */
  end
  endmodule
