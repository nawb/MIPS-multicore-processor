#--------------------------------------------
# multiply procedure
# - multiplies an arbitrary number of integers
#--------------------------------------------

	
# set the address where you want this
# code segment
	org 0x0000
	ori $1, $0, 0x0001
	ori $29, $0, 0xFFFC   	//initialize stack pointer to 0xFFFC

	##############
	#TEST VALUES:
	ori $24, $0, 2
	ori $25, $0, 3
	ori $26, $0, 4
	##############
	
mult_procedure:
	//INITIAL VALUES:
	//load stack pointer value to finish at into $8:
	andi $16, $0, 0
	addiu $16, $29, -4

	push $24
	push $25
	push $26

mult_proc_loop:
	beq $16, $29, mult_proc_loop_exit
	jal mult
	j mult_proc_loop
	
mult_proc_loop_exit:
	addiu $31, $0, 0x3FFC
	pop $8
	sw $8, 0($31)
	halt	

#### MULTIPLY ALGORITHM
#######################
	
mult:
	pop $8  	//pop op2
	pop $9  	//pop op1
	and $2, $2, $0 	//clear out $2

	//add op1 an op2 number of times
	//store accumulating sum (/product) in $2
mult_loop:
	addu $2, $2, $9
	subu $8, $8, $1 //decrement op2
	beq $8, $0, mult_exit
	j mult_loop
mult_exit:
	push $2		//push return value from return register
	jr $31

