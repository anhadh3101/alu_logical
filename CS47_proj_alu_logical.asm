.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# TBD: Complete it
	addi	$sp, $sp, -12
	sw      $ra, 12($sp)
	sw	$fp, 8($sp)
	addi	$fp, $sp, 12
	beq     $a2, '-', au_logical_sub
	beq     $a2, '*', au_logical_mul
	beq     $a2, '/', au_logical_div
	jal     add_logical
	j	au_logical_end
au_logical_sub:
	jal     sub_logical
	j       au_logical_end
au_logical_mul:
	jal	mul_signed
	j	au_logical_end
au_logical_div:
	jal	div_signed
au_logical_end:
	lw 	$ra, 12($sp)
	lw	$fp, 8($sp)
	addi	$sp, $sp, 12
	jr 	$ra

add_logical:
	# Storing RTE
	addi    $sp, $sp, -16
	sw      $ra, 16($sp)
	sw      $fp, 12($sp)
	sw	$a2, 8($sp)
	addi    $fp, $sp, 16
	# Body
	addi    $a2, $zero, 0x00000000 # Condition for logical add
	jal     add_sub_logical
	# Restoring RTE
	lw      $ra, 16($sp)
	lw      $fp, 12($sp)
	lw	$a2, 8($sp)
	addi    $sp, $sp, 16
	jr	$ra
	
sub_logical:
	# Storing RTE
	addi    $sp, $sp, -16
	sw      $ra, 16($sp)
	sw      $fp, 12($sp)
	sw	$a2, 8($sp)
	addi    $fp, $sp, 16
	# Body
	addi    $a2, $zero, 0xFFFFFFFF # Condition for logical sub
	jal     add_sub_logical
	# Restoring RTE
	lw      $ra, 16($sp)
	lw      $fp, 12($sp)
	lw	$a2, 8($sp)
	addi    $sp, $sp, 16
	
add_sub_logical:
# Storing RTE
	addi	$sp, $sp, -28
	sw	$ra, 28($sp)
	sw	$fp, 24($sp)
	sw      $s0, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 28
# Body
	# I = $t0		|
	# C = $t1		|
	# X = $t2		|
	# Y = $t3	     Variable 
	# Z = $t4	    Definitions
	# A[I] = $t8		|
	# B[I] = $t9		|
	# S = $s0	        |
	add	$t0, $zero, $zero # Index I = 0
	add     $s0, $zero, $zero # Sum S = 0
	extract_nth_bit($t1, $a2, $t0) # C = 0 (Addition) or C = 1 (Subtraction)
	beq	$t1, 0, add_sub_logical_loop # Checks for addition or subtraction
	not     $a1, $a1 # Subtraction condition
add_sub_logical_loop:
	extract_nth_bit($t8, $a0, $t0) # A[I] = Ith bit of $a0
	extract_nth_bit($t9, $a1, $t0) # B[I] = Ith bit of $a1
	xor     $t2, $t8, $t9 # X = A xor B
	and     $t4, $t8, $t9 # Z = A.B
	xor     $t3, $t2, $t1 # Y = X xor C
	and     $t1, $t2, $t1 # C = X.C
	or      $t1, $t1, $t4 # C = C + Z
	insert_to_nth_bit($s0, $t0, $t3, $t5) # S[I] = Y
	addi    $t0, $t0, 1 # I = I + 1
	blt     $t0, 32, add_sub_logical_loop # Loop terminating condition
	move    $v0, $s0 # Returning the result
	move	$v1, $t1
# Restore RTE
	lw	$ra, 28($sp)
	lw	$fp, 24($sp)
	lw      $s0, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi    $sp, $sp, 28
	jr	$ra
	
twos_complement:
# Storeing RTE
	addi    $sp, $sp, -20
	sw	$ra, 20($sp)
	sw	$fp, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 20
# Body
	not	$a0, $a0 # $a0 = ~$a0
	li	$a1, 1
	jal	add_logical # ~a0 + 1
# Restore RTE
	lw	$ra, 20($sp)
	lw	$fp, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	jr $ra
	
twos_complement_if_neg:
# Storing RTE
	addi 	$sp, $sp, -24
	sw	$ra, 24($sp)
	sw	$fp, 20($sp)
	sw	$a0, 16($sp)
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi	$fp, $sp, 24
# Body
	li	$s1, 31
	extract_nth_bit($s0, $a0, $s1) # $s0 = $a0[31]
	beq	$s0, 1, twos_complement_if_neg_true
	move 	$v0, $a0
	j	twos_complement_if_neg_end
twos_complement_if_neg_true:
	jal	twos_complement
