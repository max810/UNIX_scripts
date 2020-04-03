# Will clean the build data
clean:
	rm *.out || true
	rm *.log || true

# UNinstalls the programm
uninstall:
	make clean
	rm ${HOME}/bin/pzpi-16-2-bekuzarov-maksym-lab5.out


# archives the whole shit into one tar.gz
archive:
	tar -czvf pzpi-16-2-bekuzarov-maksym-lab5.tar.gz Makefile configure.sh install.sh pzpi-16-2-bekuzarov-maksym-lab5.c misc.c misc.h README INSTALL LICENSE


all:
	gcc -o pzpi-16-2-bekuzarov-maksym-lab5.out pzpi-16-2-bekuzarov-maksym-lab5.c misc.c

run:
	gcc -o pzpi-16-2-bekuzarov-maksym-lab5.out pzpi-16-2-bekuzarov-maksym-lab5.c misc.c
	./pzpi-16-2-bekuzarov-maksym-lab5.out

install:
	chmod +x ./install.sh
	chmod +x ./configure.sh
	./configure.sh
	gcc -o pzpi-16-2-bekuzarov-maksym-lab5.out pzpi-16-2-bekuzarov-maksym-lab5.c misc.c
	./install.sh
