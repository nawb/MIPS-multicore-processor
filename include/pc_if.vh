/*
 //Created: 	02/11/2014
 //Author:	Nabeel Zaim (mg232)
 //Lab Section:	437-03
 //Description: 	program counter interface
 */
`ifndef PC_IF_VH
 `define PC_IF_VH

 `include "cpu_types_pkg.vh"

interface pc_if;
   import cpu_types_pkg::*;

   logic [ADDR_W-1:0] imm26;
   word_t  immext; //the extended address to go to
   logic 	      branchmux; //pc_src from cu
   logic 	      jumpmux;
   word_t  imemaddr;
   logic 	      pcEN, halt;
         
   // register file ports
   modport pc 
     (
      input  branchmux, jumpmux, immext, imm26, pcEN, halt,
      output imemaddr
      );

endinterface

`endif //PC_IF_VH
