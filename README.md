# Z80 Port of Acornsoft Forth

This is a largely pointless port of Acornsoft Forth for the BBC Micro to the Z80 second processor.

I have no use for it, but I was interested in Forth, keen to re-learn 6502 and Z80 assembler, and
interested in the BBC, so it seemed like a nice little project.

The source for the port was a disassembled version of the above found on the internet. Almost all
6502 code has been rewritten (apart from the initial stub that runs on the host processor), but
the words implemented in Forth remain. Some of the 6502 code seems to have been taken pretty much
verbatim from FIG-Forth (see http://www.forth.org/fig-forth/fig-forth_6502.pdf), excluding
BBC-specific parts of course.

This is provided purely for educational purposes.
