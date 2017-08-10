        ;; output byte as hex
DOTCHEX:dw $+2
        pop bc
        call _DOTCHEX
        jp NEXT

        ;; output word as hex
_NF_DOTHEX:
        db $84,'DOTHE',$d8
        dw _LF_DOTHEX
DOTHEX: dw $+2
        pop bc
        ld l, c
        ld c, b
        call _DOTCHEX
        ld c, l
        call _DOTCHEX
        jp NEXT

        ;; display byte value in c as hex
        ;; overwrites a
_DOTCHEX:
        ld a, c
        srl a
        srl a
        srl a
        srl a
        cp 10
        jp p, ALPHA
        or 48
        jp .OUT
ALPHA:  add 55
.OUT:   call OSWRCH

	ld a, c
        and $f
        cp 10
        jp p, ALPHA1
        or 48
        jp OUT1
ALPHA1: add 55
OUT1:   call OSWRCH

        ret
