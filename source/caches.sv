/*
  Eric Villasenor
  evillase@gmail.com

  this block holds the i and d cache
*/


// interfaces
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"

// cpu types
`include "cpu_types_pkg.vh"

module caches (
  input logic CLK, nRST,
  datapath_cache_if.cache dcif,
  cache_control_if ccif
);
  // import types
  import cpu_types_pkg::word_t;

  parameter CPUID = 0;

  word_t instr;

  // icache
  //icache  ICACHE(dcif, ccif);
  // dcache
  //dcache  DCACHE(dcif, ccif);

  // single cycle instr saver (for memory ops)
  always_ff @(posedge CLK or negedge nRST)
  begin
    if (!nRST)
    begin
      instr <= '0;
    end
    else if (!ccif.iwait[CPUID] && (!dcif.dmemREN || !dcif.dmemWEN))
    begin
      instr <= ccif.iload[CPUID];
    end
  end
  // dcache invalidate before halt handled by dcache when exists
  assign dcif.flushed = dcif.halt;

  //single cycle
  assign dcif.ihit = (dcif.imemREN) ? ~ccif.iwait[CPUID] : 0;
  assign dcif.dhit = (dcif.dmemREN|dcif.dmemWEN) ? ~ccif.dwait[CPUID] : 0;
  assign dcif.imemload = instr;
  assign dcif.dmemload = ccif.dload[CPUID];


  assign ccif.iREN[CPUID] = dcif.imemREN;
  assign ccif.dREN[CPUID] = dcif.dmemREN;
  assign ccif.dWEN[CPUID] = dcif.dmemWEN;
  assign ccif.dstore[CPUID] = dcif.dmemstore;
  assign ccif.iaddr[CPUID] = dcif.imemaddr;
  assign ccif.daddr[CPUID] = dcif.dmemaddr;

endmodule
