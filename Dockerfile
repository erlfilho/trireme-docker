# Trireme package for Scalable Database Systems Group
#
# SPDX-License-Identifier: GPL-2.0-only

FROM debian:buster

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

RUN echo 'root:root' | chpasswd

RUN apt-get update && apt-get -y dist-upgrade
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends \
        apt-utils \
        build-essential \
        ca-certificates\
        clang \
        cmake \
        curl \
        git \
        gnupg2 \
        less \
        libnuma-dev \
        libtool \
        llvm \
        python \
        sudo \
        time \
        vim \
        wget

RUN useradd -m -G sudo -s /bin/bash trireme && echo "trireme:trireme" | chpasswd
RUN echo "%sudo   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

USER trireme
WORKDIR /home/trireme

RUN git clone https://github.com/epfl-dias/trireme.git
WORKDIR trireme
COPY --chown=trireme:trireme patches/ patches
RUN /bin/sh -c 'for i in patches/* ; do patch < $i ;done'

COPY --chown=trireme:trireme scripts/run-tpcc.sh .
RUN chmod 0755 /home/trireme/trireme/run-tpcc.sh .
RUN ./run-tpcc.sh

CMD /bin/bash
