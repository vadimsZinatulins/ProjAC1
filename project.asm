.model small

.stack 100h

.data
    ; Division variables
    div_input_a_msg     db  "Dividendo              $"
    div_input_b_msg     db  "Divisor                $"
    div_output_b_msg    db  " e resto ", 082h, " $"
    
    ; SQRT variables
    sqrt_input_msg      db  "N", 0a3h, "mero        $"
    
    ; Conversion variables
    conv_input_1_msg    db  "Introduza base inicial $"
    conv_input_2_msg    db  "Introduza base final   $"
    conv_intro          db  "0 -> Base 16 (valor por defeito)", 0ah, 0dh, "1 -> Base 10", 0ah, 0dh, "2 -> Base 8", 0ah, 0dh, "3 -> Base 2", 0ah, 0dh, "$"
    conv_input_3_msg    db  "Introduza o n", 0a3h, "mero     $"
    conv_bases          db  10h, 0ah, 08h, 02h
    conv_src_base       db  00h
    conv_dst_base       db  00h
    conv_table_file     db  "table.txt", 0
    
    ; Intro variables
    intro_msg           db  "Escolha um algoritmo:", 0ah, 0dh, "0 -> Divisao (valor por defeito)", 0ah, 0dh, "1 -> Raiz quadrada", 0ah, 0dh, "2 -> Conversao", 0ah, 0dh, "3 -> Sair", 0ah, 0dh, "$"
    intro_opt_msg       db  "Op", 087h, "ao         $"
                        
    ; General variables
    input_a             db  12 dup(00h), 00h
    input_a_str         db  12 dup(00h), 00h
    
    input_b             db  12 dup(00h), 00h
    input_b_str         db  12 dup(00h), 00h
    
    aux_var_a           db  12 dup(00h)
    aux_var_b           db  12 dup(00h)
    aux_var_c           db  12 dup(00h)
    
    div_output_a_msg    db  "Resultado ", 082h," $"
        
    ; Line break message
    line_break_msg      db  0ah, 0dh, "$"
    
    ; Strings that outlines a box
    input_box_top_msg   db  0dah, 11 dup(0c4h), 0bfh, "$"
    input_box_mid_msg   db  0b3h, 11 dup(' '), 0b3h, "$"
    input_box_bot_msg   db  0c0h, 11 dup(0c4h), 0d9h, "$"
    
    input_to_continue_msg db "Prima qualquer botao para continuar...$"
    
    clear_line          db 80 dup(' '), "$"
.code

; Input:
; Output:
; Description:
;   Initializes DS and ES (i.e. makes them reference .data segment)
Init_Segments proc
    pusha
    
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    popa
    ret
Init_Segments endp

; Input:
; Output:
; Description: 
;   Clears the entire screen (if it is 80x25 characters)
Clear_Screen proc
    pusha
    
    mov dx, 00h
    mov bh, 00h
    mov ah, 02h
    int 010h
    
    mov cx, 019h
    lea dx, clear_line
    mov ah, 09h
CLEAR_SCREEN_LOOP:
    int 021h
    loop CLEAR_SCREEN_LOOP
    
    mov dx, 00h
    mov bh, 00h
    mov ah, 02h
    int 010h
    
    popa
    ret
Clear_Screen endp

; Input:
; Output:
; Description: 
;   Askes user to press any key to continue
Input_To_Continue proc
    pusha
    
    lea dx, input_to_continue_msg
    mov ah, 09h
    int 021h
    
    mov ah, 01h
    int 021h
    
    popa
    ret
Input_To_Continue endp

; Input:
;   None
; Output:
;   None
; Description:
;   Performs division algorith as it would be done by hand.
Division proc
    pusha
    
    call Clear_Screen
    
    ; Clear the result
    mov word ptr aux_var_a[00h], 00h
    mov word ptr aux_var_a[02h], 00h
    mov word ptr aux_var_a[04h], 00h
    mov word ptr aux_var_a[06h], 00h
    mov word ptr aux_var_a[08h], 00h
    mov word ptr aux_var_a[0ah], 00h
    
    ; Clear the remainder
    mov word ptr aux_var_b[00h], 00h
    mov word ptr aux_var_b[02h], 00h
    mov word ptr aux_var_b[04h], 00h
    mov word ptr aux_var_b[06h], 00h
    mov word ptr aux_var_b[08h], 00h
    mov word ptr aux_var_b[0ah], 00h
    
    ; Propt user for dividend
    lea di, input_a_str
    lea si, input_a
    lea bx, div_input_a_msg 
    mov dl, 0ah
    mov dh, 0ah
    call Pretty_Input
    
    ; Propt user for divisor
    lea di, input_b_str
    lea si, input_b
    lea bx, div_input_b_msg 
    mov dl, 0ah
    mov dh, 0ah
    call Pretty_Input
    
    ; Get the number of digits in dividend
    mov cx, 00h
    mov cl, input_a_str[0ch]
    
    ; Loop through all digits in dividend
DIVISION_LOOP:
    ; remainder = remainder x 10
    lea di, aux_var_b
    call Mul_By_10
    
    ; index = chars.size - CX
    mov bh, 00h
    mov bl, input_a_str[0ch]
    sub bx, cx
    
    ; remainder = remainder + chars[index]
    mov ah, 00h
    mov al, input_a_str[bx]
    lea di, aux_var_b
    call Add_Word_To_Array
    
    ; Store CX in the stack
    push cx
    mov cx, 0ah
    ; for(CX = 10; CX > 0; CX--)
