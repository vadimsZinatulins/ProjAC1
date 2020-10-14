; title "Projecto"

.model small

.stack 100h

.data
    ; Division algorithm specific variables
    div_ask_input_a_msg     db  "Introduza o dividendo: $"
    div_ask_input_b_msg     db  "Introduza o divisor: $"
    div_output_a_msg        db  "Resultado = $"
    div_output_b_msg        db  "Resto = $"
    
    div_input_a_str         db  5 DUP("$")
    div_input_a_len         db  0x0h
    div_input_a_val         dw  0x0h
    
    div_input_b_str         db  5 DUP("$")
    div_input_b_len         db  00h
    div_input_b_val         dw  00h
             
    ; SQRT algorithm specific variables
    sqrt_ask_input_msg      db  "Introduza o numero: $"
    sqrt_output_msg         db  "Resultado = $"
    
    sqrt_input_str          db  12 DUP("0")
    sqrt_input_len          db  0x0h
    sqrt_input_val          dw  0x0h    
    
    
    ; Global variables  
    aux_var_a               dw  00h
    aux_var_b               dw  00h
    
    line_break              db  0ah, 0dh, "$"
    
    introduction_msg        db  0ah, 0dh, "Escolha um algoritmo", 0ah, 0dh, "1) Divisao", 0ah, 0dh, "2) Raiz Quadrada", 0ah, 0dh, "3) Conversao", 0ah, 0dh, 0ah, 0dh, "q para sair", 0ah, 0dh, "$"
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

; Input: None
; Output: None
; Writes a BACKSPACE character to the screen
Write_Backspace proc
    mov ah, 02h ; Setup interrupt subroutine call to write a character    
    mov dl, 08h ; Select BACKSPACE character to write
    int 21h
    
    ret 
Write_Backspace endp

; Input: None
; Output: None
; Writes SPACE character followed by BACKSPACE character to the screen
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
; Writes a line break to the screen (i.e. advances cursor to the next line)
Write_Line_Break proc
    lea dx, line_break
    mov ah, 09h
    int 21h
    
    ret
Write_Line_Break endp

