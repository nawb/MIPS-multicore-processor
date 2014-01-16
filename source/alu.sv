//File name: 	source/alu.sv
//Created: 	01/16/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	

import cpu_types_pkg::*;

parameter [3:0] ADD  = 4'b0000;
parameter [3:0] SUB  = 4'b0001;
parameter [3:0] AND  = 4'b0010;
parameter [3:0] OR   = 4'b0011;
parameter [3:0] XOR  = 4'b0100;
parameter [3:0] XNOR = 4'b0101;
parameter [3:0] LSL  = 4'b0110;
parameter [3:0] LSR  = 4'b0111;

module alu
  (
   input logic 	     nRST,
   input 	     word_t op1,
   input 	     word_t op2,
   input logic [3:0] opcode,
   output 	     word_t res,
   output logic      flag_n,
   output logic      flag_v,
   output logic      flag_z
   );
   

   always_comb begin
      if (!nRST) begin
	 res = '0;
      end
      else begin
	 casez(opcode)
	   ADD: begin
	      res = op1 + op2;
	   end
	   SUB: begin
	      res = op1 - op2;
	   end
	   AND: begin
	      res = op1 & op2;
	   end
	   OR: begin
	      res = op1 | op2;
	   end
	   XOR: begin
	      res = op1 ^ op2;
	   end
	 endcase
      end
   end
endmodule
