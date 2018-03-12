# Homework #1
# Name: Isaac Duarte
# Net ID: iduarte
# SBU ID: 111026940

.data

# include the file with the test case information
.include "Header1.asm" #change this line to test with other inputsz
.align 2
	numargs: .word 0
	AddressOfIPDest3: .word 0
	AddressOfIPDest2: .word 0
	AddressOfIPDest1: .word 0
	AddressOfIPDest0: .word 0
	AddressOfBytesSent: .word 0
	AddressOfPayload: .word 0
	
	Err_string: .asciiz "ERROR\n"
	newline: .asciiz "\n"
	wrongversion: .asciiz "Unsupported:IPv"
	rightversion: .asciiz "IPv4\n"

# Helper macro for accessing command line arguments via label
.macro load_args
	sw $a0, numargs
	lw $t0, 0($a1)
	sw $t0, AddressOfIPDest3
	lw $t0, 4($a1)
	sw $t0, AddressOfIPDest2
	lw $t0, 8($a1)
	sw $t0, AddressOfIPDest1
	lw $t0, 12($a1)
	sw $t0, AddressOfIPDest0
	lw $t0, 16($a1)
	sw $t0, AddressOfBytesSent
	lw $t0, 20($a1)
	sw $t0, AddressOfPayload
.end_macro

.macro atoi(%x)
	lw $a0, %x
	li $v0, 84
	syscall
.end_macro

.macro print_character(%x)
	.data
	char: .asciiz %x
	
	.text
	la $a0, char
	li $v0, 4
	syscall
.end_macro

.text
.globl main
main:
	load_args() 		# Only do this once
	li $t0, 6
	beq $t0, $a0, noerror	# Check if number of arguments is 6
	
error:	
	la $a0, Err_string
	li $v0, 4
	syscall
	li $v0, 10
	syscall

noerror:
	atoi(AddressOfIPDest3) 	# Validate Numeric String
	bne $v1, $0, error	# Check if success
	blt $v0, 0, error	# Check if within valid range
	bgt $v0, 255, error
	move $t3, $v0		# t3 = IPDest3
	atoi(AddressOfIPDest2)
	bne $v1, $0, error
	blt $v0, 0, error
	bgt $v0, 255, error
	move $t2, $v0		# t2 = IPDest2
	atoi(AddressOfIPDest1)
	bne $v1, $0, error
	blt $v0, 0, error
	bgt $v0, 255, error
	move $t1, $v0		# t1 = IPDest1
	atoi(AddressOfIPDest0)
	bne $v1, $0, error
	blt $v0, 0, error
	bgt $v0, 255, error
	move $t0, $v0		# t0 = IPDest0
	atoi(AddressOfBytesSent)
	bgt $v0, 255, error
	bge $v0, 8192, error	# error if BytesSent >= 2^13
	ble $v0, -2, error	# error if BytesSent <= -2
	beq $v0, -1, success	# Skip if equal to -1
	li $t7, 8		# x = 8
	div $v0, $t7		# BytesSent/8 = lo; BytesSent%8 = hi;
	mfhi $t7		# x = hi
	bne $t7, $0, error	# error if x != 0
success:
	move $t4, $v0		# t4 = BytesSent
	la $t7, Header		# t7 = Header address
	lbu $t6, 3($t7)		# load 3rd byte from header
	srl $t6, $t6, 4		# extract 4 bits for version
	beq $t6, 4, rightv

wrongv: 
	la $a0, wrongversion	# Print "Unsupported:IPv"
	li $v0, 4
	syscall
	move $a0, $t6		# Print 8 bit version in $t6
	li $v0, 1
	syscall
	print_character("\n")
	lbu $t6, 3($t7)
	andi $t6, $t6, 0x0000000f	# Save header length and remove version
	ori $t6, $t6, 0x00000040	# Set version to 4
	sb $t6, 3($t7)		# Store version number along with original header length
	j continue
	
rightv:
	la $a0, rightversion	# Print "IPv4\n"
	li $v0, 4
	syscall

