title "Projecto"

.model large

.stack 100h

.data    
    ; Outras variaveis         
    input_a_str         db  5 DUP("$")
    input_a_len         db  0
    input_a_val         dw  0
    
.code

; Input: None
; Output: None
; Initializes ds and es (i.e. make them reference data segment)
proc_init_segments proc
    mov ax, @data
    MOV ds, ax
    MOV es, ax
    RET
proc_init_segments endp

_begin:
    call proc_init_segments
    
    
    mov ah, 4ch
    int 21h
end _begin
