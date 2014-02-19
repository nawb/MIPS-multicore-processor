/*
  Eric Villasenor
  evillase@gmail.com

  pipeline top block
  holds data path components
  and cache level
*/

module pipeline (
  input logic CLK, nRST,
  output logic halt,
  cpu_ram_if.cpu scif
);

parameter PC0 = 0;

  // bus interface
  datapath_cache_if         dcif ();
  // coherence interface
  cache_control_if          ccif ();

  // map datapath
  datapath #(.PC_INIT(PC0)) DP (CLK, nRST, dcif);
  // map caches
  caches #(.CPUID(0))       CM (CLK, nRST, dcif, ccif);
  // map coherence
  memory_control            CC (CLK, nRST, ccif);

  // interface connections
  assign scif.memaddr = ccif.ramaddr;
  assign scif.memstore = ccif.ramstore;
  assign scif.memREN = ccif.ramREN;
  assign scif.memWEN = ccif.ramWEN;

  assign ccif.ramload = scif.ramload;
  assign ccif.ramstate = scif.ramstate;

  assign halt = dcif.flushed;
endmodule
