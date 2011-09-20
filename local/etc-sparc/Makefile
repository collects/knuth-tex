# Make executable files for this workstation, using the master TeX sources

PFLAGS= -O -I.. -temp=. -g
CFLAGS= -O -I.. -g
PC= time pc

all: vftovp vptovf

%.p: %.ch
	tangle ../../dist/etc/$*.web  $*.ch
	mv ../../dist/etc/$*.p .

%.ch: ../../dist/etc/%.web
	touch $*.ch

%.o: %.p
	${PC} ${PFLAGS} -c $*.p

access.o: access.c

dvityext.o: dvityext.c

access.c:
	cp ../texware/access.c .

dvityext.c:
	cp ../texware/dvityext.c .

vftovp: vftovp.o access.o dvityext.o
	${PC} ${PFLAGS} -o vftovp vftovp.o access.o dvityext.o

vptovf: vptovf.o access.o
	${PC} ${PFLAGS} -o vptovf vptovf.o access.o

dvityext.o: dvityext.c ../h00vars.h ../texpaths.h

install:        # doit make install "PROG=vftovp"
	mv $(PROG) /usr/local/bin/$(PROG)

clean:
	rm -f *.p *.o *~ access.c dvityext.c ../../dist/etc/*.pool
