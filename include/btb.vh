/*
 //Created: 	02/11/2014
 //Author:	Nabeel Zaim (mg232)
 //Lab Section:	437-03
 //Description: 	program counter interface
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

  typedef struct {
    logic valid;
    btb_state_t state;
    word_t target;
    word_t pc;
  } btb_entry_t;

endpackage

interface btb_if;
  import cpu_types_pkg::*;
  import btb_pkg::*;

  btb_entry_t entries[3:0];
  word_t pc, pc_w;
  word_t target, target_w;
  logic taken, taken_w;
  logic WEN;

  modport read
  (
    input pc,
    output target,
    output taken
  );

  modport write
  (
    input WEN,
    input pc_w,
    input target_w,
    input taken_w
  );

  modport btb
  (
    output entries
  );

endinterface

`endif //BTB_IF_VH
