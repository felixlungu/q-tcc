# Set if needed QHOME and before calling make
# QARCH is one of the following: l32,l64,l64arm,l64nosse,m64,w32,w64
CC=tcc
QHOME ?= $(HOME)/q
CFLAGS=-I$(QHOME)/c/c
LDFLAGS=-shared
QARCH ?= l64arm

cc.so: cc.c c.k
	$(CC) $(CFLAGS) $(LDFLAGS) -o cc.so cc.c -ltcc

install: cc.so 
	cp c.k $(QHOME)
	cp cc.so $(QHOME)/$(QARCH)

clean:
	rm cc.so

uninstall:
	rm $(QHOME)/c.k
	rm $(QHOME)/$(QARCH)/cc.so
