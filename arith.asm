;;; Note - for double precision (32 bit) integers, the most-significant word
;;; goes on the top of the stack, with the least-significant word underneath.


;;; <

L8688:	db	$81,$BC
	dw	$0
LESS:	dw	$+2
        pop hl
        pop bc
        sbc hl, bc
        ld hl, $1
        jp m, _LESS1
        jp z, _LESS1
        push hl
        jp NEXT
_LESS1: ld l, 0
        push hl
        jp NEXT


;;; >

L8BA3:	db	$81,$BE
	dw	$0
GREAT:	dw	DOCOL
	dw	SWAP
	dw	LESS
	dw	EXIT


;;; +
        db 1
        db 'PLUS'
PLUS:   dw $+2
        pop hl
        pop bc
        add hl, bc
        push hl
        jp NEXT


;	MIN
;  : MIN 2DUP > 0BRANCH LIT 4 SWAP DROP EXIT ;
L95AB:	db	$83,'MI',$CE
	dw	$0 ;L959C
MIN:	dw	DOCOL
	dw	TDUP
	dw	GREAT
	dw	ZBRAN,4
	dw	SWAP
	dw	DROP
	dw	EXIT


;	MAX

L95C1:	db	$83,'MA',$D8
	dw	$0 ;L95AB
MAX:	dw	DOCOL
	dw	TDUP
	dw	LESS
	dw	ZBRAN,4
	dw	SWAP
	dw	DROP
	dw	EXIT


;;;  -
;;;     : - NEGATE + EXIT ;
L8B8B:
        db $81,'',$ad
        dw $0           ; LFA
SUBB:   dw DOCOL
        dw NEGAT
        dw PLUS
        dw EXIT


;;;  0<
;;; Stack Action: n ... f
;;; Uses/Leaves: 1 1
;;; Status:
;;; Description:     Leaves a true flag if n is less than zero,
;;; otherwise leaves a false flag.
L8676:
        db $82,'0',$bc
        dw $0           ; LFA
ZLESS:  dw $+2
        pop hl
        ld a, h
        or 0
        jp M, _ZLESS_M
        ld hl, 0
        jp _ZLESS_NEXT
_ZLESS_M:
        ld hl, 1
_ZLESS_NEXT:
        push hl
        jp NEXT


;;;  NEGATE
L8708:
        db $86,'NEGAT',$c5
        dw $0           ; LFA
NEGAT:  dw $+2
        pop bc
        ld hl, 0
        and 0
        sbc hl, bc
        push hl
        jp NEXT


;;;  ABS
;;;     : ABS DUP +- EXIT ;
L958E:
        db $83,'AB',$d3
        dw $0           ; LFA
ABS:    dw DOCOL
        dw DUPP
        dw PM
        dw EXIT


;;;  +-
;;; Stack Action: n1\n2 ... n3
;;; Uses/Leaves: 2 1
;;; Status:
;;; Description:     Leaves as n3 the result of applying the sign of n2 to n1.
;;;     : +- 0< 0BRANCH LIT 4 NEGATE EXIT ;
L956B:
        db $82,'+',$ad
        dw $0           ; LFA
PM:     dw DOCOL
        dw ZLESS
        dw ZBRAN
        dw $4
        dw NEGAT
        dw EXIT


;;;  1+
;;;     : 1+ 1 + EXIT ;
L8AE0:
        db $82,'1',$ab
        dw $0           ; LFA
ONEP:   dw DOCOL
        dw ONE
        dw PLUS
        dw EXIT


;;; 1-
;;;    : 1- -1 + EXIT ;
L8AFB:
        db $82,'1',$ad
        dw $0 ; LFA
ONESUB:  dw DOCOL
        dw TRUE
        dw PLUS
        dw EXIT


;;;  2+
;;;     : 2+ 2 + EXIT ;
L8AED:
        db $82,'2',$ab
        dw $0           ; LFA
TWOP:   dw DOCOL
        dw TWO
        dw PLUS
        dw EXIT


;;;  2-
;;;     : 2- -2 + EXIT ;
L8B08:
        db $82,'2',$ad
        dw $0           ; LFA
TWOSUB: dw DOCOL
        dw NEGTWO
        dw PLUS
        dw EXIT


;;;  2*
L9806:
        db $82,'2',$aa
        dw $0           ; LFA
TSTAR:  dw $+2
        ld ix, 0
        add ix, sp
        sla (ix+0)
        rl (ix+1)
        jp NEXT


