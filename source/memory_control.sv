/*
 Eric Villasenor
 evillase@gmail.com

 Nabeel Zaim
 mg232
 
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
   cache_control_if.cc ccif
   );
   // type import
   import cpu_types_pkg::*;

   // number of cpus for cc
   parameter CPUS = 2;

   //priority mux,
   //dWEN|dREN has highest priority
   //iREN has second priority
   //so 1 x = d
   //   0 1 = i
   //   0 0 = 0
   always_comb begin
      if (ccif.dWEN) begin
	 ccif.dwait = 1'b1;
	 ccif.iwait = 1'b0;
	 ccif.ramaddr = ccif.daddr;
	 ccif.dload = ccif.ramload;
	 ccif.ramWEN = 1'b1;
      end
      else if (ccif.dREN) begin
	 ccif.dwait = 1'b1;
	 ccif.iwait = 1'b0;
	 ccif.ramaddr = ccif.daddr;
	 ccif.dload = ccif.ramload;
	 ccif.ramWEN = 1'b0;
	 ccif.ramREN = 1'b1;
      end
      else if (ccif.iREN) begin
	 ccif.iwait = 1'b1;
	 ccif.dwait = 1'b0;
	 ccif.ramaddr = ccif.iaddr;
	 ccif.iload = ccif.ramload;
	 ccif.ramREN = 1'b1;
      end
      else begin
	 ccif.dwait = 1'b0;
	 ccif.iwait = 1'b0;
	 ccif.ramREN = 1'b0;
	 ccif.ramWEN = 1'b0;
      end      
   end // always_comb

   /*
    always_comb @(ccif.dWEN, ccif.dREN, ccif.iREN) begin
    if (ccif.dWEN) begin
    ccif.ramaddr = ccif.daddr;
      end
    else if (ccif.dREN) begin
    ccif.ramaddr = ccif.daddr;
    ccif.dload = ccif.ramload;
      end
    else begin
    ccif.ramaddr = ccif.iaddr;
    ccif.iload = ccif.ramload;
      end
   end*/
   
endmodule
