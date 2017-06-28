	org $8000
        incbin 'forthz_6502.a'
HERE:
        ld a, 65
        call $ffee
        jp HERE
