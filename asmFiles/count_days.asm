#--------------------------------------------
# day counting procedure
#--------------------------------------------
	org 0x0000
	ori $1, $0, 0x0001
	ori $29, $0, 0xFFFC   	//initialize stack pointer to 0xFFFC

	##############
	#TEST VALUES:
	ori $4, $0, 20 		//current day
	ori $5, $0, 1		//current month
	ori $6, $0, 2014 	//current year
	##############

count_days:
	//days = day + 30 * (month-1) + 365 * (year-2000)

	//CALCULATE MONTH DAYS:
	addiu $5, $5, -1
	push $5
	ori $8, $0, 30
	push $8
	jal mult
	pop $16 //store month days

	//CALCULATE YEAR DAYS:
	addiu $6, $6, -2000
	push $6
	ori $8, $0, 365
	push $8
	jal mult
	pop $17 //store year days

	//ADD THEM ALL TOGETHER:
	addu $17, $17, $16
	addu $8, $17, $4
	push $8
	
count_days_exit:
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

