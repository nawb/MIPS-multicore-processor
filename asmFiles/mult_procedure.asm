#--------------------------------------------
# multiply procedure
# - multiplies an arbitrary number of integers
#--------------------------------------------

	
// set the address where you want this
// code segment
	org 0x0000
	ori $29, $0, 0xFFFC   //initialize stack pointer to 0xFFFC
	ori $31, $0, 0x3FFC   //where final result is stored
	ori $1, $0, 0x0001


	
mult:
	pop $4  //pop op2
	pop $5  //pop op1
	and $2, $2, $0 //clear out $2

	//add op1 an op2 number of times
	//store accumulating sum (/product) in $2
mult_loop:
	addu $2, $2, $5
	subu $4, $4, $1  //decrement op2
	beq $4, $0, mult_exit
	j mult_loop
mult_exit:
	//push $2 //push return value from return register
	sw $2, 0($31)
	halt
	
mydata:
	org 0x3FFC
	cfw  0xAA	
	
