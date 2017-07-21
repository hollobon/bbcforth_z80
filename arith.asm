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
