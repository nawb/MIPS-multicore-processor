/*
 Eric Villasenor
 evillase@gmail.com

 this block is the coherence protocol
 and arbitration for ram
 */

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control 
  (
   input CLK, nRST,
   cache_control_if. cc ccif
   );
   // type import
   import cpu_types_pkg::*;

   // number of cpus for cc
   parameter CPUS = 2;
   
   always_comb begin
      ccif.dwait = 1'b0;
      ccif.iwait = 1'b0;
      if (ccif.dWEN|ccif.dREN) begin
	 ccif.dwait = 1'b1;
      end
      else if (~(ccif.dWEN|ccif.dREN) & ccif.iREN) begin
	 ccif.iwait = 1'b1;
      end
   end

endmodule
