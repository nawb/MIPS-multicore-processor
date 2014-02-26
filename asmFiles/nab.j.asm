#--------------------------------------------
# typical subroutine
# - test for j, jal, jr
#--------------------------------------------

	
# set the address where you want this
# code segment
	org 0x0000
	ori $1, $0, 0x0001
	ori $29, $0, 0xFFFC   	//initialize stack pointer to 0xFFFC

	##############
	#TEST VALUES:
	ori $24, $0, 2
	ori $25, $0, 1
	##############

main:
	jal subroutine
	addiu $2, $1, 3
	halt

subroutine:
	add $26, $25, $24
	jr $31
