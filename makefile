TOP = .
include Makefile.conf

OS = $(shell uname -s)
ifeq ($(OS),Darwin)
SHLIB_EXT = dylib
else
SHLIB_EXT = so
endif
ifeq ($(HOST),SunOS)
CP_FP = cp -f
else
CP_FP = cp -fP
endif

DJDEV64LIB = lib/libdjdev64.*.*.*
DJDEV64LIBV = lib/libdjdev64.*.*
DJDEV64DEVL = lib/libdjdev64.$(SHLIB_EXT)
DJSTUB64LIB = lib/libdjstub64.*.*.*
DJSTUB64LIBV = lib/libdjstub64.*.*
DJSTUB64DEVL = lib/libdjstub64.$(SHLIB_EXT)

all:
	$(MAKE) -C src

clean:
	$(MAKE) -C src clean
	$(RM) -r lib

install:
	$(INSTALL) -d $(DESTDIR)$(libdir)/pkgconfig
	$(INSTALL) -m 0644 djdev64.pc $(DESTDIR)$(libdir)/pkgconfig
	$(INSTALL) -m 0644 djstub64.pc $(DESTDIR)$(libdir)/pkgconfig
	$(INSTALL) -d $(DESTDIR)$(includedir)/djdev64
	cp -rL $(abs_top_srcdir)/include/djdev64 $(DESTDIR)$(includedir)
	$(INSTALL) -d $(DESTDIR)$(libdir)
	$(INSTALL) -m 0755 $(DJDEV64LIB) $(DESTDIR)$(libdir)
	$(CP_FP) $(DJDEV64LIBV) $(DESTDIR)$(libdir)
	$(CP_FP) $(DJDEV64DEVL) $(DESTDIR)$(libdir)
	$(INSTALL) -m 0755 $(DJSTUB64LIB) $(DESTDIR)$(libdir)
	$(CP_FP) $(DJSTUB64LIBV) $(DESTDIR)$(libdir)
	$(CP_FP) $(DJSTUB64DEVL) $(DESTDIR)$(libdir)
	@echo "Done installing. You may need to run \"sudo ldconfig\" now."

uninstall:
	$(RM) $(DESTDIR)$(libdir)/pkgconfig/djdev64.pc
	$(RM) $(DESTDIR)$(libdir)/pkgconfig/djstub64.pc
	$(RM) $(DESTDIR)$(libdir)/$(notdir $(DJDEV64DEVL))
	$(RM) $(DESTDIR)$(libdir)/$(notdir $(DJDEV64LIBV))
	$(RM) $(DESTDIR)$(libdir)/$(notdir $(DJDEV64LIB))
	$(RM) $(DESTDIR)$(libdir)/$(notdir $(DJSTUB64DEVL))
	$(RM) $(DESTDIR)$(libdir)/$(notdir $(DJSTUB64LIBV))
	$(RM) $(DESTDIR)$(libdir)/$(notdir $(DJSTUB64LIB))
	ldconfig

deb:
	debuild -i -us -uc -b

rpm:
	$(MAKE) clean
	rpkg local && $(MAKE) clean >/dev/null
