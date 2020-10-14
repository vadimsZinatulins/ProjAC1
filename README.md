# List of procedures
- [Init_Segments](https://github.com/vadimsZinatulins/ProjAC1#init_segments-procedure)
- [Validate_Cursor_State](https://github.com/vadimsZinatulins/ProjAC1#validate_cursor_state-procedure)
- [Write_Space_And_Backspace](https://github.com/vadimsZinatulins/ProjAC1#write_space_and_backspace-procedure)
- [Write_Line_Break](https://github.com/vadimsZinatulins/ProjAC1#write_line_break-procedure)
- [Get_Input](https://github.com/vadimsZinatulins/ProjAC1#get_input-procedure)
- [Push_To_Front](https://github.com/vadimsZinatulins/ProjAC1#push_to_front-procedure)
- [Print_Num](https://github.com/vadimsZinatulins/ProjAC1#print_num-procedure)
- [Run_Division_Alg](https://github.com/vadimsZinatulins/ProjAC1#run_division_alg-procedure)
- [Run_Sqrt_Alg](https://github.com/vadimsZinatulins/ProjAC1#run_sqrt_alg-procedure)
- [Run_Conversion_Alg](https://github.com/vadimsZinatulins/ProjAC1#run_conversion_alg-procedure)

# Documentation
## Init_Segments procedure
#### Inputs
None
#### Outputs
None
#### Description
Initializes  DS and ES (i.e. makes them reference .data segment)

## Validate_Cursor_State procedure
#### Inputs
-AX: Cursor current state (Row and Column)
-DX: Cursor old state (Row and Column)
-BL: Cursor old page
#### Outputs
None
#### Description
Compares the column of the cursor in the current state with the column of old state, and if the current state is less than old state then the cursor will be reset to the old state.

## Write_Backspace procedure
#### Inputs
None
#### Outputs
None
#### Description
Writes a BACKSPACE character to the screen

## Write_Space_And_Backspace procedure
#### Inputs
None
#### Outputs
None
#### Description
Writes SPACE character followed by BACKSPACE character to the screen

## Write_Line_Break procedure
#### Inputs
None
#### Outputs
None
#### Description
Writes a line break to the screen (i.e. advances cursor to the next line)

## Get_Input procedure
#### Inputs
- Stack [SP + 6]: Address of the inputs string, input string will be stored in this address
- Stack [SP + 4]: Address of the input length, input length will be stored in this address
- Stack [SP + 2]: Address of the input value, input value will be stored in this address
#### Outputs
None
#### Description
Reads input from the user and stores it's string (ASCII value) in argument Stack [SP + 6] address, input size in Stack [SP + 4] address and hexadecimal value in Stack [SP + 2] address.

The caller doesn't need to pop values from the stack since this procedure does it!

## Push_To_Front procedure
#### Inputs
- DI
- AH
#### Outputs
None
#### Description
Shifts buffer (referenced by DI) to the right and inserts BH at the beginning

## Print_Num procedure
#### Inputs
- CX: Number to print
- DI: Reference to the buffer where ASCII value will be written
#### Outputs
None
#### Description
Prints the hexadecimal value to screen in ASCII format

## Run_Division_Alg procedure
#### Inputs
#### Outputs
#### Description

## Run_Sqrt_Alg procedure
#### Inputs
#### Outputs
#### Description

## Run_Conversion_Alg procedure
#### Inputs
#### Outputs
#### Description


# Usefull links
- [Instructions set](https://jbwyatt.com/253/emu/8086_instruction_set.html)
- [Interrupts list](https://jbwyatt.com/253/emu/8086_bios_and_dos_interrupts.html)
- [ASCII table](http://www.asciitable.com/)
