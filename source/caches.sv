/*
  Eric Villasenor
  evillase@gmail.com

 Nabeel Zaim
 mg232
 03/07/2014

  this block holds the i and d cache
*/

// interfaces
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"

// cpu types
`include "cpu_types_pkg.vh"

module caches (
  input logic CLK, nRST,

  datapath_cache_if dcif,
  cache_control_if ccif
);  
  import cpu_types_pkg::word_t;
  parameter CPUID = 0;
   
  word_t instr;   

  // icache
  icache #(CPUID)  ICACHE(CLK, nRST, dcif.icache, ccif.icache);
  // dcache
  dcache #(CPUID)  DCACHE(CLK, nRST, dcif.dcache, ccif.dcache);

   //assign dcif.flushed = dcif.halt;
   

endmodule
