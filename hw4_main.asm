.data
.macro print_int(%s)
	move $a0, %s
	li $v0, 1
	syscall
	li $a0, 10
	li $v0, 11
	syscall
.end_macro

.text
.globl _main

_main:
	li $t0, 2
	li $t1, 3
	li $a0, 0xffff0000
	li $a1, 4
	li $a2, 4
	li $a3, 1
	addi $sp, $sp, -12
	sw $a3, ($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	jal start_game
	print_int($v0)
	addi $sp, $sp, 12
	
	li $a0, 0xffff0000
	li $a1, 4
	li $a2, 4
	li $v0, 0
	game:
		li $v0, 12
		syscall
		move $a3, $v0
		jal user_move
		bnez $v0, gameend
		move $t0, $a0
		addi $sp, $sp, -4
    	addi $a3, $a1, -1
	    sw $a2, 0($sp)
	    jal calc2d_address
    	li $t5, 0
    	li $t6, 0
		find_empty:
			beq $t0, $v0, empty_end
			lh $t1, 0($t0)
			bne $t1, -1, continue_find
			bnez $t5, check_6
			move $t5, $t0
			j continue_find
			check_6:
			bnez $t6, empty_end
			move $t6, $t0
			continue_find:
			addi $t0, $t0, 2
			j find_empty
		empty_end:
		li $t0, 2
		beqz $t5, continue
		sh $t0, 0($t5)
		beqz $t6, continue
		sh $t0, 0($t6)
		continue:
		li $v0, 0
		j game
	gameend:
	
	li $v0, 10
	syscall
	
.include "hw4.asm"
