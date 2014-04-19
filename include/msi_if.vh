`ifndef MSI_VH
`define MSI_VH

`include "cpu_types_pkg.vh"

typedef enum logic[1:0] { MODIFIED='b10, SHARED='b00, INVALID='b01 } msi_state;
typedef enum logic[2:0] { IDLE, BUSRD, BUSRDX, INVALIDATE, WB } bus_command;

interface pc_if;
   import cpu_types_pkg::*;

   logic read;
   logic write;
   logic busRd;
   logic busRdX;
   msi_state state;
   bus_command command;
   
   // register file ports
   modport msi 
      (
      input  read, write, busRd, busRdX,
      output state, command
      );

endinterface

`endif //MSI_VH