# Restoring RTE
twos_complement_if_neg_end:
	lw	$ra, 24($sp)
	lw	$fp, 20($sp)
	lw	$a0, 16($sp)
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra
	
twos_complement_64bit:
# Stroing RTE
	addi 	$sp, $sp, -32
	sw	$ra, 32($sp)
	sw	$fp, 28($sp)
	sw	$a0, 24($sp)
	sw	$a1, 20($sp)
	sw	$s1, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 32
# Body
	not 	$a0, $a0 # $a0 = ~$a0
	move 	$s1, $a1 # $s1 = $a1
	li	$a1, 1 # $a1 = 1
	jal	add_logical # $v0 = ~$a0 + 1
	move 	$s6, $v0 # $s6 = $v0
	not	$a0, $s1 # $a0 = ~$s1 = ~$a1
	move 	$a1, $v1 # $a1 = C
	jal	add_logical # $v0 = ~$a1 + C
	move 	$s7, $v0 # $s7 = $v0
	move 	$v0, $s6 # $v0 = $s6
	move 	$v1, $s7 # $v1 = $s7
# Restoring RTE
	lw	$ra, 32($sp)
	lw	$fp, 28($sp)
	lw	$a0, 24($sp)
	lw	$a1, 20($sp)
	lw	$s1, 16($sp)
	lw	$s6, 12($sp)
	lw 	$s7, 8($sp)
	addi	$sp, $sp, 32
	jr 	$ra
	
bit_replicator:
# Storing RTE
	addi 	$sp, $sp, -12
	sw	$ra, 12($sp)
	sw	$fp, 8($sp)
	addi	$fp, $sp, 12
# Body
	beqz 	$a0, bit_replicator_zero
	li 	$v0, 0xFFFFFFFF
	j	bit_replicator_end
bit_replicator_zero:
	li 	$v0, 0x00000000
# Restoring RTE 
bit_replicator_end:
	lw	$ra, 12($sp)
	lw	$fp, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra
	
mul_unsigned:
# Storing RTE
	addi	$sp, $sp, -48
	sw	$ra, 48($sp)
	sw	$fp, 44($sp)
	sw	$a0, 40($sp)
	sw	$a1, 36($sp)
	sw	$s0, 32($sp)
	sw	$s1, 28($sp)
	sw	$s2, 24($sp)
	sw	$s3, 20($sp)
	sw	$s4, 16($sp)
	sw	$s5, 12($sp)
	sw	$s6, 8($sp)
	addi	$fp, $sp, 48
# Body
	# I = $s0		|
	# L = $s1		|
	# H = $s2		|
	# M = $s3	Variable Definitions
	# R = $s4		|
	# X = $s5		|
	# H[0] = $s6		|
	li 	$s0, 0 # I = 0
	li 	$s2, 0 # H = 0
	move 	$s1, $a1 # L = MPLR
	move 	$s3, $a0 # M = MCND
mul_unsigned_loop:
	extract_nth_bit($a0, $s1, $zero) # $a0 = $a1[0]
	jal	bit_replicator # $v0 = {32(l[0])}
	move 	$s4, $v0 # R = {32(L[0])}
	and 	$s5, $s3, $s4 # X = M.R
	move 	$a0, $s2 # $a0 = H
	move 	$a1, $s5 # $a1 = X
	jal 	add_logical # $v0 = H + X
	move 	$s2, $v0
	srl	$s1, $s1, 1 # L = L >> 1
	extract_nth_bit($s6, $s2, $zero) # $s6 = H[0]
	li	$t0, 31
	insert_to_nth_bit($s1, $t0, $s6, $t1) # L[31] = H[0]
	srl	$s2, $s2, 1 # H = H >> 1
	addi 	$s0, $s0, 1 # I = I + 1
	blt	$s0, 32, mul_unsigned_loop
	move 	$v0, $s1 # $v0 = Lo
	move 	$v1, $s2 # $v1 = Hi
# Restoring RTE
	lw	$ra, 48($sp)
	lw	$fp, 44($sp)
	lw	$a0, 40($sp)
	lw	$a1, 36($sp)
	lw	$s0, 32($sp)
	lw	$s1, 28($sp)
	lw	$s2, 24($sp)
	lw	$s3, 20($sp)
	lw	$s4, 16($sp)
	lw	$s5, 12($sp)
	lw	$s6, 8($sp)
	addi	$sp, $sp, 48
	jr	$ra
	
mul_signed:
# Storing RTE
	addi 	$sp, $sp, -40
	sw	$ra, 40($sp)
	sw	$fp, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$s3, 12($sp)
	sw	$s4, 8($sp)
	addi	$fp, $sp, 40
