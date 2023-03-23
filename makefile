asm:
	nasm -f elf64 -g printf.asm -o printf.o

c:
	gcc -c -g main.c -o main.o

clear:
	rm -rf *.o

