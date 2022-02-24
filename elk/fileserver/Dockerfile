FROM mayth/simple-upload-server

RUN apk update
RUN apk add openssh
ADD ./sshd_config /etc/ssh/sshd_config
RUN echo 'root:raspberry' | chpasswd
CMD ["/usr/sbin/sshd", "-D"]
EXPOSE 2200