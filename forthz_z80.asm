include "oscalls.asm"

BOS: equ $10                    ; BOTTOM OF DATA STACK
TOS: equ $58                    ; TOP OF DATA STACK
N:   equ $60                    ; SCRATCH WORKSPACE
UP:  equ $A008                  ; USER AREA POINTER

WBSIZ: equ 1+255+2              ; WORD BUFFER SIZE

UAREA:  equ $400                ; USER AREA
WORDBU: equ UAREA+64            ; WORD BUFFER
TIBB:   equ WORDBU+WBSIZ        ; TERMINAL INPUT BUFFER
PADD:   equ TIBB+126            ; PAD
RAM:    equ PADD+80             ; RAM RELOCATION ADDR

EM: equ $7C00                   ; END OF MEMORY+1
BLKSIZ: equ 1024
HDBT: equ BLKSIZ+4
NOBUF: equ 2
BUFS: equ NOBUF*HDBT
BUF1: equ EM-BUFS		; FIRST BLOCK BUFFER

        org $8000

        incbin 'forthz_6502.a'

;;; this has to be immediately after the 6502 code

LANGENT:
        cp $1
        jp z, LVALID
        ret
LVALID:
        ;; Ask if cold / warm start and jump appropriately
CWQ:    ld hl, CWMSG
        call WRSTR
	call OSRDCH
	cp $1B ; escape
	jp nz, L80F0
	push af
	ld a, $7E ; ack escape
	call OSBYTE
	pop af
L80F0:  cp 'W'
	jp z, WARM+2
	cp 'C'
	jp nz, CWQ
	jp COLD+2


        ;;
RSP:    dw $c200 ; return stack pointer
CWMSG:  dm '\r\nCOLD or WARM start (C/W)?',0
COLDST: dw START
WARMST: dw PABOR


; BOOT-UP LITERALS

BOOTLITERALS:
	dw	TOPNFA		; TOP NFA
	dw	$7F		; BACKSPACE CHARACTER
UAVALUE:
        dw	UAREA		; Initial user area
	dw	TOS		; Initial top of stack
	dw	$1FF		; Initial top of return stack
	dw	TIBB		; Initial terminal input buffer
	dw	31		; Initial width
	dw	0		; Initial warning    -- WARM $E/$F
	dw	TOPDP		; Initial fence
	dw	TOPDP		; Initial dp
	dw	0 ;VL0-REL		; Initial VOC-LINK   -- COLD $14/$15
	dw	1


WRSTR:  ld a, (hl)
        inc hl
        call OSWRCH
        cp 0
        jp nz, WRSTR
        ret


;; LIT
;; push following word onto stack
_NF_LIT:
        db $83,'LI',$d4
        dw _LF_LIT
LIT:    dw $+2
        ld l, (iy+0)
        inc iy
        ld h, (iy+0)
        inc iy
        push hl
        jp NEXT


NEXT:
;;; On entry, IY holds address of word
;;; Code field pointer is address of code to execute
;;; jp ((ip))
        ;; dereference IY into BC (BC has address of CFP)
        ld c, (iy+0)
        inc iy
        ld b, (iy+0)
        inc iy
        ;; dereference BC into HL (HL has address of code)
JPCFA:  ld a, (bc)
        ld l, a
        inc bc
        ld a, (bc)
        ld h, a
        ;; jump to address in HL
        jp (hl)


DOCOL:
        ;; push IY onto return stack
        push bc

	ld de, (RSP)
        dec de
        ld b, iyh
        ld a, b
        ld (de), a
        dec de
        ld b, iyl
        ld a, b
        ld (de), a
        ld (RSP), de

        pop bc

        ;; load IY with new IP
        inc bc
        ld iyl, c
        ld iyh, b
        jp NEXT


;	CONSTANT

	db	'CONSTANT'
;; CONST:  dw	DOCOL
;; 	dw	CREAT
;; 	dw	COMMA
;; 	dw	PSCOD
DOCON:  inc bc                  ; load word from PFA into hl
        ld a, (bc)
        ld l, a
        inc bc
        ld a, (bc)
        ld h, a
        push hl                 ; push onto forth stack
        jp NEXT


;; 	;	USER

_NF_USER:
        db	$84,'USE',$D2
	dw	_LF_USER
