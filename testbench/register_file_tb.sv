/*
 Eric Villasenor
 evillase@gmail.com

 register file test bench
 */

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

   parameter PERIOD = 10;

<<<<<<< HEAD
   logic CLK = 0, nRST = 1;
=======
  logic CLK = 0, nRST;
>>>>>>> aa81c8bad88fc3c4584bef66e53c9444c32a8d72

   // test vars
   int 	 v1 = 1;
   int 	 v2 = 4721;
   int 	 v3 = 25119;

   // clock
   always #(PERIOD/2) CLK++;

<<<<<<< HEAD
   // interface
   register_file_if rfif ();
   // test program
   test PROG ();
   // DUT
=======
  // interface
  register_file_if rfif ();
  // test program
  test PROG ();
  // DUT
>>>>>>> aa81c8bad88fc3c4584bef66e53c9444c32a8d72
`ifndef MAPPED
   register_file DUT(CLK, nRST, rfif);
`else
   register_file DUT
     (
      .\rfif.rdat2 (rfif.rdat2),
      .\rfif.rdat1 (rfif.rdat1),
      .\rfif.wdat (rfif.wdat),
      .\rfif.rsel2 (rfif.rsel2),
      .\rfif.rsel1 (rfif.rsel1),
      .\rfif.wsel (rfif.wsel),
      .\rfif.WEN (rfif.WEN),
      .\nRST (nRST),
      .\CLK (CLK)
      );
`endif
   
   initial begin
      //initial values
      nRST = 1;
      rfif.rsel1 = '0; rfif.rsel2 = '0;
      rfif.wsel = '0; rfif.wdat = '0;
      rfif.WEN = 0;
      
      //initial reset
      nRST = 1;
      nRST = 0; #(PERIOD/2);
      @(posedge CLK) nRST = 1;

      $monitor("%5dns: rdat1 [%h]\trdat2 [%h]",$time, rfif.rdat1, rfif.rdat2);
      
      //test writes and reads
      $display("Testing conseuctive writes and reads");
      for (int ii = 0; ii < 32; ii++) begin
	 rfif.WEN = 1'b1;
	 rfif.wdat = ii*4;
	 rfif.wsel = ii;
	 rfif.rsel1 = ii;
	 #(PERIOD);
	 rfif.WEN = 1'b0;
	 
	 if (rfif.rdat1 != ii*4) 
	   $display("FAILED: reg%d should be %d! %d", ii, v3, $time);
	 //else $display("reg%d -- Passed write/read test.", ii);
      end // for (int ii = 0; ii < 32; ii++)

      
      //test reset
      $display("Testing synchronous reset");
      nRST = 0; #PERIOD; nRST = 1; //send reset signal
      for (int ii = 0; ii < 32; ii++) begin
	 rfif.rsel1 = ii;
	 if (rfif.rdat1 != '0) $display("FAILED: reg%d should be 0 after reset!", ii);
	 //else $display("reg%d -- Passed reset test.", ii);
      end

      //test write to reg0
      $display("Testing write to reg0");
      rfif.wdat = v2;
      rfif.WEN = 'b1;
      rfif.wsel = 'b0; //write to reg0
      #(PERIOD);
      rfif.wsel = 'b1; //also write to reg1
      #(PERIOD);
      
//      rfif.WEN = 'b0;
      rfif.rsel1 = 'b0; //read reg0
      rfif.rsel2 = 'b1; //read reg1
      
      if (rfif.rdat1 != '0 && rfif.rdat2 != v2) $display("reg0 should be 0 after anything");
      else $display("Passed write to reg0 test.");


      $display("Testing ReadAfterWrite race case");
      rfif.wdat = v3;
      rfif.wsel = 3;
      rfif.rsel1 = 3;

      //Enable write immediately before read
      #(0.1ns) rfif.WEN = 1'b1;
      
      //read WHILE enabling WEN, should not show new value yet
      $display("While writing: [%h]", rfif.rdat1);
      if (rfif.rdat1 != '0) $display("Error: Already reading new number");

      //wait for write to complete, should have new value now
      #PERIOD;
      $display("After writing: [%h]", rfif.rdat1);
      if (rfif.rdat1 != v3) $display("Error: Still reading old number");
      else $display("Correctly passed race case");
/*
      //test writes
      rfif.WEN = 1;
      
      rfif.wsel = 31;
      rfif.wdat = 32'h0D;
      #(PERIOD*2); //<-- why does it only work like this??

      rfif.wsel = 30;
      rfif.wdat = 32'h0E;
      #(PERIOD);
      
      rfif.wsel = 29;
      rfif.wdat = 32'h0A;
      #(PERIOD);

      rfif.wsel = 28;
      rfif.wdat = 32'h0D;
      #(PERIOD);
      rfif.WEN = 'b0;

      //test reads
      rfif.rsel1 = 31;
      #(PERIOD);
      rfif.rsel1 = 30;
      #(PERIOD);
      rfif.rsel1 = 29;
      #(PERIOD);
      rfif.rsel1 = 28;
      #(PERIOD);
      rfif.rsel1 = 27;
      #(PERIOD);
*/      
   end

   
endmodule

program test;
endprogram
   
