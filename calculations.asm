.model small

.stack 100h

.data
    input_a     db  12 dup(0x00h)
    input_b     db  12 dup(0x00h)
    
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
    
    mov ax, 0x00h
    mov cx, 0x0h
PRINT_ARRAY_LOOP:
    mov ax, 0x00h
    mov bx, cx
    mov al, [si + bx]
    
    div dl
    
    ; If the remainder is above 9 then add 0x41h (to turn 
    ; it into a alphabetical character in ASCII code)
    cmp ah, 0x09h
    ja PRINT_ARRAY_ADD_41H
    
    add ah, 0x30h
    jmp PRINT_ARRAY_NEXT_LOOP_ITERATION: 

PRINT_ARRAY_ADD_41H:
    add ah, 0x41h
    
PRINT_ARRAY_NEXT_LOOP_ITERATION:
    ; Store the ASCII value in the stack (in LSB of the word)
    mov al, ah
    mov ah, 0x02h
    push ax
    
    inc cx
    cmp cx, 0x0ah
    jb PRINT_ARRAY_LOOP
    
    mov cx, 0x0bh
PRINT_ARRAY_PRINT_LOOP:
    pop ax
    mov dl, al
    int 0x21h
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
                 
    mov cx, 0x02h
    mov dx, [si]
    add [di], dx
    
    pushf
    
ADD_ARRAY_LOOP:
    mov bx, cx
    mov dx, [si + bx]
    popf
    adc [di + bx], dx
    pushf
    
    add cx, 0x02h
    cmp cx, 0xah
    jb ADD_ARRAY_LOOP    
    popf
    
    mov dx, [si + 0x0ah]
    adc [di + 0x0ah], dx
    
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
    adc [di + 0x02h], 0x0000h
    adc [di + 0x03h], 0x0000h
    adc [di + 0x04h], 0x0000h
    adc [di + 0x05h], 0x0000h
    adc [di + 0x06h], 0x0000h
    adc [di + 0x07h], 0x0000h
    adc [di + 0x08h], 0x0000h
    adc [di + 0x09h], 0x0000h
    adc [di + 0x0ah], 0x0000h
    adc [di + 0x0bh], 0x0000h
    
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
    sbb [di + 0x02h], 0x0000h
    sbb [di + 0x03h], 0x0000h
    sbb [di + 0x04h], 0x0000h
    sbb [di + 0x05h], 0x0000h
    sbb [di + 0x06h], 0x0000h
    sbb [di + 0x07h], 0x0000h
    sbb [di + 0x08h], 0x0000h
    sbb [di + 0x09h], 0x0000h
    sbb [di + 0x0ah], 0x0000h
    sbb [di + 0x0bh], 0x0000h
    
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
    
    mov cx, 0x02h
    mov dx, [si]
    sub [di], dx
    
    pushf
    
SUB_ARRAY_LOOP:
    mov bx, cx
    mov dx, [si + bx]
    popf
    sbb [di + bx], dx
    pushf
    
    add cx, 0x02h
    cmp cx, 0xah
    jb SUB_ARRAY_LOOP    
    popf
    
    mov dx, [si + 0x0ah]
    sbb [di + 0x0ah], dx
    
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
    
    mov cx, 0x0000h
    mov cl, al
    
MUL_BY_BYTE_LOOP:
    call Add_Array 
    loop MUL_BY_BYTE_LOOP
    
    popa
    ret
Mul_By_Byte endp

_begin:
    call Init_Segments
                 
    mov input_b[0x00], 0xff
    
    lea di, input_a
    lea si, input_b 
    
    mov ax, 0x0009h
    
    call Mul_By_Byte
     
    mov ah, 0x4ch
    int 21h
end _begin