DIVISION_INNER_LOOP:
    ; temp = divisor
    mov ax, word ptr input_b[00h]
    mov word ptr aux_var_c[00h], ax
    mov ax, word ptr input_b[02h]
    mov word ptr aux_var_c[02h], ax
    mov ax, word ptr input_b[04h]
    mov word ptr aux_var_c[04h], ax
    mov ax, word ptr input_b[06h]
    mov word ptr aux_var_c[06h], ax
    mov ax, word ptr input_b[08h]
    mov word ptr aux_var_c[08h], ax
    mov ax, word ptr input_b[0ah]
    mov word ptr aux_var_c[0ah], ax
    
    ; AX = CX - 1
    mov ax, cx
    dec ax
    ; temp = temp x AX
    lea di, aux_var_c
    call Mul_By_Byte
    
    ; Compare temp with remainder   
    lea di, aux_var_c
    lea si, aux_var_b
    call Cmp_array
    
    ; if (temp <= remainder) jump to DIVISION_INNER_LOOP_EXIT
    cmp al, 01h
    jbe DIVISION_INNER_LOOP_EXIT
    loop DIVISION_INNER_LOOP
     
DIVISION_INNER_LOOP_EXIT:
    ; remainder = remainder - temp
    lea di, aux_var_b
    lea si, aux_var_c
    call Sub_Array
    
    ; result = result x 10
    lea di, aux_var_a
    call Mul_By_10
    
    ; AX = CX - 1
    mov ax, cx
    dec ax
    
    ; result = result + AX
    lea di, aux_var_a
    call Add_Word_To_array
    
    ; Restore CX from the stack    
    pop cx
    
DIVISION_CONTINUE_LOOP:    
    loop DIVISION_LOOP
    
    ; Print custom message
    lea dx, div_output_a_msg
    mov ah, 09h
    int 021h
    
    ; Print the result
    lea si, aux_var_a
    call Output_Array
    
    ; Print custom message
    lea dx, div_output_b_msg
    mov ah, 09h
    int 021h
    
    ; Print the remainder
    lea si, aux_var_b
    call Output_Array
    
    ; Print the line break
    lea dx, line_break_msg
    mov ah, 09h
    int 21h
    int 21h
    
    ; Wait for user input
    call Input_To_Continue
        
    popa
    
    ret
Division endp    

Sqrt proc
    pusha
    
    call Clear_Screen
    
    ; Clear the result
    mov word ptr aux_var_a[00h], 00h
    mov word ptr aux_var_a[02h], 00h
    mov word ptr aux_var_a[04h], 00h
    mov word ptr aux_var_a[06h], 00h
    mov word ptr aux_var_a[08h], 00h
    mov word ptr aux_var_a[0ah], 00h
    
    ; Clear the remainder
    mov word ptr aux_var_b[00h], 00h
    mov word ptr aux_var_b[02h], 00h
    mov word ptr aux_var_b[04h], 00h
    mov word ptr aux_var_b[06h], 00h
    mov word ptr aux_var_b[08h], 00h
    mov word ptr aux_var_b[0ah], 00h
    
    ; Propt user for dividend
    lea di, input_a_str
    lea si, input_a
    lea bx, sqrt_input_msg 
    mov dl, 0ah
    mov dh, 0ah
    call Pretty_Input
    
    ; Check if the number of chars is even
    ; AH = chars.size % 2
    mov ah, 00h
    mov al, input_a_str[0ch]
    mov bl, 02h
    div bl
    
    ; if (AH == 0) jump to SQRT_OK
    cmp ah, 00h
    je SQRT_OK
    
    ; Shift entire array (by one byte) to the left and place 00h as first digit
    mov bx, word ptr input_a_str[09h]
    mov word ptr input_a_str[0ah], bx
    mov bx, word ptr input_a_str[07h]
    mov word ptr input_a_str[08h], bx
    mov bx, word ptr input_a_str[05h]
    mov word ptr input_a_str[06h], bx
    mov bx, word ptr input_a_str[03h]
    mov word ptr input_a_str[04h], bx
    mov bx, word ptr input_a_str[01h]
    mov word ptr input_a_str[02h], bx
    mov bx, word ptr input_a_str[00h]
    mov bh, bl
    mov bl, 00h
    mov word ptr input_a_str[00h], bx     
    
    ; chars.size += 1
    inc input_a_str[0ch]
    
SQRT_OK:
    ; AH = chars.size % 2 
    mov ah, 00h
    mov al, input_a_str[0ch]
    mov bl, 02h
    div bl
    ; Store the AL in the stack (must use entire register) 
    ; AL stores the number of pairs
    push ax
    
    ; CX = 00:AL
    mov ch, 00h
    mov cl, al
    
    ; for(CX = number of pairs; CX > 0; CX--)
