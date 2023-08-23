# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
.macro extract_nth_bit($regD, $regS, $regT) 
	li   $regD, 0x1 # Sets the LSB of $regD to 1
	srlv $t7, $regS, $regT # Shifts the bit to be extracted to LSB position
	and  $regD, $t7, $regD # Puts the bit at LSB, in $t7, at LSB of $regD
	.end_macro 
	
.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
	li    $maskReg, 0x1
	sllv  $maskReg, $maskReg, $regS
	not   $maskReg, $maskReg
	and   $maskReg, $regD, $maskReg
	sllv  $regT, $regT, $regS
	or    $regD, $regT, $maskReg
	.end_macro 
	
