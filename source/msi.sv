`include "msi_if.vh"

module msi (
	       input logic CLK, nRST,
	       msi_if.msi mif
	       );

msi_state cstate, nstate;
bus_command command, ncommand;

//flip flop logic
always_ff @(posedge CLK, negedge nRST) begin
	if(!nRST) begin
		cstate <= INVALID;
		command <= IDLE;
	end else begin
		cstate <= nstate;
		command <= ncommand;
	end
end

//next state logic
always_comb begin
	nstate <= cstate;
	ncommand <= IDLE;
	casez(cstate)
		MODIFIED: begin
			if(mif.busRdX) begin
				nstate <= INVALID;
				ncommand <= WB;
			end
			if(mif.busRd) begin
				nstate <= SHARED;
				ncommand <= INVALIDATE;
			end
		end
		SHARED: begin
			if(mif.write) begin
				nstate <= MODIFIED;
				ncommand <= BUSRDX;
			end
			if(mif.busRdX) begin
				nstate <= INVALID;
			end
		end
		INVALID: begin
			if(mif.read) begin
				nstate <= SHARED;
				ncommand <= BUSRD;
			end
			if(mif.write) begin
				nstate <= MODIFIED;
				ncommand <= BUSRDX;
			end
		end
	endcase
end

//output logic
assign mif.state = cstate;
assign mif.command = command;

endmodule
