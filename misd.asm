# File Name : misd.asm
# Author    : Elliott Gorman
# Created   : 11/15/2020
#
# Modification History:
#	None
#
# main:
#	Uses the procedures and macros listed below to read input_file containing
#	lines of 32 byte MIPS32 instructions, decode them, and 
#	print them to the console and output them to a output_file.
#
# PROCEDURES: 
# 	decodeInstr   : Decodes a 32 bit MIPS instruction into a string and places the string into a given address.
# 	copyString    : Copies a string from one memory address to another
# 	readNext32    : Reads 32 bytes from a file containing 32 byte strings of binary MIPS instructions
# 	openFile      : Opens a file and returns its descriptor
# 	closeFile     : Closes an open file
# 	str_to_dec    : Converts a binary or Hexadecimal ASCII string to decimal
# 	int_to_str    : Converts an integer to a string
# 	reverseString : Reverses a string at a given address
# 	exponentiate  : Calculates a0^a1
# 	clearBytes    : Sets memory location to all \0 until a \0 is found
# 	strLength     : Gets the length of a string
#
# MACROS:
# 	setVarI             : places immediate of %value into %varName (a variable label)
# 	setVar              : Saves %reg to %varName
# 	getVar              : Gets word at %varName (a variable label) in $v0
# 	print               : Print any given string
# 	printcomma          : Prints a comma
# 	printspace          : Prints a space
# 	println             : Prints a new line
# 	insertcomma         : inserts a comma at a given address
# 	insertspace         : inserts a space at a given address
# 	insertCommaAndSpace : inserts a space and comma at address
# 	getStringFromOffset : Gets the MIPS instruction format string equivalent of some %bitValue
# 	getBitsInRange      : Gets the value of some bits in a range [upperBit : lowerBit]
# 	getBitAt            : Gets the value of some bit at a specific location
# 	INT_TO_STRING       : Macro for int_to_string procedure
# 	COPYSTRING          : Macro for copyString Procedure


# ------------------------------------------------------- DATA SECTION ------------------------------------------------------- #
							     .data

# LOOKUP TABLES
registers               : .asciiz "$zero", "$at", "$v0", "$v1", "$a0", "$a1", "$a2", "$a3", "$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6", "$t7", "$s0", "$s1", "$s2", "$s3", "$s4", "$s5", "$s6", "$s7", "$t8", "$t9", "$k0", "$k1", "$gp", "$sp", "$fp", "$ra"
registers_off           : .half   0, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58, 62, 66, 70, 74, 78, 82, 86, 90, 94, 98, 102, 106, 110, 114, 118, 122, 126
registers_cop1		: .asciiz "$f0", "$f1", "$f2", "$f3", "$f4", "$f5", "$f6", "$f7", "$f8", "$f9", "$f10", "$f11", "$f12", "$f13", "$f14", "$f15", "$f16", "$f17", "$f18", "$f19", "$f20", "$f21", "$f22", "$f23", "$f24", "$f25", "$f26", "$f27", "$f28", "$f29", "$f30", "$f31"
registers_cop1_off	: .half   0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 130, 135, 140, 145

opcode                  : .asciiz "0", "1", "j", "jal", "beq", "bne", "blez", "bgtz", "addi", "addiu", "slti", "sltiu", "andi", "ori", "xori", "lui", "z=0", "z=1", "z=2", "19", "beql", "bnel", "blezl", "bgtzl", "24", "25", "26", "27", "28", "29", "30", "31", "lb", "lh", "lwl", "lw", "lbu", "lhu", "lwr", "39", "sb", "sh", "swl", "sw", "44", "45", "swr", "cache", "ll", "lwc1", "lwc2", "pref", "52", "ldc1", "ldc2", "55", "sc", "swc1", "swc2", "59", "60", "sdc1", "sdc2", "63"
opcode_off              : .half   0, 2, 4, 6, 10, 14, 18, 23, 28, 33, 39, 44, 50, 55, 59, 64, 68, 72, 76, 80, 83, 88, 93, 99, 105, 108, 111, 114, 117, 120, 123, 126, 129, 132, 135, 139, 142, 146, 150, 154, 157, 160, 163, 167, 170, 173, 176, 180, 186, 189, 194, 199, 204, 207, 212, 217, 220, 223, 228, 233, 236, 239, 244, 249
opcode_0                : .asciiz "sll", "1", "srl", "sra", "sllv", "5", "srlv", "srav", "jr", "jalr", "movz", "movn", "syscall", "break", "14", "sync", "mfhi", "mthi", "mflo", "mtlo", "20", "21", "22", "23", "mult", "multu", "div", "divu", "28", "29", "30", "31", "add", "addu", "sub", "subu", "and", "or", "xor", "nor", "40", "41", "slt", "sltu", "44", "45", "46", "47", "tge", "tgeu", "tlt", "tltu", "teq", "53", "tne"
opcode_0_off            : .half   0, 4, 6, 10, 14, 19, 21, 26, 31, 34, 39, 44, 49, 57, 63, 66, 71, 76, 81, 86, 91, 94, 97, 100, 103, 108, 114, 118, 123, 126, 129, 132, 135, 139, 144, 148, 153, 157, 160, 164, 168, 171, 174, 178, 183, 186, 189, 192, 195, 199, 204, 208, 213, 217, 220
opcode_0_f_1            : .asciiz "movf", "movt"
opcode_0_f_1_off        : .half   0, 5
opcode_1                : .asciiz "bltz", "bgez", "bltzl", "bgezl", "4", "5", "6", "7", "tgei", "tgeiu", "tlti", "tltiu", "tegi", "13", "tnei", "15", "bltzal", "bgezal", "bltzall", "bgczall"
opcode_1_off            : .half   0, 5, 10, 16, 22, 24, 26, 28, 30, 35, 41, 46, 52, 57, 60, 65, 68, 75, 82, 90

