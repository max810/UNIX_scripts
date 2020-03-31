all:
	gcc -o pzpi-16-2-bekuzarov-maksym-lab5.out pzpi-16-2-bekuzarov-maksym-lab5.c misc.c

install:
	chmod +x ./install.sh
	chmod +x ./configure.sh
	./configure.sh
	gcc -o pzpi-16-2-bekuzarov-maksym-lab5.out pzpi-16-2-bekuzarov-maksym-lab5.c misc.c
	./install.sh

uninstall:
	make clean
	rm ${HOME}/bin/pzpi-16-2-bekuzarov-maksym-lab5.out

clean:
	rm *.out || true
	rm *.log || true

run:
	gcc -o pzpi-16-2-bekuzarov-maksym-lab5.out pzpi-16-2-bekuzarov-maksym-lab5.c misc.c
	./pzpi-16-2-bekuzarov-maksym-lab5.out

archive:
	tar -czvf pzpi-16-2-bekuzarov-maksym-lab5.tar.gz Makefile configure.sh install.sh pzpi-16-2-bekuzarov-maksym-lab5.c misc.c misc.h README.md