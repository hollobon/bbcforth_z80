forthz.ROM: forthz_6502.a forthz_z80.a
	cat $^ > $@
	dd if=/dev/zero of=$@ bs=1 count=1 seek=16383

forthz_6502.a: forthz.asm
	xa $< -o $@

forthz_z80.a: forthz_z80.asm
	z80asm $< -o $@
