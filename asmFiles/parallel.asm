#core 1: producer

org 0x0000
  ori   $sp, $zero, 0xFFFC
  #put random seed in a0
  lui $a0,0xDEAD
  ori $a0,$0,0xBEEF
  ori $k0,$0,255
  loop0:
    jal crc32       #compute random number
    #test if buffer is full
    #full if w+1=r
    full_test:
      lw $t0,read_pointer($0) #r
      lw $t1,write_pointer($0) #w
      addiu $t1,$t1,4
      beq $t0,$t1,full_test
    jal write_buffer  #write to circular buffer
    addiu $k0, $k0, -1  #increment loop counter
    bne $k0, $0, loop0
halt

#core 2: consumer
org 0x0200
  ori $1,$0,1
  sw $1,lock($0)
  ori   $sp, $zero, 0x8FFC
  ori $k0,$0,255

  loop1:
    #test if buffer is empty
    #empty if r=w
    empty_test:
      lw $t0,read_pointer($0) #r
      lw $t1,write_pointer($0) #w
      beq $t0,$t1,empty_test

    jal read_buffer #read from circular buffer into v0
    add $a1,$0,$v0
    #compute running sum, min, max
    #m(a0,a1)->v0
    #min
    lw $a0,mintmp($0)
    jal min
    sw $v0,mintmp($0)
    #max
    lw $a0,maxtmp($0)
    jal max
    sw $a0,maxtmp($0)
    #sum
    lw $t0,sum($0)
    add $t0,$t0,$a1
    sw $t0,sum($0)
    addiu $k0, $k0, -1  #increment loop counter
    bne $k0,$0,loop1

  #divide by 256 to get average
  lw $t0,sum($0)
  sll $t0,$t0,24
  sw $t0,sum($0)
halt

#CRC

#REGISTERS
#at $1 at
#v $2-3 function returns
#a $4-7 function args
#t $8-15 temps
#s $16-23 saved temps (callee preserved)
#t $24-25 temps
#k $26-27 kernel
#gp $28 gp (callee preserved)
#sp $29 sp (callee preserved)
#fp $30 fp (callee preserved)
#ra $31 return address

#store v0 to buffer
write_buffer:
  #get lock with test&test&set loop
  ori $s3,$0,lock
  ll $t1,0($s3)
  ori $s2,$0,1
  beq $t1,$0,write_buffer
  sc $s3,0($s2)
  beq $s2,$0,write_buffer
  #ATOMIC SECTION
  lw $s0,write_pointer($0)
  ori $t4,$0,40
  addiu $s0,$s0,4
  beq $s0,$t4,dec0
  j wr0
  dec0:
  subu $s0,$s0,$t4
  wr0:
  #copy v0 to t5 and mask off upper 16 bits
  xor $t5,$v0,$0
  ori $t5,$t5,0xFFFF
  sw $v0,buffer($s0)
  sw $s0,write_pointer($0)
  #release lock
  sw $0,0($s3)
  #return from subroutine
  jr $ra

#store v0 to buffer
read_buffer:
  #get lock with test&test&set loop
  ori $s3,$0,lock
  ll $t1,0($s3)
  ori $s2,$0,1
  beq $t1,$0,read_buffer
  sc $s3,0($s2)
  beq $s2,$0,read_buffer
  #ATOMIC SECTION
  ori $t4,$0,36
  addiu $s0,$s0,-4
  beq $s0,$t4,dec1
  j rd1
  dec1:
  subu $s0,$s0,$t4
  rd1:
  lw $v0,buffer($s0)
  #release lock
  sw $0,0($s3)
  #return from subroutine
  sw $s0,read_pointer($0)
  jr $ra

# USAGE random0 = crc(seed), random1 = crc(random0)
#       randomN = crc(randomN-1)
#------------------------------------------------------
# $v0 = crc32($a0)
crc32:
  lui $t1, 0x04C1
  ori $t1, $t1, 0x1DB7
  or $t2, $0, $0
  ori $t3, $0, 32

l1:
  slt $t4, $t2, $t3
  beq $t4, $zero, l2

  srl $t4, $a0, 31
  sll $a0, $a0, 1
  beq $t4, $0, l3
  xor $a0, $a0, $t1
l3:
  addiu $t2, $t2, 1
  j l1
l2:
  or $v0, $a0, $0
  jr $ra
#------------------------------------------------------

#MINMAX

# registers a0-1,v0,t0
# a0 = a
# a1 = b
# v0 = result

#-max (a0=a,a1=b) returns v0=max(a,b)--------------
max:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $0, $a0
  slt   $t0, $a0, $a1
  beq   $t0, $0, maxrtn
  or    $v0, $0, $a1
maxrtn:
  pop   $a1
  pop   $a0
  pop   $ra
  jr    $ra
#--------------------------------------------------

#-min (a0=a,a1=b) returns v0=min(a,b)--------------
min:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $0, $a0
  slt   $t0, $a1, $a0
  beq   $t0, $0, minrtn
  or    $v0, $0, $a1
minrtn:
  pop   $a1
  pop   $a0
  pop   $ra
  jr    $ra
#--------------------------------------------------

org 0x0F00
buffer:

org 0x7000
read_pointer: nop
write_pointer: nop
mintmp: nop
maxtmp: nop
sum: nop
lock: nop