opcode_16               : .asciiz "mfc0", "1", "cfc0", "3", "mtc0", "5", "ctc0", "7", "8"
opcode_16_off           : .half   0, 5, 7, 12, 14, 19, 21, 26, 28
opcode_16_cop0          : .asciiz "0", "tlbr", "tlbwi", "3", "4", "5", "tlbwr", "7", "8", "tlbp"
opcode_16_cop0_off      : .half   0, 2, 7, 13, 15, 17, 19, 25, 27, 29

opcode_17               : .asciiz "mfc1", "1", "cfc1", "3", "mtc1", "5", "ctc1", "7", "8"
opcode_17_off           : .half   0, 5, 7, 12, 14, 19, 21, 26, 28
opcode_17_8             : .asciiz "bc1f", "bc1t", "bc1fl", "bc1tl"
opcode_17_8_off         : .half   0, 5, 10, 16

opcode_17_cop1_s        : .asciiz "add.s", "sub.s", "mul.s", "div.s", "sqrt.s", "abs.s", "mov.s", "neg.s", "8", "9", "10", "11", "round.w.s", "trunc.w.s", "cell.w.s", "floor.w.s", "16", "17", "movz.s", "movn.s", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "cvt.s.s", "cvt.d.s", "34", "35", "cvt.w.s", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "c.f.s", "c.un.s", "c.eq.s", "c.ueq.s", "c.olt.s", "c.ult.s", "c.ole.s", "c.ule.s", "c.sf.s", "c.ngle.s", "c.seq.s", "c.ngl.s", "c.lt.s", "c.nge.s", "c.le.s", "c.ngt.s"
opcode_17_cop1_s_off    : .half   0, 6, 12, 18, 24, 31, 37, 43, 49, 51, 53, 56, 59, 69, 79, 88, 98, 101, 104, 111, 118, 121, 124, 127, 130, 133, 136, 139, 142, 145, 148, 151, 154, 162, 170, 173, 176, 184, 187, 190, 193, 196, 199, 202, 205, 208, 211, 214, 217, 223, 230, 237, 245, 253, 261, 269, 277, 284, 293, 301, 309, 316, 324, 331
opcode_17_cop1_s_17     : .asciiz "movf.s", "movt.s"
opcode_17_cop1_s_17_off : .half   0, 7
opcode_17_cop1_d        : .asciiz "add.d", "sub.d", "mul.d", "div.d", "sqrt.d", "abs.d", "mov.d", "neg.d", "8", "9", "10", "11", "round.w.d", "trunc.w.d", "cell.w.d", "floor.w.d", "16", "17", "movz.d", "movn.d", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "cvt.s.d", "cvt.d.d", "34", "35", "cvt.w.d", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "c.f.d", "c.un.d", "c.eq.d", "c.ueq.d", "c.olt.d", "c.ult.d", "c.ole.d", "c.ule.d", "c.sf.d", "c.ngle.d", "c.seq.d", "c.ngl.d", "c.lt.d", "c.nge.d", "c.le.d", "c.ngt.d"
opcode_17_cop1_d_off    : .half   0, 6, 12, 18, 24, 31, 37, 43, 49, 51, 53, 56, 59, 69, 79, 88, 98, 101, 104, 111, 118, 121, 124, 127, 130, 133, 136, 139, 142, 145, 148, 151, 154, 162, 170, 173, 176, 184, 187, 190, 193, 196, 199, 202, 205, 208, 211, 214, 217, 223, 230, 237, 245, 253, 261, 269, 277, 284, 293, 301, 309, 316, 324, 331
opcode_17_cop1_d_17     : .asciiz "movf.d", "movt.d"
opcode_17_cop1_d_17_off : .half   0, 7

opcode_18               : .asciiz "mfc2", "1", "cfc2", "3", "mtc2", "5", "ctc2", "7", "8"
opcode_18_off           : .half   0, 5, 7, 12, 14, 19, 21, 26, 28
opcode_18_8             : .asciiz "bc2f", "bc2t", "bc2fl", "bc2tl"
opcode_18_8_off         : .half   0, 5, 10, 16

opcode_28               : .asciiz "madd", "maddu", "mul", "3", "msub", "msubu"
opcode_28_off           : .half   0, 5, 11, 15, 17, 22
opcode_28_cl            : .asciiz "clz", "clo"
opcode_28_cl_off        : .half   0, 4

# STRING LITERALS
integers    : .asciiz "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
file_name   : .asciiz "binaryFile.txt"
output_file : .asciiz "disassembled.txt"	
transl_file : .asciiz "translated.txt"	
null        : .asciiz ""
comma       : .asciiz ","
space       : .asciiz " "
new_line    : .asciiz "\n"
win_line    : .asciiz "\r\n"

# INIT STORAGE
temp_string    : .space 64	# Space to store temporary strings
instruction    : .space 64	# Space used to store temporary decoded ASCII instruction (used by decodeInstr)
byte_temp      : .space 32	# Used to store next 32 byte ASCII string from readNext32
null_byte_temp : .space 1	# Used to have a null terminator for byte_temp
dumpster       : .space 2	# Used by readNext32 to dump \n\r after a call so that the next call
				# 	only reads the next 32 byte string of 1's and 0's
				
# VARIABLES
.align 2
file_desc   : .space 4	# file descriptor
op	    : .space 4	# opcode
op_upper    : .space 4	# upper three bits of opcode
op_lower    : .space 4	# lower three bits of opcode
rs	    : .space 4	# register source
rt	    : .space 4	# register target
rd	    : .space 4	# register destination
funct	    : .space 4	# function field
funct_upper : .space 4	# upper three bits of function field
funct_lower : .space 4	# lower three bits of function field
imm	    : .space 4	# immediate field
shamt	    : .space 4	# shamt field




# ----------------------------------- MACROS SECTION ----------------------------------- #

# setVarI : places immediate of %value into %varName (a variable label)
#
# @param %varName : name of a variable label
# @param %value   : immediate value to place at %varName
.macro setVarI (%varName, %value)
	li $t0, %value
	sw $t0, %varName
.end_macro

# setVar : Saves %reg to %varName
.macro setVar (%varName, %reg)
	sw %reg, %varName
.end_macro

