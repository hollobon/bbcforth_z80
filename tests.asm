PI:     dw DOCON
        dw $3141

CAFE:   dw DOCON
        dw $CAFE

PABOR:  
START:  dw DOCOL
IW:     defw SHOWA

        ;; test 0BRANCH
        dw LITERAL
        dw 6
        dw LITERAL
        dw 1
        dw ZBRAN
        
        defw LITERAL
        defw 'f'
        defw EMIT
        defw SHOWA
        ;; read line from keyboard
        dw LITERAL
        dw 20
        dw LITERAL
        dw $eb10
        defw PEXPEC             
        dw DOTHEX
        dw LITERAL
        dw '/'
        dw EMIT
        ;; show first character read
        dw LITERAL
        dw $eb40
        dw AT
        dw EMIT
        dw LITERAL
        dw $41
        dw LITERAL
        dw $eb40
        dw STORE
        dw LITERAL
        dw $eb40
        dw AT
        dw EMIT
        dw LITERAL
        dw '/'
        dw EMIT
        defw TESTW
        defw SHOWA
        defw SHOWA
        defw SHOWA
        defw SHOWA
        defw SHOWB

	;; display an A
SHOWA:  defw $+2
        ld a, 65
        call $ffee
        jp NEXT

        ;; display a B then loop infinitely
SHOWB:  defw $+2
        ld a, 66
        call $ffee
HERE:
        jp HERE

TESTW:  dw DOCOL
        dw LITERAL
        dw '.'
        dw EMIT
        dw LITERAL
        dw $c
        dw DOTCHEX
        dw LITERAL
        dw '.'
        dw EMIT
        dw LITERAL
        dw $9C
        dw DOTCHEX
        dw LITERAL
        dw '.'
        dw EMIT
        ;; dw LITERAL
        ;; dw $CAFE
        dw CAFE
        dw DOTHEX
        dw SP
        dw LITERAL
        dw 'l'
        dw LITERAL
        dw 'n'
        dw OVER
        dw EMIT
        dw EMIT
        dw EMIT
        dw SP
        dw SP
        
        dw PETE3
        dw SP
        dw PETE3
        dw SP
        dw LITERAL
        dw 65
        dw LITERAL
        dw 20
        dw PLUS
        dw EMIT
        
        dw LITERAL
        dw 'd'
        dw LITERAL
        dw 'x'
        dw SWAP 
        dw EMIT
        dw EMIT

        dw EXIT
        
PETE3:  defw DOCOL
        defw PETE
        defw PETE
        defw PETE
        defw EXIT
        
PETE:   defw DOCOL
        defw LITERAL
        defw 'P'
        defw EMIT
        defw LITERAL
        defw 'e'
        defw EMIT
        defw LITERAL
        defw 't'
        defw EMIT
        defw LITERAL
        defw 'e'
        defw EMIT
        defw EXIT