SQRT_LOOP:
    mov bp, sp
    
    ; remainder = remainder x 100
    mov al, 064h
    lea di, aux_var_b
    call Mul_By_Byte
    
    ; Calculate the index of the next pair and keep it in BX
    ; Restore the AL from the stack
    mov ax, [bp + 00h]
    ; BX = 00:AL
    mov bh, 00h
    mov bl, al
    ; BL = 2 x (BL - CL)
    sub bl, cl
    shl bl, 01h
    
    ; Add the next pair to the remainder
    ; AX = 00:chars[index]
    mov ah, 00h
    mov al, input_a_str[bx + 00h]
    ; AX = AX x 10
    mov dl, 0ah
    mul dl
    mov dh, 00h
    ; AX = AX + chars[index + 1] 
    mov dl, input_a_str[bx + 01h]
    add ax, dx
    
    ; remainder = remainder + ax
    lea di, aux_var_b
    call Add_Word_To_Array
    
    ; Store CX in the stack
    push cx
    
    mov cl, 0ah
    
    ; for(CL = 10; CL > 0; CL--)
SQRT_INNER_LOOP:
    dec cl
    ; temp = result        
    mov ax, word ptr aux_var_a[00h]
    mov word ptr aux_var_c[00h], ax
    mov ax, word ptr aux_var_a[02h]
    mov word ptr aux_var_c[02h], ax
    mov ax, word ptr aux_var_a[04h]
    mov word ptr aux_var_c[04h], ax
    mov ax, word ptr aux_var_a[06h]
    mov word ptr aux_var_c[06h], ax
    mov ax, word ptr aux_var_a[08h]
    mov word ptr aux_var_c[08h], ax
    mov ax, word ptr aux_var_a[0ah]
    mov word ptr aux_var_c[0ah], ax
    
    ; temp = temp x 20
    mov ax, 014h        
    lea di, aux_var_c   
    call Mul_By_Byte    
    
    ; temp = temp + cl
    mov al, cl
    call Add_Word_To_Array
    
    ; temp = temp x cl
    call Mul_By_Byte
    
    ; if(temp < remainder) {
    ;   break  
    ; }
    lea si, aux_var_b
    call Cmp_Array
    cmp al, 01h
    jbe SQRT_INNER_LOOP_EXIT
    
    inc cl
    loop SQRT_INNER_LOOP
    
SQRT_INNER_LOOP_EXIT:
    ; remainder = remainder - temp
    lea di, aux_var_b
    lea si, aux_var_c
    call Sub_Array
    
    ; result = result x 10
    lea di, aux_var_a
    call Mul_By_10
    
    ; result = result + cl
    mov ax, cx
    call Add_Word_To_Array
    
    pop cx
    
    loop SQRT_LOOP
    
    ; input_b = result
    mov ax, word ptr aux_var_a[00h]
    mov word ptr input_b[00h], ax
    mov ax, word ptr aux_var_a[02h]
    mov word ptr input_b[02h], ax
    mov ax, word ptr aux_var_a[04h]
    mov word ptr input_b[04h], ax
    mov ax, word ptr aux_var_a[06h]
    mov word ptr input_b[06h], ax
    mov ax, word ptr aux_var_a[08h]
    mov word ptr input_b[08h], ax
    mov ax, word ptr aux_var_a[0ah]
    mov word ptr input_b[0ah], ax
    
    ; Print custom message
    lea dx, div_output_a_msg
    mov ah, 09h
    int 021h
    
    ; Print the result
    lea si, input_b
    call Output_Array
    
    ; Since print damages the input_b, it must be copied again
    mov ax, word ptr aux_var_a[00h]
    mov word ptr input_b[00h], ax
    mov ax, word ptr aux_var_a[02h]
    mov word ptr input_b[02h], ax
    mov ax, word ptr aux_var_a[04h]
    mov word ptr input_b[04h], ax
    mov ax, word ptr aux_var_a[06h]
    mov word ptr input_b[06h], ax
    mov ax, word ptr aux_var_a[08h]
    mov word ptr input_b[08h], ax
    mov ax, word ptr aux_var_a[0ah]
    mov word ptr input_b[0ah], ax
    
    ; input_b = input_b x 100
    lea di, input_b
    mov ax, 064h
    call Mul_By_Byte
        
    mov cx, 02h
SQRT_DECIMAL_LOOP:
    mov bp, sp
    
    mov al, 064h
    lea di, aux_var_b
    call Mul_By_Byte
    
    push cx    
    mov cl, 0ah
    
SQRT_DECIMAL_INNER_LOOP:
    dec cl
    
    ; temp = result        
    mov ax, word ptr aux_var_a[00h]
    mov word ptr aux_var_c[00h], ax
    mov ax, word ptr aux_var_a[02h]
    mov word ptr aux_var_c[02h], ax
    mov ax, word ptr aux_var_a[04h]
    mov word ptr aux_var_c[04h], ax
    mov ax, word ptr aux_var_a[06h]
    mov word ptr aux_var_c[06h], ax
    mov ax, word ptr aux_var_a[08h]
    mov word ptr aux_var_c[08h], ax
    mov ax, word ptr aux_var_a[0ah]
    mov word ptr aux_var_c[0ah], ax
    
    ; temp = temp x 20
    mov ax, 014h        
    lea di, aux_var_c   
    call Mul_By_Byte    
    
    ; temp = temp + cl
    mov al, cl
    call Add_Word_To_Array
    
    ; temp = temp x cl
    call Mul_By_Byte
    
    ; if(temp < remainder) {
    ;   break  
    ; }
    lea si, aux_var_b
    call Cmp_Array
    cmp al, 01h
    jbe SQRT_DECIMAL_INNER_LOOP_EXIT
    
    inc cl
    loop SQRT_DECIMAL_INNER_LOOP

