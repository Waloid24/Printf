printf : printf.o main.o
	gcc -no-pie main.o printf.o -o printf

printf.o : printf.asm
	nasm -f elf64 printf.asm -o printf.o

main.o : main.cpp
	gcc -c main.cpp -o main.o


debug:
	nasm -f elf64 -DDEBUG printf.asm -o printf.o
	ld printf.o -o printf
	./printf

clear:
	rm -rf *.o *.out

