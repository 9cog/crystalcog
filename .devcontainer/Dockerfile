FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
apt install -y python3-pip python3-tk && \
curl https://sh.rustup.rs -sSf | sh -s -- -y && \
apt install -y swi-prolog && \
apt install -y gcc
apt install -y rustc && \
apt install -y mono-devel
