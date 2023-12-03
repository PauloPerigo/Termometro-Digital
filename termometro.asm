;PAULO HENRIQUE DE CAMARGO DIONYSIO MARTINS
;RA: 221026169

; ----------------------------- CAMPO EXPLICACOES ------------------------------------
 	;------------------------------- LCD ---------------------------------------
	;LCD_DATA -> PORTA DE SAIDA DO LCD, PORTB

	;BANK0 -> BCF STATUS, RP0
	;BANK1 -> BSF STATUS, RP0
	
	;PRINCIPAL ESTA CONFIGURANDO O PIC E SUAS PORTAS.

	;BUSY CHECK -> SUB ROTINA RECOMENDADA PELO FABRICANTE, SUA FUNCAO E ESPERAR A INCIALIZACAO DO LCD
	;PARA VOCE ESPERAR QUE O LCD ESTEJA PRONTO PARA RECEBER UM COMANDO

	;DD RAM -> COMANDO QUE SERVE PARA GUARDAR A POSICAO DO CURSOR DO LCD

	;RW -> READ/WRITE, BIT DE ADCON0 PARA QUE SAIA DO LOOP APENAS QUANDO ESTIVER COM B'00100001' (GO_DONE)
	;RW -> 0 -> ESCRITA
	;RW -> 1 -> LEITURA

	;EN -> HABILITA O LCD

	;RS -> REGISTRO DE SELECAO DO LCD


	;------------------------ SENSOR DE TEMPERATURA ------------------------------
	
	;VAMOS CRIAR UM REGISTRADOR NA MEMORIA DO PIC, PARA QUE POSSAMOS COLETAR O DADO DA PORTA ANALOGICA 
	;RECEBIDO PELO SENSOR DE TEMPERATURA LM35

	;GO_DONE -> BIT DE ADCON0 PARA QUE SAIA DO LOOP APENAS QUANDO ESTIVER COM B'00100001'

#include <P16F873A.inc>

;----------- DEFININDO AS PORTAS DE ENTRADA/SAIDA DO DISPLAY ----------------

#DEFINE LCD_DATA 	PORTB						;SAIDAS/ENTRADAS LCD -> (RB0, RB1, RB2, ..., RB7)
#DEFINE RS			PORTA, 1					;REGISTRO DE SELECAO LCD
#DEFINE RW			PORTA, 2					;ESCRITA/LEITURA LCD
#DEFINE EN			PORTA, 3					;HABILITAR LCD

;----------- PAGINACAO DE MEMORIA ----------------------------------------------

#DEFINE bank0 BCF STATUS, RP0					;SELECIONA O BANCO 0 DE MEMORIA
#DEFINE bank1 BSF STATUS, RP0					;SELECIONA O BANCO 1 DE MEMORIA

;----------- REGISTRADORES ----------------------------------------------------
CBLOCK	0x20									;INICIO DAS MEMORIA
	
	CMD 										;REG. COMANDOS DO LCD
	T0											;REG. AUXILIAR PARA TEMPORIZACAO
	T1											;REG. AUXILIAR PARA TEMPORIZACAO
	DISP										;REG. MOSTRA DISPLAY
	ANVAL										;REG. QUE ARMAZENA VALOR ANALOGICO RECEBIDO
	TEMP_DEZ									;REG. PARA DEZENA DA TEMPERATURA
	TEMP_UNI									;REG. PARA UNIDADE DA TEMPERATURA
	SUBTRACAO									;REG. PARA AUXILIAR NA SUBTRACAO

	
ENDC											;FINAL DA MEMORIA

;----------- RESET -------------------------------------------------------------
ORG 0x00										;ORIGEM DO H'00' DE MEMORIA
GOTO INICIO										;MOVE PARA A LABEL INICIO


