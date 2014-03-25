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

   //internal temporary wires drawn out so we can pull their value into other places
   regbits_t wsel_tmp;    //between RegDst mux and the MW latch, so I can pull it out into the FWD unit
   word_t op2_tmp;   //between fwd_mux2 and ALUsrc mux

   //BLOCK INTERFACES
   control_unit_if    cuif ();
   register_file_if   rfif ();
   alu_if             aluif ();
   pc_if              pcif ();
   hazard_unit_if     hzif ();
   forwarding_unit_if fwif ();
   pipeline_regs_if   ppif ();

   //BLOCK PORTMAPPINGS
   control_unit    CU (cuif);
   register_file   RF (CLK, nRST, rfif);
   alu             ALU (aluif);
   pc #(PC_INIT)   PC (CLK, nRST, pcif);
   hazard_unit     HZ (hzif);
   forwarding_unit FW (fwif);

   //PIPELINE LATCHES
   pipelinereg #(70)  IF_ID  (CLK, nRST, hzif.FDen, hzif.FDflush, ppif.FD_in, ppif.FD_out);
   pipelinereg #(200) ID_EX  (CLK, nRST, hzif.DEen, hzif.DEflush, ppif.DE_in, ppif.DE_out);
   pipelinereg #(124) EX_MEM (CLK, nRST, hzif.EMen, hzif.EMflush, ppif.EM_in, ppif.EM_out);
   pipelinereg #(114) MEM_WB (CLK, nRST, hzif.MWen, hzif.MWflush, ppif.MW_in, ppif.MW_out);

   ////////////////////////////////////////////////////
   // BLOCK CONNECTIONS
   ////////////////////////////////////////////////////
   //register file
   assign rfif.rsel1 = cuif.rs;
   assign rfif.rsel2 = cuif.rt;
   assign rfif.wsel  = ppif.MW_out.wsel;
   assign rfif.WEN   = ppif.MW_out.dcuREN; 
   always_comb begin : FWD_MUX3
      casez (fwif.fwd_mem)
	0: dpif.dmemstore = ppif.EM_out.dmemstore;
	1: dpif.dmemstore = rfif.wdat;
	default: dpif.dmemstore = ppif.EM_out.dmemstore;
      endcase
   end
   always_comb begin : MEMTOREG
      casez (ppif.MW_out.memtoreg)
	0: rfif.wdat = ppif.MW_out.alu_res;  //for everything else
	1: rfif.wdat = ppif.MW_out.dmemload; //for lw
	2: rfif.wdat = ppif.MW_out.pc_plus_4;//for JAL, store next instruction address
	default: rfif.wdat = ppif.MW_out.alu_res;
      endcase
   end

   //alu
   always_comb begin : FWD_MUX_1
      casez (fwif.fwd_op1)
	0: aluif.op1 = ppif.DE_out.rdat1;
	1: aluif.op1 = ppif.EM_out.alu_res;
	2: aluif.op1 = rfif.wdat;
	default: aluif.op1 = ppif.DE_out.rdat1;
      endcase
   end
   always_comb begin : FWD_MUX_2
      casez (fwif.fwd_op2)
	0: op2_tmp = ppif.DE_out.rdat2;
	1: op2_tmp = ppif.EM_out.alu_res;
	2: op2_tmp = rfif.wdat;
	default: op2_tmp = ppif.DE_out.rdat2;
      endcase
   end
   always_comb begin : ALU_SRC
      casez (ppif.DE_out.alu_src)
	0: aluif.op2 = op2_tmp;
	1: aluif.op2 = ppif.DE_out.imm16;
	2: aluif.op2 = {ppif.DE_out.imm16, 16'b0}; //for LUI specifically
	default: aluif.op2 = ppif.DE_out.rdat2;	
      endcase
   end
   assign aluif.opcode  = ppif.DE_out.alu_op;
   assign aluif.shamt   = ppif.DE_out.shamt;

   //hazard unit
   assign hzif.ihit = dpif.ihit;
   assign hzif.dhit = dpif.dhit;
   assign hzif.halt = ppif.DE_out.halt;
   assign hzif.branching = pcif.branchmux;
   assign hzif.jumping = (ppif.DE_out.pc_src == 2 || ppif.DE_out.pc_src == 3) ? 1 : 0;
   assign hzif.dREN = ppif.EM_out.dcuREN;
   assign hzif.dWEN = ppif.EM_out.dcuWEN;

   //forwarding unit
   assign fwif.curr_rs = ppif.DE_out.rs;
   assign fwif.curr_rt = ppif.DE_out.rt;
   assign fwif.mem_rt = ppif.EM_out.rt;
   assign fwif.rd_mem = wsel_tmp;
   assign fwif.rd_wb  = ppif.MW_out.wsel;
   assign fwif.wr_mem = ppif.EM_out.regwr;
   assign fwif.wr_wb  = ppif.MW_out.dcuREN;
   assign fwif.wm_mem = ppif.EM_out.dcuWEN;

   //pc
   assign pcif.pc_src = ppif.DE_out.pc_src;
   assign pcif.regval = aluif.op1;
   assign pcif.imm16 = ppif.DE_out.pc_plus_4 + (ppif.DE_out.imm16 << 2);
   assign pcif.imm26 = ppif.DE_out.imm26;
   assign dpif.imemaddr = pcif.imemaddr;
   assign pcif.pcEN = (~cuif.halt & dpif.ihit) & hzif.FDen;
   //added OR branching so that PC doesn't shut down as soon as it sees a halt, because the halt
   //may have been a mispredict and we had actually meant to TAKE the branch 
   always_comb begin : BRANCHMUX
      casez(ppif.DE_out.beq)
	2: pcif.branchmux = (aluif.op1 == aluif.op2) ? 1:0; //BEQ
	1: pcif.branchmux = (aluif.op1 != aluif.op2) ? 1:0; //BNE
	default: pcif.branchmux = 0;
      endcase
   end

   //control unit
   assign cuif.instr = ppif.FD_out.instr;
   assign dpif.dmemaddr = ppif.EM_out.alu_res;
   assign dpif.imemREN = 1'b1;//ppif.EM_out.icuREN;
   assign dpif.dmemREN = ppif.EM_out.dcuREN;
   assign dpif.dmemWEN = ppif.EM_out.dcuWEN;
   
   //keep halt latched high after program ends
   always_ff @ (posedge CLK, negedge nRST) begin
      if (!nRST)
	dpif.halt = 0;
      else if (ppif.MW_out.halt)
	dpif.halt = 1;	
   end
   
   ///////////////////////////////////////////////////////
   //  PIPELINE LATCHES
   ///////////////////////////////////////////////////////

   //LATCH 1: INSTRUCTION FETCH/INSTRUCTION DECODE========
   assign ppif.FD_in.instr = dpif.imemload;
   assign ppif.FD_in.pc_plus_4 = pcif.imemaddr + 4;
   assign ppif.FD_in.opcode = opcode_t'(dpif.imemload[31:26]);

   //LATCH 2: INSTRUCTION DECODE/EXECUTE================
   assign ppif.DE_in.pc_plus_4 = ppif.FD_out.pc_plus_4;
   assign ppif.DE_in.rdat1 = rfif.rdat1;
   assign ppif.DE_in.rdat2 = rfif.rdat2;
   assign ppif.DE_in.imm16 = //EXTENDER BLOCK:
			     (cuif.extop ? {{16{cuif.imm16[15]}}, cuif.imm16} //sign extend
			      : {16'b0, cuif.imm16}); //zero extend
   assign ppif.DE_in.imm26 = {{5{ppif.FD_out.instr[25:0]}}, ppif.FD_out.instr[25:0]};
   assign ppif.DE_in.alu_op = cuif.alu_op;
   assign ppif.DE_in.alu_src = cuif.alu_src;
   assign ppif.DE_in.shamt = cuif.shamt;
   assign ppif.DE_in.rd = cuif.rd;
   assign ppif.DE_in.rs = cuif.rs;
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
   assign ppif.DE_in.opcode = ppif.FD_out.opcode;
   assign ppif.DE_in.beq = (ppif.FD_out.instr[31:26] == BEQ) ? 2 :
			   (ppif.FD_out.instr[31:26] == BNE) ? 1 : 0;


   //LATCH 3: EXECUTE/MEMORY===========================
   assign ppif.EM_in.pc_plus_4 = ppif.DE_out.pc_plus_4;
   assign ppif.EM_in.dmemstore = op2_tmp;
   assign ppif.EM_in.alu_res = aluif.res;
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
   assign ppif.EM_in.opcode = ppif.DE_out.opcode;

   //LATCH 4: MEMORY/WRITEBACK=========================
   assign ppif.MW_in.pc_plus_4 = ppif.EM_out.pc_plus_4;
   assign ppif.MW_in.alu_res = ppif.EM_out.alu_res;
   assign ppif.MW_in.dmemload = dpif.dmemload;

   always_comb begin : REGDST
      casez (ppif.EM_out.regdst)
	0: wsel_tmp = ppif.EM_out.rd; //for r-type
	1: wsel_tmp = ppif.EM_out.rt; //for i-type
	2: wsel_tmp = (5'd31); //store to $31 for JAL
	default: wsel_tmp = ppif.EM_out.rd;
      endcase
   end
   assign ppif.MW_in.wsel = wsel_tmp;

   assign ppif.MW_in.memtoreg = ppif.EM_out.memtoreg;
   assign ppif.MW_in.pc_src = ppif.EM_out.pc_src;
   assign ppif.MW_in.dcuREN = ppif.EM_out.regwr;
   assign ppif.MW_in.icuREN = ppif.EM_out.icuREN;
   assign ppif.MW_in.halt = ppif.EM_out.halt;
   assign ppif.MW_in.opcode = ppif.EM_out.opcode;

endmodule
