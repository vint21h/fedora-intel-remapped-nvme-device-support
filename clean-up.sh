#!/usr/bin/env sh

set -eaux pipefail;

echo "Revert back system wide stuff...";

sudo -E sh -c 'setenforce 1';  # enabling SELinux enforcing mode
sudo systemctl stop libvirtd;  # stopping libvirt daemon
screen -XS "${LOCAL_REPO_SCREEN_SESSION_NAME}" quit;  # stopping repository server screen session

echo "System wide stuff reverted successfully."
