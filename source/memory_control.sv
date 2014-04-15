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
   cache_control_if ccif
   );
   // type import
   import cpu_types_pkg::*;

   // number of cpus for cc
   parameter CPUS = 2;
   localparam CPUID = 0;

   typedef enum {IDLE, SNOOP0, SNOOP1, WB0, WB1, MEM0, MEM1} state_t;

   state_t state, next_state;

   always_ff @(posedge CLK, negedge nRST) begin
      if(!nRST) begin
	 state <= IDLE;
      end else begin
	 state <= next_state;
      end
   end

   //next state logic
   always_comb begin
      casez(state)
	 IDLE: begin
	    if(ccif.cctrans[0]) begin
	       next_state <= SNOOP0;
	    end else
	    if(ccif.cctrans[1]) begin
	       next_state <= SNOOP1;
	    end else begin
	       next_state <= IDLE;
	    end
	 end
	 SNOOP0: begin
	    if (ccif.ccwrite[1]) begin
	       next_state <= WB1;
	    end else if (ccif.cctrans[1]) begin
	       next_state <= IDLE;
	    end else begin
	       next_state <= MEM0;
	    end
	 end
	 SNOOP1: begin
	    if (ccif.ccwrite[0]) begin
	       next_state <= WB1;
	    end else if (ccif.cctrans[0]) begin
	       next_state <= IDLE;
	    end else begin
	       next_state <= MEM0;
	    end
	 end
	 WB0: begin
	    if (ccif.ccwrite[0]) begin
	       next_state <= WB0;
	    end else begin
	       next_state <= MEM1;
	    end
	 end
	 WB1: begin
	    if (ccif.ccwrite[1]) begin
	       next_state <= WB1;
	    end else begin
	       next_state <= MEM0;
	    end
	 end
	 MEM0: begin
	    if(ccif.cctrans[0])
	       next_state <= MEM0;
	    else
	       next_state <= IDLE;
	 end
	 MEM1: begin
	    if(ccif.cctrans[1])
	       next_state <= MEM1;
	    else
	       next_state <= IDLE;
	 end
      endcase
   end

   //output logic
   always_comb begin
      ccif.ccsnoopaddr[0] <= '0;
      ccif.ccsnoopaddr[1] <= '0;
      ccif.ccinv[0] <= 0;
      ccif.ccinv[1] <= 0;
      ccif.ccwait[0] <= 0;
      ccif.ccwait[1] <= 0;
      casez(state)
	 IDLE: begin
	    ccif.ramstore <= '0;
	    ccif.ramaddr <= ccif.iREN[0] ? ccif.iaddr[0] : ccif.iaddr[1];
	    if (ccif.iREN[0]) begin
	       ccif.iwait[0] <= (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.dwait[0] <= 1'b1;
	       ccif.iwait[1] <= 1'b1;
	       ccif.dwait[1] <= 1'b1;
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b1;
	    end
	    else if (ccif.iREN[1]) begin
	       ccif.iwait[1] <= (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.dwait[1] <= 1'b0;
	       ccif.iwait[0] <= 1'b1;
	       ccif.dwait[0] <= 1'b1;
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b1;
	    end
	    else begin
	       ccif.dwait[0] <= 1'b0;
	       ccif.iwait[0] = 1'b0;
	       ccif.dwait[1]<= 1'b0;
	       ccif.iwait[1] <= 1'b0;
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b0;
	    end // else: !if(ccif.iREN)
	 end
	 SNOOP0: begin
	    ccif.ramstore <= ccif.dstore[0];
	    ccif.ramaddr <= ccif.daddr[0];
	    ccif.ccsnoopaddr[1] <= ccif.daddr[0];
	    if (ccif.ccwrite[0]) begin
	       //core is writing
	       ccif.iwait[0] <= 1'b1;
	       ccif.dwait[0] <= ccif.cctrans[1]; //use cctrans as snoop hit flag
	       ccif.iwait[1] <= 1'b1;
	       ccif.dwait[1] <= 1'b1;
	       ccif.ccwait[0] <= 1'b1;
	       ccif.ccinv[0] <= 1'b1;
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b0;
	    end else begin
	       //core is reading
	       ccif.iwait[0] <= 1'b1;
	       ccif.dwait[0] <= ccif.cctrans[1]; //use cctrans as snoop hit flag
	       ccif.iwait[1] <= 1'b1;
	       ccif.dwait[1] <= 1'b1;
	       ccif.ccwait[1] <= 1'b1;
	       ccif.ccinv[1] <= 1'b1;
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b0;
	    end
	 end

	 SNOOP1: begin
	    ccif.ramstore <= ccif.dstore[1];
	    ccif.ramaddr <= ccif.daddr[1];
	    ccif.ccsnoopaddr[0] <= ccif.daddr[1];
	    if (ccif.ccwrite[1]) begin
	       //core is writing
	       ccif.iwait[1] <= 1'b1;
	       ccif.dwait[1] <= ccif.cctrans[0]; //use cctrans as snoop hit flag
	       ccif.iwait[0] <= 1'b1;
	       ccif.dwait[0] <= 1'b1;
	       ccif.ccwait[1] <= 1'b1;
	       ccif.ccinv[1] <= 1'b1;
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b0;
	    end else begin
	       //core is reading
	       ccif.iwait[1] <= 1'b1;
	       ccif.dwait[1] <= ccif.cctrans[0]; //use cctrans as snoop hit flag
	       ccif.iwait[0] <= 1'b1;
	       ccif.dwait[0] <= 1'b1;
	       ccif.ccwait[0] <= 1'b1;
	       ccif.ccinv[0] <= 1'b1;
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b0;
	    end
	 end

	 WB0: begin
	    ccif.ramstore <= ccif.dstore[0];
	    ccif.ramaddr <= ccif.daddr[0];
	    ccif.iwait[0] <= 1'b1;
	    ccif.dwait[0] <= (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	    ccif.iwait[1] <= 1'b1;
	    ccif.dwait[1] <= 1'b1;
	    ccif.ccwait[0] <= 1'b1;
	    ccif.ccinv[0] <= 1'b1;
	    ccif.ramWEN <= 1'b1;
	    ccif.ramREN <= 1'b0;
	 end

	 WB1: begin
	    ccif.ramstore <= ccif.dstore[1];
	    ccif.ramaddr <= ccif.daddr[1];
	    ccif.iwait[1] <= 1'b1;
	    ccif.dwait[1] <= (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	    ccif.iwait[0] <= 1'b1;
	    ccif.dwait[0] <= 1'b1;
	    ccif.ccwait[0] <= 1'b1;
	    ccif.ccinv[0] <= 1'b1;
	    ccif.ramWEN <= 1'b1;
	    ccif.ramREN <= 1'b0;
	 end

	 MEM0: begin
	    ccif.ramstore <= ccif.dstore[0];
	    ccif.ramaddr <= ccif.daddr[0];
	    if (ccif.ccwrite[0]) begin
	       //core is writing
	       ccif.iwait[0] <= 1'b1;
	       ccif.dwait[0] <= (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.iwait[1] <= 1'b1;
	       ccif.dwait[1] <= 1'b1;
	       ccif.ccwait[0] <= 1'b1;
	       ccif.ccinv[0] <= 1'b1;
	       ccif.ramWEN <= 1'b1;
	       ccif.ramREN <= 1'b0;
	    end else begin
	       //core is reading
	       ccif.iwait[0] <= 1'b1;
	       ccif.dwait[0] <= (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.iwait[1] <= 1'b1;
	       ccif.dwait[1] <= 1'b1;
	       ccif.ccwait[1] <= 1'b1;
	       ccif.ccinv[1] <= 1'b0;
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b1;
	    end
	 end

	 MEM1: begin
	    ccif.ramstore <= ccif.dstore[1];
	    ccif.ramaddr <= ccif.daddr[1];
	    if (ccif.ccwrite[0]) begin
	       //core is writing
	       ccif.iwait[1] <= 1'b1;
	       ccif.dwait[1] <= (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.iwait[0] <= 1'b1;
	       ccif.dwait[0] <= 1'b1;
	       ccif.ccwait[0] <= 1'b1;
	       ccif.ccinv[0] <= 1'b1;
	       ccif.ramWEN <= 1'b1;
	       ccif.ramREN <= 1'b0;
	    end else begin
	       //core is reading
	       ccif.iwait[1] <= 1'b1;
	       ccif.dwait[1] <= (ccif.ramstate == ACCESS) ? 1'b0 : 1'b1;
	       ccif.iwait[0] <= 1'b1;
	       ccif.dwait[0] <= 1'b1;
	       ccif.ccwait[0] <= 1'b1;
	       ccif.ccinv[0] <= 1'b0;
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b1;
	    end
	 end
	 default: begin
	    ccif.ccsnoopaddr[0] <= '0;
	    ccif.ccsnoopaddr[1] <= '0;
	    ccif.dload[0] <= ccif.ramload;
	    ccif.iload[0] <= ccif.ramload;
	    ccif.dload[1] <= ccif.ramload;
	    ccif.iload[1] <= ccif.ramload;
	 end
      endcase
   end // always_comb

endmodule
