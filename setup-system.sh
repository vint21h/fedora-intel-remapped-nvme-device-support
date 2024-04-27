#!/usr/bin/env sh

set -eaux pipefail;

echo "Setting up system wide stuff...";

sudo -E sh -c 'setenforce 0';  # disabling SELinux enforcing mode
sudo systemctl start libvirtd;  # starting libvirt daemon
sleep 5;  # sleeping to give libvirtd time to start
REPO_HOST_IP=$(ip -4 addr show virbr0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}');  # getting host IP
export REPO_HOST_IP;

# mark system wide stuff is configured
SYSTEM_CONFIGURED="1";  # indicates system wide stuff is configured
export SYSTEM_CONFIGURED;

echo "System wide stuff configured successfully."
