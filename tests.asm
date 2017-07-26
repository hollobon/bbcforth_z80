        ;; output byte as hex
DOTCHEX:dw $+2
        pop bc
        call _DOTCHEX
        jp NEXT

        ;; output word as hex
DOTHEX: dw $+2
        pop bc
        ld l, c
        ld c, b
        call _DOTCHEX
        ld c, l
        call _DOTCHEX
        jp NEXT

        ;; display byte value in c as hex
        ;; overwrites a
_DOTCHEX:
        ld a, c
        srl a
        srl a
        srl a
        srl a
        cp 10
        jp p, ALPHA
        or 48
        jp .OUT
ALPHA:  add 55
.OUT:   call OSWRCH

	ld a, c
        and $f
        cp 10
        jp p, ALPHA1
        or 48
        jp OUT1
ALPHA1: add 55
OUT1:   call OSWRCH

        ret

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


RUNTESTS:
        dw DOCOL
        dw DECIM
        include "runtests.asm"
        nl
        emitchr D
        emitchr O
        emitchr N
        emitchr E
        nl
        dw EXIT


READUSERFLAG:
        dw $+2
        ld a, 1
        ld hl, $FF00
        call OSBYTE
        ld h, 0
        push hl
        jp NEXT


PABOR:
START:  dw DOCOL

        ;; check if test mode; if not, skip to interactive interpreter
        dw READUSERFLAG
        dw ZBRAN
        dw $6
        dw RUNTESTS
        dw FIN

        nl
        emitchr >

        dw QUERY
        dw TIB
        dw AT
        dw DUPP
        dw AT
        dw EMIT
        dw ONEP
        dw AT
        dw EMIT

        dw FIN


;;; loop infinitely
FIN:    dw $+2
HERE:   jp HERE


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
        lit 2
        lit 3
        dw LESS
        lit '0'
        dw PLUS
        dw EMIT

        ;; 3<2 -> false
        lit 3
        lit 2
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
        lit 2
        lit 3
        dw GREAT
        lit '0'
        dw PLUS
        dw EMIT

        ;; 3>2 -> true
        lit 3
        lit 2
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

_test_BRANCH:
        test 11 ; expect t
        dw BRAN
        dw 8
        emitchr f
        emitchr t
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_0BRANCH:
        test 11 ; expect tft
        lit 0
        dw ZBRAN
        dw 8
        emitchr f
        emitchr t
        lit 1
        dw ZBRAN
        dw 8
        emitchr f
        emitchr t
        dw EXIT

;;; --------------------------------------------------------------------------------

TSTNAME:db $5,'FIRST'
TSTNAME2:db $8,'-FOURTH!'
TSTNAME3:db $7,'nothing'

_WORDA: db $5,'FIRS',$D4
        dw $0
_CFAA:  dw $0
        dw $0

_WORDB: db $6,'SECON',$C4
        dw _WORDA
        dw $0
        dw $0

_WORDC: db $7,'(THIRD',$A9
        dw _WORDB
        dw $0
        dw $0

_WORDD: db $8,'-FOURTH',$A1
        dw _WORDC
_CFAD:  dw $0
        dw $0

_test_PFIND:
        test 12 ; expect 0001.0005.{label__CFAA}
        lit TSTNAME
        lit _WORDA
        dw PFIND
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX
        dw EXIT

_test_PFIND2:
        test 13 ; expect 0001.0005.{label__CFAA}
        lit TSTNAME
        lit _WORDB
        dw PFIND
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX
        dw EXIT

_test_PFIND3:
        test 14 ; expect 0001.0008.{label__CFAD}
        lit TSTNAME2
        lit _WORDD
        dw PFIND
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX
        dw EXIT

_test_PFIND_NOTFOUND:
        test 14 ; expect 0000
        lit TSTNAME3
        lit _WORDD
        dw PFIND
        dw DOTHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

_EX1:   dw $1234

