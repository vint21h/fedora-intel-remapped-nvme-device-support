#!/usr/bin/env sh

# fedora-intel-remapped-nvme-device-support
# set-environment.sh


set -aux pipefail; \

FEDORA_VERSION="33"; \
FEDORA_ARCH="x86_64"; \
PATCH_URL="https://github.com/endlessm/linux/commit/085cc1148ff1e9bcf7d3245a53b240d6e90fb90d.patch"; \
HOST_IP=$(ip -4 addr show virbr0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

export FEDORA_VERSION; \
export FEDORA_ARCH; \
export PATCH_URL; \
export HOST_IP