;; USER:   dw	DOCOL
;; 	dw	CONST
;; 	dw	PSCOD
DOUSE:  inc bc
        ld a, (bc)
        ld c, a
        ld b, 0
        ld hl, (UAVALUE)
        add hl, bc
        push hl
        jp NEXT


;	BRANCH
        ;; unconditional branch, next word is IP offset in bytes from word following IP
_NF_BRAN:
        db	$86,'BRANC',$C8
	dw	_LF_BRAN
BRAN:	dw	$+2
_BRAN:  ld c, (iy+0)
        ld b, (iy+1)
        add iy, bc
        jp NEXT


;	0BRANCH
        ;; conditional branch, only taken if top of stack is zero
_NF_ZBRAN:
	db	$87,'0BRANC',$C8
	dw	_LF_ZBRAN
ZBRAN:	dw	$+2
        pop bc
        ld a, c
        cp 0
        jr nz, BUMP
        cp b
        jr z, _BRAN
BUMP:   inc iy                  ; skip the offset
        inc iy
        jp NEXT


;;;  EMIT
_NF_XEMIT:
        db $84,'EMI',$d4
        dw _LF_XEMIT
EMIT:   dw $+2
        pop bc
        ld a, c
        call OSWRCH
        jp NEXT


;; Pronounced:      bracket-find
;; Stack Action: (addr1\addr2 ... cfa\b\tf) [found]
;; Uses/Leaves: 2 3
;; Stack Action: (addrl\addr2 ... ff) [not found]
;; Uses/Leaves: 2 1
;; Description: Searches the dictionary starting at the
;;         name field address addr2 for a match with the text
;;         starting at addrl. For a successful match the code
;;         field execution address and length byte of the name
;;         field plus a true flag are left. If no match is found
;;         only a false flag is left.

;	(FIND)

_NF_PFIND:
        db	$86,'(FIND',$A9
	dw	_LF_PFIND
PFIND:  dw	$+2
        pop ix                  ; pop dict name field address
        pop hl                  ; pop name address
        push hl
_CPNAME:ld a, (ix+0)            ; test if lower 6 bit of length byte the same
        and $3f
        ld e, a                 ; save length in e
        xor (hl)
        ld d, 0
        jp nz, _FNDEND
_CPCHAR:inc ix                  ; point to next byte of each name
        inc hl
        inc d
        ld a, (ix+0)            ; compare lower 7 bits
        xor (hl)
        sla a
        jp nz, _NXTWRD
        jp nc, _CPCHAR          ; if bit 7 was set, we've reached end of dict name

        pop hl                  ; throw away name address
        inc ix                  ; point to cfa
        inc ix
        inc ix
        push ix                 ; push cfa
        ld d, 0
        push de                 ; push length
        ld e, 1
        push de                 ; push true flag
        jp NEXT

_NXTWRD:jp c, _NW2

_FNDEND:
        inc ix
        ld a, (ix+0)
        cp 0
        jp p, _FNDEND

_NW2:   ld c, (ix+1)            ; load link address
        ld b, (ix+2)
        ld a, b                 ; check if zero
        cp 0
        jr nz, _PFIND_NE
        cp c
_PFIND_NE:
        ld ixh, b               ; load back into ix
        ld ixl, c
        pop hl                  ; restore address of search string
        push hl
        jp nz, _CPNAME          ; if valid, compare strings

        pop hl                  ; throw away name address
        ld hl, $0               ; not found - push false flag
        push hl
        jp NEXT


;;;  -FIND
;;;     : -FIND BL 1WORD SWAP (FIND) EXIT ;
_NF_DFIND:
        db $85,'-FIN',$c4
        dw _LF_DFIND
DFIND:  dw	DOCOL
	dw	BLL
	dw	ONEWRD
	dw	SWAP
	dw	PFIND
	dw	EXIT

;	FIND

;; L90C5:  db	$84,'FIN',$C4
;; 	dw	$0
;; FIND:   dw	DOCOL
;; 	dw	CONT
;; 	dw	AT
;; 	dw	AT
;; 	dw	DFIND
;; 	dw	ZBRAN,8
;; 	dw	DROP
;; 	dw	BRAN,4
;; 	dw	ZERO
;; 	dw	EXIT


_NF_CMOVE:
	db $85,'CMOV',$C5
	dw _LF_CMOVE
CMOVE:  dw $+2
        pop bc                  ; count
        pop de                  ; to
        pop hl                  ; from
        ldir
        jp NEXT


