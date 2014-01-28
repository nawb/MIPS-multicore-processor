/*
 Eric Villasenor
 evillase@gmail.com

 register file fpga wrapper
 */

// interface
`include "alu_if.vh"

module alu_fpga 
  (
   input logic 	      CLOCK_50,
   input logic [3:0]  KEY,
   input logic [17:0] SW,
   output logic [6:0] HEX0;
   output logic [6:0] HEX1;
   output logic [6:0] HEX2;
   output logic [6:0] HEX3;
   );

   //internal registers
   logic [15:0]       operand;   
   
   // interface
   alu_if aluif();
   // rf
   alu ALU(CLOCK_50, KEY[2], aluif);
   
   assign aluif.op1 = SW[15:0];
   assign aluif.op2 = {31'b0,SW[17]};
   assign aluif.opcode = KEY[3:0];
   //assign HEX0[31:0] = aluif.res[31:0];

   always_comb
     begin
	operand = SW[16] ? '1 : '0; //SW16 fills all bits

	aluif.op1 =  SW[17] ? (operand | SW[15:0]) : '0;
	aluif.op2 = ~SW[17] ? (operand | SW[15:0]) : '0;
	
	unique casez (aluif.res[3:0])
	  'h0: HEX0 = 7'b1000000;
	  'h1: HEX0 = 7'b1111001;
	  'h2: HEX0 = 7'b0100100;
	  'h3: HEX0 = 7'b0110000;
	  'h4: HEX0 = 7'b0011001;
	  'h5: HEX0 = 7'b0010010;
	  'h6: HEX0 = 7'b0000010;
	  'h7: HEX0 = 7'b1111000;
	  'h8: HEX0 = 7'b0000000;
	  'h9: HEX0 = 7'b0010000;
	  'ha: HEX0 = 7'b0001000;
	  'hb: HEX0 = 7'b0000011;
	  'hc: HEX0 = 7'b0100111;
	  'hd: HEX0 = 7'b0100001;
	  'he: HEX0 = 7'b0000110;
	  'hf: HEX0 = 7'b0001110;
	endcase // unique casez (aluif.res[3:0])
	
	unique casez (aluif.res[7:4])
	  'h0: HEX1 = 7'b1000000;
	  'h1: HEX1 = 7'b1111001;
	  'h2: HEX1 = 7'b0100100;
	  'h3: HEX1 = 7'b0110000;
	  'h4: HEX1 = 7'b0011001;
	  'h5: HEX1 = 7'b0010010;
	  'h6: HEX1 = 7'b0000010;
	  'h7: HEX1 = 7'b1111000;
	  'h8: HEX1 = 7'b0000000;
	  'h9: HEX1 = 7'b0010000;
	  'ha: HEX1 = 7'b0001000;
	  'hb: HEX1 = 7'b0000011;
	  'hc: HEX1 = 7'b0100111;
	  'hd: HEX1 = 7'b0100001;
	  'he: HEX1 = 7'b0000110;
	  'hf: HEX1 = 7'b0001110;
	endcase // unique casez (aluif.res[7:4])
	
	unique casez (aluif.res[11:8])
	  'h0: HEX2 = 7'b1000000;
	  'h1: HEX2 = 7'b1111001;
	  'h2: HEX2 = 7'b0100100;
	  'h3: HEX2 = 7'b0110000;
	  'h4: HEX2 = 7'b0011001;
	  'h5: HEX2 = 7'b0010010;
	  'h6: HEX2 = 7'b0000010;
	  'h7: HEX2 = 7'b1111000;
	  'h8: HEX2 = 7'b0000000;
	  'h9: HEX2 = 7'b0010000;
	  'ha: HEX2 = 7'b0001000;
	  'hb: HEX2 = 7'b0000011;
	  'hc: HEX2 = 7'b0100111;
	  'hd: HEX2 = 7'b0100001;
	  'he: HEX2 = 7'b0000110;
	  'hf: HEX2 = 7'b0001110;
	endcase // unique casez (aluif.res[11:8])
	
	unique casez (aluif.res[15:12])
	  'h0: HEX3 = 7'b1000000;
	  'h1: HEX3 = 7'b1111001;
	  'h2: HEX3 = 7'b0100100;
	  'h3: HEX3 = 7'b0110000;
	  'h4: HEX3 = 7'b0011001;
	  'h5: HEX3 = 7'b0010010;
	  'h6: HEX3 = 7'b0000010;
	  'h7: HEX3 = 7'b1111000;
	  'h8: HEX3 = 7'b0000000;
	  'h9: HEX3 = 7'b0010000;
	  'ha: HEX3 = 7'b0001000;
	  'hb: HEX3 = 7'b0000011;
	  'hc: HEX3 = 7'b0100111;
	  'hd: HEX3 = 7'b0100001;
	  'he: HEX3 = 7'b0000110;
	  'hf: HEX3 = 7'b0001110;
	endcase
     end

   
endmodule
