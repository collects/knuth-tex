# This is an example Makefile for the binarydemo program only

PFLAGS= -g
CFLAGS= -g
PC= gpc

bdemo: bdemo_ext.h bdemo_ext.o binarydemo.o
	${PC} ${PFLAGS} -o bdemo binarydemo.o bdemo_ext.o

clean:
	rm -f *.o *~ core btest bdemo

