		global _printf
		global _start

section .data
		msg: db "Hel %sander%s", 0
		name: db  "Alex", 0
		bob: db "and Bob", 0


section .text

%define DEBUG


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%ifdef DEBUG
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_start:
		mov rdi, msg
		mov rsi, name
		mov rdx, bob
		call _printf

		mov rax, 0x3C		;exit64(rdi)
		xor rdi, rdi
		syscall

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%endif
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;==========================================================
;printf
;==========================================================
;----------------------------------------------------------
;
;----------------------------------------------------------
;
;
;==========================================================
_printf:	
		push rbp
        mov rbp, rsp
		
		push r9
		push r8
		push rcx
		push rdx
		push rsi

		xor rdx, rdx		; buffer
		dec rdx
		mov r8, rdi			; string
		dec r8
	
.next:	inc r8
		inc rdx				; distance between specifiers
		cmp byte [r8], 0	; end of str
		je .end
		cmp byte [r8], 0x25	; 0x25 = %
		jne .next
		
		inc r8
		mov rcx, [r8]		; specifier
		and rcx, 127		; mask = 0111 1111
		sub rcx, 'b'

		sub r8, rdx
		dec r8
		mov rsi, r8
		mov rax, 1
		mov rdi, rax
		push rcx
		syscall
		pop rcx
		add r8, rdx
		inc r8

		pop rsi
		jmp [.jumpTable + rcx*8]


.jumpTable:	dq .b			; binary mode
		dq .c			; char
		dq .d			; int
		times 10 dq (.default)
		dq .o			; octal
		times 3 dq (.default)
		dq .s			; string
		times 4 dq (.default)
		dq .x			; hex
		times 2 dq (.default)


.s:		mov rdi, rsi
		call __strlen		; in rdx - length
		mov rdi, 1
		mov rax, rdi
		syscall
		xor rdx, rdx		; buffer
		dec rdx
		jmp .next
		
		
		jmp .next

.c:		jmp .next

.d:		jmp .next

.b:		jmp .next

.o:		jmp .next

.x:		jmp .next

.default:	jmp .next			
		

.end:	mov rsi, r8
		sub rsi, rdx
		mov rax, 1
		mov rdi, rax
		syscall

		mov rsp, rbp
		pop rdi

		ret

;==========================================================
;strchr
;==========================================================
;----------------------------------------------------------
;The function that looks for the first occurence of
;a character in a string.
;----------------------------------------------------------
;Arguments:
;	1) rdi (pointer to the string)
;	2) al  (ascii code of the desired character)
;Returns:
;	1) rsi (pointer to the first occurrence of a
;		 character in a string)
;	2) zf  (1 if char was found, 0 otherwise)
;Destroys:
;	- FLAGS
;	- rsi
;==========================================================

__strchr:	push rdi 
 
		cld
.next:		
		cmp byte [rdi], 0
		je .end
		scasb			; sets zf=1 if char was found
		jne .next

		mov rsi, rdi
		dec rsi	
		pop rdi
		ret

.end:		
		or al, al		; sets zf = 0

		mov rsi, rdi	
		pop rdi
		ret

;==========================================================
;strlen
;==========================================================
;----------------------------------------------------------
;The function that finds the length of a string.
;----------------------------------------------------------
;Arguments:
;	1) rdi (pointer to the string)
;Returns:
;	1) rdx (string length)
;Destroys:
;	- FLAGS
;	- rdx
;==========================================================

__strlen:	push rdi

		xor rdx, rdx
		mov al, 0

.Next:		scasb
		je .End
		inc rdx
		jmp .Next	
	
.End:		pop rdi
		ret


