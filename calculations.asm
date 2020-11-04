.model small

.stack 100h

.data
    input_a     db  12 dup(00h), 00h
    input_b     db  12 dup(00h), 00h
                                    
    input_str   db  12 dup(00h), 00h
    
    input_msg   db  "Introduza um numero: $"
    mul_by_10_aux   db  12 dup(00h)
.code

Init_Segments proc
    pusha
    
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    popa
    ret
Init_Segments endp

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
; Description
Input_Value proc
    pusha
    
    ; Store Base in AL
    mov al, dl        
    
    ; Get the cursor position
    mov ah, 03h
    int 010h
    
    ; Store the cursor information (page in BH, position in DX)
    push bx
    push dx
    
    ; Restore Base
    mov dl, al
     
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
    cmp bx, 0ah
    jae INPUT_VALUE_INVALID_INPUT 
    
    ; Check if it is a valid digit (0 - 1)
    cmp al, 030h
    jb INPUT_VALUE_INVALID_INPUT
    cmp al, 03ah
    jb INPUT_VALUE_IS_DIGIT
    
    ; Convert to lowercase
    xor al, 040h
    
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
    ; Input is a character (A - F) so remove 41h from it to get real value
    sub al, 041h
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
    
    ; Remove mouse information from stack
    add sp, 04h                          
    
    popa
    
    ret
Input_Value endp

; Inputs:
;   DI -> Address of the destination array of words
;   SI -> Address of the source array of words
; Outputs:
; Description:
;   [DI] = [DI] + [SI]
Add_Array proc
    pusha  
                 
    mov cx, 02h
    mov dx, [si]
    add [di], dx
    
    pushf
    
ADD_ARRAY_LOOP:
    mov bx, cx
    mov dx, [si + bx]
    popf
    adc [di + bx], dx
    pushf
    
    add cx, 02h
    cmp cx, 0ah
    jb ADD_ARRAY_LOOP    
    popf
    
    mov dx, [si + 0ah]
    adc [di + 0ah], dx
    
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
    
    mov cx, 02h
    mov dx, [si]
    sub [di], dx
    
    pushf
    
SUB_ARRAY_LOOP:
    mov bx, cx
    mov dx, [si + bx]
    popf
    sbb [di + bx], dx
    pushf
    
    add cx, 02h
    cmp cx, 0ah
    jb SUB_ARRAY_LOOP    
    popf
    
    mov dx, [si + 0ah]
    sbb [di + 0ah], dx
    
    popa
    ret
Sub_Array endp

; Input:
;   DI -> Address of the destination array of words
; Output:
; Description:
Mul_By_10 proc
    pusha
                           
    mov ax, [di + 00h]
    mov word ptr [mul_by_10_aux + 00h], ax
    mov ax, [di + 02h]
    mov word ptr [mul_by_10_aux + 02h], ax
    mov ax, [di + 04h]
    mov word ptr [mul_by_10_aux + 04h], ax
    mov ax, [di + 06h]
    mov word ptr [mul_by_10_aux + 06h], ax
    mov ax, [di + 08h]
    mov word ptr [mul_by_10_aux + 08h], ax
    mov ax, [di + 0ah]
    mov word ptr [mul_by_10_aux + 0ah], ax
    
    mov ax, 03h
    call Rotate_Left_Array
    
    push di
    lea di, mul_by_10_aux
    mov ax, 01h
    call Rotate_Left_Array
    pop di
    
    lea si, mul_by_10_aux
    call Add_Array   
    
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
;   SI -> Address of the source array of words
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
    
    mov ah, 00h
    mov dx, 00h
    mov cx, 060h
    ;mov cx, 08h
    
DIV_BY_BYTE_LOOP:
    shl dx, 01h
    push ax
    mov ax, cx
    dec ax
    call Get_Bit_At
    adc dx, 00h
    pop ax
    
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
    
    pop dx
    pop cx
    pop bx
    
    ret
Div_By_Byte endp 

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
    
    ; mov input_a[00h], 0ffh
    ; mov ax, 010h
    ; call Rotate_Left_Array
     
    lea dx, input_msg
    mov ah, 09h
    int 021h
    
    lea di, input_str
    lea si, input_a 
    mov dl, 0ah
    call Input_Value
     
    mov ah, 0x4ch
    int 21h
end _begin
