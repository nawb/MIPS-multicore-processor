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

   word_t pc_cnt, pc_cnt_t;   

   assign pcif.imemaddr = pc_cnt;      
   
   always_ff @ (posedge CLK, negedge nRST) begin
      pc_cnt <= pc_cnt;
      if (!nRST) begin
	 pc_cnt <= PC_INIT;
      end
      else if (pcif.pcEN) begin
	 pc_cnt <= pc_cnt_t;	 
      end
   end

   //this is because multicore design would not fit on fpga
   //so had to shrink sensitivity list and break pc_cnt out into its own block
   always_comb begin
      casez (pcif.pc_src)
	0: pc_cnt_t <= pc_cnt + 4;                     //normal
	1: pc_cnt_t <= pcif.branchmux ? pcif.imm16 : //beq/bne taken
		     pc_cnt + 4;                   //beq/bne not taken
	2: pc_cnt_t <= pcif.imm26 << 2;                //j, jal
	3: pc_cnt_t <= pcif.regval;                    //jr	   
      endcase // casez (pcif.pcsrc)      
   end
   
endmodule

/*
	 if (pcif.jumpmux) begin
	    pc_cnt <= pcif.imm26 << 2;	   
	 end
	 else begin
	    if (pcif.branchmux)
	      pc_cnt <= pc_cnt + 4 + (pcif.immext << 2);
	    else
	      pc_cnt <= pc_cnt + 4;
	 end*/
