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

   word_t pc_cnt, pc_next;

   assign pcif.imemaddr = pc_cnt;   
   
   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 pc_cnt <= PC_INIT;
      end
      else if (pcif.pcEN) begin
	 pc_cnt <= pc_next;	 
      end
   end

   always_comb begin : PC_NEXT
      casez (pcif.pc_src)
	0: pc_next <= pc_cnt + 4;                   //normal
	1: pc_next <= pcif.branchmux ? pcif.imm16 : //beq/bne taken
		     pc_cnt + 4;                    //beq/bne not taken
	2: pc_next <= pcif.imm26 << 2;              //j, jal
	3: pc_next <= pcif.regval;                  //jr
	default: pc_next <= pc_cnt;	
      endcase // casez (pcif.pcsrc)
   end
   
endmodule
