#!/bin/bash
for flag in APPEND ASYNC CLOEXEC CREAT DIRECT DIRECTORY DSYNC EXCL LARGEFILE NOATIME NOCTTY NOFOLLOW NONBLOCK PATH SYNC TMPFILE TRUNC; do
    printf '%s: ' O_$flag; echo O_$flag | gcc -D_GNU_SOURCE -include fcntl.h -E - | tail -n 1;
done
