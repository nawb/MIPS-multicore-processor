//File name: 	source/forwarding_unit.sv
//Created: 	02/26/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	Forwarding unit for correcting data hazards in pipeline

`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module forwarding_unit ( forwarding_unit_if.fwd fwif );
   always_comb begin : OP1_handling
      if (fwif.wr_mem && (fwif.rd_mem == fwif.curr_rs) && (fwif.curr_rs != 0)) begin
	 //MEM has a new value
	 fwif.fwd_op1 = 1;
      end
      else if (fwif.wr_wb && (fwif.rd_wb == fwif.curr_rs) && (fwif.curr_rs != 0)) begin
	//WB has a new value
	 fwif.fwd_op1 = 2;
      end
      else begin
	 fwif.fwd_op1 = 0;
      end
   end // block: OP1_handling

   always_comb begin : OP2_handling
      if (fwif.wr_mem && (fwif.rd_mem == fwif.curr_rt) && (fwif.curr_rt != 0)) begin
	 //MEM has a new value
	 fwif.fwd_op2 = 1;
      end      
      else if (fwif.wr_wb && (fwif.rd_wb == fwif.curr_rt) && (fwif.curr_rt != 0)) begin
	//WB has a new value
	 fwif.fwd_op2 = 2;
      end
      else begin
	 fwif.fwd_op2 = 0;
      end
   end // block: OP2_handling

   always_comb begin : ITYPE_handling
      //if writing to memory, and register you're writing from has a newer value
      if (fwif.wm_mem && (fwif.rd_mem == fwif.rd_wb)) begin
	fwif.fwd_mem = 1;
  end
/*      else if (fwif.wr_wb && (fwif.rd_wb == fwif.mem_rt) && (fwif.mem_rt != 0)) begin
	//WB has a new value
	 fwif.fwd_mem = 1;
      end*/
      else
	fwif.fwd_mem = 0;
   end

endmodule
