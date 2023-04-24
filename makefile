#======================My Printf=========================

printf : printf.o main.o
	@ gcc -no-pie main.o printf.o -o printf
	@ ./printf

printf.o : printf.asm
	@ nasm -f elf64 printf.asm -o printf.o

main.o : main.cpp
	@ g++ -c main.cpp -o main.o


#========================C + ASM=========================
# prcasm : casm.o main.o
prcasm : casm.o 
	g++ -no-pie casm.o -o casm
	./casm

casm.o:
	nasm -f elf64 c+asm.asm -o casm.o
#========================================================

clear:
	rm -rf *.o *.out
