#!/usr/bin/env sh

set -eaux pipefail;

echo "Setting up filesystem...";

# creating build required directories
mkdir "${BUILD_DIR_PATH}" -p;  # creating root build directory
mkdir "${IMAGE_BUILD_DIR_PATH}" -p;  # creating image build directory

# mark filesystem is configured
FILESYSTEM_CONFIGURED="1";  # indicates filesystem is configured
export FILESYSTEM_CONFIGURED;

echo "Filesystem configured successfully."