SQRT_DECIMAL_INNER_LOOP_EXIT:
    ; remainder = remainder - temp
    lea di, aux_var_b
    lea si, aux_var_c
    call Sub_Array
    
    ; result = result x 10
    lea di, aux_var_a
    call Mul_By_10
    
    ; result = result + cl
    mov ax, cx
    call Add_Word_To_Array
        
    pop cx
    loop SQRT_DECIMAL_LOOP
    
    ; Get the decimal value
    lea di, aux_var_a
    lea si, input_b
    call Sub_Array
    
    ; Print '.'
    mov dl, 02eh
    mov ah, 02h
    int 21h
    
    ; Print decimal value
    lea si, aux_var_a
    call Output_Array
    
    ; Print line break
    lea dx, line_break_msg
    mov ah, 09h
    int 21h
    int 21h
    
    call Input_To_Continue
    
    pop ax
    popa
    ret
Sqrt endp

Conversion proc
    pusha
    
    call Clear_Screen
    
    lea dx, conv_intro
    mov ah, 09h
    int 21h
    
    ; Propt user for source base input
    lea di, input_a_str
    lea si, input_a
    lea bx, conv_input_1_msg
    mov dl, 04h
    mov dh, 01h
    call Pretty_Input
    mov al, input_a[00h]
    mov conv_src_base, al
    
    ; Propt user for destination base input
    lea di, input_a_str
    lea si, input_a
    lea bx, conv_input_2_msg
    mov dl, 04h
    mov dh, 01h
    call Pretty_Input
    mov al, input_a[00h]
    mov conv_dst_base, al
    
    ; Propt user for number to convert
    mov bh, 00h
    mov bl, conv_src_base
    mov dl, conv_bases[bx]
    lea di, input_a_str
    lea si, input_a
    lea bx, conv_input_3_msg
    mov dh, 0ah
    call Pretty_Input
    
    mov cx, 00h
CONVERSION_LOOP:
    ; intput_a = input_a / src_base
    mov bh, 00h
    mov bl, conv_dst_base
    mov al, conv_bases[bx]
    lea di, input_a
    call Div_By_Byte
    
    inc cl
    
    ; Store AH (remainder) in the stack
    push ax
    
    ; Check if input_a is no zero 
    mov ax, word ptr input_a[00h]
    or ax, word ptr input_a[02h]
    or ax, word ptr input_a[04h]
    or ax, word ptr input_a[06h]
    or ax, word ptr input_a[08h]
    or ax, word ptr input_a[0ah] 
    
    ; While input_a is not zero jump back
    cmp ax, 00h
    jne CONVERSION_LOOP 
    
    lea dx, div_output_a_msg
    mov ah, 09h
    int 21h
    int 21h
        
    ; Open file
    lea dx, conv_table_file
    mov al, 00h
    mov ah, 03dh
    int 21h
    
    ; Store the file handle into BX
    mov bx, ax
CONVERSION_SECOND_LOOP:    
    ; Get the number from stack and move it to DL
    pop dx
    mov dl, dh
    mov dh, 00h
    
    ; AL = 4 x DL
    mov al, 06h
    mul dl
    
    ; Store the CX in the stack
    push cx
    
    ; Seek index = CX:DX
    ; DL = AL + BaseIndex
    mov dl, al
    add dl, conv_dst_base
    ; CX = 00h 
    mov cx, 00h
    ; AL is set to 0 so that origin of seek is the beginning of the file         
    mov al, 00h
    ; Set current file position
    mov ah, 042h
    int 21h                          
    
    ; Read 1 byte from the file            
    mov cx, 01h
    lea dx, input_a_str
    mov ah, 03fh
    int 21h
    
    mov dl, input_a_str[00h]
    mov ah, 02h
    int 021h
    
    ; Retrive old CX value from stack
    pop cx
    
    loop CONVERSION_SECOND_LOOP
    
    ; close file
    mov bx, ax
    mov ah, 03eh
    int 21h
    
    lea dx, line_break_msg
    mov ah, 09h
    int 21h
    int 21h
    
    call Input_To_Continue
    
    popa
    ret
Conversion endp

; Input:
;   SI -> Array to print
; Output:
; Description:
Output_Array proc
    pusha
    
    mov cx, 00h
    
    ; If [SI] == 0 then just print '0'
    ; AX = AX OR [SI]                           
    mov ax, word ptr [SI + 00h]
    or ax, word ptr [SI + 02h]
    or ax, word ptr [SI + 04h]
    or ax, word ptr [SI + 06h]
    or ax, word ptr [SI + 08h]
    or ax, word ptr [SI + 0ah]
    
    ; if (AX != 0) jump to OUTPUT_ARRAY_LOOP
    cmp ax, 00h
    jne OUTPUT_ARRAY_LOOP
 
    ; Print '0'   
    mov dl, 030h
    mov ah, 02h
    int 21h
    ; Jump to the end
    jmp OUTPUT_ARRAY_END
    
OUTPUT_ARRAY_LOOP:
    inc cx
    
    ; [SI] = [SI] / 10
    mov di, si
    mov ax, 0ah
    call Div_By_Byte
    
    add ah, 030h
    
    ; Push the value into the stack
    push ax
    
    ; Check if there are more values to print
    mov ax, 00h
    or ax, [SI + 00h]
    or ax, [SI + 02h]
    or ax, [SI + 04h]
    or ax, [SI + 06h]
    or ax, [SI + 08h]
    or ax, [SI + 0ah]
    cmp ax, 00h
    ja OUTPUT_ARRAY_LOOP
    
