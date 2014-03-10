//icache block

// interfaces
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"

// cpu types
`include "cpu_types_pkg.vh"

module icache (
  input logic CLK, nRST,
  datapath_cache_if.cache dcif,
  cache_control_if.caches ccif
);
  // import types
  import cpu_types_pkg::*;
  parameter CPUID = 0;

  typedef struct packed {
    logic [25:0] tag;
    word_t data;
    logic valid;
  } cache_block;

  cache_block [16] cache;
  logic [25:0] tag;
  logic [3:0] index;

  assign tag = dcif.imemaddr[31:6];
  assign index = dcif.imemaddr[5:2];

  always_ff @(posedge CLK)
  begin
    if (!nRST)
    begin
      cache <= '0;
    end
    else
      if (!dcif.ihit) && (!ccif.iwait) begin
	cache[index].tag = tag;
	cache[index].valid = 1;
	cache[index].data = ccif.iload[CPUID];
      end
    end
  end

  assign dcif.ihit = (cache[index].tag == tag) && cache[index].valid;
  assign dcif.imemload = cache[index].data;

  assign ccif.iREN[CPUID] = dcif.imemREN && !dcif.ihit
  assign ccif.iaddr[CPUID] = dcif.imemaddr;
endmodule
