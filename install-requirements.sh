#!/usr/bin/env sh

set -eaux pipefail;

echo "Installing build requirements..."

# installing kernel and image build requirements
sudo dnf install -y \
wget \
fedpkg \
fedora-packager \
rpmdevtools \
ncurses-devel \
pesign \
grubby \
qemu \
lorax \
pykickstart \
createrepo_c \
screen \
sed \
coreutils;

# mark requirements are installed
REQUIREMENTS_CONFIGURED="1";  # indicates requirements are installed
export REQUIREMENTS_CONFIGURED;

echo "Build requirements successfully installed.";
