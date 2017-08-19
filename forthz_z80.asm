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
	dw	__NF_FIRST      ; Initial VOC-LINK   -- COLD $14/$15
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


;;;  LITERAL
;;;     : LITERAL STATE @ 0BRANCH 8 COMPILE LIT , EXIT ;
_NF_LITER:
        db $87,'LITERA',$cc
        dw _LF_LITER
LITER:  dw DOCOL
        dw STATE
        dw AT
        dw ZBRAN
        dw _LITER_EXIT - $
        dw COMP
        dw LIT
        dw COMMA
_LITER_EXIT:
        dw EXIT


;;;  DLITERAL
;;;     : DLITERAL STATE @ 0BRANCH 8 SWAP LITERAL LITERAL EXIT ;
_NF_DLITER:
        db $88,'DLITERA',$cc
        dw _LF_DLITER
DLITER: dw DOCOL
        dw STATE
        dw AT
        dw ZBRAN
        dw _DLITER_EXIT - $
        dw SWAP
        dw LITER
        dw LITER
_DLITER_EXIT:
        dw EXIT


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


;;;  TOGGLE
_NF_TOGGL:
        db $86,'TOGGL',$c5
        dw _LF_TOGGL
TOGGL:  dw $+2
        pop bc
        pop hl
        ld a, (hl)
        xor c
        ld (hl), a
        jp NEXT


;;;  LAST
;;;     : LAST CURRENT @ @ EXIT ;
_NF_LAST:
        db $84,'LAS',$d4
        dw _LF_LAST
LAST:   dw DOCOL
        dw CURR
        dw AT
        dw AT
        dw EXIT


;;;  SMUDGE
;;;     : SMUDGE LAST LIT 32 TOGGLE EXIT ;
_NF_SMUDG:
        db $86,'SMUDG',$c5
        dw _LF_SMUDG
SMUDG:  dw DOCOL
        dw LAST
        dw LIT
        dw $20
        dw TOGGL
        dw EXIT


;;;  ] - force compilation of subsequent input
;;;     : ] LIT 192 STATE ! EXIT ;
_NF_RBRAC:
        db $81,'',$dd
        dw _LF_RBRAC
RBRAC:  dw DOCOL
        dw LIT
        dw $c0
        dw STATE
        dw STORE

        dw EXIT


