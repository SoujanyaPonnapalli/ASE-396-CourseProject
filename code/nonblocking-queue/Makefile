#!/usr/bin/make -f
SRC="default"

all:
	echo 'starting $(SRC)'
	spin -a $(SRC)
	gcc -O2 -o pan pan.c
	./pan -n

log:
	spin -t -p $(SRC).trail

clean:
	rm pan pan.* *.trail _spin*
