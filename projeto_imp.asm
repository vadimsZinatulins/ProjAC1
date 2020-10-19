; title "Projecto"

.model small

.stack 100h

.data
    ; Division algorithm variables                                  
    div_msg_a               db  'Introduza o dividendo', 0ah, 0dh, '$'
    div_msg_b               db  'Introduza o divisor', 0ah, 0dh, '$'
    
    div_input_a_str         db  6, 0, 6 dup(?)
    div_input_a_value       dw  0
     
    div_input_b_str         db  6, 0, 6 dup(?)
    div_input_b_value       dw  0
                                                  
    div_msg_result_pt1      db  ' a dividir por $'
    div_msg_result_pt2      db  ' ', 082h, ' $'
    div_msg_result_pt3      db  ' e sobra $'
    
    ; SQRT algorithm variables
    sqrt_msg                db  'Introduza o numero', 0ah, 0dh, '$'
    
    sqrt_input_str          db  6, 0 6 dup(?)
    sqrt_input_value        dw  0
    
    ; General variables
    aux_var_a               dw  0, 0ffffh
    aux_var_b               dw  0, 0ffffh
    break_line_msg          db  0ah, 0dh, '$'    
    overflow_msg            db  0ah, 0dh, 'Erro de overflow!', 0ah, 0dh, '$'
    introduce_again_msg     db  0ah, 0dh, 'Introduza novamente o numero', 0ah, 0dh, '$'
    invalid_input_msg       db  0ah, 0dh, 'Input invalido!', 0ah, 0dh, '$'
    undefined_msg           db  'indefinido$', 0ah, 0dh, '$'   
.code

; Input: 
;           None
; Output: 
;           None
; Description:
;           Initializes ds and es (i.e. make them reference data segment)
Init_Segments proc
    mov ax, @data
    mov ds, ax
    mov es, ax
    ret
Init_Segments endp

; Input:
;           None
; Output:
;           None
; Description:
;           Prints a line break
Print_Line_Break proc
    pusha
    
    lea dx, break_line_msg 
    mov ah, 09h
    int 21h
    
    popa
    ret
Print_Line_Break endp

; Input:
;           Stack [SP + 2] (1 byte) ->  Base
;           Stack [SP + 3] (1 byte) ->  Character
; Output:
;           AL -> Hexadecimal value
;           AH -> Status 
; Description:
;           Checks if the character (in Stack [SP + 3]) is a valid ASCII character and if it is in the 
;           specified base (passed in Stack [SP + 2]). If the character is in valid state then AH equals
;           to 00h otherwise it is not a valid character. AL returns the character in 
;           its hexadecimal value.
Validate_Character proc
    mov bp, sp
    
    ; Store previous state
    push bx
    push cx
    push dx
    
    mov ax, [bp + 02h]
    
    or al, 020h     ; Convert char to lowercase
    
    cmp al, 30h
    jb VALIDATE_CHARACTER_INVALID
    cmp al, 3ah
    jb VALIDATE_CHARACTER_IS_NUMBER
    cmp al, 041h
    jb VALIDATE_CHARACTER_INVALID
    cmp al, 047h
    jb VALIDATE_CHARACTER_IS_CHAR
    
VALIDATE_CHARACTER_INVALID:
    mov ax, 00100h  ; Set AH (status) as not OK
    jmp VALIDATE_CHARACTER_END_VALIDATION
    
VALIDATE_CHARACTER_IS_NUMBER:
    sub al, 030h    ;   Convert the number to a correct hexadecimal value
    
    ; Check if the value is in range within its base
    cmp al, ah
    jae VALIDATE_CHARACTER_INVALID
    
    mov ah, 00h         ; Set AH (status) as OK
    jmp VALIDATE_CHARACTER_END_VALIDATION
    
VALIDATE_CHARACTER_IS_CHAR:
    sub al, 041h    ;   Convert the number to a correct hexadecimal value
    
    ; Check if the value is in range within its base
    cmp al, ah
    jae VALIDATE_CHARACTER_INVALID
    
    mov ah, 00h     ; Set AH (status) as OK
    jmp VALIDATE_CHARACTER_END_VALIDATION

VALIDATE_CHARACTER_END_VALIDATION:
    ; Restore previous state    
    pop dx
    pop cx
    pop bx
    
    ret
Validate_Character endp