include "arith.asm"

include "stack.asm"

include "word.asm"

include "loop.asm"


;;;  EXIT
_NF_EXIT:
        db $84,'EXI',$d4
        dw _LF_EXIT
EXIT:   dw $+2
        ;; pop IY from return stack
        ld de, (RSP)
        ld a, (de)
        ld iyl, a
        inc de
        ld a, (de)
        ld iyh, a
        inc de
        ld (RSP), de
        jp NEXT


;;;  SPACE
;;;     : SPACE BL EMIT EXIT ;
_NF_SPACE:
        db $85,'SPAC',$c5
        dw _LF_SPACE
SPACE:    dw DOCOL
        dw BLL
;        dw XEMIT
        dw EMIT
        dw EXIT


;;;  SPACES
;;;     : SPACES 0 MAX ?DUP 0BRANCH 12 0 (DO) SPACE (ULOOP) -4 EXIT ;
L96B3:
        db $86,'SPACE',$d3
        dw $0           ; LFA
SPACS:  dw DOCOL
        dw ZERO
        dw MAX
        dw QDUP
        dw ZBRAN
        dw $c
        dw ZERO
        dw XDO
        dw SPACE
        dw XPULO
        dw -$4
        dw EXIT


;;;  +!
;;;
;;; Stack Action: n\addr ...
;;; Uses/Leaves: 2 0
;;; Description: Adds n to the value at the address addr.

_NF_PSTOR:
        db $82,'+',$a1
        dw _LF_PSTOR
PSTOR:  dw $+2
        pop ix
        pop hl
        ld c, (ix+0)
        ld b, (ix+1)
        add hl, bc
        ld (ix+0), l
        ld (ix+1), h
        jp NEXT


;;;  QUERY
;;;     : QUERY TIB @ LIT 80 EXPECT 0 >IN ! EXIT ;
_NF_QUERY:
        db $85,'QUER',$d9
        dw _LF_QUERY
QUERY:  dw DOCOL
        dw TIB
        dw AT
        dw LIT
        dw $50
        dw EXPECT
        dw ZERO
        dw INN
        dw STORE
        dw EXIT


;	COLD

;; L9510	.BYTE	$84,'COL',$C4
;; 	.WORD	L94A7
COLD:   dw $+2
	;; LDA	L812A+1		; SET BRKVEC
	;; STA	$203
	;; LDA	L812A
	;; STA	$202
        ld iy, COLDST
	ld bc, $15
	jp COPYLITERALS

;	WARM

;; L9534	.BYTE	$84,'WAR',$CD
;; 	.WORD	L9510
WARM:   dw $+2
        ld iy, WARMST
	;; LDA	L812A+1  ; brkvec
	;; STA	$203
	;; LDA	L812A
	;; STA	$202
	ld bc, $F
        jp COPYLITERALS


COPYLITERALS:
        ;; ld ix, (UAVALUE)
        ;; ld (UP), ix ; Set user area address

        ld hl, 0
        add hl, sp
        ld (UAVALUE+2), hl

; a is $15 for cold start, $F for warm start
; copy literals up to and including WARNING (for warm start) or VOC-LINK (for cold start)
        ld hl, BOOTLITERALS
        ld de, (UAVALUE)
        ldir
	jp NEXT
;	jp RPSTO+2		; Reset return pointer and RUN FORTH


;	! (n\addr ...) -- Stores the value at n at the address addr

_NF_STORE:
        db $81,$A1
	dw _LF_STORE
STORE:  dw $+2
        pop ix
        pop bc
        ld (ix+0), c
        ld (ix+1), b
        jp NEXT


;	C@

_NF_CAT:
        db $82,'C',$C0
	dw _LF_CAT
CAT:    dw $+2
        pop hl
        ld c, (hl)
        ld b, 0
        push bc
        jp NEXT


;	@

_NF_AT:
        db $81,$C0
	dw _LF_AT
AT:     dw $+2
        pop hl
        ld c, (hl)
        inc hl
        ld b, (hl)
        push bc
        jp NEXT


;;;  COUNT
;;;     : COUNT DUP 1+ SWAP C@ EXIT ;
_NF_COUNT:
        db $85,'COUN',$d4
        dw _LF_COUNT
COUNT:  dw DOCOL
        dw DUPP
        dw ONEP
        dw SWAP
        dw CAT
        dw EXIT


