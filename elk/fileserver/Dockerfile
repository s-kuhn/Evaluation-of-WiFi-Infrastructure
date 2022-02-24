FROM mayth/simple-upload-server

RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN apk add sysstat
ADD ./sshd_config /etc/ssh/sshd_config
ADD entrypoint.sh /
RUN apk add --update --no-cache openssh
RUN echo 'root:raspberry' | chpasswd
ENTRYPOINT ["/entrypoint.sh"]