;;;  [
;;;     : [ 0 STATE ! EXIT ;
_NF_LBRAC:
        db $81,'',$db
        dw _LF_LBRAC
LBRAC:  dw DOCOL
        dw ZERO
        dw STATE
        dw STORE
        dw EXIT


;;;  ?COMP
;;;     : ?COMP STATE @ 0= LIT 17 ?ERROR EXIT ;
_NF_QCOMP:
        db $85,'?COM',$d0
        dw _LF_QCOMP
QCOMP:  dw DOCOL
        dw STATE
        dw AT
        dw ZEQU
        dw LIT
        dw $11
        dw QERR
        dw EXIT


;;;  COMPILE
;;;     : COMPILE ?COMP R> DUP 2+ >R @ , EXIT ;
_NF_COMP:
        db $87,'COMPIL',$c5
        dw _LF_COMP
COMP:   dw DOCOL
        dw QCOMP
        dw RFROM
        dw DUPP
        dw TWOP
        dw TOR
        dw AT
        dw COMMA
        dw EXIT


;;;  !CSP - save stack pointer in CSP variable
;;;     : !CSP SP@ CSP ! EXIT ;
_NF_SCSP:
        db $84,'!CS',$d0
        dw _LF_SCSP
SCSP:   dw DOCOL
        dw SPAT
        dw CSP
        dw STORE
        dw EXIT


;;;  ?CSP
;;;     : ?CSP SP@ CSP @ - LIT 20 ?ERROR EXIT ;
_NF_QCSP:
        db $84,'?CS',$d0
        dw _LF_QCSP
QCSP:   dw DOCOL
        dw SPAT
        dw CSP
        dw AT
        dw SUBB
        dw LIT
        dw $14
        dw QERR
        dw EXIT


;;;  ?EXEC - issues error message if not executing
;;;     : ?EXEC STATE @ LIT 18 ?ERROR EXIT ;
_NF_QEXEC:
        db $85,'?EXE',$c3
        dw _LF_QEXEC
QEXEC:  dw DOCOL
        dw STATE
        dw AT
        dw LIT
        dw $12
        dw QERR
        dw EXIT


;;;  CFA
;;;     : CFA 2- EXIT ;
_NF_CFA:
        db $83,'CF',$c1
        dw _LF_CFA
CFA:    dw DOCOL
        dw TWOSUB
        dw EXIT


;;;  PFA
;;;     : PFA 1 TRAVERSE LIT 5 + EXIT ;
_NF_PFA:
        db $83,'PF',$c1
        dw _LF_PFA
PFA:    dw DOCOL
        dw ONE
        dw TRAV
        dw LIT
        dw $5
        dw PLUS
        dw EXIT


;;;  NFA
;;;     : NFA LIT 5 - -1 TRAVERSE EXIT ;
_NF_NFA:
        db $83,'NF',$c1
        dw _LF_NFA
NFA:    dw DOCOL
        dw LIT
        dw $5
        dw SUBB
        dw TRUE
        dw TRAV
        dw EXIT


;;;  LFA
;;;     : LFA LIT 4 - EXIT ;
_NF_LFA:
        db $83,'LF',$c1
        dw _LF_LFA
LFA:    dw DOCOL
        dw LIT
        dw $4
        dw SUBB
        dw EXIT


;;;  (;CODE)
;;;     : (;CODE) R> LAST PFA CFA ! EXIT ;
_NF_PSCOD:
        db $87,'(       ;CODE',$a9
        dw _LF_PSCOD
PSCOD:  dw DOCOL
        dw RFROM
        dw LAST
        dw PFA
        dw CFA
        dw STORE
        dw EXIT


;;;  FILL
;;;     : FILL OVER 1 < 0BRANCH 10 DROP 2DROP BRANCH 20 SWAP >R OVER C! DUP 1+ R> 1- CMOVE EXIT ;
_NF_FILL:
        db $84,'FIL',$cc
        dw _LF_FILL
FILL:   dw DOCOL
        dw OVER
        dw ONE
        dw LESS
        dw ZBRAN
        dw $a
        dw DROP
        dw TDROP
        dw BRAN
        dw $14
        dw SWAP
        dw TOR
        dw OVER
        dw CSTOR
        dw DUPP
        dw ONEP
        dw RFROM
        dw ONESUB
        dw CMOVE
        dw EXIT


;; (CREATE)
;;    : (CREATE) FIRST HERE LIT 160 + U< 2 ?ERROR BL WORD DUP C@ DUP 0= LIT 10 ?ERROR OVER CONTEXT @ @ (FIND) 0BRANCH 18 DROP 2+ NFA ID. LIT 4 MESSAGE SPACE WIDTH @ MIN DUP DP C@ + LIT 252 = ALLOT 1+ DUP >R HERE SWAP CMOVE HERE R> ALLOT DUP LIT 128 TOGGLE HERE 1- LIT 128 TOGGLE LAST , CURRENT @ ! LIT ?DOVAR? , EXIT ;
_NF_PCREAT:
	db $88,'(CREATE',$a9
	dw _LF_PCREAT
PCREAT:	dw DOCOL
	dw XFIRS
	dw HERE
	dw LIT
	dw $a0
	dw PLUS
	dw ULESS
	dw TWO
	dw QERR
	dw BLL
	dw WORD
	dw DUPP
	dw CAT
	dw DUPP
	dw ZEQU
	dw LIT
	dw $a
	dw QERR
	dw OVER
	dw CONT
	dw AT
	dw AT
	dw PFIND
	dw ZBRAN
	dw $12
	dw DROP
	dw TWOP
	dw NFA
	dw IDDOT
	dw LIT
	dw $4
        dw SMSG  ;; dw XMES
	dw SPACE
	dw WIDTH
	dw AT
	dw MIN
	dw DUPP
	dw DP
	dw CAT
	dw PLUS
	dw LIT
	dw $fc
	dw EQUAL
	dw ALLOT
	dw ONEP
	dw DUPP
	dw TOR
	dw HERE
	dw SWAP
	dw CMOVE
	dw HERE
	dw RFROM
	dw ALLOT
	dw DUPP
	dw LIT
	dw $80
	dw TOGGL
	dw HERE
	dw ONESUB
	dw LIT
	dw $80
	dw TOGGL
	dw LAST
	dw COMMA
	dw CURR
	dw AT
	dw STORE
	dw LIT
	dw DOVAR
	dw COMMA
	dw EXIT


;; ;;;  R:
;;;     : R: ?EXEC !CSP CURRENT @ CONTEXT ! CREATE ] (;CODE) ;
_NF_RCOLON:
        db $82,'R',$ba
        dw _LF_RCOLON
RCOLON: dw DOCOL
        dw QEXEC
        dw SCSP
        dw CURR
        dw AT
        dw CONT
        dw STORE
        ;; dw XCREA
        dw PCREAT
        dw RBRAC
        dw PSCOD

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


;;;  :
;;;     : : R: SMUDGE EXIT ;
_NF_COLON:
        db $81,'',$ba
        dw _LF_COLON
COLON:  dw DOCOL
        dw RCOLON
        dw SMUDG
        dw EXIT


;;;  R;
;;;     : R; ?CSP COMPILE EXIT [ EXIT ;
_NF_RSEMI:
        db $c2,'R',$bb
        dw _LF_RSEMI
RSEMI:  dw DOCOL
        dw QCSP
        dw COMP
        dw EXIT
        dw LBRAC
        dw EXIT


;;;  ;
;;;     : ; R; SMUDGE EXIT ;
_NF_SEMIS:
        db $c1,'',$bb
        dw _LF_SEMIS
SEMIS:  dw DOCOL
        dw RSEMI
        dw SMUDG
        dw EXIT


;;;  CONSTANT
;;;     : CONSTANT CREATE , (;CODE) ;
_NF_CONST:
        db $88,'CONSTAN',$d4
        dw _LF_CONST
CONST:  dw DOCOL
        dw PCREAT ;; XCREA
        dw COMMA
        dw PSCOD
DOCON:  inc bc                  ; load word from PFA into hl
        ld a, (bc)
        ld l, a
        inc bc
        ld a, (bc)
        ld h, a
        push hl                 ; push onto forth stack
        jp NEXT


;;; USER
;;;    : USER CONSTANT (;CODE) ;
_NF_USER:
        db $84,'USE',$d2
        dw _LF_USER
USER:   dw DOCOL
        dw CONST
        dw PSCOD
DOUSE:  inc bc
        ld a, (bc)
        ld c, a
        ld b, 0
        ld hl, (UAVALUE)
        add hl, bc
        push hl
        jp NEXT


;;;  VARIABLE
;;;     : VARIABLE CREATE 0 , (;CODE) ;
_NF_VAR:
        db $88,'VARIABL',$c5
        dw _LF_VAR
VAR:    dw DOCOL
        dw PCREAT ;; dw XCREA
        dw ZERO
        dw COMMA
        dw PSCOD
DOVAR:
        inc bc
        push bc
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
        and $7f
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
        ld e, a                 ; save length in e
        and $3f
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



;;;  FIND
;;;     : FIND CONTEXT @ @ -FIND 0BRANCH 8 DROP BRANCH 4 0 EXIT ;
_NF_FIND:
        db $84,'FIN',$c4
        dw _LF_FIND
FIND:   dw DOCOL
        dw CONT
        dw AT
        dw AT
        dw DFIND
	dw ZBRAN
        dw _FIND_ZERO - $
	dw DROP
	dw BRAN
        dw _FIND_EXIT - $
_FIND_ZERO:
	dw ZERO
_FIND_EXIT:
        dw EXIT


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

include "util.asm"

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
SPACE:  dw DOCOL
        dw BLL
;        dw XEMIT
        dw EMIT
        dw EXIT


;;;  SPACES
;;;     : SPACES 0 MAX ?DUP 0BRANCH 12 0 (DO) SPACE (ULOOP) -4 EXIT ;
_NF_SPACS:
        db $86,'SPACE',$d3
        dw _LF_SPACS
SPACS:  dw DOCOL
        dw ZERO
        dw MAX
        dw QDUP
        dw ZBRAN
        dw _SPACS_EXIT - $
        dw ZERO
        dw XDO
_SPACS_LOOP:
        dw SPACE
        dw XPULO
        dw _SPACS_LOOP - $
_SPACS_EXIT:
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


;;;  QUIT
;;;     : QUIT 0 BLK ! [ RP! CR QUERY INTERPRET STATE @ 0= 0BRANCH LIT 7 ;
_NF_QUIT:
        db $84,'QUI',$d4
        dw _LF_QUIT
QUIT:   dw DOCOL
        dw ZERO
        dw BLK
        dw STORE
        dw LBRAC
_QUIT_LOOP:
        dw RPSTO
        dw CRR
        dw QUERY
        dw INTE
        dw STATE
        dw AT
        dw ZEQU
        dw ZBRAN
        dw _QUIT_END - $
        dw PDOTQ
        db 2,'OK'
        dw BRAN
        dw _QUIT_LOOP - $
_QUIT_END:
        dw EXIT


_NF_CRR:
        db $82,'C',$d2
        dw _LF_CRR
CRR:    dw DOCOL
        dw LIT
        dw $a
        dw EMIT
        dw LIT
        dw $d
        dw EMIT
        dw NEGTWO
        dw OUT
        dw PSTOR
        dw EXIT


;;;  INTERPRET
;;;     : INTERPRET CONTEXT @ @ -FIND 0BRANCH 24 STATE @ < 0BRANCH 8 , BRANCH LIT 4 EXECUTE BRANCH 6 WBFR NUM ?STACK BRANCH -42 EXIT ;
_NF_INTE:
        db $89,'INTERPRE',$d4
        dw _LF_INTE
INTE:   dw DOCOL
_INTE_LOOP:
        dw CONT
        dw AT
        dw AT
        dw DFIND

        dw ZBRAN
        dw _INTE_TARGET_1 - $

        dw STATE
        dw AT
        dw LESS
        dw ZBRAN
        dw _INTE_SKIP_COMPILE - $

        dw COMMA
        dw BRAN
        dw _INTE_SKIP_EXEC - $
_INTE_SKIP_COMPILE:
        dw EXEC
_INTE_SKIP_EXEC:
        dw BRAN
        dw _INTE_TARGET_2 - $
_INTE_TARGET_1:
        dw WBFR
        ;; dw XNUM
        dw PNUM
_INTE_TARGET_2:
        ;; dw QSTAC
        dw BRAN
        dw _INTE_LOOP - $
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


;;;  (NUM)
;;;     : (NUM) DUP C@ OVER + SWAP NUMBER ROT C@ LIT ?'.'? - 0BRANCH 10 DROP LITERAL BRANCH 4 DLITERAL EXIT ;
_NF_PNUM:
        db $85,'(NUM',$a9
        dw _LF_PNUM
PNUM:   dw DOCOL
        dw DUPP
        dw CAT
        dw OVER
        dw PLUS
        dw SWAP
        dw NUMBER
        dw ROT
        dw CAT
        dw LIT
        dw '.'
        dw SUBB
        dw ZBRAN
        dw $a
        dw DROP
        dw LITER
        dw BRAN
        dw $4
        dw DLITER
        dw EXIT


;;;  ?ERROR
;;; Stack Action; f3n ...!
;;;         Uses/Leaves: 2 0
;;; Status:
;;; Description:     Issues error message number n if the
;;;         boolean flag f is true. Uses ERROR. The stack is
;;;         always empty after an error message.
;;;     : ?ERROR SWAP 0BRANCH LIT 8 ERROR BRANCH LIT 4 DROP EXIT ;
L8C21:
        db $86,'?ERRO',$d2
        dw $0           ; LFA
QERR:   dw DOCOL
        dw SWAP
        dw ZBRAN
        dw $8
        dw ERROR
        dw BRAN
        dw $4
        dw DROP
        dw EXIT


;;;  $MSG
;;;     : $MSG DUP DUP 0> SWAP LIT 26 < AND 0BRANCH 32 LIT ?LB47E? SWAP 0 (DO) DUP C@ + 1+ (LOOP) -10 COUNT TYPE BRANCH 4 MSG# EXIT ;
_NF_SMSG:
        db $84,'$MS',$c7
        dw _LF_SMSG
SMSG:      dw DOCOL
        dw DUPP
        dw DUPP
        dw ZGREA
        dw SWAP
        dw LIT
        dw $1a
        dw LESS
        dw ANDD
        dw ZBRAN
        dw $20
        dw LIT
        dw MSG_TABLE
        dw SWAP
        dw ZERO
        dw XDO
        dw DUPP
        dw CAT
        dw PLUS
        dw ONEP
        dw XLOOP
        dw -$a
        dw COUNT
        dw TYPE
        dw BRAN
        dw $4
        dw DROP        ;; dw MSGNUM
        dw EXIT


;;;  ERROR
;;;     : ERROR WARNING @ 0< 0BRANCH 8 ABORT BRANCH 31 WBFR COUNT TYPE (.") 4 ?'  ? '? MESSAGE SP! 2DROP >IN @ BLK @ QUIT EXIT ;
_NF_ERROR:
        db $85,'ERRO',$d2
        dw _LF_ERROR
ERROR:  dw DOCOL
        dw WARN
        dw AT
        dw ZLESS
        dw ZBRAN
        dw $8
        ;; dw XABOR
        dw PABOR
        dw BRAN
        dw $1f
        dw WBFR
        dw COUNT
        dw TYPE
        dw PDOTQ
        db $4
        db '  ? '
        ;; dw XMES
        dw SMSG
        dw SPSTO
        dw TDROP
        dw INN
        dw AT
        dw BLK
        dw AT
        dw QUIT
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
        db $c1,'',$80
        dw _LF_NULL
NULL:   dw DOCOL
        dw BLK
        dw AT
        dw ZBRAN
        dw $28
        dw ONE
        dw BLK
        dw PSTOR
        dw ZERO
        dw INN
        dw STORE
        dw BLK
        dw AT
        dw BSCR
        dw ONESUB
        dw ANDD
        dw ZEQU
        dw ZBRAN
        dw $8
        dw QEXEC
        dw RFROM
        dw DROP
        dw BRAN
        dw $6
        dw RFROM
        dw DROP
        dw EXIT


;;;  >VDU
_NF_TOVDU:
        db $84,'>VD',$d5
        dw _LF_TOVDU
TOVDU:  dw $+2
        pop hl
        ld a, l
        call OSWRCH
        jp NEXT


;;;  MODE
;;;     : MODE LIT 22 >VDU >VDU EXIT ;
_NF_MODE:
        db $84,'MOD',$c5
        dw _LF_MODE
MODE:   dw DOCOL
        dw LIT
        dw $16
        dw TOVDU
        dw TOVDU
        dw EXIT


TOPDP: equ $	; TOP OF DICTIONARY

TOPNFA:  equ 0 ; top non-forth area?

include "constants.asm"
include "user.asm"

include "messages.asm"
include "links.asm.gen"
