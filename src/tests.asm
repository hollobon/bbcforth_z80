
lit:    macro value
        dw LIT
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

test:   macro number
        dw DOCOL
        nl
        emitchr T
        emitchr E
        emitchr S
        emitchr T
        lit number
        lit $20
        dw EMIT
        dw DOTHEX
        emitchr :
        endm

CHECK_STACK:
        dw DOCOL
        dw DEPTH
        dw ZBRAN
        dw _CHECK_STACK_OK - $
        emitchr s
        emitchr t
        emitchr k
        emitchr !
        dw SPSTO
_CHECK_STACK_OK:
        dw DECIM
        dw EXIT

SET_TIB:
        dw DOCOL

        lit 0
        dw INN
        dw STORE

        dw TIB
        dw AT

        dw SWAP
        dw TIB
        dw STORE

        dw EXIT

RESET_TIB:
        dw DOCOL

        dw TIB
        dw STORE

        dw EXIT


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

        dw DECIM

        dw FORTH
        dw CONT
        dw AT
        dw CURR
        dw STORE

        ;; set DP (data pointer)
        lit TOPDP
        dw DP
        dw STORE

        ;; check if test mode; if not, skip to interactive interpreter
        dw READUSERFLAG
        dw ZBRAN
        dw INTERACTIVE - $
        dw RUNTESTS
        dw FIN

INTERACTIVE:
        nl
        dw QUIT
        dw FIN


;;; loop infinitely
FIN:    dw $+2
_FINLOOP:
        jp _FINLOOP


;;; --------------------------------------------------------------------------------

_test_0:
        test 1 ; expect 0

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
        test 1 ; expect dx

        lit 'd'
        lit 'x'
        dw SWAP
        dw EMIT
        dw EMIT
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_LESS:
        test 1 ; expect 1000

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

        ;; 10<0 -> false
        lit 2
        lit 2
        dw LESS
        lit '0'
        dw PLUS
        dw EMIT

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_GREAT:
        test 1 ; expect 010

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
        test 1 ; expect cab
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
        test 1 ; expect 9C
        lit $9C
        dw DOTCHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_DOTHEX:
        test 1 ; expect BEEF
        lit $BEEF
        dw DOTHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

PI:     dw DOCON
        dw $3141

CAFE:   dw DOCON
        dw $CAFE

_test_DOCON:
        test 1 ; expect CAFE
        dw CAFE
        dw DOTHEX
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_OVER:
        test 1 ; expect lnl
        lit 'l'
        lit 'n'
        dw OVER
        dw EMIT
        dw EMIT
        dw EMIT
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_words:
        test 1 ; expect petepetepete petepetepete

        ;; test SPACE and EXIT -
        dw PETE3
        dw SPACE
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
        test 1 ; expect t
        dw BRAN
        dw _TB_TARGET - $
        emitchr f
_TB_TARGET:
        emitchr t
        dw EXIT

;;; --------------------------------------------------------------------------------

_test_0BRANCH:
        test 1 ; expect tftft

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

        lit $0101
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
_CFAB:  dw $0
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
        test 1 ; expect 0001.0005.{label__CFAA}
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
        test 1 ; expect 0001.0005.{label__CFAA}
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
        test 1 ; expect 0001.0008.{label__CFAD}
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
        test 1 ; expect 0000
        lit TSTNAME3
        lit _WORDD
        dw PFIND
        dw DOTHEX
        dw EXIT

_dtest_DFIND_TIB:       db '   SECOND    '

_test_DFIND3:
        test 1 ; expect 0001.0006.{label__CFAB}

        lit _dtest_DFIND_TIB
        dw SET_TIB

        lit _WORDD
        dw DFIND
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX

        dw RESET_TIB

        dw EXIT

_dtest_PFIND_FORTH_1:   db 5,'WIDTH'

