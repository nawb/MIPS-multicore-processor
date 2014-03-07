//File name: 	source/hazard_unit.sv
//Created: 	02/25/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	Hazard Unit

`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module hazard_unit ( hazard_unit_if.haz hzif );

   assign hzif.FDen = (~hzif.halt | hzif.branching | hzif.jumping) & 1'b1;
   assign hzif.DEen = 1'b1;//~hzif.dhit;
   assign hzif.EMen = 1'b1;
   assign hzif.MWen = 1'b1; //MW latch always enabled

   //insert a bubble when:
   assign hzif.FDflush = ~hzif.halt & (hzif.dhit | hzif.branching | hzif.jumping);
   assign hzif.DEflush = ~hzif.halt & (hzif.jumping | hzif.branching);
   assign hzif.EMflush = 1'b0;
   assign hzif.MWflush = 1'b0;
   
endmodule