OUTPUT_ARRAY_LOOP_PRINT:    
    pop ax
    mov dl, ah
    mov ah, 02h
    int 021h
    loop OUTPUT_ARRAY_LOOP_PRINT
    
OUTPUT_ARRAY_END:
    
    popa
    ret
Output_Array endp

; Input:
;   [Stack + 00h] -> Cursor limit coordinates
;   [Stack + 02h] -> Cursor restore page
; Output:
; Description
;   Compares the current cursor column with the column stored in [Stack + 00h], if the 
;   current column is below stored column then the cursor position will be restored
;   to the value stored in [Stack + 00h]. The page is used just to make sure the 
;   cursor stays in same page.
Input_Limit_Cursor proc
    pusha
    
    mov bp, sp
    add bp, 012h
                          
    mov bx, [bp + 02h]
    mov dx, [bp + 00h]
    
    push dx
    push bx
    
    ; Get the cursor position
    mov ah, 03h
    int 010h
    
    pop bx
    pop cx
    
    cmp dl, cl
    jae INPUT_LIMIT_CURSOR_OK
    
    mov dx, cx
    mov ah, 02h
    int 010h
    
INPUT_LIMIT_CURSOR_OK:
    
    popa
    ret
Input_Limit_Cursor endp

; Input:
;   DI -> Destination string
;   SI -> Destination array
;   DL -> Base
; Output:
; Description:
Input_Value proc
    pusha
         
    mov bp, sp
    
    ; Get the cursor position
    mov ah, 03h
    int 010h
    
    ; Store the cursor information (page in BH, position in DX)
    push bx
    push dx
    
    ; Restore DX from stack
    mov dx, [bp + 0ah]
     
    ; Clear Inputs                   
    mov word ptr [di + 00h], 00h
    mov word ptr [di + 02h], 00h
    mov word ptr [di + 04h], 00h
    mov word ptr [di + 06h], 00h
    mov word ptr [di + 08h], 00h
    mov word ptr [di + 0ah], 00h
    
    mov word ptr [si + 00h], 00h
    mov word ptr [si + 02h], 00h
    mov word ptr [si + 04h], 00h
    mov word ptr [si + 06h], 00h
    mov word ptr [si + 08h], 00h
    mov word ptr [si + 0ah], 00h
    
    ; Input counter           
    mov bx, 00h
INPUT_VALUE_LOOP:
    mov ah, 01h
    int 21h   
    
    ; Check if input is ENTER
    cmp al, 0dh
    je INPUT_VALUE_END
    
    ; Check if input is BACKSPACE
    cmp al, 08h
    je INPUT_VALUE_BACKSPACE
    
    ; Make sure input is no longer than 10 digits
    cmp bl, dh
    jae INPUT_VALUE_INVALID_INPUT 
    
    ; Check if it is a valid digit (0 - 1)
    cmp al, 030h
    jb INPUT_VALUE_INVALID_INPUT
    cmp al, 03ah
    jb INPUT_VALUE_IS_DIGIT
    
    ; Convert to lowercase
    xor al, 020h
    
    ; Check if input is a valid character (A - F)
    cmp al, 041h
    jb INPUT_VALUE_INVALID_INPUT
    cmp al, 47h
    jb INPUT_VALUE_IS_CHAR
    
INPUT_VALUE_INVALID_INPUT:
    ; Store DX (because it will be used)
    push dx
    
    ; Print BACKSPACE (to move cursor back)
    mov ah, 02h
    mov dl, 08h
    int 021h
    
    ; Increment BX (input counter) since it will be decremented
    inc bx                                                     
    
    ; Restore DX
    pop dx
    
INPUT_VALUE_BACKSPACE:
    call Input_Limit_Cursor
    
    ; If BX (input counter) is 0 then don't decrement it 
    cmp bx, 00h
    je INPUT_VALUE_DONT_DEC_BX
    
    ; Decrement input counter
    dec bx
    
INPUT_VALUE_DONT_DEC_BX:
    ; Store DX (because it will be used)
    push dx
        
    ; Print SPACE (to erase character from the screen)
    mov ah, 02h
    mov dl, 020h
    int 021h
    
    ; Print BACKSPACE (to move cursor back)
    mov dl, 08h
    int 021h
     
    ; Restore DX 
    pop dx
    
    jmp INPUT_VALUE_LOOP
    
INPUT_VALUE_IS_CHAR:
    ; Input is a character (A - F) so remove 37h from it to get real value
    sub al, 037h
    jmp INPUT_VALUE_CONTINUE
    
INPUT_VALUE_IS_DIGIT:
    ; Input is a number (0 - 9) so remove 30h from it to get real value
    SUB al, 030h
    
INPUT_VALUE_CONTINUE:
    ; If the real value of the input is greater than DL (base) then
    ; it means that input value is invalid
    cmp al, dl
    jae INPUT_VALUE_INVALID_INPUT
    
    ; Store the input value
    mov [di + bx], al
    
    ; Increment BX (input counter) 
    inc bx
    jmp INPUT_VALUE_LOOP    

INPUT_VALUE_END:
    
    ; Store the number of inputs
    mov [di + 0ch], bl
    
    cmp bx, 00h
    jz INPUT_VALUE_EMPTY
    
    mov cx, bx