_test_PFIND_FORTH_1:
	test 1 ; expect 0085.{label_WIDTH}

        lit _dtest_PFIND_FORTH_1
        lit TOPNFA
        dw PFIND
        dw ZBRAN
        dw _fail_PFIND_FORTH_1 - $
        dw DOTHEX
        emitchr .
        dw DOTHEX
        dw BRAN
        dw _end_PFIND_FORTH_1 - $
_fail_PFIND_FORTH_1:
        emitchr f
_end_PFIND_FORTH_1:
        dw EXIT

_dtest_DFIND_MULTI_TIB:       db '   BL MAX EMIT ',0

_LOOKUP_SHOW:
        dw DOCOL

        lit TOPNFA
        dw DFIND
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX

        dw EXIT


_test_DFIND_MULTI:
        test 1 ; expect 0001.0082.{label_BLL}-0001.0083.{label_MAX}-0001.0084.{label_EMIT}-0001.00C1.{label_NULL}

        lit _dtest_DFIND_MULTI_TIB
        dw SET_TIB

        dw _LOOKUP_SHOW
        emitchr -
        dw _LOOKUP_SHOW
        emitchr -
        dw _LOOKUP_SHOW
        emitchr -
        dw _LOOKUP_SHOW

        dw RESET_TIB

        dw EXIT

_dtest_FIND_TIB:        db 'FIND',0
_dtest_FIND_TIB2:       db 'MIND',0

_test_FIND:
        test 1 ; expect {label_FIND}

        lit _dtest_FIND_TIB
        dw SET_TIB

        dw FIND
        dw DUPP
        dw ZBRAN, _fail_FIND - $
        dw DOTHEX

        lit _dtest_FIND_TIB2
        dw TIB
        dw STORE

        lit 0
        dw INN
        dw STORE

        dw FIND
        dw ZBRAN, _fail_FIND - $
        emitchr f

_fail_FIND:
        dw DROP

        dw RESET_TIB

        dw EXIT


;; --------------------------------------------------------------------------------

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
        test 1 ; expect 0001-0004.0001-000E.0001-0023.0000.0000.0000

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
        test 1 ; expect 000003A8.00010000.FFFE0001

        lit $12
        lit $34
        dw USTAR
        dw DDOTHEX

        emitchr .

        lit $8000
        lit $0002
        dw USTAR
        dw DDOTHEX

        emitchr .

        lit $FFFF
        lit $FFFF
        dw USTAR
        dw DDOTHEX

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

_test_DO_ULOOP:
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

_test_DO_ULOOP_I:
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

_test_DO_LOOP:
        test 1 ; expect FFFD.FFFE.FFFF.0000.0001.0002.#FFFA.FFFB.FFFC.#

        lit 3
        lit -3
        dw XDO
        dw IDO
        dw DOTHEX
        emitchr .
        dw XLOOP
        dw -$C

        emitchr #

        lit -3
        lit -6
        dw XDO
        dw IDO
        dw DOTHEX
        emitchr .
        dw XLOOP
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
        db 14,"this is a test"
        dw LIT
        dw '.'
        dw EMIT
        dw EXIT

;;; --------------------------------------------------------------------------------

_dtest_PWORD_TIB:
        db 'this is a test'

_test_PWORD:
        test 1 ; expect 0004.{label__dtest_PWORD_TIB}

        lit _dtest_PWORD_TIB
        dw SET_TIB

        lit 32
        dw PWORD

        dw DOTHEX
        emitchr .
        dw DOTHEX

        dw RESET_TIB

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_BSWAP:
        test 1 ; expect 3412

        lit $1234
        dw BSWAP
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_ALLOT:
        test 1 ; expect 000F

        dw DP
        dw AT

        lit $f
        dw ALLOT

        dw DP
        dw AT
        dw SWAP
        dw SUBB

        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_COMMA:
        test 1 ; expect 0002.BEEF

        dw HERE

        lit $BEEF
        dw COMMA

        dw HERE
        dw SWAP
        dw SUBB
        dw DOTHEX

        emitchr .

        dw HERE
        dw TWOSUB
        dw AT
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_DNEGAT:
        test 1 ; expect 00000001.00100001.EB61753C
        lit $FFFF
        lit $FFFF
        dw DNEGAT
        dw DDOTHEX

        emitchr .

        lit $FFFF
        lit $FFEF
        dw DNEGAT
        dw DDOTHEX

	emitchr .

        lit $8AC4
        lit $149E
        dw DNEGAT
        dw DDOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_dtest_NUMBER:
        db 6,'482914'
