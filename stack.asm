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
	
;	2DUP

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

DROP:   dw $+2
        inc sp
        inc sp

;	DUP

;; L874E	db	$83,'DU',$D0
;; 	dw	L8744
DUP:    dw $+2
        pop hl
        push hl
        push hl
        jp NEXT
	
;	?DUP

;; L875E	db	$84,'?DU',$D0
;; 	dw	L874E
QDUP:
        dw $+2
        pop hl
        push hl
        jp z, NEXT
        push hl
        jp NEXT

;;	ROT

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