; Input:
;           Stack [SP + 2]  -> Overflow flag
;           Stack [SP + 3]  -> Base
;           Stack [SP + 4]  -> Destination string
; Output:
;           AX              -> If overflow validation is true, then AX will return the validated hexadecimal value
; Description:
;
Get_Input_Str proc    
    mov bp, sp
    
    ; Store previous state
    push bx
    push cx
    push dx
    
    ; Store the string pointer in SI
    mov si, [bp + 4]
    
GET_INPUT_STR_BEGIN: 
    ; Get the string length
    mov cx, 00h
    mov cl, [si]           
    
    ; Clear the entire string    
GET_INPUT_STR_CLEAR_INPUT: 
    mov bx, cx
    mov [si + bx + 2], 00h
    loop GET_INPUT_STR_CLEAR_INPUT
    
    ; Read string from user
    mov dx, [bp + 4]
    mov ah, 0ah
    int 21h
    
    ; Get the number of characters read]
    mov cx, 00h
    mov cl, [si + 1]
    
    ; Iterate over all characters, validate them and store their hexadecimal value instead 
    ; of their ASCII representation
GET_INPUT_STR_VALIDATE_CHARS:
    ; Get the number of characters read
    mov bx, 00h
    mov bl, [si + 1]
    
    ; Get the index of next character to validate
    sub bx, cx
    
    mov al, [si + bx + 2]   ; Place the character to validate in AL
    mov ah, [bp + 3]        ; Place the base in AH
    
    push bp     ; Store BP state
    push ax     
    
    call Validate_Character
    
    add sp, 02h     ; Remove previous argument from stack (It is no longer needed)
    pop bp          ; Restore BP state
    
    cmp ah, 00h
    jne GET_INPUT_STR_INVALID_INPUT 
    
    mov [si + bx + 2], al   ; Store input as hexadecimal value
    
    loop GET_INPUT_STR_VALIDATE_CHARS
    
    ; Get the overflow flag and check the input overflows
    mov ax, [bp + 02h]
    cmp al, 00h
    je GET_INPUT_STR_END 
    
    ; Check if the input overflows
    ; Get the number of characters read]
    mov cx, 00h
    mov cl, [si + 1]
               
    ; Accumulator
    mov ax, 00h
GET_INPUT_STR_CHECK_OVERFLOW:
    mov dx, 00h
    ; Place the base in BL
    mov bx, 00h
    mov bl, [bp + 3]        
    
    ; Multiply AX by base
    mul bx                  
    
    ; Add carry do DX
    adc dx, 00h
    
    ; Get the number of characters read
    mov bx, 00h
    mov bl, [si + 1]
    
    ; Get the index of next digit
    sub bx, cx
    
    mov bl, [si + bx + 2]   ; Place the digit in BL
    
    ; Add the digit to accumulator
    add ax, bx 
    
    ; Add carry do DX
    adc dx, 00h
    
    ; Check if overflow has occurred
    cmp dx, 00h
    jne GET_INPUT_STR_OVERFLOW_ERROR
    
    loop GET_INPUT_STR_CHECK_OVERFLOW
    
    jmp GET_INPUT_STR_END

GET_INPUT_STR_OVERFLOW_ERROR:
    lea dx, overflow_msg
    mov ah, 09h
    int 21h
    
    lea dx, introduce_again_msg
    mov ah, 09h
    int 21h
     
    jmp GET_INPUT_STR_BEGIN
    
GET_INPUT_STR_INVALID_INPUT:
    lea dx, invalid_input_msg
    mov ah, 09h
    int 21h
    
    lea dx, introduce_again_msg
    mov ah, 09h
    int 21h
    
    jmp GET_INPUT_STR_BEGIN    

GET_INPUT_STR_END:

    ; Restore previous state
    pop dx
    pop cx
    pop bx
    
    ret
Get_Input_Str endp

; Input:
;           BX -> Number to print
;           CX -> Base
; Output:
;           None
; Description:
;           Prints the number in AX as ASCII
Print_Number proc
    push ax
    push bx
    push cx
    push dx
    
    mov bp, sp
    
    mov ax, bx      
    
    cmp ax, 00h
    jne PRINT_NUMBER_GET_DIGITS
    mov dx, 030h
    push dx
    
