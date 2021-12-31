.global _start
_start:
.intel_syntax noprefix
    mov rbp, 0x7478742e61 # "a.txt"
    push rbp
    mov rax, 0x02         # syscall number for open
    mov rdi, rsp          # arg1 = "a.txt"
    mov rsi, 0x00         # arg2 = flags -- 0 = O_RDONLY, 1 = O_WRONLY, 2 = O_RDWR
    mov rdx, 0x180        # arg3 = mode -- 0o600 = read and write only for owner
    syscall
    mov r13, rax          # save fid for open

    # Here, I'm going to remove the O_APPEND flag from the STDOUT_FILENO file descriptor's flags
    mov rax, 0x48         # syscall number for fcntl
    mov rdi, 1            # arg1 -- file descriptor. In this case, it's STDOUT_FILENO
    mov rsi, 1            # arg2 -- cmd. 1 = F_GETFD, 2 = F_SETFD
    syscall
    mov r12, rax          # Get the new file descriptor flags

    mov r8, 1024          # O_APPEND = 0o2000
    not r8                # ~O_APPEND
    and r12, r8           # new_fid = new_fid & ~O_APPEND
    mov rax, 0x48         # syscall number for fcntl
    mov rdi, 1            # arg1 -- original file descriptor = STDOUT_FILENO
    mov rsi, 2            # arg2 -- cmd. 1 = F_GETFD, 2 = F_SETFD
    mov rdx, r12          # arg3 -- args. In this case, the modified file descriptor flags without O_APPEND
    syscall

    mov rax, 0x28         # syscall number for sendfile
    mov rdi, 1            # arg1 = stdout
    mov rsi, r13          # arg2 = fid for open
    mov rdx, 0            # arg3 = offset
    mov r10, 0x1000       # arg4 = bytes to read
    syscall

    xor rax, rax          # Zero out the registers that were used
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx
    xor r13, r13
    xor r12, r12
    xor r10, r10
    mov rax, 0x3c         # syscall for exit
    syscall
