//File name: source/btb.sv
//Created: 3/2/2014
//Author:Steven ellis (mg205)
//Lab Section:437-04
//Description:Branch Predictor Table

`include "cpu_types_pkg.vh"
`include "btb_if.vh"

import cpu_types_pkg::*;
import btb_pkg::*;
module btb
  (
   input logic CLK, nRST,
   btb_if bpif
   );

   logic [1:0] tag, tag_w;
   assign tag = bpif.pc[3:2];
   assign tag_w = bpif.pc_w[3:2];

   //logic for writing to the BTB
   always_ff @(posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 bpif.entries <= '0;
      end
      else if (bpif.WEN) begin
	 //only update state machine if this PC is already in the entries
	 if (bpif.pc_w == bpif.entries[tag_w].pc) begin
	    //state machine for predictor
	    casez (bpif.entries[tag_w].state)
              STRONG_TAKEN: bpif.entries[tag_w].state <= bpif.taken_w ? STRONG_TAKEN : WEAK_TAKEN;
              WEAK_TAKEN: bpif.entries[tag_w].state <= bpif.taken_w ? STRONG_TAKEN : WEAK_NOT_TAKEN;
              WEAK_NOT_TAKEN: bpif.entries[tag_w].state <= bpif.taken_w ? WEAK_TAKEN : STRONG_NOT_TAKEN;
              STRONG_NOT_TAKEN: bpif.entries[tag_w].state <= bpif.taken_w ? WEAK_NOT_TAKEN : STRONG_NOT_TAKEN;
	    endcase
	 end else begin
	    //if this PC wasn't in the BTB, write it and initialize the state machine
	    bpif.entries[tag_w].pc <= bpif.pc_w;
	    bpif.entries[tag_w].target <= bpif.target_w;
	    bpif.entries[tag_w].state <= WEAK_TAKEN;
	 end
	 bpif.entries[tag_w].valid <= 1;
      end
   end

   //logic for reading from the BTB
   always_comb begin
      //check if this PC is in the BTB
      if (bpif.entries[tag].valid && (bpif.entries[tag].pc == bpif.pc)) begin
	 bpif.target = bpif.entries[tag].target;
	 bpif.taken =
			  (bpif.entries[tag].state == STRONG_TAKEN) ||
			  (bpif.entries[tag].state == WEAK_TAKEN) ? 1 : 0;
      end else begin
	 //if PC is not already in BTB, always predict not taken
	 bpif.target = 32'b0;
	 bpif.taken = 0;
      end
   end

endmodule
