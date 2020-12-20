# MIPS Instruction Set Disassembler

The MIPS Instruction Set Disassembler (MISD) is a tool written in MIPS32 Assembly language that converts 32 bit long binary ASCII strings representing MIPS format instructions to their disassembled counterpart. For example:

The string "100100000000100000000000000100" represents the instruction "addiu $2, $0, 4". 

The series of binary instructions should be held within a text file. The text file currently specified within misd.asm is called "binaryText.txt" and can be changed if desired. Keep in mind that due to different text encodings, you may need to adjust how MISD handles new lines. For example, for .txt encoding on MacOS the new line character is simply '\r' whereas on Windows it is '\r\n'. Currently MISD is set to work for Windows platforms, but this can be adjusted within the readNext32 procedure. 

MISD has two output files, a disassembled and translated file. The disassembled file contains only the disassembled instructions and the translated file shows both the original binary instruction and its disassembled counterpart. 

***** Please note the following *****
- At the moment, MISD does not support hexadecimal format and further work will allow hexadecimal or binary input. 
- MISD does not utilize a lookup table and therefore labels are replaced with their absolute addresses. Further work will allow the use of a lookup table to replace the absolute addresses.
- MISD does not currently work for the entire MIPS32 instruction set. It is currently missing coproc functions; however, it works for over half of the instruction set and includes all of the most commonly used instructions. Further work will allow MISD to work on all MIPS32 instructions.

