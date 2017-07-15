.PHONY: renumber_tests

forthz.ROM: forthz_z80.asm arith.asm stack.asm tests.asm forthz_6502.a renumber_tests
	z80asm --list=$@.LST $< -o $@ 

renumber_tests: tests.asm
	./renumber_tests.py
# mv tests.asm.new tests.asm
	cp tests.asm.new tests.asm

forthz_6502.a: forthz_6502.asm
	xa $< -o $@

test: forthz.ROM
	@echo 'Set RS423 to IP: localhost:25232 then issue *FX3,1 then *FX2,1'
	./zforthtests.py