# getVar : Gets word at %varName (a variable label) in $v0
#
# @param   %varName : name of a variable label
# @returns $v0      : word at %varName
.macro getVar (%varName)
	lw $v0, %varName
.end_macro

# print : Print any given string
#
# @param : %string ( given as "STRING" )
.macro print(%string)
	.data
	string: .asciiz %string
	.text
	li $v0, 4
	la $a0, myLabel
	syscall
.end_macro

# printcomma : Prints a comma
.macro printcomma()
	li $v0, 4
	la $a0, comma
	syscall
.end_macro

# printspace : Prints a space
.macro printspace()
	li $v0, 4
	la $a0, space
	syscall
.end_macro

# println : Prints a new line
.macro println()
	li $v0, 4
	la $a0, new_line
	syscall
.end_macro

# insertcomma : Inserts a comma at a given address
#
# @param %address : address to place comma
# @param %rr	  : return register for address + 1
# @returns 	  : returns %address + 1
.macro insertcomma(%address, %rr)
	move $t0, %address
	lb $t1, comma		# get comma
	sb $t1, 0($t0)		# store comma
	addi $v0, $t0, 1	# return address + 1
	move %rr, $v0
.end_macro

# insertspace : Inserts a space at a given address
#
# @param %address : address to place space
# @param %rr	  : return register for address + 1
# @returns 	  : returns address + 1
.macro insertspace(%address, %rr)
	move $t0, %address
	lb $t1, space		# get space
	sb $t1, 0($t0)		# store space
	addi $v0, $t0, 1	# return address + 1
	move %rr, $v0
.end_macro

# insertCommaAndSpace : Inserts a space and comma at address
#
# @param   %address : address to place comma and space
# @param   %rr	    : desired register to return address + 2
# @returns $v0	    : returns %address + 2
.macro insertCommaAndSpace(%address, %rr)
	insertcomma(%address, %rr)
	move %address, %rr
	insertspace(%address, %rr)
	move %rr, %rr
.end_macro

# COPYSTRING : Macro for copyString Procedure
#
# @param %arg0 : argument for copyString $a0
# @param %arg1 : argument for copyString $a1
# @returns     : returns copyString result in $v0 and $s7
.macro COPYSTRING(%arg0, %arg1)
	move $a0, %arg0		# a0 = arg0; string to copy
	move $a1, %arg1		# copy to %arg1
	jal copyString		# copy string over
.end_macro

# INT_TO_STRING : Macro for int_to_string procedure
#
# @param   %int     : $a0 of int_to_string
# @param   %address : $a1 of int_to_string
# @param   %flag    : $a2 of int_to_string
# @param   %bit     : $a3 of int_to_string
# @returns %v0      : same return as int_to_string
.macro INT_TO_STRING(%int, %address, %flag, %bit)
	move $a0, %int
	move $a1, %address
	li $a2, %flag
	li $a3, %bit
	jal int_to_str
.end_macro

# getStringFromOffset : Gets the MIPS instruction format string equivalent of some %bitValue
#
# @param   %stringArray : label of array containing MIPS Instruction format strings
# @param   %offsetArray : label of offset array for %stringArray
# @param   %bitValue    : decimal value of bit range to find
# @returns $v0          : returns address to %stringArray with value from %offsetarray applied
.macro getStringFromOffset(%stringArray, %offsetArray, %bitValue)
	move $t0, %bitValue
	la $t1, %offsetArray
	
	mul $t0, $t0, 2		# offset bitValue by two since offsetArrays are halfwords
	add $t2, $t0, $t1	# offsetArrayAddress += bitValue*2
	lh $t0, ($t2)
	
	la $t3, %stringArray
	add $t3, $t3, $t0	# stringArrayAddress += offset
	move $v0, $t3		# address into $v0
.end_macro


# getBitsInRange : Gets the value of some bits in a range [upperBit : lowerBit]
#
# @param    %instruction : decimal value of MIPS-32 instruction
# @param    %upperBit    : upperBit of range
# @param    %lowerBit    : lowerBit of range
# @returns  $v0	         : bit range right shifted by lowerBit
#
# Note that this returns the values shifted down to the lowest
# order bit. ex: instr[31:26] = opcode, instead of a very large
# number returning, it returns a value 0-64 (since opcodes are 0-64)
.macro getBitsInRange(%instruction, %upperBit, %lowerBit)
	
	# save stack to ensure safety of a0, a1
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	
	move $t0, %instruction	# store parameters
	li $t1, %lowerBit
	li $t2, %upperBit
	
	li $a0, 2		# 2 = base = a0
	sub $a1, $t2, $t1	# a1 = upperBit - lowerBit
	jal exponentiate

	subi $t3, $v0, 1	# 2^(upperBit - lowerBit) - 1
	add $t3, $t3, $v0	# 2^(upperBit - lowerBit) + 2^(upperBit - lowerBit) - 1
				# 	This gives a mask of size upperbit-lowerbit
	sllv $t3, $t3, $t1	# sll 2^(upperBit - lowerBit) - 1 by %lowerBit
	and $v0, $t0, $t3	# mask instruction with $t3 and return 
	srlv $v0, $v0, $t1	# shift bits down to lowest end
	
	lw $a1, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8
.end_macro

# getBitAt : Gets the value of some bit at a specific location
#
# @param    %instruction : decimal value of MIPS-32 instruction
# @param    %bit	 : bit in range 31 - 0
# @returns  $v0	         : value of %bit
.macro getBitAt(%instruction, %bit)
	
	# save stack to ensure safety of a0, a1
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	
	move $t0, %instruction	# store parameters
	move $t1, %bit
	move $t2, %bit
	
	li $a0, 2		# 2 = base = a0
	sub $a1, $t2, $t1	# a1 = upperBit - lowerBit
	jal exponentiate

	subi $t3, $v0, 1	# 2^(upperBit - lowerBit) - 1
	sllv $t3, $t3, $t1	# sll 2^(upperBit - lowerBit) - 1, by %lowerBit
	and $v0, $t0, $t3	# mask instruction with $t3 and return 
	srav $v0, $v0, $t1	# shift bits down to lowest end
	
	lw $a1, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8
