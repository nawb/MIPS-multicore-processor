/*
//Created: 	02/11/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	program counter interface
*/
`ifndef PC_IF_VH
`define PC_IF_VH

`include "cpu_types_pkg.vh"

interface pc_if;
  import cpu_types_pkg::*;


  // register file ports
  modport pc (
	      
  );

endinterface

`endif //PC_IF_VH
