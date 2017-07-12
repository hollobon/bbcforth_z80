;	<

L8688:	db	$81,$BC
	dw	$0
LESS:	dw	$+2
        pop hl
        pop bc
        sbc hl, bc
        ld hl, $0
        jp m, _LESS1
        push hl
        jp NEXT
_LESS1: ld l, 1
        push hl
        jp NEXT
;; 	SEC
;; 	LDA	2,X
;; 	SBC	0,X
;; 	LDA	3,X
;; 	SBC	1,X
;; 	STY	3,X
;; 	BVC	L869D
;; 	EOR	#$80
;; L869D:	BPL	L86A0
;; 	INY
;; L86A0:	STY	2,X
;; 	JMP	POP
	
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