PRINT_NUMBER_GET_DIGITS:
    cmp ax, 00h
    je PRINT_NUMBER_READY_TO_PRINT
    
    mov dx, 00h
    
    div cx
    
    cmp dx, 0ah
    jae PRINT_NUMBER_IS_NOT_NUMBER
    
    add dx, 30h
    push dx

    jmp PRINT_NUMBER_GET_DIGITS
     
PRINT_NUMBER_IS_NOT_NUMBER:
    add dx, 41h
    push dx   
    
    jmp PRINT_NUMBER_GET_DIGITS
    
PRINT_NUMBER_READY_TO_PRINT:
    cmp bp, sp
    je PRINT_NUMBER_FINISH
    
    pop dx
    mov ah, 02h
    int 21h
    jmp PRINT_NUMBER_READY_TO_PRINT
    
    
PRINT_NUMBER_FINISH:
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
Print_Number endp

; Input:    
;           AL -> Value to insert
;           BX -> String
; Output:
;           None
; Description:
;           
Push_To_Front proc
    pusha
    
    mov di, bx
    mov cx, 00h
    mov cl, [bx + 1]
    mov bx, 00
    mov ax, 00h
    
PUSH_TO_FRONT_SHIFT:
    mov bx, cx
    mov ah, [di + bx + 1]
    mov [di + bx + 2], ah
    loop PUSH_TO_FRONT_SHIFT    
    
    mov [di + 2], al
    
    popa
    ret
Push_To_Front  endp

; Input:
;           BX -> String
;           CX -> Index
; Output:
;           AX -> Hexadecimal value
; Description:
;
Get_Next_Word proc
    ; Store all registers state
    pusha
    
    ; Setup
    mov di, bx
    mov bx, cx
    mov dx, 0ah
    
    ; AX = str[0] * 10
    mov ax, 00h
    mov al, [di + bx + 2]
    mul dx
    
    ; AX = AX + str[1]
    mov dx, 00h
    mov dl, [di + bx + 3]
    add ax, dx
    
    ; Store the final result in the stack
    push ax
    pop ax
    
    ; Restore all registers state
    popa
    
    ; Restore the final result from the stack
    push bp
    mov bp, sp
    mov ax, [bp - 010h]
    pop bp
    
    ret
Get_Next_Word endp

Run_Division_Alg proc
    mov bp, sp
    
    lea dx, div_msg_a
    mov ah, 09h
    int 21h
    
    push bp         ; Store BP value
                
    lea ax, div_input_a_str 
    push ax
    mov ah, 0ah     ; Base 10 argument
    mov al, 01h     ; Do overflow validation argument
    push ax
    
    call Get_Input_Str
    
    mov div_input_a_value, ax   
    
    add sp, 04h     ; Remove previous arguments from stack (they are no longer needed!)
    
    call Print_Line_Break
    
    lea dx, div_msg_b
    mov ah, 09h
    int 21h
    
    lea ax, div_input_b_str 
    push ax
    mov ah, 0ah     ; Base 10 argument
    mov al, 01h     ; Do overflow validation argument
    push ax
    
    call Get_Input_Str
    
    mov div_input_b_value, ax   
    
    add sp, 04h     ; Remove previous arguments from stack (they are no longer needed!)
    
    pop bp          ; Restore BP value
    
    mov aux_var_a, 00h      ; Will store the result
    mov aux_var_b, 00h      ; Will store the remainder
    
    cmp div_input_b_value, 00h
    je RUN_DIVISION_ALG_UNDEFINED 
    
    mov cx, 00h
    mov cl, div_input_a_str[1]  ; Get the dividend length

RUN_DIVISION_ALG_BEGIN:        
    ; While the remainder is less than divisor, multiply it by 10 and add digits from dividend at specific index
    
    ; Remainder = Remainder x 10
    mov ax, aux_var_b       
    mov bx, 0ah
    mul bx 
    
    ; Get the index of dividend digit to use
    mov bx, 00h
    mov bl, div_input_a_str[1]
    sub bx, cx
    
    ; Remainder = Remainder + Dividend[index]
    mov bl, div_input_a_str[bx + 2] ; Get the digit at the current index
    mov bh, 00h
    add ax, bx
    
    mov aux_var_b, ax
    
    cmp ax, div_input_b_value
    jbe RUN_DIVISION_ALG_NEXT_ITERATION
          
    ; Store current CX state
    push cx
    
    mov cx, 00h

