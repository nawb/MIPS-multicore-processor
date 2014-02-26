//File name: 	testbench/alu_tb.sv
//Created: 	01/16/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description:

`include "alu_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module alu_tb;
   //interface
   alu_if alum ();
//   logic nRST;
   parameter PERIOD = 10; //just need a random time, but helpful if we match it against the clock period for counting cycles

`ifndef MAPPED
   alu DUT(alum);
`else
   alu DUT
     (
      .\alum.op1 (alum.op1),
      .\alum.op2 (alum.op2),
      .\alum.opcode (alum.opcode),
      .\alum.res (alum.res),
      .\alum.flag_v (alum.flag_n),
      .\alum.flag_v (alum.flag_v),
      .\alum.flag_v (alum.flag_z)
      );    
`endif // !`ifndef MAPPED

   int testA = 32'hAAAAAAAA;
   int test5 = 32'h55555555;
   int test1 = 32'h11111111;
   int test0 = 32'h00000000;
   int testF = 32'hFFFFFFFF;
   int test1_neg = -1;

   logic nRST;
   
   initial begin
      //initial values
      alum.op1 = '0;
      alum.op2 = '0;
      alum.opcode = aluop_t'('0);
      nRST = 0;
      //initial reset
      #PERIOD nRST = 1;

      #PERIOD;      
      
      ///////////////////////////////////////////////
      //     ADDITION TESTS
      ///////////////////////////////////////////////
      $display("==========\n= ADD \n==========\n");
      
      $display("Testing ADD AAAA+5555");
      do_op(testA, test5, ALU_ADD, 32'hffffffff);
      
      
      $display("Testing ADD 1111+1111");
      nRST = 0;  #PERIOD nRST = 1; //reset result
      do_op(test1, test1, ALU_ADD, 32'h22222222);

            
      $display("Testing ADD FFFF+1 (overflow flag)");
      do_op(testF, 32'h01, ALU_ADD, 32'h0);


      $display("Testing ADD -1+2 (negative with positive)");
      do_op(-1, 2, ALU_ADD, 1);

      
      $display("Testing ADD -256+-256 (negative with negative)");
      do_op(-256, -256, ALU_ADD, -512);

      
      $display("Testing ADD 0000+0000 (zero flag)");
      do_op(test0, test0, ALU_ADD, 32'h0);


      $display("Testing ADD -1+0 (negative flag)");
      do_op(test1_neg, test0, ALU_ADD, 32'hffffffff);
    
      
      ///////////////////////////////////////////////
      //     SUBTRACTION TESTS
      ///////////////////////////////////////////////
      $display("==========\n= SUB \n==========\n");
      //nRST = 0;  #PERIOD nRST = 1; //no reset, want to see change in garbage value
      $display("Testing SUB 1111-1111");
      do_op(test1, test1, ALU_SUB, '0);

      $display("Testing SUB 30-5 (pos-pos)");
      do_op(30, 5, ALU_SUB, 25);

      $display("Testing SUB 30-5 (pos-neg)");
      do_op(30, -5, ALU_SUB, 35); 
      
      $display("Testing SUB -30-5 (neg-pos)");
      do_op(-30, 5, ALU_SUB, -35);
      
      $display("Testing SUB -30-(-5) (neg-neg)");
      do_op(-30, -5, ALU_SUB, -25);

      $display("Testing SUB 7FFF-0 (identity test)");
      do_op(32'h7FFFFFFF, 0, ALU_SUB, 32'h7FFFFFFF);

      $display("Testing SUB FFFF-0 (identity test)");
      do_op(32'hFFFFFFFF, 0, ALU_SUB, 32'hFFFFFFFF);
      
      $display("Testing SUB 0-0 (identity test)");
      do_op(0, 0, ALU_SUB, 0);      
      
      ///////////////////////////////////////////////
      //     AND TESTS
      ///////////////////////////////////////////////
      $display("==========\n= AND \n==========\n");
      //nRST = 0;  #PERIOD nRST = 1; //dont reset because result is going to be 0, so want a garbage value to see res change
      $display("Testing AND 7878&ffff (A.1=A)");
      do_op(testF, 32'h78787878, ALU_AND, 32'h78787878);
      
      $display("Testing AND 1111&1111 (A.A=A)");
      do_op(test1, test1, ALU_AND, test1);

      $display("Testing AND 7777&0000 (A.0=0)");
      do_op(testA, test0, ALU_AND, '0);
      
      $display("Testing AND AAAA&5555");
      do_op(testA, test5, ALU_AND, '0);
      
      $display("Testing AND AAAA&5551");
      do_op(testA, 32'h55555552, ALU_AND, 2);

      ///////////////////////////////////////////////
      //     OR TESTS
      ///////////////////////////////////////////////
      $display("==========\n= OR \n==========\n");
      
      $display("Testing OR 1111&1111 (A+A=A)");
      do_op(test1, test1, ALU_OR, test1);

      $display("Testing OR 7777&0000 (A+0=A)");
      do_op(testA, test0, ALU_OR, testA);

      $display("Testing OR 7777&ffff (A+1=1)");
      do_op(32'h77777777, testF, ALU_OR, testF);      

      $display("Testing OR 5555&aaaa");
      do_op(test5, testA, ALU_OR, testF);

      ///////////////////////////////////////////////
      //     XOR TESTS
      ///////////////////////////////////////////////
      $display("==========\n= XOR \n==========\n");

      $display("Testing XOR 0^0");
      do_op('0, '0, ALU_XOR, '0);

      $display("Testing XOR 0^A");
      do_op('0, testA, ALU_XOR, testA);

      $display("Testing XOR 5555^AAAA");
      do_op(test5, testA, ALU_XOR, testF);

      $display("Testing XOR ffff^ffff");
      do_op(testF, testF, ALU_XOR, '0);

      ///////////////////////////////////////////////
      //     NOR TESTS
      ///////////////////////////////////////////////
      $display("==========\n= NOR \n==========\n");

      $display("Testing NOR 0^0");
      do_op('0, '0, ALU_NOR, testF);

      $display("Testing NOR 0^AAAA");
      do_op('0, testA, ALU_NOR, test5);

      $display("Testing NOR 5555^AAAA");
      do_op(test5, testA, ALU_NOR, '0);

      $display("Testing NOR ffff^ffff");
      do_op(testF, testF, ALU_NOR, '0);

      ///////////////////////////////////////////////
      //     SLT TESTS
      ///////////////////////////////////////////////
      $display("==========\n= SLT \n==========\n");

      $display("Testing SLT 0 < 0");
      do_op(0, 0, ALU_SLT, 0);

      $display("Testing SLT 1 < 7fff");
      do_op(1, 32'h7fffffff, ALU_SLT, 1);

      $display("Testing SLT 7fff < 1");
      do_op(32'h7fffffff, 1, ALU_SLT, 0);
      
      $display("Testing SLT ffffffff < 7fffffff");
      do_op(testF, 32'h7FFFFFFF, ALU_SLT, 1);

      $display("Testing SLT 7fffffff < ffffffff");
      do_op(32'h7FFFFFFF, testF, ALU_SLT, 0);

      $display("Testing SLT 1 < 0");
      do_op(1, 0, ALU_SLT, 0);


      ///////////////////////////////////////////////
      //     SLTU TESTS
      ///////////////////////////////////////////////
      $display("==========\n= SLTU \n==========\n");

      $display("Testing SLTU 0 < 0");
      do_op(0, 0, ALU_SLTU, 0);

      $display("Testing SLTU 1 < 7fff");
      do_op(1, 32'h7fffffff, ALU_SLTU, 1);

      $display("Testing SLTU 7fff < 1");
      do_op(32'h7fffffff, 1, ALU_SLTU, 0);
      
      $display("Testing SLTU ffffffff < 7fffffff");
      do_op(testF, 32'h7FFFFFFF, ALU_SLTU, 0);

      $display("Testing SLTU 7fffffff < ffffffff");
      do_op(32'h7FFFFFFF, testF, ALU_SLTU, 1);

      $display("Testing SLTU 1 < 0");
      do_op(1, 0, ALU_SLTU, 0);
      
      
   end // initial begin

   
   task do_op;
      input [31:0] op1_;
      input [31:0] op2_;
      input [3:0]  opcode_;
      input [31:0] desired_res;
//      input [2:0]  desired_flags; //3 bits [V N Z]
      
      begin
	 alum.op1 = op1_;
	 alum.op2 = op2_;
	 alum.opcode = aluop_t'(opcode_);
	 #0.5ns;
	 if (alum.res != desired_res) $display("====FAILED===");
	 //$display("%b < %b", alum.op1, alum.op2);//UNCOMMENT TO SHOW OPERANDS
	 $display("res=%h, [V%d N%d Z%d]\n", alum.res, alum.flag_v, alum.flag_n, alum.flag_z);
      end
   endtask

endmodule

