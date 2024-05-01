#!/usr/bin/env sh

set -eaux pipefail;

echo "Building image...";

# shellcheck source=/dev/null
. "${PWD}/configure.sh";  # configure if necessary

if [ -z ${KERNEL_BUILT+x} ]; then
    echo "Kernel was not built."
    # shellcheck source=/dev/null
    . "${PWD}/build-kernel.sh";
fi;

if [ -d "${FEDORA_KICKSTARTS_PATH}" ]; then  # cleaning up Fedora kickstarts directory
  rm -rf "${FEDORA_KICKSTARTS_PATH}";
fi;
createrepo "${KERNEL_BUILD_DIR_PATH}/${FEDORA_ARCH}";  # creating repository metadata
screen -d -m -S "${LOCAL_REPO_SCREEN_SESSION_NAME}" python -m http.server -d "${KERNEL_BUILD_DIR_PATH}/${FEDORA_ARCH}" "${LOCAL_REPO_SERVER_PORT}";  # serve local packages repository
git clone "${FEDORA_KICKSTARTS_REPO_URL}" "${FEDORA_KICKSTARTS_PATH}";  # getting Fedora kickstarts (because fedora-kickstarts package removed from repository starting from 39 release)
ksflatten --config "${FEDORA_KICKSTARTS_PATH}/fedora-live-workstation.ks" -o "${FEDORA_KICKSTART_FILE_PATH}" --version F"${FEDORA_VERSION}";  # flatten .kickstart file
# patching .kickstart file
# shellcheck disable=SC2016
sed -i 's#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch"#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever\&arch=$basearch"#g' "${FEDORA_KICKSTART_FILE_PATH}";  # disabling Fedora Rawhide repository
# shellcheck disable=SC2016
sed -i 's#repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#\# repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#g' "${FEDORA_KICKSTART_FILE_PATH}";  # disabling Fedora Rawhide repository
sed -i "/^# repo --name=\"rawhide\" --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=rawhide\&arch=\$basearch/a repo --name='fedora' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-\$releasever\&arch=\$basearch" "${FEDORA_KICKSTART_FILE_PATH}";  # adding Fedora repository to repositories list
sed -i "/^repo --name='fedora' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-\$releasever\&arch=\$basearch/a repo --name='updates' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-f\$releasever\&arch=\$basearch" "${FEDORA_KICKSTART_FILE_PATH}";  # adding updates repository to repositories list
sed -i "/^repo --name='updates' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-f\$releasever\&arch=\$basearch/a repo --name='fedora-custom-kernel' --cost=1 --baseurl=http:\/\/${REPO_HOST_IP}:8080/" "${FEDORA_KICKSTART_FILE_PATH}";  # adding local repository with custom kernel packages to repositories list
sed -i 's#part / --size=8192#part / --fstype="ext4" --size=12288#g' "${FEDORA_KICKSTART_FILE_PATH}";  # setting image filesystem type and volume size
sed -i '/@x86-baremetal-tools/d' "${FEDORA_KICKSTART_FILE_PATH}";  # removing useless packages group
(
  cd "${IMAGE_BUILD_DIR_PATH}" || exit ;  # switching to image build directory
  sudo -E sh -c 'lorax -p Fedora\ "${FEDORA_VERSION}" -v "${FEDORA_VERSION}" -r "${FEDORA_VERSION}" -s http://localhost:8080/ -s https://dl.fedoraproject.org/pub/fedora/linux/releases/"${FEDORA_VERSION}"/Everything/"${FEDORA_ARCH}"/os/ -s https://dl.fedoraproject.org/pub/fedora/linux/updates/"${FEDORA_VERSION}"/Everything/"${FEDORA_ARCH}"/ "${IMAGE_BUILD_DIR_PATH}/result/"';  # building Anaconda boot.iso
  sudo -E sh -c 'livemedia-creator --make-iso --iso="${IMAGE_BUILD_DIR_PATH}/result/images/boot.iso" --ks "${FEDORA_KICKSTART_FILE_PATH}" --releasever="${FEDORA_VERSION}" --macboot --resultdir="${IMAGE_BUILD_DIR_PATH}/live" --live-rootfs-size 10 --iso-name Fedora-"${FEDORA_VERSION}"';  # building image
)

# mark kernel as built
IMAGE_BUILT="1";  # indicates that image was built
export IMAGE_BUILT;

echo "Image built successfully."
