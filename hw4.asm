
##############################################################
# Homework #4
# name: Isaac Duarte
# sbuid: 111026940
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################

error:
	li $v0, -1
	jr $ra

clear_board:    
    blt $a1, 2, error
    blt $a2, 2, error
    
    addi $sp, $sp, -12
    sw $a3, 8($sp)
    addi $a3, $a1, -1
    sw $a2, 0($sp)
    sw $ra, 4($sp)
    jal calc2d_address
    lw $ra, 4($sp)
    lw $a3, 8($sp)
    addi $sp, $sp, 12
    
    move $t1, $v0
    move $t0, $a0
    li $t2, -1
    clear_loop:
	    beq $t0, $t1, clear_loop_end
    	sh $t2, 0($t0)
    	addi $t0, $t0, 2
    	j clear_loop
    clear_loop_end:
    
    li $v0, 0
	jr $ra

place:
	sw $ra, -4($sp)
    jal calc2d_address
    lw $ra, -4($sp)
    lw $t0, 4($sp)
    lw $t1, 0($sp)
    
    blt $a1, 2, error
    blt $a2, 2, error
    bltz $a3, error
    bge $a3, $a1, error
    bltz $t1, error
    bge $t1, $a2, error
    beq $t0, -1, valid_place
    li $t5, 0
	li $t6, 1
	count_loop:
		beq $t6, 4096, loop_end
		bgt $t5, 1, loop_end
		and $t4, $t6, $t0
		beqz $t4, no_add
		addi $t5, $t5, 1
		no_add:
		sll $t6, $t6, 1
		j count_loop
	loop_end:
	bne $t5, 1, error
	blt $t0, 2, error
    
    valid_place:
    sh $t0, 0($v0)
    li $v0, 0
    jr $ra

start_game:
	blt $a1, 2, error
    blt $a2, 2, error
	
	lw $t1, 0($sp)    
    bltz $a3, error
    bge $a3, $a1, error
    bltz $t1, error
    bge $t1, $a2, error
    
    lw $t1, 8($sp)
    lw $t2, 4($sp)
    bltz $t2, error
    bge $t2, $a1, error
    bltz $t1, error
    bge $t1, $a2, error
	
	addi $sp, $sp, -12
	sw $ra, 8($sp)
    jal clear_board
    lw $t0, 12($sp)
    sw $t0, 0($sp)
    li $t0, 2
    sw $t0, 4($sp)
    jal place
    lw $a3, 16($sp)
    lw $t0, 20($sp)
    sw $t0, 0($sp)
    jal place
    lw $ra, 8($sp)
    li $v0, 0
    jr $ra

##############################
# PART 2 FUNCTIONS
##############################

merge_row:
	blt $a1, 2, error
    blt $a2, 2, error
    bltz $a3, error
    bge $a3, $a1, error
    
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a2, 0($sp)
    jal calc2d_address
    lw $ra, 4($sp)
    addi $sp, $sp, 8
	
	li $t1, 2			# t1 = object size
    mul $t2, $a2, $t1	# t2 = n_cols & object size = row_size
    mul $t2, $t2, $a3	# t2 = row_size * row
    add $t0, $a0, $t2
	
    lw $t2, 0($sp)
    beq $t2, 1, r_to_l
    beq $t2, 0, l_to_r
    j error
    l_to_r:
    	lh $t2, 0($t0)
    	addi $t0, $t0, 2
    	beq $t0, $v0, r_loop_end
    	beq $t2, -1, l_to_r
    	lh $t3, 0($t0)
    	bne $t2, $t3, l_to_r
    	li $t2, -1
    	sh $t2, -2($t0)
    	sll $t3, $t3, 1
    	sh $t3, 0($t0)
    	j l_to_r
    r_to_l:
    addi $v0, $v0, -2
    addi $t0, $t0, -2
    r_loop:
    	lh $t3, 0($v0)
    	addi $v0, $v0, -2
    	beq $t0, $v0, r_loop_end
    	beq $t3, -1, r_loop
    	lh $t2, 0($v0)
    	bne $t2, $t3, r_loop
    	li $t2, -1
    	sh $t2, 2($v0)
    	sll $t3, $t3, 1
    	sh $t3, 0($v0)
    	j r_loop
    r_loop_end:
    li $v0, 0
    jr $ra

