TITLE "Projecto"

.MODEL LARGE

.STACK 100H

.DATA
    ; Variaveis gerais do programa (nao pertencem a nenhum algoritmo em especifico)
    INITIAL_MSG         DB  "Escolha o algoritmo a utilizar (use as 'i' e 'k' para escolher):$"
    
    DIVISION_INI_MSG    DB  "Algoritmo da divisao$"
    SQRT_INIT_MSG       DB  "Algorito da raiz quadrada$"
    CONVERSION_INIT_MSG DB  "Algoritmo da conversao$"
    
    CURRENT_ALG         DB  0
    
    CLEAN_LINE          DB  80 DUP(" "), "$"
    LINE_BREAK          DB  0Dh, 0Ah, "$"
    
    ; Variaveis do algoritmo da divisao

.CODE

; Procedimento que inicializa o registos DS e ES
INIT_SEGMENTS PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    RET
INIT_SEGMENTS ENDP

; Procedimento que apaga um linha inteira (80 characteres)
CLEAR_LINE PROC
    MOV AH, 03h
    INT 10h

    MOV DL, 00h
    
    MOV AH, 02h
    INT 10h
    
    LEA DX, CLEAN_LINE
    MOV AH, 09h
    INT 21h
    
    MOV AH, 03h
    INT 10h

    MOV DL, 00h
    
    MOV AH, 02h
    INT 10h
    
    RET
CLEAR_LINE ENDP

; Procedimento que permite o utilizador escolher que algoritmo utilizar
CHOOSE_ALG PROC
    ; Mostrar mensagem inicial
    LEA DX, INITIAL_MSG
    MOV AH, 09h
    INT 21h
    
    ; Mudar de linha
    LEA DX, LINE_BREAK
    MOV AH, 09H
    INT 21h

 CHOOSE_ALG_GET_KEY:
    ; Limpar a linha
    CALL CLEAR_LINE
    
    ; Se 'CURRENT_ALG' for igual a 0 entao mostar a mensagem de 'DIVISION_INI_MSG'
    CMP CURRENT_ALG, 00h
    JE PRINT_DIVISION_MSG_CHOOSE_ALG
    
    ; Se 'CURRENT_ALG' for igual a 1 entao mostar a mensagem de 'SQRT_INIT_MSG'
    CMP CURRENT_ALG, 01h
    JE PRINT_SQRT_MSG_CHOOSE_ALG
    
    ; Por exclusao de parte, mostra a mensagem de 'CONVERSION_INIT_MSG'
    LEA DX, CONVERSION_INIT_MSG
    MOV AH, 09h
    INT 21h
    JMP END_PRINT_CHOOSE_ALG
     
 PRINT_DIVISION_MSG_CHOOSE_ALG:
    LEA DX, DIVISION_INI_MSG
    MOV AH, 09h
    INT 21h
    JMP END_PRINT_CHOOSE_ALG
    
 PRINT_SQRT_MSG_CHOOSE_ALG:
    LEA DX, SQRT_INIT_MSG
    MOV AH, 09h
    INT 21h
    JMP END_PRINT_CHOOSE_ALG
 
 END_PRINT_CHOOSE_ALG:  
    ; Ler input do utilizador    
    MOV AH, 01h
    INT 21h
 
    ; Guardar o valor do utilizador (que esta em AL) na pilha   
    PUSH AX
    
    ; Mover o cursor para tras      
    MOV DL, 08h
    MOV AH, 02h
    INT 21h
    
    ; Escrever caracter 'SPACE'
    MOV DL, 20h
    MOV AH, 02h
    INT 21h
    
    ; Mover o cursor para tras
    MOV DL, 08h
    MOV AH, 02h
    INT 21h
    
    ; Retiar o valor do utilizador da pilha
    POP AX
    
    ; Caso o valor introduzido pelo utilizador seja 'i' ou 'I' entao incrementar 'CURRENT_ALG'
    ; Caso o valir introduzido pelo utilizador seja 'k' ou 'K' entao decrementar 'CURRENT_ALG'
    ; Caso o valir introduzido pelo utilizador seja 'ENTER' entao saltar para 'RET_CHOOSE_ALG'
    ; Para os restantes valores, voltar a solicitar o input 
    CMP AL, 'i'
    JE INC_CHOOSE_ALG
    CMP AL, 'I'
    JE INC_CHOOSE_ALG
    CMP AL, 'k'
    JE DEC_CHOOSE_ALG
    CMP AL, 'K'
    JE DEC_CHOOSE_ALG
    CMP AL, 0Dh
    JE RET_CHOOSE_ALG
    
    JMP CHOOSE_ALG_GET_KEY
    
    ; Incrementa 'CURRENT_ALG'. Se resultado final de 'CURRENT_ALG' for menor que 3 entao salta
    ; para 'CHOOSE_ALG_GET_KEY', caso seja maior ou igual entao mete 'CURRENT_ALG' a 0 e salta
    ; para 'CHOOSE_ALG_GET_KEY'
 INC_CHOOSE_ALG:
    INC CURRENT_ALG    
    CMP CURRENT_ALG, 03h
    JL CHOOSE_ALG_GET_KEY
    MOV CURRENT_ALG, 00h
    JMP CHOOSE_ALG_GET_KEY
    
    ; Decrenebta 'CURRENT_ALG'. Se resultado final de 'CURRENT_ALG' for maior ou igual a 0 entao salta
    ; para 'CHOOSE_ALG_GET_KEY', caso seja meno entao mete 'CURRENT_ALG' a 2 e salta
    ; para 'CHOOSE_ALG_GET_KEY' 
 DEC_CHOOSE_ALG:
    DEC CURRENT_ALG
    CMP CURRENT_ALG, 00h
    JGE CHOOSE_ALG_GET_KEY
    MOV CURRENT_ALG, 02h
    JMP CHOOSE_ALG_GET_KEY
    
 RET_CHOOSE_ALG:    
    RET
CHOOSE_ALG ENDP

CHECK_KEY_IN_BUFFER PROC
    ; Verificar se existe alguma tecla em buffer
    XOR AL, AL
    MOV AH, 01h
    INT 21h
    
    ; Se ZF = 0 significa que buffer esta vazio
    JZ RET_CHECK_KEY_IN_BUFFER
    
    ; Retirar tecla do buffer
    MOV AH, 00h
    INT 16h
    
 RET_CHECK_KEY_IN_BUFFER:    
    RET
CHECK_KEY_IN_BUFFER ENDP

DIVISION_ALG PROC
    
    RET
DIVISION_ALG ENDP

_BEGIN:
    CALL INIT_SEGMENTS
                   
    CALL CHOOSE_ALG
    
    MOV AH, 4Ch
    INT 21h
END _BEGIN