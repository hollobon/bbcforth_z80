.PHONY: test clean forthz.ROM

forthz.ROM:
	cd src && $(MAKE) $@
	cp src/$@ .

test:
	cd src && $(MAKE) $@

clean:
	cd src && $(MAKE) $@
