
  #------------------------------------------------------------------
  # R-type Instruction (ALU) Test Program
  #------------------------------------------------------------------

  org 0x0000
  ori   $1,$zero,0x0F00
  ori   $2,$zero,0xBADE

  sw    $2,0($1)
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
  halt

org 0x200
  ori   $1,$zero,0x0F00
  ori   $2,$zero,0xBAAD
  ori   $3,$zero,0xABED
  ori   $4,$zero,0xBABE
nop
  lw    $2,0($1)
  ori   $2,$2,0xF000
  sw    $2,0($1)
 halt
