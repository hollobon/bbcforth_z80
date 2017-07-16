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

bl:     macro
        lit $20
        dw EMIT
        endm

test:   macro number
        dw DOCOL
        nl
        emitchr T
        emitchr E
        emitchr S
        emitchr T
        lit number
        bl
        dw DOTHEX
        emitchr :
        endm

;;; --------------------------------------------------------------------------------

_test_0:
        test 0 ; expect 0

        emitchr 0
        exit

;;; --------------------------------------------------------------------------------

_test_PLUS:
        test 1 ; expect U

        lit 65
        lit 20
        dw PLUS
        dw EMIT
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_SWAP:
        test 2 ; expect dx

        lit 'd'
        lit 'x'
        dw SWAP
        dw EMIT
        dw EMIT
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_LESS:
        test 3 ; expect 100

        ;; 2<3 -> true
        lit 3
        lit 2
        dw LESS
        lit '0'
        dw PLUS
        dw EMIT

        ;; 3<2 -> false
        lit 2
        lit 3
        dw LESS
        lit '0'
        dw PLUS
        dw EMIT

        ;; 2<2 -> false
        lit 2
        lit 2
        dw LESS
        lit '0'
        dw PLUS
        dw EMIT

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_GREAT:
        test 4 ; expect 010

        ;; 2>3 -> false
        lit 3
        lit 2
        dw GREAT
        lit '0'
        dw PLUS
        dw EMIT

        ;; 3>2 -> true
        lit 2
        lit 3
        dw GREAT
        lit '0'
        dw PLUS
        dw EMIT

        ;; 2>2 -> false
        lit 2
        lit 2
        dw GREAT
        lit '0'
        dw PLUS
        dw EMIT

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_ROT:
        test 5 ; expect cab
        lit 'c'
        lit 'b'
        lit 'a'
        dw ROT
        dw EMIT
        dw EMIT
        dw EMIT
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_DOTCHEX:
        test 6 ; expect 9C
        lit $9C
        dw DOTCHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_DOTHEX:
        test 7 ; expect BEEF
        lit $BEEF
        dw DOTHEX
        dw SP
        dw EXIT

;;; --------------------------------------------------------------------------------

PI:     dw DOCON
        dw $3141

CAFE:   dw DOCON
        dw $CAFE

_test_DOCON:
        test 8 ; expect CAFE
        dw CAFE
        dw DOTHEX
        dw SP
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_OVER:
        test 9 ; expect lnl
        lit 'l'
        lit 'n'
        dw OVER
        dw EMIT
        dw EMIT
        dw EMIT
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_words:
        test 10 ; expect petepetepete petepetepete

        ;; test SP and EXIT -
        dw PETE3
        dw SP
        dw PETE3
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

;;; --------------------------------------------------------------------------------

_test_0BRANCH:
        test 11 ; expect tft
        lit 6
        lit 0
        dw ZBRAN
        emitchr f
        emitchr t
        lit 6
        lit 1
        dw ZBRAN
        emitchr f
        emitchr t
        dw EXIT

;;; --------------------------------------------------------------------------------

TSTNAME:db $7,'0BRANCH'
        db 88,'TESTFIN',$4C
        dw $0

TESTFIND: dw DOCOL
        nl
        ok
        ok
        nl
        exit

_test_PFIND:
        test 12 ; expect 0001.0007.{label_ZBRAN}
        lit TSTNAME
        lit L834F
        dw PFIND
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

RUNTESTS:
        dw DOCOL
        include "runtests.asm"
        nl
        emitchr D
        emitchr O
        emitchr N
        emitchr E
        nl
        dw EXIT

PABOR:
START:  dw DOCOL
        dw RUNTESTS
        dw SHOWB
IW:     dw SHOWA
        dw TESTFIND

        emitchr -

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
        dw SHOWA
        dw SHOWA
        dw SHOWA
        dw SHOWA
        nl
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
