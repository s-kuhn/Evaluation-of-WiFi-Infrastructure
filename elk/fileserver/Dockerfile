FROM golang:1.14 AS build-env

RUN mkdir -p /go/src/app
WORKDIR /go/src/app

# resolve dependency before copying whole source code
COPY go.mod .
COPY go.sum .
RUN go mod download

# copy other sources & build
COPY . /go/src/app
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o /go/bin/app

FROM ubuntu AS runtime-env
COPY --from=build-env /go/bin/app /usr/local/bin/app


# own code
RUN apt-get update
RUN apt-get install time -y
RUN apt-get update && \
    apt-get install -yq tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
RUN apt-get install sysstat -y
RUN apt-get install netcat -y

COPY ./sshd_config /etc/ssh/sshd_config
ADD entrypoint.sh /
RUN echo 'root:raspberry' | chpasswd
RUN apt update && apt install  openssh-server sudo -y
RUN service ssh start
#CMD ["/usr/sbin/sshd","-D"]

ENTRYPOINT ["/entrypoint.sh"]

#python3 && ln -sf python3 /usr/bin/python \