_test_AT_STORE:
        test 1 ; expect 1234.FADB
        lit _EX1
        dw AT
        dw DOTHEX
        emitchr .
        lit $FADB
        lit _EX1
        dw STORE
        lit _EX1
        dw AT
        dw DOTHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

_EX2:   dw $1234

_test_CAT:
        test 1 ; expect 0034
        lit _EX2
        dw CAT
        dw DOTHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

_tcmove_FROM:   db 'atest'
_tcmove_TO:     db 'xxxxxxxx'

;;; print 6 characters from address at top of stack, without looping
_emit6: dw DOCOL
        dw DUPP
        dw AT
        dw EMIT

        dw DUPP
        dw ONE
        dw PLUS
        dw AT
        dw EMIT

        dw DUPP
        dw TWO
        dw PLUS
        dw AT
        dw EMIT

        dw DUPP
        lit 3
        dw PLUS
        dw AT
        dw EMIT

        dw DUPP
        lit 4
        dw PLUS
        dw AT
        dw EMIT

        lit 5
        dw PLUS
        dw AT
        dw EMIT

        dw EXIT

_test_CMOVE:
        test 1 ; expect xxxxxx.atestx
        lit _tcmove_TO
	dw _emit6
        emitchr .
        lit _tcmove_FROM
        lit _tcmove_TO
        lit 5
        dw CMOVE
        lit _tcmove_TO
        dw _emit6
        dw EXIT

;;; --------------------------------------------------------------------------------

_d_test_COUNT:
        db $05,'abcde'

_test_COUNT:
        test 1 ; expect 0005

        lit _d_test_COUNT
        dw COUNT
        dw DOTHEX

        dw DROP                 ; drop addr2 from COUNT
        dw EXIT

;;; --------------------------------------------------------------------------------

_d_test_CSTOR:
        dw $0000

_test_CSTOR:
        test 1 ; expect 0000.00DE
	lit _d_test_CSTOR
        dw AT
        dw DOTHEX
        emitchr .
        lit $BCDE
	lit _d_test_CSTOR
        dw CSTOR
	lit _d_test_CSTOR
        dw AT
        dw DOTHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

_d_test_PSTORE:
        dw $1234

_test_PSTORE:
        test 1 ; expect 666C
        lit $5438
        lit _d_test_PSTORE
        dw PSTOR
        lit _d_test_PSTORE
        dw AT
        dw DOTHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_ZLESS:
        test 1 ; expect 0000.0001.0000

        lit $0001
        dw ZLESS
        dw DOTHEX
        emitchr .

        lit $FFFF
        dw ZLESS
        dw DOTHEX
        emitchr .

        lit $0
        dw ZLESS
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_NEGAT:
        test 1 ; expect FFFF.FF00.0001

        lit $1
        dw NEGAT
        dw DOTHEX
        emitchr .

        lit $100
        dw NEGAT
        dw DOTHEX
        emitchr .

        lit $FFFF
        dw NEGAT
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_PM:
        test 1 ; expect 0001.FFFE
        lit $1
        lit $1
        dw PM
        dw DOTHEX
        emitchr .

        lit $2
        lit $FFFF
        dw PM
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_MIN:
        test 1 ; expect 0005.00AA
        lit 5
        lit 6
        dw MIN
        dw DOTHEX
        emitchr .

        lit $7A00
        lit $00AA
        dw MIN
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_ZEQU:
        test 1 ; expect 0001.0000.0000.0000.0000.0000
        lit $0
        dw ZEQU
        dw DOTHEX
        emitchr .

        lit $1
        dw ZEQU
        dw DOTHEX
        emitchr .

        lit $FFFF
        dw ZEQU
        dw DOTHEX
        emitchr .

        lit $0101
        dw ZEQU
        dw DOTHEX
        emitchr .

        lit $00FF
        dw ZEQU
        dw DOTHEX
        emitchr .

        lit $FF00
        dw ZEQU
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_DROP:
        test 1 ; expect FEED
        lit $FEED
        lit $B00F
        dw DROP
        dw DOTHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

