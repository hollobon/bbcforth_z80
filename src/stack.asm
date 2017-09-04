;;;  OVER
_NF_OVER:
        db $84,'OVE',$d2
        dw _LF_OVER
OVER:   dw $+2
        ld hl, 2
        add hl, sp
        ld c, (hl)
        inc hl
        ld b, (hl)
        push bc
        jp NEXT


;; NIP:    dw $+2
;;         pop hl
;;         inc sp
;;         inc sp
;;         push hl
;;         jp NEXT


;;;	2DUP
_NF_TDUP:
	db	$84,'2DU',$D0
	dw	_LF_TDUP
TDUP:	dw	$+2
        ld hl, 0
        add hl, sp
        ld c, (hl)
        inc hl
        ld b, (hl)
        inc hl
        ld e, (hl)
        inc hl
        ld d, (hl)
        push de
        push bc
        jp NEXT


;;;  SWAP
_NF_SWAP:
        db $84,'SWA',$d0
        dw _LF_SWAP
SWAP:   dw $+2
        ld hl, 0
        add hl, sp

        ld c, (hl)
        inc hl
        ld b, (hl)
        inc hl
        ld e, (hl)
        inc hl
        ld d, (hl)

        ld (hl), b
        dec hl
        ld (hl), c
        dec hl
        ld (hl), d
        dec hl
        ld (hl), e

        jp NEXT


;;;  DROP
_NF_DROP:
        db $84,'DRO',$d0
        dw _LF_DROP
DROP:   dw $+2
        inc sp
        inc sp
        jp NEXT


;;;  DUP
_NF_DUPP:
        db $83,'DU',$d0
        dw _LF_DUPP
DUPP:   dw $+2
        pop hl
        push hl
        push hl
        jp NEXT


;;;	?DUP
_NF_QDUP:
        db $84,'?DU',$d0
        dw _LF_QDUP
QDUP:
        dw $+2
        pop hl
        push hl
        ld a, l
        cp 0
        jr z, _QDUPNEXT
        cp h
        jr z, _QDUPNEXT
        push hl
_QDUPNEXT:
        jp NEXT


;;;	ROT
_NF_ROT:
        db $83,'RO',$D4
	dw _LF_ROT
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
_NF_PICK:
        db $84,'PIC',$cb
        dw _LF_PICK
PICK:   dw $+2
        pop hl                  ; get n, multiply by 2 to get offset in bytes
        sla l
        sla h

        add hl, sp

        ld c, (hl)            ; load word from stack
        inc hl
        ld b, (hl)

        push bc
        jp NEXT


;;;  SP@
_NF_SPAT:
        db $83,'SP',$c0
        dw _LF_SPAT
SPAT:   dw $+2
        ld hl, 0
        add hl, sp
        push hl
        jp NEXT


;;;  SP!
_NF_SPSTO:
        db $83,'SP',$a1
        dw _LF_SPSTO
SPSTO:  dw $+2
        ld hl, (UAVALUE+2)
        ld sp, hl
        jp NEXT


;;;  DEPTH
;;;     : DEPTH SP@ S0 @ - NEGATE 2/ EXIT ;
_NF_DEPTH:
        db $85,'DEPT',$c8
        dw _LF_DEPTH
DEPTH:  dw DOCOL
        dw SPAT
        dw SZERO
        dw AT
        dw SUBB
        dw NEGAT
        dw TSLAS
        dw EXIT


;;;  >R
_NF_TOR:
        db $82,'>',$d2
        dw _LF_TOR
TOR:    dw $+2
        pop hl

	ld de, (RSP)

        ld a, h
        dec de
        ld (de), a
        ld a, l
        dec de
        ld (de), a

        ld (RSP), de
        jp NEXT


;;;  R>
_NF_RFROM:
        db $82,'R',$be
        dw _LF_RFROM
RFROM:  dw $+2
	ld de, (RSP)

        ld a, (de)
        ld c, a
        inc de
        ld a, (de)
        ld b, a
        inc de
        push bc

        ld (RSP), de
        jp NEXT


;;;  RP@
_NF_RPAT:
        db $83,'RP',$c0
        dw _LF_RPAT
RPAT:   dw $+2
	ld de, (RSP)
        push de
        jp NEXT


;;;  RP!
L8455:
        db $83,'RP',$a1
        dw $0           ; LFA
RPSTO:  dw $+2

        jp NEXT


;;;  R@
_NF_RAT:
        db $82,'R',$c0
        dw _LF_RAT
RAT:    dw $+2
        ld hl, (RSP)
        ld e, (hl)
        inc hl
        ld d, (hl)
        push de
        jp NEXT


;;;  2DROP
_NF_TDROP:
        db $85,'2DRO',$d0
        dw _LF_TDROP
TDROP:  dw DOCOL
        dw DROP
        dw DROP
        dw EXIT


;;;  ROLL
_D_ROLL_TEMP:   dw 0

_NF_ROLL:
        db $84,'ROL',$cc
        dw _LF_ROLL
ROLL:   dw $+2
        pop bc                  ; get n, multiply by 2 to get offset in bytes
        dec bc
        sla c
        sla b

        ld hl, 1                ; get SP
        add hl, sp

        add hl, bc              ; apply offset

        ld d, (hl)
        dec hl
        ld e, (hl)

        push de

        inc hl

        ld d, h
        ld e, l

        dec hl
        dec hl

        lddr

        pop de
        pop bc
        push de

        jp NEXT


;;;  2SWAP
_NF_TSWAP:
        db $85,'2SWA',$d0
        dw _LF_TSWAP
TSWAP:  dw $+2
        ld hl, 0
        add hl, sp
        ex de, hl
        ld hl, 4
        add hl, sp

        ld b, (hl)
        ex de, hl
        ld c, (hl)
        ld (hl), b
        inc hl
        ex de, hl
        ld (hl), c
        inc hl

        ld b, (hl)
        ex de, hl
        ld c, (hl)
        ld (hl), b
        inc hl
        ex de, hl
        ld (hl), c
        inc hl

	ld b, (hl)
        ex de, hl
        ld c, (hl)
        ld (hl), b
        inc hl
        ex de, hl
        ld (hl), c
        inc hl

	ld b, (hl)
        ex de, hl
        ld c, (hl)
        ld (hl), b
        ex de, hl
        ld (hl), c

        jp NEXT


;;;  2OVER
_NF_TOVER:
        db $85,'2OVE',$d2
        dw _LF_TOVER
TOVER:  dw $+2

        ld hl, -1
        add hl, sp
        ex de, hl

        ld hl, 7
        add hl, sp

        ld bc, 4

        lddr

        ex de, hl
        inc hl
        ld sp, hl

        jp NEXT