INPUT_VALUE_ACCUM_LOOP:
    mov bx, 00h
    mov bl, [di + 0xch]
    sub bx, cx     
    
    mov al, [di + bx]
    mov ah, 00h
    
    push di
    push ax
    mov ax, 00h
    mov al, dl
    mov di, si
    call Mul_By_Byte
    pop ax
    
    call Add_Word_To_Array
    pop di
    
    loop INPUT_VALUE_ACCUM_LOOP
    
INPUT_VALUE_EMPTY:
    ; Remove mouse information from stack
    add sp, 04h                          
    
    popa
    
    ret
Input_Value endp

; Input:
;   DI -> Destination string
;   SI -> Destination array
;   BX -> Propt to display
;   DH -> Max. number of digits
;   DL -> Base
; Output:
; Description: 
Pretty_Input proc
    pusha
    
    mov bp, sp
    
    ; Prompt user for input
    push dx
    
    ; Jump to line below
    lea dx, line_break_msg
    mov ah, 09h
    int 021h
    
    ; Output custom msg
    mov dx, bx
    mov ah, 09h
    int 021h
    
    mov bh, 00h
    ; Get the cursor position
    mov ah, 03h
    int 10h
    
    push bx
    push dx
    
    ; Go to line above
    dec dh
    mov ah, 02h
    int 010h
    
    ; Output top bar
    lea dx, input_box_top_msg
    mov ah, 09h
    int 021h
    
    mov bx, [bp - 04h]
    mov dx, [bp - 06h]
    
    ; Go to line bellow
    inc dh
    mov ah, 02h
    int 010h
    
    ; Output bot bar
    lea dx, input_box_bot_msg
    mov ah, 09h
    int 021h
    
    mov bx, [bp - 04h]
    mov dx, [bp - 06h]
    
    ; Go to back to center
    mov ah, 02h
    int 010h
    
    ; Output top bar
    lea dx, input_box_mid_msg
    mov ah, 09h
    int 021h
    
    mov bx, [bp - 04h]
    mov dx, [bp - 06h]    
    
    inc dl
    mov ah, 02h
    int 010h
    
    mov dx, [bp - 02h]
    
    call Input_Value
    
    ; Place cursor at a position that will not damange the result
    ; on the screen
    mov bx, [bp - 04h]
    mov dx, [bp - 06h]
    add dh, 02h
    mov dl, 00h
    mov ah, 02h
    int 010h
    
    ; Clear the stack
    add sp, 06h
    
    popa
    ret
Pretty_Input endp

; Inputs:
;   DI -> Address of the destination array of words
;   SI -> Address of the source array of words
; Outputs:
; Description:
;   [DI] = [DI] + [SI]
Add_Array proc
    pusha  
    
    mov ax, word ptr [si + 00h]
    add word ptr [di + 00h], ax
    mov ax, word ptr [si + 02h]
    adc word ptr [di + 02h], ax
    mov ax, word ptr [si + 04h]
    adc word ptr [di + 04h], ax
    mov ax, word ptr [si + 06h]
    adc word ptr [di + 06h], ax
    mov ax, word ptr [si + 08h]
    adc word ptr [di + 08h], ax
    mov ax, word ptr [si + 0ah]
    adc word ptr [di + 0ah], ax    
    
    popa
    ret
Add_Array endp

; Input:
;   DI -> Address of the destination array of words
;   AX -> Word to add
; Output:
; Description:
;   [DI] = [DI] + AX
Add_Word_To_Array proc
    pusha
    
    add word ptr [di + 00h], ax           
    adc word ptr [di + 02h], 00h
    adc word ptr [di + 04h], 00h
    adc word ptr [di + 06h], 00h
    adc word ptr [di + 08h], 00h
    adc word ptr [di + 0ah], 00h
    
    popa
    ret
Add_Word_To_Array endp

; Input:
;   DI -> Address of the destination array of words
;   AL -> Word to add
; Output:
; Description:
;   [DI] = [DI] - AX
Sub_Word_To_Array proc
    pusha
    
    sub word ptr [di + 00h], ax           
    sbb word ptr [di + 02h], 00h
    sbb word ptr [di + 04h], 00h
    sbb word ptr [di + 06h], 00h
    sbb word ptr [di + 08h], 00h
    sbb word ptr [di + 0ah], 00h
    
    popa
    ret
Sub_Word_To_Array endp
; Input:
;   DI -> Address of the destination array of words
;   SI -> Address of the source array of words
; Output:
; Description:
;   [DI] = [DI] - [SI]
Sub_Array proc
    pusha
    
    mov ax, word ptr [si + 00h]
    sub word ptr [di + 00h], ax
    mov ax, word ptr [si + 02h]
    sbb word ptr [di + 02h], ax
    mov ax, word ptr [si + 04h]
    sbb word ptr [di + 04h], ax
    mov ax, word ptr [si + 06h]
    sbb word ptr [di + 06h], ax
    mov ax, word ptr [si + 08h]
    sbb word ptr [di + 08h], ax
    mov ax, word ptr [si + 0ah]
    sbb word ptr [di + 0ah], ax
    
    popa
    ret
Sub_Array endp

