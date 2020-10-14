# Procedures Documentation
## Init_Segments
### Inputs
None
### Outputs
None
### Description
Initializes  DS and ES (i.e. makes them reference .data segment)

## Validate_Cursor_State
### Inputs
-AX: Cursor current state (Row and Column)
-DX: Cursor old state (Row and Column)
-BL: Cursor old page
### Outputs
None
### Description
Compares the column of the cursor in the current state with the column of old state, and if the current state is less than old state then the cursor will be reset to the old state.

## Write_Backspace
### Inputs
None
### Outputs
None
### Description
Writes a BACKSPACE character to the screen

## Write_Space_And_Backspace
### Inputs
None
### Outputs
None
### Description
Writes SPACE character followed by BACKSPACE character to the screen

## Write_Line_Break
### Inputs
None
### Outputs
None
### Description
Writes a line break to the screen (i.e. advances cursor to the next line)

## Get_Input
### Inputs
- Stack [SP + 6]: Address of the inputs string, input string will be stored in this address
- Stack [SP + 4]: Address of the input length, input length will be stored in this address
- Stack [SP + 2]: Address of the input value, input value will be stored in this address
### Outputs
None
### Description
Reads input from the user and stores it's string (ASCII value) in argument Stack [SP + 6] address, input size in Stack [SP + 4] address and hexadecimal value in Stack [SP + 2] address.

The caller doesn't need to pop values from the stack since this procedure does it!

## Push_To_Front
### Inputs
- DI
- AH
### Outputs
None
### Description
Shifts buffer (referenced by DI) to the right and inserts BH at the beginning

## Print_Num
### Inputs
- CX
### Outputs
None
### Description
Prints the hexadecimal value to screen in ASCII format

## Run_Division_Alg
### Inputs
### Outputs
### Description

## Run_Sqrt_Alg
### Inputs
### Outputs
### Description

## Run_Conversion_Alg
### Inputs
### Outputs
### Description


# Usefull links
- [Instructions set](https://jbwyatt.com/253/emu/8086_instruction_set.html)
- [Interrupts list](https://jbwyatt.com/253/emu/8086_bios_and_dos_interrupts.html)
- [ASCII table](http://www.asciitable.com/)