.end_macro
# ----------------------------------- END MACROS SECTION ----------------------------------- #

# ------------------------------------------------------- END DATA SECTION ------------------------------------------------------- #



# ------------------------------------------------------- TEXT SECTION ------------------------------------------------------- #
							     .text
 
main:
	# open input file
	la $a0, file_name	# get file name
	li $a1, 0		# flag = read (0)
	jal openFile
	#setVar(file_desc, $v0)
	move $s7, $v0 		# save file descriptor
	
	# open/create output files
		# Regular output file
		la $a0, output_file
		li $a1, 1
		jal openFile
		move $s6, $v0
	
		# Translated binary file
		la $a0, transl_file
		li $a1, 1
		jal openFile
		move $t9, $v0
	
	main_loop:
		move $a0, $s7		# descriptor in a0
		la $a1, byte_temp	# address to storage
		jal readNext32
	
		# if readNext32 returns 0, we've reached eof
		beqz $v0, main_exit
		
		# else decode and print instruction
	
			# convert to decimal
				la $a0, byte_temp
				li $a1, 2		# convert from base 2
				jal str_to_dec
	
				move $a0, $v0		# result from str_to_dec --> a0
				la $a1, instruction
				jal decodeInstr
			
			# Print string of instruction to console
				li $v0, 4
				la $a0, byte_temp
				syscall
				printspace()
			
			# Print decoded instruction to console
				li $v0, 4
				la $a0, instruction
				syscall
				println()
			
			# get string length of instruction
				la $a0, instruction
				jal strLength
			
			# writeout instruction to file
				# writeout decoded to REGULAR file
				move $a2, $v0		# numbytes to read = strLength
				li $v0, 15
				move $a0, $s6
				la $a1, instruction
				syscall
				
				# writeout binary and decoded to TRANSLATED file
				li $v0, 15		# write to file
				move $a0, $t9		# a0 = file descriptor
				la $a1, byte_temp	# Print chars at byte_temp
				li $a2, 32		# Print 32 bytes 
				syscall
				
				# add a space
				li $v0, 15		# write to file
				move $a0, $t9		# a0 = file descriptor
				la $a1, space		# print char at space
				li $a2, 1		# print 1 char
				syscall
				
				# writout instruction
				la $a0, instruction
				jal strLength
				
				move $a2, $v0		# numbytes to read = strLength
				li $v0, 15		# write to file
				move $a0, $t9		# $a0 = file descriptor
				la $a1, instruction	# Print chars at instruction
				syscall

			# write \r\n to both output files
				# writeout to regular output file
				li $v0, 15
				move $a0, $s6
				la $a1, win_line
				li $a2, 2
				syscall
				
				# writeout to translated file
				li $v0, 15
				move $a0, $t9
				la $a1, win_line
				li $a2, 2
				syscall
			
			# clear temp space and loop
				la $a0, instruction
				jal clearBytes
				j main_loop
	# END main_loop
	
	main_exit:
	
		# close reg output file
		move $a0, $s6
		jal closeFile
		
		# close translated output file
		move $a0, $t9
		jal closeFile
		
		# close input file
		move $a0, $s7
		jal closeFile
	
		# exit
		li $v0, 10
		syscall
	# END main_exit
# END main



# ------------------------------------------------------- PROCEDURE SECTION ------------------------------------------------------- #


