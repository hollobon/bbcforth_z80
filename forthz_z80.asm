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

OLDSTARTUP:
        dw $+2
        ;; ld hl, SP
        ;; ld (TOS), hl
        ld iy, IW
        jp NEXT

        ;; 
RSP:    defw $c200 ; return stack pointer
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

;; push following word onto stack
LITERAL: defw $+2
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

L897D:  db	$84,'USE',$D2
	dw	$0 ;L895C
;; USER:   dw	DOCOL
;; 	dw	CONST
;; 	dw	PSCOD
DOUSE:  inc bc
        ld a, (bc)
        ld c, a
        ld b, 0
        ld ix, (UAVALUE)
        add ix, bc
        ld l, (ix+0)
        ld h, (ix+1)
        push hl
        jp NEXT

include "constants.asm"
include "user.asm"
        
;	BRANCH
        ;; unconditional branch, next word is IP offset in bytes from word following IP
L81D4:	db	$86,'BRANC',$C8
	dw	$0 ;L81B4
BRAN:	dw	$+2
        pop bc
        add iy, bc
        jp NEXT

;	0BRANCH
        ;; conditional branch, only taken if top of stack is zero
L81F4:	db	$87,'0BRANC',$C8
	dw	$0
ZBRAN:	dw	$+2
        pop bc
        ld a, c
        cp b
        jp z, BRAN
        pop bc
        jp NEXT

        db 4
        db 'EMIT'
EMIT:   defw $+2
        pop bc
        ld a, c
        call OSWRCH
        jp NEXT


;; Pronounced:      bracket-find
;;         Stack Action: (addr1\addr2 ... cfa\b\tf) [found]
;;         Uses/Leaves: 2 3
;;         Stact Action: (addrl\addr2 ... ff) [not found]
;;         Uses/Leaves: 2 1
;; Status:
;; Description:     Searches the dictionary starting at the
;;         name field address addr2 for a match with the text
;;         starting at addrl. For a successful match the code
;;         field execution! address and length byte of the name

;	(FIND)

L834F:  db	$86,'(FIND',$A9
	dw	L81F4
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
        cp c
        ld ixh, b               ; load back into ix
        ld ixl, c
        pop hl                  ; restore address of search string
        push hl
        jp nz, _CPNAME          ; if valid, compare strings
        
        ld hl, $AA5E            ; not valid, 
        push hl
        ld hl, $0      
        push hl
        jp NEXT

include "word.asm"


;	-FIND

;; L90B1:  db	$85,'-FIN',$C4
;; 	dw	$0
        
;; DFIND:  dw	DOCOL
;; 	dw	BLL
;; 	dw	ONEWRD
;; 	dw	SWAP
;; 	dw	PFIND
;; 	dw	EXIT

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
        
include "arith.asm"

include "stack.asm"	

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

;; On exit,
;;  C=0 if a carriage return terminated input.
;;  C=1 if an ESCAPE condition terminated input.
;;  Y contains line length, including carriage return if used

;; ;	(EXPECT)

;; L8EC8	.BYTE	$88,'(EXPECT',$A9
        ;; 	.WORD	L8E8B
PEXPEC: dw $+2
        call OSNEWL
        ld ix, $eb00
        pop bc                  ; address to write input
        ld (ix+0), $40
        ld (ix+1), $eb
        pop bc                  ; number of characters to read
        ld (ix+2), c            
        ld (ix+3), $20          ; min ASCII value
        ld (ix+4), $FF          ; max ASCII value
        ld hl, $eb00
        ld a, $0
        call OSWORD
        ld l, h                 ; h contains number of characters read
        ld h, 0
        push hl
        jp NEXT

;; ;	EXPECT

;; L8EFC	.BYTE	$86,'EXPEC',$D4
;; 	.WORD	L8EC8
EXPECT: dw	DOCOL
	dw	OVER
	dw	SWAP
	dw	PEXPEC
	dw	PLUS
	dw	ZERO
	dw	SWAP
;	dw	STORE
	dw	EXIT
	
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

; a is $15 for cold start, $F for warm start
; copy literals up to and including WARNING (for warm start) or VOC-LINK (for cold start)
        ld hl, BOOTLITERALS
        ld de, (UAVALUE)
        ldir 
	jp NEXT
;	jp RPSTO+2		; Reset return pointer and RUN FORTH


;	! (n\addr ...) -- Stores the value at n at the address addr

L88B7:  db	$81,$A1
	dw	$0 ;L88A9
STORE:  dw	$+2
        pop ix
        pop bc
        ld (ix+0), c
        ld (ix+1), b
        jp NEXT

        
L8895:  db	$81,$C0
	dw	$0 ;L8885
AT:     dw $+2
        pop hl
        ld c, (hl)
        inc hl
        ld b, (hl)
        push bc
        jp NEXT

        
        include "tests.asm"

TOPDP: equ $	; TOP OF DICTIONARY
	
TOPNFA:  equ 0 ; top non-forth area?

       
;include "messages.asm"
