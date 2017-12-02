.PHONY: test clean forthz.ROM

forthz.ROM:
	$(MAKE) -C src $@
	cp src/$@ .

test:
	$(MAKE) -C src $@

clean:
	$(MAKE) -C src $@