; Input:
;   DI -> Address of the destination array of words
; Output:
; Description: 
;   Performs shift multiplication. The result is [DI] = [DI] x 10.
;   Using the following formula: x << 3 + x << 1
Mul_By_10 proc
    pusha
                         
    mov ax, [di + 0ah]   
    push ax
    mov ax, [di + 08h]
    push ax
    mov ax, [di + 06h]
    push ax
    mov ax, [di + 04h]
    push ax
    mov ax, [di + 02h]
    push ax
    mov ax, [di + 00h]
    push ax
    
    mov bp, sp
    
    ; Rotate the value in stack to the left (same as x2)
    shl word ptr [bp + 00h], 01h
    rcl word ptr [bp + 02h], 01h
    rcl word ptr [bp + 04h], 01h
    rcl word ptr [bp + 06h], 01h
    rcl word ptr [bp + 08h], 01h
    rcl word ptr [bp + 0ah], 01h
    
    ; Rotate value to the left 3x
    mov ax, 03h
    call Rotate_Left_Array
     
    ; Add the rotated values 
    pop ax
    add word ptr [di + 00h], ax
    pop ax           
    adc word ptr [di + 02h], ax
    pop ax
    adc word ptr [di + 04h], ax
    pop ax
    adc word ptr [di + 06h], ax
    pop ax
    adc word ptr [di + 08h], ax
    pop ax
    adc word ptr [di + 0ah], ax   
    
    popa
    ret
Mul_By_10 endp

; Input:
;   DI -> Address of the destination array of words
;   AL -> Multiply value
; Output:
; Description:
;   [DI] = [SI] x AL
Mul_By_Byte proc
    pusha
    
    ; Store copy of [DI] in stack                  
    mov dx, [di + 0ah]
    push dx
    mov dx, [di + 08h]
    push dx
    mov dx, [di + 06h]
    push dx
    mov dx, [di + 04h]
    push dx
    mov dx, [di + 02h]
    push dx
    mov dx, [di + 00h]
    push dx
    
    ; Clear input                  
    mov word ptr [di + 0ah], 00h
    mov word ptr [di + 08h], 00h
    mov word ptr [di + 06h], 00h
    mov word ptr [di + 04h], 00h
    mov word ptr [di + 02h], 00h
    mov word ptr [di + 00h], 00h
    
    mov bp, sp
    
    mov cx, 08h
MUL_BY_BYTE_LOOP:    
    test al, 01h
    jz MUL_BY_BYTE_DO_SHIFT
    
    ; Add stack to [DI]
    mov dx, [bp + 00h]
    add [di + 00h], dx
    mov dx, [bp + 02h]
    adc [di + 02h], dx
    mov dx, [bp + 04h]
    adc [di + 04h], dx
    mov dx, [bp + 06h]
    adc [di + 06h], dx
    mov dx, [bp + 08h]
    adc [di + 08h], dx
    mov dx, [bp + 0ah]
    adc [di + 0ah], dx
        
MUL_BY_BYTE_DO_SHIFT:
    mov dl, 00h
     
    shr al, 01h
    
    push ax
    mov ax, 01h
    call Rotate_Right_Array                       
    pop ax
    
    loop MUL_BY_BYTE_LOOP
    
    ; Shift result back           
    mov ax, 08h
    call Rotate_Left_Array
    
    ; Remove array copy from stack
    add sp, 0ch
     
    popa
    ret
Mul_By_Byte endp    
        
; Input:
;   DI -> Address of the destination array of words
;   AL -> Divide value
; Output:
;   AH -> Remainder
; Description:
;   [DI] = [SI] / AL
;    AH  = [SI] % AL
Div_By_Byte proc
    push bx
    push cx
    push dx
    push ax
                      
    mov ax, word ptr [di + 0ah]
    push ax
    mov ax, word ptr [di + 08h]
    push ax
    mov ax, word ptr [di + 06h]
    push ax
    mov ax, word ptr [di + 04h]
    push ax
    mov ax, word ptr [di + 02h]
    push ax
    mov ax, word ptr [di + 00h]
    push ax
    
    mov bp, sp
    
    mov ax, word ptr [bp + 0ch]
                               
    mov word ptr [di + 00h], 00h
    mov word ptr [di + 02h], 00h
    mov word ptr [di + 04h], 00h
    mov word ptr [di + 06h], 00h
    mov word ptr [di + 08h], 00h
    mov word ptr [di + 0ah], 00h
    
    mov ah, 00h
    mov dx, 00h
    mov cx, 060h
    ;mov cx, 08h
    
DIV_BY_BYTE_LOOP:    
    mov bl, 00h
    shl word ptr [bp + 00h], 01h
    rcl word ptr [bp + 02h], 01h
    rcl word ptr [bp + 04h], 01h
    rcl word ptr [bp + 06h], 01h
    rcl word ptr [bp + 08h], 01h
    rcl word ptr [bp + 0ah], 01h    
    adc bl, 00h
    or [bp + 00h], bl
    
    shl dx, 01h
    
    mov bl, [bp + 00h]
    and bl, 01h
    or dl, bl    
    
    cmp dx, ax
    jb DIV_BY_BYTE_CONTINUE_LOOP
 
    sub dx, ax
    
    push ax
    mov ax, cx
    dec ax
    call Set_Bit_At
    pop ax
    
DIV_BY_BYTE_CONTINUE_LOOP:
    loop DIV_BY_BYTE_LOOP
    
    mov ah, dl
    
    add sp, 0eh
    
    pop dx
    pop cx
    pop bx
    
    ret
Div_By_Byte endp 

