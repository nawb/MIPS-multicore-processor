/*
 //Created: 	02/10/2014
 //Author:	Nabeel Zaim (mg232)
 //Lab Section:	437-03
 //Description: control unit interface 
 */

`ifndef CONTROL_UNIT_IF_VH
 `define CONTROL_UNIT_IF_VH

 `include "cpu_types_pkg.vh"

package control_unit_pkg;
   
endpackage // control_unit_pkg
   
interface control_unit_if;   
   import cpu_types_pkg::*;

   //IF STAGE
   logic [31:0] align; //for aligning my indentations in emacs. not used.
   word_t       instr;
   logic [3:0] 	alu_flags;
   //ID STAGE
   word_t       rs, rd, rt;
   logic 	regdst;
   logic 	extop;
   //EX STAGE
   aluop_t 	alu_op;
   logic 	alu_src, pc_src;
   //MEM+WB STAGE
   logic 	memwr, memtoreg, regwr;
   
         
   // regular module ports
   modport cu
     (
      input instr, alu_flags,
      output rs, rd, rt, regdst, extop, alu_op, alu_src, pc_src,
      memwr, memtoreg, regwr
      );
   
endinterface

`endif //CONTROL_UNIT_IF_VH
