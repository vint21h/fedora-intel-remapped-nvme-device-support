#!/usr/bin/env sh

# fedora-intel-remapped-nvme-device-support
# set-environment.sh


set -aux pipefail; \

# shellcheck disable=SC2034
FEDORA_VERSION="36"; \
# shellcheck disable=SC2034
FEDORA_ARCH="x86_64"; \
# shellcheck disable=SC2034
PATCH_URL="https://github.com/endlessm/linux/commit/70812177ce4709c20f4ca4977c15a6681680ab83.patch"; \
# shellcheck disable=SC2034
HOST_IP=$(ip -4 addr show virbr0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
