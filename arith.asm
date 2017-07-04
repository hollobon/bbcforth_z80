        db 1
        db 'PLUS'
PLUS:   dw $+2
        pop hl
        pop bc
        add hl, bc
        push hl
        jp NEXT
