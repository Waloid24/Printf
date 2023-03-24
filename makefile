asm:
	nasm -f elf64 -g printf.asm -o printf.o
	ld printf.o -o printf.out
	./printf.out
c:
	gcc -c -g main.c -o main.o

clear:
	rm -rf *.o *.out

