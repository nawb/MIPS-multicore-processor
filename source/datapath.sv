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
`include "pipeline_regs_if.vh"
`include "cpu_types_pkg.vh"

module datapath (
		 input logic CLK, nRST,
		 datapath_cache_if.dp dpif
		 );
   // import types
   import cpu_types_pkg::*;
   import pipeline_regs_pkg::*; 

   // pc init
   parameter PC_INIT = 0;

   //BLOCK INTERFACES
   control_unit_if    cuif ();
   register_file_if   rfif ();
   alu_if             aluif ();
   pc_if              pcif ();
   request_unit_if    rqif ();
   pipeline_regs_if   ppif ();   
   
   //MAP BLOCKS
   control_unit    CU (cuif);
   register_file   RF (CLK, nRST, rfif);
   alu             ALU (aluif);
   pc #(PC_INIT)   PC (CLK, nRST, pcif);
   request_unit    RQ (CLK, nRST, rqif);

   //PIPELINE LATCHES
   pipelinereg #(64)   IF_ID  (CLK, nRST, cuif.regEN, cuif.flush, ppif.FD_in, ppif.FD_out);
   pipelinereg #(160) ID_EX  (CLK, nRST, cuif.regEN, cuif.flush, ppif.DE_in, ppif.DE_out);
   pipelinereg #(118) EX_MEM (CLK, nRST, cuif.regEN, cuif.flush, ppif.EM_in, ppif.EM_out);
   pipelinereg #(107) MEM_WB (CLK, nRST, cuif.regEN, cuif.flush, ppif.MW_in, ppif.MW_out);
   
   ////////////////////////////////////////////////////
   // BLOCK CONNECTIONS
   ////////////////////////////////////////////////////
   //register file
   assign rfif.rsel1 = cuif.rs;
   assign rfif.rsel2 = cuif.rt;
   assign rfif.WEN   = rqif.wreq;
   assign dpif.dmemstore = ppif.EM_out.dmemstore;//rfif.rdat2;
   always_comb begin : MEMTOREG
      casez (cuif.memtoreg)
	0: rfif.wdat = ppif.MW_out.alu_res;  //for everything else
	1: rfif.wdat = ppif.MW_out.dmemload; //for lw
	2: rfif.wdat = ppif.MW_out.pc_plus_4 + 4;//pcif.imemaddr + 4; //for JAL, store next instruction address
	default: rfif.wdat = ppif.MW_out.alu_res;	
      endcase
   end

   //alu
   assign aluif.op1  = ppif.DE_out.rdat1;//rfif.rdat1;
   always_comb begin : ALU_SRC
      casez (ppif.DE_out.alu_src)//cuif.alu_src)
	0: aluif.op2 = ppif.DE_out.rdat2;//rfif.rdat2;
	1: aluif.op2 = ppif.DE_out.imm16;	
	2: aluif.op2 = {ppif.DE_out.imm16, 16'b0}; //for LUI specifically
	default: aluif.op2 = ppif.DE_out.rdat2;//rfif.rdat2;
      endcase
   end
   assign aluif.opcode  = ppif.DE_out.alu_op;//cuif.alu_op;
   assign aluif.shamt   = ppif.DE_out.shamt;//cuif.shamt;
   
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
   assign cuif.instr = ppif.FD_out.instr;
   //assign cuif.alu_flags = {aluif.flag_n, aluif.flag_v, aluif.flag_z};
   assign dpif.dmemaddr = ppif.EM_out.alu_res;   
   assign dpif.halt = cuif.halt;

   ///////////////////////////////////////////////////////
   //  PIPELINE LATCHES
   ///////////////////////////////////////////////////////

   //LATCH 1: INSTRUCTION FETCH/INSTRUCTION DECODE======== 
   assign ppif.FD_in.instr = dpif.imemload;
   assign ppif.FD_in.pc_plus_4 = pcif.imemaddr;

   //LATCH 2: INSTRUCTION DECODE/EXECUTE================
   assign ppif.DE_in.pc_plus_4 = ppif.FD_out.pc_plus_4;
   assign ppif.DE_in.rdat1 = rfif.rdat1;   
   assign ppif.DE_in.rdat2 = rfif.rdat2;   
   assign ppif.DE_in.imm16 = //EXTENDER BLOCK:
			     (cuif.extop ? $signed(cuif.imm16) 
			      : {16'b0, cuif.imm16});
   assign ppif.DE_in.alu_op = cuif.alu_op;
   assign ppif.DE_in.alu_src = cuif.alu_src;
   assign ppif.DE_in.shamt = cuif.shamt;   
   assign ppif.DE_in.rd = cuif.rd;   
   assign ppif.DE_in.rt = cuif.rt;   
   assign ppif.DE_in.regdst = cuif.regdst;   
   assign ppif.DE_in.memwr = cuif.memwr;   
   assign ppif.DE_in.memtoreg = cuif.memtoreg;   
   assign ppif.DE_in.pc_src = cuif.pc_src;   
   assign ppif.DE_in.regwr = cuif.regwr;   
   assign ppif.DE_in.icuREN = cuif.icuREN;   
   assign ppif.DE_in.dcuWEN = cuif.dcuWEN;   
   assign ppif.DE_in.dcuREN = cuif.dcuREN;			   

   //LATCH 3: EXECUTE/MEMORY===========================
   assign ppif.EM_in.pc_plus_4 = ppif.DE_out.pc_plus_4;
   assign ppif.EM_in.dmemstore = ppif.DE_out.rdat2;
   assign ppif.EM_in.alu_res = aluif.res;
   //assign ppif.EM_in.zflag = aluif.zeroflag; not implemented yet
   assign ppif.EM_in.rd = ppif.DE_out.rd;   
   assign ppif.EM_in.rt = ppif.DE_out.rt;   
   assign ppif.EM_in.regdst = ppif.DE_out.regdst;   
   assign ppif.EM_in.memwr = ppif.DE_out.memwr;   
   assign ppif.EM_in.memtoreg = ppif.DE_out.memtoreg;   
   assign ppif.EM_in.pc_src = ppif.DE_out.pc_src;   
   assign ppif.EM_in.regwr = ppif.DE_out.regwr;   
   assign ppif.EM_in.icuREN = ppif.DE_out.icuREN;   
   assign ppif.EM_in.dcuWEN = ppif.DE_out.dcuWEN;   
   assign ppif.EM_in.dcuREN = ppif.DE_out.dcuREN;

   //LATCH 4: MEMORY/WRITEBACK=========================
   assign ppif.MW_in.pc_plus_4 = ppif.EM_out.pc_plus_4;
   assign ppif.MW_in.alu_res = ppif.EM_out.alu_res;
   assign ppif.MW_in.dmemload = dpif.dmemload;
   always_comb begin : REGDST
      casez (ppif.EM_out.regdst)
	0: ppif.MW_in.wsel = ppif.EM_out.rd; //for r-type
	1: ppif.MW_in.wsel = ppif.EM_out.rt; //for i-type
	2: ppif.MW_in.wsel = (5'd31); //store to $31 for JAL
	default: ppif.MW_in.wsel = ppif.EM_out.rd;	
      endcase
   end
   
   assign ppif.MW_in.memtoreg = ppif.EM_out.memtoreg;   
   assign ppif.MW_in.pc_src = ppif.EM_out.pc_src;   
   assign ppif.MW_in.regwr = ppif.EM_out.regwr;   
   assign ppif.MW_in.icuREN = ppif.EM_out.icuREN;
   
endmodule
