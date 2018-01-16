

.org 0x00
	rjmp RESET

RESET:

    ldi r16, $12
    out UCSRA, r16
    ldi r17, $00
    ldi r16, $47

    out UBRRL,  r16
    out UBRRH,  r17
    ; Enable receiver and transmitter
    ldi r16,    (1<<RXEN) | (1<<TXEN)
    out UCSRB, r16

    ; Set frame format: 8 data, 1 stop bit
    ldi r16, (1<<URSEL)|(1<<UCSZ0)|(1<<UCSZ1)
    out UCSRC, r16
    ldi r16, $80
    ldi r17, (0<<URSEL)
    out UBRRH,  r17
loop:
    ldi r16, $41
    jmp TX

TX:
    sbis UCSRA, UDRE
    rjmp TX
    ;move data to the buffer
    out UDR, r16
    jmp loop