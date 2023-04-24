section .text
global main
extern printf

main:
    push rax
    xor rax, rax
    mov rdi, buffer
    mov rsi, 7
    call printf
    pop rax
    xor rax, rax
    ret

buffer: db "Register = %d", 10, 0
someNum: dq 1.2345        ; двойной точности


