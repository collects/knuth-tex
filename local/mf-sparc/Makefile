# Make executable files for this workstation, using the master TeX sources

PFLAGS= -I..
CFLAGS= -g -I.. -I/usr/openwin/include
#CFLAGS= -O -I.. -I/usr/openwin/include
#LIBS= -lsuntool -lsunwindow -lpixrect
LIBS= -L/usr/openwin/lib -lxview -lolgx -lX11

PC= time pc

all: inimf

traptest: trapmf
	-trapmf < trap1.in
	mv trap.log trapin.log
	-trapmf < trap2.in | tee trap.fot
	gftype trap.72270gf trap.typ < gftype.in
	tftopl trap.tfm trap.pl
	rm -f *.dif
	-diff trapin.log ../../dist/mf/trapin.log > trapin.log.dif
	-diff trap.log ../../dist/mf/trap.log > trap.log.dif
	-diff trap.fot ../../dist/mf/trap.fot > trap.fot.dif
	-diff trap.typ ../../dist/mf/trap.typ > trap.typ.dif
	-diff trap.pl ../../dist/mf/trap.pl > trap.pl.dif
	more trapin.log.dif trap.log.dif trap.typ.dif trap.fot.dif trap.pl.dif

%.p: %.ch
	tangle ../../dist/mf/mf.web  $*.ch
	mv ../../dist/mf/mf.pool .
	mv ../../dist/mf/mf.p $*.p

inimf.ch: ../../dist/mf/mf.web

trapmf.ch: inimf.ch ini_to_trap
	ini_to_trap inimf.ch trapmf.ch

%.o: %.p
	${PC} ${PFLAGS} -c $*.p

trapmf.o: trapmf.p
	${PC} -g ${PFLAGS} -c trapmf.p

inimf: inimf.o ext.o mf_arith.o mf_sunwin.o
	pc ${PFLAGS} -o inimf inimf.o ext.o mf_arith.o mf_sunwin.o ${LIBS}

trapmf: trapmf.o ext.o mf_arith.o
	pc -g ${PFLAGS} -o trapmf trapmf.o ext.o mf_arith.o
	cp ../../dist/mf/trap.mf .

ext.o: ext.c ext.h ../h00vars.h ../mfpaths.h
	cc ${CFLAGS} -c ext.c

mf_arith.o: mf_arith.c
mf_sunwin.o: mf_sunwin.c

plain.base: ../../dist/lib/plain.mf ../lib/local.mf
	-inimf plain \\input local \\dump

install:        # doit make install
	mv inimf /usr/local/bin
	rm /usr/local/bin/mf
	ln /usr/local/bin/inimf /usr/local/bin/mf
	make plain.base

installtrap:	# when the trap test is satisfactory
	mv trap.mf trapin.log trap.log trap.fot trap.typ trap.pl ../../dist/mf

clean:
	rm -f *.p *.o *~ *.mf trapmf* trap.* trapin*
	@echo "Remaining files should be:"
	@echo "Makefile      gftype.in     mf.pool       mf_window.h   trap1.in"
	@echo "ext.c         ini_to_trap*  mf_arith.c    plain.base    trap2.in"
	@echo "ext.h         inimf.ch      mf_sunwin.c   plain.log"
