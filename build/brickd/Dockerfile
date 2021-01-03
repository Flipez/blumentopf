FROM ubuntu:latest
MAINTAINER Robert Mueller <code@brauser.io>

ENV BRICKD_VERSION 2.4.3

RUN apt-get update && apt-get install -y --no-install-recommends \
				pkg-config \
				libusb-1.0-0-dev \
				libudev-dev \
        ca-certificates \
        build-essential \
        curl \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -SL "https://github.com/Tinkerforge/brickd/archive/v${BRICKD_VERSION}.tar.gz" -o brickd.tar.gz \
	&& curl -SL "https://github.com/Tinkerforge/daemonlib/archive/brickd-${BRICKD_VERSION}.tar.gz" -o daemonlib.tar.gz \
	&& mkdir -p /usr/src/brickdaemon_${BRICKD_VERSION} \
	&& tar -xvf brickd.tar.gz -C /usr/src/brickdaemon_${BRICKD_VERSION} --strip-components=1 \
	&& mkdir -p /usr/src/brickdaemon_${BRICKD_VERSION}/src/daemonlib \
	&& tar -xvf daemonlib.tar.gz -C /usr/src/brickdaemon_${BRICKD_VERSION}/src/daemonlib --strip-components=1 \
	&& rm brickd.tar.gz \
	&& rm daemonlib.tar.gz \
	&& cd /usr/src/brickdaemon_${BRICKD_VERSION}/src/brickd \
	&& make \
	&& make install

WORKDIR /usr/src/brickdaemon_${BRICKD_VERSION}/src

EXPOSE 4223

CMD ["brickd/brickd"]