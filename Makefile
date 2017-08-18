.PHONY: test clean

forthz.ROM: forthz_z80.asm word.asm arith.asm stack.asm loop.asm util.asm tests.asm.gen forthz_6502.a
	sed -n 's/^\_NF_\([A-Z_]\+\):.*$$/_LF_\1: equ 0/p' *.asm | sort | uniq | ./assign_links.py links.asm.gen
	z80asm --list=$@.LST --label=$@.LABEL $< -o $@

tests.asm.gen: tests.asm renumber_tests.py
	./renumber_tests.py --only "$(ONLY)" $< $<.gen

forthz_6502.a: forthz_6502.asm
	xa $< -o $@

test: forthz.ROM
	@echo 'In BeebEm, set RS423 to IP: localhost:25232 then issue *TEST'
	@echo 'Waiting ...'
	@./zforthtests.py

clean:
	rm *.gen *.ROM *.LABEL *.LST *.a

user.asm:
	./parsewords.py --alloftype DOUSE > $@

constants.asm:
	./parsewords.py --alloftype DOCON > $@
