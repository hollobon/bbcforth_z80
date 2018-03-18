.PHONY: test clean

# Build the ROM image from Z80 source, including the 6502 portion
forthz.ROM: forthz_z80.asm word.asm arith.asm stack.asm loop.asm util.asm tests.asm.gen forthz_6502.a
	sed -n 's/^\_NF_\([A-Z_]\+\):.*$$/_LF_\1: equ 0/p' *.asm | sort | uniq | ./assign_links.py links.asm.gen
	z80asm --list=$@.LST --label=$@.LABEL $< -o $@

# Build generated tests file
tests.asm.gen: tests.asm renumber_tests.py
	./renumber_tests.py --only "$(ONLY)" $< $<.gen

# Build the 6502 portion
forthz_6502.a: forthz_6502.asm
	xa $< -o $@

# Build tests - set ONLY=LIST,OF,TESTS to run a subset of tests
test: forthz.ROM
	cp forthz.ROM ../
	@echo 'In BeebEm, set RS423 to IP: localhost:25232 then issue *TEST'
	@echo 'Waiting ...'
	@./zforthtests.py

clean:
	rm -f *.gen *.ROM *.LABEL *.LST *.a

# Build user word definitions from original 6502 disassembly
user.asm:
	./parsewords.py --alloftype DOUSE > $@

# Build constant word definitions from original 6502 disassembly
constants.asm:
	./parsewords.py --alloftype DOCON > $@
