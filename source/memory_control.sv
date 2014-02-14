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

   //Also, assert a wait high during RAM's BUSY state...until it reaches ACCESS state,
   //that's when you want to pull it back low to let cache layer know that it has been done, and it can assert ihit/dhit
   always_comb begin
      if (ccif.dWEN) begin
	 ccif.dwait = (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	 ccif.iwait = 1'b0;
	 ccif.ramWEN = 1'b1;
	 ccif.ramREN = 1'b0;
      end
      else if (ccif.dREN) begin
	 ccif.dwait = (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	 ccif.iwait = 1'b0;
	 ccif.ramWEN = 1'b0;
	 ccif.ramREN = 1'b1;
      end
      else if (ccif.iREN) begin
	 ccif.iwait = (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	 ccif.dwait = 1'b0;
	 ccif.ramWEN = 1'b0;
	 ccif.ramREN = 1'b1;
      end
      else begin
	 ccif.dwait = 1'b0;
	 ccif.iwait = 1'b0;
	 ccif.ramWEN = 1'b0;
	 ccif.ramREN = 1'b0;
      end // else: !if(ccif.iREN)
   end // always_comb

   assign ccif.ramaddr = (ccif.dWEN | ccif.dREN) ? ccif.daddr : ccif.iaddr;
   assign ccif.dload = ccif.ramload;
   assign ccif.iload = ccif.ramload;
   assign ccif.ramstore = ccif.dstore;
   
   
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