; Input:
;   DI -> Operand A
;   SI -> Operand B
; Output:
;   AL -> Result
; Description:
;   DI > SI => AL = 2
;   DI = SI => AL = 1
;   DI < SI => AL = 0
Cmp_Array proc
    pusha
    
    mov ax, word ptr [di + 0ah]
    cmp ax, word ptr [si + 0ah]
    ja CMP_ARRAY_ABOVE
    jb CMP_ARRAY_BELOW
    mov ax, word ptr [di + 08h]
    cmp ax, word ptr [si + 08h]
    ja CMP_ARRAY_ABOVE
    jb CMP_ARRAY_BELOW
    mov ax, word ptr [di + 06h]
    cmp ax, word ptr [si + 06h]
    ja CMP_ARRAY_ABOVE
    jb CMP_ARRAY_BELOW
    mov ax, word ptr [di + 04h]
    cmp ax, word ptr [si + 04h]
    ja CMP_ARRAY_ABOVE
    jb CMP_ARRAY_BELOW
    mov ax, word ptr [di + 02h]
    cmp ax, word ptr [si + 02h]
    ja CMP_ARRAY_ABOVE
    jb CMP_ARRAY_BELOW
    mov ax, word ptr [di + 00h]
    cmp ax, word ptr [si + 00h]
    ja CMP_ARRAY_ABOVE
    jb CMP_ARRAY_BELOW
    
    mov al, 01h
    
    jmp CMP_ARRAY_END
    
CMP_ARRAY_ABOVE:
    mov al, 02h
    jmp CMP_ARRAY_END
    
CMP_ARRAY_BELOW:    
    mov al, 00h
    
CMP_ARRAY_END:
    push ax
    
    add sp, 02h
    
    popa
    
    mov bp, sp
    mov ax, [bp - 012h]
    
    ret
Cmp_Array endp

; Input: 
;   SI -> Address of the siyrce array
;   AX -> Bit index [0 - 95]
; Output:
;   CF -> Indicates the value of the bit at AX index
; Description:
;   Retrieves the value of the bit in the SI array at AX index
Get_Bit_At proc
    pusha
    
    mov dx, 00h
    
    clc
              
    push ax
    mov bx, 08h
    div bx
    mov bx, ax
    mov cx, dx
    pop ax
    
    mov al, 01h
    
    shl al, cl
    test [si + bx], al
    jnz GET_BIT_AT_SET_FLAG
    
    jmp GET_BIT_AT_RETURN
GET_BIT_AT_SET_FLAG:
    stc
    
GET_BIT_AT_RETURN:
    
    popa
    ret
Get_Bit_At endp

; Input: 
;   DI -> Address of the siyrce array
;   AX -> Bit index [0 - 95]
; Output:
; Description:
;   Sets the bit at index specified by AX in the SI array
Set_Bit_At proc
    pusha
    
    mov dx, 00h
    
    push ax
    mov bx, 08h
    div bx
    mov bx, ax
    mov cx, dx
    pop ax
    
    mov al, 01h
    
    shl al, cl
    or [di + bx], al
    
    popa
    ret
Set_Bit_At endp

; Input:
;   DI -> Address of the destination array of words
;   AL -> Rotation ammount
; Output:
; Description:
;   Rotates [DI] to the right
Rotate_Right_Array proc
    pusha
    
    mov dx, 00h
    mov cx, ax
    
ROTATE_RIGHT_ARRAY_LOOP:
    mov dl, 00h                 

    shr word ptr [di + 0ah], 01h
    rcr word ptr [di + 08h], 01h
    rcr word ptr [di + 06h], 01h
    rcr word ptr [di + 04h], 01h
    rcr word ptr [di + 02h], 01h
    rcr word ptr [di + 00h], 01h
    
    adc dl, 00h
    ror dl, 01h
    or [di + 0bh], dl
    
    loop ROTATE_RIGHT_ARRAY_LOOP
    
    popa
    ret
Rotate_Right_Array endp

; Input:
;   DI -> Address of the destination array of words
;   AL -> Rotation ammount
; Output:
; Description:
;   Rotates [DI] to the left
Rotate_Left_Array proc
    pusha 
    
    mov dx, 00h
    mov cx, ax
    
ROTATE_LEFT_ARRAY_LOOP:
    mov dl, 00h
    
    shl word ptr [di + 00h], 01h
    rcl word ptr [di + 02h], 01h
    rcl word ptr [di + 04h], 01h
    rcl word ptr [di + 06h], 01h
    rcl word ptr [di + 08h], 01h
    rcl word ptr [di + 0ah], 01h
    
    adc dl, 00h
    or [di + 00h], dl
    
    loop ROTATE_LEFT_ARRAY_LOOP
    
    popa
    ret
Rotate_Left_Array endp

_begin:
    call Init_Segments
    
    call Clear_Screen
    
    lea dx, intro_msg
    mov ah, 09h
    int 21h
      
    lea di, input_a_str
    lea si, input_a
    lea bx, intro_opt_msg 
    mov dl, 04h
    mov dh, 01h
    call Pretty_Input
    
    mov al, input_a[00h]
    cmp al, 03h
    je EXIT
    cmp al, 02h
    je DO_CONVERSION_ALG
    cmp al, 01h
    je DO_SQRT_ALG 

    call Division
    jmp _begin
    
DO_SQRT_ALG:
    call Sqrt
    jmp _begin
    
DO_CONVERSION_ALG:
    call Conversion
    jmp _begin
    
EXIT:
    mov ah, 0x4ch
    int 21h
end _begin
