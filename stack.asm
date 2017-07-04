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

;; L874E	.BYTE	$83,'DU',$D0
;; 	.WORD	L8744
DUP:    dw $+2
        pop hl
        push hl
        push hl
        jp NEXT
	
;	?DUP

;; L875E	.BYTE	$84,'?DU',$D0
;; 	.WORD	L874E
QDUP:
        dw $+2
        pop hl
        push hl
        jp z, NEXT
        push hl
        jp NEXT