STACKHEIGHT:
        dw DOCOL
        dw SPAT
        dw SZERO
        dw AT
        dw SWAP
        dw SUBB
        dw DOTHEX
        dw EXIT

_test_SPAT_SZERO:
        test 1 ; expect 0000.0006.0000

        ;; check that SP@ - S0 is 0
        dw STACKHEIGHT
        emitchr .

        ;; push 3 things on stack and check stack depth is 6 bytes
        lit 1
        lit 1
        lit 1

        dw STACKHEIGHT
        emitchr .

        ;;  check that SP! resets stack
        dw SPSTO
        dw STACKHEIGHT
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_PICK:
        test 1 ; expect BEEF.600D.6006
        lit $6006
        lit $EEFF
        lit $BEEF
        lit $000F
        lit $B0B0
        lit $600D

        lit 3
        dw PICK
        dw DOTHEX
        emitchr .

        lit 0
        dw PICK
        dw DOTHEX
        emitchr .

        lit 5
        dw PICK
        dw DOTHEX

        ;; reset stack
        dw SPSTO

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_TSTAR:
        test 1 ; expect 0004.0000.0100.

        lit $2
        dw TSTAR
        dw DOTHEX
        emitchr .

        lit $0
        dw TSTAR
        dw DOTHEX
        emitchr .

        lit $80
        dw TSTAR
        dw DOTHEX
        emitchr .

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_TSLAS:
        test 1 ; expect 0001.0000.0080.C001

        lit $2
        dw TSLAS
        dw DOTHEX
        emitchr .

        lit $0
        dw TSLAS
        dw DOTHEX
        emitchr .

        ;; check carry crosses from MSB to LSB
        lit $0100
        dw TSLAS
        dw DOTHEX
        emitchr .

        ;; check sign maintained
        lit $8002
        dw TSLAS
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_ABS:
        test 1 ; expect 0000.0001.0001.7FFF

        lit $0
        dw ABS
        dw DOTHEX
        emitchr .

        lit $1
        dw ABS
        dw DOTHEX
        emitchr .

        lit $FFFF
        dw ABS
        dw DOTHEX
        emitchr .

        lit $8001
        dw ABS
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_ONESUB:
        test 1 ; expect 0001.FFFF.0000

        lit $2
        dw ONESUB
        dw DOTHEX
        emitchr .

        lit $0
        dw ONESUB
        dw DOTHEX
        emitchr .

        lit $1
        dw ONESUB
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_TWOSUB:
        test 1 ; expect 0001.FFFE.0000

        lit $3
        dw TWOSUB
        dw DOTHEX
        emitchr .

        lit $0
        dw TWOSUB
        dw DOTHEX
        emitchr .

        lit $2
        dw TWOSUB
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_ANDD:
        test 1 ; expect 0000.F005

        lit $FFFF
        lit $0000
        dw ANDD
        dw DOTHEX
        emitchr .

        lit $FEE7
        lit $F005
        dw ANDD
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_ORR:
        test 1 ; expect FFFF.FEE7

        lit $FFFF
        lit $0000
        dw ORR
        dw DOTHEX
        emitchr .

        lit $F005
        lit $4EE2
        dw ORR
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_XORR:
        test 1 ; expect BB9C.0010

        lit $F4A8
        lit $4F34
        dw XORR
        dw DOTHEX
        emitchr .

        lit $FF0F
        lit $FF1F
        dw XORR
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_DEPTH:
        test 1 ; expect 0000.0005.0000

        dw DEPTH
        dw DOTHEX
        emitchr .

        lit $0
        lit $0
        lit $0
        lit $0
        lit $0

        dw DEPTH
        dw DOTHEX
        emitchr .

        dw DROP
        dw DROP
        dw DROP
        dw DROP
        dw DROP

        dw DEPTH
        dw DOTHEX

        dw EXIT


;;; --------------------------------------------------------------------------------

