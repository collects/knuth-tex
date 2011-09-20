# Make executable files for this workstation, using the master TeX sources

PFLAGS= -g -I..
CFLAGS= -g -I..
PC= gpc

all: tangle weave

%.p: %.ch
	tangle ../../dist/web/$*.web  $*.ch
# the next line formerly necessary; but not with Linux's (Web2C) tangle
#	mv ../../dist/web/$*.p . 

%.ch: ../../dist/web/%.web
	touch $*.ch

%.o: %.p
	${PC} ${PFLAGS} -c $*.p

tangle: tangle.o tangext.o tangext.h
	pc ${PFLAGS} -o tangle tangle.o tangext.o

tangext.o: tangext.c ../GPCtypes.h

weave: weave.o tangext.o tangext.h
	pc ${PFLAGS} -o weave weave.o tangext.o

install:        # doit make install PROG=tangle
	mv ${PROG} /usr/local/bin/${PROG}

clean:		# we save tangle.p for emergency rebooting
#	rm -f weave.p *.o *~ ../../dist/web/*.pool
	rm -f weave.p *.o *~ *.pool

