# List of procedures
- [Init_Segments](https://github.com/vadimsZinatulins/ProjAC1#init_segments-procedure)
- [Division](https://github.com/vadimsZinatulins/ProjAC1#division-procedure)
- [Sqrt](https://github.com/vadimsZinatulins/ProjAC1#sqrt-procedure)
- [Conversion](https://github.com/vadimsZinatulins/ProjAC1#conversion-procedure)
- [Output_Array](https://github.com/vadimsZinatulins/ProjAC1#output_array-procedure)
- [Input_Limit_Cursor](https://github.com/vadimsZinatulins/ProjAC1#input_limit_cursor-procedure)
- [Input_Value](https://github.com/vadimsZinatulins/ProjAC1#input_value-procedure)
- [Pretty_Input](https://github.com/vadimsZinatulins/ProjAC1#pretty_input-procedure)
- [Add_Array](https://github.com/vadimsZinatulins/ProjAC1#add_Array-procedure)
- [Add_Word_To_Array](https://github.com/vadimsZinatulins/ProjAC1#add_word_to_array-procedure)
- [Sub_Word_To_Array](https://github.com/vadimsZinatulins/ProjAC1#sub_word_to_array-procedure)
- [Sub_Array](https://github.com/vadimsZinatulins/ProjAC1#sub_array-procedure)
- [Mul_By_10](https://github.com/vadimsZinatulins/ProjAC1#mul_by_10-procedure)
- [Mul_By_Byte](https://github.com/vadimsZinatulins/ProjAC1#mul_by_byte-procedure)
- [Div_By_Byte](https://github.com/vadimsZinatulins/ProjAC1#div_by_byte-procedure)
- [Cmp_Array](https://github.com/vadimsZinatulins/ProjAC1#cmp_array-procedure)
- [Get_Bit_At](https://github.com/vadimsZinatulins/ProjAC1#get_bit_at-procedure)
- [Set_Bit_At](https://github.com/vadimsZinatulins/ProjAC1#set_bit_at-procedure)
- [Rotate_Right_Array](https://github.com/vadimsZinatulins/ProjAC1#rotate_right_array-procedure)
- [Rotate_Left_Array](https://github.com/vadimsZinatulins/ProjAC1#rotate_left_array-procedure)

# Procedures documentation
## Init_Segments procedure
#### Inputs
None
#### Outputs
None
#### Description
Initializes  DS and ES (i.e. makes them reference .data segment)

## Division procedure
#### Inputs
None
#### Outputs
None
#### Description
Performs division algorith as it would be done by hand.

## Sqrt procedure
#### Inputs
None
#### Outputs
None
#### Description
Performs square root algorith as it would be done by hand.

## Conversion procedure
#### Inputs
None
#### Outputs
None
#### Description
Performs conversion using a file table.

## Output_Array procedure
#### Inputs
SI -> Array to print
#### Outputs
None
#### Description
None

## Input_Limit_Cursor procedure
#### Inputs
[Stack + 00h] -> Cursor limit coordinates
[Stack + 02h] -> Cursor restore page
#### Outputs
#### Description
Compares the current cursor column with the column stored in [Stack + 00h], if the current column is below stored column then the cursor position will be restored to the value stored in [Stack + 00h]. The page is used just to make sure the cursor stays in same page.

## Input_Value procedure
#### Inputs
DI -> Destination string
SI -> Destination array
DH -> Max. number of digits
DL -> Base
#### Outputs
#### Description

## Pretty_Input procedure
#### Inputs
DI -> Destination string
SI -> Destination array
BX -> Propt to display
DH -> Max. number of digits
DL -> Base
#### Outputs
#### Description

## Add_Array procedure
#### Inputs
DI -> Address of the destination array of words
SI -> Address of the source array of words
#### Outputs
#### Description
[DI] = [DI] + [SI]

## Add_Word_To_Array procedure
#### Inputs
DI -> Address of the destination array of words
AX -> Word to add
#### Outputs
#### Description
[DI] = [DI] + AX

## Sub_Word_To_Array procedure
#### Inputs
DI -> Address of the destination array of words
AL -> Word to add
#### Outputs
#### Description
[DI] = [DI] - AX

## Sub_Array procedure
#### Inputs
DI -> Address of the destination array of words
SI -> Address of the source array of words
#### Outputs
#### Description
[DI] = [DI] - [SI]

## Mul_By_10 procedure
#### Inputs
DI -> Address of the destination array of words
#### Outputs
#### Description
Performs shift multiplication. The result is [DI] = [DI] x 10. Using the following formula: x << 3 + x << 1

## Mul_By_Byte procedure
#### Inputs
DI -> Address of the destination array of words
AL -> Multiply value
#### Outputs
#### Description
[DI] = [SI] x AL

## Div_By_Byte procedure
#### Inputs
DI -> Address of the destination array of words
AL -> Divide value
#### Outputs
AH -> Remainder
#### Description
[DI] = [SI] / AL
 AH  = [SI] % AL

## Cmp_Array procedure
#### Inputs
DI -> Operand A
SI -> Operand B
#### Outputs
AL -> Result
#### Description
DI > SI => AL = 2
DI = SI => AL = 1
DI < SI => AL = 0

## Get_Bit_At procedure
#### Inputs
SI -> Address of the siyrce array
AX -> Bit index [0 - 95]
#### Outputs
CF -> Indicates the value of the bit at AX index
#### Description
Retrieves the value of the bit in the SI array at AX index

## Set_Bit_At procedure
DI -> Address of the siyrce array
AX -> Bit index [0 - 95]
#### Inputs
#### Outputs
#### Description
Sets the bit at index specified by AX in the SI array

## Rotate_Right_Array procedure
#### Inputs
DI -> Address of the destination array of words
AL -> Rotation ammount
#### Outputs
#### Description
Rotates [DI] to the right

## Rotate_Left_Array procedure
#### Inputs
DI -> Address of the destination array of words
AL -> Rotation ammount
#### Outputs
#### Description
Rotates [DI] to the left

# Usefull links
- [Instructions set](https://jbwyatt.com/253/emu/8086_instruction_set.html)
- [Interrupts list](https://jbwyatt.com/253/emu/8086_bios_and_dos_interrupts.html)
- [ASCII table](http://www.asciitable.com/)
