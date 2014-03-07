//File name: 	include/pipeline_regs_if.sv
//Created: 	02/21/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	Interface file containing modports for pipeline latches

`ifndef PIPELINE_REGS_IF_VH
 `define PIPELINE_REGS_IF_VH

 `include "cpu_types_pkg.vh"

package pipeline_regs_pkg;
   import cpu_types_pkg::*;

   typedef struct packed {
      opcode_t opcode;
      word_t instr;
      word_t pc_plus_4;
      } FD_t;

   typedef struct packed {
      opcode_t opcode;
      word_t rdat1;
      word_t rdat2;
      word_t imm16;
      logic [25:0] imm26;
      //control signals:
      //EX:
      logic [1:0] alu_src;
      aluop_t alu_op;
      regbits_t shamt;
      //unused:
      //logic branchmux, branching, jumping;
      //MEM:
      regbits_t rd, rs, rt;
      logic [1:0] regdst;
      logic memwr, dcuWEN, dcuREN;
      word_t pc_plus_4;
      //WB:
      logic [1:0] memtoreg, pc_src;
      logic 	  regwr, icuREN;
      logic 	  halt;
      logic [1:0] beq;
      } DE_t;

   typedef struct packed {
      opcode_t opcode;
      word_t alu_res;
      word_t dmemstore;
      //unused:
      //logic zeroflag;

      //control signals:
      //MEM:
      regbits_t rd, rt;
      logic [1:0] regdst;
      logic memwr, dcuWEN, dcuREN;
      word_t pc_plus_4;
      //WB:
      logic [1:0] memtoreg, pc_src;
      logic regwr, icuREN;
      logic halt;
      } EM_t;

   typedef struct packed {
      opcode_t opcode;
      word_t alu_res;
      word_t dmemload;
      regbits_t wsel;
      //control signals:
      //WB:
      logic [1:0] memtoreg, pc_src;
      logic dcuREN, icuREN;
      word_t pc_plus_4;
      logic halt;
      } MW_t;

endpackage

interface pipeline_regs_if;
   import cpu_types_pkg::*;
   import pipeline_regs_pkg::*;

   //STAGES: F (IF), D (ID), E (EX), M (MEM), W (WB)
   FD_t   FD_in, FD_out;
   DE_t   DE_in, DE_out;
   EM_t   EM_in, EM_out;
   MW_t   MW_in, MW_out;

endinterface

`endif //PIPELINE_REGS_IF_VH
