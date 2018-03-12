
##############################################################
# Homework #2
# name: Isaac Duarte
# sbuid: 111026940
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################

replace1st:
	bgtu $a1, 0x7f, replaceerror
	bltu $a1, 0x00, replaceerror
	bgtu $a2, 0x7f, replaceerror
	bltu $a2, 0x00, replaceerror

	move $t0, $a0
	find_1st:
		lbu $t1, ($t0)
		beqz $t1, dne
		beq $t1, $a1, found
		addi $t0, $t0, 1
		j find_1st

	replaceerror:
	li $v0, -1
	j replace1st.end

	found:
	sb $a2, ($t0)
	addi $v0, $t0, 1
	j replace1st.end

	dne:
	li $v0, 0

replace1st.end:
	jr $ra

printStringArray:
    addi $sp, $sp, -4	# Allocate memory on stack
    sw $a0, ($sp)

    blt $a3, 1, error	# Check for errors
    blt $a2, $a1, error
    bltz $a1, error
    bltz $a2, error
    bge $a1, $a3, error
    bge $a2, $a3, error

    li $t3, 4
    mul $t1, $t3, $a1	# Calculate Start Index
    add $t0, $a0, $t1
    mul $t1, $t3, $a2	# Calculate End Index
    add $t1, $a0, $t1

    printloop:			# Print Strings in array
    	bgt $t0, $t1, printloop.end
    	lw $a0, ($t0)
    	li $v0, 4
    	syscall
    	la $a0, n
    	li $v0, 4
    	syscall
    	syscall
    	addi $t0, $t0, 4
    	j printloop
    printloop.end:
    sub $v0, $a2, $a1	# Set return value
    addi $v0, $v0, 1
    j printStringArray.end

    error:
    li $v0, -1

	printStringArray.end:
	lw $a0, ($sp)		# Deallocate memory
	addi $sp, $sp, 4
    jr $ra

verifyIPv4Checksum:
    move $t0, $a0
    lbu $t1, 3($t0)		# Retrieve header length
    andi $t1, $t1, 0xf
    sll $t1, $t1, 1		# Double to retrieve num of halfwords

    li $t2, 0			# Initialize sum
    li $t7, 0
    checksumloop:
    	beq $t7, $t1, checksumloop.end
    	lhu $t3, ($t0)		# Load halfword to add
    	addu $t2, $t3, $t2
    	addi $t0, $t0, 2	# Increment to next halfword
    	addi $t7, $t7, 1
    	j checksumloop
    checksumloop.end:

    carryloop:
    	srl $t3, $t2, 16			# Retrieve carry
		beq $t3, 0, carryloop.end	# End if no carry
		andi $t2, $t2, 0xffff		# Remove carry from sum
		addu $t2, $t2, $t3			# Add carry
		j carryloop
    carryloop.end:
	
    xori $v0, $t2, -1	# Flip all the bits
    andi $v0, $v0, 0xffff

    jr $ra

##############################
# PART 2 FUNCTIONS
##############################

extractData:
    addi $sp, $sp, -36	# Allocate memory to stack
    sw $ra, ($sp)
    sw $a0, 4($sp)
    sw $s0, 8($sp)
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	sw $s3, 20($sp)
	sw $s5, 24($sp)
	sw $s7, 28($sp)
	sw $s4, 32($sp)

    li $s4, 0			# t8 = bytes read
    li $s7, 0			# t7 = packets read
    move $s0, $a0		# t0 = packets
    move $s5, $a2		# t5 = msg
    packetloop:
	    beq $s7, $a1, packetloop.end
    	move $s1, $s0		# t1 = packets[i]
    	move $a0, $s1
	    jal verifyIPv4Checksum
	    
	    bnez $v0, packet_error		# verify checksum
    	lhu $s2, 0($s1)		# Load total packet length
    	addi $s3, $s2, -20	# t3 = num characters to read
    	addi $s1, $s1, 20	# t1 = start of payload
    	li $t6, 0			# t6 = characters read
    	payloadloop:
    		beq $t6, $s3, payloadloop.end
    		lbu $t4, ($s1)		# t4 = payload[k] (character)
    		sb $t4, ($s5)		# t2[k] = t4
    		addi $t6, $t6, 1	# increment characters read
    		addi $s4, $s4, 1
    		addi $s1, $s1, 1	# increment k
    		addi $s5, $s5, 1
    		j payloadloop
    	payloadloop.end:
    	addi $s7, $s7, 1	# increment packets read
    	addi $s0, $s0, 60	# increment i
    	j packetloop
    packetloop.end:
    li $v0, 0
    move $v1, $s4
    j extractData.end

    packet_error:
    li $v0, -1
    move $v1, $s7

    extractData.end:
 	lw $s4, 32($sp)
    lw $s7, 28($sp)
    lw $s5, 24($sp)
	lw $s3, 20($sp)
    lw $s2, 16($sp)
	lw $s1, 12($sp)
	lw $s0, 8($sp)
    lw $a0, 4($sp)
    lw $ra, ($sp)		# Deallocate memory to stack
    addi $sp, $sp, 36

    jr $ra

processDatagram:
    addi $sp, $sp, -16
    sw $ra, ($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)

	blez $a1, processerror

	add $t5, $a0, $a1
	sb $0, ($t5)	# msg[m] = \0
	li $a1, 10		# Load newline character
	move $a2, $0	# Load null terminator
	move $t7, $a0
	lw $t3, 12($sp)
	li $t4, 0

	msgloop:
		move $a0, $t7
		jal replace1st
		beqz $v0, msgloop.end
		sw $t7, ($t3)
		move $t7, $v0
		addi $t3, $t3, 4
		addi $t4, $t4, 1
		j msgloop
	msgloop.end:
	beq $t5, $t7, processdone
	sw $t7, ($t3)
	addi $t4, $t4, 1

	processdone:
	move $v0, $t4
	j process.end

	processerror:
	li $v0, -1

	process.end:
	lw $a2, 12($sp)
	lw $a1, 8($sp)
	lw $a0, 4($sp)
	lw $ra, ($sp)
	addi $sp, $sp, 16

    jr $ra

##############################
# PART 3 FUNCTIONS
##############################

printDatagram:
    addi $sp, $sp, -20
    sw $ra, ($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)
    sw $a3, 16($sp)

    jal extractData
    bltz $v0, printDatagram.end
    move $s0, $v1

    move $a0, $a2
    move $a1, $v1
    move $a2, $a3
    jal processDatagram
    bltz $v0, printDatagram.end

    move $a0, $a3
    move $a1, $0
    addi $a2, $v0, -1
    move $a3, $v0
    jal printStringArray
	
	move $v0, $0

    printDatagram.end:
    lw $a3, 16($sp)
    lw $a2, 12($sp)
    lw $a1, 8($sp)
    lw $a0, 4($sp)
    lw $ra, ($sp)
    addi $sp, $sp, 20
    jr $ra

#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary

#place all data declarations here
n: .asciiz "\n"
