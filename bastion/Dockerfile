FROM alpine:3.20

RUN apk add --no-cache \
    bash \
    curl \
    busybox-extras \
    wget \
    mysql-client \
    iputils \
    bind-tools

CMD ["tail", "-f", "/dev/null"]
