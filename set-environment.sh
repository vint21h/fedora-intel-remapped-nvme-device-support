#!/usr/bin/env sh

# fedora-intel-remapped-nvme-device-support
# set-environment.sh


set -aux pipefail; \

# shellcheck disable=SC2034
FEDORA_VERSION="35"; \
# shellcheck disable=SC2034
FEDORA_ARCH="x86_64"; \
# shellcheck disable=SC2034
PATCH_URL="https://github.com/endlessm/linux/commit/a7c44cdc49c405482f52effa7c874574ccde92af.patch"; \
# shellcheck disable=SC2034
HOST_IP=$(ip -4 addr show virbr0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