# Body
	move	$s0, $a0 # $s0 = $a0
	move 	$s1, $a1 # $s1 = $a1
	jal	twos_complement_if_neg # if $a0 < 0, $v0 = ~$a0 + 1
	move 	$s3, $v0 # $s3 = $v0
	move 	$a0, $a1
	jal	twos_complement_if_neg # if $a1 < 0, $v0 = ~$a1 + 1
	move	$s4, $v0 # $s4 = $v0
	move	$a0, $s3
	move 	$a1, $s4
	jal	mul_unsigned # $v1 + $v0 = $a0 * $a1
	li	$s2, 31
	extract_nth_bit($t8, $s0, $s2) # $t8 = $a0[31]
	extract_nth_bit($t9, $s1, $s2) # $t9 = $a1[31]
	xor	$s2, $t8, $t9 # $s2 = $t8 xor $t9
	beqz	$s2, mul_signed_end
	move	$a0, $v0
	move	$a1, $v1
	jal	twos_complement_64bit
# Restoring RTE
mul_signed_end:
	lw	$ra, 40($sp)
	lw	$fp, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$s0, 24($sp)
	lw	$s1, 20($sp)
	lw	$s2, 16($sp)
	lw	$s3, 12($sp)
	lw	$s4, 8($sp)
	addi	$sp, $sp, 40
	jr	$ra
	
div_unsigned:
# Storing RTE
	addi 	$sp, $sp, -36
	sw	$ra, 36($sp)
	sw	$fp, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	addi	$fp, $sp, 36
# Body
	# Q = $s0
	# R = $s1
	# I = $s2
	# D = $s3
	li	$s2, 0 # I = 0
	move	$s0, $a0 # Q = Dividend
	li	$s1, 0	 # R = 0
	move 	$s3, $a1 # D = Divisor
div_unsigned_loop:
	sll	$s1, $s1, 1 # R = R << 1
	li	$t0, 31
	extract_nth_bit($t1, $s0, $t0) # $t1 = Q[31]
	insert_to_nth_bit($s1, $zero, $t1, $t2) # R[0] = Q[31]
	sll	$s0, $s0, 1 # Q = Q << 1
	move 	$a0, $s1 # $a0 = R
	move 	$a1, $s3 # $a1 = D
	jal	sub_logical # $v0 = S = R - D
	li	$t0, 31
	extract_nth_bit($t1, $v0, $t0) # $t1 = S[0]
	beq	$t1, 1, div_unsigned_rem_negative
	move 	$s1, $v0 # R = S
	li 	$t1, 1
	insert_to_nth_bit($s0, $zero, $t1, $t2) # Q[0] = 1
div_unsigned_rem_negative:
	addi	$s2, $s2, 1 # I = I + 1
	blt	$s2, 32, div_unsigned_loop
	move	$v0, $s0 # $v0 = Q
	move	$v1, $s1 # $v1 = R
# Restoring RTE
	lw	$ra, 36($sp)
	lw	$fp, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	addi	$sp, $sp, 36
	jr	$ra
	
div_signed:
# Storing RTE
	addi 	$sp, $sp, -44
	sw	$ra, 44($sp)
	sw	$fp, 40($sp)
	sw	$a0, 36($sp)
	sw	$a1, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 44
# Body
	move	$s0, $a0 # $s0 = $a0
	move	$s1, $a1 # $s1 = $a1
	jal	twos_complement_if_neg
	move 	$s2, $v0 # $s2 = |$a0|
	move 	$a0, $s1
	jal	twos_complement_if_neg
	move 	$s3, $v0 # $s3 = |$a1|
	move	$a0, $s2
	move	$a1, $s3
	jal 	div_unsigned # |$a0| / |$a1|
	move 	$s6, $v0 # $s6 = |Q|
	move	$s7, $v1 # $s7 = |R|
	li	$t2, 31
	extract_nth_bit($t0, $s0, $t2) # $t0 = $a0[31]
	extract_nth_bit($t1, $s1, $t2) # $t1 = $a1[31]
	xor	$t3, $t0, $t1 # $t3 = $a0[31] xor $a1[31]
	beqz	$t3, div_signed_positive_div
	move	$a0, $s6
	jal	twos_complement
	move	$s6, $v0 # $s6 = Q 
div_signed_positive_div:
	li	$t2, 31
	extract_nth_bit($t0, $s0, $t2) # $t0 = $a0[31]
	beqz	$t0, div_signed_end
	move	$a0, $s7
	jal	twos_complement
	move	$s7, $v0 # $s7 = ~R
div_signed_end:
	move	$v0, $s6
	move 	$v1, $s7
# Restoring RTE
	lw	$ra, 44($sp)
	lw	$fp, 40($sp)
	lw	$a0, 36($sp)
	lw	$a1, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 44
	jr	$ra
