#!/usr/bin/env sh

set -eaux pipefail;

# shellcheck source=/dev/null
. "${PWD}/configure.sh";  # configure
# shellcheck source=/dev/null
. "${PWD}/build-kernel.sh";  # build kernel
# shellcheck source=/dev/null
. "${PWD}/build-image.sh";  # build image
# shellcheck source=/dev/null
. "${PWD}/clean-up.sh";  # cleaning up
