.model small

.stack 100h

.data
    input_a     db  12 dup(00h)
    input_b     db  12 dup(00h)
    
.code

Init_Segments proc
    pusha
    
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    popa
    ret
Init_Segments endp

; Input:
;   DL -> Base
;   SI -> Address of the source array of bytes
; Output:
;
; Description:
;   Prints the number in the array as ASCII in a specified base number.
Print_Array proc
    pusha 
    
    mov ax, 00h
    mov cx, 0h
PRINT_ARRAY_LOOP:
    mov ax, 00h
    mov bx, cx
    mov al, [si + bx]
    
    div dl
    
    ; If the remainder is above 9 then add 0x41h (to turn 
    ; it into a alphabetical character in ASCII code)
    cmp ah, 09h
    ja PRINT_ARRAY_ADD_41H
    
    add ah, 30h
    jmp PRINT_ARRAY_NEXT_LOOP_ITERATION: 

PRINT_ARRAY_ADD_41H:
    add ah, 41h
    
PRINT_ARRAY_NEXT_LOOP_ITERATION:
    ; Store the ASCII value in the stack (in LSB of the word)
    mov al, ah
    mov ah, 02h
    push ax
    
    inc cx
    cmp cx, 0ah
    jb PRINT_ARRAY_LOOP
    
    mov cx, 0bh
PRINT_ARRAY_PRINT_LOOP:
    pop ax
    mov dl, al
    int 21h
    loop PRINT_ARRAY_PRINT_LOOP
    
    popa
    ret
Print_Array endp

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
;   AL -> Word to add
; Output:
; Description:
;   [DI] = [DI] + AX
Add_Word_To_Array proc
    pusha
    
    add [di], ax           
    adc [di + 02h], 00h
    adc [di + 03h], 00h
    adc [di + 04h], 00h
    adc [di + 05h], 00h
    adc [di + 06h], 00h
    adc [di + 07h], 00h
    adc [di + 08h], 00h
    adc [di + 09h], 00h
    adc [di + 0ah], 00h
    adc [di + 0bh], 00h
    
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
    
    sub [di], ax           
    sbb [di + 02h], 00h
    sbb [di + 03h], 00h
    sbb [di + 04h], 00h
    sbb [di + 05h], 00h
    sbb [di + 06h], 00h
    sbb [di + 07h], 00h
    sbb [di + 08h], 00h
    sbb [di + 09h], 00h
    sbb [di + 0ah], 00h
    sbb [di + 0bh], 00h
    
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
;   SI -> Address of the source array of words
;   AL -> Multiply value
; Output:
; Description:
;   [DI] = [SI] x AL
Mul_By_Byte proc
    pusha
                        
    mov dx, [si + 00h]
    mov [di + 00h], 00h
    mov dx, [si + 02h]
    mov [di + 02h], 00h
    mov dx, [si + 04h]
    mov [di + 04h], 00h
    mov dx, [si + 06h]
    mov [di + 06h], 00h
    mov dx, [si + 08h]
    mov [di + 08h], 00h
    mov dx, [si + 0ah]
    mov [di + 0ah], 00h
    
    mov cx, 08h
MUL_BY_BYTE_LOOP:    
    test al, 01h
    jz MUL_BY_BYTE_DO_SHIFT
    
    call Add_Array
        
MUL_BY_BYTE_DO_SHIFT:
    mov dl, 00h
     
    shr al, 01h
    
    push ax
    mov ax, 01h
    call Rotate_Right_Array                       
    pop ax
    
    adc dl, 00h
    rol dl, 01h
    
    or [di + 0bh], dl
    
    loop MUL_BY_BYTE_LOOP
    
    ; Shift result back           
    mov ax, 08h
    call Rotate_Left_Array
     
    popa
    ret
Mul_By_Byte endp    

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
    
    shr [di + 00h], 01h
    rcr [di + 01h], 01h
    rcr [di + 02h], 01h
    rcr [di + 03h], 01h
    rcr [di + 04h], 01h
    rcr [di + 05h], 01h
    rcr [di + 06h], 01h
    rcr [di + 07h], 01h
    rcr [di + 08h], 01h
    rcr [di + 09h], 01h
    rcr [di + 0ah], 01h
    rcr [di + 0bh], 01h
    
    adc dl, 00h
    ror dl, 01h
    or [di + 00h], dl
    
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
    
    shl [di + 0bh], 01h
    rcl [di + 0ah], 01h
    rcl [di + 09h], 01h
    rcl [di + 08h], 01h
    rcl [di + 07h], 01h
    rcl [di + 06h], 01h
    rcl [di + 05h], 01h
    rcl [di + 04h], 01h
    rcl [di + 03h], 01h
    rcl [di + 02h], 01h
    rcl [di + 01h], 01h
    rcl [di + 00h], 01h
    
    adc dl, 00h
    or [di + 0bh], dl
    
    loop ROTATE_LEFT_ARRAY_LOOP
    
    popa
    ret
Rotate_Left_Array endp

_begin:
    call Init_Segments  
     
    mov input_b[00h], 0ffh
    
    lea di, input_a
    lea si, input_b 
    
    mov ax, 0ffh
    
    call Mul_By_Byte
     
    mov ah, 0x4ch
    int 21h
end _begin
