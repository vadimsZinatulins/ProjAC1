; title "Projecto"

.model small

.stack 100h

.data
    ; Division algorithm specific variables
    ask_input_a_msg     db  "Introduza o dividendo: $"
    ask_input_b_msg     db  "Introduza o divisor: $"
    
    ; Global variables
    input_a_str         db  5 DUP("$")
    input_a_len         db  0x0h
    input_a_val         dw  0x0h
    
    input_b_str         db  5 DUP("$")
    input_b_len         db  00h
    input_b_val         dw  00h
                               
    aux_var_a           dw  00h
    aux_var_b           dw  00h
    
    line_break          db  0ah, 0dh, "$"
.code

; Input: None
; Output: None
; Initializes ds and es (i.e. make them reference data segment)
Init_Segments proc
    mov ax, @data
    MOV ds, ax
    MOV es, ax
    ret
Init_Segments endp
    
; Input:    ax  -> Cursor current state (row and column)
;           dx  -> Cursor old state (row and column)
;           bl  -> Cursor old page
; Output: None
; Compares the column of the cursor in the current state with the old state, and if the 
; current state is less than old state then the cursor will be reset to the old state.
Validate_Cursor_State proc
    cmp ax, dx
    jge VALIDATE_CURSOR_STATE_END
    
    mov ah, 02h
    int 10h
    
VALIDATE_CURSOR_STATE_END:   
    ret
Validate_Cursor_State endp

Write_Backspace proc
    mov ah, 02h ; Setup interrupt subroutine call to write a character    
    mov dl, 08h ; Select BACKSPACE character to write
    int 21h
    
    ret 
Write_Backspace endp

; Input: None
; Output: None
; Write SPACE character and then BACKSPACE character to the screen
Write_Space_And_Backspace proc
    mov ah, 02h ; Setup interrupt subroutine call to write a character
    mov dl, 20h ; Select SPACE character to write
    int 21h
    
    mov dl, 08h ; Select BACKSPACE character to write
    int 21h
    
    ret
Write_Space_And_Backspace endp

; Input: None
; Output: None
; Writes a line break to the screen
Write_Line_Break proc
    lea dx, line_break
    mov ah, 09h
    int 21h
    
    ret
Write_Line_Break endp

