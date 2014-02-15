/*
 Nabeel Zaim
 mg232
 
 datapath contains register file, control, hazard,
 muxes, and glue logic for processor
 */

// data path interface
`include "datapath_cache_if.vh"
// block interfaces
`include "control_unit_if.vh"
`include "register_file_if.vh"
`include "alu_if.vh"
`include "pc_if.vh"
`include "request_unit_if.vh"
// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"

module datapath (
		 input logic CLK, nRST,
		 datapath_cache_if.dp dpif
		 );
   // import types
   import cpu_types_pkg::*;

   // pc init
   parameter PC_INIT = 0;

   //BLOCK INTERFACES
   control_unit_if    cuif ();
   register_file_if   rfif ();
   alu_if             aluif ();
   pc_if              pcif ();
   request_unit_if    rqif ();   
   
   //MAP BLOCKS
   control_unit    CU (cuif);
   register_file   RF (CLK, nRST, rfif);
   alu             ALU (aluif);
   pc #(PC_INIT)   PC (CLK, nRST, pcif);
   request_unit    RQ (CLK, nRST, rqif);
   
   //BLOCK CONNECTIONS
   //register file
   assign rfif.rsel1 = cuif.rs;
   assign rfif.rsel2 = cuif.rt;
   assign rfif.WEN   = rqif.wreq;
   assign dpif.dmemstore = rfif.rdat2;
//   assign rfif.wdat  = cuif.memtoreg ? dpif.dmemload : aluif.res;
   always_comb begin : MEMTOREG
      casez (cuif.memtoreg)
	0: rfif.wdat = aluif.res;     //for everything else
	1: rfif.wdat = dpif.dmemload; //for lw
	2: rfif.wdat = pcif.imemaddr + 4; //for JAL, store next instruction address
	default: rfif.wdat = aluif.res;	
      endcase
   end
   always_comb begin : REGDST
      casez (cuif.regdst)
	0: rfif.wsel = cuif.rd; //for r-type
	1: rfif.wsel = cuif.rt;	//for i-type
	2: rfif.wsel = (5'd31); //store to $31 for JAL
	default: rfif.wsel = cuif.rd;	
      endcase
   end


   //alu
   assign aluif.op1  = rfif.rdat1;
   always_comb begin : ALU_SRC
      casez (cuif.alu_src)
	0: aluif.op2 = rfif.rdat2;
	1: aluif.op2 = //EXTENDER BLOCK:
		       (cuif.extop ? $signed(cuif.imm16) : {16'b0, cuif.imm16});
	2: aluif.op2 = {cuif.imm16, 16'b0}; //for LUI specifically
	default: aluif.op2 = rfif.rdat2;
      endcase
   end
   assign aluif.opcode  = cuif.alu_op;
   assign aluif.shamt   = cuif.shamt;
   /*
   always_comb begin
      casez (dpif.imemload[31:26])
	LW, SW: dpif.dmemaddr = aluif.res;
	default: dpif.dmemaddr = '0;	
      endcase
   end*/
   assign dpif.dmemaddr = aluif.res;

   //request unit
   assign rqif.regwr = cuif.regwr;
   assign rqif.icuREN = cuif.icuREN;   
   assign rqif.dcuREN = cuif.dcuREN;
   assign rqif.dcuWEN = cuif.dcuWEN;
   assign rqif.ihit = dpif.ihit;
   assign rqif.dhit = dpif.dhit;
   assign dpif.imemREN = rqif.imemREN;
   assign dpif.dmemREN = rqif.dmemREN;
   assign dpif.dmemWEN = rqif.dmemWEN;

   //pc
   assign pcif.pc_src = cuif.pc_src;
   assign pcif.regval = aluif.res; //could have been op1 too...either way   
   assign pcif.imm16 = $signed(cuif.imm16);
   assign pcif.imm26 = $signed(dpif.imemload[25:0]);   
   assign dpif.imemaddr = pcif.imemaddr;
   assign pcif.pcEN = ~cuif.halt & dpif.ihit;
   assign pcif.halt = cuif.halt;   
   
   //control unit
//   assign cuif.instr = (nRST) ? dpif.imemload : '0; //give it default state, prevents red lines propagating throughout the system
   assign cuif.instr = dpif.imemload;
   assign cuif.alu_flags = {aluif.flag_n, aluif.flag_v, aluif.flag_z};
//   assign cuif.zeroflag = aluif.flag_z;
   assign dpif.halt = cuif.halt;
   
endmodule