;------------ PRINCIPAL ------------------------------------------------------
INICIO:
    bank1     								    ;SELECIONA O BANCO 1 DE MEMORIA
	;PROGRAMANDO AS PORTAS ANx COMO DIGITAIS
	MOVLW H'8E'									;MOVE LITERAL B'10001110' PARA WORK
	MOVWF ADCON1								;APENAS AN0 COMO ANALOGICO
	MOVLW H'31'									;MOVE LITERAL B'00110001' PARA WORK
	MOVWF TRISA									;CONFIGURA RA1, RA2 E RA3 COMO SAIDA
	MOVLW H'00'									;MOVE LITERAL H'00' PARA WORK
	MOVWF TRISB									;CONFIGURA PORTB COMO SAIDA
	
	bank0       								;SELECIONA O BANCO 0 DE MEMORIA
	CLRF PORTA									;LIMPA PORTA
	CLRF LCD_DATA								;LIMPA PORTB
	CLRF DISP									;LIMPA REG. DISP
	
	CALL MEIO_SEGUNDO							;ESPERA MEIO SEGUNDO
	CALL LCD_INICIALIZA							;INICIA LCD
	CALL ADC_INICIALIZA							;INICIA CONVERSAO ANALOG/DIGITAL		
	
;----------- LOOP INFINITO --------------------------------------------------------
loop:
	
	CALL MEIO_SEGUNDO 							;ESPERA MEIO SEGUNDO
	CALL MEIO_SEGUNDO							;ESPERA MEIO SEGUNDO
	MOVLW H'01'									;MOVE LITERAL PARA WORK
	CALL LCD_COMMAND							;LIMPA O DISPLAY
	CALL ADC_READ								;LEIA O VALOR ANALOGICO DA TEMPERATURA
	CALL LCD_PRINT								;ENVIA PARA O LCD O VALOR

	goto loop									;volta para o loop


;------------ INICIALIZACAO DO LCD -------------------------------------------------
;--------------------- MENSAGEM PARA O LCD -------------------
LCD_PRINT:

	MOVLW	' '									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA O LCD
	MOVLW	' '									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA O LCD
	MOVLW 	'T'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'E'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'M'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'P'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'E'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'R'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'A'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'T'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'U'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'R'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'A'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	
	MOVLW	H'C0'								;COMANDO PARA MUDAR DE LINHA
	CALL 	LCD_COMMAND							;ENVIA COMANDO PARA LCD
	MOVLW	' '									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA O LCD
	MOVLW	' '									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA O LCD
	MOVLW	' '									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA O LCD
	MOVLW	' '									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA O LCD
	MOVLW	' '									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA O LCD
	MOVLW	' '									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA O LCD

	CLRF	LCD_DATA							;DA CLEAR EM TODO PORTB
	MOVF	ANVAL, W							;ENVIA VALOR DE ANVAL PARA W
	MOVWF 	SUBTRACAO							;MOVE O CONTEUDO DE WORK PARA REG. QUE SERA SUBTRAIDO
	CLRF    TEMP_DEZ							;ZERA O VALOR DA DEZENA
	CLRF    TEMP_UNI							;ZERA O VALOR DA UNIDADE
	
	CALL 	CALC_TEMP							;CALCULA DEZENA E UNIDADE
	MOVF	TEMP_DEZ, W							;W = TEMP_DEZ
	ADDLW	D'48'								;SOMA COM 48, POIS O 48 EH O VALOR 0 NA TABELA ASCII
	CALL	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVF	TEMP_UNI, W							;W = TEMP_UNI
	ADDLW	D'48'								;SOMA COM 48, POIS O 48 EH O VALOR 0 NA TABELA ASCII
	CALL	LCD_CHAR							;ENVIA CARACTERE PARA LCD

	MOVLW 	' '									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
	MOVLW 	'C'									;MOVE CARACTERE PARA WORK
	CALL 	LCD_CHAR							;ENVIA CARACTERE PARA LCD
		

	
	RETLW 	H'00'								;RETORNA LIMPANDO WORK

;----------- MENSAGEM DE CARACTERE LCD ----------------
LCD_CHAR:

	MOVWF CMD									;MOVE CONTEUDO PARA WORK
	CALL BUSY_CHECK								;AGUARDA LCD FICAR PRONTO
	BCF RW										;LCD EM MODO DE LEITURA
	BSF RS										;LCD EM MODO COMANDO
	BSF EN										;HABILITA LCD
	MOVF CMD, W									;MOVE CONTEUDO DE CMD PARA WORK
	MOVWF LCD_DATA								;ENVIA DADOS PARA O LCD
	BCF EN										;DESABILITA LCD
	RETLW H'00'									;RETORNA COM WORK = 0