; Input:    [SP + 6] -> Address of input string
;           [SP + 4] -> Address of input length
;           [SP + 2] -> Address of input value
; Output: None
; Reads input from the user and stores it's string (decimal value in ASII) in argument [SP + 6], input size
; in [SP + 4] and hexadecimal value in [SP + 2]. 
; The caller doesn't need to pop values from the stack since this procedure does it!            
Get_Input proc
    ; Get cursor position
    mov ah, 03h
    int 10h
    
    ;mov dh, 00h ; Set cursos row to 0 (we don't need it)
    push dx     ; Store the cursos row and column, this value is used to indicate that the cursos should not get less that
                ; this current column value (important when user presses BACKSPACE key)
    push bx     ; Store cursor current page aswell (this is needed to restore the current cursor state)
    
    ; Clear [SP - 6] (string input)
    mov ax, 00h
    mov al, "$"
    add sp, 0ah
    pop di
    sub sp, 0ch
    mov cx, 04h    
GET_INPUT_CLEAR_STRING_INPUT:
    mov bx, cx
    mov [di + bx], al
    loop GET_INPUT_CLEAR_STRING_INPUT
    mov bx, cx
    mov [di + bx], "$" 
                                          
    ; Clear [SP - 4] (length of the input)
    mov ax, 00h
    add sp, 08h
    pop di
    sub sp, 0ah
    mov [di], al 
    
    ; Clear [SP - 2] (input's hexadecimal value)
    mov ax, 00h
    add sp, 06h
    pop di
    sub sp, 08h
    mov [di], ax
    
    mov cx, 06h
        
GET_INPUT_PROPT_USER:
    mov ah, 01h
    int 21h
    
    mov bx, 06h
    sub bx, cx
    
    cmp al, 0dh ; Compare user input with ENTER
    je GET_INPUT_FINALIZATION
    cmp al, 08h ; Compare user input with BACKSPACE
    je GET_INPUT_BACKSPACE_PRESSED
    cmp bx, 05h ; If di is 1 it means that all 5 bytes are full, user can only input ENTER or BACKSPACE
    jge GET_INPUT_INVALID_NUMBER
    cmp al, 30h ; If user input is less than 30h then it is invalid number
    jl GET_INPUT_INVALID_NUMBER
    cmp al, 39h ; If user input is less than 39h then it is invalid number
    jg GET_INPUT_INVALID_NUMBER
 
    ; Update [SP - 6](String input)   
    add sp, 0ah
    pop di
    sub sp, 0ch 
    mov [di + bx], al
    
    ; Update [SP - 4](length of the input)
    add sp, 08h
    pop di
    sub sp, 0ah
    inc [di]
    
    ; Update [SP - 2] (input's hexadecimal value)
    add sp, 06h
    pop di
    sub sp, 08h
    mov bx, [di]
    
    push cx         ; Store current loop state
    mov cx, 00h
    mov cl, al      ; Save user input into cl
    sub cx, 30h     ; Convert ascii input to machine numeric value
    
    mov dx, 00h
    mov ax, 0ah
    mul bx
    
    ; Check for overflow error (after multiplication)
    adc dx, dx
    
    add ax, cx
    
    pop cx          ; Restore current loop state
    
    ; Check for overflow error (after adition)
    adc dx, dx
    cmp dx, 00h
    jne GET_INPUT_OVERFLOW_ERROR 
    
    mov [di], ax  
    
    loop GET_INPUT_PROPT_USER
    
GET_INPUT_INVALID_NUMBER:
    call Write_Backspace
    call Write_Space_And_Backspace
    
    jmp GET_INPUT_PROPT_USER
    
GET_INPUT_BACKSPACE_PRESSED:
    inc cx
    
    ; Update [SP - 2] (input's hexadecimal value), divide it by 10
    add sp, 06h
    pop di
    sub sp, 08h
    mov ax, [di]
    mov bx, 0ah
    mov dx, 00h
    div bx
    mov [di], ax
    
    ; Update [SP - 4](length of the input), it needs to be decremented since one character was removed by user
    add sp, 08h
    pop di
    sub sp, 0ah
    dec [di]
    
    ; Make sure cx is never bigger than 6
    cmp cx, 06h
    jle GET_INPUT_CX_FIXED
    mov cx, 06h
    
    ; Update [SP - 4](length of the input) so it is never less than 0
    mov [di], 00h
    
    ; Update [SP - 2] (input's hexadecimal value) set it to 0
    add sp, 06h
    pop di
    sub sp, 08h
    mov ax, 00h
    mov [di], ax                         
GET_INPUT_CX_FIXED:    
    ; Save curret loop state
    push cx
    
    ; Get cursos current state
    mov ah, 03h
    int 10h
    
    ; Restore loop state
    pop cx
    
    ; Move cursor row and column to ax
    mov ax, dx
    
    ; Restore cursor default state
    pop bx
    pop dx
    
    ; Store cursor default state (so it can be used again)
    push dx
    push bp

    call Validate_Cursor_State
       
    call Write_Space_And_Backspace    
    
    jmp GET_INPUT_PROPT_USER

GET_INPUT_OVERFLOW_ERROR:
    pop bx
    pop dx
    
    push dx
    push bx
    
    mov ah, 02h
    int 10h
    
    add sp, 0ah
    pop di
    sub sp, 0ch
    mov [di + 0], " "
    mov [di + 1], " "
    mov [di + 2], " "
    mov [di + 3], " "
    mov [di + 4], " "
    mov [di + 5], "$"
    
    mov dx, di
    mov ah, 09h
    int 21h
    
    pop bx
    pop dx
    
    mov ah, 02h
    int 10h
    
    jmp Get_Input
GET_INPUT_FINALIZATION:
    pop ax  ; Remove cursor page from stack
    pop ax  ; Remove cursor row and column from stack
    pop ax  ; Remove return address from stack
    
    pop bx  ; Remove argument [SP + 2] from stack
    pop bx  ; Remove argument [SP + 4] from stack
    pop bx  ; Remove argument [SP + 6] from stack
    
    push ax ; Store return address into stack
    
    ret
Get_Input endp

Run_Division_Alg proc
    ; Ask for input A
    lea dx, ask_input_a_msg
    mov ah, 09h
    int 21h
    lea ax, input_a_str
    push ax
    lea ax, input_a_len
    push ax
    lea ax, input_a_val
    push ax
    call Get_Input
    
    call Write_Line_Break
    
    ; Ask for input B
    lea dx, ask_input_b_msg
    mov ah, 09h
    int 21h
    lea ax, input_b_str
    push ax
    lea ax, input_b_len
    push ax
    lea ax, input_b_val
    push ax
    call Get_Input
    
    mov di, 00h
RUN_DIVISION_ALG_CALC_REMAINDER:
    
    inc di
    cmp di, 04h
    jle RUN_DIVISION_ALG_CALC_REMAINDER 
    
    ret
Run_Division_Alg endp
_begin:        
    call Init_Segments
    
    call Run_Division_Alg 
    mov ah, 4ch
    int 21h
end _begin
