forthz.ROM: forthz_z80.asm forthz_6502.a
	z80asm --list=$@.LST $< -o $@ 

forthz_6502.a: forthz_6502.asm
	xa $< -o $@