;;;  C!
_NF_CSTOR:
        db $82,'C',$a1
        dw _LF_CSTOR
CSTOR:  dw $+2
        pop ix
        pop bc
        ld (ix+0), c
        jp NEXT

        include "tests.asm.gen"


;;;  COMPILE
;;;     : COMPILE ?COMP R> DUP 2+ >R @ , EXIT ;
;; L8CCB:
;;         db $87,'COMPIL',$c5
;;         dw $0           ; LFA
;; COMP:   dw DOCOL
;;         dw QCOMP
;;         dw RFROM
;;         dw DUPP
;;         dw TWOP
;;         dw TOR
;;         dw AT
;;         dw COMMA
;;         dw EXIT


;;;  DIGIT
_NF_DIGIT:
        db $85,'DIGI',$d4
        dw _LF_DIGIT
DIGIT:  dw $+2
        ld ix, 0
        add ix, sp

        ld a, (ix+2)
        sub '0'
        jp m, _DIGIT_INVALID

        cp 10
        jp m, _DIGIT_NOADJ

        sub 7
        cp 10
        jp m, _DIGIT_INVALID
_DIGIT_NOADJ:
        cp (IX+0)
        jp p, _DIGIT_INVALID
        ld (ix+2), a
        ld (ix+0), 1
        jp NEXT

_DIGIT_INVALID:
        pop hl
        pop hl
        ld hl, 0
        push hl
        jp NEXT


;;;  CONVERT
;; \ (nd1\addrl ... nd2\addr2)
;; \ Description: Converts the text beginning at the
;; \ address addrl to the equivalent stack number. The value
;; \ is accumulated into double number nd1, with regard to
;; \ the current numeric base, being left as nd2. The
;; \ address of the first non-convertible character is left
;; \ as addr2.
;; : CONVERT
;;     1+                                  \ skip length byte
;;     DUP >R                              \ save copy of addr to return stack
;;     C@ BASE @ DIGIT                     \ attempt to convert current char to digit
;;     0BRANCH 28                          \ fail - jump to R>
;;     SWAP                                \ put nd1 on top
;;     BASE @ U*                           \ shift left
;;     DROP                                \ drop MSW
;;     ROT BASE @ U* D+
;;     R>
;;     BRANCH -42                          \ loop to first word
;;     R>                                  \ restore addr
;;     EXIT
;; ;
_NF_CONV:
        db $87,'CONVER',$d4
        dw _LF_CONV
CONV:   dw DOCOL
        dw ONEP
        dw DUPP
        dw TOR
        dw CAT
        dw BASE
        dw AT
        dw DIGIT
        dw ZBRAN
        dw $1c
        dw SWAP
        dw BASE
        dw AT
        dw USTAR
        dw DROP
        dw ROT
        dw BASE
        dw AT
        dw USTAR
        dw DPLUS
        dw RFROM
        dw BRAN
        dw -$2a
        dw RFROM
        dw EXIT


;;;  NOOP
;;;     : NOOP EXIT ;
L8D05:
        db $84,'NOO',$d0
        dw $0           ; LFA
NOOP:   dw DOCOL
        dw EXIT


;; NUMBER
;;    : NUMBER DUP C@ OVER + >R 0 0 ROT DUP 1+ C@ LIT ?'-'? = DUP >R + CONVERT R> 0BRANCH LIT 8 >R DNEGATE R> R> OVER - DUP 0< 0BRANCH LIT 8 2DROP BRANCH 18 0 ?ERROR C@ LIT ?'.'? - 0 ?ERROR EXIT ;
_NF_NUMBER:
	db $86,'NUMBE',$d2
	dw _LF_NUMBER
NUMBER:	dw DOCOL
	dw DUPP
	dw CAT
	dw OVER
	dw PLUS
	dw TOR
	dw ZERO
	dw ZERO
	dw ROT
	dw DUPP
	dw ONEP
	dw CAT
	dw LIT
	dw '-'
	dw EQUAL
	dw DUPP
	dw TOR
	dw PLUS
	dw CONV
	dw RFROM
	dw ZBRAN
	dw $8
	dw TOR
	dw DNEGAT
	dw RFROM
	dw RFROM
	dw OVER
	dw SUBB
	dw DUPP
	dw ZLESS
	dw ZBRAN
	dw $8
        dw TDROP
	dw BRAN
	dw $12
	dw ZERO
	dw QERR
	dw CAT
	dw LIT
	dw '.'
	dw SUBB
	dw ZERO
	dw QERR
	dw EXIT


