#!/usr/bin/env sh

set -aux pipefail;

echo "Setting up environment variables...";

# setting up environment variables
FEDORA_VERSION="40";  # Fedora version
FEDORA_ARCH="x86_64";  # Fedora architecture
FEDORA_KICKSTARTS_REPO_URL="https://pagure.io/fedora-kickstarts.git";  # Fedora kickstarts files repository URL
BUILD_DIR_NAME="fedora-custom-kernel";  # build directory name
BUILD_DIR_PATH="${PWD}/${BUILD_DIR_NAME}";  # build directory path
IMAGE_BUILD_DIR_PATH="${BUILD_DIR_PATH}/image";  # Fedora live image build directory path
KERNEL_BUILD_DIR_PATH="${BUILD_DIR_PATH}/kernel";  # kernel build directory path
KERNEL_SPEC_PATH="${BUILD_DIR_PATH}/kernel/kernel.spec";  # kernel RPM .spec path
KERNEL_PATCH_PATH="${BUILD_DIR_PATH}/kernel/patch-intel-remapped-nvme-device-support.patch";  # kernel patch path
KERNEL_PATCH_URL="https://github.com/endlessm/linux/commit/1559f18a1b3122df5200c739963c52e21b108a9e.patch";  # kernel patch URL
LOCAL_REPO_SERVER_PORT="8080";  # local repository server port
LOCAL_REPO_SCREEN_SESSION_NAME="repo-server";  # repository server screen session name

export FEDORA_VERSION;
export FEDORA_ARCH;
export FEDORA_KICKSTARTS_REPO_URL;
export BUILD_DIR_NAME;
export BUILD_DIR_PATH;
export IMAGE_BUILD_DIR_PATH;
export KERNEL_BUILD_DIR_PATH;
export KERNEL_SPEC_PATH;
export KERNEL_PATCH_PATH;
export KERNEL_PATCH_URL;
export LOCAL_REPO_SERVER_PORT;
export LOCAL_REPO_SCREEN_SESSION_NAME;

# mark environment variables are configured
ENVIRONMENT_CONFIGURED="1";  # indicates environment variables are configured
export ENVIRONMENT_CONFIGURED;

echo "Environment variables configured successfully."
