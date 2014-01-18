//File name: 	source/alu.sv
//Created: 	01/16/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	

`include "alu_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module alu
  (
   input logic 	     nRST,
   alu_if.alum aluif
   );
   
   always_comb begin
      if (!nRST) begin
	 aluif.res = '0;
      end
      else begin
	 casez(aluif.opcode)
	   ALU_ADD: begin
	      aluif.res = aluif.op1 + aluif.op2;
	   end
	   ALU_SUB: begin
	      aluif.res = aluif.op1 - aluif.op2;
	   end
	   ALU_AND: begin
	      aluif.res = aluif.op1 & aluif.op2;
	   end
	   ALU_OR: begin
	      aluif.res = aluif.op1 | aluif.op2;
	   end
	   ALU_XOR: begin
	      aluif.res = aluif.op1 ^ aluif.op2;
	   end
	   ALU_NOR: begin
	      aluif.res = aluif.op1 ^ aluif.op2;	      
	   end
	   ALU_SLT: begin
	   end
	   ALU_SLTU: begin
	   end
	   ALU_SLL: begin
	      aluif.res = aluif.op1 << 1;
	   end
	   ALU_SRL: begin
	      aluif.res = aluif.op1 >> 1;	      
	   end
	 endcase
      end
   end
endmodule
