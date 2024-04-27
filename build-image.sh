#!/usr/bin/env sh

set -eaux pipefail;

# shellcheck source=/dev/null
. "${PWD}/configure.sh";  # configure if necessary

if [ -d "${BUILD_DIR_PATH}/fedora-kickstarts" ]; then  # cleaning up Fedora kickstarts directory
  rm -rf "${BUILD_DIR_PATH}/fedora-kickstarts";
fi;

createrepo "${BUILD_DIR_PATH}/kernel/${FEDORA_ARCH}";  # creating repository metadata
screen -d -m -S "${LOCAL_REPO_SCREEN_SESSION_NAME}" python -m http.server -d "${BUILD_DIR_PATH}/kernel/${FEDORA_ARCH}" "${LOCAL_REPO_SERVER_PORT}";  # serve local packages repository
git clone "${FEDORA_KICKSTARTS_REPO_URL}" "${BUILD_DIR_PATH}/fedora-kickstarts";  # getting Fedora kickstarts (because fedora-kickstarts package removed from repository starting from 39 release)
ksflatten --config "${BUILD_DIR_PATH}/fedora-kickstarts/fedora-live-workstation.ks" -o "${BUILD_DIR_PATH}/fedora-kickstarts/flat-fedora-live-workstation.ks" --version F"${FEDORA_VERSION}";  # flatten .kickstart file
# patching .kickstart file
# shellcheck disable=SC2016
sed -i 's#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch"#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever\&arch=$basearch"#g' "${BUILD_DIR_PATH}/fedora-kickstarts/flat-fedora-live-workstation.ks";  # TODO: add comment
# shellcheck disable=SC2016
sed -i 's#repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#\# repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#g' "${BUILD_DIR_PATH}/fedora-kickstarts/flat-fedora-live-workstation.ks";  # commenting Fedora Rawhide repository
sed -i "/^# repo --name=\"rawhide\" --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=rawhide\&arch=\$basearch/a repo --name='fedora' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-\$releasever\&arch=\$basearch" "${BUILD_DIR_PATH}/fedora-kickstarts/flat-fedora-live-workstation.ks";  # adding Fedora repository to repositories list
sed -i "/^repo --name='fedora' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-\$releasever\&arch=\$basearch/a repo --name='updates' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-f\$releasever\&arch=\$basearch" "${BUILD_DIR_PATH}/fedora-kickstarts/flat-fedora-live-workstation.ks";  # adding updates repository to repositories list
sed -i "/^repo --name='updates' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-f\$releasever\&arch=\$basearch/a repo --name='fedora-custom-kernel' --cost=1 --baseurl=http:\/\/${REPO_HOST_IP}:8080/" "${BUILD_DIR_PATH}/fedora-kickstarts/flat-fedora-live-workstation.ks";  # adding local repository to repositories list
sed -i 's#part / --size=8192#part / --fstype="ext4" --size=12288#g' "${BUILD_DIR_PATH}/fedora-kickstarts/flat-fedora-live-workstation.ks";  # setting image filesystem and volume size
sed -i '/@x86-baremetal-tools/d' "${BUILD_DIR_PATH}/fedora-kickstarts/flat-fedora-live-workstation.ks";  # removing useless packages group
(
  cd "${IMAGE_BUILD_DIR_PATH}" || exit ;  # switching to image build directory
  sudo -E sh -c 'lorax -p Fedora\ "${FEDORA_VERSION}" -v "${FEDORA_VERSION}" -r "${FEDORA_VERSION}" -s http://localhost:8080/ -s https://dl.fedoraproject.org/pub/fedora/linux/releases/"${FEDORA_VERSION}"/Everything/"${FEDORA_ARCH}"/os/ -s https://dl.fedoraproject.org/pub/fedora/linux/updates/"${FEDORA_VERSION}"/Everything/"${FEDORA_ARCH}"/ "${IMAGE_BUILD_DIR_PATH}/result/"';  # building boot.iso
  sudo -E sh -c 'livemedia-creator --make-iso --iso="${IMAGE_BUILD_DIR_PATH}/result/images/boot.iso" --ks "${BUILD_DIR_PATH}/fedora-kickstarts/flat-fedora-live-workstation.ks" --releasever="${FEDORA_VERSION}" --macboot --resultdir="${IMAGE_BUILD_DIR_PATH}/live" --live-rootfs-size 10 --iso-name Fedora-"${FEDORA_VERSION}"';  # building image
)

# shellcheck source=/dev/null
. "${PWD}/clean-up.sh";  # cleaning up
