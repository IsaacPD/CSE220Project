# hw2_main1.asm
# This file is NOT part of your homework 2 submission.
# Any changes to this file WILL NOT BE GRADED.
#
# We encourage you to modify this file  and/or make your own mains to test different inputs

.include "hw2_examples.asm"
.include "hw2_grading.asm"

# Constants
.data
newline:  .asciiz "\n"
comma:    .asciiz ", "
testchar: .byte '9'
success: .asciiz "Success: "
bytes: .asciiz "Bytes: "
packetNumber_1: .asciiz "packet number "
packetNumber_2: .asciiz " has invalid checksum"

.text
.globl _start


####################################################################
# This is the "main" of your program; Everything starts here.
####################################################################

_start:

	##################
	# replace1st
	##################
	la $a0, FF
	li $a1, 'F'
	li $a2,	'B'
	jal replace1st

	# print return value
	move $a0, $v0
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, newline
	syscall

	##################
	# printStringArray
	##################
	la $a0, sarray_ex1
	li $a1, 3
	li $a2, 4
	li $a3, 5
	jal printStringArray

	# print return value
	move $a0, $v0
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, newline
	syscall

	##################
	# verifyIPv4Checksum
	##################
	la $a0, __checksum_invalid1
	jal verifyIPv4Checksum

	# print return value
	move $a0, $v0
	li $v0, 34
	syscall
	li $v0, 4
	la $a0, newline
	syscall

	##################
	# extractData
	##################
	la $a0, array2c
	li $a1, 4
	la $a2, msg
	jal extractData

	# print return value, sucess
	move $t0, $v0
	li $v0, 4
	la $a0, success
	syscall
	move $a0, $t0
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	beqz $t0, Print_Bytes
	li $v0, 4
	la $a0, packetNumber_1
	syscall
	li $v0, 1
	move $a0, $v1
	syscall
	li $v0, 1
	la $a0, packetNumber_2
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	j toProcessDatagram

	Print_Bytes:
		li $v0, 4
		la $a0, bytes
		syscall
		li $v0, 1
		move $a0, $v1
		syscall
		li $v0, 4
		la $a0, newline
		syscall

toProcessDatagram:
	##################
	# processDatagram
	##################
	la $a0, msg
	li $a1, 32
	la $a2, abcArray
	jal processDatagram

	# print return value
	move $a0, $v0
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, newline
	syscall

	#print abcArray addresses

	##################
	# printDatagram
	##################
	la $a0, array1
	li $a1, 1
	la $a2, msg_buffer
	la $a3, abcArray
	jal printDatagram

	# Ouptut:
	# I'm a shooting star leaping through the sky
	# Like a tiger defying the laws of gravity
	# I'm a racing car passing by like Lady Godiva
	#
	# print return value
	move $a0, $v0
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, newline
	syscall

	# Exit the program
	li $v0, 10
	syscall

###################################################################
# End of MAIN program
####################################################################


#################################################################
# Student defined functions will be included starting here
#################################################################

.include "hw2.asm"
