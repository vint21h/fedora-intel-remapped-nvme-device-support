#!/usr/bin/env sh

set -eaux pipefail;

# shellcheck source=/dev/null
. "${PWD}/configure.sh";  # configure if necessary

if [ -d "${KERNEL_BUILD_DIR_PATH}" ]; then  # cleaning up kernel build directory
  rm -rf "${KERNEL_BUILD_DIR_PATH}";
fi;
fedpkg clone -a kernel -b "f${FEDORA_VERSION}" "${KERNEL_BUILD_DIR_PATH}";  # getting Fedora kernel sources
sudo dnf builddep "${KERNEL_SPEC_PATH}" -y;  # installing kernel build dependencies
wget -c "${KERNEL_PATCH_URL}" -O "${KERNEL_PATCH_PATH}";  # getting kernel patch
# patching kernel RPM .spec
sed -i 's/# define buildid .local/%define buildid .local/g' "${KERNEL_SPEC_PATH}";  # mark RPM as built locally
sed -i '/^Patch1: patch-%{patchversion}-redhat.patch/a Patch2: patch-intel-remapped-nvme-device-support.patch' "${KERNEL_SPEC_PATH}";  # adding custom kernel patch to RPM .spec
sed -i '/^ApplyOptionalPatch patch-%{patchversion}-redhat.patch/a ApplyOptionalPatch patch-intel-remapped-nvme-device-support.patch' "${KERNEL_SPEC_PATH}";  # adding custom kernel patch to RPM .spec
(
  cd "${KERNEL_BUILD_DIR_PATH}" || exit ;  # switching to kernel build directory
  fedpkg srpm;  # building SRPM
  fedpkg local;  # building RPMs
)
