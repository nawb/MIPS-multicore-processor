//File name: 	source/pc.sv
//Created: 	02/11/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	

`include "cpu_types_pkg.vh"
`include "pc_if.vh"
import cpu_types_pkg::*;


module pc
  #(PC_INIT)
  (
   input logic CLK, 
   input logic nRST, 
   pc_if.pc pcif
   );

   word_t pc_cnt;

   assign pcif.imemaddr = pc_cnt;   
   
   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 pc_cnt <= PC_INIT;
      end
      else begin
	 if (pcif.jumpmux) begin
	    pc_cnt <= pcif.imm26 << 2;	   
	 end
	 else begin
	    if (pcif.branchmux)
	      pc_cnt <= pc_cnt + 4 + (pcif.immext << 2);
	    else
	      pc_cnt <= pc_cnt + 4;	    
	 end
      end
   end
   
endmodule