_dtest_NUMBER_2:
        db 5,'-1234'
_dtest_NUMBER_3:
        db 8,'7FEEB1E9'

_test_NUMBER:
        test 1 ; expect 00075E62.FFFFFB2E.7FEEB1E9

        lit _dtest_NUMBER
        dw NUMBER
        dw DDOTHEX

        emitchr .

        lit _dtest_NUMBER_2
        dw NUMBER
        dw DDOTHEX

        emitchr .

        dw HEX
        lit _dtest_NUMBER_3
        dw NUMBER
        dw DDOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_TDROP:
        test 1 ; expect 0001

        lit 1
        lit 2
        lit 3
        dw TDROP
        dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_test_EXEC:
        test 1 ; expect 0305

        lit DOTHEX
        lit $0102
        lit $0203
        lit PLUS
        dw EXEC
        dw SWAP
        dw EXEC

	dw EXIT

;;; --------------------------------------------------------------------------------

_test_TRAVERSE:
        test 1 ; expect {label__NF_TRAV}.{label_TRAV}

        lit TRAV-3
        lit -1
        dw TRAV
	dw DOTHEX

        emitchr .

        lit _NF_TRAV
        lit 1
        dw TRAV
        lit 3
        dw PLUS
	dw DOTHEX

        dw EXIT

;;; --------------------------------------------------------------------------------

_ENCLOSE_TEST:
        dw DOCOL

        lit 'c'
        dw ENCL
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX

        dw EXIT

_dtest_ENCLOSE_1:        db 'ccABCDcc'
_test_ENCLOSE_1:
        test 1 ; expect 0007.0006.0002.{label__dtest_ENCLOSE_1}
        lit _dtest_ENCLOSE_1
        dw _ENCLOSE_TEST
        dw EXIT

_dtest_ENCLOSE_2:        db 'ABCDcc'
_test_ENCLOSE_2:
        test 1 ; expect 0005.0004.0000.{label__dtest_ENCLOSE_2}
        lit _dtest_ENCLOSE_2
        dw _ENCLOSE_TEST
        dw EXIT

_dtest_ENCLOSE_3:        db 'ABC',0,'c'
_test_ENCLOSE_3:
        test 1 ; expect 0003.0003.0000.{label__dtest_ENCLOSE_3}
        lit _dtest_ENCLOSE_3
        dw _ENCLOSE_TEST
        dw EXIT

_dtest_ENCLOSE_4:        db 0,'ccc'
_test_ENCLOSE_4:
        test 1 ; expect 0000.0001.0000.{label__dtest_ENCLOSE_4}
        lit _dtest_ENCLOSE_4
        dw _ENCLOSE_TEST
        dw EXIT

;;; --------------------------------------------------------------------------------

_dtest_WORD_TIB:   db '  Hello World',0

_test_WORD:
        test 1 ; expect Hello.World.

        lit _dtest_WORD_TIB
        dw SET_TIB

        dw BLL
        dw WORD
        dw COUNT
        dw TYPE
        emitchr .

        dw BLL
        dw WORD
        dw COUNT
        dw TYPE
        emitchr .

        dw RESET_TIB

        dw EXIT

;; --------------------------------------------------------------------------------

_test_2DUP:
        test 1 ; expect 1234.ABCD.1234.ABCD

        lit $ABCD
        lit $1234
        dw TDUP
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX
        emitchr .
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_MAX:
        test 1 ; expect 000A.000A
        lit 1
        lit 10
        dw MAX
        dw DOTHEX
        emitchr .

        lit 10
        lit 1
        dw MAX
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_SPACES:
        test 1 ; expect <          ><>

        emitchr <
        lit 10
        dw SPACS
        emitchr >

        emitchr <
        lit -10
        dw SPACS
        emitchr >

        dw EXIT

