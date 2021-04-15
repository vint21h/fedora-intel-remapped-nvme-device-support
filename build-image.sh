#!/usr/bin/env sh

# fedora-intel-remapped-nvme-device-support
# build-image.sh


set -eaux pipefail;

sudo dnf install lorax fedora-kickstarts pykickstart createrepo_c \
  && cd fedora-custom-kernel/kernel/x86_64 \
  && createrepo . \
  && cd ../.. \
  && mkdir image \
  && cd image \
  && sudo sh -c 'setenforce 0 && lorax -p Fedora\ 33 -v 33 -r 33 -s http://localhost:8080/ -s https://dl.fedoraproject.org/pub/fedora/linux/releases/33/Everything/x86_64/os/ -s https://dl.fedoraproject.org/pub/fedora/linux/updates/33/Everything/x86_64/ ./result/ && setenforce 1' \
  && ksflatten --config /usr/share/spin-kickstarts/fedora-live-workstation.ks -o flat-fedora-live-workstation.ks --version F33 \
  && sed -i 's#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch"#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever\&arch=$basearch"#g' flat-fedora-live-workstation.ks \
  && sed -i 's#repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#\# repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#g' flat-fedora-live-workstation.ks \
  && sed -i '/^# repo --name="rawhide" --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=rawhide\&arch=$basearch/a repo --name=fedora --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-$releasever\&arch=$basearch' flat-fedora-live-workstation.ks \
  && sed -i '/^repo --name=fedora --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-$releasever\&arch=$basearch/a repo --name=updates --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-$releasever\&arch=$basearch' flat-fedora-live-workstation.ks \
  && sed -i '/^repo --name=updates --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-$releasever\&arch=$basearch/a repo --name=fedora-custom-kernel --cost=1 --baseurl=https://fedora-custom-kernel-repo.s3.amazonaws.com/$releasever/$basearch/' flat-fedora-live-workstation.ks \
  && sudo sh -c 'setenforce 0 && livemedia-creator --make-iso --iso=result/images/boot.iso --ks flat-fedora-live-workstation.ks --releasever=33 --macboot --resultdir=./live/ --live-rootfs-size 10 && setenforce 1';\
