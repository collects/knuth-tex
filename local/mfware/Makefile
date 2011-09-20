# Make executable files for this workstation, using the master TeX sources

PFLAGS= -g -I..
CFLAGS= -g -I..
PC= gpc

all: gftype gftopk gftodvi mft pktype

%.p: %.ch
	tangle ../../dist/mfware/$*.web  $*.ch
#	mv ../../dist/mfware/$*.p .

pktype.p: pktype.ch
	tangle pktype.web pktype.ch

%.ch: ../../dist/mfware/%.web
	touch $*.ch

%.o: %.p
	${PC} ${PFLAGS} -c $*.p

gftype: gftype.o gftopk_ext.h gftopk_ext.o
	pc ${PFLAGS} -o gftype gftype.o gftopk_ext.o

gftopk: gftopk.o gftopk_ext.o gftopk_ext.h
	pc ${PFLAGS} -o gftopk gftopk.o gftopk_ext.o

pktype: pktype.o gftopk_ext.h gftopk_ext.o
	pc ${PFLAGS} -o pktype pktype.o gftopk_ext.o

gftodvi: gftodvi.o ext.o ../tex/ext.h
	pc ${PFLAGS} -o gftodvi gftodvi.o ext.o

gf2dvi.p: gf2dvi.ch
	cp ../../dist/mfware/gftodvi.web gf2dvi.web
	tangle gf2dvi.web gf2dvi.ch
	rm gf2dvi.web

gf2dvi: gf2dvi.o ext.o ../tex/ext.h
	pc $(PFLAGS) -o gf2dvi gf2dvi.o ext.o

ext.o: ../tex/ext.c
	cc ${CFLAGS} -c ../tex/ext.c

gftopk_ext.o: gftopk_ext.c

mft: mft.o weavext.o mft_ext.h mft_ext.o
	pc ${PFLAGS} -o mft mft.o mft_ext.o

install:        # doit make install "PROG=gftype"
	mv $(PROG) /usr/local/bin/$(PROG)

clean:
#	rm -f *.p *.o *~ ../../dist/mfware/*.pool
	rm -f *.p *.o *~ *.pool
