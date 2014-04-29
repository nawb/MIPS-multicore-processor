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
   // parameter PC_INIT = '0;   
   
   word_t pc_cnt, pc_cnt_next;   

   assign pcif.imemaddr = pc_cnt;      
   
   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 pc_cnt <= PC_INIT;
      end else if (pcif.pcEN) begin
      	 pc_cnt <= pc_cnt_next;
      end
   end

   always_comb begin
      pc_cnt_next <= pc_cnt;      
      casez (pcif.pc_src)
	0: pc_cnt_next <= pc_cnt + 4;                     //normal
	1: pc_cnt_next <= pcif.branchmux ? pcif.imm16 :   //beq/bne taken
			  pc_cnt + 4;                     //beq/bne not taken
	2: pc_cnt_next <= pcif.imm26 << 2;                //j, jal
	3: pc_cnt_next <= pcif.regval;                    //jr
	default: pc_cnt_next <= pc_cnt;	
      endcase // casez (pcif.pcsrc)
   end

endmodule