merge_col:
    blt $a1, 2, error
    blt $a2, 2, error
    bltz $a3, error
    bge $a3, $a2, error
    
    addi $sp, $sp, -12
    sw $a3, 8($sp)
    sw $a3, 0($sp)
    move $a3, $a1
    sw $ra, 4($sp)
    jal calc2d_address
    lw $ra, 4($sp)
    lw $a3, 8($sp)
    addi $sp, $sp, 12
    
    li $t1, 2			# t1 = object size
    mul $t4, $a2, $t1	# t2 = n_cols & object size = row_size
    mul $t3, $t1, $a3	# t3 = obj_size * col
    add $t0, $t3, $a0
    
    lw $t2, 0($sp)
    beq $t2, 0, b_to_t
    beq $t2, 1, t_to_b
    j error
    b_to_t:
    	lh $t2, 0($t0)
    	add $t0, $t0, $t4
    	beq $t0, $v0, top_loop_end
    	beq $t2, -1, b_to_t
    	lh $t3, 0($t0)
    	bne $t2, $t3, b_to_t
    	li $t2, -1
    	sub $t0, $t0, $t4
    	sh $t2, 0($t0)
    	add $t0, $t0, $t4
    	sll $t3, $t3, 1
    	sh $t3, 0($t0)
    	j b_to_t
    t_to_b:
    sub $v0, $v0, $t4
    sub $t0, $t0, $t4
    top_loop:
    	lh $t2, 0($v0)
    	sub $v0, $v0, $t4
    	beq $t0, $v0, top_loop_end
    	beq $t2, -1, top_loop
    	lh $t3, 0($v0)
    	bne $t2, $t3, top_loop
    	li $t2, -1
    	add $v0, $v0, $t4
    	sh $t2, 0($v0)
    	sub $v0, $v0, $t4
    	sll $t3, $t3, 1
    	sh $t3, 0($v0)
    	j top_loop
    top_loop_end:
    li $v0, 0
    jr $ra

shift_row:
    blt $a1, 2, error
    blt $a2, 2, error
    bltz $a3, error
    bge $a3, $a1, error
    
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a2, 0($sp)
    jal calc2d_address
    lw $ra, 4($sp)
    addi $sp, $sp, 8
	
	li $t7, -1
	li $t1, 2			# t1 = object size
    mul $t2, $a2, $t1	# t2 = n_cols & object size = row_size
    mul $t2, $t2, $a3	# t2 = row_size * row
    add $t3, $a0, $t2
    addi $t0, $t3, 2
    addi $t5, $t3, -2
	
    lw $t2, 0($sp)
    beq $t2, 0, shift_l
    beq $t2, 1, shift_r
    j error
    shift_l:
    	beq $t0, $v0, shift_r_end
    	lh $t2, 0($t0)
    	beq $t2, -1, left_shift_end
    	addi $t4, $t0, -2
    	left_shift:
    		beq $t4, $t5, left_shift_end
    		lh $t6, 0($t4)
    		addi $t4, $t4, -2
    		bne $t6, -1, left_shift_end
    		sh $t2, 2($t4)
    		sh $t7, 4($t4)
    		j left_shift
    	left_shift_end:
    	addi $t0, $t0, 2
    	j shift_l
    shift_r:
    move $t0, $v0
    addi $v0, $v0, -4
    shift_r_loop:
    	beq $t5, $v0, shift_r_end
    	lh $t2, 0($v0)
    	beq $t2, -1, right_shift_end
    	addi $t4, $v0, 2
    	right_shift:
    		beq $t4, $t0, right_shift_end
    		lh $t6, 0($t4)
    		addi $t4, $t4, 2
    		bne $t6, -1, right_shift_end
    		sh $t2, -2($t4)
    		sh $t7, -4($t4)
    		j right_shift
    	right_shift_end:
    	addi $v0, $v0, -2
    	j shift_r_loop
    shift_r_end:
    li $v0, 0
    jr $ra


shift_col:
    blt $a1, 2, error
    blt $a2, 2, error
    bltz $a3, error
    bge $a3, $a2, error
    
    blt $a1, 2, error
    blt $a2, 2, error
    bltz $a3, error
    bge $a3, $a2, error
    
    addi $sp, $sp, -12
    sw $a3, 8($sp)
    sw $a3, 0($sp)
    move $a3, $a1
    sw $ra, 4($sp)
    jal calc2d_address
    lw $ra, 4($sp)
    lw $a3, 8($sp)
    addi $sp, $sp, 12
    
    li $t1, 2			# t1 = object size
    li $t7, -1
    mul $t8, $a2, $t1	# t8 = n_cols & object size = row_size
    mul $t3, $t1, $a3	# t3 = obj_size * col
    add $t3, $t3, $a0
    add $t0, $t3, $t8
    sub $t5, $t3, $t8
    
    lw $t2, 0($sp)
    beq $t2, 0, shift_up
    beq $t2, 1, shift_down
    j error
    shift_up:
    	beq $t0, $v0, shift_down_end
    	lh $t2, 0($t0)
    	beq $t2, -1, up_shift_end
    	sub $t4, $t0, $t8
    	up_shift:
    		beq $t4, $t5, up_shift_end
    		lh $t6, 0($t4)
    		sub $t4, $t4, $t8
    		bne $t6, -1, up_shift_end
    		add $t4, $t4, $t8
    		sh $t2, 0($t4)
    		add $t4, $t4, $t8
    		sh $t7, 0($t4)
    		sub $t4, $t4, $t8
    		sub $t4, $t4, $t8
    		j up_shift
    	up_shift_end:
    	add $t0, $t0, $t8
    	j shift_up
    shift_down:
    move $t0, $v0
    sub $v0, $v0, $t8
    sub $v0, $v0, $t8
    shift_down_loop:
    	beq $t5, $v0, shift_down_end
    	lh $t2, 0($v0)
    	beq $t2, -1, down_shift_end
    	add $t4, $v0, $t8
    	down_shift:
    		beq $t4, $t0, down_shift_end
    		lh $t6, 0($t4)
    		add $t4, $t4, $t8
    		bne $t6, -1, down_shift_end
    		sub $t4, $t4, $t8
    		sh $t2, 0($t4)
    		sub $t4, $t4, $t8
    		sh $t7, 0($t4)
    		add $t4, $t4, $t8
    		add $t4, $t4, $t8
    		j down_shift
    	down_shift_end:
    	sub $v0, $v0, $t8
    	j shift_down_loop
    shift_down_end:
    li $v0, 0
    jr $ra

