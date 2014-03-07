#--------------------------------------------
# - chris's super nasty corner testcase
#--------------------------------------------

	
# set the address where you want this
# code segment
	org 0x0000
	ori $1, $0, 0x0BEF
	lw $2, 0($3) #random load from irrelevant registers
	bne $1, $0, works
	sw $1, 0($1)
works:
	halt