;;;  ?ERROR
;;;     : ?ERROR SWAP 0BRANCH LIT 8 ERROR BRANCH LIT 4 DROP EXIT ;
L8C21:
        db $86,'?ERRO',$d2
        dw $0           ; LFA
QERR:   dw DOCOL
        dw DROP
        dw DROP
        ;; dw SWAP
        ;; dw ZBRAN
        ;; dw LIT
        ;; dw $8
        ;; dw ERROR
        ;; dw BRAN
        ;; dw LIT
        ;; dw $4
        ;; dw DROP
        dw EXIT


;;;  TYPE
;;;     : TYPE DUP 0> 0BRANCH 24 OVER + SWAP (DO) I C@ EMIT (ULOOP) -8 BRANCH 4 2DROP EXIT ;
_NF_TYPE:
        db $84,'TYP',$c5
        dw _LF_TYPE
TYPE:   dw DOCOL
        dw DUPP
        dw ZGREA
        dw ZBRAN
        dw $18
        dw OVER
        dw PLUS
        dw SWAP
        dw XDO
        dw IDO
        dw CAT
        ;; dw XEMIT
        dw EMIT
        dw XPULO
        dw -$8
        dw BRAN
        dw $4
        dw TDROP
        dw EXIT


;;;  (.")
;;;     : (.") R@ COUNT DUP 1+ R> + >R TYPE EXIT ;
L8E70:
        db $84,'(."',$a9 ; "
        dw $0           ; LFA
PDOTQ:  dw DOCOL
        dw RAT
        dw COUNT
        dw DUPP
        dw ONEP
        dw RFROM
        dw PLUS
        dw TOR
        dw TYPE
        dw EXIT


;;;  ><
_NF_BSWAP:
        db $82,'>',$bc
        dw _LF_BSWAP
BSWAP:  dw $+2
        pop hl
        ld c, h
        ld b, l
        push bc
        jp NEXT


;;;  ALLOT
;;;     : ALLOT DP +! EXIT ;
;;; Stack Action: (n ...)
;;; Reserve n bytes of dictionary space.
_NF_ALLOT:
        db $85,'ALLO',$d4
        dw _LF_ALLOT
ALLOT:  dw DOCOL
        dw DP
        dw PSTOR
        dw EXIT


;;;  HERE
;;;     : HERE DP @ EXIT ;
_NF_HERE:
        db $84,'HER',$c5
        dw _LF_HERE
HERE:   dw DOCOL
        dw DP
        dw AT
        dw EXIT


;;;  ,
;;;     : , HERE ! 2 ALLOT EXIT ;
_NF_COMMA:
        db $81,'',$ac
        dw _LF_COMMA
COMMA:  dw DOCOL
        dw HERE
        dw STORE
        dw TWO
        dw ALLOT
        dw EXIT


;;;  EXECUTE
_NF_EXEC:
        db $87,'EXECUT',$c5
        dw _LF_EXEC
EXEC:   dw $+2
        pop bc
        jp JPCFA


;;; NULL
;;;     :  BLK @ 0BRANCH 40 1 BLK +! 0 >IN ! BLK @ B/SCR 1- AND 0= 0BRANCH 8 ?EXEC R> DROP BRANCH 6 R> DROP EXIT ;
_NF_NULL:
        db $81,'',$80
        dw _LF_NULL
NULL:   dw DOCOL
        ;; dw BLK
        ;; dw AT
        ;; dw ZBRAN
        ;; dw $28
        ;; dw ONE
        ;; dw BLK
        ;; dw PSTOR
        ;; dw ZERO
        ;; dw INN
        ;; dw STORE
        ;; dw BLK
        ;; dw AT
        ;; dw BSCR
        ;; dw ONESUB
        ;; dw ANDD
        ;; dw ZEQU
        ;; dw ZBRAN
        ;; dw $8
        ;; dw QEXEC
        ;; dw RFROM
        ;; dw DROP
        ;; dw BRAN
        ;; dw $6
        dw RFROM
        dw DROP
        dw EXIT


TOPDP: equ $	; TOP OF DICTIONARY

TOPNFA:  equ 0 ; top non-forth area?

include "constants.asm"
include "user.asm"

;include "messages.asm"
include "links.asm.gen"