; Input:    Stack [SP + 8]  ->  Indicate if it is to check for overflow (1 to check, 0 to not check)
;           Stack [SP + 7]  ->  Max. number of digits to read
;           Stack [SP + 6]  ->  Address of the inputs string, input string will be stored in this address
;           Stack [SP + 4]  ->  Address of the input length, input length will be stored in this address
;           Stack [SP + 2]  ->  Address of the input value, input value will be stored in this address
; Output: None
; Reads input from the user and stores it's string (ASCII value) in argument Stack [SP + 6] address, input size 
; in Stack [SP + 4] address and hexadecimal value in Stack [SP + 2] address. 
; The caller doesn't need to pop values from the stack since this procedure does it!            
Get_Input proc
    mov bp, sp
    
    ; Get cursor position
    mov ah, 03h
    int 10h
    
    ;mov dh, 00h ; Set cursos row to 0 (we don't need it)
    push dx     ; Store the cursos row and column, this value is used to indicate that the cursos should not get less that
                ; this current column value (important when user presses BACKSPACE key)
    push bx     ; Store cursor current page aswell (this is needed to restore the current cursor state)
    
    ; Clear [SP + 6] (string input)
    mov di, [bp + 06h]  ; Get the address of input string and store it in DI
    mov cx, [bp + 08h]  ; Get the max. number of digits to read and store it in CX (this also stores the flag argument)
    mov ch, 00h         ; Remove the flag argument from cx
    dec cx              
GET_INPUT_CLEAR_STRING_INPUT:
    mov bx, cx
    mov [di + bx], "0"
    loop GET_INPUT_CLEAR_STRING_INPUT
    mov [di], "0" 
                                          
    ; Clear [SP + 4] (length of the input)
    mov di, [bp + 04h]  ; Get the address of the input length and store it in DI
    mov [di], 00h       ; Reset input lenght
    
    ; Clear [SP + 2] (input's hexadecimal value)
    mov ax, 00h
    mov di, [bp + 02h]  ; Get the address of the input value
    mov [di], ax        ; Reset input length
    
    ; Get the max. number of digits to read ([SP + 7])
    mov cx, [bp + 08h]  ; Get the max. number of digits to read and store it in CX (this also stores the flag argument)
    mov ch, 00h         ; Remove the flag argument from cx
    inc cx
        
GET_INPUT_PROPT_USER:
    mov ah, 01h
    int 21h
    
    ; Get the max. number of digits to read ([SP + 7])
    mov bx, [bp + 08h]  ; Get the max. number of digits to read and store it in BX (this also stores the flag argument)
    mov bh, 00h         ; Remove the flag argument from BX
    mov dx, bx          ; Save the max. number of digits to read into DX
    inc bx
    sub bx, cx          ; Get the number of digits already read
    
    cmp al, 0dh ; Compare user input with ENTER
    je GET_INPUT_FINALIZATION
    cmp al, 08h ; Compare user input with BACKSPACE
    je GET_INPUT_BACKSPACE_PRESSED
    cmp bx, dx ; If bx is greather than dx it means that all 5 bytes are full, user can only input ENTER or BACKSPACE
    jge GET_INPUT_INVALID_NUMBER
    cmp al, 30h ; If user input is less than 30h then it is invalid number
    jl GET_INPUT_INVALID_NUMBER
    cmp al, 39h ; If user input is less than 39h then it is invalid number
    jg GET_INPUT_INVALID_NUMBER
 
    ; Update [SP + 6](String input)
    mov di, [bp + 06h]    
    mov [di + bx], al
    
    ; Update [SP + 4](length of the input)
    mov di, [bp + 04h]
    inc [di]
    
    ; Update [SP + 2] (input's hexadecimal value)
    mov di, [bp + 02h}
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
    
    adc dx, dx
    
    ; Check if overflow validation is needed ([SP + 8])
    mov bx, [bp + 08h]  
    cmp bh, 00h
    je GET_INPUT_SKIP_OVERFLOW_VALIDATION
    
    ; Check for overflow error (after adition)
    cmp dx, 00h
    jne GET_INPUT_OVERFLOW_ERROR 

GET_INPUT_SKIP_OVERFLOW_VALIDATION:
    mov [di], ax  
    
    loop GET_INPUT_PROPT_USER
    
GET_INPUT_INVALID_NUMBER:
    call Write_Backspace
    call Write_Space_And_Backspace
    
    jmp GET_INPUT_PROPT_USER
    
GET_INPUT_BACKSPACE_PRESSED:
    inc cx
    
    ; Update [SP + 2] (input's hexadecimal value), divide it by 10
    add sp, 06h
    pop di
    sub sp, 08h
    mov ax, [di]
    mov bx, 0ah
    mov dx, 00h
    div bx
    mov [di], ax
    
    ; Update [SP + 4](length of the input), it needs to be decremented since one character was removed by user
    add sp, 08h
    pop di
    sub sp, 0ah
    dec [di]
    
    ; Make sure cx is never bigger than 6
    cmp cx, 06h
    jle GET_INPUT_CX_FIXED
    mov cx, 06h
    
    ; Update [SP + 4](length of the input) so it is never less than 0
    mov [di], 00h
    
    ; Update [SP + 2] (input's hexadecimal value) set it to 0
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
    add sp, 08h
    pop di
    sub sp, 0ah
    cmp [di], 00h
    je GET_INPUT_OVERFLOW_ERROR
    
    pop ax  ; Remove cursor page from stack
    pop ax  ; Remove cursor row and column from stack
    pop ax  ; Remove return address from stack
    
    pop bx  ; Remove argument [SP + 2] from stack
    pop bx  ; Remove argument [SP + 4] from stack
    pop bx  ; Remove argument [SP + 6] from stack
    pop bx  ; Remove argument [SP + 7] and [SP + 8] from stack
    
    push ax ; Store return address into stack
    
    ret
Get_Input endp
                  
; Input:    di  ->  Buffer address
;           ah  ->  Value to insert
; Output: None
; Shifts buffer (referenced by DI) to the right and inserts BH at the beginning
Push_To_Front proc
    mov cx, 04h

PUSH_TO_FRONT_SHIFT:
    mov bx, cx
    mov al, [di + bx]
    mov [di + bx + 1], al
    loop PUSH_TO_FRONT_SHIFT
    mov bx, cx
    mov al, [di + bx]
    mov [di + bx + 1], al
    mov [di], ah
    
    ret
Push_To_Front endp
       
; Input:    cx  ->  Number to print
;           di  ->  Reference to the buffer where ASCII value will be written
; Ouput: None
; Prints the hexadecimal value to screen as ascii 
Print_Num proc 
    mov [di], "$"    
PRINT_NUM_START:
    mov ax, cx
    mov bx, 0ah
    mov dx, 00h
    div bx
    mov cx, ax
    add dx, 30h
     
    push cx 
    mov ah, dl   
    call Push_To_Front
    pop cx
       
    cmp cx, 00h
    jg PRINT_NUM_START
               
    mov dx, di
    mov ah, 09h       
    int 21h
    
    ret
Print_Num endp   

Run_Division_Alg proc
    ; Ask for input A
    lea dx, div_ask_input_a_msg
    mov ah, 09h
    int 21h
    mov ah, 01h         ; Make sure overflow is checked 
    mov al, 05h         ; Read only at max. 5 digits
    push ax
    lea ax, div_input_a_str
    push ax
    lea ax, div_input_a_len
    push ax
    lea ax, div_input_a_val
    push ax
    call Get_Input
    
    call Write_Line_Break
    
    ; Ask for input B
    lea dx, div_ask_input_b_msg
    mov ah, 09h
    int 21h
    mov ah, 01h         ; Make sure overflow is checked 
    mov al, 05h         ; Read only at max. 5 digits
    push ax
    lea ax, div_input_b_str
    push ax
    lea ax, div_input_b_len
    push ax
    lea ax, div_input_b_val
    push ax
    call Get_Input
    
    cmp div_input_b_val, 00h
    je RUN_DIVISION_ALG_INF
                      
    mov aux_var_a, 00h      ; Remainder
    mov aux_var_b, 00h      ; Result
    mov di, 00h
RUN_DIVISION_ALG_CALC_REMAINDER:
    mov ax, 00h
    mov al, div_input_a_len
    cmp di, ax
    jge RUN_DIVISION_ALG_FINISHED
    
    mov ax, 0ah
    
    mov bx, 00h
    mov bl, [div_input_a_str + di]
    sub bx, 30h
    inc di
    
    mov dx, 00h
    
    mul aux_var_a
    add ax, bx
    mov aux_var_a, ax
    
    cmp ax, div_input_b_val
    jl RUN_DIVISION_ALG_CALC_REMAINDER
    
    mov cx, 00h
RUN_DIVISION_ALG_CALC_NEW_DIGIT:
    mov ax, cx
    mul div_input_b_val
    
    cmp ax, aux_var_a
    jg RUN_DIVISION_ALG_CALC_DIGIT_FOUND:
    
    inc cx
    cmp cx, 09h
    jl RUN_DIVISION_ALG_CALC_NEW_DIGIT

RUN_DIVISION_ALG_CALC_DIGIT_FOUND:
    dec cx
    mov ax, cx
    mul div_input_b_val
    
    sub aux_var_a, ax
    
    mov ax, 0ah
    mul aux_var_b
    add ax, cx
    mov aux_var_b, ax
                      
    mov ax, 00h
    mov al, div_input_a_len
    cmp di, ax
    jl RUN_DIVISION_ALG_CALC_REMAINDER
     
RUN_DIVISION_ALG_FINISHED:
    call Write_Line_Break
    
    ; Print the result
    lea dx, div_output_a_msg
    mov ah, 09h
    int 21h
    
    mov cx, aux_var_b
    lea di, div_input_b_str  
    call Print_Num  
    
    call Write_Line_Break
    
    ; Print the remainder
    lea dx, div_output_b_msg
    mov ah, 09h
    int 21h
    
    mov cx, aux_var_a
    lea di, div_input_b_str
    call Print_Num
    
    jmp RUN_DIVISION_ALG_TERMINATE
      
RUN_DIVISION_ALG_INF:
    mov [div_input_b_str + 0], "I"
    mov [div_input_b_str + 1], "N"
    mov [div_input_b_str + 2], "F"
    mov [div_input_b_str + 3], "$"
    
    call Write_Line_Break
    
    ; Print the result
    lea dx, div_output_a_msg
    mov ah, 09h
    int 21h
    
    lea dx, div_input_b_str
    mov ah, 09h
    int 21h
    
    call Write_Line_Break
    
    ; Print the remainder
    lea dx, div_output_b_msg
    mov ah, 09h
    int 21h
    
    lea dx, div_input_b_str
    mov ah, 09h
    int 21h
RUN_DIVISION_ALG_TERMINATE:
    
    ret
Run_Division_Alg endp

; Input:    Stack [SP + 6]  -> Start index
;           Stack [SP + 4]  -> Pair count
;           Stack [SP + 2]  -> Current result value
; Output:   AX              -> Final result
; 
Calc_Half_Sqrt proc
    ; Get the pair count
    add sp, 04h
    pop cx
    sub sp, 06h
    
CALC_HALF_SQRT_INTEGER_PART:
    ; Get start index
    add sp, 06h
    pop bx
    sub sp, 08h
    
    ; Get next pair index
    add sp, 04h
    pop ax
    sub sp, 06h
    sub ax, cx
    shl ax, 01h
    add ax, bx
    mov si, ax
    
    call Get_Pair
    
    push cx
    
    mov cx, ax
    mov ax, aux_var_a
    mov bx, 064h
    mov dx, 00h
    
    mul bx
    
    adc dx, dx
    
    add ax, cx
    
    adc dx, dx
    
    pop cx
    
    mov aux_var_a, ax
    
    cmp dx, 00h
    jne CALC_HALF_SQRT_OVERFLOW
    
    ; Place the result in DX
    add sp, 02h
    pop dx
    sub sp, 04h
    
    ; Multiplicate DX by 2   
    shl dx, 01h
    
    push cx
    
    mov cx, 00h
CALC_HALF_SQRT_INTEGER_PART_FIND_NUMBER:
    mov ax, dx
    push dx
    mov dx, 00h
    mov bx, 0ah
    mul bx
    adc dx, dx
    add ax, cx
    adc dx, dx
    mul cx
    adc dx, dx
    
    mov bx, dx
    pop dx
    
    cmp bx, 00h
    jne CALC_HALF_SQRT_OVERFLOW 
    
    cmp ax, aux_var_a
    jg CALC_HALF_SQRT_INTEGER_PART_FIND_NUMBER_DONE
    
    inc cx
    jmp CALC_HALF_SQRT_INTEGER_PART_FIND_NUMBER
    
CALC_HALF_SQRT_INTEGER_PART_FIND_NUMBER_DONE:
    
    dec cx 
    mov ax, dx
    mov bx, 0ah
    mul bx
    add ax, cx
    mul cx
    
    push ax
    
    ; Place the result in AX
    add sp, 06h
    pop ax
    sub sp, 08h
    
    mov bx, 0ah
    mul bx
    add ax, cx
    ; Place AX in result
    add sp, 08h
    push ax
    sub sp, 06h
    
    pop ax
    
    sub aux_var_a, ax
    
    pop cx
 
    loop CALC_HALF_SQRT_INTEGER_PART
    
    jmp CALC_HALF_SQRT_FINISHED
     
CALC_HALF_SQRT_OVERFLOW:
    ; Log some overflow message...
    
CALC_HALF_SQRT_FINISHED:
    add sp, 02h
    pop cx
    sub sp, 04h
    
    pop ax  ; Retrieve returning address from stack
                                                  
    pop bx  ; Remove Stack [SP + 2] from the stack
    pop bx  ; Remove Stack [SP + 4] from the stack 
    pop bx  ; Remove Stack [SP + 6] from the stack
    
    push ax ; Place returning address back to stack
    
    mov ax, cx
    
    ret
Calc_Half_Sqrt endp

; Input:    sqrt_input_str  -> String from wich pair will be obtained
;           si              -> Index from wich obtain pair
; Output:   ax              -> Hexadecimal value of obtained pair
; Reads 2 bytes from sqrt_input_str at ax index and converts them into hexadecimal value
Get_Pair proc
    mov ax, 00h
    mov al, [sqrt_input_str + si + 0]
    sub al, 30h
    
    mov bx, 0ah
    mul bx 
    
    mov bx, 00h
    mov bl, [sqrt_input_str + si + 1]
    sub bl, 30h
    
    add ax, bx
    ret
Get_Pair endp

Run_Sqrt_Alg proc 
    ; Ask for input A
    lea dx, sqrt_ask_input_msg
    mov ah, 09h
    int 21h
    mov ah, 00h         ; Don't check of overflow
    mov al, 09h         ; Read at max. 5 digits
    push ax
    lea ax, sqrt_input_str
    push ax
    lea ax, sqrt_input_len
    push ax
    lea ax, sqrt_input_val
    push ax
    call Get_Input
    call Write_Line_Break
    
    mov aux_var_a, 00h      ; Result
    mov aux_var_b, 00h      ; Remainder
    
    mov ax, 00h
    mov al, sqrt_input_len
    mov bx, 02h
    div bl
    
    mov sqrt_input_len, al
    
    cmp ah, 00h
    je RUN_SQRT_ALG_EVEN_INPUT
    inc sqrt_input_len
    lea di, sqrt_input_str
    mov ah, 030h
    call Push_To_Front
    
RUN_SQRT_ALG_EVEN_INPUT:
    ; add sqrt_input_len, 02h
    mov ax, 00h
    push ax
    mov al, sqrt_input_len
    push ax
    mov ax, 00h
    push ax  
    
    call Calc_Half_Sqrt
    mov aux_var_b, ax
    
    mov bx, 00h
    mov bl, sqrt_input_len
    shl bx, 01h
    push bx
    mov bx, 02h
    push bx
    push ax
    
    call Calc_Half_Sqrt
    
    push ax
    
    mov cx, aux_var_b
    lea di, sqrt_input_str  
    call Print_Num
    
    pop cx
    lea di, sqrt_input_str  
    call Print_Num
    
    ret
Run_Sqrt_Alg endp

Run_Conversion_Alg proc
    ret
Run_Conversion_Alg endp

_begin:        
    call Init_Segments
    
MAIN_LOOP:
    mov ax, 0ffffh
    push ax
    mov bp, sp
    mov dx, [bp]    
    pop ax
    
    
    lea dx, introduction_msg
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    
    cmp al, 051h
    je QUIT_MAIN_LOOP
    cmp al, 071h
    je QUIT_MAIN_LOOP
    cmp al, 031h 
    je MAIN_RUN_DIVISION_ALG
    cmp al, 032h 
    je MAIN_RUN_SQRT_ALG
    cmp al, 33h
    je MAIN_RUN_CONVERSION_ALG
    jmp MAIN_LOOP
    
MAIN_RUN_DIVISION_ALG:
    call Write_Line_Break
    call Run_Division_Alg
    call Write_Line_Break
    
    jmp MAIN_LOOP

MAIN_RUN_SQRT_ALG:
    call Write_Line_Break
    call Run_Sqrt_Alg
    call Write_Line_Break
    
    jmp MAIN_LOOP
    
MAIN_RUN_CONVERSION_ALG:
    call Write_Line_Break
    call Run_Conversion_Alg
    call Write_Line_Break
    
    jmp MAIN_LOOP

QUIT_MAIN_LOOP: 
    mov ah, 4ch
    int 21h
end _begin
