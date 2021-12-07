#!/usr/bin/env sh

# fedora-intel-remapped-nvme-device-support
# build-image.sh


set -eaux pipefail; \

HOST_IP=$(ip -4 addr show virbr0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'); \
export HOST_IP; \

sudo dnf install qemu lorax fedora-kickstarts pykickstart createrepo_c; \
cd fedora-custom-kernel/kernel/"${FEDORA_ARCH}"; \
createrepo .; \
screen -d -m python -m http.server 8080; \
cd ../..; \
mkdir image; \
cd image; \
sudo -E sh -c 'setenforce 0 && lorax -p Fedora\ "${FEDORA_VERSION}" -v "${FEDORA_VERSION}" -r "${FEDORA_VERSION}" -s http://localhost:8080/ -s https://dl.fedoraproject.org/pub/fedora/linux/releases/"${FEDORA_VERSION}"/Everything/"${FEDORA_ARCH}"/os/ -s https://dl.fedoraproject.org/pub/fedora/linux/updates/"${FEDORA_VERSION}"/Everything/"${FEDORA_ARCH}"/ ./result/ && setenforce 1'; \
ksflatten --config /usr/share/spin-kickstarts/fedora-live-workstation.ks -o flat-fedora-live-workstation.ks --version F"${FEDORA_VERSION}"; \
# shellcheck disable=SC2016
sed -i 's#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch"#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever\&arch=$basearch"#g' flat-fedora-live-workstation.ks; \
# shellcheck disable=SC2016
sed -i 's#repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#\# repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#g' flat-fedora-live-workstation.ks; \
sed -i "/^# repo --name=\"rawhide\" --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=rawhide\&arch=\$basearch/a repo --name='fedora' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-\$releasever\&arch=\$basearch" flat-fedora-live-workstation.ks; \
sed -i "/^repo --name='fedora' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-\$releasever\&arch=\$basearch/a repo --name='updates' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-f\$releasever\&arch=\$basearch" flat-fedora-live-workstation.ks; \
sed -i "/^repo --name='updates' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-f\$releasever\&arch=\$basearch/a repo --name='fedora-custom-kernel' --cost=1 --baseurl=http:\/\/${HOST_IP}:8080/" flat-fedora-live-workstation.ks; \
sed -i 's#part / --size=7680#part / --fstype="ext4" --size=10240#g' flat-fedora-live-workstation.ks; \
sudo -E sh -c 'setenforce 0 && livemedia-creator --make-iso --iso=result/images/boot.iso --ks flat-fedora-live-workstation.ks --releasever="${FEDORA_VERSION}" --macboot --resultdir=./live/ --live-rootfs-size 10 --iso-name Fedora-"${FEDORA_VERSION}" && setenforce 1'
