LOOPCOUNT_HIGH:  equ 1
LOOPCOUNT_LOW: equ 0

LOOPLIMIT_HIGH: equ 3
LOOPLIMIT_LOW: equ 2

;;;  (ULOOP)
L828C:
        db $87,'(ULOOP',$a9
        dw $0           ; LFA
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
        ld hl, (RSP)
        ld de, $4
        add hl, de
        ld (RSP), hl
        ;; pop offset and continue
        jp BUMP


;;;  (DO)

L82C8:
        db $84,'(DO',$a9
        dw $0           ; LFA
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
L82B3:
        db $81,'',$c9
        dw $0           ; LFA
IDO:    dw $+2
        ld hl, (RSP)
        ld e, (hl)
        inc hl
        ld d, (hl)
        push de
        jp NEXT
