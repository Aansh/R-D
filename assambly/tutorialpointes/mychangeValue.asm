section .data
name db 'Nikhil Soni '
len equ $ - name

section	.text
	global _start
_start:	
   
   mov	edx, len       ;message length
   mov	ecx, name   ;message to write
   mov	ebx,1       ;file descriptor (stdout)
   mov	eax,4       ;system call number (sys_write)
   int	0x80        ;call kernel
   mov	[name],  dword 'Nuha'    ; Changed the name to Nuha Soni
		;writing the name 'Nuha Soni'
   mov	edx,112       ;message length
   mov	ecx,name    ;message to write
   mov	ebx,1       ;file descriptor (stdout)
   mov	eax,4       ;system call number (sys_write)
   int	0x80        ;call kernel
	
   mov	eax,1       ;system call number (sys_exit)
   int	0x80        ;call kernel

