all:
	$(MAKE) -C src

clean:
	$(MAKE) -C src clean
	$(RM) -r lib
