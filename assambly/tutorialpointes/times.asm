section .text
	global _start

_start:
	mov edx,len
	mov ecx,stars
	mov ebx,1
	mov eax,4
	int 0x80
	mov	eax,1       ;system call number (sys_exit)
    int	0x80        ;call kernel


section .data
stars times 9 db '*'
len equ $ - stars	