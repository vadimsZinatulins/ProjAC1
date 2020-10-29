.model small

.stack 100h

.data
    input_a     db  10 dup(0x00h)
    input_b     db  10 dup(0x00h)
    
.code

Init_Segments proc
    pusha
    
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    popa
    ret
Init_Segments endp

; Inputs:
;           DI -> Address for input a
;           SI -> Address for input b
;           AL -> Array size
; Outputs:
;           AH -> If 0x00 then OK else Overflow error
; Description:
;           [DI] = [DI] + [SI]
Array_Add proc
    pusha
    
    dec al
    mov cx, 0x00h
    mov cl, al
    
    ; This will set carry flag to 0 and dx to 0
    xor dx, dx
ARRAY_ADD_BEGIN:
    mov bx, cx 
    mov dl, [si + bx]
    adc [di + bx], dl
         
    loop ARRAY_ADD_BEGIN
    
    mov dl, [si]
    adc [di], dl
    
    jc ARRAY_ADD_OVERFLOW
    
    popa
    mov ah, 0x00h
    
    jmp ARRAY_ADD_END
    
ARRAY_ADD_OVERFLOW:    
    popa
    mov ah, 0x01h
        
ARRAY_ADD_END:
    
    ret
Array_Add endp

; Inputs:
;           DI -> Address for input a
;           SI -> Address for input b
;           AL -> Array size
; Outputs:
;           AH -> If 0x00 then OK else Overflow error
; Description:
;           [DI] = [DI] - [SI]
Array_Sub proc
    pusha
    
    dec al
    mov cx, 0x00h
    mov cl, al
    
    ; This will set carry flag to 0 and dx to 0
    xor dx, dx
ARRAY_SUB_BEGIN:
    mov bx, cx 
    mov dl, [si + bx]
    sbb [di + bx], dl
         
    loop ARRAY_SUB_BEGIN
    
    mov dl, [si]
    sbb [di], dl
    
    jc ARRAY_SUB_OVERFLOW
    
    popa
    mov ah, 0x00h
    
    jmp ARRAY_SUB_END
    
ARRAY_SUB_OVERFLOW:    
    popa
    mov ah, 0x01h

ARRAY_SUB_END:

    ret
Array_Sub endp

; Inputs:
;           DI -> Address for input a
;           SI -> Address for input b
;           AL -> Array size
; Outputs:
;           AH -> If 0x00 then OK else Overflow error
; Description:
;           [DI] = [DI] x [SI]
Array_Mul proc
    pusha
    popa
    
    ret
Array_Mul endp
_begin:
    call Init_Segments
                         
    mov input_a[0], 0xffh
    mov input_a[1], 0xffh
    mov input_a[2], 0x00h
                            
    mov input_b[0], 0x00h
    mov input_b[1], 0xffh
    mov input_b[2], 0xffh
    
    mov al, 03h
                   
    lea di, input_a
    lea si, input_b
    
    call Array_Sub
    
    mov ah, 0x4ch
    int 21h
end _begin