;; --------------------------------------------------------------------------------

_dtest_TOGGLE:   db $59

_test_TOGGLE:
        test 1 ; expect 7C

        lit _dtest_TOGGLE
        dw DUPP
        lit $25
        dw TOGGL
        dw AT
        dw DOTCHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_dtest_NFA:
        db $84,'TES',$D4
_dtest_LFA:
	dw $924A
_dtest_CFA:
        dw $294
_dtest_PFA:
        dw $592F

_test_NFA:
        test 1 ; expect {label__dtest_NFA}
        lit _dtest_PFA
        dw NFA
        dw DOTHEX
        dw EXIT

_test_PFA:
        test 1 ; expect {label__dtest_PFA}
        lit _dtest_NFA
        dw PFA
        dw DOTHEX
        dw EXIT

_test_CFA:
        test 1 ; expect {label__dtest_CFA}
        lit _dtest_PFA
        dw CFA
        dw DOTHEX
        dw EXIT

_test_LFA:
        test 1 ; expect {label__dtest_LFA}
        lit _dtest_PFA
        dw LFA
        dw DOTHEX
        dw EXIT

;; --------------------------------------------------------------------------------

_test_IDDOT:
        test 1 ; expect TEST
        lit _dtest_NFA
        dw IDDOT
        dw EXIT

;; --------------------------------------------------------------------------------

_test_STOD:
        test 1 ; expect FFFFFFFF.00000000.00007FFF

        lit $FFFF
        dw STOD
        dw DOTHEX
        dw DOTHEX
        emitchr .

        lit $0000
        dw STOD
        dw DOTHEX
        dw DOTHEX
        emitchr .

        lit $7FFF
        dw STOD
        dw DOTHEX
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_DABS:
        test 1 ; expect 12345678

        lit $a988
        lit $edcb
        dw DABS
        dw DOTHEX
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_DLESS:
        test 1 ; expect 0000.0001.0001.0001.0000.0001

        lit $0
        lit $0
        lit $0
        lit $0
        dw DLESS
        dw DOTHEX

        emitchr .

        lit $0
        lit $0
        lit $0
        lit $1
        dw DLESS
        dw DOTHEX

        emitchr .

        lit $0
        lit $0
        lit $1
        lit $0
        dw DLESS
        dw DOTHEX

        emitchr .

        lit $fffe
        lit $ffff
        lit $ffff
        lit $ffff
        dw DLESS
        dw DOTHEX

        emitchr .

        lit $ffff
        lit $ffff
        lit $fffe
        lit $ffff
        dw DLESS
        dw DOTHEX

	emitchr .

        lit $ffff
        lit $0000
        lit $0000
        lit $0001
        dw DLESS
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_ULESS:
	test 1 ; expect 0000.0001

        lit $ffff
        lit $0001
        dw ULESS
        dw DOTHEX

        emitchr .

        lit $fffe
        lit $ffff
        dw ULESS
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_CONTEXT:
        test 1 ; expect {label_TOPNFA}

        dw CONT
        dw AT
        dw AT
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_SMSG:
        test 1 ; expect Parameter outside valid range

        lit 5
        dw SMSG

        dw EXIT

;; --------------------------------------------------------------------------------

_dtest_DOVAR_CFA:
        dw DOVAR
        dw $1234

_test_DOVAR:
	test 1 ; expect 1234

        dw _dtest_DOVAR_CFA
        dw AT
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_ROLL:
        test 1 ; expect 000500010002000300040006

        lit 6
        lit 5
        lit 4
        lit 3
        lit 2
        lit 1

        lit 5
        dw ROLL

        dw DOTHEX
        dw DOTHEX
        dw DOTHEX
        dw DOTHEX
        dw DOTHEX
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_dtest_PSA:
        db ' there'
_dtest_PSA_2:
        db 5
        db 'hello'
        ds 8

