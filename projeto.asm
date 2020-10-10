; title "Projecto"

.model small

.stack 100h

.data    
    ; Outras variaveis         
    input_a_str         db  5 DUP("$")
    input_a_len         db  5
    input_a_val         dw  5
    
    some_msg            db  "Hello World!$"
    
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
    add sp, 08h
    pop di
    sub sp, 0ah
    mov cx, 04h    
 GET_INPUT_CLEAR_STRING_INPUT:
    mov bx, cx
    mov [di + bx], "$"
    loop GET_INPUT_CLEAR_STRING_INPUT
    mov bx, cx
    mov [di + bx], "$" 
                                          
    ; Clear [SP - 4] (length of the input)
    add sp, 06h
    pop di
    sub sp, 08h
    mov [di], 0 
    
    ; Clear [SP - 2] (input's hexadecimal value)
    add sp, 04h
    pop di
    sub sp, 06h
    mov [di], 0
    
    mov cx, 06h
    jmp GET_INPUT_PROPT_USER
 GET_INPUT_INVALID_NUMBER:
    call Write_Backspace
    
 GET_INPUT_BACKSPACE_PRESSED:
    ; Get cursos current state
    mov ah, 03h
    int 10h
    
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
    
 GET_INPUT_PROPT_USER:
    mov ah, 01h
    int 21h
    
    mov di, 06h
    sub di, cx
    
    cmp al, 0dh ; Compare user input with ENTER
    je GET_INPUT_FINALIZATION
    cmp al, 08h ; Compare user input with BACKSPACE
    je GET_INPUT_BACKSPACE_PRESSED
    cmp di, 05h ; If di is 1 it means that all 5 bytes are full, user can only input ENTER or BACKSPACE
    je GET_INPUT_INVALID_NUMBER
    cmp al, 30h ; If user input is less than 30h then it is invalid number
    jl GET_INPUT_INVALID_NUMBER
    cmp al, 39h ; If user input is less than 39h then it is invalid number
    jg GET_INPUT_INVALID_NUMBER
    
    loop GET_INPUT_PROPT_USER

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

_begin:
    call Init_Segments

    lea ax, input_a_str
    push ax
    
    lea ax, input_a_len
    push ax
    
    lea ax, input_a_val
    push ax
    
    lea dx, some_msg
    mov ah, 09h
    int 21h 
    
    call Get_Input
     
    mov ah, 4ch
    int 21h
end _begin
