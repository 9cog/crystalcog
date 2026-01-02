# Use an official Rust image as the base
FROM rust:latest

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y qemu qemu-system-x86 build-essential git && \
    rm -rf /var/lib/apt/lists/*

# Clone the Redox OS repository
RUN git clone https://gitlab.redox-os.org/redox-os/redox.git /redox
WORKDIR /redox

# Build Redox OS
RUN make all

# Default command to run Redox with QEMU
CMD ["make", "qemu"]
