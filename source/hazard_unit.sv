//File name: 	source/hazard_unit.sv
//Created: 	02/25/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	Hazard Unit

`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module hazard_unit ( hazard_unit_if.haz hzif );

   //insert a bubble when:
   assign hzif.FDen = (~hzif.halt | hzif.branching | hzif.jumping) & hzif.DEen;
   assign hzif.DEen = hzif.EMen & ~hzif.loading; //if there is a reg value in MEM that you need in EX, stall F,D stages while it loads.
   assign hzif.EMen = ~(~hzif.dhit & (hzif.dWEN | hzif.dREN)); //stall until cache returns from a cache miss  
   assign hzif.MWen = hzif.EMen; //MW latch always enabled

   //flush when:
   assign hzif.FDflush = ~hzif.halt & (hzif.branching | hzif.jumping);
			 //(hzif.dhit | hzif.branching | hzif.jumping);
   assign hzif.DEflush = ~hzif.halt & (hzif.jumping | hzif.branching);
   assign hzif.EMflush = 1'b0; //hzif.loading;
   assign hzif.MWflush = 1'b0;
   
endmodule
