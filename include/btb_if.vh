/*
 //Created: 	03/03/2014
 //Author:	Steven Ellis (mg205)
 //Lab Section:	437-04
 //Description: 
 */
`ifndef BTB_IF_VH
`define BTB_IF_VH

`include "cpu_types_pkg.vh"

package btb_pkg;
  import cpu_types_pkg::*;

  typedef enum {
    STRONG_TAKEN,
    WEAK_TAKEN,
    WEAK_NOT_TAKEN,
    STRONG_NOT_TAKEN
  } btb_state_t;

  typedef struct packed {
    logic valid;  //encountered in the program ourselves
    btb_state_t state;
    word_t target;
    word_t pc;
  } btb_entry_t;

endpackage

interface btb_if;
  import cpu_types_pkg::*;
  import btb_pkg::*;

   btb_entry_t [3:0] entries;
   
  word_t pc, pc_w;
  word_t target, target_w;
  logic taken, taken_w;
  logic WEN;

  modport btbport
  (
   //READ PORTION:
   input  pc,
   output target,
   output taken,

   //WRITE PORTION:
   input  WEN,
   input  pc_w,
   input  target_w,
   input  taken_w
  );

endinterface

`endif //BTB_IF_VH
