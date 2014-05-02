#--------------------------------------
# Test branches upon branches
#--------------------------------------
	org 0x0000
	ori   $1, $zero, 0x1
	ori   $2, $zero, 0x2
	beq   $zero, $zero, braZ
	bne  $0, $0, braZ
	halt
braZ:
	beq $0,$1,braZ	
	halt
	beq $1, $1, wrong
wrong:
	beq $1, $1, braZ
