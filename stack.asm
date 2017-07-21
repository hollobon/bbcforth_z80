;;;  OVER
L87D2:
        db $84,'OVE',$d2
        dw $0           ; LFA
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


;;;	2DUP
L8770:	db	$84,'2DU',$D0
	dw	$0
TDUP:	dw	$+2
        ld ix, 0
	add ix, sp
        ld l, (ix+0)
        ld h, (ix+1)
        ld d, (ix+2)
        ld e, (ix+3)
        push hl
        push de
        jp NEXT


;;;  SWAP
L878F:
        db $84,'SWA',$d0
        dw $0           ; LFA
SWAP:   dw $+2
        ld ix, 0
        add ix, sp
        ld l, (ix+0)
        ld h, (ix+1)
        ld d, (ix+2)
        ld c, (ix+3)
        ld (ix+0), d
        ld (ix+1), c
        ld (ix+2), l
        ld (ix+3), h
        jp NEXT


;;;  DROP
L873B:
        db $84,'DRO',$d0
        dw $0           ; LFA
DROP:   dw $+2
        inc sp
        inc sp
        jp NEXT


;;;  DUP
L874E:
        db $83,'DU',$d0
        dw $0           ; LFA
DUPP:   dw $+2
        pop hl
        push hl
        push hl
        jp NEXT


;;;	?DUP
L875E:
        db $84,'?DU',$d0
        dw $0           ; LFA
QDUP:
        dw $+2
        pop hl
        push hl
        jp z, NEXT
        push hl
        jp NEXT


;;;	ROT
L87FF:  db $83,'RO',$D4
	dw $0
ROT:    dw $+2
        ld ix, 0
        add ix, sp

        ld c, (ix+4)
        ld b, (ix+5)

        ld a, (ix+3)
        ld (ix+5), a
        ld a, (ix+2)
        ld (ix+4), a

        ld a, (ix+1)
        ld (ix+3), a
        ld a, (ix+0)
        ld (ix+2), a

        ld (ix+0), c
        ld (ix+1), b

        jp NEXT


;;;  PICK
L9B90:
        db $84,'PIC',$cb
        dw $0           ; LFA
PICK:   dw $+2
        pop bc                  ; get n, multiply by 2 to get offset in bytes
        sla c
        sla b

        ld ix, 0                ; get SP
        add ix, sp

        add ix, bc              ; apply offset

        ld c, (ix+0)            ; load word from stack
        ld b, (ix+1)

        push bc
        jp NEXT


;;;  SP@
L8422:
        db $83,'SP',$c0
        dw $0           ; LFA
SPAT:   dw $+2
        ld ix, 0
        add ix, sp
        push ix
        jp NEXT 


;;;  SP!
L8445:
        db $83,'SP',$a1
        dw $0           ; LFA
SPSTO:  dw $+2
        ld hl, (UAVALUE+2)
        ld sp, hl
        jp NEXT


;;;  DEPTH
;;;     : DEPTH SP@ S0 @ - NEGATE 2/ EXIT ;
L9B46:
        db $85,'DEPT',$c8
        dw $0           ; LFA
DEPTH:  dw DOCOL
        dw SPAT
        dw SZERO
;        dw AT
        dw SUBB
        dw NEGAT
        dw TSLAS
        dw EXIT
