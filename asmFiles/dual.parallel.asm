#------------------------------------------
# Paralell Algorithm
#------------------------------------------

#----------------------------------------------------------
# First Processor
#----------------------------------------------------------
  org   0x0000              # first processor p0
  ori   $sp, $zero, 0x3ffc  # stack
  #put random seed in a0
  lui $a0,0xDEAD
  ori $a0,$0,0xBEEF
  #initialize loop counter
  ori $k0,$0,255
  loop0:
    jal crc32       #compute random number
    #test if buffer is full
    #full if w+1=r
    #wait until non-full
    full_test:
      lw $t0,read_pointer($0) #r
      lw $t1,write_pointer($0) #w
      addiu $t1,$t1,4
      beq $t0,$t1,full_test
    jal write_buffer  #write to circular buffer
    addiu $k0, $k0, -1  #increment loop counter
    bne $k0, $0, loop0
  halt

# returns when lock is available
lock:
acquire:
  ll    $t0, lock_pointer($0)         # load lock location
  bne   $t0, $0, acquire    # wait on lock to be open
  addiu $t0, $t0, 1
  sc    $t0, lock_pointer($0)
  beq   $t0, $0, lock       # if sc failed retry
  jr    $ra

# returns when lock is free
unlock:
  sw    $0, lock_pointer($0)
  jr    $ra

# store v0 into the circular buffer
write_buffer:
  push  $ra                 # save return address
  #ori   $a0, $zero, l1      # move lock to arguement register
  jal   lock                # try to aquire the lock
  # critical code segment BEGIN
  
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
  
  # critical code segment END
  ori   $a0, $zero, l5      # move lock to arguement register
  jal   unlock              # release the lock
  pop   $ra                 # get return address
  jr    $ra                 # return to caller
l5:
  cfw 0x0

#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
  org   0x200               # second processor p1
  ori   $sp, $zero, 0x7ffc  # stack pointer
  ori $k0,$0,255            #initialize loop counter

  loop1:
    #test if buffer is empty
    #empty if r=w
    #wait if empty
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

# read from the cirular buffer
read_buffer:
  push  $ra                 # save return address
  #ori   $a0, $zero, l1      # move lock to arguement register
  jal   lock                # try to aquire the lock
  # critical code segment BEGIN

  ori $t4,$0,36
  addiu $s0,$s0,-4
  beq $s0,$t4,dec1
  j rd1
  dec1:
  subu $s0,$s0,$t4
  rd1:
  lw $v0,buffer($s0)

  # critical code segment END
  #ori   $a0, $zero, l5      # move lock to arguement register
  jal   unlock              # release the lock
  pop   $ra                 # get return address
  jr    $ra                 # return to caller

res:
  cfw 0x0                   # end result should be 3

#----------------------------------------------
# Course Provided Subroutines
#----------------------------------------------

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
lock_pointer: nop
