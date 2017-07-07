lit:    macro value
        dw LITERAL
        dw value
        endm
        
emitchr:macro char
        lit 'char'
        dw EMIT
        endm
	
exit:   macro
        dw EXIT
        endm

ok:     macro
        emitchr O
        emitchr K
        endm

nl:     macro
        emitchr \r
        emitchr \n
        endm
        
word:   macro name length label link code
        db length,name
        dw link
label:  dw code
        endm
        
PI:     dw DOCON
        dw $3141

CAFE:   dw DOCON
        dw $CAFE

TSTNAME:db $6,'(FIN1)'
;TSTNAME:db $7,'0BRANCH'

         ;; word 'TESTFIN\0114' 88 TESTFIND $0 DOCOL
        db 88,'TESTFIN',$4C
        dw $0
TESTFIND: dw DOCOL
        nl
        ok
        ok
        nl
        exit
        
PABOR:  
START:  dw DOCOL
IW:     dw SHOWA
        dw TESTROT
        dw TESTFIND
        emitchr -

        lit TSTNAME
        lit L834F
        dw PFIND
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX

        emitchr -

        dw WIDTH
        dw DOTHEX ; expect $1F

        ;; nl
        ;; ;; test 0BRANCH - expect t
        ;; lit 6
        ;; lit 0
        ;; dw ZBRAN

        ;; emitchr f
        ;; emitchr t

        ;; test 0BRANCH and BRANCH - expect t
        ;; nl
        ;; lit 6
        ;; lit 1
        ;; dw ZBRAN
        ;; emitchr t
        ;; lit 6
        ;; dw BRAN
        ;; emitchr f
        
        nl
        ;; read line from keyboard
        lit 20
        lit $eb10
        dw PEXPEC             
        dw DOTHEX
        emitchr /
        ;; show first character read
        lit $eb40
        dw AT
        dw EMIT
        lit $41
        lit $eb40
        dw STORE
        lit $eb40
        dw AT
        dw EMIT
        emitchr /
        dw TESTW
        dw SHOWA
        dw SHOWA
        dw SHOWA
        dw SHOWA
        dw SHOWB

	;; display an A
SHOWA:  dw $+2
        ld a, 65
        call $ffee
        jp NEXT

        ;; display a B then loop infinitely
SHOWB:  dw $+2
        ld a, 66
        call $ffee
HERE:
        jp HERE

TESTW:  dw DOCOL
        emitchr .
        lit $c
        dw DOTCHEX
        emitchr .

        ;; test .CHEX - expect '9C' to be output
        lit $9C
        dw DOTCHEX
        emitchr .

        ;; test .HEX - expect 'BEEF' to be output
        lit $BEEF
        dw DOTHEX
        dw SP
        
        ;; test DOCON - expect 'CAFE' to be output
        dw CAFE
        dw DOTHEX
        dw SP

        ;; test OVER - expect 'lnl  ' to be output
        lit 'l'
        lit 'n'
        dw OVER
        dw EMIT
        dw EMIT
        dw EMIT
        dw SP
        dw SP

        ;; test SP and EXIT - expect 'petepetepete petepetepete '
        dw PETE3
        dw SP
        dw PETE3
        dw SP

        ;; test + - expect 'U' to be output
        lit 65
        lit 20
        dw PLUS
        dw EMIT

        ;; test SWAP - expect 'dx' to be output
        lit 'd'
        lit 'x'
        dw SWAP 
        dw EMIT
        dw EMIT

        dw EXIT

        ;; test ROT - expect cab
TESTROT:        dw DOCOL
        nl
        lit 'c'
        lit 'b'
        lit 'a'
        dw ROT
        dw EMIT
        dw EMIT
        dw EMIT
        nl
        dw EXIT
        
PETE3:  dw DOCOL
        dw PETE
        dw PETE
        dw PETE
        dw EXIT
        
PETE:   dw DOCOL
        emitchr p
        emitchr e
        emitchr t
        emitchr e
        dw EXIT
