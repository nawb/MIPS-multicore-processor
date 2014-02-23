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

   logic       memfree;   
   
   assign rqif.wreq = rqif.regwr;
   assign rqif.imemREN = 1'b1;
   
   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 rqif.dmemREN <= 0;
	 rqif.dmemWEN <= 0;
	 memfree <= 0;
	 rqif.pcEN <= rqif.ihit;	 
      end
      else begin
	 //rqif.dmemREN <= rqif.dhit & ~rqif.dcuREN ? 0 : rqif.dcuREN;
	 //rqif.dmemWEN <= rqif.dhit & ~rqif.dcuWEN ? 0 : rqif.dcuWEN;
	 rqif.dmemREN <= rqif.dhit ? 0 : rqif.dcuREN;
	 rqif.dmemWEN <= rqif.dhit ? 0 : rqif.dcuWEN;
	 memfree <= 0;
	 rqif.pcEN <= rqif.ihit; 
      end
      /*
      else if (!(rqif.dcuWEN || rqif.dcuREN)) begin //when not at a lw/sw instruction
	 rqif.dmemREN <= rqif.dcuREN;
	 rqif.dmemWEN <= rqif.dcuWEN;
	 rqif.pcEN <= rqif.ihit & !(rqif.dcuWEN || rqif.dcuREN);
	 memfree <= !rqif.dhit;
      end
      else if (!memfree) begin
	 rqif.dmemREN <= rqif.dcuREN;	 
	 rqif.dmemWEN <= rqif.dcuWEN;
	 rqif.pcEN <= 0;  //pause PC for a cycle, while using ram lines to get data	 
	 memfree <= rqif.dhit; //will stay in this case until receive a dhit,
	 //in which case it will go to the last case and proceed to deassert it
      end
      else begin
	 //on next clock cycle, deassert dENs to mark end of dR/W
	 rqif.dmemREN <= 0;
	 rqif.dmemWEN <= 0;
	 rqif.pcEN <= rqif.ihit; //reinstate PC.
	 memfree <= rqif.dhit;
      end*/
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

