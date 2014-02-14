//File name: 	source/request_unit.sv
//Created: 	02/11/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	request unit (hazard unit) coordinates between DP and memory_control

`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"

import cpu_types_pkg::*;

module request_unit
  (
   input logic CLK, nRST,
   request_unit_if.req rqif
   );

   assign rqif.wreq = rqif.regwr;   
   // assign rqif.imemREN = ~rqif.dhit;
   assign rqif.imemREN = 1'b1;
   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 rqif.dmemREN <= 0;
	 rqif.dmemWEN <= 0;
//	 rqif.pcEN <= 0;	 
      end
      else begin
	 //on next clock cycle, deassert dENs to mark end of dR/W
	 rqif.dmemREN <= rqif.dhit ? 0 : rqif.dcuREN;
	 rqif.dmemWEN <= rqif.dhit ? 0 : rqif.dcuWEN;
      end
   end
endmodule // request_unit


	 /*
	 else if (!(rqif.dcuWEN || rqif.dcuREN)) begin //when not at a lw/sw instruction
	  rqif.dmemREN <= rqif.dcuREN;
	  rqif.dmemWEN <= rqif.dcuWEN;	 
	  rqif.imemREN <= 1;
	  rqif.pcEN <= rqif.ihit & !(rqif.dcuWEN || rqif.dcuREN);
      end
	  
	  if (!memfree) begin //processing a dren/dwen
	  rqif.dmemREN <= rqif.dcuREN;
	    rqif.dmemWEN <= rqif.dcuWEN;
	    rqif.pcEN <= 0;
	    memfree <= rqif.dhit;
	 end
	 else begin
	    rqif.dmemREN <= 0;
	    rqif.dmemWEN <= 0;
	    rqif.pcEN <= rqif.ihit; //move to next instruction
	    memfree <= !rqif.ihit;
	 end	 
	  */

