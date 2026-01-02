#!/bin/bash
set -e

# Enable debug logging if GITHUB_ACTION_DEBUG is set
if [ "${GITHUB_ACTION_DEBUG}" == "true" ]; then
  set -x
fi

# Export environment variables
export CCACHE_DIR=${CCACHE_DIR:-/ws/ccache}
export MAKEFLAGS=${MAKEFLAGS:--j2}

# Navigate to the repository directory
cd /github/workspace

# Start restoring ccache
date +%d-%m-%Y > /tmp/date

# Restore ccache using the provided cache key
# Note: Caching is typically handled outside the Docker action in the workflow
# If you need to handle caching within Docker, consider using ccache commands here

# Configure the build with CMake
mkdir -p build
cd build
cmake ..

# Build the project
make

# Build tests
make tests

# Run tests
make check ARGS="$MAKEFLAGS"

# Print the test log
cat build/tests/Testing/Temporary/LastTest.log

# Optionally, set outputs for artifact upload steps
# echo "::set-output name=artifact_path::/ws/<package_name>"
