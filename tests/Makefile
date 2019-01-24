# Dlang
DINCL = -I. -I"../source/" -I"./modules/"

SOURCES_lib = $(shell find -L "../source/" -type f -name '*.d')
SOURCES_mdl = $(shell find -L "./modules/" -type f -name '*.d')

# dmd
DCMP  = dmd -debug -w -g -wi ${DINCL}
DLD   = dmd -debug -w -g -wi

# Dlang compiler/linker out option
DOUT = -of=

ifeq ($(BUILD),release)   
	# Dlang
	# dmd
	#DCMP  = dmd -color -O -inline -release -w -boundscheck=off
	#DLD   = dmd -color -O -release -w 
	# ldc
	#DCMP  = ldc2 -O3 -dw -enable-inlining -release -w -wi -boundscheck=off ${DINCL}
	DCMP  = ldc2 -O3 -dw -release -w -wi -boundscheck=off ${DINCL}
	# -expensive-combines -template-depth=100


	#DLD	  = ldc2 -O3 -dw -release -w 
	# DLD	  = ldc2 -O3 -dw -release -w \
	# 	/usr/lib/x86_64-linux-gnu/libphobos2-ldc.a \
	# 	/usr/lib/x86_64-linux-gnu/libdruntime-ldc.a \
	# 	-L-lz

	DLD	  = ldc2 -O3 -dw -release -w \
		-link-defaultlib-shared=false \
		-defaultlib=:libphobos2-ldc.a,:libdruntime-ldc.a,:libz.a

	# DLD	  = ldc2 -O3 -dw -release -w \
	# 	-link-defaultlib-shared=false \
	# 	-L-l:libphobos2-ldc.a -L-l:libdruntime-ldc.a -L-l:libz.a

	# gdc
	#DCMP  = gdc -Wp,-color,-O,-inline,-release,-w,-boundscheck=off -Wa,-w
	#DLD	  = gdc -Wl,-O,-release 
	## Dlang compiler/linker out option
	#DOUT		   = -o 
else
	# "Debug" build - no optimization, and debugging symbols
	
endif


############################################################
.PHONY: clean release all cleanall

# make dev version
all: tests.bin
	@echo
	@echo "\033[1;36mBuild complite \033[0m"

# make release version
release:
	make "BUILD=release"

o/tests.o: tests.d
	${DCMP} -c tests.d ${DOUT}o/tests.o

OBJECTS_lib := $(patsubst ../source/drocks/%.d,o/lib/%.o, $(SOURCES_lib))
OBJECTS_mdl := $(patsubst ./modules/%.d,o/mdl/%.o, $(SOURCES_mdl))

tests.bin:  o/tests.o $(OBJECTS_lib) $(OBJECTS_mdl)
	@echo ""
	${DLD} -w o/tests.o $(OBJECTS_mdl) $(OBJECTS_lib) ${DOUT}tests.bin
	@echo ""


$(OBJECTS_lib) : o/lib/%.o : ../source/drocks/%.d
	${DCMP} -c $< ${DOUT}$@

$(OBJECTS_mdl) : o/mdl/%.o : ./modules/%.d
	${DCMP} -c $< ${DOUT}$@


clean:
	find o/ -type f -name '*.o' -delete
	rm -f *.bin

