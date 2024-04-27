#!/usr/bin/env sh

set -eaux pipefail;

if [ -z ${ENVIRONMENT_CONFIGURED+x} ]; then
    echo "Environment variables are not configured."
    # shellcheck source=/dev/null
    . "${PWD}/setup-environment.sh";
fi;
if [ -z ${FILESYSTEM_CONFIGURED+x} ]; then
    echo "Filesystem is not configured."
    # shellcheck source=/dev/null
    . "${PWD}/setup-filesystem.sh";
fi;
if [ -z ${REQUIREMENTS_CONFIGURED+x} ]; then
    echo "Build requirements are not installed."
    # shellcheck source=/dev/null
    . "${PWD}/install-requirements.sh";
fi;
if [ -z ${SYSTEM_CONFIGURED+x} ]; then
    echo "System wide stuff is not configured."
    # shellcheck source=/dev/null
    . "${PWD}/setup-system.sh";
fi;
