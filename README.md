# Fedora Intel remapped NVME device support

*or how to install Fedora to laptops with Intel remapped NVME devices without possibility switch the mode to AHCI*

Contents

* [Problem](#problem)
* [Possible solutions](#possible-solutions)
* [Build a custom kernel](#build-a-custom-kernel)
* [Build custom installation media](#build-custom-installation-media)
* [Licensing](#licensing)
* [Contacts](#contacts)

## Problem

Some new laptops, like [HP ENVY 15 Laptop](https://www.hp.com/us-en/shop/mdp/laptops/envy-15-204072--1) have problem with linux installation/work.
The reason is the manufacturers use Intel Rapid Storage Technology with NVME disks and, accordingly, in the UEFI of these devices [there is no possibility to switch these drives to AHCI mode](https://h30434.www3.hp.com/t5/Notebook-Boot-and-Lockup/envy-15-2020-ahci-mode/td-p/7703443), [DELL Inspiron 7490](https://www.dell.com/community/Linux-General/Inspiron-7490-BIOS-How-to-turn-off-intel-RAID-on-and-swith-disk/td-p/7388147) have that problem too.

The modern version of the Linux kernel does not provide support for this technology in such a combination and only shows a warning to the user to change the mode of the disks.
There are two sets of patches to make these disks work, from [Dan Williams](https://marc.info/?l=linux-ide&m=147709610621480&w=2), and another one from [Daniel Drake](https://lkml.org/lkml/2019/6/20/27) based on previous, but they have not been merged into the mainline kernel.

Bad thing - both of them are not applicable for the latest kernel version.

Good thing - Daniel Drake supports his patch in [Endless OS](https://endlessos.com/) custom kernel.

## Possible solutions

* Install and use [Endless OS](https://endlessos.com/).
* Use similar instruction for [Debian/Ubuntu](https://askubuntu.com/questions/1204648/install-ubuntu-on-dell-inspiron-14-7490/1232818#1232818).
* Build Fedora custom live/installation media with a custom kernel with applied remapped NVME device support patch.

## Some pre-requirements

Another machine with Fedora, installed and configured `sudo` is required.

Also, ~40G of free disk space and 2+ hours of free time is needed.

Setup environment variables:

```console
export FEDORA_VERSION="40"; \
export FEDORA_ARCH="x86_64"; \
export PATCH_URL="https://github.com/endlessm/linux/commit/1559f18a1b3122df5200c739963c52e21b108a9e.patch"; \
export FEDORA_KICKSTARTS_REPO_URL="https://pagure.io/fedora-kickstarts.git"
```

Or just source [set-environment.sh](setup-environment.sh) script from this repository.

```console
source set-environment.sh
```

## Build a custom kernel

* Install build tools:

    ```console
    sudo dnf install fedpkg fedora-packager rpmdevtools ncurses-devel pesign grubby
    ```

* Create working directory and enter to it:

   ```console
    mkdir fedora-custom-kernel
    ```

* Get kernel package sources:

    ```console
    fedpkg clone -a kernel
    ```

* Enter to the package source directory:

   ```console
    cd kernel
    ```

* Switch to desired fedora kernel branch:

   ```console
    git checkout -b local origin/f"${FEDORA_VERSION}"
    ```

* Install kernel build requirements:

   ```console
   sudo dnf builddep kernel.spec
   ```

* Get the latest patch from [Endless OS kernel repository](https://github.com/endlessm/linux/), it can be found by searching commit with [PCI: Add Intel remapped NVMe device support](https://github.com/endlessm/linux/commit/a2e548aaac239c9c3e79d61f5386856efaa98c4c) name.

    ```console
    wget -c "${PATCH_URL}" -O patch-intel-remapped-nvme-device-support.patch
    ```

* Update kernel package spec file (kernel.spec):

    1. Replace `# define buildid .local` by `%define buildid .local`
    2. Add `Patch2: patch-intel-remapped-nvme-device-support.patch` line after `Patch1: patch-%{patchversion}-redhat.patch`
    3. Add `ApplyOptionalPatch patch-intel-remapped-nvme-device-support.patch` line after `ApplyOptionalPatch patch-%{patchversion}-redhat.patch`

    Or using command line:

    ```console
    sed -i 's/# define buildid .local/%define buildid .local/g' kernel.spec
    sed -i '/^Patch1: patch-%{patchversion}-redhat.patch/a Patch2: patch-intel-remapped-nvme-device-support.patch' kernel.spec
    sed -i '/^ApplyOptionalPatch patch-%{patchversion}-redhat.patch/a ApplyOptionalPatch patch-intel-remapped-nvme-device-support.patch' kernel.spec
    ```

* Build source package (optional):

    ```console
    fedpkg srpm
    ```

* Build kernel packages:

    ```console
    fedpkg local
    ```

Or just use [build-kernel.sh](build-kernel.sh) script from this repository.

```console
./build-kernel.sh
```

Freshly built packages can be found in the [fedora-custom-kernel/kernel/x86_64](fedora-custom-kernel/kernel/x86_64) directory.

## Build custom installation media

* Install build tools:

    ```console
    sudo dnf install lorax fedora-kickstarts pykickstart createrepo_c screen
    ```

* Enter to the directory with freshly built kernel packages:

   ```console
    cd fedora-custom-kernel/kernel/x86_64
    ```

* Create repository metadata:

    ```console
    createrepo .
    ```

* Serve local repository with custom kernel packages:

    ```console
    screen -d -m python -m http.server 8080
    ```

* Switch to main directory:

    ```console
    cd ../..
    ```

* Create image build directory:

    ```console
    mkdir image
    ```

* Enter image build directory:

    ```console
    cd image
    ```

* Build boot image:

    ```console
    sudo sh -c 'setenforce 0 && lorax -p Fedora\ "${FEDORA_VERSION}" -v "${FEDORA_VERSION}" -r "${FEDORA_VERSION}" -s http://localhost:8080/ -s https://dl.fedoraproject.org/pub/fedora/linux/releases/"${FEDORA_VERSION}"/Everything/"${FEDORA_ARCH}"/os/ -s https://dl.fedoraproject.org/pub/fedora/linux/updates/"${FEDORA_VERSION}"/Everything/"${FEDORA_ARCH}"/ ./result/ && setenforce 1'
    ```

* Create flat kickstart file:

    ```console
    ksflatten --config /usr/share/spin-kickstarts/fedora-live-workstation.ks -o flat-fedora-live-workstation.ks --version F"${FEDORA_VERSION}"
    ```

* Update kickstart file:

    ```console
    sed -i 's#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch"#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever\&arch=$basearch"#g' flat-fedora-live-workstation.ks
    sed -i 's#repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#\# repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#g' flat-fedora-live-workstation.ks
    sed -i "/^# repo --name=\"rawhide\" --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=rawhide\&arch=\$basearch/a repo --name='fedora' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-\$releasever\&arch=\$basearch" flat-fedora-live-workstation.ks
    sed -i "/^repo --name='fedora' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-\$releasever\&arch=\$basearch/a repo --name='updates' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-f\$releasever\&arch=\$basearch" flat-fedora-live-workstation.ks
    sed -i "/^repo --name='updates' --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-f\$releasever\&arch=\$basearch/a repo --name='fedora-custom-kernel' --cost=1 --baseurl=http:\/\/${HOST_IP}:8080/" flat-fedora-live-workstation.ks
    sed -i 's#part / --size=7680#part / --fstype="ext4" --size=10240#g' flat-fedora-live-workstation.ks
    ```

* Build live/installation media image:

    ```console
    sudo -E sh -c 'setenforce 0 && livemedia-creator --make-iso --iso=result/images/boot.iso --ks flat-fedora-live-workstation.ks --releasever="${FEDORA_VERSION}" --macboot --resultdir=./live/ --live-rootfs-size 10 --iso-name Fedora-"${FEDORA_VERSION}" && setenforce 1'
    ```

Or just use [build-image.sh](build-image.sh) script from this repository.

```console
./build-image.sh
```

Congratulations, you have [fedora-custom-kernel/image/live/images/boot.iso](fedora-custom-kernel/image/live/images/boot.iso).

Now you can write it to DVD or USB flash drive using [Fedora Media Writer](https://getfedora.org/en/workstation/download/) and install it.

## Licensing

fedora-intel-remapped-nvme-device-support uses the Creative Commons Attribution Share Alike 4.0 International license.
Please check the LICENSE file for more details.

## Contacts

**Author**: Oleksii Andrushevych <vint21h@vint21h.pp.ua>

For contributors list see CONTRIBUTORS file.
