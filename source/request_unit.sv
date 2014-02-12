//File name: 	source/request_unit.sv
//Created: 	02/11/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	request unit (hazard unit) coordinates between DP and memory_control

`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"

import cpu_types_pkg::*;

module request_unit
  (
   input logic 	CLK, nRST,
   request_unit_if.req rqif
   );
   logic 	memdone;

   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 memdone = 0;
	 rqif.pcstate = 0;
	 rqif.dREN = 0;
	 rqif.dWEN = 0;
	 rqif.iREN = 0;	 
      end 
      else if (!(rqif.ren||rqif.wen)) begin
	 memdone = 0;
	 rqif.pcstate = (rqif.ihit & !(rqif.ren||rqif.wen));
	 rqif.dREN = rqif.ren;
	 rqif.dWEN = rqif.wen;
      end 
      else begin
	 if (!memdone) begin
	    memdone = rqif.dhit;
	    rqif.pcstate = 0;
	    rqif.dREN = rqif.ren;
	    rqif.dWEN = rqif.wen;
	 end 
	 else begin
	    memdone = !rqif.ihit;
	    rqif.pcstate = rqif.ihit;
	    rqif.dREN = 0;
	    rqif.dWEN = 0;
	 end
      end
   end

      /*	logic [1:0]state;
    logic [1:0]nextstate;
    
    //next state logic
    always_ff @ (state, ren, wen, ihit, dhit)
    begin
    nextstate = 2'b00;
    casez(state)
    2'b00:begin
    if(ren||wen)begin
    nextstate = 2'b01;
					end
				end
    2'b01:begin
    if(dhit)begin
    nextstate = 2'b10;
					end
				end
    2'b10:begin
    if(ihit)begin
    nextstate = 2'b00;
					end
				end
		endcase
	end
    
    //output logic
    always_ff @ (state)
    begin
    casez(state)
    2'b00:begin
    dREN = ren;
    dWEN = wen;
    pcstate = ihit;
				end
    2'b01:begin
    dREN = ren;
    dWEN = wen;
    pcstate = 0;
				end
    2'b10:begin
    dREN = 0;
    dWEN = 0;
    pcstate = ihit;
				end
		endcase
	end
    
    //next logic
    always_ff @ (posedge CLK, negedge nRST)
    begin
    if(!nRST)begin
    state = 2'b00;
		end else if(CLK)begin
    state = nextstate;
		end
	end*/

endmodule