RUN_DIVISION_ALG_FIND_RESULT_DIGIT:
    inc cx
    mov ax, div_input_b_value
    mul cx
    
    cmp ax, aux_var_b
    jbe RUN_DIVISION_ALG_IS_LESS
    
    jmp RUN_DIVISION_ALG_IS_NOT_LESS
    
RUN_DIVISION_ALG_IS_LESS:
    cmp dx, 00h
    je RUN_DIVISION_ALG_FIND_RESULT_DIGIT
    
RUN_DIVISION_ALG_IS_NOT_LESS:    
    ; Remainder = Remainder - (CX x divisor)
    dec cx
    mov ax, div_input_b_value
    mul cx
    sub aux_var_b, ax
    
    ; Result = (Result x 10) + CX
    mov ax, aux_var_a
    mov bx, 0ah
    mul bx
    add ax, cx 
    mov aux_var_a, ax
          
    ; Restore the old CX state
    pop cx

    
RUN_DIVISION_ALG_NEXT_ITERATION:    
    loop RUN_DIVISION_ALG_BEGIN
    
    call Print_Line_Break                                      
    
    mov bx, div_input_a_value
    mov cx, 0ah
    call Print_Number
    
    lea dx, div_msg_result_pt1
    mov ah, 09h
    int 21h
    
    mov bx, div_input_b_value
    mov cx, 0ah
    call Print_Number
    
    lea dx, div_msg_result_pt2
    mov ah, 09h
    int 21h
    
    mov bx, aux_var_a
    mov cx, 0ah
    call Print_Number  
    
    lea dx, div_msg_result_pt3
    mov ah, 09h
    int 21h
    
    mov bx, aux_var_b
    mov cx, 0ah
    call Print_Number
    
    jmp RUN_DIVISION_ALG_FINISH
    
RUN_DIVISION_ALG_UNDEFINED:
    call Print_Line_Break

    mov bx, div_input_a_value
    mov cx, 0ah
    call Print_Number
    
    lea dx, div_msg_result_pt1
    mov ah, 09h
    int 21h
    
    mov bx, div_input_b_value
    mov cx, 0ah
    call Print_Number
    
    lea dx, div_msg_result_pt2
    mov ah, 09h
    int 21h
    
    lea dx, undefined_msg
    mov ah, 09h
    int 21h
    
RUN_DIVISION_ALG_FINISH:
        
    ret
Run_Division_Alg endp

Run_Sqrt_Alg proc
    mov bp, sp
    
    lea dx, sqrt_msg
    mov ah, 09h
    int 21h
    
    push bp         ; Store BP value
                
    lea ax, sqrt_input_str 
    push ax
    mov ah, 0ah     ; Base 10 argument
    mov al, 01h     ; Do overflow validation argument
    push ax
    
    call Get_Input_Str
    
    mov sqrt_input_value, ax
    
    add sp, 04h     ; Remove arguments from the stack
    
    pop bp          ; Restore BP value
    
    mov ax, 00h
    mov al, sqrt_input_str[1]
    
    mov bx, 02h
    
    mov dx, 00h
    
    div bx
    
    cmp dx, 00h
    je RUN_SQRT_ALG_IS_EVEN_NUMBER
    
    mov al, 00h
    lea bx, sqrt_input_str
    call Push_To_Front
    
RUN_SQRT_ALG_IS_EVEN_NUMBER:
                         
    mov aux_var_a[0], 00h   ; Remainder LS
    mov aux_var_a[1], 00h   ; Remainder MS
                                       
    mov aux_var_b[0], 00h   ; Result LS
    mov aux_var_b[1], 00h   ; Result MS
    
    lea bx, sqrt_input_str
    mov cx, 00h
    mov cl, sqrt_input_str[1]
    
RUN_SQRT_ALG_INTEGER_PART:
    push cx
    
    mov bx, 00h
    mov bl, sqrt_input_str[1]
    
    sub bx, cx
                            
                            ; Args:
    mov cx, bx              ;   CX = Index
    lea bx, sqrt_input_str  ;   BX = Str
    call Get_Next_Word
    
    pop cx
    
    loop RUN_SQRT_ALG_INTEGER_PART
    
    
    ret
Run_Sqrt_Alg endp

_begin:        
    call Init_Segments
    
    ;call Run_Division_Alg 
    
    call Run_Sqrt_Alg
      
    mov ah, 4ch
    int 21h
end _begin
