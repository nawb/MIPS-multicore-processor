/*
 Nabeel Zaim
 ALU file interface
 */
`ifndef ALU_IF_VH
 `define ALU_IF_VH

 `include "cpu_types_pkg.vh"

package alu_pkg;
   
   parameter [3:0] ADD  = 4'b0000;
   parameter [3:0] SUB  = 4'b0001;
   parameter [3:0] AND  = 4'b0010;
   parameter [3:0] OR   = 4'b0011;
   parameter [3:0] XOR  = 4'b0100;
   parameter [3:0] XNOR = 4'b0101;
   parameter [3:0] LSL  = 4'b0110;
   parameter [3:0] LSR  = 4'b0111;
   parameter [3:0] HLT  = 4'b1000;

endpackage


interface alu_if;
   import cpu_types_pkg::*;
/*
   const logic [3:0] ADD  = 4'b0000;
   const logic [3:0] SUB  = 4'b0001;
   const logic [3:0] AND  = 4'b0010;
   const logic [3:0] OR   = 4'b0011;
   const logic [3:0] XOR  = 4'b0100;
   const logic [3:0] XNOR = 4'b0101;
   const logic [3:0] LSL  = 4'b0110;
   const logic [3:0] LSR  = 4'b0111;
   const logic [3:0] HLT  = 4'b1000;
*/
   
   logic [3:0] opcode;
   word_t      op1, op2, res;
   logic       flag_n, flag_v, flag_z;   
   
   // regular module ports
   modport alum
     (
      input  op1, op2, opcode,
      output res, flag_n, flag_v, flag_z
      );
   	          
   // testbench module ports
   modport tb 
     (
      input  res, flag_n, flag_v, flag_z,
      output op1, op2, opcode
      );   
endinterface

`endif //ALU_VH
