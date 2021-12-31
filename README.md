## C/Assembly using sendfile to print to stdout

Here, I used C and GCC Linux Intel-syntax assembly to read a file and print it out to the screen.

To build the C application:
```nash
$ gcc main.c -o main
```

To build the assembly application:
```console
$ gcc -masm=intel -nostdlib -static main.S -o main_asm
```

Here is the definition for the `sendfile` system call that I was trying to get to work:

```c
#include <sys/sendfile.h><br/>
ssize_t sendfile(int out_fd, int in_fd, off_t *offset, size_t count);
```

When I tried to use `sendfile` to write to the screen with the `STDOUT_FILENO` file descriptor, it would never work! 
```console
sendfile(STDOUT_FILENO, open("a.txt", O_RDONLY), 0, 1000);
```

To debug it, I wrote/built it in assembly and used the `strace` utility on it.
```console
$ strace ./main_asm
```

And I would get an `EINVAL Invalid Argument` error on the `sendfile` utility. The `man` page said that this might happen because the `out_fd` parameter has the `O_APPEND` flag on it. To check this, I needed to check the flags for the `STDOUT_FILENO` file descriptor.

I knew that the file descriptors were (0 = stdin, 1 = stdout, and 2 = stderr), so I ran the following command to check the flags for `/proc/self/fdinfo/1` for `STDOUT_FILENO`, and I got this as a result:

```console
$ cat /proc/self/fdinfo/1
pos:    0
flags:  0102002
mnt_id: 79
```

But I didn't know what the octal number that the `flags` represented! So I found the BASH script to print out the meanings of each flag, and when I ran it, I found that the `O_APPEND` flag is represented by the octal number `02000`. So in my assembly and C programs, I had to unset the `O_APPEND` flag before attempting to write to stdout.

To do this, I had to call the `fcntl` system call, whose definition from the `man` page is:
```c
#include <unistd.h><br/>
#include <fcntl.h><br/>
int fcntl(int fd, int cmd, ... /* arg */ );
```

...where `fd` represented the `STDOUT_FILENO`, `cmd` would be either `F_GETFD` (which has the value of `1`) or `F_SETFD` (which has the value of `2`), and `args` being the value where I modify the flags.

The `fcntl` call modifies the flags of the flags for the `STDOUT_FILENO` so that the `sendfile` system call can write them out through it.

In the C program, I printed out the `F_GETFD` and `F_SETFD` constants, so I could insert the contant values directly into the assembly file.

I also used my [Go application](https://github.com/brian-chau/go_x86_64_assembly_instruction_set) to look up the syscall definitions for `open`, `sendfile`, and `fcntl` to put them into my assembly file.

When I compiled both programs, they both read the `a.txt` file and wrote them out the stdout, displaying them to the screen.