check_state:
    addi $sp, $sp, -12
    sw $a3, 8($sp)
    addi $a3, $a1, -1
    sw $a2, 0($sp)
    sw $ra, 4($sp)
    jal calc2d_address
    lw $ra, 4($sp)
    lw $a3, 8($sp)
    addi $sp, $sp, 12
    
    move $t1, $v0
    move $t0, $a0
    li $t3, 0
    check_win:
	    beq $t0, $t1, check_win_end
	    lh $t2, 0($t0)
	    addi $t0, $t0, 2
	    bne $t2, -1, win
	    addi $t3, $t3, 1
	    win:
	    blt $t2, 2048, check_win
	    li $v0, 1
	    jr $ra
    check_win_end:
    
    beqz $t3, check_loss
    li $v0, 0
    jr $ra
    
    check_loss:
    move $t0, $a0
    li $t6, 0	# t6 = current row
    li $t7, 0	# t7 = current column
    check_merge_loop:
    	beq $t0, $t1, check_merge_end
    	lh $t2, 0($t0)		# check horizontal merge
    	lh $t3, 2($t0)
    	addi $t5, $t7, 1
    	beq $t5, $a2, check_vertical	# if (j+1 = num_cols) check vertical
    	bne $t2, $t3, check_vertical	# if (board[i][j] == board[i][j+1]) continue game
    	li $v0, 0
    	jr $ra
    	check_vertical:
    	li $t3, 2			# t3 = object size
    	mul $t3, $a2, $t3	# t3 = n_cols & object size = row_size
    	add $t3, $t3, $t0	
    	lh $t3, 0($t3)		# t3 = board[i+1][j]
    	addi $t5, $t6, 1
    	beq $t5, $a2, continue_merge_loop	#if (i+1 = num_rows) continue loop
    	bne $t2, $t3, continue_merge_loop	# if (board[i][j] == board[i+1][j]) continue game
    	li $v0, 0
    	jr $ra
    	continue_merge_loop:
    	addi $t0, $t0, 2
    	addi $t7, $t7, 1
    	bne $t7, $a1, check_merge_loop	# if (col = num_cols) increment row
    	li $t7, 0
    	addi $t6, $t6, 1
    	j check_merge_loop
    check_merge_end:
    
    continue_game:
    li $v0, -1
    jr $ra

user_move:
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	move $s0, $0
	
    beq $a3, 76, left
    beq $a3, 82, right
    beq $a3, 85, up
    beq $a3, 68, down
    user_move_error:
    li $v0, -1
    li $v1, -1
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra
    
    left:
    li $a3, 0
    sw $a3, 0($sp)
    j move_rows
    right:
    li $a3, 1
    sw $a3, 0($sp)
    move_rows:
    	beq $s0, $a1, check_if_win
    	move $a3, $s0
    	jal shift_row
    	beq $v0, -1, user_move_error
    	jal merge_row
    	beq $v0, -1, user_move_error
    	jal shift_row
    	beq $v0, -1, user_move_error
    	addi $s0, $s0, 1
    	j move_rows
    
    up:
    li $a3, 0
    sw $a3, 0($sp)
    j move_cols
    down:
    li $a3, 1
    sw $a3, 0($sp)
    move_cols:
    	beq $s0, $a2, check_if_win
    	move $a3, $s0
    	jal shift_col
    	beq $v0, -1, user_move_error
    	jal merge_col
    	beq $v0, -1, user_move_error
    	jal shift_col
    	beq $v0, -1, user_move_error
    	addi $s0, $s0, 1
    	j move_cols
    
    check_if_win:
    jal check_state
    beq $v0, -1, user_move_error
    move $v1, $v0
    li $v0, 0
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra
    
##############################
# HELPER FUNCTIONS
##############################
calc2d_address: # a0 = cell[][] board, a1 = num_rows, a2 = num_cols, a3 = i, a4 = j
	lw $t4, 0($sp)
	li $t1, 2			# t1 = object size
    mul $t2, $a2, $t1	# t2 = n_cols & object size = row_size
    mul $t2, $t2, $a3	# t2 = row_size * i
    mul $t3, $t1, $t4	# t3 = obj_size * j
    add $t2, $t2, $t3	# t2 = offset of address
    add $v0, $a0, $t2	# v0 = board[i][j]
	jr $ra
	
#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary

#place all data declarations here


