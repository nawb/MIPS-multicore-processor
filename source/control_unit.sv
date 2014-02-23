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
   
   always_comb begin : HALT_DETECT //had to convert this assign into casez to account for case of zs
      casez(op)
	HALT: cuif.halt = 1;
	default: cuif.halt = 0;      
      endcase
   end   

   assign cuif.regEN = 1'b1;
   assign cuif.flush = 1'b0;   
   
   //CONTROL SIGNALS
   always_comb begin : REGDST
      casez (op)
	RTYPE: cuif.regdst = 0;
	LW, LUI, SLTI, SLTIU: cuif.regdst = 1;
	JAL: cuif.regdst = 2;
	default: cuif.regdst = 1;
      endcase
   end

   assign cuif.extop   = (op == ORI || op == ANDI || op == XORI || op == LUI) ?
			 0 : 1; //0=zeroextend, 1=signextend
   //signextend on: ADDIU, LW, SLTI, SLTIU, SW, LL, SC
   
   always_comb begin : ALU_SRC
      casez (op)
	RTYPE: cuif.alu_src = 0;
	// all the things requiring a signexted/zeroextend:
	ORI, ANDI, XORI, ADDIU, SLTI, SLTIU, SW, LW: cuif.alu_src = 1; 
	LUI: cuif.alu_src = 2;
	default: cuif.alu_src = 0;
      endcase
   end

   always_comb begin : PC_SRC
      casez (op)
	J, JAL:  cuif.pc_src = 2;
	BEQ:     cuif.pc_src = cuif.alu_flags[0]; //alu_flags[0]= zero flag
	BNE:     cuif.pc_src = ~cuif.alu_flags[0];
	RTYPE:   cuif.pc_src = (funct == JR) ? 3 : 0;
	default: cuif.pc_src = 0;
      endcase
   end

   assign cuif.memwr   = (op == SW) ?
			 1 : 0 ;

   always_comb begin : MEMTOREG
      casez (op)
	JAL: cuif.memtoreg = 2;
	LW:  cuif.memtoreg = 1; //DON'T ASSERT ON LUI...LUI is more like ORI
	default: cuif.memtoreg = 0;	
      endcase
   end

   assign cuif.regwr   = (op == RTYPE || op == LW || op == ORI || op == ANDI || op == XORI || op == LUI || op == JAL || op == ADDIU || op == SLTI || op == SLTIU) ?
			 1 : 0;

   assign cuif.icuREN  = ~(op == SW || op == LW) ? 1 : 0;
   always_comb begin : DCUREN
      casez (cuif.memtoreg)
	1: cuif.dcuREN = 1;
	default: cuif.dcuREN = 0;
      endcase
   end
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
	   JR:   cuif.alu_op = ALU_ADD;	   
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
	   BEQ, BNE: begin
	      cuif.alu_op = ALU_SUB;
	   end
	   SLTI: begin
	      cuif.alu_op = ALU_SLT;	      
	   end
	   SLTIU: begin
	      cuif.alu_op = ALU_SLTU;	      
	   end
	   default: cuif.alu_op = ALU_ADD; //(if LW/SW)
	 endcase // casez (op)
      end // else: !if(op == RTYPE)
      
   end // block: ALU_OP
   
endmodule
