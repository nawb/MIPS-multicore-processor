//File name: 	source/control_unit.sv
//Created: 	02/10/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	

`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"

import cpu_types_pkg::*;

module control_unit
  (
   control_unit_if.cu cuif
   );

   logic [5:0] op;
   logic [4:0] regs, regt, regd, shamt;
   logic [5:0] funct;
   logic [15:0] imm16;

   //INSTRUCTION PARSE AND DECODE
   assign op    = cuif.instr[31:26];
   assign regs  = cuif.instr[25:21];
   assign regt  = cuif.instr[20:16];
   assign regd  = cuif.instr[15:11];
   assign shamt = cuif.instr[10:6];
   assign funct = cuif.instr[5:0];
   assign imm16 = cuif.instr[15:0];

   //CONTROL SIGNALS
   assign cuif.regdst  = (op == LW || op == ORI) ? 
			 0 : 1 ;

   assign cuif.extop   = (op == ORI) ? 0 : 1; //0=zeroextend, 1=signextend
   
   assign cuif.alu_src = (op == RTYPE) ? 
			 0 : (op == BEQ) ? 0 : 1;
   
   assign cuif.pc_src  = (op == BEQ) ?
			 alu_flags[0] : 0; //alu_flags[0] = zero flag
   
   assign cuif.memwr   = (op == SW || op == BEQ) ?
			 0 : 1 ;
   
   assign cuif.memtoreg= (op == LW) ?
			 1 : 0;

   assign cuif.regwr   = (op == LW || op == ORI) ?
			 1 : 0;
      
   
   always_comb begin : ALU_OP
      if (op == RTYPE) begin
	 casez (funct)
	   ADD:  cuif.alu_op = ALU_ADD;
	   ADDU: cuif.alu_op = ALU_ADD;
	   SUB:  cuif.alu_op = ALU_SUB;
	   SUBU: cuif.alu_op = ALU_SUB;
	   AND:  cuif.alu_op = ALU_AND;
	   OR:   cuif.alu_op = ALU_OR;
	   XOR:  cuif.alu_op = ALU_XOR;
	   NOR:  cuif.alu_op = ALU_NOR;
	   SLL:  cuif.alu_op = ALU_SLL;
	   SRL:  cuif.alu_op = ALU_SRL;
	   SLT:  cuif.alu_op = ALU_SLT;
	   SLTU: cuif.alu_op = ALU_SLTU;	   
	   //JR:   cuif.alu_op =  
	 endcase // casez	 
      end // if (op == RTYPE)
      else if (op == ORI) begin
	 cuif.alu_op = ALU_OR;
      end
      else if (op == BEQ) begin
	 cuif.alu_op = ALU_SUB;
      end
      else begin
	 cuif.alu_op = ALU_ADD;	 
      end      
   end // block: ALU_OP
   

   
   
endmodule
