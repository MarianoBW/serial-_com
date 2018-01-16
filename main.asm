;
; dif_tempo_assembly.asm
;
; Created: 29/12/2017 13:43:06
; Author : MarianoBW
;
;

.include "m328pdef.inc"
.equ CLOCK   = 20000000
.equ BAUD    = 9600
.equ UBRRVAL = CLOCK/(BAUD*16)-1


.def temp    = R16
.def time1 = r17
.def time2 = r18
.def sum40 = r19
.def dir=r20
.def flag40khz = R23


;.equ CLOCK   = 8000000
;.equ BAUD    = 9600
;.equ UBRRVAL = CLOCK/(BAUD*16)-1



.org 0x0000
	rjmp start

;.org 0x002           ; local da memoria do ext_int0       pag 65
;	rjmp int0_calc

;.org 0x004           ; local da memoria do ext_int1
;	rjmp int1_ini

;.org 0x001A   ; timer1 ovf
;	rjmp timer1_ovf

;.org 0x001C   ; local da memoria do TIM0_COMPA 
;	rjmp TIM0_COMPA
.org 0x0028
	rjmp loop

start:
	cli
	;
	ldi temp,0b10000000
	;sts CKSEL,r16
	sts CLKPR,temp
	;ldi r16,0b10000000
	;sts CLKPR,r16
	ldi temp,0b00000000
	sts CLKPR,temp
	;
	;saidas e entradas
	;ldi r16,0b11000001     ;configura pino PD0,PD6,PD7,PC3,PC4 como saída e demais como entradas
	sbi DDRD,0
	sbi DDRD,6
	sbi DDRD,7
	sbi DDRC,3
	sbi DDRC,4
	;-------------------------------
	;serial config
		; inisialisasi baudrate
	ldi temp, LOW(UBRRVAL)
	sts UBRR0L, temp
	ldi temp, HIGH(UBRRVAL)
	sts UBRR0H, temp

		; Frame-Format: 8 Bit
	ldi temp, 0b00000110
	sts UCSR0C, temp

		; set interrupt and receive
	ldi temp, (1<<TXCIE0)|(1<<TXEN0)
	sts UCSR0B, temp


	;-------------------------------
;	;Timer1 config
;	ldi temp,0b00000000
;	sts TCCR1A,temp        ;configura TCCR1A    normal mode		 pg 132
;	;out TCCR1B,r16
;	ldi temp,0b00000001    ;configura TCCR1B    clk/1			 pg 133
;	sts TCCR1B,temp
;	ldi temp,0b00000001    ;liga timer1 ovf
;	sts TIMSK1,temp

	; ini var
	ldi temp,0b00000000
	ldi sum40,0b00000000 ; contador de pulsos
	ldi dir,0b00000000
	ldi flag40khz,0b00000000    ; flag 40khz
	
	sei					 ; ativa interrupçao
	rjmp loop


loop:
	;sei
	nop
	rjmp TX
	rjmp loop




;timer1_ovf:
;	cli
;	cpi r22,0b00000000 ; se flag = 0 
;	brne baixo1 ;PC+2 ; entao   / pula 1 linha se nao igual
;	rjmp cima1  ; seta 1 no pind0
;
;cima1:
;	sbi PORTD,0 ; seta 1 no pind0
;	ldi r22,0b00000001 ; levanta flag
;	sei
;	rjmp loop
;baixo1:
;	cbi PORTD,0 ; se nao, seta 0 no pind0
;	ldi r22,0b00000000 ; zerar flag 
;	sei
;	rjmp loop

TX:
	lds temp, UCSR0A ; ????? 
	sbrs temp, UDRE0
    rjmp TX
	nop
    ldi temp, 0b00001111
    sts UDR0, r16

	cpi r22,0b00000000 ; se flag = 0 
	brne baixo1 ;PC+2 ; entao   / pula 1 linha se nao igual
	rjmp cima1  ; seta 1 no pind0

cima1:
	sbi PORTD,0 ; seta 1 no pind0
	ldi r22,0b00000001 ; levanta flag
	sei
	rjmp loop
baixo1:
	cbi PORTD,0 ; se nao, seta 0 no pind0
	ldi r22,0b00000000 ; zerar flag 
	sei
	rjmp loop
