# testing or instruction

main:
	addi a0, zero, 32
    addi a1, zero, 52
    
    or a0, a0, a1
    
	# EXPECTED OUTPUT = 52
