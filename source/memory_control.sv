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

   typedef enum {IDLE, ARBITRATE, SNOOP0, SNOOP1, CACHE0, CACHE1, MEM0, MEM1} state_t;
   //MEM0: memory has ownership, will send to core 0
   //MEM1: memory has ownership, will send to core 1
   //CACHE0: cache 1 has ownership, will send to core 0
   //CACHE1: cache 0 has ownership, will send to core 1

   state_t state, next_state;

   always_ff @(posedge CLK, negedge nRST) begin
      if(!nRST) begin
	 state <= IDLE;
      end else begin
	 state <= next_state;
      end
   end
   
   //next state logic
   always_comb begin : NEXT_STATE_LOGIC
      casez(state)
	 IDLE: begin
	    if (ccif.dREN[0] || ccif.dWEN[0] || ccif.dREN[1] || ccif.dWEN[1])
	      next_state <= ARBITRATE;	       
	    else
	      next_state <= IDLE;	    
	 end
	ARBITRATE: begin
	   if(ccif.dREN[0] || ccif.dWEN[0]) begin//ccif.cctrans[0]) begin
	      next_state <= SNOOP0;
	   end else if(ccif.dREN[1] || ccif.dWEN[1]) begin//ccif.cctrans[1]) begin
	      next_state <= SNOOP1;
	   end else begin
	      next_state <= IDLE;
	   end
	end
	 SNOOP0: begin
	    if (ccif.cctrans[1]) begin //stay in snoop until other cache does a WB or INV
	       next_state <= SNOOP0;	       
	    end else if (ccif.ccwrite[1]) begin //it has done a WB
	       next_state <= CACHE0;
	    end else begin //it doesn't have it
	       next_state <= MEM0;
	    end
	 end
	 SNOOP1: begin
	    if (ccif.cctrans[0]) begin
	       next_state <= SNOOP1;
	    end else if (ccif.ccwrite[0]) begin
	       next_state <= CACHE1;
	    end else begin
	       next_state <= MEM1;
	    end
	 end
	 CACHE0: begin
	    if (!ccif.ccwrite[1] && (ccif.daddr[0] == ccif.daddr[1])) begin //wait until other cache is done writing to memory and changes state from M->S
	       next_state <= CACHE0;
	    end else begin
	       next_state <= IDLE;
	    end
	 end
	 CACHE1: begin
	    if (!ccif.ccwrite[0] && (ccif.daddr[0] == ccif.daddr[1])) begin //wait until other cache is done writing to memory and changes state from M->S IF it is doing so for the address we are snooping for
	       next_state <= CACHE1;
	    end else begin
	       next_state <= IDLE;
	    end
	 end
	 MEM0: begin
	    if(ccif.cctrans[0])
	       next_state <= IDLE;
	    else
	       next_state <= MEM0;
	 end
	 MEM1: begin
	    if(ccif.cctrans[1])
	       next_state <= IDLE;
	    else
	       next_state <= MEM1;
	 end	
      endcase
   end

   //output logic
   always_comb begin : OUTPUT_LOGIC
      default_values();      
      casez(state)
	 IDLE: begin
	    default_values();
	    ccif.ccsnoopaddr[0] <= '0;
	    ccif.ccsnoopaddr[1] <= '0;
	    
	    if (ccif.iREN[0]) begin //Priority to Core0
	       ccif.ramaddr <= ccif.iaddr[0];
	       ccif.iload[0] <= ccif.ramload;	       
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b1;
	       ccif.iwait[0] <= (ccif.ramstate == ACCESS)? 0:1;	       
	    end // if (ccif.iREN[0])
	    else if (ccif.iREN[1]) begin //Priority to Core1
	       ccif.ramaddr <= ccif.iaddr[1];
	       ccif.iload[1] <= ccif.ramload;
	       ccif.ramWEN <= 1'b0;
	       ccif.ramREN <= 1'b1;
	       ccif.iwait[0] <= 1'b1;
	       ccif.iwait[1] <= (ccif.ramstate == ACCESS)? 0:1;
	    end // if (ccif.iREN[1])
	    /*
	    if (ccif.ccwrite[1]) begin
	       ccif.ccinv[0] <= 1;
	       ccif.ccsnoopaddr[0] <= ccif.daddr[1];
	       ccif.ccwait[0] <= 1; //to tell it a coherence operation is happening
	    end
	    if (ccif.ccwrite[0]) begin
	       ccif.ccinv[1] <= 1;	   
	       ccif.ccsnoopaddr[1] <= ccif.daddr[0];
	       ccif.ccwait[1] <= 1; //coherence operation happening
	    end*/
	 end // case: IDLE
	ARBITRATE: begin
	   default_values();
	   ccif.ccwait[0] <= 1'b1;
	   ccif.ccwait[1] <= 1'b1;	   
	end
	 SNOOP0: begin
	    default_values();
	    ccif.ccwait[0] <= 1'b0;
	    ccif.ccwait[1] <= 1'b1; //hold all other cores
	    ccif.ccsnoopaddr[1] <= ccif.daddr[0]; //send to other core's snooptag
	    ccif.ccinv[1] <= ccif.ccwrite[0] & ccif.dWEN[0];	    
	 end
	 SNOOP1: begin
	    default_values();
	    ccif.ccwait[0] <= 1'b1; //hold all other cores
	    ccif.ccwait[1] <= 1'b0;
	    ccif.ccsnoopaddr[0] <= ccif.daddr[1]; //send to other core's snooptag
	   // ccif.ccinv[0] <= 1'b1;
	 end
	 CACHE0: begin
	    default_values();
	    ccif.ramWEN <= ccif.dWEN[1];	    
	    ccif.dload[0] <= ccif.dstore[1]; //cache2cache bypassing memory
	    ccif.ramaddr <= ccif.daddr[1];
	    ccif.ramstore <= ccif.dstore[1];
	    ccif.dwait[0] <= 0; //data is available on c2c instantly
	    ccif.dwait[1] <= (ccif.ramstate == ACCESS)?0:1; //for the core writing to memory, it has to wait to change state until ram is free
	    ccif.ccwait[1] <= 1;
	 end       	
	 CACHE1: begin
	    default_values();
	    ccif.ramWEN <= ccif.dWEN[0];	    
	    ccif.dload[1] <= ccif.dstore[0]; //c2c bypassing memory
	    ccif.ramaddr <= ccif.daddr[0];
	    ccif.ramstore <= ccif.dstore[0];
	    ccif.dwait[1] <= 0;	    //data is available on c2c bus instantly
	    ccif.dwait[0] <= (ccif.ramstate == ACCESS)?0:1;
	    //^^ for the core writing to memory, it has to wait to change state until ram is free
	    ccif.ccwait[0] <= 1;
	 end
	 MEM0: begin
	    default_values();
	    ccif.ramREN <= ccif.dREN[0];
	    ccif.ramWEN <= ccif.dWEN[0];
	    ccif.ramaddr <= ccif.daddr[0];	    
	    ccif.dload[0] <= ccif.ramload;
	    ccif.ramstore <= ccif.dstore[0];
	    ccif.dwait[0] <= (ccif.ramstate == ACCESS)? 0:1;
	    ccif.ccwait[1] <= 0;  //can be 0 since not dealing with cache anymore
	 end       
 	MEM1: begin
	   default_values();
	   ccif.ramREN <= ccif.dREN[1];
	   ccif.ramWEN <= ccif.dWEN[1];
	   ccif.ramaddr <= ccif.daddr[1];
	   ccif.dload[1] <= ccif.ramload;
	   ccif.ramstore <= ccif.dstore[1];
	   ccif.dwait[1] <= (ccif.ramstate == ACCESS)? 0:1;
	   ccif.ccwait[0] <= 0; //0 since only dealing with memory now	  
 	end // case: MEM1
	 default: begin
	    default_values();
	    ccif.iload[0] <= '0;
	    ccif.iload[1] <= '0;	    
	 end
      endcase
   end // always_comb
      
   task default_values;
      //initializes all the variables in OUTPUT_LOGIC so they don't create latches
      ccif.ramREN <= 0;
      ccif.ramWEN <= 0;
      ccif.ramaddr <= ccif.iaddr[0];
      ccif.iload[0] <= ccif.iload[0];
      ccif.iload[1] <= ccif.iload[1];      
      ccif.dload[0] <= '0;
      ccif.dload[1] <= '0;
      ccif.ramstore <= '0;
      ccif.dwait[0] <= 1;
      ccif.dwait[1] <= 1;
      ccif.iwait[0] <= 1;
      ccif.iwait[1] <= 1;
      ccif.ccsnoopaddr[0] <= ccif.ccsnoopaddr[0];
      ccif.ccsnoopaddr[1] <= ccif.ccsnoopaddr[1];
      ccif.ccwait[0] <= 0;
      ccif.ccwait[1] <= 0;
      ccif.ccinv[0] <= 0;
      ccif.ccinv[1] <= 0;      
   endtask // default_values
   
   
endmodule
