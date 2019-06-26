FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
	build-essential \
	ca-certificates \
    automake \
    autoconf \
    libtool \
    perl \
    git 

WORKDIR /opt/libressl

RUN git clone --single-branch https://github.com/libressl-portable/portable.git .
RUN	./autogen.sh && ./configure LDFLAGS=-lrt --prefix=/opt/libressl/.openssl/
RUN make install-strip -j $(nproc) 