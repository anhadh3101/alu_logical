.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
# TBD: Complete it
	addi	$sp, $sp, -12
	sw      $ra, 12($sp)
	sw	$fp, 8($sp)
	addi	$fp, $sp, 12
	beq     $a2, '-', au_normal_subtract  # Checks for subtraction
	beq     $a2, '*', au_normal_multiply  # Checks for multiplication 
	beq     $a2, '/', au_normal_divide    # Checks for division
	
	add     $v0, $a0, $a1		      # Body of addition operation
	j       au_normal_end
	
au_normal_subtract:			      # Body of subtraction operation
	sub     $v0, $a0, $a1
	j       au_normal_end
	
au_normal_multiply:			      # Body of multipication operation
	mul     $v0, $a0, $a1
	mfhi    $v1
	j       au_normal_end
	
au_normal_divide:			      # Body of dividion operation
	div     $a0, $a1
	mflo    $v0
	mfhi    $v1 
au_normal_end:
	lw      $ra, 12($sp)
	lw	$fp, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra
