#include <fcntl.h>
#include <stdio.h>
#include <sys/sendfile.h>
#include <unistd.h>

int main(int argc, char** argv){
    int old_flags = fcntl(STDOUT_FILENO, F_GETFD);
    fcntl(STDOUT_FILENO, F_SETFL, old_flags & ~O_APPEND);
    sendfile(STDOUT_FILENO, open("a.txt", O_RDONLY), 0, 1000);
    return 0;
}
