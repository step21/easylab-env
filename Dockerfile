# Dockerfile for EasyLab development and deployment environment

MAINTAINER syso "syso@makea.org"

FROM ubuntu:16.04

CMD /sbin/init

# Install Go
RUN apt-get update &&  apt-get -y install curl git-core

RUN \
  mkdir -p /goroot && mkdir -p /gopath && \
  curl https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1

RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata && \
    apt-get install -y sudo && \
    echo "root ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/root && chmod 0440 /etc/sudoers.d/root

# Set environment variables.
ENV GOROOT /goroot
ENV GOPATH=/gopath
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH
ENV GO15VENDOREXPERIMENT 1
ENV TZ=Europe/Berlin

RUN mkdir -p $GOPATH/bin $GOROOT/bin

RUN \
  curl -sL https://deb.nodesource.com/setup_6.x | bash - 

RUN apt-get install -y nodejs build-essential dpkg-dev mysql-client && \
    go get github.com/beego/bee && \
    go get github.com/astaxie/beego/migration && \
    go get github.com/go-sql-driver/mysql && \
    go get github.com/lib/pq && \
    npm -g install bower grunt-cli && \
    curl https://glide.sh/get | bash

RUN touch /etc/inittab && \
    dpkg-divert --local --rename --add /sbin/initctl && \
    ln -sf /bin/true /sbin/initctl
    
COPY ./prepare-env.sh /prepare-env.sh
RUN chmod +x /prepare-env.sh

RUN apt-get clean autoclean && \
    apt-get autoremove -y

EXPOSE 8080