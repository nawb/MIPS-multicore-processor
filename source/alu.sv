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
   input logic nRST,
   alu_if.alum aluif
   );

   logic       carry_bit;   
   
   always_comb begin
      if (!nRST) begin
	 aluif.res = '0;
	 aluif.flag_v = 'x;
	 aluif.flag_n = 'x;
	 aluif.flag_z = 'x;
      end
      else begin
	 casez(aluif.opcode)
	   ALU_ADD: begin
	      {aluif.flag_v, aluif.res} = aluif.op1 + aluif.op2;
	   end
	   ALU_SUB: begin
	      {aluif.flag_v, aluif.res} = aluif.op1 - aluif.op2;
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
	      aluif.res = aluif.op1 ~^ aluif.op2;
	   end
	   ALU_SLT: begin
	      aluif.res = aluif.op1 < aluif.op2 ? 32'b0 : 32'b01;	      
	   end
	   ALU_SLTU: begin
	      aluif.res = $unsigned(aluif.op1) < $unsigned(aluif.op2) ?
			  32'b0 : 32'b01;
	   end
	   ALU_SLL: begin
	      aluif.res = aluif.op1 << 1;
	   end
	   ALU_SRL: begin
	      aluif.res = aluif.op1 >> 1;	      
	   end
	   default: begin
	      aluif.res = 32'b0;	      
	   end
	 endcase // casez (aluif.opcode)
	 
	 aluif.flag_z = aluif.res ? 0 : 1; //Zero flag
	 aluif.flag_n = aluif.res[$size(aluif.res) - 1] ? 1 : 0; //Neg flag
      end
   end
endmodule
