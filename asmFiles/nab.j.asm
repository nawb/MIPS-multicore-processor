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
	beq $0, $0, main    #forward jump
	addiu $3, $4, 0xdead

subroutine:
	add $26, $25, $24
	jr $31
	

main:
	jal subroutine  #backward jump
	addiu $2, $1, 3
	beq $0, $0, subroutine
	halt              #be careful here, there is a halt right after beq, so it might go through the pipeline and even though you had just branched the system might halt if you dont have mispredictions corrected properly


