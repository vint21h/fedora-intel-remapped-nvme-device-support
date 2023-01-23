#!/usr/bin/env sh

# fedora-intel-remapped-nvme-device-support
# set-environment.sh


set -aux pipefail; \

# shellcheck disable=SC2034
FEDORA_VERSION="37"; \
# shellcheck disable=SC2034
FEDORA_ARCH="x86_64"; \
# shellcheck disable=SC2034
PATCH_URL="https://github.com/endlessm/linux/commit/a2e548aaac239c9c3e79d61f5386856efaa98c4c.patch"; \
# shellcheck disable=SC2034
HOST_IP=$(ip -4 addr show virbr0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
