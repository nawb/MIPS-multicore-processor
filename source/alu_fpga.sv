/*
  Eric Villasenor
  evillase@gmail.com

  register file fpga wrapper
*/

// interface
`include "alu_if.vh"

module alu_fpga (
  input logic CLOCK_50,
  input logic [3:0] KEY,
  input logic [17:0] SW,
  output logic [17:0] LEDR
);

  // interface
   alu_if aluif();
  // rf
  alu ALU(CLOCK_50, KEY[2], aluif);

   assign aluif.op1 = SW[15:0];
   assign aluif.op2 = {31'b0,SW[17]};
   assign aluif.opcode = KEY[3:0];
   assign LEDR[31:0] = aluif.res[31:0];
   
endmodule
