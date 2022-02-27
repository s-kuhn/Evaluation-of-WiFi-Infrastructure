#!/bin/bash
ssh-keygen -A && \
exec /usr/sbin/sshd -D -e "$@" & \
/usr/local/bin/app -port 8888 -token 123 -upload_limit 100000000 /home/projektarbeit