_test_DIGIT:
        test 1 ; expect 0001-0004.0001-000E.0001-0023.0000.0000.0000.0000

        lit '4'
        lit 10
        dw DIGIT
        dw DOTHEX
        emitchr -
        dw DOTHEX
        emitchr .

        lit 'E'
        lit 16
        dw DIGIT
        dw DOTHEX
        emitchr -
        dw DOTHEX
        emitchr .

        lit 'Z'
        lit 36
        dw DIGIT
        dw DOTHEX
        emitchr -
        dw DOTHEX
	emitchr .

        lit 'A'
        lit 10
        dw DIGIT
        dw DOTHEX
        emitchr .

        lit ':'
        lit 16
        dw DIGIT
        dw DOTHEX
	emitchr .

        lit 'G'
        lit 16
        dw DIGIT
        dw DOTHEX
	emitchr .

        dw DEPTH
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_TOR_RFROM:
        test 1 ; expect 0002.1234.0000

        dw RPAT

        lit $1234
        dw TOR

        dw DUPP
        dw RPAT
        dw SUBB
        dw DOTHEX

        emitchr .

        dw RFROM
        dw DOTHEX

        emitchr .

        dw RPAT
        dw SUBB
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

DDOTHEX:
        dw DOCOL
        dw DOTHEX
        dw DOTHEX
        dw EXIT

_test_DPLUS:
        test 1 ; expect 00010000.01000400

        lit $1000
        lit $0000
        lit $F000
        lit $0000
        dw DPLUS
        dw DDOTHEX

        emitchr .

        lit $0280
        lit $0080
        lit $0180
        lit $0080
        dw DPLUS
        dw DDOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_USTAR:
        test 1 ; expect 000003A8.

        lit $12
        lit $34
        dw USTAR
        dw DDOTHEX
        emitchr .

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_default_BASE:
        test 1 ; expect 000A

        dw BASE
        dw AT
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_dtest_CONV:  db 10,'1234xxxxxx'
_dtest_CONV2:  db 6,'53605 '

_test_CONV:
        test 1 ; expect 000004D2.0000D165

        lit 0
        lit 0
        lit _dtest_CONV
        dw CONV
        dw DROP
        dw DDOTHEX

        emitchr .

        lit 0
        lit 0
        lit _dtest_CONV2
        dw CONV
        dw DROP
        dw DDOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_USER:
        test 1 ; expect {label_TIBB}

        dw TIB
        dw AT
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_DO_LOOP:
        test 1 ; expect 0000.0006.xxxxxxy

        lit 6  ; limit
        lit 0  ; initial value
        dw XDO
        dw RFROM
        dw DOTHEX
        emitchr .
        dw RFROM
        dw DOTHEX
        emitchr .

        lit 6
        lit 0
        dw XDO
        lit 'x'
        dw EMIT
        dw XPULO
        dw -$8

        emitchr y

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_DO_LOOP_I:
        test 1 ; expect 0001.0002.0003.0004.0005.#

        lit 6
        lit 1
        dw XDO
        dw IDO
        dw DOTHEX
        emitchr .
        dw XPULO
        dw -$C

        emitchr #

        dw EXIT

;;; --------------------------------------------------------------------------------

_dtest_TYPE:
        db 'hello, world!'

_test_TYPE:
        test 1 ; expect hello, world!

        lit _dtest_TYPE
        lit 13
        dw TYPE

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_PDOTQ:
        test 1 ; expect this is a test.
        dw PDOTQ
        db 15,"this is a test."
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_BSWAP:
        test 1 ; expect 3412

        lit $1234
        dw BSWAP
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

;; _test_PEXPEC:
;;         ;; read line from keyboard
;;         lit 20
;;         lit $eb10
;;         dw PEXPEC
;;         dw DOTHEX
;;         emitchr /
;;         ;; show first character read
;;         lit $eb40
;;         dw AT
;;         dw EMIT
;;         lit $41
;;         lit $eb40
;;         dw STORE
;;         lit $eb40
;;         dw AT
;;         dw EMIT
