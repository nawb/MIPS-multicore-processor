//File name: 	source/memory_control.sv
//Created: 	02/05/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

`include "cache_control_if.vh"
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
   localparam CPUID = 0;
   
   typedef enum {IDLE, CORE0, CORE1} state_t;
   
   state_t state, next_state;
   
   always_ff @(posedge CLK, negedge nRST) begin
      if(!nRST) begin
	 state <= IDLE;
      end else begin 
	 state <= next_state;
      end
   end
   
   always_comb begin
      casez(state)
	 IDLE:
	    if(ccif.cctrans[0]) begin
	       next_state <= CORE0;
	    end else 
	    if(ccif.cctrans[1]) begin
	       next_state <= CORE1;
	    end else begin
	       next_state <= IDLE;
	    end
	 CORE0:
	    if(ccif.cctrans[0])
	       next_state <= CORE0;
	    else
	       next_state <= IDLE;
	 CORE1:
	    if(ccif.cctrans[1])
	       next_state <= CORE1;
	    else
	       next_state <= IDLE;
      endcase
   end

   //priority mux,
   //dWEN|dREN has highest priority
   //iREN has second priority
   //so 1 x = d
   //   0 1 = i
   //   0 0 = 0

   //Also, assert a wait high during RAM's BUSY state...until it reaches ACCESS state,
   //that's when you want to pull it back low to let cache layer know that it has been done, and it can assert ihit/dhit
   always_comb begin
      casez(state)
	 IDLE: begin
	    ccif.ramstore = '0;
	    ccif.ramaddr = ccif.iREN[0] ? ccif.iaddr[0] : ccif.iaddr[1];
	    if (ccif.iREN[0]) begin
	       ccif.iwait[0] = (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.dwait[0] = 1'b1;
	       ccif.iwait[1] = 1'b1;
	       ccif.dwait[1] = 1'b1;
	       ccif.ramWEN = 1'b0;
	       ccif.ramREN = 1'b1;
	    end
	    else if (ccif.iREN[1]) begin
	       ccif.iwait[1] = (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.dwait[1] = 1'b0;
	       ccif.iwait[0] = 1'b1;
	       ccif.dwait[0] = 1'b1;
	       ccif.ramWEN = 1'b0;
	       ccif.ramREN = 1'b1;
	    end
	    else begin
	       ccif.dwait[0] = 1'b0;
	       ccif.iwait[0] = 1'b0;
	       ccif.dwait[1] = 1'b0;
	       ccif.iwait[1] = 1'b0;
	       ccif.ramWEN = 1'b0;
	       ccif.ramREN = 1'b0;
	    end // else: !if(ccif.iREN)
	 end
	 CORE0: begin
	    ccif.ramstore = ccif.dstore[0];
	    ccif.ramaddr = ccif.daddr[0];
	    if (ccif.ccwrite[0]) begin
	       //core is writing
	       ccif.iwait[0] = 1'b1;
	       ccif.dwait[0] = (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.iwait[1] = 1'b1;
	       ccif.dwait[1] = 1'b1;
	       ccif.ramWEN = 1'b1;
	       ccif.ramREN = 1'b0;
	    end else begin
	       //core is reading
	       ccif.iwait[0] = 1'b1;
	       ccif.dwait[0] = (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.iwait[1] = 1'b1;
	       ccif.dwait[1] = 1'b1;
	       ccif.ramWEN = 1'b0;
	       ccif.ramREN = 1'b1;
	    end
	 end
	 CORE1: begin
	    ccif.ramstore = ccif.dstore[1];
	    ccif.ramaddr = ccif.daddr[1];
	    if (ccif.ccwrite[0]) begin
	       //core is writing
	       ccif.iwait[1] = 1'b1;
	       ccif.dwait[1] = (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.iwait[0] = 1'b1;
	       ccif.dwait[0] = 1'b1;
	       ccif.ramWEN = 1'b1;
	       ccif.ramREN = 1'b0;
	    end else begin
	       //core is reading
	       ccif.iwait[1] = 1'b1;
	       ccif.dwait[1] = (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.iwait[0] = 1'b1;
	       ccif.dwait[0] = 1'b1;
	       ccif.ramWEN = 1'b0;
	       ccif.ramREN = 1'b1;
	    end
	 end
      endcase
   end // always_comb

   assign ccif.dload[0] = ccif.ramload;
   assign ccif.iload[0] = ccif.ramload;
   assign ccif.dload[1] = ccif.ramload;
   assign ccif.iload[1] = ccif.ramload;

endmodule
