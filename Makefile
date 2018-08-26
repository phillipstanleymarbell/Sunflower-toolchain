include ../conf/setup.conf

GCCVER		= 7.2.0
GCC		= $(TOOLS)/source/gcc-$(GCCVER)
BINUTILS	= $(TOOLS)/source/binutils-2.29.1
NEWLIB		= $(TOOLS)/source/newlib-2.5.0.20170922


all: binutils gcc newlib


binutils: binutils-pre binutils-post

binutils-pre:
	if test -d $(TOOLS)/bin; then true; else mkdir $(TOOLS)/bin; fi;\
	if test -d $(TOOLS)/$(TARGET); then true; else mkdir $(TOOLS)/$(TARGET); fi;\
	cd $(BINUTILS);\
	$(DEL) objdir; mkdir -p objdir; cd objdir;\
	export MAKEINFO=missing && ../configure --disable-docs --target=$(TARGET-ARCH)\
		--prefix=$(PREFIX) --disable-libssp --disable-nls -v;\
	$(MAKE) -r CC=$(TOOLCC) CFLAGS="-D_FORTIFY_SOURCE=1" LD=$(TOOLCC) all install;\

binutils-post:
	mv $(PREFIX)/bin/$(TARGET-ARCH)* $(TOOLS)/bin/;\
	$(DEL) $(BINUTILS)/objdir;\



gcc: gcc-pre gcc-post

g++-pre:
	if test -d $(TOOLS)/bin; then true; else mkdir $(TOOLS)/bin; fi;\
	if test -d $(TOOLS)/$(TARGET); then true; else mkdir $(TOOLS)/$(TARGET); fi;\
	cd $(GCC);\
	$(DEL) objdir; mkdir -p objdir; cd objdir;\
	export CC=$(TOOLCC) CXX=$(TOOLCXX) LD=$(TOOLCC) CFLAGS='-fgnu89-inline -ansi -std=c99 -D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE' CXXFLAGS='-D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE' MAKEINFO=missing && ../configure --disable-docs --target=$(TARGET-ARCH) --prefix=$(PREFIX)\
		--disable-libssp --with-gnu-as --with-gnu-ld --with-newlib\
		--enable-languages="c,c++"\
		--with-headers=$(NEWLIB)/newlib/libc/include --with-gmp=/opt/local --with-mpfr=/opt/local --with-mpc=/opt/local -v;\	# On macOS with macports, add --with-gmp=/opt/local --with-mpfr=/opt/local --with-mpc=/opt/local
	$(MAKE) CC=$(TOOLCC) CXX=$(TOOLCXX) LD=$(TOOLCC) CFLAGS="-fgnu89-inline -std=c99 -ansi -D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE" CXXFLAGS='-D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE';\		# On MacOS, add "-D_DARWIN_C_SOURCE" to both flags
	$(MAKE) CC=$(TOOLCC) CXX=$(TOOLCXX) LD=$(TOOLCC) CFLAGS="-fgnu89-inline -ansi -std=c99 -D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE" CXXFLAGS='-D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE' install;\	# On MacOS, add "-D_DARWIN_C_SOURCE" to both flags

gcc-pre:
	if test -d $(TOOLS)/bin; then true; else mkdir $(TOOLS)/bin; fi;\
	if test -d $(TOOLS)/$(TARGET); then true; else mkdir $(TOOLS)/$(TARGET); fi;\
	cd $(GCC);\
	$(DEL) objdir; mkdir -p objdir; cd objdir;\
	export CC=$(TOOLCC) CXX=$(TOOLCXX) LD=$(TOOLCC) CFLAGS='-fgnu89-inline -ansi -std=c99 -D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE' CXXFLAGS='-D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE' MAKEINFO=missing && ../configure --disable-docs --target=$(TARGET-ARCH) --prefix=$(PREFIX)\
		--disable-libssp --with-gnu-as --with-gnu-ld --with-newlib\
		--enable-languages=c $(ADDITIONAL_ARCH_FLAGS) --disable-multilib\
		--with-headers=$(NEWLIB)/newlib/libc/include --with-gmp=/opt/local --with-mpfr=/opt/local --with-mpc=/opt/local -v;\
	$(MAKE) CC=$(TOOLCC) CXX=$(TOOLCXX) LD=$(TOOLCC) CFLAGS="-fgnu89-inline -ansi -std=c99 -D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE" CXXFLAGS='-D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE';\		# On MacOS, add "-D_DARWIN_C_SOURCE" to both flags
	$(MAKE) CC=$(TOOLCC) CXX=$(TOOLCXX) LD=$(TOOLCC) CFLAGS="-fgnu89-inline -ansi -std=c99 -D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE" CXXFLAGS='-D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE' install;\	# On MacOS, add "-D_DARWIN_C_SOURCE" to both flags


gcc-post:
	cp $(PREFIX)/lib/gcc-lib/$(TARGET-ARCH)/$(GCCVER)/*.a $(SUNFLOWERROOT)/tools/tools-lib/$(TARGET)/;\
	cp $(PREFIX)/lib/gcc/$(TARGET-ARCH)/$(GCCVER)/*.a $(SUNFLOWERROOT)/tools/tools-lib/$(TARGET)/;\
	cp $(PREFIX)/lib/*.a $(SUNFLOWERROOT)/tools/tools-lib/$(TARGET)/;\
	cp $(PREFIX)/bin/$(TARGET-ARCH)* $(TOOLS)/bin/;\
	$(DEL) $(GCC)/objdir;\



newlib: newlib-pre newlib-post

newlib-pre:
	if test -d $(TOOLS)/bin; then true; else mkdir $(TOOLS)/bin; fi;\
	if test -d $(TOOLS)/$(TARGET); then true; else mkdir $(TOOLS)/$(TARGET); fi;\
	cd $(NEWLIB);\
	$(DEL) objdir; mkdir -p objdir; cd objdir;\
	../configure --target=$(TARGET-ARCH) --prefix=$(PREFIX)\
		-v --with-stabs --nfp --disable-multilib;\
	$(MAKE) -j5 CC=$(TOOLCC) all;\
	$(MAKE) CC=$(TOOLCC) install;\

newlib-post:
	cp $(PREFIX)/$(TARGET-ARCH)/lib/*.a $(SUNFLOWERROOT)/tools/tools-lib/$(TARGET)/;\
	#$(DEL) $(NEWLIB)/objdir;\



clean:
	@echo '==> $(BINUTILS)'; $(DEL) $(BINUTILS)/objdir
	@echo '==> $(GCC)'; $(DEL) $(GCC)/objdir
	@echo '==> $(NEWLIB)'; $(DEL) $(NEWLIB)/objdir

nuke:
	@echo '==> $(BINUTILS)'; $(DEL) $(BINUTILS)/objdir
	@echo '==> $(GCC)'; $(DEL) $(GCC)/objdir
	@echo '==> $(TOOLS)'; $(DEL) $(TOOLS)/bin
	@echo '==> $(NEWLIB)'; $(DEL) $(NEWLIB)/objdir
	@set -e; for dir in $(SUPPORTED-TARGETS); do\
		($(DEL) $$dir; echo 'rm -rf' $$dir);\
	done;\
