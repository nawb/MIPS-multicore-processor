//Created: 	02/11/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	forwarding unit interface

`ifndef FORWARDING_UNIT_IF_VH
 `define FORWARDING_UNIT_IF_VH

 `include "cpu_types_pkg.vh"

interface forwarding_unit_if;
   import cpu_types_pkg::*;
   
   regbits_t rd_mem, rd_wb; //rd from 2 instructions ago; rd from 1 instruction ago
   regbits_t curr_rs, curr_rt;   
   logic wr_mem, wr_wb;   
   logic [1:0] fwd_op1, fwd_op2;   
   
   modport fwd (
		input  rd_mem, rd_wb, curr_rs, curr_rt,
		       wr_mem, wr_wb,
		output fwd_op1, fwd_op2
		);
      
endinterface

`endif //FORWARDING_UNIT_IF_VH
