//Created: 	02/11/2014
//Author:	Nabeel Zaim (mg232)
//Lab Section:	437-03
//Description: 	request unit (hazard unit) interface

`ifndef REQUEST_UNIT_IF_VH
 `define REQUEST_UNIT_IF_VH

 `include "cpu_types_pkg.vh"

interface request_unit_if;
   import cpu_types_pkg::*;

   logic regw, ren, wen, ihit, dhit, iREN, dREN, dWEN;
   logic [2:0] pcstate;   
   
   modport req (
		input  regw, ren, wen, ihit, dhit,
		output iREN, dREN, dWEN, pcstate
		);
endinterface

`endif //REQUEST_UNIT_IF_VH
