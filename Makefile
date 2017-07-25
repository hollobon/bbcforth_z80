.PHONY: test clean

forthz.ROM: forthz_z80.asm word.asm arith.asm stack.asm loop.asm tests.asm.gen forthz_6502.a
	z80asm --list=$@.LST --label=$@.LABEL $< -o $@ 

tests.asm.gen: tests.asm
	./renumber_tests.py $< $<.gen

forthz_6502.a: forthz_6502.asm
	xa $< -o $@

test: forthz.ROM
	@echo 'In BeebEm, set RS423 to IP: localhost:25232 then issue *TEST'
	./zforthtests.py

clean:
	rm *.gen *.ROM *.LABEL *.LST *.a