_test_PSA:
        test 1 ; expect 000Bhello there
        lit _dtest_PSA
        lit 6
        lit _dtest_PSA_2
        dw PSA
        lit _dtest_PSA_2
        dw DUPP
        dw CAT
        dw DOTHEX
        dw COUNT
        dw TYPE
        dw EXIT

;; --------------------------------------------------------------------------------

_dtest_INTE_1:    db '5 10 + .HEX', 0

_test_INTE_1:
        test 1 ; expect 000F

        lit _dtest_INTE_1
        dw SET_TIB
        dw INTE
        dw RESET_TIB

        dw EXIT

_dtest_INTE_2:    db ': SAYHI ." Hello there " ; SAYHI ." Xxx " SAYHI ." Yyy"',0

_test_INTE_2:
        test 1 ; expect Hello there Xxx Hello there Yyy

        lit _dtest_INTE_2
        dw SET_TIB
        dw INTE
        dw RESET_TIB

        dw EXIT

;; --------------------------------------------------------------------------------

_dtest_ATEXEC:  dw EMIT

_test_ATEXEC:
        test 1 ; expect AB

        lit 65
        lit 66
        lit _dtest_ATEXEC
        dw ROT
        dw OVER
        dw ATEXEC
        dw ATEXEC

        dw EXIT

;; --------------------------------------------------------------------------------

_test_TSWAP:
        test 1 ; expect 0123456789ABCDEF

        lit $4567
        lit $0123
        lit $CDEF
        lit $89AB

        dw TSWAP
        dw DOTHEX
        dw DOTHEX
        dw DOTHEX
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_TOVER:
        test 1 ; expect 0123456789ABCDEF01234567

        lit $4567
        lit $0123
        lit $CDEF
        lit $89AB

        dw TOVER
        dw DOTHEX
        dw DOTHEX
        dw DOTHEX
        dw DOTHEX
        dw DOTHEX
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_USLAS:
        test 1 ; expect 0001000371FF049E

        lit $0015               ; dividend low-order word
        lit $0000               ; dividend high-order word
        lit $0012               ; divisor
        dw USLAS                ; result is remainder quotient
        dw DOTHEX
        dw DOTHEX

        lit $AB63
        lit $46E7
        lit $9F3B
        dw USLAS
        dw DOTHEX
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

;; _test_USMOD:
;;         test 1 ; expect 0001000371FF049E   ? Can't divide by zero

;;         lit $0015               ; dividend low-order word
;;         lit $0000               ; dividend high-order word
;;         lit $0012               ; divisor
;;         dw USMOD                ; result is remainder quotient
;;         dw DOTHEX
;;         dw DOTHEX

;;         lit $AB63
;;         lit $46E7
;;         lit $9F3B
;;         dw USMOD
;;         dw DOTHEX
;;         dw DOTHEX

;;         lit $FFFF
;;         lit $FFFF
;;         lit $0000
;;         dw USMOD
;;         dw DOTHEX
;;         dw DOTHEX

;;         dw EXIT

;; --------------------------------------------------------------------------------

_test_MSLAS:
        test 1 ; expect 25F8445894D402C8

        lit $5678
        lit $1234
        lit $7abc
        dw MSLAS
        dw DOTHEX
        dw DOTHEX

        lit $5678
        lit $0234
        lit $fabc
        dw MSLAS
        dw DOTHEX
        dw DOTHEX

        dw EXIT


;; --------------------------------------------------------------------------------

_test_SLASH:
        test 1 ; expect 001C

        lit $76AC
        lit $042E
        dw SLASH
        dw DOTHEX

        dw EXIT

;; --------------------------------------------------------------------------------

_test_DECDOT:
        test 1 ; expect 4660 -1

        lit $1234
        dw DECDOT

        lit $FFFF
        dw DECDOT

        dw EXIT
;; --------------------------------------------------------------------------------

_test_HEX:
        test 1 ; expect 31486 7AFE

        lit $7AFE
        dw DUPP
        dw DOT
        dw HEX
        dw DOT

        dw EXIT

;; --------------------------------------------------------------------------------

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
