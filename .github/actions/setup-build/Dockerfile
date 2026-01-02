# .github/actions/setup-build/Dockerfile

FROM ubuntu:20.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    ccache \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /github/workspace

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make sure the entrypoint script is executable
RUN chmod +x /entrypoint.sh

# Define the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
