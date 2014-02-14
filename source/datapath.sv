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
   assign rfif.wsel  = cuif.regdst ? cuif.rt : cuif.rd;
   assign rfif.wdat  = cuif.memtoreg ? dpif.dmemload : aluif.res;
   assign rfif.WEN   = rqif.wreq;
   assign dpif.dmemstore = rfif.rdat2;   

   //alu
   assign aluif.op1  = rfif.rdat1;
   always_comb begin : THREE_INPUT_MUX_FOR_OP2
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
   assign pcif.branchmux = cuif.pc_src;
   assign pcif.jumpmux = 0; //cuif.jump_src;
   assign dpif.imemaddr = pcif.imemaddr;
   assign pcif.pcEN = rqif.pcEN;
   assign pcif.halt = cuif.halt;   
   
   //control unit
//   assign cuif.instr = (nRST) ? dpif.imemload : '0; //give it default state, prevents red lines propagating throughout the system
   assign cuif.instr = dpif.imemload;   
   assign cuif.alu_flags = {aluif.flag_n, aluif.flag_v, aluif.flag_z};
   assign dpif.halt = cuif.halt;
   
endmodule
