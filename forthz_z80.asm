include "oscalls.asm"

BOS: equ $10		; BOTTOM OF DATA STACK
TOS: equ $58		; TOP OF DATA STACK
N:   equ $60		; SCRATCH WORKSPACE
UP:  equ $68		; USER AREA POINTER

WBSIZ: equ 1+255+2      ; WORD BUFFER SIZE

UAREA:  equ $400     ; USER AREA
WORDBU: equ UAREA+64 ; WORD BUFFER
TIBB:   equ WORDBU+WBSIZ	; TERMINAL INPUT BUFFER
PADD:   equ TIBB+126            ; PAD
RAM:    equ PADD+80 ; RAM RELOCATION ADDR

EM: equ $7C00		; END OF MEMORY+1
BLKSIZ: equ 1024
HDBT: equ BLKSIZ+4
NOBUF: equ 2
BUFS: equ NOBUF*HDBT
BUF1: equ EM-BUFS		; FIRST BLOCK BUFFER

        org $8000
        incbin 'forthz_6502.a'
LANGENT:
        cp $1
        jp z, LVALID
        ret
LVALID:
;        ld hl, SP
        ld iy, IW
        jp NEXT

RSP:    defw $a000

;; push following word onto stack
LITERAL: defw $+2
        ld l, (iy+0)
        inc iy
        ld h, (iy+0)
        inc iy
        push hl
        jp NEXT

NEXT:
;;; IP is address of current words code field pointer
;;; Code field pointer is address of code to execute
;;; jp ((ip))
        ;; dereference IY into BC (BC has address of CFP)
        ld c, (iy+0)
        inc iy
        ld b, (iy+0)
        inc iy
        ;; dereference BC into HL (HL has address of code)
        ld a, (bc)
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

	
;; 	;	USER

;; L897D	.BYTE	$84,'USE',$D2
;; 	.WORD	L895C
;; USER	.WORD	DOCOL
;; 	.WORD	CONST
;; 	.WORD	PSCOD
;; DOUSE:  LDY	#2
	;; CLC
	;; LDA	(W),Y
	;; ADC	UP
	;; PHA
	;; LDA	#0
	;; ADC	UP+1
	;; JMP	PUSH



        db 4
        db 'EMIT'
EMIT:   defw $+2
        pop bc
        ld a, c
        call OSWRCH
        jp NEXT


        db 1
        db 'PLUS'
PLUS:   dw $+2
        pop hl
        pop bc
        add hl, bc
        push hl
        jp NEXT


SWAP:   dw $+2
        ld ix, 0
        add ix, sp
        ld l, (ix+0)
        ld h, (ix+1)
        ld d, (ix+2)
        ld e, (ix+3)
        ld (ix+0), d
        ld (ix+1), c
        ld (ix+2), l
        ld (ix+3), h
        jp NEXT

OVER:   dw $+2
        ld ix, 0
        add ix, sp
        ld l, (ix+2)
        ld h, (ix+3)
        push hl
        jp NEXT
	
NIP:    dw $+2
        pop hl
        inc sp
        inc sp
        push hl
        jp NEXT

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
        jp OUT
ALPHA:  add 55
OUT:    call OSWRCH

	ld a, c
        and $f
        cp 10
        jp p, ALPHA1
        or 48
        jp OUT1
ALPHA1: add 55
OUT1:   call OSWRCH

        ret

        
        db 4
        db 'EXIT'
EXIT:   defw $+2
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

        db 2
        db 'SP'
SP:     defw DOCOL
        dw LITERAL
        dw 32
        dw EMIT
        dw EXIT


;; ;	(EXPECT)

;; L8EC8	.BYTE	$88,'(EXPECT',$A9
;; 	.WORD	L8E8B
;; PEXPEC	.WORD	*+2
;; 	STX	XSAVE
;; 	DEX
;; 	LDA	3,X
;; 	STA	0,X
;; 	LDA	1,X
;; 	STA	2,X
;; 	LDA	4,X
;; 	STA	1,X
;; 	LDA	#$20
;; 	STA	3,X
;; 	LDA	#$FF
;; 	STA	4,X
;; 	LDA	#0
;; 	JSR	$FFF1
;; 	LDX	XSAVE
;; 	STY	2,X
;; 	LDA	#0
;; 	STA	3,X
;; 	JMP	POP

;; ;	EXPECT

;; L8EFC	.BYTE	$86,'EXPEC',$D4
;; 	.WORD	L8EC8
;; EXPECT	.WORD	DOCOL
;; 	.WORD	OVER
;; 	.WORD	SWAP
;; 	.WORD	PEXPEC
;; 	.WORD	PLUS
;; 	.WORD	ZERO
;; 	.WORD	SWAP
;; 	.WORD	STORE
;; 	.WORD	EXIT
	
;; 	;	QUERY

;; ;L8F17	.BYTE	$85,'QUER',$D9
;; ;	.WORD	L8EFC
;; QUERY	dw	DOCOL
;; 	dw	TIB
;; 	dw	AT
;; 	dw	LITERAL
;;         dw      80
;; 	dw	EXPECT
;; 	dw	ZERO
;; 	dw	INN
;; 	dw	STORE
;; 	dw	EXIT



include "tests.asm"
