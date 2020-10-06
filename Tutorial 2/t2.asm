option casemap:none             ; case sensitive
includelib legacy_stdio_definitions.lib ;lib needed for print f
extrn printf:near

.data; start of a data section
public g; export variable g

g QWORD 4; declare global variable g initialised to 4

.code; start of a code section

; min subroutine
; Calculates the smallest of 3 signed integers
; params:
;		rcx: 	a - first signed integer
;		rdx: b - second signed integer
;		r8: c - third signed integer
; return: 	v	- signed integer returned in rax

public	min
min:		mov rax, rcx		;v=a
			cmp rdx, rax		;if(b<v)
			jge secIf
			mov rax, rdx		;{b=v}

secIf:		cmp r8, rax			;if(c<v)
			jge endRet			
			mov rax, r8			;v=c

endRet:		ret	


; p subroutine
; params:
;		rcx:	i - first signed integer
;		rdx:	j - second signed integer
;		r8:		k	- third signed integer
;		r9:		l - fourth signed integer
;	return: min(min(g, i, j), k, l) - signed integer in rax 
public	p

p:			mov r10, rcx		;tmpa=i
			mov r11, rdx		;tmpb=J
			mov r12, r8			;tmpc=k
			mov r13, r9			;tmpd=l

			;first call to min(g,i,j)
			sub rsp, 32			;allocate shadow space
			mov rcx, g			;first param constant g
			mov rdx, r10		;second param i
			mov r8, r11			;third param j
			call min
			add rsp, 32			;dealloc shadow space

			;second call to min(min(g,i,j)k,l)
			sub rsp, 32
			mov rcx, rax		;first param result of first call to min
			mov rdx, r12		;second param k
			mov r8, r13			;third param l
			call min
			add rsp, 32

			ret 0


; gcd subroutine
; Calculates the greatest common divisor of two values
; params:
;		rcx:	a - first integer
;		rdx: b - second integer
; return: signed integer in eax 
public gcd
gcd:		mov rax, rdx		;tmp=b
			test rax, rax		;if(b==0)
			jne els
			mov rax, rcx		;rax=a to return a 
			jmp endGCD

els:		mov rax, rcx		;tmp=a
			mov rbx, rdx		;tmp =b
			xor rdx, rdx		;clear rdx
			idiv rbx			;rdx=rax%rbx dst=a%b

			sub rsp, 32			;allocate shadow space
			mov rcx, rbx		;rcx=b
			;mov rdx, rdx		rdx=a%b
			call gcd
			add rsp, 32			;deallocate shdow space 

endGCD:		ret 0


;q
public q

strFormat		db "a = %I64d b = %I64d c = %I64d d = %I64d e = %I64d",0AH,00H
str2Format		db "sum = %I64d\n", 0AH, 00H

q:			mov r10, rcx		;tmp=a
			mov r11, rdx		;tmp=b
			mov r12, r8			;tmp=c
			mov r13, r9			;tmp=d
			mov r14, [rsp+40]	;tmp=e @rbp-24 on stack

			xor rax, rax		;clr rax
			add rax, rcx		;sum=a
			add rax, rdx		;sum a+b
			add rax, r8			;sum+=c
			add rax, r9			;sum+=d
			add rax, r14	;sum+=e @ rbp-24 on stack
			
			;call to printf
			push rbx
			sub rsp, 48			;allocate shadow spac
			mov rbx, rax		;preserve sum acrcoss fucntion call
			lea rcx, strFormat		;format string
			mov rdx, r10		;rdx=a
			mov r8, r11			;r8=b
			mov r9, r12			;r9=c
			mov [rsp+32], r13	;pushing d
			mov [rsp+40], r14	;pushing e
			call printf
			mov rax, rbx
			lea rcx, str2Format
			mov rdx, rax
			call printf
			mov rax, rbx
			add rsp, 48
			pop rbx


			ret	0



;qns
;comment in and out shadow space allocation lines
stringqns db "qns",0AH,00H
public qns
qns:
	rsp, 32 ; allocate shadow space
	lea rcx, stringqns
	call printf
	add rsp, 32 ; 
	ret 0
end