;---- SUB ROTINA PARA INICIALIZAR O LCD ----
LCD_INICIALIZA:

	;FUNCTION SET - DATASHEET LCD
	MOVLW H'38' 								;MOVE LITERAL B'00111000' PARA WORK
	CALL LCD_COMMAND							;ENVIA COMANDO PARA LCD MODO 8bits
												;LCD COM 2 LINHAS
												;RESOLUCAO DOS CARACTERES: 5x7 PONTOS
	
	;DISPLAY ON/OFF CONTROL - DATASHEET LCD											
	MOVLW H'0E'									;MOVE LITERAL B'00001111' PARA WORK
	CALL LCD_COMMAND							;LIGA DISPLAY
												;LIGA CURSOR
												;BLINK DESABILITADO (PISCA-PISCA)
										
	;ENTRY MODE SET - DATASHEET LCD											
	MOVLW H'06'									;MOVE LITERAL B'00000110' PARA WORK
	CALL LCD_COMMAND							;INCREMENTO DO DISPLAY/DESLOCAMENTO DO CURSOR
	
	;CLEAR DISPLAY - DATASHEET LCD
	MOVLW H'01'									;MOVE LITERAL H'01' PARA WORK
	CALL LCD_COMMAND							;LIMPA O DISPLAY
	
	RETLW H'00'									;RETORNA LIMPANDO O WORK
	
;---- SUB ROTINA PARA ENVIO DE COMANDOS LCD ----
LCD_COMMAND:
	MOVWF CMD									;MOVE O H'38' DE WORK PARA CMD
	CALL BUSY_CHECK								;AGUARDA O LCD FICAR PRONTO
	BCF RW										;LCD MODO LEITURA
	BCF RS										;LCD MODO COMANDO
	BSF EN										;HABILITA LCD
	MOVF CMD, W									;MOVE CONTEUDO DE CDM PARA WORK
	MOVWF LCD_DATA								;ENVIA DADO PARA O LCD (ENVIA PARA O PORTB)
	BCF EN										;DESABILITA LCD
	RETLW H'00'									;RETORNA LIMPANDO WORK
	
;---- SUB ROTINA PARA CHEGAR A BUSY FLAG ----
BUSY_CHECK:
	bank1       								;SELECIONA O BANCO 1 DE MEMORIA
	
	MOVLW H'FF'									;MOVE LITERAL B'11111111' PARA WORK
	MOVWF TRISB									;CONFIGURA PORTB INTEIRO COMO ENTRADA
	
	bank0       								;SELECIONA O BANCO 0 DE MEMORIA
	BCF RS										;LCD MODO COMANDO
	BSF RW										;LCD MODO ESCRITA
	BSF EN										;HABILITA LCD
	MOVF LCD_DATA, W							;LE O BUSY FLAG, ENDERECO DDram
	BCF EN										;DESABILITA LCD
	ANDLW H'80'									;LIMPA BITS NAO USADOS
	BTFSS STATUS, Z								;CHEGOU EM ZERO?
	GOTO BUSY_CHECK								;CONTINUA O TESTE
	
SAIDABUSY:
	BCF RW										;LCD MODO LEITURA
	bank1       								;SELECIONA O BANCO 1 DE MEMORIA
	MOVLW H'00'									;MOVE LITERAL H'00' PARA WORK
	MOVWF TRISB									;CONFIGURA TODO O PORTB COMO SAIDA
	bank0           							;SELECIONA O BANCO 0 DE MEMORIA
	RETLW H'00'									;RETORNA LIMPANDO O WORK
	

;--------------------- SENSOR DE TEMPERATURA -------------------------------------

; ---- INICIALIZA CONVERSOR AD ----
ADC_INICIALIZA:

	;ADCON1
	bank1										;SELECIONA O BANCO 1 DE 
	MOVLW H'8E'									;MOVENDO LITERAL B'10001110' PARA WORK
	MOVWF ADCON1								;CONFIGURANDO ADC1 COMO TUDO DIGITAL, APENAS O RA0 COMO ANALOGICO

	;ADCON0
	bank0
	MOVLW H'41'									;MOVENDO LITERAL H'41' PARA WORK
	MOVWF ADCON0								;SETANDO ADCON0
	
	RETURN


; ---- SUB ROTINA PARA LEITURA DO CANAL AD -----
ADC_READ:

	bank0										;SELECIONA O BANCO 0 DE MEMORIA
	BSF ADCON0, 2								;INICIA O PROCESSO DE CONVERS�O

