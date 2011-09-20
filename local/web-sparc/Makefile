# Make executable files for this workstation, using the master TeX sources

PFLAGS= -O -I.. -temp=.
CFLAGS= -O -I..
PC= time pc

all: tangle weave

%.p: %.ch
	tangle ../../dist/web/$*.web  $*.ch
	mv ../../dist/web/$*.p .

%.ch: ../../dist/web/%.web
	touch $*.ch

%.o: %.p
	${PC} ${PFLAGS} -c $*.p

tangle: tangle.o tangext.o tangext.h
	pc ${PFLAGS} -o tangle tangle.o tangext.o

tangext.o: tangext.c ../h00vars.h

weave: weave.o weavext.o tangext.h
	pc ${PFLAGS} -o weave weave.o weavext.o

weavext.o: weavext.c ../h00vars.h

install:        # doit make install PROG=tangle
	mv ${PROG} /usr/local/bin/${PROG}

clean:		# we save tangle.p for emergency rebooting
	rm -f weave.p *.o *~ ../../dist/web/*.pool
