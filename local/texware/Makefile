# Make executable files for this workstation, using the master TeX sources

PFLAGS= -g -I..
CFLAGS= -g -I..
PC= gpc

all: pooltype tftopl pltotf dvitype

%.p: %.ch
	tangle ../../dist/texware/$*.web  $*.ch
# the next line formerly necessary; but not with Linux's (Web2C) tangle
#	mv ../../dist/texware/$*.p .

%.ch: ../../dist/texware/%.web
	touch $*.ch

%.o: %.p
	${PC} ${PFLAGS} -c $*.p

pooltype: pooltype.o dvityext.o dvityext.h
	pc ${PFLAGS} -o pooltype pooltype.o dvityext.o

tftopl: tftopl.o dvityext.o dvityext.h
	pc ${PFLAGS} -o tftopl tftopl.o dvityext.o

pltotf: pltotf.o dvityext.o dvityext.h
	${PC} ${PFLAGS} -o pltotf pltotf.o dvityext.o

dvitype: dvitype.o dvityext.o dvityext.h
	${PC} ${PFLAGS} -o dvitype dvitype.o dvityext.o

dvityext.o: dvityext.c ../GPCtypes.h ../texpaths.h

install:        # doit make install "PROG=dvitype"
	mv $(PROG) /usr/local/bin/$(PROG)

clean:
#	rm -f *.p *.o *~ ../../dist/texware/*.pool
	rm -f *.p *.o *~ *.pool core

