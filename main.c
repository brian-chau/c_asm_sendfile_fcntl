#include <fcntl.h>
#include <stdio.h>
#include <sys/sendfile.h>
#include <unistd.h>

int main(int argc, char** argv){
    int new_stdout_fd = fcntl(STDOUT_FILENO, F_GETFD);
    fcntl(STDOUT_FILENO, F_SETFL, new_stdout_fd & ~O_APPEND);
    sendfile(STDOUT_FILENO, open("a.txt", O_RDONLY), 0, 1000);
    printf("\n");
    printf("%d\n", F_GETFD);
    printf("%d\n", F_SETFD);
    return 0;
}
