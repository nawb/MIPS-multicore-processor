//File name: 	source/request_unit.sv
//Created: 	02/11/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	

`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"

import cpu_types_pkg::*;


module request_unit
  (
   input logic 	CLK, nRST,
   input logic 	ren,
   input logic 	wen,
   input logic 	ihit,
   input logic 	dhit,
   output logic dren,
   output logic dwen,
   output logic nextpc
   );

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
    dren = ren;
    dwen = wen;
    nextpc = ihit;
				end
    2'b01:begin
    dren = ren;
    dwen = wen;
    nextpc = 0;
				end
    2'b10:begin
    dren = 0;
    dwen = 0;
    nextpc = ihit;
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

   logic 	memdone;

   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST) begin
	 memdone = 0;
	 nextpc = 0;
	 dren = 0;
	 dwen = 0;
      end 
      else if (!(ren||wen)) begin
	 memdone = 0;
	 nextpc = (ihit & !(ren||wen));
	 dren = ren;
	 dwen = wen;
      end 
      else begin
	 if (!memdone) begin
	    memdone = dhit;
	    nextpc = 0;
	    dren = ren;
	    dwen = wen;
	 end 
	 else begin
	    memdone = !ihit;
	    nextpc = ihit;
	    dren = 0;
	    dwen = 0;
	 end
      end
   end
   
endmodule
