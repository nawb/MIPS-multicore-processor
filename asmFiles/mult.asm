#--------------------------------------------
# multiply algorithm
# - multiplies two unsigned words from stack
#--------------------------------------------

	
# set the address where you want this
# code segment
  org 0x0000

mult:
	#get 16 bits from stack (A)
	#multiply it with each bit from (B)
	#add them together
	#store upper 16
	#store lower 16

	ori $1, $0, mydata
	ori $2, $0, 4(mydata)
#  ori   $1, $0, mydata
#  ori   $2, $0, 0x0080
#  addu  $3, $1, $2
#  sw    $3, 4($1)
  halt



mydata:
	org 0x0080
	cfw   10	
	cfw 5
