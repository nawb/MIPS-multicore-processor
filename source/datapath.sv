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
`include "hazard_unit_if.vh"
`include "forwarding_unit_if.vh"
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
   hazard_unit_if     hzif ();
   forwarding_unit_if fwif ();
   pipeline_regs_if   ppif ();   
   
   //MAP BLOCKS
   control_unit    CU (cuif);
   register_file   RF (CLK, nRST, rfif);
   alu             ALU (aluif);
   pc #(PC_INIT)   PC (CLK, nRST, pcif);
   request_unit    RQ (CLK, nRST, rqif);
   hazard_unit     HZ (hzif);
   forwarding_unit FW (fwif);  

   //PIPELINE LATCHES
   pipelinereg #(64)  IF_ID  (CLK, nRST, hzif.FDen, hzif.FDflush, ppif.FD_in, ppif.FD_out);
   pipelinereg #(161) ID_EX  (CLK, nRST, hzif.DEen, hzif.DEflush, ppif.DE_in, ppif.DE_out);
   pipelinereg #(119) EX_MEM (CLK, nRST, hzif.EMen, hzif.EMflush, ppif.EM_in, ppif.EM_out);
   pipelinereg #(108) MEM_WB (CLK, nRST, hzif.MWen, hzif.MWflush, ppif.MW_in, ppif.MW_out);
   
   ////////////////////////////////////////////////////
   // BLOCK CONNECTIONS
   ////////////////////////////////////////////////////
   //register file
   assign rfif.rsel1 = cuif.rs;
   assign rfif.rsel2 = cuif.rt;
   assign rfif.wsel  = ppif.MW_out.wsel;
   assign rfif.WEN   = ppif.MW_out.dcuREN;
   assign dpif.dmemstore = ppif.EM_out.dmemstore;//rfif.rdat2;
   always_comb begin : MEMTOREG
      casez (ppif.MW_out.memtoreg)
	0: rfif.wdat = ppif.MW_out.alu_res;  //for everything else
	1: rfif.wdat = ppif.MW_out.dmemload; //for lw
	2: rfif.wdat = ppif.MW_out.pc_plus_4 + 4;//pcif.imemaddr + 4; //for JAL, store next instruction address
	default: rfif.wdat = ppif.MW_out.alu_res;	
      endcase
   end

   //alu
   //assign aluif.op1  = ppif.DE_out.rdat1;//rfif.rdat1;
   always_comb begin : FWD_MUX_1
      casez (fwif.fwd_op1)
	0: aluif.op1 = ppif.DE_out.rdat1;	
	1: aluif.op1 = ppif.EM_out.alu_res;	
	2: aluif.op1 = rfif.wdat;
	default: aluif.op1 = ppif.DE_out.rdat1;
      endcase
   end
   word_t op2_tmp;   
   always_comb begin : FWD_MUX_2
      casez (fwif.fwd_op2)
	0: op2_tmp = ppif.DE_out.rdat2;
	1: op2_tmp = ppif.EM_out.alu_res;
	2: op2_tmp = rfif.wdat;
	default: op2_tmp = ppif.DE_out.rdat2;	
      endcase
   end
   always_comb begin : ALU_SRC
      casez (ppif.DE_out.alu_src)//cuif.alu_src)
	0: aluif.op2 = op2_tmp;//ppif.DE_out.rdat2;//rfif.rdat2;
	1: aluif.op2 = ppif.DE_out.imm16;	
	2: aluif.op2 = {ppif.DE_out.imm16, 16'b0}; //for LUI specifically
	default: aluif.op2 = ppif.DE_out.rdat2;//rfif.rdat2;
      endcase
   end
   assign aluif.opcode  = ppif.DE_out.alu_op;//cuif.alu_op;
   assign aluif.shamt   = ppif.DE_out.shamt;//cuif.shamt;
   
   //request unit
   //assign rqif.regwr = cuif.regwr;
   //assign rqif.icuREN = cuif.icuREN;  
   //assign rqif.dcuREN = ppif.DE_out.dcuREN;
   //assign rqif.dcuWEN = ppif.DE_out.dcuWEN;
   //assign rqif.ihit = dpif.ihit;
   //assign rqif.dhit = dpif.dhit;
   //assign dpif.imemREN = rqif.imemREN;
   //assign dpif.dmemREN = rqif.dmemREN;
   //assign dpif.dmemWEN = rqif.dmemWEN;

   //hazard unit
   assign hzif.ihit = dpif.ihit;
   assign hzif.dhit = dpif.dhit;
   assign hzif.halt = cuif.halt;

   //forwarding unit
   assign fwif.curr_rs = cuif.rs;
   assign fwif.curr_rt = cuif.rt;
   assign fwif.rd_mem = ppif.EM_out.rd;
   assign fwif.rd_wb  = ppif.MW_out.wsel;
   assign fwif.wr_mem = ppif.EM_out.regwr;
   assign fwif.wr_wb  = ppif.MW_out.dcuREN;   
   
   //pc
   assign pcif.pc_src = cuif.pc_src;
   assign pcif.regval = aluif.res; //could have been op1 too...either way   
   assign pcif.imm16 = $signed(cuif.imm16);
   assign pcif.imm26 = $signed(dpif.imemload[25:0]);   
   assign dpif.imemaddr = pcif.imemaddr;
   assign pcif.pcEN = ~cuif.halt & dpif.ihit;//rqif.pcEN;
   assign pcif.halt = cuif.halt;
   
   //control unit
   assign cuif.instr = ppif.FD_out.instr;
   //assign cuif.alu_flags = {aluif.flag_n, aluif.flag_v, aluif.flag_z};
   assign dpif.dmemaddr = ppif.EM_out.alu_res;   
   assign dpif.imemREN = ppif.EM_out.icuREN; 
   assign dpif.dmemREN = ppif.EM_out.dcuREN;
   assign dpif.dmemWEN = ppif.EM_out.dcuWEN;
   assign dpif.halt = ppif.MW_out.halt;

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
   assign ppif.DE_in.halt   = cuif.halt;   

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
   assign ppif.EM_in.halt = ppif.DE_out.halt;
   

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
   assign ppif.MW_in.dcuREN = ppif.EM_out.regwr;
   assign ppif.MW_in.icuREN = ppif.EM_out.icuREN;
   assign ppif.MW_in.halt = ppif.EM_out.halt;
   
endmodule
