;	<

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
	
;	>

L8BA3:	db	$81,$BE
	dw	$0
GREAT:	dw	DOCOL
	dw	SWAP
	dw	LESS
	dw	EXIT

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