WAIT:
	BTFSC ADCON0, 2								;GO_DONE IGUAL A ZERO?
	GOTO WAIT									;NAO, ESPERA
	
; ---- AGORA PROCESSAMOS O BYTE BAIXO DO RESULTADO -----

	bank1
	MOVF ADRESL, 0								;MOVE CONTEUDO DO ADRESL PARA WORK
	bank0										;SELECIONA O BANCO 0 DE MEMORIA
	MOVWF ANVAL									;MOVE O VALOR DE W PARA ANVAL, ANVAL = W
	RRF ANVAL, F								;SHIFTA O VALOR DE ANVAL E DIVIDE POR 2

	RETURN										;RETORNA

;-------------------- CALCULA DEZENA/UNIDADE -------------------------------------------
;-------------------------- CALCULA DEZENA ----------------------------------------

CALC_TEMP:
	MOVLW D'10'									;COLOCA VALOR LITERAL DE D'10' PARA WORK
	SUBWF SUBTRACAO, 1						    ;WORK = SUBTRACAO - 10
	BTFSC STATUS, C								;O VALOR EH MENOR QUE ZERO?
	GOTO ADD_DEZ								;ADICIONA UM DA DEZENA

	MOVLW D'10'									;SOMA MAIS 10 NO WORK 
	ADDWF SUBTRACAO, 1							;SOMA 10 PARA PEGAR O RESTO (UNIDADE)
	GOTO CALC_UNI

ADD_DEZ:
	INCF TEMP_DEZ, F							;INCREMENTA O VALOR DA DEZENA
	GOTO CALC_TEMP								;VOLTA PARA A CONTAGEM DA DEZENA

; ----------------------- CALCULA UNIDADE -----------------------------------------
CALC_UNI:
    MOVLW D'1'	             					;CARREGA O VALOR LITERAL PARA WORK
    SUBWF SUBTRACAO, 1       					;SUBTRAI 10 DO CONTADOR DE UNIDADE (W = W - TEMP_UNI)
    BTFSC STATUS, C        						;SE O RESULTADO FOR MENOR QUE ZERO
    GOTO ADD_UNI          						;VOLTA PARA RECALCULAR A UNIDADE

	RETURN

ADD_UNI:
	INCF TEMP_UNI, F							;INCREMENTA O VALOR DA UNIDADE
	GOTO CALC_UNI								;VOLTA PARA A CONTAGEM DA UNIDADE


;---- SUB ROTINA PARA O MEIO SEGUNDO ---
MEIO_SEGUNDO:
	
	MOVLW D'200'								;MOVE O VALOR PARA W
	MOVWF T0									;INICIALIZA TEMPO0
	
												;4 CICLOS DE MAQUINA
AUX1:
	MOVLW D'250'								;MOVE O VALOR PARA W
	MOVWF T1									;INICIALIZA TEMPO1
	
												;2 CICLOS DE MAQUINA
												
AUX2:
	NOP											;SEM OPERACAO | 1 CICLO DE MAQUINA
	NOP											;SEM OPERACAO | 1 CICLO DE MAQUINA
	NOP											;SEM OPERACAO | 1 CICLO DE MAQUINA
	NOP											;SEM OPERACAO | 1 CICLO DE MAQUINA
	NOP											;SEM OPERACAO | 1 CICLO DE MAQUINA
	NOP											;SEM OPERACAO | 1 CICLO DE MAQUINA
	NOP											;SEM OPERACAO | 1 CICLO DE MAQUINA
	
	DECFSZ T1									;DECREMENTA TEMPO1 ATE QUE SEJA IGUAL A ZERO
	GOTO AUX2									;VAI PARA LABEL AUX2
	
												;250 x 10 CICLOS DE MAQUINA = 2500 CICLOS
	
	DECFSZ T0									;DECREMENTA TEMPO0 ATEQ UE SEJA IGUAL A ZERO
	GOTO AUX1									;VAI PARA A LABEL AUX1
	
												;3 CICLOS DE MAQUINA
												
												;2500 x 200 = 500000
												
	RETURN										;RETORNA APOS A CHAMADA DA SUB ROTINA
	
	
;------------ FINAL DO PROGRAMA --------------------------------------------------------
	END											