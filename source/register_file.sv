

`include "register_file_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module register_file 
  (
   input logic CLK, nRST,
   register_file_if.rf rfif
   );

   word_t [31:0] rfile;

   //READ ON FALLING EDGE
   always_ff @(negedge CLK) begin
      //read from reg0 must always return 0.
      rfif.rdat1 <= rfif.rsel1 ? rfile[rfif.rsel1] : 0;
      rfif.rdat2 <= rfif.rsel2 ? rfile[rfif.rsel2] : 0;
   end

   //WRITE ON RISING EDGE
   always_ff @(posedge CLK, negedge nRST) begin
      if (!nRST)
	rfile <= '0;
      else if (rfif.WEN && rfif.wsel) //wsel should not be 0
	rfile[rfif.wsel] <= rfif.wdat;
   end // always_ff @
   
endmodule // register_file
