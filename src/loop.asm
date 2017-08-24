LOOPCOUNT_HIGH:  equ 1
LOOPCOUNT_LOW: equ 0

LOOPLIMIT_HIGH: equ 3
LOOPLIMIT_LOW: equ 2

;;;  (ULOOP)
_NF_XPULO:
        db $87,'(ULOOP',$a9
        dw _LF_XPULO
XPULO:  dw $+2
        ld bc, (RSP)
        ld ix, 0
        add ix, bc
        inc (ix+LOOPCOUNT_LOW)
        jp nz, _XPULO_NI
        inc (ix+LOOPCOUNT_HIGH)
_XPULO_NI:
        ld a, (ix+LOOPLIMIT_LOW)
        scf
        sbc a, (ix+LOOPCOUNT_LOW)
        ld a, (ix+LOOPLIMIT_HIGH)
        sbc a, (ix+LOOPCOUNT_HIGH)
        jp p, _BRAN    ; continue loop

        ;; end of loop - pop 2 values from return stack that were put there by (DO)
_LOOP_DONE:
        ld hl, (RSP)
        ld de, $4
        add hl, de
        ld (RSP), hl
        ;; pop offset and continue
        jp BUMP


;;;  (LOOP)
_NF_XLOOP:
        db $86,'(LOOP',$a9
        dw _LF_XLOOP
XLOOP:  dw $+2

        ld bc, (RSP)
        ld ix, 0
        add ix, bc
        inc (ix+LOOPCOUNT_LOW)
        jp nz, _XPULO_NI
        inc (ix+LOOPCOUNT_HIGH)
        jp po, _XPULO_NI
        jp _LOOP_DONE
_XLOOP_NI:
        ld a, (ix+LOOPLIMIT_LOW)
        scf
        sbc a, (ix+LOOPCOUNT_LOW)
        ld a, (ix+LOOPLIMIT_HIGH)
        sbc a, (ix+LOOPCOUNT_HIGH)
        jp po, _XLOOP_NI
        xor $80
        jp p, _BRAN    ; continue loop
        jp _LOOP_DONE


;;;  (DO)

_NF_XDO:
        db $84,'(DO',$a9
        dw _LF_XDO
XDO:    dw $+2
        ld hl, (RSP)
        pop de                  ; inital counter value
        pop bc                  ; loop limit
        dec hl
        ld (hl), b
        dec hl
        ld (hl), c
        dec hl
        ld (hl), d
        dec hl
        ld (hl), e
        ld (RSP), hl
        jp NEXT


;;;  I
_NF_IDO:
        db $81,'',$c9
        dw _LF_IDO
IDO:    dw $+2
        ld hl, (RSP)
        ld e, (hl)
        inc hl
        ld d, (hl)
        push de
        jp NEXT


;;;  DO
;;;     : DO COMPILE (DO) HERE 3 ;
_NF_DO:
        db $c2,'D',$cf
        dw _LF_DO
DO:     dw DOCOL
        dw COMP
        dw XDO
        dw HERE
        dw LIT
        dw $3
        dw EXIT


;;;  LOOP
;;;     : LOOP 3 ?PAIRS COMPILE (LOOP) BACK ;
_NF_LOOP:
        db $c4,'LOO',$d0
        dw _LF_LOOP
LOOP:   dw DOCOL
        dw LIT
        dw $3
        dw QPAIR
        dw COMP
        dw XLOOP
        dw BACK
        dw EXIT


;;;  BEGIN
;;;     : BEGIN ?COMP HERE 1 ;
_NF_BEGIN:
        db $c5,'BEGI',$ce
        dw _LF_BEGIN
BEGIN:    dw DOCOL
        dw QCOMP
        dw HERE
        dw ONE
        dw EXIT


;;;  UNTIL
;;;     : UNTIL 1 ?PAIRS COMPILE 0BRANCH BACK ;
_NF_UNTIL:
        db $c5,'UNTI',$cc
        dw _LF_UNTIL
UNTIL:  dw DOCOL
        dw ONE
        dw QPAIR
        dw COMP
        dw ZBRAN
        dw BACK
        dw EXIT


;;;  REPEAT
;;;     : REPEAT >R >R AGAIN R> R> 2 - THEN ;
_NF_REPEAT:
        db $c6,'REPEA',$d4
        dw _LF_REPEAT
REPEAT: dw DOCOL
        dw TOR
        dw TOR
        dw AGAIN
        dw RFROM
        dw RFROM
        dw TWO
        dw SUBB
        dw THEN
        dw EXIT


;;;  WHILE
;;;     : WHILE IF 2+ ;
_NF_WHILE:
        db $c5,'WHIL',$c5
        dw _LF_WHILE
WHILE:  dw DOCOL
        dw IFF
        dw TWOP
        dw EXIT


;;;  AGAIN
;;;     : AGAIN 1 ?PAIRS COMPILE BRANCH BACK ;
_NF_AGAIN:
        db $c5,'AGAI',$ce
        dw _LF_AGAIN
AGAIN:  dw DOCOL
        dw ONE
        dw QPAIR
        dw COMP
        dw BRAN
        dw BACK
        dw EXIT


;;;  BACK
;;;     : BACK HERE - , ;
_NF_BACK:
        db $84,'BAC',$cb
        dw _LF_BACK
BACK:   dw DOCOL
        dw HERE
        dw SUBB
        dw COMMA
        dw EXIT
