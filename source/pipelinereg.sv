//File name: 	source/pipelinereg.sv
//Created: 	02/19/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	Pipeline register (latch) between stages

`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module pipelinereg
  #(parameter RSIZE = 64)  
   //default value of 64, in case not overridden upon instantiation
  (
   input logic CLK, nRST, EN, flush,
   input       [RSIZE-1:0] in,
   output      [RSIZE-1:0] out
   );

   logic [RSIZE-1:0] 	   outreg;
   assign out = outreg;
   
   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST | flush)
	outreg <= '0;
      else if (EN)
	outreg <= in;
      else
	outreg <= outreg;
   end
   
endmodule
