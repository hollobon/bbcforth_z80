forthz.ROM: forthz_z80.asm forthz_6502.a
	z80asm $< -o $@

forthz_6502.a: forthz.asm
	xa $< -o $@