;;;  2/
L9814:
        db $82,'2',$af
        dw $0           ; LFA
TSLAS:  dw $+2
        ld ix, 0
        add ix, sp
        sra (ix+1)
        rr (ix+0)
        jp NEXT


;;;  0=
L8661:
        db $82,'0',$bd
        dw $0           ; LFA
ZEQU:   dw $+2
        pop hl
        ld a, l
        or h
        ld hl, 0
        jp z, _ZEQU_T
        push hl
        jp NEXT
_ZEQU_T:
        inc l
        push hl
        jp NEXT


;;;  AND
L854E:
        db $83,'AN',$c4
        dw $0           ; LFA
ANDD:   dw $+2
        pop bc
        pop hl

        ld a, c
        and l
        ld l, a

        ld a, b
        and h
        ld h, a

        push hl
        jp NEXT


;;;  OR
L8564:
        db $82,'O',$d2
        dw $0           ; LFA
ORR:    dw $+2

        pop bc
        pop hl

        ld a, c
        or l
        ld l, a

        ld a, b
        or h
        ld h, a

        push hl
        jp NEXT


;;;  XOR
L8579:
        db $83,'XO',$d2
        dw $0           ; LFA
XORR:   dw $+2
        pop bc
        pop hl

        ld a, c
        xor l
        ld l, a

        ld a, b
        xor h
        ld h, a

        push hl
        jp NEXT


;;;  D+
L86E5:
        db $82,'D',$ab
        dw $0           ; LFA
DPLUS:  dw $+2
        pop ix
        pop hl
        pop bc
        pop de

        add hl, de              ; add low words

        ld a, c                 ; add high word low bytes
        adc a, ixh              ; BUG? ixh and ixl appear to be reversed here
        ld e, a

        ld a, b                 ; add high word high bytes
        adc a, ixl
        ld d, a

        push hl
        push de
        jp NEXT



;;;  U*
L84D5:
        db $82,'U',$aa
        dw $0           ; LFA
USTAR:  dw $+2
        pop bc
        pop de
        ld a, c
        ld c, b

;;; 16-bit multiply
;;; multiplier in a:c (shifted right during calc)
;;; multiplicand (shifted left during calc) in de':de
;;; result in hl':hl
;;; Likely can be optimised. Uses alternate register set.
        ld b, 16
        ld hl, 0
        exx
        ld de, 0
        ld hl, 0
        exx
MULT:   srl c                   ; right shift multiplier, high
        rra                     ; rotate right multiplier, low
        jr nc, NOADD            ; test carry
        add hl, de              ; add multiplicand to result
        exx
        adc hl, de
        exx

NOADD:  ex de, hl
        add hl, hl              ; double-shift multiplicand (ix:de) left
        exx
        ex de, hl
        adc hl, hl
        ex de, hl
        exx
        ex de, hl
        djnz MULT

        push hl
        exx
        push hl
        exx
        jp NEXT


;;;  DECIMAL
;;;     : DECIMAL LIT 10 BASE ! EXIT ;
L8D37:
        db $87,'DECIMA',$cc
        dw $0           ; LFA
DECIM:  dw DOCOL
        dw LITERAL
        dw $a
        dw BASE
        dw STORE
        dw EXIT


;;;  HEX
;;;     : HEX LIT 16 BASE ! EXIT ;
L8D25:
        db $83,'HE',$d8
        dw $0           ; LFA
HEX:    dw DOCOL
        dw LITERAL
        dw $10
        dw BASE
        dw STORE
        dw EXIT


;;;  0>
;;;     : 0> NEGATE 0< EXIT ;
L8DCE:
        db $82,'0',$be
        dw $0           ; LFA
ZGREA:    dw DOCOL
        dw NEGAT
        dw ZLESS
        dw EXIT


;;;  =
;;;     : = - 0= EXIT ;
L8B97:
        db $81,'',$bd
        dw $0           ; LFA
EQUAL:  dw DOCOL
        dw SUBB
        dw ZEQU
        dw EXIT


;;;  DNEGATE
L8721:
        db $87,'DNEGAT',$c5
        dw $0           ; LFA
DNEGAT: dw $+2
	pop de                  ; MSW
        pop bc                  ; LSW
        ld hl, 0
        sbc hl, bc
        ld c, l
        ld b, h
        ld hl, 0
        sbc hl, de
        push bc
        push hl
        jp NEXT
