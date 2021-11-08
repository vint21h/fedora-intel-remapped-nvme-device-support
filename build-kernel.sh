#!/usr/bin/env sh

# fedora-intel-remapped-nvme-device-support
# build-kernel.sh


set -eaux pipefail; \

sudo dnf install fedpkg fedora-packager rpmdevtools ncurses-devel pesign grubby ;\
mkdir fedora-custom-kernel; \
cd fedora-custom-kernel; \
fedpkg clone -a kernel; \
cd kernel; \
git checkout -b local origin/f"${FEDORA_VERSION}"; \
sudo dnf builddep kernel.spec; \
wget -c "${PATCH_URL}" -O patch-intel-remapped-nvme-device-support.patch; \
sed -i 's/# define buildid .local/%define buildid .local/g' kernel.spec; \
sed -i '/^Patch1: patch-%{patchversion}-redhat.patch/a Patch2: patch-intel-remapped-nvme-device-support.patch' kernel.spec; \
sed -i '/^ApplyOptionalPatch patch-%{patchversion}-redhat.patch/a ApplyOptionalPatch patch-intel-remapped-nvme-device-support.patch' kernel.spec; \
fedpkg srpm; \
fedpkg local
