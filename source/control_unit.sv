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
   logic [IMM_W-1:0] imm16;

   //INSTRUCTION PARSE AND DECODE
   assign op         = opcode_t'(cuif.instr[31:26]);
   assign cuif.rs    = cuif.instr[25:21];
   assign cuif.rt    = cuif.instr[20:16];
   assign cuif.rd    = cuif.instr[15:11];
   assign cuif.shamt = cuif.instr[10:6];
   assign funct      = funct_t'(cuif.instr[5:0]);
   assign imm16      = cuif.instr[15:0];

   //CONTROL SIGNALS
   assign cuif.regdst  = (op == LW || op == ORI || op == ANDI || op == XORI) ? 
			 0 : 1 ;

   assign cuif.extop   = (op == ORI || op == ANDI || op == XORI) ?
			 0 : 1; //0=zeroextend, 1=signextend
   
   assign cuif.alu_src = (op == RTYPE) ? 
			 0 : (op == BEQ || op == BNE || op == ORI || op == ANDI || op == XORI) ? 1 : 0;
   
   assign cuif.pc_src  = (op == BEQ) ? 
			 cuif.alu_flags[0] :  //alu_flags[0] = zero flag
			 (op == BNE) ? ~cuif.alu_flags[0] : 0;
   
//   assign cuif.memwr   = (op == SW || op == SB || op == SH || op == BEQ || op == BNE) ?
   //idk what I'm doing here^
   assign cuif.memwr   = (op == SW || op == SB || op == SH) ?
			 1 : 0 ;
   
   assign cuif.memtoreg= (op == LW || op == LUI || op == LBU || op == LHU) ?
			 1 : 0;

   assign cuif.regwr   = (op == LW || op == ORI || op == ANDI || op == XORI || op == LUI) ?
			 1 : 0;
      
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
	 endcase // casez	 
      end // if (op == RTYPE)
      else if (op == ORI) begin
	 cuif.alu_op = ALU_OR;
      end
      else if (op == ANDI) begin
	 cuif.alu_op = ALU_AND;
      end
      else if (op == XORI) begin
	 cuif.alu_op = ALU_XOR;
      end
      else if (op == BEQ || op == BNE) begin
	 cuif.alu_op = ALU_SUB;
      end
      else begin //(if LW/SW)
	 cuif.alu_op = ALU_ADD;	 
      end      
   end // block: ALU_OP
   

   
   
endmodule
