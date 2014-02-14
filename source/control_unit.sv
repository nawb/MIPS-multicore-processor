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

   opcode_t op;
   funct_t funct;


   //INSTRUCTION PARSE AND DECODE
   assign op         = opcode_t'(cuif.instr[31:26]);
   assign cuif.rs    = cuif.instr[25:21];
   assign cuif.rt    = cuif.instr[20:16];
   assign cuif.rd    = cuif.instr[15:11];
   assign cuif.shamt = cuif.instr[10:6];
   assign funct      = funct_t'(cuif.instr[5:0]);
   assign cuif.imm16 = cuif.instr[15:0];
   assign cuif.halt  = ~(op == HALT) ? 0 : 1;
   
   //CONTROL SIGNALS
   assign cuif.regdst  = (op == LW || ~(op == RTYPE)) ? 
			 1 : 0 ;

   assign cuif.extop   = (op == ORI || op == ANDI || op == XORI || op == LUI) ?
			 0 : 1; //0=zeroextend, 1=signextend
   //signextend on: ADDIU, LW, SLTI, SLTIU, SW, LL, SC
   
   //assign cuif.luimux  = (op == LUI) ? 1 : 0; // Basically, ALUsrc[1] = LUI ? {imm16, 16'b0} : extender
   
   assign cuif.alu_src = (op == RTYPE) ? 0 :
			 (op == BEQ || op == BNE || op == ORI || op == ANDI || op == XORI || op == ADDIU || op == SLTI || op == SLTIU || op == SW || op == SC || op == LW) ? 1 : //all the things requiring a signexted/zeroextend
			 (op == LUI) ? 2 : 0
			 ;
   
   assign cuif.pc_src  = (op == BEQ) ? 
			 cuif.alu_flags[0] :  //alu_flags[0] = zero flag
			 (op == BNE) ? ~cuif.alu_flags[0] : 0;
   
   //   assign cuif.memwr   = (op == SW || op == SB || op == SH || op == BEQ || op == BNE) ?
   //idk what I'm doing here^
   assign cuif.memwr   = (op == SW) ?
			 1 : 0 ;
   
   assign cuif.memtoreg= (op == LW) ? //NOT ON LUI...LUI is more like ORI
			 1 : 0;

   assign cuif.regwr   = //(op == RTYPE || op == LW || op == ORI || op == ANDI || op == XORI || op == LUI) ?
			 ~(op == SW || op == BEQ || op == BNE || op == SC || op == J) ?
			 1 : 0;

   assign cuif.icuREN  = ~(op == SW || op == LW) ? 1 : 0;
   assign cuif.dcuREN  = cuif.memtoreg;
   assign cuif.dcuWEN  = cuif.memwr;
   
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
	   default: cuif.alu_op = ALU_ADD;	   
	 endcase // casez	 
      end // if (op == RTYPE)
      else begin
	 casez (op)
	   ORI: begin
	      cuif.alu_op = ALU_OR;
	   end
	   ANDI: begin
	      cuif.alu_op = ALU_AND;
	   end
	   XORI: begin
	      cuif.alu_op = ALU_XOR;
	   end
	   (BEQ | BNE): begin
	      cuif.alu_op = ALU_SUB;
	   end
	   default: cuif.alu_op = ALU_ADD; //(if LW/SW)
	 endcase // casez (op)
      end // else: !if(op == RTYPE)
      
   end // block: ALU_OP
   
endmodule
