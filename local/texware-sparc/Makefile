# Make executable files for this workstation, using the master TeX sources

PFLAGS= -O -I.. -temp=.
CFLAGS= -O -I..
PC= time pc

all: pooltype tftopl pltotf dvitype

%.p: %.ch
	tangle ../../dist/texware/$*.web  $*.ch
	mv ../../dist/texware/$*.p .

%.ch: ../../dist/texware/%.web
	touch $*.ch

%.o: %.p
	${PC} ${PFLAGS} -c $*.p

pooltype: pooltype.o
	${PC} ${PFLAGS} -o pooltype pooltype.o

tftopl: tftopl.o access.o
	${PC} ${PFLAGS} -o tftopl tftopl.o access.o

pltotf: pltotf.o access.o
	${PC} ${PFLAGS} -o pltotf pltotf.o access.o

dvitype: dvitype.o dvityext.o dvityext.h
	${PC} ${PFLAGS} -o dvitype dvitype.o dvityext.o

dvityext.o: dvityext.c ../h00vars.h ../texpaths.h

access.o: access.c

install:        # doit make install "PROG=dvitype"
	mv $(PROG) /usr/local/bin/$(PROG)

clean:
	rm -f *.p *.o *~ ../../dist/texware/*.pool
