/*
 Eric Villasenor
 evillase@gmail.com
 
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
   assign rfif.wdat  = cuif.memtoreg ? aluif.res : dpif.dmemload;
   assign rfif.WEN   = rqif.wreq;
   assign dpif.dmemstore = rfif.rdat2;   

   //alu
   assign aluif.op1  = rfif.rdat1;
   assign aluif.op2  = cuif.alu_src ?
		       //EXTENDER BLOCK:
		       (cuif.extop ? $signed(dpif.imemload[25:0]) : {12'b0, dpif.imemload[25:0]}) :
		       rfif.rdat2; 
   assign aluif.opcode = cuif.alu_op;
   assign dpif.dmemaddr = aluif.res;

   //request unit
   assign rqif.regwr = cuif.regwr;
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
   
   //control unit
   assign cuif.instr = dpif.imemload;
   assign cuif.alu_flags = {aluif.flag_n, aluif.flag_v, aluif.flag_z};

   
endmodule
