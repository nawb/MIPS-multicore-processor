
  #------------------------------------------------------------------
  # R-type Instruction (ALU) Test Program
  #------------------------------------------------------------------

  org 0x0000
  ori   $1,$zero,0xD269
  ori   $2,$zero,0x37F1

  ori   $21,$zero,0x80
  ori   $22,$zero,0xF0

# Now running all R type instructions
  or    $3,$1,$2
  and   $4,$1,$2
  andi  $5,$1,0xF
  addu  $6,$1,$2
  addiu $7,$3,0x8740
  subu  $8,$4,$2
  xor   $9,$5,$2
  xori  $10,$1,0xf33f
  sll   $11,$1,4
  srl   $12,$1,5
  nor   $13,$1,$2
# Store them to verify the results
  sw    $13,0($22)
  sw    $3,0($21)
  sw    $4,4($21)
  sw    $5,8($21)
  sw    $6,12($21)
  sw    $7,16($21)
  sw    $8,20($21)
  sw    $9,24($21)
  sw    $10,28($21)
  sw    $11,32($21)
  sw    $12,36($21)
  halt  # that's all

org 0x200

  ori   $1,$zero,0xD269
  ori   $2,$zero,0x37F1

  ori   $25,$zero,0x80
  ori   $26,$zero,0xF0

  or    $13,$1,$2
  and   $14,$1,$2
  andi  $15,$1,0xF
  addu  $16,$1,$2
  addiu $17,$13,0x8740
  subu  $18,$14,$2
  xor   $19,$15,$2
  xori  $20,$1,0xf33f
  sll   $21,$1,4
  srl   $22,$1,5
  nor   $23,$1,$2
# Store them to verify the results
  sw    $23,0($26)
  sw    $13,0($25)
  sw    $14,4($25)
  sw    $15,8($25)
  sw    $16,12($25)
  sw    $17,16($25)
  sw    $18,20($25)
  sw    $19,24($25)
  sw    $20,28($25)
  sw    $21,32($25)
  sw    $22,36($25)
 halt
