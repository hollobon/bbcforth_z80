;;; Note - for double precision (32 bit) integers, the most-significant word
;;; goes on the top of the stack, with the least-significant word underneath.


;;; <

_NF_LESS:
        db	$81,$BC
	dw	_LF_LESS
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

_NF_GREAT:
	db	$81,$BE
	dw	_LF_GREAT
GREAT:	dw	DOCOL
	dw	SWAP
	dw	LESS
	dw	EXIT


;;;  +
_NF_PLUS:
        db $81,$ab
        dw _LF_PLUS
PLUS:   dw $+2
        pop hl
        pop bc
        add hl, bc
        push hl
        jp NEXT


;	MIN
;  : MIN 2DUP > 0BRANCH LIT 4 SWAP DROP EXIT ;
_NF_MIN:
	db	$83,'MI',$CE
	dw	_LF_MIN
MIN:	dw	DOCOL
	dw	TDUP
	dw	GREAT
	dw	ZBRAN,4
	dw	SWAP
	dw	DROP
	dw	EXIT


;;;  MAX
;;;     : MAX 2DUP < 0BRANCH 4 SWAP DROP EXIT ;
_NF_MAX:
        db $83,'MA',$d8
        dw _LF_MAX
MAX:    dw DOCOL
        dw TDUP
        dw LESS
        dw ZBRAN
        dw $4
        dw SWAP
        dw DROP
        dw EXIT


;;;  -
;;;     : - NEGATE + EXIT ;
_NF_SUBB:
        db $81,'',$ad
        dw _LF_SUBB
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
_NF_ZLESS:
        db $82,'0',$bc
        dw _LF_ZLESS
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
_NF_NEGAT:
        db $86,'NEGAT',$c5
        dw _LF_NEGAT
NEGAT:  dw $+2
        pop bc
        ld hl, 0
        and 0
        sbc hl, bc
        push hl
        jp NEXT


;;;  ABS
;;;     : ABS DUP +- EXIT ;
_NF_ABS:
        db $83,'AB',$d3
        dw _LF_ABS
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
_NF_PM:
        db $82,'+',$ad
        dw _LF_PM
PM:     dw DOCOL
        dw ZLESS
        dw ZBRAN
        dw $4
        dw NEGAT
        dw EXIT


;;;  1+
;;;     : 1+ 1 + EXIT ;
_NF_ONEP:
        db $82,'1',$ab
        dw _LF_ONEP
ONEP:   dw DOCOL
        dw ONE
        dw PLUS
        dw EXIT


;;; 1-
;;;    : 1- -1 + EXIT ;
_NF_ONESUB:
        db $82,'1',$ad
        dw _LF_ONESUB
ONESUB:  dw DOCOL
        dw TRUE
        dw PLUS
        dw EXIT


;;;  2+
;;;     : 2+ 2 + EXIT ;
_NF_TWOP:
        db $82,'2',$ab
        dw _LF_TWOP
TWOP:   dw DOCOL
        dw TWO
        dw PLUS
        dw EXIT


;;;  2-
;;;     : 2- -2 + EXIT ;
_NF_TWOSUB:
        db $82,'2',$ad
        dw _LF_TWOSUB
TWOSUB: dw DOCOL
        dw NEGTWO
        dw PLUS
        dw EXIT


;;;  2*
_NF_TSTAR:
        db $82,'2',$aa
        dw _LF_TSTAR
TSTAR:  dw $+2
        ld ix, 0
        add ix, sp
        sla (ix+0)
        rl (ix+1)
        jp NEXT


;;;  2/
_NF_TSLAS:
        db $82,'2',$af
        dw _LF_TSLAS
TSLAS:  dw $+2
        ld ix, 0
        add ix, sp
        sra (ix+1)
        rr (ix+0)
        jp NEXT


;;;  0=
_NF_ZEQU:
        db $82,'0',$bd
        dw _LF_ZEQU
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
_NF_ANDD:
        db $83,'AN',$c4
        dw _LF_ANDD
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
_NF_ORR:
        db $82,'O',$d2
        dw _LF_ORR
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
_NF_XORR:
        db $83,'XO',$d2
        dw _LF_XORR
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
_NF_DPLUS:
        db $82,'D',$ab
        dw _LF_DPLUS
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
_NF_USTAR:
        db $82,'U',$aa
        dw _LF_USTAR
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
_NF_DECIM:
        db $87,'DECIMA',$cc
        dw _LF_DECIM
DECIM:  dw DOCOL
        dw LIT
        dw $a
        dw BASE
        dw STORE
        dw EXIT


;;;  HEX
;;;     : HEX LIT 16 BASE ! EXIT ;
_NF_HEX:
        db $83,'HE',$d8
        dw _LF_HEX
HEX:    dw DOCOL
        dw LIT
        dw $10
        dw BASE
        dw STORE
        dw EXIT


;;;  0>
;;;     : 0> NEGATE 0< EXIT ;
_NF_ZGREA:
        db $82,'0',$be
        dw _LF_ZGREA
ZGREA:    dw DOCOL
        dw NEGAT
        dw ZLESS
        dw EXIT


;;;  =
;;;     : = - 0= EXIT ;
_NF_EQUAL:
        db $81,'',$bd
        dw _LF_EQUAL
EQUAL:  dw DOCOL
        dw SUBB
        dw ZEQU
        dw EXIT


;;;  DNEGATE
_NF_DNEGAT:
        db $87,'DNEGAT',$c5
        dw _LF_DNEGAT
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


;;;  D<
_NF_DLESS:
        db $82,'D',$bc
        dw _LF_DLESS
DLESS:  dw $+2
        ld ix, 0
        add ix, sp

        ld bc, 0

	scf
        ccf
        ld a, (ix+6)
        sbc a, (ix+2)
        ld a, (ix+7)
        sbc a, (ix+3)
	ld a, (ix+4)
        sbc a, (ix+0)
	ld a, (ix+5)
        sbc a, (ix+1)

        jp po,	_DLESS_NO_OVERFLOW
        xor $80

_DLESS_NO_OVERFLOW:                          ;
	jp p, _DLESS_POSITIVE

        inc c
_DLESS_POSITIVE:
        pop hl
        pop hl
        pop hl
        pop hl
        push bc

        jp NEXT


;;;  U<
;;;     : U< 0 SWAP 0 D< EXIT ;
_NF_ULESS:
        db $82,'U',$bc
        dw _LF_ULESS
ULESS:  dw DOCOL
        dw ZERO
        dw SWAP
        dw ZERO
        dw DLESS
        dw EXIT


;;;  D+-
;;;     : D+- 0< 0BRANCH 4 DNEGATE EXIT ;
_NF_DPM:
        db $83,'D+',$ad
        dw _LF_DPM
DPM:    dw DOCOL
        dw ZLESS
        dw ZBRAN
        dw $4
        dw DNEGAT
        dw EXIT


;;;  DABS
;;;     : DABS DUP D+- EXIT ;
_NF_DABS:
        db $84,'DAB',$d3
        dw _LF_DABS
DABS:   dw DOCOL
        dw DUPP
        dw DPM
        dw EXIT


;;;  S->D
_NF_STOD:
        db $84,'S->',$c4
        dw _LF_STOD
STOD:   dw $+2
        pop hl
        ld bc, 0
        ld a, h
        and $80
        jr z, _STOD_POSITIVE
        dec bc
_STOD_POSITIVE:
        push hl
        push bc
        jp NEXT
