/*
  Eric Villasenor
  evillase@gmail.com

  multicoretop block
  holds data path components, cache level
  and coherence
*/

module multicore (
  input logic CLK, nRST,
  output logic halt,
  cpu_ram_if.cpu scif
);

parameter PC0 = 0;
parameter PC1 = 'h200;

  // bus interface
  datapath_cache_if         dcif0 ();
  datapath_cache_if         dcif1 ();
  // coherence interface
  cache_control_if           ccif ();

  // map datapath
  datapath #(.PC_INIT(PC0)) DP0 (CLK, nRST, dcif0);
  datapath #(.PC_INIT(PC1)) DP1 (CLK, nRST, dcif1);
  // map caches
  caches #(.CPUID(0))       CM0 (CLK, nRST, dcif0, ccif);
  caches #(.CPUID(1))       CM1 (CLK, nRST, dcif1, ccif);
  // map coherence
  memory_control            CC (CLK, nRST, ccif);

  // interface connections
  assign scif.memaddr = ccif.ramaddr;
  assign scif.memstore = ccif.ramstore;
  assign scif.memREN = ccif.ramREN;
  assign scif.memWEN = ccif.ramWEN;

  assign ccif.ramload = scif.ramload;
  assign ccif.ramstate = scif.ramstate;

  assign halt = dcif1.flushed & dcif2.flushed;
endmodule