# decodeInstr : Decodes a 32 bit MIPS instruction into a string
#		and places the string into a given address.
# 
# ARGUMENTS :
#	$a0: decimal value of instruction
#	$a1: address of where to store string of instruction
#
# RETURNS : 
#	$v0: Address to string representing instruction from $a0
decodeInstr:
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s7, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)
	
	move $s0, $a0		# Store instruction in $s0
	move $s7, $a1		# Store a1 in s7
	
	# get and save opcode field
		getBitsInRange($s0, 31, 26)
		setVar(op, $v0)
	
		# get and save opcode upper/lower
		getBitsInRange($s0, 31, 29)
		setVar(op_upper, $v0)
	
		getBitsInRange($s0, 26, 28)
		setVar(op_lower, $v0)
	
	# get and save function field
		getBitsInRange($s0, 5, 0)
		setVar(funct, $v0)
		
		getBitsInRange($s0, 5, 3)
		setVar(funct_upper, $v0)
		
		getBitsInRange($s0, 2, 0)
		setVar(funct_lower, $v0)
	
	# get and save rs, rt, rd
		getBitsInRange($s0, 25, 21)
		setVar(rs, $v0)
	
		getBitsInRange($s0, 20, 16)
		setVar(rt, $v0)
	
		getBitsInRange($s0, 15, 11)
		setVar(rd, $v0)
	
	# get and save immediate
	getBitsInRange($s0, 15, 0)
	setVar(imm, $v0)
	
	# get and save shamt
	getBitsInRange($s0, 10, 6)
	setVar(shamt, $v0)
	
	# Decode opcode
	getVar(op)
	beq $v0, 0,  decode_funct	# opcode == 0, go to decode funct field
	beq $v0, 1,  decode_target	# opcode == 1, go to decode rt field
	#beq $v0, 16, decode_zed0	# opcode == 16, z = 0, go to decode rs field
	#beq $v0, 17, decode_zed1	# opcode == 17, z = 1, go to decode rs field
	beq $v0, 18, decode_zed2	# opcode == 17, z = 2, go to decode rs field
	beq $v0, 28, decode_funct_sec	# opcode == 28, go to decode 2ndary funct field
	
	# else we have root instructions, immediates
	
	decode_root:
		getVar(op)
		ble $v0, 3, decode_root_jmps	# op <= 3, j or jal
		
		getVar(op_upper)
		beq $v0, 1, decode_root_imms	# op_upper == 1, addi ... lui immediates
		beq $v0, 2, decode_root_bra	# op_upper == 2, beql ... bgtzl (not intended for coproc functions)
		
		# else opcode >= 24 (these instructions have a special base offset)
			# print instr
				getVar(op)
				getStringFromOffset(opcode, opcode_off, $v0)
				COPYSTRING($v0, $s7)
				insertspace($v0, $s7)
			
			# print rs
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				insertCommaAndSpace($v0, $s7)
			
			# print rt
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				insertCommaAndSpace($v0, $s7)
				
			# print immediate
				getBitsInRange($s0, 15, 0)
				move $t1, $v0			# get result from getBitsInRange()
				getVar(rs)
				add $v0, $t1, $v0
				INT_TO_STRING($v0, $s7, 1, 15)
			
			# exit
				j di_exit
		# END else opcode >= 16
		
		decode_root_bra:
			# print instr
				getVar(op)
				getStringFromOffset(opcode, opcode_off, $v0)
				COPYSTRING($v0, $s7)
				insertspace($v0, $s7)
		
			# print rs
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				insertCommaAndSpace($v0, $s7)
			
			# print rt
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				insertCommaAndSpace($v0, $s7)
				
			# print immediate
				getBitsInRange($s0, 15, 0)
				INT_TO_STRING($v0, $s7, 1, 15)
			
			# exit
				j di_exit
		# END decode_root_bra
		
		
		decode_root_imms:
			# print instr
			getVar(op)
			getStringFromOffset(opcode, opcode_off, $v0)
			COPYSTRING($v0, $s7)
			insertspace($v0, $s7)
			
			getVar(op)
			beq $v0, 15, decode_root_lui	# if op == 15, lui ; separate from rest in output
			
			# print rt
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				insertCommaAndSpace($v0, $s7)
			
			# print rs
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				insertCommaAndSpace($v0, $s7)
			
			# print immediate
				getBitsInRange($s0, 15, 0)
				INT_TO_STRING($v0, $s7, 1, 15)
			
			# exit
				j di_exit
				
			decode_root_lui:
			# print rt
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				insertCommaAndSpace($v0, $s7)
			
			# print immediate
				getBitsInRange($s0, 15, 0)
				INT_TO_STRING($v0, $s7, 1, 15)
			
			# exit
				j di_exit
			# END decode_root_lui
		# END decode_root_imms
		
		decode_root_jmps:
			getVar(op)
			getStringFromOffset(opcode, opcode_off, $v0)
			COPYSTRING($v0, $s7)
			move $s7, $v0
			insertspace($s7, $s7)
			
			# Print absolute target
				getBitsInRange($s0, 25, 0)
				mul $v0, $v0, 4			# Note: *4 for actual address
				INT_TO_STRING($v0, $s7, 1, 25)
			
			# exit
				j di_exit
		# END decode_root_jmps

	decode_funct_sec:
		getVar(funct_upper)
		beq $v0, 4, df_sec_cl	# if funct_upper == 4, instr is clz / clo
		getVar(funct)
		beq $v0, 2, df_sec_mul	# if funct == 2, instr is mul
		
		# else, madd ... msubu
			# print "%funct "
				getVar(funct)
				getStringFromOffset(opcode_28, opcode_28_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertspace($s7, $s7)
			
			# print reg rs
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
			
			# print reg rt
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
		
			# exit
				j di_exit
		# END else, madd ... msubu
		
		df_sec_cl:
			# print instr clz / clo at funct_lower
				getVar(funct_lower)
				getStringFromOffset(opcode_28_cl, opcode_28_cl_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertspace($s7, $s7)
			
			# print reg rd
				getVar(rd)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
			
			# print reg rs
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
			
			# exit
				j di_exit
		# END df_sec_cl
		
		df_sec_mul:
			# print "%funct " 
				getVar(funct)
				getStringFromOffset(opcode_28, opcode_28_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertspace($s7, $s7)
			
			# print reg rd
				getVar(rd)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
		
			# print reg rs
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
	
			# print reg rt
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
			
			# exit
				j di_exit
		# END df_sec_mul
	# END decode_funct_sec
	
	decode_zed1:
		getVar(rs)
		beq $v0, 16, decode_zed1_s	# if rs == 16, singleword precision coproc functs (5:0)
		beq $v0, 17, decode_zed1_d	# if rs == 17, doubleword precision coproc functs (5:0)
		
		
		decode_zedl_s:
			
			getVar(funct_upper)
			beq $v0, 0, dc_zed1_s_fu0	# if functUpper == 0, basic arithmetic coproc functs
			beq $v0, 1, dc_zed1_s_fu1	# if functUpper == 1, rounding coproc functs
			beq $v0, 2, dc_zed1_s_fu2	# if functUpper == 2, mov coproc functs
			beq $v0, 4, dc_zedl_s_fu4	# if functUpper == 4, cvt coproc functs
			
			# else c.cond.fmt functs (funct == 6 && 7)
			
			
			dc_zed1_s_fu2:
				getVar(funct)
				# TODOOO
				# TODOOO
				# TODOOO WORKING HERE
			
			dc_zed1_s_fu4:
				# print instruction
					getVar(funct)
					getStringFromOffset(opcode_17_cop1_s, opcode_17_cop1_s_off, $v0)
					move $s7, $v0
					insertspace($s7, $s7)
					
				# Get and print fd
					getBitsInRange(10, 6)
					getStringFromOffset(registers_cop1, registers_cop1_off, $v0)
					COPYSTRING($v0, $s7)
					move $s7, $v0
					insertCommaAndSpace($s7, $s7)
					
				# Get and print fs
					getBitsInRange(15, 11)
					getStringFrommOffset(registers_cop1, registers_cop1_off, $v0)
					COPYSTRING($v0, $s7)
				
				# exit
					j di_exit
			# END dc_zed1_s_fu4
		
	
	decode_zed2:
		getVar(rs)
		beq $v0, 8, decode_zed2_rs8 # if rs == 8, go to bczX instructions
		
		# else print instruction
			getVar(rs)
			getStringFromOffset(opcode_18, opcode_18_off, $v0)
			move $s7, $v0
			insertspace($s7, $s7)
		
		# print reg rt
			getVar(rt)
			getStringFromOffset(registers, registers_off, $v0)
			COPYSTRING($v0, $s7)
			move $s7, $v0
			insertCommaAndSpace($s7, $s7)
		
		# print Impl field (immediate field)
			getVar(imm)
			INT_TO_STRING($v0, $s7, 1, 15)
		
		# exit
			j di_exit
		
		decode_zed2_rs8:
			
			# Print coproc 2 branches
				getBitsInRange($s0, 17, 16)
				getStringFromOffset(opcode_18_8, opcode_18_8_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertspace($s7, $s7)
			
			# print cc (in bits 20-18)
				getBitsInRange($s0, 20, 18)
				INT_TO_STRING($v0, $s7, 0, 0)	# Note that the fourth argument here is irrelevant
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
				
			# print offset field (immediate field)
				getVar(imm)
				INT_TO_STRING($v0, $s7, 1, 15)
			
			# exit
				j di_exit
		# END decode_zed2_rs8
	# END decode_zed2
	
	decode_target:
		# print instruction at rt
			getVar(rt)
			getStringFromOffset(opcode_1, opcode_1_off, $v0)
			COPYSTRING($v0, $s7)
			move $s7, $v0
			insertspace($s7, $s7)
		
		# print reg rs
			getVar(rs)
			getStringFromOffset(registers, registers_off, $v0)
			COPYSTRING($v0, $s7)
			move $s7, $v0
			insertCommaAndSpace($s7, $s7)
		
		# print imm
			getVar(imm)
			INT_TO_STRING($v0, $s7, 1, 15)
		
		# exit
			j di_exit
	# END decode_target
	
	decode_funct:				# case if op = 0
		getVar(funct_upper)
		beq $v0, 0, decode_func_shift	# if funct_upper == 0, shift instructions
		beq $v0, 1, decode_func_misc	# if funct_upper == 1, decode instructions 8 - 15
		beq $v0, 2, decode_func_moves	# if funct_upper == 2, decode instructions 16 - 23
		beq $v0, 3, decode_func_mds	# if funct_upper == 3, decode instructions 24 - 31
		beq $v0, 6, decode_func_traps	# if funct_upper == 6, decode instructions 48 - 55 
		# else instructions must be 32 - 39	
			# print "%funct "
				getVar(funct)
				getStringFromOffset(opcode_0, opcode_0_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertspace($s7, $s7)
			
			# print reg rd
				getVar(rd)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
			
			# print reg rs
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
				
			# print reg rs
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
			
			# exit
				j di_exit
		
		decode_func_traps:
			# print "%funct "
				getVar(funct)
				getStringFromOffset(opcode_0, opcode_0_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertspace($s7, $s7)
				
			# print reg rs
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
			
			# print reg rt
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
		
			# exit
				j di_exit
		# END decode_func_traps
		
		decode_func_mds:
			# print "%funct "
				getVar(funct)
				getStringFromOffset(opcode_0, opcode_0_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertspace($s7, $s7)
				
			# print reg rs
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
			
			# print reg rt
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
			
			# exit
				j di_exit
		# END decode_func_mds
		
		decode_func_moves:
			getVar(funct)
			getStringFromOffset(opcode_0, opcode_0_off, $v0)
			COPYSTRING($v0, $s7)
			move $s7, $v0
			insertspace($s7, $s7)	# print "%funct "
			
			getVar(funct_lower)
			rem $v0, $v0, 2		# check if even
			beq $v0, 0, dfm_mf	# evens are mfhi, mflo
			
			# else instructions are mthi, mtlo
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)	# print reg rs
				
				# exit
				j di_exit
			
			dfm_mf:
				getVar(rd)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)	# print reg rd
				
				# exit
				j di_exit
			# END dfm_mf
		# END decode_func_moves
		
		
		decode_func_misc:
			getVar(funct)
			getStringFromOffset(opcode_0, opcode_0_off, $v0)
			COPYSTRING($v0, $s7)
			move $s7, $v0
			insertspace($s7, $s7)	# print "%funct "
			
			getVar(funct_lower)
			ble $v0, 1, dfm_jumps	# equal to jr / jalr
			ble $v0, 3, dfm_movs	# equal to movz / movn
			
			# else is syscall, break, sync (sync will get defaulted since its not in MARS/SPIM)
			getVar(funct)
			beq $v0, 13, dfm_break	# if funct == 13, break
				
				# else its a syscall, therefore exit
				j di_exit
			
			dfm_break:
				getBitsInRange($s0, 25, 6)
				move $a0, $v0
				move $a1, $s7
				jal int_to_str		# write out break code
				j di_exit		# exit
			# END dfm_break

			dfm_jumps:
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				j di_exit
			# END dfm_jumps
			
			dfm_movs:
				getVar(rd)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
				
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
				
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
	
				j di_exit	# exit
			# END dfm_movs
		# END decode_func_misc


		decode_func_shift:		# case if op = 0, funct_upper = 0
			
			getVar(funct_lower)
			beq $v0, 1, decode_func_shift_mov	# if funct == 1, look at movf / movt
			bge $v0, 4, decode_func_shift_var	# if func_lower >= 4, it's a variable shift
			
			# else it's a regular shift func
				
				# print shift instruction type
				getVar(funct)
				getStringFromOffset(opcode_0, opcode_0_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertspace($s7, $s7)
				
				# write out rd
				getVar(rd)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
				
				# write out rt
				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
				
				# write out shamt
				getVar(shamt)
				move $a0, $v0
				move $a1, $s7
				jal int_to_str
				
				# instruction decoded, exit
				j di_exit
				

			decode_func_shift_var:
			
				# print shift instruction type
				getVar(funct)
				getStringFromOffset(opcode_0, opcode_0_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0		# storage address += copiedString Length
				insertspace($s7, $s7)
			
				getVar(rd)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)

				getVar(rt)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
				
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				
				j di_exit
			# END decode_func_shift_var
			
			decode_func_shift_mov:
			
				getBitsInRange($s0, 16, 16)
					
				# print shift instruction type
				getStringFromOffset(opcode_0_f_1, opcode_0_f_1_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertspace($s7, $s7)
					
				# print reg rd
				getVar(rd)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
					
				# print reg rs
				getVar(rs)
				getStringFromOffset(registers, registers_off, $v0)
				COPYSTRING($v0, $s7)
				move $s7, $v0
				insertCommaAndSpace($s7, $s7)
					
				# print cc
				getBitsInRange($s0, 20, 18)
				move $a0, $v0
				move $a1, $s7
				jal int_to_str		# write out trap code
					
				j di_exit
			# END decode_func_shift_mov
		# END decode_func_shift
	# END decode_func			
	
	di_exit:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s7, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra
# END decodeInstr



# copyString : Copies a string from one memory address to another
#
# ARGUMENTS:
#	$a0: address of string to copy
#	$a1: address of where to copy string at $a0
#
# RETURNS:
#	$v0: address of where $a1 was left after copying
copyString:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	copyStringLoop:
	lb $s0, ($a0)			# Read byte from a0
	beq $s0, '\0', copyStringExit	# if byte is null, exit
	sb $s0, ($a1)			# store byte in a1
	addi $a0, $a0, 1		# advance addresses
	addi $a1, $a1, 1
	j copyStringLoop		# loop back
	
	copyStringExit:
	move $v0, $a1			# return a1
	
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi, $sp, $sp, 8
	jr $ra
# END copyString



# readNext32 : Reads 32 bytes from a file containing 32 byte
#	       strings of binary MIPS instructions
#
# ARGUMENTS : 
#	$a0: File descriptor 
#	$a1: Address of where to temp store 32 byte ASCII String
#
# RETURNS : 
#	$v0: Address to where 32 byte string is stored
#
# NOTE :
#	- $v0 returns 0 on EOF
readNext32:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, 14
	# file descriptor in $a0
	# address to input buffer in $a1
	li $a2, 32	# Read 32 bytes
	syscall		# Read next 32 bytes into $a1
	
	# If syscall returns 0, EOF reached. return 0
	beqz $v0, readNext32_eof
	
	# Windows .txt format stores a new line using \n\r
	li $v0, 14
	la $a1, dumpster
	li $a2, 2		# for different newline formats, adjust this number. Currently dumps the next two characters
	syscall			# dump \n\r
	
	move $v0, $a1		# return address of 32 byte string
	
	readNext32_eof:
	# restore stack and return
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
# END readNext32



# openFile: Opens a file and returns its descriptor
# 
# ARGUMENTS:
#	$a0: file name to open
#	$a1: flags
#	$a2: mode
#
# RETURNS:
#	$v0: file descriptor
openFile:
	addi $sp, $sp, -4	# Make space for 1 register on the stack
	sw $ra, 0($sp)		# Save return address on stack
	
	file_open:
    		li $v0, 13	# Open file service number (13) in $v0
    		#la $a0		# Address of file in $a0 as per Procedure Definition
   		#li $a1		# flags in a1
    		#li $a2		# mode in a2
    		syscall  	# Execute open file
	
	# syscall returns fileDescriptor in $v0
	
	lw $ra, 0($sp)		# restore stack
	addi $sp, $sp, 4
	jr $ra			# return to caller
# END openFile



# closeFile: Closes an open file
#
# ARGUMENTS: 
#	$a0: file descriptor to close
#
# RETURNS:
#	
closeFile:
	addi $sp, $sp, -4	# Make space for 1 register on the stack
	sw $ra, 0($sp)		# Save return address on stack
	
	file_close:
    		li $v0, 16 	# Close file service number (16) in $v0
    		#la $a0		# $a0 still has file descriptor	
    		syscall		# Execute close file
	
	lw $ra, 0($sp)		# restore stack
	addi $sp, $sp, 4
	jr $ra			# return to caller
# END closeFile
	


# str_to_dec: Converts a binary or Hexadecimal ASCII string to decimal
# ARGUMENTS:
#	$a0: Address to string buffer 
#	$a1: Base of which to convert to
# RETURNS:
#	$v0: Decimal value of string
str_to_dec:
		
	# Store return address on stack
	sw $ra, 0($sp)		# save return address on stack
	
	la   $s1, ($a0)		# Put address of string in $s1
	move $s2, $a1		# Put desired base in $s2
	li   $t0, 0		# Current number Value of read byte, x
	lb   $t2, null		# Null Terminator address
	move $v0, $zero 	# Zero out v0
	
	str_to_dec_loop:
		
		# WORKING HERE CURRENTLY
		
		lb $t1, 0($s1)		# Get byte at $s1 address --> $t1
		beq $t1, $t2, std_exit	# if byte ($t1) of string is \0 ($t2), exit
		beq $t1, 10, std_exit	# Extra catch-all
		
		# if byte of string is NOT \0, interpret byte
		ble $t1, 57, isNumeric	# if $t1 <= 57 (ASCII), then $t1 is numeric
		
		isNumericElse:
		bge $t1, 65, isLetter	# if $t1 >= 65 (ASCII), then $t1 is a letter
		
		isLetter:
		bge $t1, 97, isLowerCase  # if $t1 >- 97 (ASCII), then $t1 is a lowercase letter
		
		isUpperCase:		# Else clause of is Lower case --> $t1 is uppercase
		subi $t0, $t1, 65	# x = currentByte - 'a' (97 in ASCII is 'a')
		addi $t0, $t0, 10	# x += 10
		j nextIteration
		
		isLowerCase:
		subi $t0, $t1, 97	# x = currentByte = 'A' (65 in ASCII is 'A')
		addi $t0, $t0, 10	# x += 1
		j nextIteration	
		
		isNumeric: 
		subi $t0, $t1, 48	# x = currentByte - '0' (30 in ASCII is '0')
		j nextIteration
		
		
		nextIteration:
		addi $s1, $s1, 1	# branch memory offset by a byte
		mul  $v0, $s2, $v0	# v0 = base * v0 -- Total
		add $v0, $v0, $t0	# v0 = v0 + x
		j str_to_dec_loop
		
	std_exit:
	
		lw $ra, 0($sp)		# restore stack
		jr $ra			# return to caller	
# END str_to_dec
	


# int_to_str : converts an integer to a string
#
# ARGUMENTS: 
#	$a0: integer to convert
#	$a1: address of where to store converted int
#	$a2: flag if sign extension may need to be performed
#	$a3: location of signed bit
#
# NOTES:
#	$a2 = 1 if $a0 might be signed, 0 if not
int_to_str:
	addi $sp, $sp, -24
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, 0($sp)
	
	li $s0, 10		# s0 = 10; for division ops
	move $s3, $a1		# save a1
	move $s4, $zero		# count = 0
	bne $a2, 1, its_next	# If flag != 1, no need to sign extend
	
	getBitAt($a0, $a3)	# This is the sign bit
	li $s1, 1
	and $v0, $v0, $s1
	bne $v0, 1, its_next	# if sign bit != 1, $a0 is pos, continue
	
	# else, make number positive and add '-'
		sll $a0, $a0, 16
		sra $a0, $a0, 16	# make positive
		sub $a0, $zero, $a0
		
		li $s1, 45		# load '-' in s1
		sb $s1, ($a1)		# place into string
		addi $a1, $a1, 1	# increment offset
		addi $s3, $s3, 1	# also increment saved offset
		
	its_next:
	itr_loop:
		div $a0, $s0		# int / 10
		mfhi $s1		# s1 = rem
		addi $s1, $s1, 48	# rem + 48 = ASCII value of digit
		sb $s1, ($a1)		# store ASCII digit
		
		mflo $s2		# s2 = quotient
		addi $s4, $s4, 1	# count += 1
		beq $s2, 0, itr_exit	# exit if quotient is 0
		addi $a1, $a1, 1	# increment a1 offset
		# else quotient != 0
		move $a0, $s2		# a0 = quotient
		j itr_loop
		
	itr_exit:
	
		# reverse string so it is in correct order
		move $a0, $s3		# address to a0
		jal reverseString	# reverse string
	
		# return address (count + original in $s3)
		add $v0, $s3, $s4	# return = count + addr
		
		lw $s4, 0($sp)
		lw $s3, 4($sp)
		lw $s2, 8($sp)
		lw $s1, 12($sp)
		lw $s0, 16($sp)
		lw $ra, 20($sp)
		addi $sp, $sp, 24
		jr $ra
# END int_to_str



# reverseString : reverses a string at a given address
# 
# ARGUMENTS :
#	$a0: address to string that needs to be reversed
#
# NOTE: string must be null-terminated
reverseString:
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, 0($sp)
	
	move $s0, $a0		# s0 = base address
	move $s1, $zero		# s1 = 0
	
	rs_str_len:
		lb $s2, ($a0)			# get byte
		beq $s2, '\0', rs_next		# if byte is null, next step
		addi $a0, $a0, 1		# increment pointer
		addi $s1, $s1, 1		# count += 1
		j rs_str_len	
	
	rs_next:
	div $s1, $s1, 2			# s1 = s1 / 2
	mflo $s1			# s1 = quotient (This is how many times rs_reverse needs to loop)
	addi $a0, $a0, -1		# reset a0 to byte just before \0
	
	rs_reverse:
		ble $s1, 0, rs_exit	# exit if done reversing
		
		lb $s2, ($s0)		# get byte at lefthand side
		lb $s3, ($a0)		# get byte at righthand side
		
		sb $s2, ($a0)		# swap bytes
		sb $s3, ($s0)		#
		
		addi $s0, $s0, 1 	# increment lefthand pointer
		addi $a0, $a0, -1	# decrement righthand pointer
		addi $s1, $s1, -1	# decrement loop iter
		j rs_reverse
		
	rs_exit:
	lw $s3, 0($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra
# END reverseString
	


# exponentiate : calculates a0^a1
#
# ARGUEMNTS :
#	$a0: base
#	$a1: power
# 
# RETURNS:
#	$v0: decimal value of a0^a1
exponentiate:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	
	move $s0, $zero		# zero s0
	addi $s0, $s0, 2	# count = 2
	move $v0, $a0		# result = base
	exp_loop:
		bgt $s0, $a1, exp_exit		# if we've looped more than a1 times, exit
		mul $v0, $v0, $a0		# base*base
		addi $s0, $s0, 1		# count += 1
		j exp_loop
		
	exp_exit:
	lw $s0, 4($sp)		# restore stack and return
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra
# END exponentitate
	
	
	
# clearBytes: Sets memory location to all \0 until a \0 is found
#
# ARUGMENTS: 
#	$a0: address to clear
#
# RETURNS:
#	na
# 
# NOTES:
#	- Requires a null terminator .asciiz string called null
clearBytes:
	addi $sp, $sp, -4	# Make space for 1 register on the stack
	sw $ra, 0($sp)		# save return address
	
	lb $t2, null	# $t2 contains '\0'
	
	cb_loop:
		lb $t1, ($a0)		# get byte
		beq $t1, $t2 cb_exit	# if byte == '\0' exit
		move $t1, $t2		# else byte = '\0'
		sb $t1, ($a0)		# store byte back
		addi $a0, $a0, 1	# advance address
		j cb_loop
		
	cb_exit:
		lw $ra 0($sp)		# restore stack
		jr $ra
# END clearBytes



# strLength : gets the length of a string
#
# ARGUMENTS :
#	$a0: address to string
#
# RETURNS :
#	$v0: length of string
strLength:
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)
	
	move $s1, $zero		# zero counter
	
	strLength_loop:
		lb $s0, 0($a0)			# get a byte
		beq $s0, '\0', strLength_exit	# exit if byte is null
		
		# else add one to counter and jump back
		addi $s1, $s1, 1	# count += 1
		addi $a0, $a0, 1	# pointer += 1
		j strLength_loop
	
	strLength_exit:
		move $v0, $s1		# return string length
		
		lw $s0, 0($sp)		# restore stack
		lw $s1, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		jr $ra
# END strLength





