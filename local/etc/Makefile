# Make executable files for this workstation, using the master TeX sources

PFLAGS= -g -I..
CFLAGS= -g -I..
PC= gpc

all: vftovp vptovf

%.p: %.ch
	tangle ../../dist/etc/$*.web  $*.ch
# the next line formerly necessary; but not with Linux's (Web2C) tangle
#	mv ../../dist/etc/$*.p . 

%.ch: ../../dist/etc/%.web
	touch $*.ch

%.o: %.p
	${PC} ${PFLAGS} -c $*.p

dvityext.c: ../texware/dvityext.c
	cp ../texware/dvityext.c .

texwarext.h: ../texware/texwarext.h
	cp ../texware/texwarext.h .

dvityext.h: ../texware/dvityext.h
	cp ../texware/dvityext.h .

vftovp: vftovp.o dvityext.o
	${PC} ${PFLAGS} -o vftovp vftovp.o dvityext.o

vptovf: vptovf.o
	${PC} ${PFLAGS} -o vptovf vptovf.o dvityext.o

dvityext.o: dvityext.c ../GPCtypes.h ../texpaths.h

vptovf.o: texwarext.h

vftovp.o: dvityext.h

install:        # doit make install "PROG=vftovp"
	mv $(PROG) /usr/local/bin/$(PROG)

clean:
#	rm -f *.p *.o *~ dvityext.c ../../dist/etc/*.pool
	rm -f *.p *.o *~ dvityext.c *.pool core texwarext.h
