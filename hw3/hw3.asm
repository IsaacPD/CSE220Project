
##############################################################
# Homework #3
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
# PART 2 FUNCTIONS
##############################
extractUnorderedData:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $s0, 8($sp)
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	move $s0, $0	# s0 = k, pArray[k] = packet
	move $s1, $0	# s1 = number of beginning packets
	move $s2, $0	# s2 = number of last fragment packets
	
	blt $a1, 1, invalidPacketA		# If (n < 1) error
	
	validatePackets:
		beq $s0, $a1, validatePackets.end
		mul $t0, $s0, $a3
		add $a0, $t0, $a0
		lhu $t0, ($a0)					# Load total length
		bgt $t0, $a3, invalidPacketB	# if (total length > packetEntrySize) error
		jal verifyIPv4Checksum
		bnez $v0, invalidPacketB
		lhu $t0, 4($a0)					# Load flags and fragments for single packet
		andi $t1, $t0, 0x1fff			# t1 = fragment
		srl $t0, $t0, 13				# t0 = flags
		beq $a1, 1, singlePacket		# if n == 1
		beq $t0, 2, invalidPacketA		# if (flags == 010) invalidPacket
		
		bne $t0, 4, checkLastFrag
		bnez $t1, checkLastFrag
		addi $s1, $s1, 1
		checkLastFrag:
		bnez $t0, conditionFalse
		beqz $t1, conditionFalse
		addi $s2, $s2, 1
		conditionFalse:
		
		addi $s0, $s0, 1
		lw $a0, 4($sp)
		j validatePackets
	validatePackets.end:
	
	bne $s1, 1, invalidPacketA		# if (s1 == 1) continue else error
	beq $s1, $s2, validParray		# if (s1 == s2) success
	
	singlePacket:
	beq $t0, 2, validParray			# if (flags == 010) validPacket
	bnez $t0, invalidPacketA		# else if (flags != 0) error
	beqz $t1, validParray			# else if (fragment == 0) validPacket
	j invalidPacketA
	
	invalidPacketA:
	li $v0, -1
	li $v1, -1
	j euD.end
	
	invalidPacketB:
	li $v0, -1
	move $v1, $s0
	j euD.end
	
	validParray:
	lw $t0, 4($sp)			# t0 = packet
	move $t1, $a2			# t1 = msg
	move $t2, $0			# t2 = k, packet[k] = packet
	move $s0, $0			# s0 = bytes written
	payLoadLoop:
		beq $t2, $a1, endLoop
		mul $t3, $t2, $a3
		add $t0, $t3, $t0
		lhu $t4, ($t0)					# Load total length
		lbu $t8, 3($t0)					# Load header length
		andi $t8, $t8, 0xf
		li $v0, 4
		mul $t8, $t8, $v0
		sub $t4, $t4, $t8				# t4 = payload length = total length - (header length * 4)
		lhu $t5, 4($t0)					# Load flags and fragments for single packet
		andi $t6, $t5, 0x1fff			# t6 = fragment
		srl $t5, $t5, 13				# t5 = flags
		bne $t5, 0x2, storePayload
		move $t6, $0
		storePayload:
		add $t5, $t6, $t1				# t5 = msg[fragmentOffset]
		add $t0, $t8, $t0				# t0 = start of payload
		add $t6, $t0, $t4				# t6 = endOfPacket
		store:
			beq $t0, $t6, endStore
			lbu $t7, ($t0)
			sb $t7, ($t5)
			addi $t0, $t0, 1
			addi $t5, $t5, 1
			addi $s0, $s0, 1
			j store
		endStore:
		addi $t2, $t2, 1
		lw $t0, 4($sp)
		j payLoadLoop
	endLoop:
	move $v0, $0
	move $v1, $s0
	euD.end:
	lw $s2, 16($sp)
	lw $s1, 12($sp)
	lw $s0, 8($sp)
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20

	jr $ra

##############################
# PART 3 FUNCTIONS
##############################

printUnorderedDatagram:
	lw $s0, ($sp)
    addi $sp, $sp, -24
    sw $ra, ($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)
    sw $a3, 16($sp)
    sw $s0, 20($sp)

	move $a3, $s0
    jal extractUnorderedData
    bltz $v0, printUnorderedDatagram.end
    lw $a3, 16($sp)

    move $a0, $a2
    move $a1, $v1
    move $a2, $a3
    jal processDatagram
    bltz $v0, printUnorderedDatagram.end

    move $a0, $a3
    move $a1, $0
    addi $a2, $v0, -1
    move $a3, $v0
    jal printStringArray
	
	move $v0, $0

    printUnorderedDatagram.end:
    lw $s0, 20($sp)
    lw $a3, 16($sp)
    lw $a2, 12($sp)
    lw $a1, 8($sp)
    lw $a0, 4($sp)
    lw $ra, ($sp)
    addi $sp, $sp, 24
    jr $ra

##############################
# PART 4 FUNCTIONS
##############################

editDistance:
	addi $sp, $sp, -32
	sw $a2, ($sp)
	sw $a3, 4($sp)
	sw $ra, 8($sp)
	sw $a0, 12($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $a1, 28($sp)
	
	bltz $a2, editDistanceError
	bgez $a3, noEDError
	
	editDistanceError:
	li $v0, -1
	j endED
	
	noEDError:
	la $a0, m
	li $v0, 4
	syscall
	move $a0, $a2
	li $v0, 1
	syscall
	la $a0, nn
	li $v0, 4
	syscall
	move $a0, $a3
	li $v0, 1
	syscall
	la $a0, n
	li $v0, 4
	syscall
	
	bnez $a2, checkN	# If first string is empty, just insert n
	move $v0, $a3
	j endED
	
	checkN:				# If second string is empty, just remove m
	bnez $a3, EDRecursion
	move $v0, $a2
	j endED
	
	EDRecursion:
	lw $a0, 12($sp)
	addi $t0, $a2, -1
	addi $t1, $a3, -1
	add $t0, $a0, $t0
	lbu $t0, ($t0)
	add $t1, $a1, $t1
	lbu $t1, ($t1)
	
	bne $t0, $t1, tripleRecursion
	addi $a2, $a2, -1
	addi $a3, $a3, -1
	jal editDistance
	j endED
	
	tripleRecursion:
	addi $a3, $a3, -1
	jal editDistance	# editDistance(str1, str2, m, n-1)
	move $s0, $v0
	
	addi $a3, $a3, 1
	addi $a2, $a2, -1
	jal editDistance	# editDistance(str1, str2, m-1, n)
	move $s1, $v0
	
	addi $a3, $a3, -1
	jal editDistance	# editDistance(str1, str2, m-1, n-1)
	move $s2, $v0
	
	move $a0, $s1
	move $a1, $s2
	jal findMin
	move $a0, $s0
	move $a1, $v0
	jal findMin
	addi $v0, $v0, 1
	
	endED:
	lw $a1, 28($sp)
	lw $s2, 24($sp)
	lw $s1, 20($sp)
	lw $s0, 16($sp)
	lw $a0, 12($sp)
	lw $ra, 8($sp)
	lw $a3, 4($sp)
	lw $a2, ($sp)
	addi $sp, $sp, 32
	jr $ra

findMin:
	blt $a0, $a1, argZero
	move $v0, $a1
	jr $ra
	argZero:
	move $v0, $a0
	jr $ra

#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary

#place all data declarations here
n: .asciiz "\n"
m: .asciiz "m:"
nn: .asciiz ",n:"
