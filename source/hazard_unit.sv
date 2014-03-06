//File name: 	source/hazard_unit.sv
//Created: 	02/25/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	Hazard Unit

`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module hazard_unit ( hazard_unit_if.haz hzif );

   assign hzif.FDen = (~hzif.halt | ~hzif.lwinmem_fwdtoex | hzif.mispredict | hzif.jumping) & 1'b1;
   assign hzif.DEen = ~hzif.lwinmem_fwdtoex;//~hzif.dhit;
   assign hzif.EMen = 1'b1;
   assign hzif.MWen = 1'b1; //MW latch always enabled

   //insert a bubble when:
   assign hzif.FDflush = ~hzif.halt & (hzif.dhit | hzif.mispredict | hzif.jumping);
   assign hzif.DEflush = ~hzif.halt & (hzif.jumping | hzif.mispredict);
   assign hzif.EMflush = hzif.lwinmem_fwdtoex;
   assign hzif.MWflush = 1'b0;
   
endmodule
