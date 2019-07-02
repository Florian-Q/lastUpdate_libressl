FROM ubuntu:latest

ENV PATH_LIBRESSL_EXTRACT /libressl

WORKDIR /tmp/libressl

RUN OFFICIAL_DEPO="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL" \
	&& apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		build-essential \
		automake \
	    autoconf \
	    libtool \
	    perl \
	    git \
	    curl \
	    wget \
	    gnupg \
	    tar \
	# script to get last number version of file "libressl-X.X.X.tar.gz"
	&& LAST_VERSION=$(wget -O - $OFFICIAL_DEPO | \
		grep '^<a href="libressl-.*\.tar\.gz">' | \
		awk 'BEGIN{FS="<a href=\"libressl-"} {print $2}' | \
		awk 'BEGIN{FS=".tar.gz\">"} {print $1}' | \
		sort -nr -t. -k1,1 -k2,2 -k3,3 | \
		head -n 1 ) \
	&& echo "the last version of LibreSSL is : $LAST_VERSION" \
	#
	&& LIBRESSL_TARBALL="libressl-$LAST_VERSION.tar.gz" \
	&& curl -fSL $OFFICIAL_DEPO/$LIBRESSL_TARBALL -o $LIBRESSL_TARBALL \
	&& curl -fSL $OFFICIAL_DEPO/$LIBRESSL_TARBALL.asc -o $LIBRESSL_TARBALL.asc \
	&& curl -fSL $OFFICIAL_DEPO/libressl.asc -o libressl.asc \
	&& gpg --import libressl.asc \
	&& gpg --batch --verify $LIBRESSL_TARBALL.asc $LIBRESSL_TARBALL \
	#
	&& tar -zxf $LIBRESSL_TARBALL \
	&& mv "libressl-$LAST_VERSION" $PATH_LIBRESSL_EXTRACT \
	&& cd $PATH_LIBRESSL_EXTRACT \
	&& ./configure --prefix=$PATH_LIBRESSL_EXTRACT/.openssl/ \
	&& make install-strip -j $(nproc)