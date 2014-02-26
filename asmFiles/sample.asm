#---------------------------------------
# sample asm file for tutoriala
#---------------------------------------

# set the address where you want this
# code segment
  org 0x0000

ori $3, $0, 0xff
  ori   $1, $0, mydata
  ori   $2, $0, 0x0080
  addu  $3, $1, $2
  sw    $3, 4($1)
  halt



mydata:
  org 0x0080
  cfw   0x10
