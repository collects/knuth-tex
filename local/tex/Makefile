# Make executable files for this workstation, using the master TeX sources

#PFLAGS= -I.. -temp=.
PFLAGS= -I.. -g
#PFLAGS= -I..
CFLAGS= -O -I..
PC= time pc

all: initex virtex

triptest: triptex
	-triptex < trip1.in
	mv trip.log tripin.log
	-triptex < trip2.in | tee trip.fot
	dvitype trip.dvi < dvitype.in > /dev/null
	mv dvitype.out trip.typ
	rm -f *.dif
	-diff tripin.log ../../dist/tex/tripin.log > tripin.log.dif
	-diff trip.log ../../dist/tex/trip.log > trip.log.dif
	-diff trip.fot ../../dist/tex/trip.fot > trip.fot.dif
	-diff trip.typ ../../dist/tex/trip.typ > trip.typ.dif
	more tripin.log.dif trip.log.dif trip.typ.dif trip.fot.dif

%.p: %.ch
	tangle ../../dist/tex/tex.web  $*.ch
	mv ../../dist/tex/tex.pool .
	mv ../../dist/tex/tex.p $*.p

initex.ch: ../../dist/tex/tex.web

virtex.ch: initex.ch ini_to_vir
	ini_to_vir initex.ch virtex.ch

triptex.ch: initex.ch ini_to_trip
	ini_to_trip initex.ch triptex.ch

%.o: %.p
	${PC} ${PFLAGS} -c $*.p

triptex.o: triptex.p
	${PC} -g ${PFLAGS} -c triptex.p

initex: initex.o ext.o
	pc ${PFLAGS} -o initex initex.o ext.o

virtex: virtex.o ext.o
	pc ${PFLAGS} -o virtex virtex.o ext.o

triptex: triptex.o ext.o
	pc -g ${PFLAGS} -o triptex triptex.o ext.o
	cp ../../dist/tex/trip.tex .

ext.o: ext.c ext.h ../h00vars.h ../texpaths.h
	cc ${CFLAGS} -c ext.c

plain.fmt: ../../dist/lib/plain.tex ../lib/local.tex
	-initex plain \\input local \\dump

install:        # doit make install
	mv initex virtex /usr/local/bin
	rm /usr/local/bin/tex
	ln /usr/local/bin/virtex /usr/local/bin/tex
	make plain.fmt

installtrip:	# when the trip test is satisfactory
	mv trip.tex tripin.log trip.log trip.fot trip.typ \
	    trip.dvi trip.tfm ../../dist/tex

clean:
	rm -f *.p *.o *~ *.tex triptex* *.dif trip.* tripin.log virtex.ch
	@echo "Remaining files should be:"
	@echo "Makefile      ext.h         initex.ch     tex.pool"
	@echo "dvitype.in    ini_to_trip*  plain.fmt     trip1.in"
	@echo "ext.c         ini_to_vir*   plain.log     trip2.in"

