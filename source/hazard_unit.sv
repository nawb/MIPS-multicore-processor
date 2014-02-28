//File name: 	source/hazard_unit.sv
//Created: 	02/25/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	Hazard Unit

`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module hazard_unit ( hazard_unit_if.haz hzif );

   assign hzif.FDen = ~hzif.halt & 1'b1;
   assign hzif.DEen = 1'b1;
   assign hzif.EMen = 1'b1;
   assign hzif.MWen = 1'b1; //MW latch always enabled

   assign hzif.FDflush = ~hzif.halt & (hzif.dhit); //insert bubble
   assign hzif.DEflush = 1'b0;
   assign hzif.EMflush = 1'b0;
   assign hzif.MWflush = 1'b0;
   
endmodule
