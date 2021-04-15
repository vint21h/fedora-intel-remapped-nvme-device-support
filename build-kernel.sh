#!/usr/bin/env sh

# fedora-intel-remapped-nvme-device-support
# build-kernel.sh


set -eaux pipefail;

mkdir sudo dnf install fedpkg fedora-packager rpmdevtools ncurses-devel pesign grubby \
  && fedora-custom-kernel \
  && cd fedora-custom-kernel \
  && fedpkg clone -a kernel \
  && cd kernel \
  && git checkout -b local origin/f33 \
  && sudo dnf builddep kernel.spec \
  && wget -c https://github.com/endlessm/linux/commit/085cc1148ff1e9bcf7d3245a53b240d6e90fb90d.patch -O patch-intel-remapped-nvme-device-support.patch \
  && sed -i 's/# define buildid .local/%define buildid .local/g' kernel.spec \
  && sed -i '/^Patch1: patch-%{stableversion}-redhat.patch/a Patch2: patch-intel-remapped-nvme-device-support.patch' kernel.spec \
  && sed -i '/^ApplyOptionalPatch patch-%{stableversion}-redhat.patch/a ApplyOptionalPatch patch-intel-remapped-nvme-device-support.patch' kernel.spec \
  && fedpkg srpm \
  && fedpkg local;\