continue:
	lbu $a0, 2($t7)		# Print type of service
	li $v0, 1
	syscall
	print_character(",")
	lhu $a0, 6($t7)		# Print identifier
	li $v0, 1
	syscall
	print_character(",")
	lbu $a0, 11($t7)	# Print time to live
	li $v0, 1
	syscall
	print_character(",")
	lbu $a0, 10($t7)	# Print protocol
	li $v0, 1
	syscall
	print_character("\n")	
	lbu $a0, 15($t7)	# Start printing Source IPAddress
	li $v0, 1
	syscall
	print_character(".")
	lbu $a0, 14($t7)
	li $v0, 1
	syscall
	print_character(".")
	lbu $a0, 13($t7)
	li $v0, 1
	syscall
	print_character(".")
	lbu $a0, 12($t7)
	li $v0, 1
	syscall			# End printing Source IPAddress
	print_character("\n")	
	sb $t3, 19($t7)		# Start storing Dest IPAddress
	sb $t2, 18($t7)
	sb $t1, 17($t7)
	sb $t0, 16($t7)		# End storing Dest IPAddress
	lw $a0, 16($t7)
	li $v0, 34		# Print Dest IPAddress in Hex
	syscall
	print_character("\n")

	lw $t0, AddressOfPayload
payloadloop:
	lbu $t1, ($t0)		# Load character (byte) from payload
	beq $t1, $0, endloop	# Check if character is null terminator (0), break if true
	addiu $s0, $s0, 1	# Increment counter
	addiu $t0, $t0, 1	# Move to next byte
	j payloadloop
endloop:
	move $s3, $s0
	lbu $t1, 3($t7)		# Load byte containing Header Length field
	andi $t1, $t1, 0x0000000f	# Extract Header Length field
	move $s7, $t1		# Store header value for later
	li $v0, 4
	mul $v0, $v0, $s7
	addu $s0, $s0, $v0	# Add header length to the number of bytes in Payload
	sh $s0, 0($t7)		# Store header length + payload length in total length
	lhu $t1, 4($t7)
	srl $t2, $t1, 13	# Extract flags
	move $a0, $t2
	li $v0, 35		# Print flags in binary
	syscall
	print_character(",")
	andi $a0, $t1, 0x00001fff	# Extract fragment offset
	li $v0, 35		# Print fragment offset in binary
	syscall
	print_character("\n")
	beq $t4, $0, equal0
	beq $t4, -1, negative

greaterthan0:
	addi $t2, $0, 4		# Set flags to 4
	sll $t2, $t2, 13	# Shift to correct position within 16 bits
	addu $t2, $t2, $t4	# Combine with bytes sent
	sh $t2, 4($t7)		# Store new flags and fragment offset value
	j part7

equal0:
	sh $0, 4($t7)		# Set flags and fragment Offset to 0
	j part7

negative:
	addi $t2, $0, 2		# Set flags to 010 and Fragment Offset to 0
	sll $t2, $t2, 13
	sh $t2, 4($t7)

part7:
	li $t2, 4		# x = 4
	mul $t2, $s7, $t2	# t2 = header length* 4
	add $t2, $t2, $t7	# t2 = header + header length * 4
	lw $t0, AddressOfPayload
	
storepayloadloop:
	lb $s2, ($t0)		# Extract character (byte) of payload
	sb $s2, ($t2)		# Store character after IPHeader
	addi $t0, $t0, 1	# Increment to next character (byte) of payload
	addi $t2, $t2, 1	# Increment to next byte after IPHeader
	addi $s3, $s3, -1	# Decrement number of characters (byte) left
	beq $s3, 0, endstoring	# If no characters left break
	j storepayloadloop
endstoring:
	la $a0, Header		# Print the start of the IPPacket
	li $v0, 34
	syscall
	print_character(",")
	move $a0, $t2		# Print the end of the IPPacket
	li $v0, 34
	syscall
	print_character("\n")
	
	la $t1, Header		# Load header
	lb $t6, 3($t1)		# Load header length to calculate limit
	andi $t6, $t6, 0x0000000f
	sll $t6, $t6, 1
	move $t3, $t1		# Load temporary header for counting and incrementing
	move $s0, $0		# Initialize sum
	addi $t5, $0,  4	# Initialize half word address to exclude
	move $t4, $0
	
sumloop:			# Add hex values to calculate checksum, exclude original checksum
	beq $t4, $t6, sumloop.end
	beq $t4, $t5, incr
	lhu $t2, ($t3)
	addu $s0, $s0, $t2
incr:	addi $t3, $t3, 2
	addi $t4, $t4, 1
	j sumloop
sumloop.end:#

checksumloop:
	srl $t2, $s0, 16	# Retrieve carry
	beq $t2, 0, endprogram	# End if no carry
	andi $s0, $s0, 0x0000ffff	# Remove carry from sum
	addu $s0, $s0, $t2	# Add carry
	j checksumloop
	
endprogram:
	xori $s0, $s0, -1	# Flip all the bits
	sh $s0, 8($t1)
	li $v0, 10		# Terminate the program (END)
	syscall
